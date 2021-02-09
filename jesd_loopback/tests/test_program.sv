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
`include "m_axi_sequencer.sv"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;

`define ADC_XCVR    32'h44a6_0000
`define DAC_XCVR    32'h44b6_0000
`define AXI_JESD_RX 32'h44a9_0000
`define AXI_JESD_TX 32'h44b9_0000
`define ADC_TPL     32'h44a1_0000
`define DAC_TPL     32'h44b1_0000

`define PRBS_OFF 4'b0000
`define PRBS_7   4'b0001
`define PRBS_9   4'b0010
`define PRBS_15  4'b0011
`define PRBS_23  4'b0100
`define PRBS_31  4'b0101

parameter OUT_BYTES = `LL_OUT_BYTES;

program test_program;

  test_harness_env env;
  bit [31:0] val;
  int link_clk_freq;
  int device_clk_freq;
  int sysref_freq;
  int data_path_width;
  int tpl_data_path_width;

  int use_dds = 0;
  bit [31:0] lane_rate_khz = `LANE_RATE*1000000;
  longint lane_rate = lane_rate_khz*1000;

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

    link_clk_freq = lane_rate/40;
    data_path_width = 4;
    tpl_data_path_width = OUT_BYTES;
    device_clk_freq = link_clk_freq * data_path_width / tpl_data_path_width;
    sysref_freq = link_clk_freq*data_path_width/(`JESD_K*`JESD_F);

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));
    `TH.`DEVICE_CLK.inst.IF.set_clk_frq(.user_frequency(device_clk_freq));
    `TH.`SYSREF_CLK.inst.IF.set_clk_frq(.user_frequency(sysref_freq));

    `TH.`REF_CLK.inst.IF.start_clock;
    `TH.`DEVICE_CLK.inst.IF.start_clock;
    `TH.`SYSREF_CLK.inst.IF.start_clock;

    // -----------------------
    // PHY INIT
    // -----------------------
    env.mng.RegWrite32(`ADC_XCVR+32'h0020,32'h00001003);   // RXOUTCLK uses DIV1
    env.mng.RegWrite32(`DAC_XCVR+32'h0020,32'h00001003);

    env.mng.RegWrite32(`ADC_XCVR+32'h0010,32'h00000001);
    env.mng.RegWrite32(`DAC_XCVR+32'h0010,32'h00000001);

    // Wait PLLs to lock
    #5us;

    // -----------------------
    // Put XCVR in PRBS mode
    // -----------------------
    env.mng.RegWrite32(`DAC_XCVR+32'h0180, `PRBS_9);
    env.mng.RegWrite32(`ADC_XCVR+32'h0180, `PRBS_7);

    #1us;
    // Error should be detected
    env.mng.RegReadVerify32(`ADC_XCVR+32'h0184,1<<8 | 0);

    // Check if error can be cleared
    env.mng.RegWrite32(`DAC_XCVR+32'h0180, `PRBS_7);
    env.mng.RegWrite32(`ADC_XCVR+32'h0180, 1 << 8); // Clear prbs err
    env.mng.RegWrite32(`ADC_XCVR+32'h0180, `PRBS_7);

    #1us;
    // No error should be detected, Lock shoud be set
    env.mng.RegReadVerify32(`ADC_XCVR+32'h0184,0<<8 | 1);

    // -----------------------
    // Check Error injection
    // -----------------------
    env.mng.RegWrite32(`DAC_XCVR+32'h0180, `PRBS_7 | 1<<15 ); // Enable Error inject
    env.mng.RegWrite32(`ADC_XCVR+32'h0180, 1 << 8); // Clear prbs err
    env.mng.RegWrite32(`ADC_XCVR+32'h0180, `PRBS_7);

    #1us;
    // Error should be detected
    env.mng.RegReadVerify32(`ADC_XCVR+32'h0184,1<<8 | 0);

    env.mng.RegWrite32(`DAC_XCVR+32'h0180, `PRBS_OFF);
    env.mng.RegWrite32(`ADC_XCVR+32'h0180, 1 << 8); // Clear prbs err
    env.mng.RegWrite32(`ADC_XCVR+32'h0180, `PRBS_OFF);

    // -----------------------
    // Configure TPL
    // -----------------------
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
    env.mng.RegWrite32(`AXI_JESD_RX+32'h021C,((`JESD_F*`JESD_K)/OUT_BYTES-1)); // Beats per multiframe
    env.mng.RegWrite32(`AXI_JESD_TX+32'h021C,((`JESD_F*`JESD_K)/OUT_BYTES-1));
    //CONF1
    env.mng.RegWrite32(`AXI_JESD_RX+32'h0214,32'h00000001); // Scrambler disable
    env.mng.RegWrite32(`AXI_JESD_TX+32'h0214,32'h00000001); // Scrambler disable
    //CONF2
    env.mng.RegWrite32(`AXI_JESD_TX+32'h0240,32'h00000000);
    // Send an arbitrary ILAS sequence, does not have to match the link
    // parameters. They should be sent and received on the other side of the
    // link as is.
    env.mng.RegWrite32(`AXI_JESD_TX+32'h0314,32'h1f018300);
    env.mng.RegWrite32(`AXI_JESD_TX+32'h0318,32'h202f0f03);
    env.mng.RegWrite32(`AXI_JESD_TX+32'h031c,32'h47000000);

    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_RX+32'h00c0,32'h00000000);
    env.mng.RegWrite32(`AXI_JESD_TX+32'h00c0,32'h00000000);

    #10us;
    // Read status back
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h0280,3);
    // Check received ILAS
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h0314,32'h1f018300);
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h0318,32'h202f0f03);
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h031c,32'h47000000);

    #1us;

    // Drift SYSREF with one device clock
    //
    system_tb.sysref_dly_sel = 2'b01;
    #1us;
    // Check SYSREF alignment ERROR
    env.mng.RegReadVerify32(`AXI_JESD_TX+32'h0108,32'h3);
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h0108,32'h3);

    env.mng.RegWrite32(`AXI_JESD_TX+32'h0108,32'h3);
    env.mng.RegWrite32(`AXI_JESD_RX+32'h0108,32'h3);


    // Invert SYSREF
    //
    system_tb.sysref_dly_sel = 2'b10;
    #1us;
    // Check SYSREF alignment ERROR
    env.mng.RegReadVerify32(`AXI_JESD_TX+32'h0108,32'h3);
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h0108,32'h3);

    env.mng.RegWrite32(`AXI_JESD_TX+32'h0108,32'h3);
    env.mng.RegWrite32(`AXI_JESD_RX+32'h0108,32'h3);

    #1us;

  end

endprogram
