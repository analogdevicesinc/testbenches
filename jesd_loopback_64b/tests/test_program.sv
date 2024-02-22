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

`define JESD_PHY    32'h44a6_0000
`define AXI_JESD_RX 32'h44a9_0000
`define AXI_JESD_TX 32'h44b9_0000
`define ADC_TPL     32'h44a1_0000
`define DAC_TPL     32'h44b1_0000

parameter OUT_BYTES = (`JESD_F % 3 != 0) ? 8 : 12;

program test_program;

  test_harness_env env;
  bit [31:0] val;
  int link_clk_freq_khz;
  int device_clk_freq_khz;
  int sysref_freq_khz;
  int data_path_width;
  int tpl_data_path_width;

  bit [31:0] lane_rate_khz = `LANE_RATE*1000000;
  longint lane_rate = lane_rate_khz*1000;

  int use_dds = 0;

  initial begin
    //creating environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    #2ps;

    setLoggerVerbosity(6);
    env.start();

    `TH.`SYS_CLK.inst.IF.start_clock;
    `TH.`DMA_CLK.inst.IF.start_clock;
    `TH.`DDR_CLK.inst.IF.start_clock;

    link_clk_freq_khz = lane_rate_khz/66;
    data_path_width = 8;
    tpl_data_path_width = (`JESD_NP==12) ? 12 : 8;
    device_clk_freq_khz = link_clk_freq_khz * data_path_width / tpl_data_path_width;
    sysref_freq_khz = link_clk_freq_khz * data_path_width/(`JESD_K*`JESD_F);

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));
    `TH.`DEVICE_CLK.inst.IF.set_clk_frq(.user_frequency(device_clk_freq_khz*1000));
    `TH.`SYSREF_CLK.inst.IF.set_clk_frq(.user_frequency(sysref_freq_khz*1000));

    `TH.`REF_CLK.inst.IF.start_clock;
    `TH.`DRP_CLK.inst.IF.start_clock;
    `TH.`DEVICE_CLK.inst.IF.start_clock;
    `TH.`SYSREF_CLK.inst.IF.start_clock;

    for (int i = 0; i < `JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        env.mng.RegWrite32(`DAC_TPL+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
        // Configure tone amplitude and frequency
        env.mng.RegWrite32(`DAC_TPL+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
        env.mng.RegWrite32(`DAC_TPL+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));

      end else begin
        // Set DMA as source for DAC TPL
        env.mng.RegWrite32(`DAC_TPL+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      end
    end

    for (int i = 0; i < `JESD_M; i++) begin
      env.mng.RegWrite32(`ADC_TPL+'h40*i+GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end


    env.mng.RegWrite32(`DAC_TPL+GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    env.mng.RegWrite32(`ADC_TPL+GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));


    // Sync DDS cores
    env.mng.RegWrite32(`DAC_TPL+GetAddrs(DAC_COMMON_REG_CNTRL_1),
                       `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));

    //SYSREFCONF
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(JESD_RX_SYSREF_CONF),
                       `SET_JESD_RX_SYSREF_CONF_SYSREF_DISABLE(0)); 
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(JESD_TX_SYSREF_CONF),
                       `SET_JESD_TX_SYSREF_CONF_SYSREF_DISABLE(0));

    //CONF0
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(JESD_RX_LINK_CONF0),
                       `SET_JESD_RX_LINK_CONF0_OCTETS_PER_FRAME(`JESD_F-1) | 
                       `SET_JESD_RX_LINK_CONF0_OCTETS_PER_MULTIFRAME(`JESD_F*`JESD_K-1));
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(JESD_TX_LINK_CONF0),
                       `SET_JESD_TX_LINK_CONF0_OCTETS_PER_FRAME(`JESD_F-1) | 
                       `SET_JESD_TX_LINK_CONF0_OCTETS_PER_MULTIFRAME(`JESD_F*`JESD_K-1));
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(JESD_RX_LINK_CONF4),
                       `SET_JESD_RX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((`JESD_F*`JESD_K)/`LL_OUT_BYTES-1));
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(JESD_TX_LINK_CONF4),
                       `SET_JESD_TX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((`JESD_F*`JESD_K)/`LL_OUT_BYTES-1));
    //CONF1
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(JESD_RX_LINK_CONF1),
                       `SET_JESD_RX_LINK_CONF1_DESCRAMBLER_DISABLE(0)); 
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(JESD_TX_LINK_CONF1),
                       `SET_JESD_TX_LINK_CONF1_SCRAMBLER_DISABLE(0)); 

    //CONF2
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(JESD_TX_LINK_CONF2),
                       `SET_JESD_TX_LINK_CONF2_CONTINUOUS_CGS(0));
    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(0));

    #25us;
    // Read status back
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(JESD_RX_LINK_STATUS),
                            `SET_JESD_RX_LINK_STATUS_STATUS_STATE(3));
    #1us;
    
    // --------------------------------------
    //  Attempt a second link bring-up
    // --------------------------------------
    
    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));
    #1us;

    
    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(0));

    #25us;
    // Read status back
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(JESD_RX_LINK_STATUS),
                            `SET_JESD_RX_LINK_STATUS_STATUS_STATE(3));
  end

endprogram
