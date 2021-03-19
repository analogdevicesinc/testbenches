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
`include "test_harness_env.sv"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;

`define RX1_DMA      32'h44A3_0000
`define RX2_DMA      32'h44A4_0000
`define TX1_DMA      32'h44A5_0000
`define TX2_DMA      32'h44A6_0000
`define AXI_ADRV9001 32'h44A0_0000
`define DDR_BASE     32'h8000_0000

`define PN7 0
`define PN15 1
`define NIBBLE_RAMP 2
`define FULL_RAMP 3

program test_program;

  parameter CMOS_LVDS_N = 1;
  parameter SDR_DDR_N = 1;
  parameter SINGLE_LANE = 1;
  parameter SYNTH_R1_MODE = 0;
  parameter USE_RX_CLK_FOR_TX = 0;
  parameter DDS_DISABLE = 0;
  parameter IQCORRECTION_DISABLE = 1;

  parameter BASE = `AXI_ADRV9001;

  parameter CH0 = 8'h00 * 4;
  parameter CH1 = 8'h10 * 4;
  parameter CH2 = 8'h20 * 4;
  parameter CH3 = 8'h30 * 4;

  parameter RX1_COMMON  = BASE + 'h00_00 * 4;
  parameter RX1_CHANNEL = BASE + 'h01_00 * 4;

  parameter RX1_DLY = BASE + 'h02_00 * 4;

  parameter RX2_COMMON  = BASE + 'h04_00 * 4;
  parameter RX2_CHANNEL = BASE + 'h05_00 * 4;

  parameter RX2_DLY = BASE + 'h06_00 * 4;

  parameter TX1_COMMON  = BASE + 'h08_00 * 4;
  parameter TX1_CHANNEL = BASE + 'h09_00 * 4;

  parameter TX2_COMMON  = BASE + 'h10_00 * 4;
  parameter TX2_CHANNEL = BASE + 'h11_00 * 4;

  parameter TDD1 = BASE + 'h12_00 * 4;
  parameter TDD2 = BASE + 'h13_00 * 4;

  test_harness_env env;
  bit [31:0] val;
  int R1_MODE = 0;

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

  integer rate;
  initial begin
    case ({CMOS_LVDS_N[0],SINGLE_LANE[0],SDR_DDR_N[0]})
      3'b000 : rate = 2;
      3'b010 : rate = 4;
      3'b111 : rate = 8;
      3'b110 : rate = 4;
      3'b100 : rate = 1;
      3'b101 : rate = 2;
      default : rate = 1;
    endcase
  end

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

    setLoggerVerbosity(6);
    env.start();

    //set source synchronous interface clock frequency
    `TH.`SSI_CLK.inst.IF.set_clk_frq(.user_frequency(80000000));
    `TH.`SSI_CLK.inst.IF.start_clock;

    //asserts all the resets for 100 ns
    `TH.`SYS_RST.inst.IF.assert_reset;
    #100
    `TH.`SYS_RST.inst.IF.deassert_reset;

    #1us;

    sanity_test;

    // R2T2 tests
    R1_MODE = 0;

    pn_test(`NIBBLE_RAMP);
    pn_test(`FULL_RAMP);
    pn_test(`PN7);
    pn_test(`PN15);

    dds_test;

    dma_test;

    // independent R1T1 tests
    R1_MODE = 1;

    dma_test_ch2;

    `INFO(("Test Done"));

  end

  // --------------------------
  // Sanity test reg interface
  // --------------------------
  task sanity_test;
  begin

    //check ADC VERSION
    #100 axi_read_v (RX1_COMMON + 32'h0000000, 'h000a0162);
    #100 axi_read_v (RX2_COMMON + 32'h0000000, 'h000a0162);
    //check DAC VERSION
    #100 axi_read_v (TX1_COMMON + 32'h0000000, 'h00090162);
    #100 axi_read_v (TX2_COMMON + 32'h0000000, 'h00090162);
    // check DAC CONFIG
    #100 axi_read_v (TX1_COMMON + 32'h000000c, (USE_RX_CLK_FOR_TX * 1024) +
                                               (CMOS_LVDS_N * 128) +
                                               (SYNTH_R1_MODE * 16) +
                                               (DDS_DISABLE * 64) +
                                               (IQCORRECTION_DISABLE * 1));
    #100 axi_read_v (TX2_COMMON + 32'h000000c, (USE_RX_CLK_FOR_TX * 1024) +
                                               (CMOS_LVDS_N * 128) +
                                               (1 * 16) +
                                               (DDS_DISABLE * 64) +
                                               (IQCORRECTION_DISABLE * 1));
     // Check dummy constant regs
     #100 axi_read_v (RX1_COMMON + 32'h000008C, 'h8);
     #100 axi_read_v (RX2_COMMON + 32'h000008C, 'h8);
  end
  endtask

  // --------------------------
  // Setup link
  // --------------------------
  task link_setup(bit rx1_en = 1,
                  bit rx2_en = 1,
                  bit tx1_en = 1,
                  bit tx2_en = 1);
  begin
    // Configure Rx interface
    #100 axi_write (RX1_COMMON + 32'h00000044, (SDR_DDR_N << 16) | (SINGLE_LANE << 8) | (R1_MODE << 2));
    #100 axi_write (RX2_COMMON + 32'h00000044, (SDR_DDR_N << 16) | (SINGLE_LANE << 8) | (R1_MODE << 2));

    // Configure Tx interface
    #100 axi_write (TX1_COMMON + 32'h00000048, (SDR_DDR_N << 16) | (SINGLE_LANE << 8) | (R1_MODE << 5));
    #100 axi_write (TX2_COMMON + 32'h00000048, (SDR_DDR_N << 16) | (SINGLE_LANE << 8) | (R1_MODE << 5));
    #100 axi_write (TX1_COMMON + 32'h0000004c, rate-1);
    #100 axi_write (TX2_COMMON + 32'h0000004c, rate-1);

    // pull out TX of reset
    #100 axi_write (TX1_COMMON + 32'h00000040, tx1_en << 1 | tx1_en << 0);
    #100 axi_write (TX2_COMMON + 32'h00000040, tx2_en << 1 | tx2_en << 0);

    gen_mssi_sync;

    // pull out RX of reset
    #100 axi_write (RX1_COMMON + 32'h00000040, rx1_en << 1 | rx1_en << 0);
    #100 axi_write (RX2_COMMON + 32'h00000040, rx2_en << 1 | rx2_en << 0);

  end
  endtask

  // --------------------------
  // Link teardown
  // --------------------------
  task link_down;
  begin
    // put RX in reset
    #100 axi_write (RX1_COMMON + 32'h00000040, 0);
    #100 axi_write (RX2_COMMON + 32'h00000040, 0);
    // put TX in reset
    #100 axi_write (TX1_COMMON + 32'h00000040, 0);
    #100 axi_write (TX2_COMMON + 32'h00000040, 0);

    #1000;
  end
  endtask

  // --------------------------
  // Test pattern test
  // --------------------------
  task pn_test;
    input [3:0] pattern;
  begin

    reg [3:0] tx_pattern_map[0:3];
    reg [3:0] rx_pattern_map[0:3];

    tx_pattern_map[`PN7] = 6;
    tx_pattern_map[`PN15] = 7;
    tx_pattern_map[`NIBBLE_RAMP] = 10;
    tx_pattern_map[`FULL_RAMP] = 11;

    rx_pattern_map[`PN7] = 4;
    rx_pattern_map[`PN15] = 5;
    rx_pattern_map[`NIBBLE_RAMP] = 10;
    rx_pattern_map[`FULL_RAMP] = 11;

    link_setup;

    // enable test data for TX1
    #100 axi_write (TX1_CHANNEL + CH0 + 6'h18, tx_pattern_map[pattern]);
    #100 axi_write (TX1_CHANNEL + CH1 + 6'h18, tx_pattern_map[pattern]);
    #100 axi_write (TX1_CHANNEL + CH2 + 6'h18, tx_pattern_map[pattern]);
    #100 axi_write (TX1_CHANNEL + CH3 + 6'h18, tx_pattern_map[pattern]);

    // enable test data check for RX1
    #100 axi_write (RX1_CHANNEL + CH0 + 6'h18, rx_pattern_map[pattern]<<16);
    #100 axi_write (RX1_CHANNEL + CH1 + 6'h18, rx_pattern_map[pattern]<<16);
    #100 axi_write (RX1_CHANNEL + CH2 + 6'h18, rx_pattern_map[pattern]<<16);
    #100 axi_write (RX1_CHANNEL + CH3 + 6'h18, rx_pattern_map[pattern]<<16);

    // Allow initial OOS to propagate
    #15000;

    // clear PN OOS and PN ERR
    #100 axi_write (RX1_CHANNEL + CH0 + 6'h4, 7);
    #100 axi_write (RX1_CHANNEL + CH1 + 6'h4, 7);
    #100 axi_write (RX1_CHANNEL + CH2 + 6'h4, 7);
    #100 axi_write (RX1_CHANNEL + CH3 + 6'h4, 7);

    #10000;

    // check PN OOS and PN ERR flags
    #100 axi_read_v (RX1_COMMON + 32'h000005c, 'h001);

    link_down;

  end
  endtask

  // --------------------------
  // DDS test procedure
  // --------------------------
  task dds_test;
  begin

    //  -------------------------------------------------------
    //  Test DDS path
    //  -------------------------------------------------------

    link_setup;

    // Select DDS as source
    #100 axi_write (TX1_CHANNEL + CH0 + 6'h18, 0);
    #100 axi_write (TX1_CHANNEL + CH1 + 6'h18, 0);
    #100 axi_write (TX1_CHANNEL + CH2 + 6'h18, 0);
    #100 axi_write (TX1_CHANNEL + CH3 + 6'h18, 0);

    // enable normal data path for RX1
    #100 axi_write (RX1_CHANNEL + CH0 + 6'h18, 0);
    #100 axi_write (RX1_CHANNEL + CH1 + 6'h18, 0);
    #100 axi_write (RX1_CHANNEL + CH2 + 6'h18, 0);
    #100 axi_write (RX1_CHANNEL + CH3 + 6'h18, 0);

    // Configure tone amplitude and frequency
    #100 axi_write (TX1_CHANNEL + CH0 + 6'h0, 32'h00000fff);
    #100 axi_write (TX1_CHANNEL + CH1 + 6'h0, 32'h000007ff);
    #100 axi_write (TX1_CHANNEL + CH2 + 6'h0, 32'h000003ff);
    #100 axi_write (TX1_CHANNEL + CH3 + 6'h0, 32'h000001ff);
    #100 axi_write (TX1_CHANNEL + CH0 + 6'h4, 32'h00000100);
    #100 axi_write (TX1_CHANNEL + CH1 + 6'h4, 32'h00000200);
    #100 axi_write (TX1_CHANNEL + CH2 + 6'h4, 32'h00000400);
    #100 axi_write (TX1_CHANNEL + CH3 + 6'h4, 32'h00000800);

    // Enable Rx channel, enable sign extension
    #100 axi_write (RX1_CHANNEL + CH0 + 6'h0, 1 | (1 << 4) | (1 << 6));
    #100 axi_write (RX1_CHANNEL + CH1 + 6'h0, 1 | (1 << 4) | (1 << 6));
    #100 axi_write (RX1_CHANNEL + CH2 + 6'h0, 1 | (1 << 4) | (1 << 6));
    #100 axi_write (RX1_CHANNEL + CH3 + 6'h0, 1 | (1 << 4) | (1 << 6));

    // SYNC DAC channels
    #100 axi_write (TX1_COMMON+32'h0044, 32'h00000001);
    // SYNC ADC channels
    #100 axi_write (RX1_COMMON+32'h0044, 1<<3);

    #20000;

    link_down;

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

    // Init test data
    for (int i=0;i<2048*2 ;i=i+2) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+i*2,((i+1) << 16) | i ,15);
    end

    // Configure TX DMA
    env.mng.RegWrite32(`TX1_DMA+32'h400, 32'h00000001); // Enable DMA
    env.mng.RegWrite32(`TX1_DMA+32'h40c, 32'h00000001); // use CYCLIC
    env.mng.RegWrite32(`TX1_DMA+32'h418, 32'h00000FFF); // X_LENGHT = 4k
    env.mng.RegWrite32(`TX1_DMA+32'h414, `DDR_BASE+32'h00000000); // SRC_ADDRESS
    env.mng.RegWrite32(`TX1_DMA+32'h408, 32'h00000001); // Submit transfer DMA

    // Select DDS as source
    #100 axi_write (TX1_CHANNEL + CH0 + 6'h18, 2);
    #100 axi_write (TX1_CHANNEL + CH1 + 6'h18, 2);
    #100 axi_write (TX1_CHANNEL + CH2 + 6'h18, 2);
    #100 axi_write (TX1_CHANNEL + CH3 + 6'h18, 2);

    // enable normal data path for RX1
    #100 axi_write (RX1_CHANNEL + CH0 + 6'h18, 0);
    #100 axi_write (RX1_CHANNEL + CH1 + 6'h18, 0);
    #100 axi_write (RX1_CHANNEL + CH2 + 6'h18, 0);
    #100 axi_write (RX1_CHANNEL + CH3 + 6'h18, 0);

    // Enable Rx channel, enable sign extension
    #100 axi_write (RX1_CHANNEL + CH0 + 6'h0, 1 | (1 << 4) | (1 << 6));
    #100 axi_write (RX1_CHANNEL + CH1 + 6'h0, 1 | (1 << 4) | (1 << 6));
    #100 axi_write (RX1_CHANNEL + CH2 + 6'h0, 1 | (1 << 4) | (1 << 6));
    #100 axi_write (RX1_CHANNEL + CH3 + 6'h0, 1 | (1 << 4) | (1 << 6));

    // SYNC DAC channels
    #100 axi_write (TX1_COMMON+32'h0044, 32'h00000001);
    // SYNC ADC channels
    #100 axi_write (RX1_COMMON+32'h0044, 1<<3);

    link_setup;

    #20us;

    // Configure RX DMA
    env.mng.RegWrite32(`RX1_DMA+32'h080, 32'h00000001); // Mask SOT IRQ, Enable EOT IRQ
    env.mng.RegWrite32(`RX1_DMA+32'h400, 32'h00000001); // Enable DMA
    env.mng.RegWrite32(`RX1_DMA+32'h40c, 32'h00000006); // use TLAST
    env.mng.RegWrite32(`RX1_DMA+32'h418, 32'h000003FF); // X_LENGHTH = 1024-1
    env.mng.RegWrite32(`RX1_DMA+32'h410, `DDR_BASE+32'h00002000); // DEST_ADDRESS
    env.mng.RegWrite32(`RX1_DMA+32'h408, 32'h00000001); // Submit transfer DMA

    @(posedge system_tb.test_harness.axi_adrv9001_rx1_dma.irq);
    //Clear interrupt
    env.mng.RegWrite32(`RX1_DMA+32'h084, 32'h00000002);

    check_captured_data(
      .address (`DDR_BASE+'h00002000),
      .length (1024),
      .step (1),
      .max_sample(2048)
    );

  end
  endtask

  // --------------------------
  // DMA test procedure for Rx2/Tx2 independent pairs
  // --------------------------
  task dma_test_ch2;
  begin

    //  -------------------------------------------------------
    //  Test DMA path
    //  -------------------------------------------------------

    // Init test data
    for (int i=0;i<2048*2 ;i=i+2) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+i*2,((i+1) << 16) | i ,15);
    end

    // Configure TX DMA
    env.mng.RegWrite32(`TX2_DMA+32'h400, 32'h00000001); // Enable DMA
    env.mng.RegWrite32(`TX2_DMA+32'h40c, 32'h00000001); // use CYCLIC
    env.mng.RegWrite32(`TX2_DMA+32'h418, 32'h00000FFF); // X_LENGHT = 4k
    env.mng.RegWrite32(`TX2_DMA+32'h414, `DDR_BASE+32'h00000000); // SRC_ADDRESS
    env.mng.RegWrite32(`TX2_DMA+32'h408, 32'h00000001); // Submit transfer DMA

    // Select DDS as source
    #100 axi_write (TX2_CHANNEL + CH0 + 6'h18, 2);
    #100 axi_write (TX2_CHANNEL + CH1 + 6'h18, 2);

    // enable normal data path for RX1
    #100 axi_write (RX2_CHANNEL + CH0 + 6'h18, 0);
    #100 axi_write (RX2_CHANNEL + CH1 + 6'h18, 0);

    // Enable Rx channel, enable sign extension
    #100 axi_write (RX2_CHANNEL + CH0 + 6'h0, 1 | (1 << 4) | (1 << 6));
    #100 axi_write (RX2_CHANNEL + CH1 + 6'h0, 1 | (1 << 4) | (1 << 6));

    // SYNC DAC channels
    #100 axi_write (TX2_COMMON+32'h0044, 32'h00000001);
    // SYNC ADC channels
    #100 axi_write (RX2_COMMON+32'h0044, 1<<3);

    link_setup(0,1,0,1);

    #20us;

    // Configure RX DMA
    env.mng.RegWrite32(`RX2_DMA+32'h080, 32'h00000001); // Mask SOT IRQ, Enable EOT IRQ
    env.mng.RegWrite32(`RX2_DMA+32'h400, 32'h00000001); // Enable DMA
    env.mng.RegWrite32(`RX2_DMA+32'h40c, 32'h00000006); // use TLAST
    env.mng.RegWrite32(`RX2_DMA+32'h418, 32'h000003FF); // X_LENGHTH = 1024-1
    env.mng.RegWrite32(`RX2_DMA+32'h410, `DDR_BASE+32'h00002000); // DEST_ADDRESS
    env.mng.RegWrite32(`RX2_DMA+32'h408, 32'h00000001); // Submit transfer DMA

    @(posedge system_tb.test_harness.axi_adrv9001_rx2_dma.irq);
    //Clear interrupt
    env.mng.RegWrite32(`RX2_DMA+32'h084, 32'h00000002);

    check_captured_data(
      .address (`DDR_BASE+'h00002000),
      .length (1024),
      .step (1),
      .max_sample(2048)
    );

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
    bit [15:0] first;

    for (int i=0;i<length/2;i=i+2) begin
      current_address = address+(i*2);
      captured_word = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(current_address);
      if (i==0) begin
        first = captured_word[15:0];
      end else begin
        reference_word = (((first + (i+1)*step)%max_sample) << 16) | ((first + (i*step))%max_sample);

        if (captured_word !== reference_word) begin
          `ERROR(("Address 0x%h Expected 0x%h found 0x%h",current_address,reference_word,captured_word));
        end
      end

    end
  endtask

endprogram
