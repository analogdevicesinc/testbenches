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
import adi_regmap_dmac_pkg::*;
import adi_regmap_dac_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_jesd_tx_pkg::*;
import adi_regmap_jesd_rx_pkg::*;

`define RX1_DMA      32'h44A3_0000
`define TX1_DMA      32'h44A5_0000
`define AXI_ADRV9001 32'h44A0_0000
`define DDR_BASE     32'h8000_0000

`define PN7 0
`define PN15 1
`define NIBBLE_RAMP 2
`define FULL_RAMP 3

program test_program;

  parameter CMOS_LVDS_N = `CMOS_LVDS_N;
  parameter SDR_DDR_N = 1;
  parameter SINGLE_LANE = 1;
  parameter R1_MODE = 0;
  parameter USE_RX_CLK_FOR_TX = `USE_RX_CLK_FOR_TX;
  parameter DDS_DISABLE = 0;
  parameter IQCORRECTION_DISABLE = 1;

  parameter BASE = `AXI_ADRV9001;

  parameter CH0 = 8'h00 * 4;
  parameter CH1 = 8'h10 * 4;
  parameter CH2 = 8'h20 * 4;
  parameter CH3 = 8'h30 * 4;

  parameter RX1_COMMON  = BASE + 'h00_00 * 4;
  parameter RX1_CHANNEL = BASE;
  parameter RX1_DLY = BASE + 'h02_00 * 4;

  parameter RX2_COMMON  = BASE + 'h04_00 * 4;
  parameter RX2_CHANNEL = BASE + 'h05_00 * 4;

  parameter RX2_DLY = BASE + 'h06_00 * 4;

  parameter TX1_COMMON  = BASE + 'h08_00 * 4;
  parameter TX1_CHANNEL = BASE + 32'h0000_2000;

  parameter TX2_COMMON  = BASE + 'h10_00 * 4;
  parameter TX2_CHANNEL = BASE + 'h11_00 * 4;

  parameter TDD1 = BASE + 'h12_00 * 4;
  parameter TDD2 = BASE + 'h13_00 * 4;

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

    pn_test(`NIBBLE_RAMP);
    pn_test(`FULL_RAMP);
    pn_test(`PN7);
    pn_test(`PN15);

    dma_test;
    `INFO(("Test Done"));

  end

  // --------------------------
  // Sanity test reg interface
  // --------------------------
  task sanity_test;
  begin

    //check ADC VERSION
    #100 axi_read_v (RX1_COMMON + GetAddrs(REG_VERSION),
                    `SET_REG_VERSION_VERSION('h000a0162));
    #100 axi_read_v (RX2_COMMON + GetAddrs(REG_VERSION),
                    `SET_REG_VERSION_VERSION('h000a0162));
    //check DAC VERSION
    #100 axi_read_v (TX1_COMMON + GetAddrs(REG_VERSION),
                    `SET_REG_VERSION_VERSION('h00090162));
    #100 axi_read_v (TX2_COMMON + GetAddrs(REG_VERSION),
                    `SET_REG_VERSION_VERSION('h00090162));
    // check DAC CONFIG
    #100 axi_read_v (TX1_COMMON + GetAddrs(REG_CONFIG), (USE_RX_CLK_FOR_TX * 1024) +
                                               (CMOS_LVDS_N * 128) +
                                               (R1_MODE * 16) +
                                               (DDS_DISABLE * 64) +
                                               (IQCORRECTION_DISABLE * 1));
    #100 axi_read_v (TX2_COMMON + GetAddrs(REG_CONFIG), (USE_RX_CLK_FOR_TX * 1024) +
                                               (CMOS_LVDS_N * 128) +
                                               (1 * 16) +
                                               (DDS_DISABLE * 64) +
                                               (IQCORRECTION_DISABLE * 1));
    end
  endtask

  // --------------------------
  // Setup link
  // --------------------------
  task link_setup;
  begin
    // Configure Rx interface
    axi_write (RX1_COMMON + GetAddrs(adc_common_REG_CNTRL),
              `SET_adc_common_REG_CNTRL_R1_MODE(1) | (SDR_DDR_N << 16) | (SINGLE_LANE << 8));
    axi_write (RX2_COMMON + GetAddrs(adc_common_REG_CNTRL),
              `SET_adc_common_REG_CNTRL_R1_MODE(1) | (SDR_DDR_N << 16) | (SINGLE_LANE << 8));
    // Configure Tx interface
    axi_write (TX1_COMMON + GetAddrs(dac_common_REG_CNTRL_2),
              `SET_dac_common_REG_CNTRL_2_R1_MODE(1) | (SDR_DDR_N << 16) | (SINGLE_LANE << 8));
    axi_write (TX2_COMMON + GetAddrs(dac_common_REG_CNTRL_2),
              `SET_dac_common_REG_CNTRL_2_R1_MODE(1) | (SDR_DDR_N << 16) | (SINGLE_LANE << 8));
    axi_write (TX1_COMMON + GetAddrs(dac_common_REG_RATECNTRL),
              `SET_dac_common_REG_RATECNTRL_RATE(rate-1));
    axi_write (TX2_COMMON + GetAddrs(dac_common_REG_RATECNTRL),
              `SET_dac_common_REG_RATECNTRL_RATE(rate-1));

    // pull out TX of reset
    axi_write (TX1_COMMON + GetAddrs(dac_common_REG_RSTN),
              `SET_dac_common_REG_RSTN_RSTN(1));
    axi_write (TX2_COMMON + GetAddrs(dac_common_REG_RSTN),
              `SET_dac_common_REG_RSTN_RSTN(1));

    gen_mssi_sync;

    // pull out RX of reset
    axi_write (RX1_COMMON + GetAddrs(adc_common_REG_RSTN),
              `SET_adc_common_REG_RSTN_RSTN(1));
    axi_write (RX2_COMMON + GetAddrs(adc_common_REG_RSTN),
              `SET_adc_common_REG_RSTN_RSTN(1));

  end
  endtask

  // --------------------------
  // Link teardown
  // --------------------------
  task link_down;
  begin
    // put RX in reset
    axi_write (RX1_COMMON + GetAddrs(adc_common_REG_RSTN), 
              `SET_adc_common_REG_RSTN_RSTN(0));
    axi_write (RX2_COMMON + GetAddrs(adc_common_REG_RSTN),
              `SET_adc_common_REG_RSTN_RSTN(0));
    // put TX in reset
    axi_write (TX1_COMMON + GetAddrs(dac_common_REG_RSTN),
              `SET_dac_common_REG_RSTN_RSTN(0));
    axi_write (TX2_COMMON + GetAddrs(dac_common_REG_RSTN),
              `SET_dac_common_REG_RSTN_RSTN(0));

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
    axi_write (TX1_CHANNEL + CH0 + GetAddrs(dac_channel_REG_CHAN_CNTRL_7),
              `SET_dac_channel_REG_CHAN_CNTRL_7_DAC_DDS_SEL(tx_pattern_map[pattern]));
    axi_write (TX1_CHANNEL + CH1 + GetAddrs(dac_channel_REG_CHAN_CNTRL_7),
              `SET_dac_channel_REG_CHAN_CNTRL_7_DAC_DDS_SEL(tx_pattern_map[pattern]));
    axi_write (TX1_CHANNEL + CH2 + GetAddrs(dac_channel_REG_CHAN_CNTRL_7),
              `SET_dac_channel_REG_CHAN_CNTRL_7_DAC_DDS_SEL(tx_pattern_map[pattern]));
    axi_write (TX1_CHANNEL + CH3 + GetAddrs(dac_channel_REG_CHAN_CNTRL_7),
              `SET_dac_channel_REG_CHAN_CNTRL_7_DAC_DDS_SEL(tx_pattern_map[pattern]));

    // enable test data check for RX1
    axi_write (RX1_CHANNEL + CH0 + GetAddrs(adc_channel_REG_CHAN_CNTRL_3),
              `SET_adc_channel_REG_CHAN_CNTRL_3_ADC_PN_SEL(rx_pattern_map[pattern]));
    axi_write (RX1_CHANNEL + CH1 + GetAddrs(adc_channel_REG_CHAN_CNTRL_3),
              `SET_adc_channel_REG_CHAN_CNTRL_3_ADC_PN_SEL(rx_pattern_map[pattern]));
    axi_write (RX1_CHANNEL + CH2 + GetAddrs(adc_channel_REG_CHAN_CNTRL_3),
              `SET_adc_channel_REG_CHAN_CNTRL_3_ADC_PN_SEL(rx_pattern_map[pattern]));
    axi_write (RX1_CHANNEL + CH3 + GetAddrs(adc_channel_REG_CHAN_CNTRL_3),
              `SET_adc_channel_REG_CHAN_CNTRL_3_ADC_PN_SEL(rx_pattern_map[pattern]));

    // Allow initial OOS to propagate
    #15000;

    // clear PN OOS and PN ERR
    axi_write (RX1_CHANNEL + CH0 + GetAddrs(adc_channel_REG_CHAN_STATUS),
              `SET_adc_channel_REG_CHAN_STATUS_PN_ERR(1) |
              `SET_adc_channel_REG_CHAN_STATUS_PN_OOS(1) |
              `SET_adc_channel_REG_CHAN_STATUS_OVER_RANGE(1));
    axi_write (RX1_CHANNEL + CH1 + GetAddrs(adc_channel_REG_CHAN_STATUS),
              `SET_adc_channel_REG_CHAN_STATUS_PN_ERR(1) |
              `SET_adc_channel_REG_CHAN_STATUS_PN_OOS(1) |
              `SET_adc_channel_REG_CHAN_STATUS_OVER_RANGE(1));
    axi_write (RX1_CHANNEL + CH2 + GetAddrs(adc_channel_REG_CHAN_STATUS),
              `SET_adc_channel_REG_CHAN_STATUS_PN_ERR(1) |
              `SET_adc_channel_REG_CHAN_STATUS_PN_OOS(1) |
              `SET_adc_channel_REG_CHAN_STATUS_OVER_RANGE(1));
    axi_write (RX1_CHANNEL + CH3 + GetAddrs(adc_channel_REG_CHAN_STATUS),
              `SET_adc_channel_REG_CHAN_STATUS_PN_ERR(1) |
              `SET_adc_channel_REG_CHAN_STATUS_PN_OOS(1) |
              `SET_adc_channel_REG_CHAN_STATUS_OVER_RANGE(1)); 
    #10000;

    // check PN OOS and PN ERR flags
    axi_read_v (RX1_COMMON + GetAddrs(adc_common_REG_STATUS),
               `SET_adc_common_REG_STATUS_STATUS('h1));
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

  // --------------------------
  // DMA test procedure
  // --------------------------
  task dma_test;
  begin
    /*
    //  -------------------------------------------------------
    //  Test DDS path
    //  -------------------------------------------------------

    // Configure Transport Layer for DDS
    //

    
    axi_write (`ADC_TPL + GetAddrs(adc_channel_REG_CHAN_CNTRL),
               `SET_adc_channel_REG_CHAN_CNTRL_ENABLE(1));
    axi_write (`DAC_TPL + GetAddrs(dac_channel_REG_CHAN_CNTRL_7),
               `SET_dac_channel_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    axi_write (`DAC_TPL + GetAddrs(dac_channel_REG_CHAN_CNTRL_1),
               `SET_dac_channel_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
    axi_write (`DAC_TPL + GetAddrs(dac_channel_REG_CHAN_CNTRL_1),
               `SET_dac_channel_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));

    // Pull out TPL cores from reset
    axi_write (`DAC_TPL + GetAddrs(dac_common_REG_RSTN),
               `SET_dac_common_REG_RSTN_RSTN(1));
    axi_write (`ADC_TPL +  GetAddrs(adc_common_REG_RSTN),
               `SET_adc_common_REG_RSTN_RSTN(1));
    // Sync DDS cores
    axi_write (`DAC_TPL + GetAddrs(dac_common_REG_CNTRL_1),
               `SET_dac_common_REG_CNTRL_1_SYNC(1));
    //
    // Configure TX Link Layer
    //

    //LINK DISABLE
    axi_write (`AXI_JESD_TX + GetAddrs(jesd_tx_LINK_DISABLE),
               `SET_jesd_tx_LINK_DISABLE_LINK_DISABLE(1));
    //SYSREFCONF
    axi_write (`AXI_JESD_TX + GetAddrs(jesd_tx_SYSREF_CONF),
               `SET_jesd_tx_SYSREF_CONF_SYSREF_DISABLE(0));
    //CONF0
    axi_write (`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_CONF0), 
               `SET_jesd_tx_LINK_CONF0_OCTETS_PER_FRAME(`TX_JESD_F-1) | 
               `SET_jesd_tx_LINK_CONF0_OCTETS_PER_MULTIFRAME(`TX_JESD_F*`TX_JESD_K-1));
    axi_write (`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_CONF4),
               `SET_jesd_tx_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((`TX_JESD_F*`TX_JESD_K)/TX_OUT_BYTES-1));
    //CONF1
    axi_write (`AXI_JESD_TX + GetAddrs(jesd_tx_LINK_CONF1),
               `SET_jesd_tx_LINK_CONF1_SCRAMBLER_DISABLE(0));
    //LINK ENABLE
    axi_write (`AXI_JESD_TX + GetAddrs(jesd_tx_LINK_DISABLE),
               `SET_jesd_tx_LINK_DISABLE_LINK_DISABLE(0));
    //
    // Configure RX Link Layer
    //

    //LINK DISABLE
    axi_write (`AXI_JESD_RX + GetAddrs(jesd_rx_LINK_DISABLE),
               `SET_jesd_rx_LINK_DISABLE_LINK_DISABLE(1));
    //SYSREFCONF
    axi_write (`AXI_JESD_RX + GetAddrs(jesd_rx_SYSREF_CONF),
               `SET_jesd_rx_SYSREF_CONF_SYSREF_DISABLE(0));
    //CONF0
    axi_write (`AXI_JESD_RX + GetAddrs(jesd_rx_LINK_CONF0),
               `SET_jesd_rx_LINK_CONF0_OCTETS_PER_FRAME(`RX_JESD_F-1) | 
               `SET_jesd_rx_LINK_CONF0_OCTETS_PER_MULTIFRAME(`RX_JESD_F*`RX_JESD_K-1));
    axi_write(`AXI_JESD_RX + GetAddrs(jesd_rx_LINK_CONF4),
              `SET_jesd_rx_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((`RX_JESD_F*`RX_JESD_K)/RX_OUT_BYTES-1));

    //CONF1
    axi_write (`AXI_JESD_RX + GetAddrs(jesd_rx_LINK_CONF1),
               `SET_jesd_rx_LINK_CONF1_DESCRAMBLER_DISABLE(0));
    //LINK ENABLE
    axi_write (`AXI_JESD_RX + GetAddrs(jesd_rx_LINK_DISABLE),
               `SET_jesd_rx_LINK_DISABLE_LINK_DISABLE(0));
    //XCVR INIT
    //REG CTRL
    if (`JESD_MODE != "64B66B") begin
        axi_write (`RX_XCVR+32'h0020,32'h00001004);   // RXOUTCLK uses DIV2
        axi_write (`TX_XCVR+32'h0020,32'h00001004);

        axi_write (`RX_XCVR+32'h0010,32'h00000001);
        axi_write (`TX_XCVR+32'h0010,32'h00000001);
    end

    // Give time the PLLs to lock
    #35us;

    //Read status back
    // Check SYSREF_STATUS
    axi_read_v (`AXI_JESD_TX+GetAddrs(jesd_tx_SYSREF_STATUS),
                `SET_jesd_tx_SYSREF_STATUS_SYSREF_DETECTED(1));
    axi_read_v (`AXI_JESD_RX+GetAddrs(jesd_rx_SYSREF_STATUS),
                `SET_jesd_rx_SYSREF_STATUS_SYSREF_DETECTED(1));
    // Check if in DATA state and SYNC is 1
    axi_read_v (`AXI_JESD_RX+GetAddrs(jesd_rx_LINK_STATUS),
                `SET_jesd_rx_LINK_STATUS_STATUS_STATE(3));
    axi_read_v (`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_STATUS),
                `SET_jesd_tx_LINK_STATUS_STATUS_STATE('h3) | 
                `SET_jesd_tx_LINK_STATUS_STATUS_SYNC(ref_sync_status));

    //LINK DISABLE
    axi_write (`AXI_JESD_RX + GetAddrs(jesd_rx_LINK_DISABLE),
               `SET_jesd_rx_LINK_DISABLE_LINK_DISABLE(1));
    axi_write (`AXI_JESD_TX + GetAddrs(jesd_tx_LINK_DISABLE),
               `SET_jesd_tx_LINK_DISABLE_LINK_DISABLE(1));

    //  -------------------------------------------------------
    //  Test DAC FIFO path and RX DMA capture
    //  -------------------------------------------------------

    // Init test data
    // .step (1),
    // .max_sample(2048)
    for (int i=0;i<2048*2 ;i=i+2) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+i*2,(((i+1)) << 16) | i ,15);
    end

    // Configure TX DMA
    axi_write (`TX_DMA+GetAddrs(dmac_CONTROL),
              `SET_dmac_CONTROL_ENABLE(1));
    axi_write (`TX_DMA+GetAddrs(dmac_FLAGS),
               `SET_dmac_FLAGS_TLAST(1));
    axi_write (`TX_DMA+GetAddrs(dmac_X_LENGTH),
               `SET_dmac_X_LENGTH_X_LENGTH(32'h00000FFF));
    axi_write (`TX_DMA+GetAddrs(dmac_SRC_ADDRESS),
               `SET_dmac_SRC_ADDRESS_SRC_ADDRESS(`DDR_BASE+32'h00000000));
    axi_write (`TX_DMA+GetAddrs(dmac_TRANSFER_SUBMIT),
               `SET_dmac_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
    #5us;

    // Configure Transport Layer for DMA
    axi_write (`DAC_TPL+'h40*i+GetAddrs(dac_channel_REG_CHAN_CNTRL_7),
               `SET_dac_channel_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));  
    #1us;

    //LINK ENABLE
    axi_write (`AXI_JESD_RX + GetAddrs(jesd_rx_LINK_DISABLE),
               `SET_jesd_rx_LINK_DISABLE_LINK_DISABLE(0));
    axi_write (`AXI_JESD_TX + GetAddrs(jesd_tx_LINK_DISABLE),
               `SET_jesd_tx_LINK_DISABLE_LINK_DISABLE(0));
 

    #25us;

    //Read status back
    // Check SYSREF_STATUS
    axi_read_v (`AXI_JESD_TX+GetAddrs(jesd_tx_SYSREF_STATUS),
                `SET_jesd_tx_SYSREF_STATUS_SYSREF_DETECTED(1));
    axi_read_v (`AXI_JESD_RX+GetAddrs(jesd_rx_SYSREF_STATUS),
                `SET_jesd_rx_SYSREF_STATUS_SYSREF_DETECTED(1));

    #1us;

    // Check if in DATA state and SYNC is 1
    axi_read_v (`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_STATUS),
                `SET_jesd_tx_LINK_STATUS_STATUS_STATE('h3));
    axi_read_v (`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_STATUS),
                `SET_jesd_tx_LINK_STATUS_STATUS_STATE('h3) | 
                `SET_jesd_tx_LINK_STATUS_STATUS_SYNC(ref_sync_status));
 
    // Configure RX DMA
    axi_write (`RX_DMA+GetAddrs(dmac_CONTROL),
               `SET_dmac_CONTROL_ENABLE(1));
    axi_write (`RX_DMA+GetAddrs(dmac_FLAGS),
               `SET_dmac_FLAGS_TLAST(1));
    axi_write (`RX_DMA+GetAddrs(dmac_X_LENGTH),
               `SET_dmac_X_LENGTH_X_LENGTH(32'h000003DF));
    axi_write (`RX_DMA+GetAddrs(dmac_DEST_ADDRESS),
               `SET_dmac_DEST_ADDRESS_DEST_ADDRESS(`DDR_BASE+32'h00001000));
    axi_write (`RX_DMA+GetAddrs(dmac_TRANSFER_SUBMIT),
               `SET_dmac_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
    #5us;
    axi_write (`ADC_TPL+GetAddrs(adc_channel_REG_CHAN_CNTRL),
               `SET_adc_channel_REG_CHAN_CNTRL_ENABLE(0));
    #5us;

    check_captured_data(
      .address (`DDR_BASE+'h00001000),
      .length (992),
      .step (1),
      .max_sample(2048)
    );

    axi_write (`ADC_TPL+GetAddrs(adc_channel_REG_CHAN_CNTRL),
               `SET_adc_channel_REG_CHAN_CNTRL_ENABLE(1));
    #5us;

    // Configure RX DMA
    axi_write(`RX_DMA+GetAddrs(dmac_CONTROL),
              `SET_dmac_CONTROL_ENABLE(1));
    axi_write (`RX_DMA+GetAddrs(dmac_FLAGS),
               `SET_dmac_FLAGS_TLAST(1));
    axi_write (`RX_DMA+GetAddrs(dmac_X_LENGTH),
               `SET_dmac_X_LENGTH_X_LENGTH(32'h000003DF));
    axi_write (`RX_DMA+GetAddrs(dmac_DEST_ADDRESS),
               `SET_dmac_DEST_ADDRESS_DEST_ADDRESS(`DDR_BASE+32'h00002000));
    axi_write (`RX_DMA+GetAddrs(dmac_TRANSFER_SUBMIT),
               `SET_dmac_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
    #10us;

    check_captured_data(
      .address (`DDR_BASE+'h00002000),
      .length (992),
      .step (1),
      .max_sample(2048)
    );
*/

  end
  endtask

endprogram
