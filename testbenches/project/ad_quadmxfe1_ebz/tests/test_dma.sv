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

parameter RX_OUT_BYTES = (`RX_JESD_F % 3 != 0) ? (`JESD_MODE == "64B66B") ? 8 : 4
                                               : (`JESD_MODE == "64B66B") ? 12 : 6;
parameter TX_OUT_BYTES = (`TX_JESD_F % 3 != 0) ? (`JESD_MODE == "64B66B") ? 8 : 4
                                               : (`JESD_MODE == "64B66B") ? 12 : 6;

`define  CH_COUNT 4

program test_dma;

  test_harness_env env;
  bit [31:0] val;
  bit [31:0] link_clk_freq;
  bit [31:0] device_clk_freq;
  bit [31:0] sysref_freq;
  int data_path_width;
  int tpl_data_path_width;

  bit [31:0] lane_rate_khz = `RX_LANE_RATE*1000000;
  longint lane_rate = lane_rate_khz*1000;

  reg timed_out;

  initial begin

    // There is no SYNC in 64B66B
    int ref_sync_status = (`JESD_MODE != "64B66B");

    //creating environment
    env = new("AD QuadMXFE Environment",
              `TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    #2ps;

    setLoggerVerbosity(ADI_VERBOSITY_NONE);
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
    //  Test DAC FIFO path
    //  -------------------------------------------------------

    // Init test data
    //
    for (int i=0;i<1024;i=i+2) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BA+i*2,
                                                              ((((i+1) % 1024)<<16) <<4) | ((i % 1024) << 4) ,
                                                              4'b1111);
    end

    // Configure TX DMA

    env.mng.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_CONTROL),
                       `SET_DMAC_CONTROL_ENABLE(1));
    env.mng.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(32'h00000FFF));
    env.mng.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_FLAGS),
                       `SET_DMAC_FLAGS_CYCLIC(1));
    env.mng.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_SRC_ADDRESS),
                       `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BA+32'h00000000));
    env.mng.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));


    // Configure Transport Layer to send DMA data on CH0-CH_COUNT-1
    for (int i=0;i<`CH_COUNT;i=i+1) begin
      env.mng.RegWrite32(`DAC_TPL_BA+((30'h0106+('h10*i))<<2),
                         `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      // Enable Rx channel
      env.mng.RegWrite32(`ADC_TPL_BA+((30'h0100+('h10*i))<<2),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end


    // Pull out TPL cores from reset
    env.mng.RegWrite32(`DAC_TPL_BA+GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    env.mng.RegWrite32(`ADC_TPL_BA+GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));
 
    // Sync DDS cores
    env.mng.RegWrite32(`DAC_TPL_BA+GetAddrs(DAC_COMMON_REG_CNTRL_1),
                       `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));

    //
    // Configure TX Link Layer
    //

    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));
    //SYSREFCONF
    env.mng.RegWrite32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_SYSREF_CONF),
                       `SET_JESD_TX_SYSREF_CONF_SYSREF_DISABLE(0));
    //CONF0
    env.mng.RegWrite32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_LINK_CONF0),
                       `SET_JESD_TX_LINK_CONF0_OCTETS_PER_FRAME(`TX_JESD_F-1) | 
		       `SET_JESD_TX_LINK_CONF0_OCTETS_PER_MULTIFRAME(`TX_JESD_F*`TX_JESD_K-1));
    env.mng.RegWrite32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_LINK_CONF4),
                       `SET_JESD_TX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((`TX_JESD_F*`TX_JESD_K)/TX_OUT_BYTES-1));
    //CONF1
    env.mng.RegWrite32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_LINK_CONF1),
                       `SET_JESD_TX_LINK_CONF1_SCRAMBLER_DISABLE(0)); 
    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(0));
    //
    // Configure RX Link Layer
    //

    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));
    //SYSREFCONF
    env.mng.RegWrite32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_SYSREF_CONF),
                       `SET_JESD_RX_SYSREF_CONF_SYSREF_DISABLE(0)); 
    //CONF0
    env.mng.RegWrite32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_LINK_CONF0),
                       `SET_JESD_RX_LINK_CONF0_OCTETS_PER_FRAME(`RX_JESD_F-1) | 
                       `SET_JESD_RX_LINK_CONF0_OCTETS_PER_MULTIFRAME(`RX_JESD_F*`RX_JESD_K-1));
    env.mng.RegWrite32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_LINK_CONF4),
                       `SET_JESD_RX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((`RX_JESD_F*`RX_JESD_K)/RX_OUT_BYTES-1));
    //CONF1
    env.mng.RegWrite32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_LINK_CONF1),
                       `SET_JESD_RX_LINK_CONF1_DESCRAMBLER_DISABLE(0)); 
    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));

    //XCVR INIT
    //REG CTRL
    if (`JESD_MODE != "64B66B") begin
    env.mng.RegWrite32(`RX_XCVR_BA+32'h0020,32'h00001004);   // RXOUTCLK uses DIV2
    env.mng.RegWrite32(`TX_XCVR_BA+32'h0020,32'h00001004);

    env.mng.RegWrite32(`RX_XCVR_BA+32'h0010,32'h00000001);
    env.mng.RegWrite32(`TX_XCVR_BA+32'h0010,32'h00000001);
    end

     // Wait until link is up
    fork : timeout_f
       begin
         #25us;
         `FATAL(("Link bringup wait Timeout"));
         timed_out = '1;
       end
    join_none
    wait(`TH.axi_mxfe_rx_jesd.rx.inst.buffer_release_n === 1'b0 || timed_out);
    disable timeout_f;

    //Read status back
    // Check SYSREF_STATUS
    env.mng.RegReadVerify32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_SYSREF_STATUS),
                            `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));
    env.mng.RegReadVerify32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_SYSREF_STATUS),
                            `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));
    // Check if in DATA state and SYNC is 1
    env.mng.RegReadVerify32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_LINK_STATUS),
                            `SET_JESD_TX_LINK_STATUS_STATUS_STATE('h3));
    env.mng.RegReadVerify32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_LINK_STATUS),
                            `SET_JESD_TX_LINK_STATUS_STATUS_STATE('h3) | 
                            `SET_JESD_TX_LINK_STATUS_STATUS_SYNC(ref_sync_status));
    // Configure RX DMA
    env.mng.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_CONTROL),
                       `SET_DMAC_CONTROL_ENABLE(1));
    env.mng.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_FLAGS),
                       `SET_DMAC_FLAGS_TLAST(1));
    env.mng.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003FF));
    env.mng.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_DEST_ADDRESS),
                       `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA+32'h00001000));
    env.mng.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
    #5us;
    for (int i=0;i<`CH_COUNT;i=i+1) begin
      // Disable Rx channels
      env.mng.RegWrite32(`ADC_TPL_BA+((30'h0100+('h10*i))<<2), 32'h0000000);
    end
    #5us;

    check_captured_data(
      .address (`DDR_BA+'h00001000),
      .length (1024),
      .step (1),
      .max_sample(512)
    );

    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));
    env.mng.RegWrite32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));


    #2us;

    env.stop();
    
    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

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
