// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018 (c) Analog Devices, Inc. All rights reserved.
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
//
`include "utils.svh"

import test_harness_env_pkg::*;
import adi_regmap_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_dac_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_common_pkg::*;

`define RX_DMA       32'h44A3_0000
`define AXI_AD4080   32'h44A0_0000
`define DDR_BASE     32'h8000_0000

program test_program;

  parameter BASE = `AXI_AD4080;

  parameter CH0 = 8'h00 * 4;
  parameter CH1 = 8'h10 * 4;
  parameter CH2 = 8'h20 * 4;
  parameter CH3 = 8'h30 * 4;

  parameter RX1_COMMON  = BASE + 'h00_00 * 4;
  parameter RX1_CHANNEL = BASE;

  parameter RX1_DLY = BASE + 'h02_00 * 4;

  parameter TX1_COMMON  = BASE + 'h10_00 * 4;
  parameter TX1_CHANNEL = BASE + 32'h0000_4000;

  test_harness_env env;
  bit [31:0] val;

  // --------------------------
  // Wrapper function for AXI read verify
  // --------------------------
  task axi_read_v();

      input   [31:0]  raddr;
      input   [31:0]  vdata;

  begin
    env.mng.RegReadVerify32(raddr,vdata);
  end
  endtask

  // --------------------------
  // Wrapper function for AXI write
  // --------------------------
  task axi_write;
    input [31:0]  waddr;
    input [31:0]  wdata;
  begin
    env.mng.RegWrite32(waddr,wdata);
  end
  endtask

  task axi_read(
    input   [31:0]  raddr,
    output  [31:0]  data);
  begin
    env.mng.RegRead32(raddr,data);
  end
  endtask
  // --------------------------
  // Main procedure
  // --------------------------
  initial begin

    //creating environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    #2ps;

    setLoggerVerbosity(2);
    env.start();

    //asserts all the resets for 100 ns
    `TH.`SYS_RST.inst.IF.assert_reset;
    #100
    `TH.`SYS_RST.inst.IF.deassert_reset;

    #1us;

    sanity_test;
    
    dma_test;

    // Tap value for lane 0
    axi_write (RX1_DLY + 'h0,15);
    axi_write (RX1_DLY + 'h4,10);

    `INFO(("Test Done"));

  end

  // --------------------------
  // Sanity test reg interface
  // --------------------------
  task sanity_test;
  begin
    //check ADC VERSION
    axi_read_v (RX1_COMMON + GetAddrs(REG_VERSION),
               `SET_REG_VERSION_VERSION('h000a0162));
  end
  endtask

  // --------------------------
  // Setup link
  // --------------------------
  task link_setup;
  begin

    int num_lanes = (`SINGLE_LANE==1) ? 1 : 2;
    int sdr_ddr_n = `SDR_DDR_N;

    // Configure Rx interface
    axi_write (RX1_COMMON + GetAddrs(ADC_COMMON_REG_CNTRL),
              num_lanes<<8 |
              sdr_ddr_n<<16);

    // pull out RX of reset
    axi_write (RX1_COMMON + GetAddrs(ADC_COMMON_REG_RSTN),
              `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    force system_tb.sync_n = 1'b1;
    #10;

  end
  endtask

  // --------------------------
  // Link teardown
  // --------------------------
  task link_down;
  begin
    // put RX in reset
    axi_write (RX1_COMMON + GetAddrs(ADC_COMMON_REG_RSTN),
               `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    #1000;
    force system_tb.sync_n = 1'b0;
    #10;
  end
  endtask


  // --------------------------
// Enable pattern
// --------------------------
task enable_pattern;
begin
   int num_lanes = (`SINGLE_LANE==1) ? 1 : 2;
    int sdr_ddr_n = `SDR_DDR_N;
    bit [31:0] sync_status = 32'b0;
  force system_tb.enable_pattern = 1'b1;
  axi_write (RX1_COMMON+GetAddrs(ADC_COMMON_REG_CNTRL), 1<<3 | num_lanes<<8 | sdr_ddr_n<<16);

  axi_read(RX1_COMMON+ GetAddrs(ADC_COMMON_REG_SYNC_STATUS), sync_status);

  while(sync_status == 31'b0)
    axi_read(RX1_COMMON+ GetAddrs(ADC_COMMON_REG_SYNC_STATUS), sync_status); 

  force system_tb.enable_pattern = 1'b0;

end
endtask


  // --------------------------
  // DMA test procedure
  // --------------------------
  task dma_test;
  begin

    //  -------------------------------------------------------
    //  Test DMA path
    //  -------------------------------------------------------

    link_setup;

    #1us;

    // Configure RX DMA
    axi_write (`RX_DMA+GetAddrs(DMAC_CONTROL),
               `SET_DMAC_CONTROL_ENABLE(1));
    axi_write (`RX_DMA+GetAddrs(DMAC_FLAGS),
               `SET_DMAC_FLAGS_TLAST(1));
    axi_write (`RX_DMA+GetAddrs(DMAC_X_LENGTH),
               `SET_DMAC_X_LENGTH_X_LENGTH(64*4-1));
    axi_write (`RX_DMA+GetAddrs(DMAC_DEST_ADDRESS),
               `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BASE+32'h00002000));
    axi_write (`RX_DMA+GetAddrs(DMAC_TRANSFER_SUBMIT),
               `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));


 
    enable_pattern;
    


 

//    check_captured_data(
//      .address (`DDR_BASE+'h00002000),
//      .length (64),
//      .step (1),
//      .max_sample(2048)
//    );

    link_down;

  end
  endtask

  // Check captured data against incremental pattern based on first sample
  // Pattern should be contiguous
  task check_captured_data(bit [31:0] address,
                           int length = 1024,
                           int step = 1,
                           int max_sample = 2048
                          );

    bit [31:0] current_address;
    bit [31:0] captured_word;
    bit [31:0] reference_word;
    bit [19:0] first;

    for (int i=0;i<length;i=i+1) begin
      current_address = address+(i*4);
      captured_word = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(current_address);
      if (i==0) begin
        first = captured_word[19:0];
      end else begin
        reference_word = (first + (i*step))%max_sample;

        if (captured_word !== reference_word) begin
          `ERROR(("Address 0x%h Expected 0x%h found 0x%h",current_address,reference_word,captured_word));
        end else begin
          `INFO(("Address 0x%h Expected 0x%h found 0x%h",current_address,reference_word,captured_word));
        end
      end

    end
  endtask

endprogram
