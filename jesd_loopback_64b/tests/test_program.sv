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
        env.mng.RegWrite32(`DAC_TPL+'h40*i+32'h0418, 32'h00000000);
        // Configure tone amplitude and frequency
        env.mng.RegWrite32(`DAC_TPL+'h40*i+32'h0400, 32'h00000fff);
        env.mng.RegWrite32(`DAC_TPL+'h40*i+32'h0404, 32'h00000100);
      end else begin
        // Set DMA as source for DAC TPL
        env.mng.RegWrite32(`DAC_TPL+'h40*i+32'h0418,32'h00000002);
      end
    end

    for (int i = 0; i < `JESD_M; i++) begin
      env.mng.RegWrite32(`ADC_TPL+'h40*i+32'h0400,32'h0000001);
    end


    env.mng.RegWrite32(`DAC_TPL+32'h0040,32'h00000003);
    env.mng.RegWrite32(`ADC_TPL+32'h0040,32'h00000003);

    // Sync DDS cores
    env.mng.RegWrite32(`DAC_TPL+32'h0044, 32'h00000001);

    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_RX+32'h00c0,32'h00000001);
    env.mng.RegWrite32(`AXI_JESD_TX+32'h00c0,32'h00000001);

    //SYSREFCONF
    env.mng.RegWrite32(`AXI_JESD_RX+32'h0100,32'h00000000); // Enable SYSREF handling
    env.mng.RegWrite32(`AXI_JESD_TX+32'h0100,32'h00000000); // Enable SYSREF handling

    //CONF0
    env.mng.RegWrite32(`AXI_JESD_RX+32'h0210,(`JESD_F-1)<<16 | (`JESD_F*`JESD_K-1));
    env.mng.RegWrite32(`AXI_JESD_TX+32'h0210,(`JESD_F-1)<<16 | (`JESD_F*`JESD_K-1));
    env.mng.RegWrite32(`AXI_JESD_RX+32'h021C,((`JESD_F*`JESD_K)/`LL_OUT_BYTES-1)); // Beats per multiframe
    env.mng.RegWrite32(`AXI_JESD_TX+32'h021C,((`JESD_F*`JESD_K)/`LL_OUT_BYTES-1));
    //CONF1
    env.mng.RegWrite32(`AXI_JESD_RX+32'h0214,32'h00000000); // Scrambler enable
    env.mng.RegWrite32(`AXI_JESD_TX+32'h0214,32'h00000000); // Scrambler enable
    //CONF2
    env.mng.RegWrite32(`AXI_JESD_TX+32'h0240,32'h00000000);

    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_RX+32'h00c0,32'h00000000);
    env.mng.RegWrite32(`AXI_JESD_TX+32'h00c0,32'h00000000);

    #25us;
    // Read status back
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h0280,3);

    #1us;
    
    // --------------------------------------
    //  Attempt a second link bring-up
    // --------------------------------------
    
    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_RX+32'h00c0,32'h00000001);
    env.mng.RegWrite32(`AXI_JESD_TX+32'h00c0,32'h00000001);
    
    #1us;
    
    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_RX+32'h00c0,32'h00000000);
    env.mng.RegWrite32(`AXI_JESD_TX+32'h00c0,32'h00000000);

    #25us;
    // Read status back
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h0280,3);
  end

endprogram
