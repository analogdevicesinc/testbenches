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
import adi_regmap_jesd_tx_pkg::*;
import adi_regmap_jesd_rx_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_dac_pkg::*;
import adi_regmap_adc_pkg::*;

`define RX_DMA      32'h7c42_0000
`define RX_XCVR     32'h44a6_0000
`define TX_DMA      32'h7c43_0000
`define TX_XCVR     32'h44b6_0000
`define AXI_JESD_RX 32'h44a9_0000
`define ADC_TPL     32'h44a1_0000
`define DAC_TPL     32'h44b1_0000
`define AXI_JESD_TX 32'h44b9_0000
`define DDR_BASE    32'h8000_0000

parameter RX_OUT_BYTES = (`RX_JESD_F % 3 != 0) ? (`JESD_MODE == "64B66B") ? 8 : 4
                                               : (`JESD_MODE == "64B66B") ? 12 : 6;
parameter TX_OUT_BYTES = (`TX_JESD_F % 3 != 0) ? (`JESD_MODE == "64B66B") ? 8 : 4
                                               : (`JESD_MODE == "64B66B") ? 12 : 6;
program test_program;

  test_harness_env env;
  bit [31:0] val;
  bit [31:0] link_clk_freq;
  bit [31:0] device_clk_freq;
  bit [31:0] sysref_freq;
  int data_path_width;
  int tpl_data_path_width;

  bit [31:0] lane_rate_khz = `RX_LANE_RATE*1000000;
  longint lane_rate = lane_rate_khz*1000;

  initial begin

    // There is no SYSREF in 64B66B
    int ref_sync_status = (`JESD_MODE != "64B66B");

    //creating environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    #2ps;

    setLoggerVerbosity(6);
    env.start();

    if (`JESD_MODE != "64B66B") begin
      link_clk_freq = lane_rate/40;
      data_path_width = 4;
      tpl_data_path_width = (`RX_JESD_NP==12) ? 6 : 4;
    end else begin
      link_clk_freq = lane_rate/66;
      data_path_width = 8;
      tpl_data_path_width = (`RX_JESD_NP==12) ? 12 : 8;
    end
    device_clk_freq = link_clk_freq * data_path_width / tpl_data_path_width;
    sysref_freq = link_clk_freq*data_path_width/(`RX_JESD_K*`RX_JESD_F);

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));
    `TH.`DEVICE_CLK.inst.IF.set_clk_frq(.user_frequency(device_clk_freq));
    `TH.`SYSREF_CLK.inst.IF.set_clk_frq(.user_frequency(sysref_freq));

    `TH.`DRP_CLK.inst.IF.start_clock;
    `TH.`REF_CLK.inst.IF.start_clock;
    `TH.`DEVICE_CLK.inst.IF.start_clock;
    `TH.`SYSREF_CLK.inst.IF.start_clock;

    //asserts all the resets for 100 ns
    `TH.`SYS_RST.inst.IF.assert_reset;

    #100
    `TH.`SYS_RST.inst.IF.deassert_reset;

    #1us;

    //  -------------------------------------------------------
    //  Test DDS path
    //  -------------------------------------------------------

    // Configure Transport Layer for DDS
    //

    // Enable Rx channel
    env.mng.RegWrite32(`ADC_TPL + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                       `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    // Select DDS as source
    env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    // Configure tone amplitude and frequency
    env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
    env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));
    // Pull out TPL cores from reset
    env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    env.mng.RegWrite32(`ADC_TPL +  GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));
    // Sync DDS cores
    env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_COMMON_REG_CNTRL_1),
                       `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    //
    // Configure TX Link Layer
    //

    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_TX + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));
    //SYSREFCONF
    env.mng.RegWrite32(`AXI_JESD_TX + GetAddrs(JESD_TX_SYSREF_CONF),
                       `SET_JESD_TX_SYSREF_CONF_SYSREF_DISABLE(0));
    //CONF0
    env.mng.RegWrite32(`AXI_JESD_TX + GetAddrs(JESD_TX_LINK_CONF0),
                       `SET_JESD_TX_LINK_CONF0_OCTETS_PER_FRAME(`TX_JESD_F-1) | 
                       `SET_JESD_TX_LINK_CONF0_OCTETS_PER_MULTIFRAME(`TX_JESD_F*`TX_JESD_K-1));
    env.mng.RegWrite32(`AXI_JESD_TX + GetAddrs(JESD_TX_LINK_CONF4),
                       `SET_JESD_TX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((`TX_JESD_F*`TX_JESD_K)/TX_OUT_BYTES-1));
    //CONF1
    env.mng.RegWrite32(`AXI_JESD_TX + GetAddrs(JESD_TX_LINK_CONF1),
                       `SET_JESD_TX_LINK_CONF1_SCRAMBLER_DISABLE(0));

    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_TX + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(0));

    //
    // Configure RX Link Layer
    //

    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_RX + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));

    //SYSREFCONF
    env.mng.RegWrite32(`AXI_JESD_RX + GetAddrs(JESD_RX_SYSREF_CONF),
                       `SET_JESD_RX_SYSREF_CONF_SYSREF_DISABLE(0));

    //CONF0
    env.mng.RegWrite32(`AXI_JESD_RX + GetAddrs(JESD_RX_LINK_CONF0),
                       `SET_JESD_RX_LINK_CONF0_OCTETS_PER_FRAME(`RX_JESD_F-1) | 
                       `SET_JESD_RX_LINK_CONF0_OCTETS_PER_MULTIFRAME(`RX_JESD_F*`RX_JESD_K-1));
    env.mng.RegWrite32(`AXI_JESD_RX + GetAddrs(JESD_RX_LINK_CONF4),
                       `SET_JESD_RX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((`RX_JESD_F*`RX_JESD_K)/RX_OUT_BYTES-1));
 
    //CONF1
    env.mng.RegWrite32(`AXI_JESD_RX + GetAddrs(JESD_RX_LINK_CONF1),
                       `SET_JESD_RX_LINK_CONF1_DESCRAMBLER_DISABLE(0));
    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_RX + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));

    //XCVR INIT
    //REG CTRL
    if (`JESD_MODE != "64B66B") begin
        env.mng.RegWrite32(`RX_XCVR+32'h0020,32'h00001004);   // RXOUTCLK uses DIV2
        env.mng.RegWrite32(`TX_XCVR+32'h0020,32'h00001004);

        env.mng.RegWrite32(`RX_XCVR+32'h0010,32'h00000001);
        env.mng.RegWrite32(`TX_XCVR+32'h0010,32'h00000001);
    end

    // Give time the PLLs to lock
    #35us;

    //Read status back
    // Check SYSREF_STATUS
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(JESD_RX_SYSREF_STATUS),
                            `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));
    env.mng.RegReadVerify32(`AXI_JESD_TX+GetAddrs(JESD_TX_SYSREF_STATUS),
                            `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));

    // Check if in DATA state and SYNC is 1
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(JESD_RX_LINK_STATUS),
                            `SET_JESD_RX_LINK_STATUS_STATUS_STATE('h3));
    env.mng.RegReadVerify32(`AXI_JESD_TX+GetAddrs(JESD_TX_LINK_STATUS),
                            `SET_JESD_TX_LINK_STATUS_STATUS_STATE('h3) | 
                            `SET_JESD_TX_LINK_STATUS_STATUS_SYNC(ref_sync_status));
    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_TX + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));
    env.mng.RegWrite32(`AXI_JESD_RX + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));


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
    env.mng.RegWrite32(`TX_DMA+GetAddrs(dmac_CONTROL),
                       `SET_dmac_CONTROL_ENABLE(1));
    env.mng.RegWrite32(`TX_DMA+GetAddrs(dmac_FLAGS),
                       `SET_dmac_FLAGS_TLAST(1));
    env.mng.RegWrite32(`TX_DMA+GetAddrs(dmac_X_LENGTH),
                       `SET_dmac_X_LENGTH_X_LENGTH(32'h00000FFF));
    env.mng.RegWrite32(`TX_DMA+GetAddrs(dmac_SRC_ADDRESS),
                       `SET_dmac_SRC_ADDRESS_SRC_ADDRESS(`DDR_BASE+32'h00000000));
    env.mng.RegWrite32(`TX_DMA+GetAddrs(dmac_TRANSFER_SUBMIT),
                       `SET_dmac_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
    #5us;

    // Configure Transport Layer for DMA
    env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
    #1us;

    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_TX + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(0));
    env.mng.RegWrite32(`AXI_JESD_RX + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));


    #25us;

    //Read status back
    // Check SYSREF_STATUS
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(JESD_RX_SYSREF_STATUS),
                            `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));
    env.mng.RegReadVerify32(`AXI_JESD_TX+GetAddrs(JESD_TX_SYSREF_STATUS),
                            `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));

    #1us;

    // Check if in DATA state and SYNC is 1
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(JESD_RX_LINK_STATUS),
                            `SET_JESD_RX_LINK_STATUS_STATUS_STATE(3));
    env.mng.RegReadVerify32(`AXI_JESD_TX+GetAddrs(JESD_TX_LINK_STATUS),
                            `SET_JESD_TX_LINK_STATUS_STATUS_STATE(3) | 
                            `SET_JESD_TX_LINK_STATUS_STATUS_SYNC(ref_sync_status));

    // Configure RX DMA
    env.mng.RegWrite32(`RX_DMA+GetAddrs(dmac_CONTROL),
                       `SET_dmac_CONTROL_ENABLE(1));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(dmac_FLAGS),
                       `SET_dmac_FLAGS_TLAST(1));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(dmac_X_LENGTH),
                       `SET_dmac_X_LENGTH_X_LENGTH(32'h000003DF));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(dmac_DEST_ADDRESS),
                       `SET_dmac_DEST_ADDRESS_DEST_ADDRESS(`DDR_BASE+32'h00001000));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(dmac_TRANSFER_SUBMIT),
                       `SET_dmac_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
    #5us;
    env.mng.RegWrite32(`ADC_TPL + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                       `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(0));
    #5us;

    check_captured_data(
      .address (`DDR_BASE+'h00001000),
      .length (992),
      .step (1),
      .max_sample(2048)
    );

    env.mng.RegWrite32(`ADC_TPL + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                       `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    #5us;

    // Configure RX DMA
    env.mng.RegWrite32(`RX_DMA+GetAddrs(dmac_CONTROL),
                       `SET_dmac_CONTROL_ENABLE(1));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(dmac_FLAGS),
                       `SET_dmac_FLAGS_TLAST(1));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(dmac_X_LENGTH),
                       `SET_dmac_X_LENGTH_X_LENGTH(32'h000003DF));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(dmac_DEST_ADDRESS),
                       `SET_dmac_DEST_ADDRESS_DEST_ADDRESS(`DDR_BASE+32'h00002000));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(dmac_TRANSFER_SUBMIT),
                       `SET_dmac_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    #10us;

    check_captured_data(
      .address (`DDR_BASE+'h00002000),
      .length (992),
      .step (1),
      .max_sample(2048)
    );

    `INFO(("Test Done"));

  end

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
