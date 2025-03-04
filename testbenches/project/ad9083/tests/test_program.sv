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
import adi_regmap_xcvr_pkg::*;
import adi_jesd204_pkg::*;
import adi_xcvr_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

parameter RX_OUT_BYTES = 8;
parameter TX_OUT_BYTES = 8;

program test_program;

  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  
  bit [31:0] val;
  int link_clk_freq;
  int device_clk_freq;
  int sysref_freq;
  int data_path_width;
  int tpl_data_path_width;

  bit [31:0] lane_rate_khz = `RX_RATE*1000000;
  longint lane_rate = lane_rate_khz*1000;

  initial begin

    //creating environment
    base_env = new("Base Environment",
                    `TH.`SYS_CLK.inst.IF,
                    `TH.`DMA_CLK.inst.IF,
                    `TH.`DDR_CLK.inst.IF,
                    `TH.`SYS_RST.inst.IF,
                    `TH.`MNG_AXI.inst.IF,
                    `TH.`DDR_AXI.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);
    
    base_env.start();

    link_clk_freq = lane_rate/40;
    data_path_width = 4;
    tpl_data_path_width = 8;
    device_clk_freq = link_clk_freq * data_path_width / tpl_data_path_width;
    sysref_freq = link_clk_freq*data_path_width/(`RX_JESD_K*`RX_JESD_F);

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));
    `TH.`DEVICE_CLK.inst.IF.set_clk_frq(.user_frequency(device_clk_freq));
    `TH.`SYSREF_CLK.inst.IF.set_clk_frq(.user_frequency(sysref_freq));

    `TH.`DRP_CLK.inst.IF.start_clock;
    `TH.`REF_CLK.inst.IF.start_clock;
    `TH.`DEVICE_CLK.inst.IF.start_clock;
    `TH.`SYSREF_CLK.inst.IF.start_clock;

    base_env.sys_reset();

    //  -------------------------------------------------------
    //  Test DDS path
    //  -------------------------------------------------------

    // Configure Transport Layer for DDS
    //

    // Enable Rx channel
    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                       `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));

    // Select DDS as source
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    // Configure tone amplitude and frequency
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(32'h00000fff));
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INIT_1(16'h0000)|
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));

    // Pull out TPL cores from reset
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_MMCM_RSTN(1)|
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_MMCM_RSTN(1)|
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    // Sync DDS cores
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),
                       `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));

    //
    // Configure TX Link Layer
    //

    //LINK DISABLE
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));

    //SYSREFCONF
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_SYSREF_CONF),
                       `SET_JESD_TX_SYSREF_CONF_SYSREF_DISABLE(0)); // Enable SYSREF handling

    //CONF0
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_CONF0),
                       `SET_JESD_TX_LINK_CONF0_OCTETS_PER_FRAME(`TX_JESD_F-1)|
                       `SET_JESD_TX_LINK_CONF0_OCTETS_PER_MULTIFRAME(`TX_JESD_F*`TX_JESD_K-1));
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_CONF4),
                       `SET_JESD_TX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((`TX_JESD_F*`TX_JESD_K)/TX_OUT_BYTES-1));
    //CONF1
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_CONF1),
                       `SET_JESD_TX_LINK_CONF1_SCRAMBLER_DISABLE(0)); // Scrambler enable

    //LINK ENABLE
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(0));

    //
    // Configure RX Link Layer
    //

    //LINK DISABLE
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));

    //SYSREFCONF
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_SYSREF_CONF),
                       `SET_JESD_RX_SYSREF_CONF_SYSREF_DISABLE(0)); // Enable SYSREF handling

    //CONF0
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_CONF0),
                       `SET_JESD_RX_LINK_CONF0_OCTETS_PER_FRAME(`RX_JESD_F-1)|
                       `SET_JESD_RX_LINK_CONF0_OCTETS_PER_MULTIFRAME(`RX_JESD_F*`RX_JESD_K-1));
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_CONF4),
                       `SET_JESD_RX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((`RX_JESD_F*`RX_JESD_K)/RX_OUT_BYTES-1)); // Beats per multiframe
    //CONF1
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_CONF1),
                       `SET_JESD_RX_LINK_CONF1_DESCRAMBLER_DISABLE(0)); // Scrambler enable

    //LINK ENABLE
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));

    //XCVR INIT
    //REG CTRL
    base_env.mng.sequencer.RegWrite32(`RX_XCVR_BA + GetAddrs(XCVR_CONTROL),
                       `SET_XCVR_CONTROL_LPM_DFE_N(1)|
                       `SET_XCVR_CONTROL_OUTCLK_SEL(4)); // RXOUTCLK uses DIV2
    base_env.mng.sequencer.RegWrite32(`TX_XCVR_BA + GetAddrs(XCVR_CONTROL),
                       `SET_XCVR_CONTROL_LPM_DFE_N(1)|
                       `SET_XCVR_CONTROL_OUTCLK_SEL(4)); // TXOUTCLK uses DIV2

    base_env.mng.sequencer.RegWrite32(`RX_XCVR_BA + GetAddrs(XCVR_RESETN),
                       `SET_XCVR_RESETN_RESETN(1));
    base_env.mng.sequencer.RegWrite32(`TX_XCVR_BA + GetAddrs(XCVR_RESETN),
                       `SET_XCVR_RESETN_RESETN(1));

    // Give time the PLLs to lock
    #50us;

    //Read status back
    // Check SYSREF_STATUS
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_SYSREF_STATUS),
                            `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_SYSREF_STATUS),
                            `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));

    // Check if in DATA state and SYNC is 1
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_STATUS),
                            `SET_JESD_RX_LINK_STATUS_STATUS_STATE(3));
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_STATUS),
                            `SET_JESD_TX_LINK_STATUS_STATUS_SYNC(1)|
                            `SET_JESD_TX_LINK_STATUS_STATUS_STATE(3));

    //LINK DISABLE
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));

    //  -------------------------------------------------------
    //  Test DAC FIFO path and RX DMA capture
    //  -------------------------------------------------------

    // Init test data
    // .step (1),
    // .max_sample(2048)
    for (int i=0;i<2048*2 ;i=i+2) begin
      base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),(((i+1)) << 16) | i ,15);
    end

    #5us;

    // Reset TPL cores
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_MMCM_RSTN(1)|
                       `SET_DAC_COMMON_REG_RSTN_RSTN(0));
    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_MMCM_RSTN(1)|
                       `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    // Pull out TPL cores from reset
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_MMCM_RSTN(1)|
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_MMCM_RSTN(1)|
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    // Configure Transport Layer for DMA
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));

    #1us;

    // Configure TX DMA
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_CONTROL),
                       `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_FLAGS),
                       `SET_DMAC_FLAGS_CYCLIC(0)|
                       `SET_DMAC_FLAGS_TLAST(1)); // use TLAST, disable CYCLIC
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003DF)); // X_LENGTH = 992-1
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_SRC_ADDRESS),
                       `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BA)); // SRC_ADDRESS
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer
                       
    
    // Configure RX DMA
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_CONTROL),
                       `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_FLAGS),
                       `SET_DMAC_FLAGS_CYCLIC(0)|
                       `SET_DMAC_FLAGS_TLAST(1)); // use TLAST, disable CYCLIC
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003DF)); // X_LENGTH = 992-1
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_DEST_ADDRESS),
                       `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA+32'h00001000)); // DEST_ADDRESS
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer
                       
    //LINK ENABLE
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(0));

    #25us;

    //Read status back
    // Check SYSREF_STATUS
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_SYSREF_STATUS),
                            `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_SYSREF_STATUS),
                            `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));

    #1us;

    // Check if in DATA state and SYNC is 1
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_STATUS),
                            `SET_JESD_RX_LINK_STATUS_STATUS_STATE(3));
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_STATUS),
                            `SET_JESD_TX_LINK_STATUS_STATUS_SYNC(1)|
                            `SET_JESD_TX_LINK_STATUS_STATUS_STATE(3));
    
    #5us;
    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                       `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(0));
    #5us;

    check_captured_data(
      .address (`DDR_BA+'h00001000),
      .length (992),
      .step (1),
      .max_sample(496)
    );


    //LINK DISABLE
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));

    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                       `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    #5us;

    // Configure TX DMA
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_CONTROL),
                       `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_FLAGS),
                       `SET_DMAC_FLAGS_CYCLIC(0)|
                       `SET_DMAC_FLAGS_TLAST(1)); // use TLAST, disable CYCLIC
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003DF)); // X_LENGTH = 992-1
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_SRC_ADDRESS),
                       `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BA)); // SRC_ADDRESS
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer

    // Configure RX DMA
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_CONTROL),
                       `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_FLAGS),
                       `SET_DMAC_FLAGS_CYCLIC(0)|
                       `SET_DMAC_FLAGS_TLAST(1)); // use TLAST, disable CYCLIC
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003DF)); // X_LENGTH = 992-1
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_DEST_ADDRESS),
                       `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA+32'h00002000)); // DEST_ADDRESS
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer DMA
                       
    //LINK ENABLE
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(0));

    #10us;

    check_captured_data(
      .address (`DDR_BA+'h00002000),
      .length (992),
      .step (1),
      .max_sample(496)
    );

    base_env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
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
      captured_word = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(current_address);
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
