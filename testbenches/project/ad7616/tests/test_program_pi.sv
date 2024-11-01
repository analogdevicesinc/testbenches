// ***************************************************************************
// ***************************************************************************
// Copyright 2022 (c) Analog Devices, Inc. All rights reserved.
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
import adi_regmap_pkg::*;
import adi_regmap_axi_ad7616_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_pwm_gen_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;

localparam AD7616_CTRL_RESETN         = 1;
localparam AD7616_CTRL_CNVST_EN       = 2;
localparam NUM_OF_TRANSFERS           = 10;

program test_program_pi (
  output [15:0] rx_db_i,
  input         rx_db_t,
  input         rx_rd_n,
  input         rx_wr_n,
  output        rx_cs_n,
  input  [15:0] rx_db_o,
  input         sys_clk,
  input         rx_busy);

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
  env = new("AD7616 Environment",
            `TH.`SYS_CLK.inst.IF,
            `TH.`DMA_CLK.inst.IF,
            `TH.`DDR_CLK.inst.IF,
            `TH.`SYS_RST.inst.IF,
            `TH.`MNG_AXI.inst.IF,
            `TH.`DDR_AXI.inst.IF);

  setLoggerVerbosity(ADI_VERBOSITY_NONE);
  env.start();

  //asserts all the resets for 100 ns
  `TH.`SYS_RST.inst.IF.assert_reset;
  #100
  `TH.`SYS_RST.inst.IF.deassert_reset;
  #100

  sanity_test();

  #100

  data_acquisition_test();

  env.stop();

  `INFO(("Test Done"), ADI_VERBOSITY_NONE);
  $finish;

end

wire        rx_rd_n_negedge_s;
wire        rx_rd_n_posedge_s;
reg         rx_rd_n_d;
reg         rx_rd_n_tmp;
reg [15:0]  tx_data_buf = 16'ha1b2;
bit [31:0]  dma_data_store_arr [(NUM_OF_TRANSFERS) - 1:0];
bit [31:0] transfer_cnt;
bit transfer_status = 0;

assign rx_db_i = tx_data_buf;

initial begin
  while(1) begin
    @(posedge sys_clk);
    rx_rd_n_tmp <= rx_rd_n;
    fork
      rx_rd_n_d <= rx_rd_n_tmp;
    join_none
  end
end

assign rx_rd_n_negedge_s = ~rx_rd_n & rx_rd_n_d;
assign rx_rd_n_posedge_s = rx_rd_n & ~rx_rd_n_d;

initial begin
  while(1) begin
    @(negedge rx_rd_n);
      tx_data_buf <= tx_data_buf + 16'h0808;
      if (transfer_status)
        if (transfer_cnt[0]) begin
          dma_data_store_arr [(transfer_cnt - 1)  >> 1] [15:0] = tx_data_buf;
        end else begin
          dma_data_store_arr [(transfer_cnt - 1) >> 1] [31:16] = tx_data_buf;
        end
      @(posedge rx_rd_n);
  end
end


//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test();
  axi_write (`AXI_AD7616_BA + GetAddrs(AXI_AD7616_REG_SCRATCH), `SET_AXI_AD7616_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
  axi_read_v (`AXI_AD7616_BA + GetAddrs(AXI_AD7616_REG_SCRATCH), `SET_AXI_AD7616_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
  `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
endtask

//---------------------------------------------------------------------------
// Transfer Counter
//---------------------------------------------------------------------------

initial begin
  while(1) begin
    @(posedge rx_rd_n);
  if (transfer_status)
        transfer_cnt <= transfer_cnt + 'h1;
        @(negedge rx_rd_n);
    end
end

//---------------------------------------------------------------------------
// Data Acquisition Test
//---------------------------------------------------------------------------

reg [31:0] rdata_reg;
bit [31:0] captured_word_arr [(NUM_OF_TRANSFERS) -1 :0];


task data_acquisition_test();
    // Start spi clk generator
    axi_write (`AD7616_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
      `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
      `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
      );

    // Configure pwm gen
    axi_write (`AD7616_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
    axi_write (`AD7616_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('h64)); // set PWM period
    axi_write (`AD7616_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
    `INFO(("Axi_pwm_gen started"), ADI_VERBOSITY_LOW);

     // Configure DMA
    env.mng.RegWrite32(`AD7616_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    env.mng.RegWrite32(`AD7616_DMA_BA + GetAddrs(DMAC_FLAGS),
      `SET_DMAC_FLAGS_TLAST(1) |
      `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
      ); // Use TLAST
    env.mng.RegWrite32(`AD7616_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH((NUM_OF_TRANSFERS*4)-1)); // X_LENGHTH = 1024-1
    env.mng.RegWrite32(`AD7616_DMA_BA + GetAddrs(DMAC_DEST_ADDRESS), `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA));  // DEST_ADDRESS

    // Configure AXI_AD7616
    axi_write (`AXI_AD7616_BA + GetAddrs(AXI_AD7616_REG_UP_CNTRL),
      `SET_AXI_AD7616_REG_UP_CNTRL_CNVST_EN(0) |
      `SET_AXI_AD7616_REG_UP_CNTRL_RESETN(0)
      );
    axi_write (`AXI_AD7616_BA + GetAddrs(AXI_AD7616_REG_UP_CNTRL), `SET_AXI_AD7616_REG_UP_CNTRL_RESETN(AD7616_CTRL_RESETN));
    axi_write (`AXI_AD7616_BA + GetAddrs(AXI_AD7616_REG_UP_CNTRL), `SET_AXI_AD7616_REG_UP_CNTRL_RESETN(AD7616_CTRL_RESETN) | `SET_AXI_AD7616_REG_UP_CNTRL_CNVST_EN(AD7616_CTRL_CNVST_EN));
    #10000
    axi_write (`AXI_AD7616_BA + GetAddrs(AXI_AD7616_REG_UP_CNTRL), `SET_AXI_AD7616_REG_UP_CNTRL_RESETN(AD7616_CTRL_RESETN));

    @(negedge rx_busy)
    #200

    transfer_status = 1;

    env.mng.RegWrite32(`AD7616_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer DMA

    wait(transfer_cnt == 2 * NUM_OF_TRANSFERS );

    #100
    @(negedge rx_rd_n_negedge_s);
    @(posedge sys_clk);
    transfer_status = 0;

    // Stop pwm gen
    axi_write (`AD7616_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1));
    `INFO(("Axi_pwm_gen stopped"), ADI_VERBOSITY_LOW);

    #200
    axi_write (`AXI_AD7616_BA + GetAddrs(AXI_AD7616_REG_UP_WRITE_DATA ), `SET_AXI_AD7616_REG_UP_WRITE_DATA_UP_WRITE_DATA(32'hDEAD));
    axi_read  (`AXI_AD7616_BA + GetAddrs(AXI_AD7616_REG_UP_READ_DATA ), rdata_reg);

    #2000

    for (int i=0; i<=((NUM_OF_TRANSFERS) -1); i=i+1) begin
      #1
      captured_word_arr[i] = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(`DDR_BA + 4*i);
    end

    if (captured_word_arr  != dma_data_store_arr) begin
      `ERROR(("Data Acquisition Test FAILED"));
    end else begin
      `INFO(("Data Acquisition Test PASSED"), ADI_VERBOSITY_LOW);
    end
endtask

endprogram
