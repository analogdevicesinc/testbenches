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

`define RX_DMA      32'h7c42_0000
`define RX_XCVR     32'h44a6_0000
`define TX_DMA      32'h7c43_0000
`define TX_XCVR     32'h44b6_0000
`define AXI_JESD_RX 32'h44a9_0000
`define ADC_TPL     32'h44a1_0000
`define DAC_TPL     32'h44b1_0000
`define AXI_JESD_TX 32'h44b9_0000
`define DDR_BASE    32'h8000_0000

program test_program;

  test_harness_env env;
  bit [31:0] val;

  initial begin
    //creating environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    #2ps;

    `TH.`DEVICE_CLK.inst.IF.set_clk_frq(.user_frequency(250000000));
    `TH.`DEVICE_CLK.inst.IF.start_clock;

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(500000000));
    `TH.`REF_CLK.inst.IF.start_clock;

    `TH.`SYSREF_CLK.inst.IF.start_clock;

    setLoggerVerbosity(6);
    env.start();

    #1us;

    //  -------------------------------------------------------
    //  Test DDS path
    //  -------------------------------------------------------

    // Configure Transport Layer for DDS
    //

    // Enable Rx channel CH0
    env.mng.RegWrite32(`ADC_TPL+(30'h0100<<2), 32'h00000001);
    // Enable Rx channel CH31
    env.mng.RegWrite32(`ADC_TPL+(30'h02F0<<2), 32'h00000001);

    // Select DDS as source CH0
    env.mng.RegWrite32(`DAC_TPL+(30'h0106<<2), 32'h00000000);
    // Configure tone amplitude and frequency  CH0
    env.mng.RegWrite32(`DAC_TPL+(30'h0100<<2), 32'h00000fff);
    env.mng.RegWrite32(`DAC_TPL+(30'h0101<<2), 32'h00000100);
    // Select DDS as source CH31
    env.mng.RegWrite32(`DAC_TPL+(30'h02F5<<2), 32'h00000000);
    // Configure tone amplitude and frequency  CH31
    env.mng.RegWrite32(`DAC_TPL+(30'h02F0<<2), 32'h000000ff);
    env.mng.RegWrite32(`DAC_TPL+(30'h02F1<<2), 32'h00000010);

    // Pull out TPL cores from reset
    env.mng.RegWrite32(`DAC_TPL+32'h0040, 32'h00000003);
    env.mng.RegWrite32(`ADC_TPL+32'h0040, 32'h00000003);

    // Sync DDS cores
    env.mng.RegWrite32(`DAC_TPL+32'h0044, 32'h00000001);


    //
    // Configure Link Layer
    //

    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_RX+32'h00c0, 32'h00000001);
    env.mng.RegWrite32(`AXI_JESD_TX+32'h00c0, 32'h00000001);

    //SYSREFCONF
    env.mng.RegWrite32(`AXI_JESD_RX+32'h0100, 32'h00000000); // Enable SYSREF handling
    env.mng.RegWrite32(`AXI_JESD_TX+32'h0100, 32'h00000000); // Enable SYSREF handling

    //CONF0
    env.mng.RegWrite32(`AXI_JESD_RX+32'h0210, 32'h0003007f); // F = 4 ; K=32
    env.mng.RegWrite32(`AXI_JESD_TX+32'h0210, 32'h0003007f); // F = 4 ; K=32
    //CONF1
    env.mng.RegWrite32(`AXI_JESD_RX+32'h0214, 32'h00000000);  // Scrambler enable
    env.mng.RegWrite32(`AXI_JESD_TX+32'h0214, 32'h00000000);  // Scrambler enable

    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_RX+32'h00c0, 32'h00000000);
    env.mng.RegWrite32(`AXI_JESD_TX+32'h00c0, 32'h00000000);


    //XCVR INIT
    //REG CTRL
    env.mng.RegWrite32(`RX_XCVR+32'h0020,32'h00001004);   // RXOUTCLK uses DIV2
    env.mng.RegWrite32(`TX_XCVR+32'h0020,32'h00001004);

    env.mng.RegWrite32(`RX_XCVR+32'h0010,32'h00000001);
    env.mng.RegWrite32(`TX_XCVR+32'h0010,32'h00000001);

    #35us;

    //Read status back
    // Check SYSREF_STATUS
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h108,1);
    env.mng.RegReadVerify32(`AXI_JESD_TX+32'h108,1);

    // Check if in DATA state and SYNC is 1
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h280,'h3);
    env.mng.RegReadVerify32(`AXI_JESD_TX+32'h280,'hF3);

    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_RX+32'h00c0, 32'h00000001);
    env.mng.RegWrite32(`AXI_JESD_TX+32'h00c0, 32'h00000001);

    //  -------------------------------------------------------
    //  Test DAC FIFO path
    //  -------------------------------------------------------

    // Init test data
    //
    for (int i=0;i<1024;i=i+2) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(i*2,(((i+1)*16) << 16) | (i*16) ,15);
    end

    // Configure TX DMA
    env.mng.RegWrite32(`TX_DMA+32'h400, 32'h00000001); // Enable DMA
    env.mng.RegWrite32(`TX_DMA+32'h40c, 32'h00000006); // use TLAST
    env.mng.RegWrite32(`TX_DMA+32'h418, 32'h000003FF); // X_LENGHT = 1k
    env.mng.RegWrite32(`TX_DMA+32'h408, 32'h00000001); // Submit transfer DMA

    #5us;

    // Configure Transport Layer for DMA  CH0
    env.mng.RegWrite32(`DAC_TPL+(30'h0106<<2), 32'h00000002);
    // Configure Transport Layer for DMA  CH31
    env.mng.RegWrite32(`DAC_TPL+(30'h02F6<<2), 32'h00000002);

    #1us;

    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_RX+32'h00c0, 32'h00000000);
    env.mng.RegWrite32(`AXI_JESD_TX+32'h00c0, 32'h00000000);


    #15us;

    //Read status back
    // Check SYSREF_STATUS
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h108,1);
    env.mng.RegReadVerify32(`AXI_JESD_TX+32'h108,1);

    #1us;

    // Check if in DATA state and SYNC is 1
    env.mng.RegReadVerify32(`AXI_JESD_RX+32'h280,'h3);
    env.mng.RegReadVerify32(`AXI_JESD_TX+32'h280,'hF3);

    #2us;

  end

endprogram
