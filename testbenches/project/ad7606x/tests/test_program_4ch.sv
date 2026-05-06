// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2023-2026 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
//
//

`include "utils.svh"

import axi_vip_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_common_pkg::*;
import adc_api_pkg::*;
import pwm_gen_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

parameter SIMPLE_STATUS_CRC = 0;

program test_program_4ch (
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
  output logic [2:0] adc_config_mode);

  timeunit 1ns;
  timeprecision 1ps;

  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  adc_api adc_api;
  pwm_gen_api pwm_api;

  // --------------------------
  // Main procedure
  // --------------------------
  initial begin

    //creating environment
    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(`IRQ_C_BA),
      .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

    mng = new("", `TH.`MNG_AXI.inst.IF);
    ddr = new("", `TH.`DDR_AXI.inst.IF);

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    adc_api = new("ADC API",
                  base_env.mng.master_sequencer,
                  `AXI_AD7606X_BA);

    pwm_api = new("PWM API",
                  base_env.mng.master_sequencer,
                  `AXI_PWMGEN_BA);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    base_env.sys_reset();

    sanity_test();

    #100ns adc_config_number_of_channels();

    #100ns adc_config_SIMPLE_test();

    #200ns adc_config_CRC_test();

    #200ns adc_config_STATUS_test();

    #200ns adc_config_STATUS_CRC_test();

    #200ns adc_config_SIMPLE_test();

    #100ns db_transmission_test();

    base_env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  // fixed data for channels
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch1 = (`ADC_N_BITS == 18) ? 18'hAB322 : 16'hACCA;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch2 = (`ADC_N_BITS == 18) ? 18'h57311 : 16'h5CC5;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch3 = (`ADC_N_BITS == 18) ? 18'hA8CE2 : 16'hA33A;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch4 = (`ADC_N_BITS == 18) ? 18'h54CD1 : 16'h5335;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch5 = (`ADC_N_BITS == 18) ? 18'h32AB0 : 16'hCAAC;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch6 = (`ADC_N_BITS == 18) ? 18'h31570 : 16'hC55C;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch7 = (`ADC_N_BITS == 18) ? 18'hCEA83 : 16'h3AA3;
  bit [(`ADC_N_BITS == 18 ? 17 : 15):0]  tx_ch8 = (`ADC_N_BITS == 18) ? 18'hCD543 : 16'h3553;
  bit [ 7:0]            tx_status_1 = 8'h0;
  bit [ 7:0]            tx_status_2 = 8'h1;
  bit [ 7:0]            tx_status_3 = 8'h2;
  bit [ 7:0]            tx_status_4 = 8'h3;
  bit [ 7:0]            tx_status_5 = 8'h4;
  bit [ 7:0]            tx_status_6 = 8'h5;
  bit [ 7:0]            tx_status_7 = 8'h6;
  bit [ 7:0]            tx_status_8 = 8'h7;

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
    adc_api.axi_verify(GetAddrs(COMMON_REG_VERSION),
                       `SET_COMMON_REG_VERSION_VERSION('h000a0300));
    `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // Transfer Counter
  //---------------------------------------------------------------------------

  bit [31:0] transfer_cnt;
  assign transfer_cnt = rx_ch_count;

  initial begin
    forever begin
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
        32'h00000007: begin
                        tx_data_buf = tx_ch7;
                        if (`ADC_N_BITS == 18) begin
                          tx_data_buf = tx_ch4[17:2];
                        end
                      end
        32'h00000008: begin
                        if ((`ADC_N_BITS == 16) && (adc_config_mode == 2 || adc_config_mode == 3)) begin
                          tx_data_buf = {8'b0,tx_status_4};
                        end else if ((`ADC_N_BITS == 16) && (adc_config_mode == 0 || adc_config_mode == 1)) begin
                          tx_data_buf = tx_ch8;
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
        32'h0000000D: begin
                        if (`ADC_N_BITS == 18) begin
                          tx_data_buf = tx_ch7[17:2];
                        end
                      end
        32'h0000000E: begin
                        if ((`ADC_N_BITS == 16) && (adc_config_mode == 2 || adc_config_mode == 3)) begin
                          tx_data_buf = {8'b0,tx_status_7};
                        end
                        if (`ADC_N_BITS == 18) begin
                          if (adc_config_mode == 0 || adc_config_mode == 1) begin
                            tx_data_buf = {tx_ch1[1:0],14'b0};
                          end else if (adc_config_mode == 2 || adc_config_mode == 3) begin
                            tx_data_buf = {tx_ch1[1:0],5'b0,tx_status_1};
                          end
                        end
                      end
        32'h0000000F: begin
                        if (`ADC_N_BITS == 18) begin
                          tx_data_buf = tx_ch8[17:2];
                        end
                      end
        32'h00000010: begin
                        if ((`ADC_N_BITS == 16) && (adc_config_mode == 2 || adc_config_mode == 3)) begin
                          tx_data_buf = {8'b0,tx_status_8};
                        end
                        if (`ADC_N_BITS == 18) begin
                          if (adc_config_mode == 0 || adc_config_mode == 1) begin
                            tx_data_buf = {tx_ch1[1:0],14'b0};
                          end else if (adc_config_mode == 2 || adc_config_mode == 3) begin
                            tx_data_buf = {tx_ch1[1:0],5'b0,tx_status_1};
                          end
                        end
                      end
        32'h00000011: begin
                        if ((`ADC_N_BITS == 16) &&  adc_config_mode == 3) begin
                          tx_data_buf = {8'b0,tx_status_8};
                        end else if (`ADC_N_BITS == 18 && (adc_config_mode == 1 || adc_config_mode == 3)) begin
                          tx_data_buf = tx_crc;
                        end
                      end
        default: ;
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
    adc_api.reset(.ce_n(1'b0), .mmcm_rstn(1'b1), .rstn(1'b1));
    adc_api.set_adc_config_wr(32'h00002181);
    adc_api.get_adc_config_wr(config_SIMPLE);
    `INFO(("Config_SIMPLE is set up, ADC_CONFIG_WR contains 0x%h",config_SIMPLE), ADI_VERBOSITY_LOW);
    adc_api.set_adc_config_control(32'h00000001);
    adc_api.get_adc_config_control(config_wr_SIMPLE);
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE), ADI_VERBOSITY_LOW);

    `INFO(("Data on DB_O port: 0x%h",rx_db_o), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_control(32'h00000000);
    adc_api.get_adc_config_control(config_wr_SIMPLE);
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_wr(32'h00000000);
    adc_api.set_adc_config_control(32'h00000001);
    adc_api.set_adc_config_control(32'h00000000);

    adc_api.set_common_control_3(.crc_en(1'b0), .custom_control(8'h00));

    adc_config_mode = 3'h0;
  endtask

  task adc_config_CRC_test();
    adc_api.reset(.ce_n(1'b0), .mmcm_rstn(1'b1), .rstn(1'b1));
    adc_api.set_adc_config_wr(32'h00002185);
    adc_api.get_adc_config_wr(config_CRC);
    `INFO(("Config_CRC is set up, ADC_CONFIG_WR contains 0x%h",config_CRC), ADI_VERBOSITY_LOW);
    adc_api.set_adc_config_control(32'h00000001);
    adc_api.get_adc_config_control(config_wr_CRC);
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC), ADI_VERBOSITY_LOW);

    `INFO(("Data on DB_O port: 0x%h",rx_db_o), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_control(32'h00000000);
    adc_api.get_adc_config_control(config_wr_CRC);
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_wr(32'h00000000);
    adc_api.set_adc_config_control(32'h00000001);
    adc_api.set_adc_config_control(32'h00000000);

    adc_api.set_common_control_3(.crc_en(1'b1), .custom_control(8'h00));

    adc_config_mode = 3'h1;
  endtask

  task adc_config_STATUS_test();
    adc_api.reset(.ce_n(1'b0), .mmcm_rstn(1'b1), .rstn(1'b1));
    adc_api.set_adc_config_wr(32'h00002181);
    adc_api.get_adc_config_wr(config_STATUS);
    `INFO(("Config_SIMPLE is set up, ADC_CONFIG_WR contains 0x%h",config_STATUS), ADI_VERBOSITY_LOW);
    adc_api.set_adc_config_control(32'h00000001);
    adc_api.get_adc_config_control(config_wr_STATUS);
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_STATUS), ADI_VERBOSITY_LOW);

    `INFO(("Data on DB_O port: 0x%h",rx_db_o), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_control(32'h00000000);
    adc_api.get_adc_config_control(config_wr_CRC);
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_wr(32'h00000248);
    adc_api.get_adc_config_wr(config_STATUS);
    `INFO(("Config_STATUS is set up, ADC_CONFIG_WR contains 0x%h",config_STATUS), ADI_VERBOSITY_LOW);
    adc_api.set_adc_config_control(32'h00000001);
    adc_api.get_adc_config_control(config_wr_STATUS);
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_STATUS), ADI_VERBOSITY_LOW);

    `INFO(("Data on DB_O port: 0x%h",rx_db_o), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_control(32'h00000000);
    adc_api.get_adc_config_control(config_wr_CRC);
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_wr(32'h00000000);
    adc_api.set_adc_config_control(32'h00000001);
    adc_api.set_adc_config_control(32'h00000000);

    adc_api.set_common_control_3(.crc_en(1'b0), .custom_control(8'h02));

    adc_config_mode = 3'h2;
  endtask

  task adc_config_STATUS_CRC_test();
    adc_api.reset(.ce_n(1'b0), .mmcm_rstn(1'b1), .rstn(1'b1));
    adc_api.set_adc_config_wr(32'h00002185);
    adc_api.get_adc_config_wr(config_STATUS);
    `INFO(("Config_SIMPLE is set up, ADC_CONFIG_WR contains 0x%h",config_STATUS), ADI_VERBOSITY_LOW);
    adc_api.set_adc_config_control(32'h00000001);
    adc_api.get_adc_config_control(config_wr_STATUS);
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_STATUS), ADI_VERBOSITY_LOW);

    `INFO(("Data on DB_O port: 0x%h",rx_db_o), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_control(32'h00000000);
    adc_api.get_adc_config_control(config_wr_CRC);
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_wr(32'h00000248);
    adc_api.get_adc_config_wr(config_STATUS);
    `INFO(("Config_STATUS is set up, ADC_CONFIG_WR contains 0x%h",config_STATUS), ADI_VERBOSITY_LOW);
    adc_api.set_adc_config_control(32'h00000001);
    adc_api.get_adc_config_control(config_wr_STATUS);
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_STATUS), ADI_VERBOSITY_LOW);

    `INFO(("Data on DB_O port: 0x%h",rx_db_o), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_control(32'h00000000);
    adc_api.get_adc_config_control(config_wr_CRC);
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_CRC), ADI_VERBOSITY_LOW);

    adc_api.set_adc_config_wr(32'h00000000);
    adc_api.set_adc_config_control(32'h00000001);
    adc_api.set_adc_config_control(32'h00000000);

    adc_api.set_common_control_3(.crc_en(1'b1), .custom_control(8'h03));

    adc_config_mode = 3'h3;
  endtask

  task adc_config_number_of_channels();
    for (int i = 0; i < 4; i++) begin
      adc_api.enable_channel(i);
    end

    adc_config_mode = 3'h4;
  endtask

  //---------------------------------------------------------------------------
  // DB transmission test
  //---------------------------------------------------------------------------
  bit [31:0] capp_word;
  task db_transmission_test();
    transfer_status = 1;

    // Generate cnvst_n pulse using AXI_PWM_GEN
    pwm_api.reset();
    pwm_api.start();
    pwm_api.pulse_period_config(0, 'h64);
    pwm_api.pulse_width_config(0, 'h63);
    pwm_api.load_config();
    `INFO(("axi_pwm_gen started."), ADI_VERBOSITY_LOW);

    wait(rx_ch_count == num_of_transfers);

    // Stop pwm gen
    pwm_api.reset();
    `INFO(("axi_pwm_gen stopped."), ADI_VERBOSITY_LOW);
  endtask

endprogram
