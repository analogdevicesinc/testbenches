// ***************************************************************************
// ***************************************************************************
// Copyright 2023 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsabilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
//
//

`include "utils.svh"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_pwm_gen_pkg::*;

parameter SIMPLE_STATUS_CRC = 0;

parameter CH0 = 8'h00 * 4;
parameter CH1 = 8'h10 * 4;
parameter CH2 = 8'h20 * 4;
parameter CH3 = 8'h30 * 4;
parameter CH4 = 8'h40 * 4;
parameter CH5 = 8'h50 * 4;

program test_program_6ch (
  input         rx_cnvst_n,
  output [15:0] rx_db_i,
  input         rx_db_t,
  input         rx_rd_n,
  input         rx_wr_n,
  input         rx_cs_n,
  output        rx_first_data,
  input         rx_data_ready,
  input  [ 3:0] rx_ch_count,
  input  [15:0] rx_db_o,
  input         sys_clk,
  output        rx_busy,
  output bit [2:0] adc_config_mode);

test_harness_env env;

// --------------------------
// Wrapper function for AXI read verif
// --------------------------
task axi_read_v(
    input   [31:0]  raddr,
    input   [31:0]  vdata);

  env.mng.RegReadVerify32(raddr,vdata);
endtask

task axi_read(
    input   [31:0]  raddr,
    output  [31:0]  data);

  env.mng.RegRead32(raddr,data);
endtask

// --------------------------
// Wrapper function for AXI write
// --------------------------
task axi_write(
  input [31:0]  waddr,
  input [31:0]  wdata);

  env.mng.RegWrite32(waddr,wdata);
endtask

// --------------------------
// Main procedure
// --------------------------
initial begin

  //creating environment
  env = new(`TH.`SYS_CLK.inst.IF,
            `TH.`DMA_CLK.inst.IF,
            `TH.`DDR_CLK.inst.IF,
            `TH.`SYS_RST.inst.IF,
            `TH.`MNG_AXI.inst.IF,
            `TH.`DDR_AXI.inst.IF);

  setLoggerVerbosity(6);
  env.start();

  //asserts all the resets for 100 ns
  `TH.`SYS_RST.inst.IF.assert_reset;
  #100
  `TH.`SYS_RST.inst.IF.deassert_reset;
  #100

  sanity_test();

  #100 adc_config_number_of_channels();

  #100 adc_config_SIMPLE_test();

  #200 adc_config_CRC_test();

  #200 adc_config_STATUS_test();

  #200 adc_config_STATUS_CRC_test();

  #200 adc_config_SIMPLE_test();

  #100 db_transmission_test();

  `INFO(("Test Done"));

  $finish;

end

  // fixed data for channels
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch1 = (`ADC_N_BITS == 18) ? 18'hAB322 : 16'hACCA;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch2 = (`ADC_N_BITS == 18) ? 18'h57311 : 16'h5CC5;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch3 = (`ADC_N_BITS == 18) ? 18'hA8CE2 : 16'hA33A;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch4 = (`ADC_N_BITS == 18) ? 18'h54CD1 : 16'h5335;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch5 = (`ADC_N_BITS == 18) ? 18'h32AB0 : 16'hCAAC;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch6 = (`ADC_N_BITS == 18) ? 18'h31570 : 16'hC55C;

  bit [ 7:0]            tx_status_1 = 8'h0;
  bit [ 7:0]            tx_status_2 = 8'h1;
  bit [ 7:0]            tx_status_3 = 8'h2;
  bit [ 7:0]            tx_status_4 = 8'h3;
  bit [ 7:0]            tx_status_5 = 8'h4;
  bit [ 7:0]            tx_status_6 = 8'h5;


  reg [15:0]  tx_data_buf = 16'h0;
  bit [15:0]  tx_crc;

  assign rx_db_i = tx_data_buf;
  assign tx_crc = (`ADC_N_BITS == 16) ? ((adc_config_mode == 1) ? 16'hE0E2 : ((adc_config_mode == 3) ? 16'h6B33 : 16'h0)) : ((adc_config_mode == 1) ? 16'hD885 : ((adc_config_mode == 3) ? 16'hAF8B : 16'h0));

  wire [4:0] num_of_transfers;
  assign num_of_transfers = (`ADC_N_BITS == 16) ? ((adc_config_mode == 0 ? 8 : (adc_config_mode == 1 ? 9 : (adc_config_mode == 2 ? 16 : 17)))) : ((adc_config_mode == 0 || adc_config_mode == 2) ? 16 : 17);

//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test();
    // check ADC VERSION
    axi_read_v (`AXI_AD7606X_BA + GetAddrs(COMMON_REG_VERSION),
                    `SET_COMMON_REG_VERSION_VERSION('h000a0300));
    $display("[%t] Sanity Test Done.", $time);
endtask

//---------------------------------------------------------------------------
// Transfer Counter
//---------------------------------------------------------------------------

bit [31:0] transfer_cnt;
assign transfer_cnt = rx_ch_count;

initial begin
  while (1) begin
    @(negedge rx_data_ready);
    case (transfer_cnt)
      32'h00000000: tx_data_buf = 16'h0;
      32'h00000001: begin
                      if (`ADC_N_BITS == 16) begin
                        tx_data_buf = tx_ch1;
                      end else if (`ADC_N_BITS == 18) begin
                        tx_data_buf = tx_ch1[17:2];
                      end
                    end
      32'h00000002: begin
                      if ((`ADC_N_BITS == 16) && (adc_config_mode == 2 || adc_config_mode == 3)) begin
                        tx_data_buf = {8'b0,tx_status_1};
                      end else if ((`ADC_N_BITS == 16) && (adc_config_mode == 0 || adc_config_mode == 1)) begin
                        tx_data_buf = tx_ch2;
                      end
                      if (`ADC_N_BITS == 18) begin
                        if (adc_config_mode == 0 || adc_config_mode == 1) begin
                          tx_data_buf = {tx_ch1[1:0],14'b0};
                        end else if (adc_config_mode == 2 || adc_config_mode == 3) begin
                          tx_data_buf = {tx_ch1[1:0],5'b0,tx_status_1};
                        end
                      end
                    end
      32'h00000003: begin
                      tx_data_buf = tx_ch3;
                      if (`ADC_N_BITS == 18) begin
                        tx_data_buf = tx_ch2[17:2];
                      end
                    end
      32'h00000004: begin
                      if ((`ADC_N_BITS == 16) && (adc_config_mode == 2 || adc_config_mode == 3)) begin
                        tx_data_buf = {8'b0,tx_status_2};
                      end else if ((`ADC_N_BITS == 16) && (adc_config_mode == 0 || adc_config_mode == 1)) begin
                        tx_data_buf = tx_ch4;
                      end
                      if (`ADC_N_BITS == 18) begin
                        if (adc_config_mode == 0 || adc_config_mode == 1) begin
                          tx_data_buf = {tx_ch1[1:0],14'b0};
                        end else if (adc_config_mode == 2 || adc_config_mode == 3) begin
                          tx_data_buf = {tx_ch1[1:0],5'b0,tx_status_1};
                        end
                      end
                    end
      32'h00000005: begin
                      tx_data_buf = tx_ch5;
                      if (`ADC_N_BITS == 18) begin
                        tx_data_buf = tx_ch3[17:2];
                      end
                    end
      32'h00000006: begin
                      if ((`ADC_N_BITS == 16) && (adc_config_mode == 2 || adc_config_mode == 3)) begin
                        tx_data_buf = {8'b0,tx_status_3};
                      end else if ((`ADC_N_BITS == 16) && (adc_config_mode == 0 || adc_config_mode == 1)) begin
                        tx_data_buf = tx_ch6;
                      end
                      if (`ADC_N_BITS == 18) begin
                        if (adc_config_mode == 0 || adc_config_mode == 1) begin
                          tx_data_buf = {tx_ch1[1:0],14'b0};
                        end else if (adc_config_mode == 2 || adc_config_mode == 3) begin
                          tx_data_buf = {tx_ch1[1:0],5'b0,tx_status_1};
                        end
                      end
                    end


      32'h00000009: begin
                      if (`ADC_N_BITS == 18) begin
                        tx_data_buf = tx_ch5[17:2];
                      end else begin
                        tx_data_buf = tx_crc;
                      end
                    end
      32'h0000000A: begin
                      if ((`ADC_N_BITS == 16) && (adc_config_mode == 2 || adc_config_mode == 3)) begin
                        tx_data_buf = {8'b0,tx_status_5};
                      end
                      if (`ADC_N_BITS == 18) begin
                        if (adc_config_mode == 0 || adc_config_mode == 1) begin
                          tx_data_buf = {tx_ch1[1:0],14'b0};
                        end else if (adc_config_mode == 2 || adc_config_mode == 3) begin
                          tx_data_buf = {tx_ch1[1:0],5'b0,tx_status_1};
                        end
                      end
                    end
      32'h0000000B: begin
                      if (`ADC_N_BITS == 18) begin
                        tx_data_buf = tx_ch6[17:2];
                      end
                    end
      32'h0000000C: begin
                      if ((`ADC_N_BITS == 16) && (adc_config_mode == 2 || adc_config_mode == 3)) begin
                        tx_data_buf = {8'b0,tx_status_6};
                      end
                      if (`ADC_N_BITS == 18) begin
                        if (adc_config_mode == 0 || adc_config_mode == 1) begin
                          tx_data_buf = {tx_ch1[1:0],14'b0};
                        end else if (adc_config_mode == 2 || adc_config_mode == 3) begin
                          tx_data_buf = {tx_ch1[1:0],5'b0,tx_status_1};
                        end
                      end
                    end

    endcase
  end
end

//---------------------------------------------------------------------------
// Configuration Test
//---------------------------------------------------------------------------

bit transfer_status = 0;
bit [31:0] config_CRC = 'h0; // CRC with channel static data setup
bit [31:0] config_SIMPLE = 'h0; // channel static data setup
bit [31:0] config_STATUS = 'h0; // channel static data setup + Status header
bit [31:0] config_STATUS_CRC = 'h0; // CRC with channel static data setup + Status header
bit [31:0] config_wr_CRC = 'h0; // write request sent result
bit [31:0] config_wr_SIMPLE = 'h0; // write request sent result
bit [31:0] config_wr_STATUS = 'h0; // write request sent result
bit [31:0] config_wr_STATUS_CRC = 'h0; // write request sent result
bit        ctrl_status_CRC = 'h0; // ctrl_status bit from ADC common core
bit        ctrl_status_SIMPLE = 'h0; // ctrl_status bit from ADC common core
bit        ctrl_status_STATUS = 'h0; // ctrl_status bit from ADC common core
bit        ctrl_status_STATUS_CRC = 'h0; // ctrl_status bit from ADC common core

task adc_config_SIMPLE_test();
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(1'b1)); //ADC common core out of reset
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00002181)); // set static data setup in device's reg 0x21
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), config_SIMPLE); // read last config result
    `INFO(("Config_SIMPLE is set up, ADC_CONFIG_WR contains 0x%h",config_SIMPLE));
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_SIMPLE); // read last config result
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE));

    `INFO(("Data on DB_O port: 0x%h",rx_db_o)); // read written data

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_SIMPLE); // read last config result
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE));

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00000000)); // set exit from register mode sequence
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)

    //set HDL config mode
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_CNTRL_3), 'h100); // set default

    adc_config_mode = 3'h0;
endtask

task adc_config_CRC_test();
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(1'b1)); //ADC common core out of reset
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00002185)); // set CRC and static data setup in device's reg 0x21
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), config_CRC); // read last config result
    `INFO(("Config_CRC is set up, ADC_CONFIG_WR contains 0x%h",config_CRC));
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_CRC); // read last config result
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC));

    `INFO(("Data on DB_O port: 0x%h",rx_db_o)); // read written data

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_CRC); // read last config result
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC));

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00000000)); // set exit from register mode sequence
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)

    //set HDL config mode
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_CNTRL_3), 'h101); // set default

    adc_config_mode = 3'h1;
endtask

task adc_config_STATUS_test();
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(1'b1)); //ADC common core out of reset
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00002181)); // static data setup in device's reg 0x21
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), config_STATUS); // read last config result
    `INFO(("Config_SIMPLE is set up, ADC_CONFIG_WR contains 0x%h",config_STATUS));
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_STATUS); // read last config result
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_STATUS));

    `INFO(("Data on DB_O port: 0x%h",rx_db_o)); // read written data

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_CRC); // read last config result
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC));

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00000248)); // set STATUS header in device's reg 0x02
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), config_STATUS); // read last config result
    `INFO(("Config_STATUS is set up, ADC_CONFIG_WR contains 0x%h",config_STATUS));
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_STATUS); // read last config result
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_STATUS));

    `INFO(("Data on DB_O port: 0x%h",rx_db_o)); // read written data

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_CRC); // read last config result
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC));

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00000000)); // set exit from register mode sequence
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)

    //set HDL config mode
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_CNTRL_3), 'h102); // set default

    adc_config_mode = 3'h2;
endtask

task adc_config_STATUS_CRC_test();
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(1'b1)); //ADC common core out of reset
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00002185)); // static data and CRC setup in device's reg 0x21
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), config_STATUS); // read last config result
    `INFO(("Config_SIMPLE is set up, ADC_CONFIG_WR contains 0x%h",config_STATUS));
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_STATUS); // read last config result
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_STATUS));

    `INFO(("Data on DB_O port: 0x%h",rx_db_o)); // read written data

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_CRC); // read last config result
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC));

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00000248)); // set STATUS header in device's reg 0x02
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), config_STATUS); // read last config result
    `INFO(("Config_STATUS is set up, ADC_CONFIG_WR contains 0x%h",config_STATUS));
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_STATUS); // read last config result
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_STATUS));

    `INFO(("Data on DB_O port: 0x%h",rx_db_o)); // read written data

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)
    axi_read(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_CRC); // read last config result
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC));

    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00000000)); // set exit from register mode sequence
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)

   //set HDL config mode
    axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_CNTRL_3), 'h103); // set default

    adc_config_mode = 3'h3;
endtask

task adc_config_number_of_channels();
    
    axi_write (`AXI_AD7606X_BA + CH0 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),`SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    axi_write (`AXI_AD7606X_BA + CH1 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),`SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    axi_write (`AXI_AD7606X_BA + CH2 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),`SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    axi_write (`AXI_AD7606X_BA + CH3 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),`SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    axi_write (`AXI_AD7606X_BA + CH4 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),`SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    axi_write (`AXI_AD7606X_BA + CH5 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),`SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));

   //set HDL config mode
   // axi_write(`AXI_AD7606X_BA + GetAddrs(ADC_COMMON_REG_CNTRL_3), 'h103); // set default

    adc_config_mode = 3'h4;
endtask

//---------------------------------------------------------------------------
// DB transmission test
//---------------------------------------------------------------------------
bit [31:0] capp_word;
task db_transmission_test();
    #100 transfer_status = 1;

    // Generate cnvst_n pulse using AXI_PWM_GEN
    axi_write (`AXI_PWMGEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
    axi_write (`AXI_PWMGEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(0)); // PWM_GEN reset in regmap (ACTIVE HIGH)
    axi_write (`AXI_PWMGEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('h64)); // set PWM period
    axi_write (`AXI_PWMGEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_WIDTH), `SET_AXI_PWM_GEN_REG_PULSE_X_WIDTH_PULSE_X_WIDTH('h63)); // set PWM pulse width
    axi_write (`AXI_PWMGEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
    $display("[%t] axi_pwm_gen started.", $time);

    wait(rx_ch_count == num_of_transfers);

    // Stop pwm gen
    axi_write (`AXI_PWMGEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1));
    $display("[%t] axi_pwm_gen stopped.", $time);
endtask

endprogram
