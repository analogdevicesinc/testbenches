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
    env.mng.RegWrite32(`ADC_TPL+(30'h0100<<2),
                       `SET_adc_channel_REG_CHAN_CNTRL_ENABLE(1));
    // Enable Rx channel CH31
    env.mng.RegWrite32(`ADC_TPL+(30'h02F0<<2),
                       `SET_adc_channel_REG_CHAN_CNTRL_ENABLE(1));

    // Select DDS as source CH0
    env.mng.RegWrite32(`DAC_TPL + (30'h0106<<2),
                       `SET_dac_channel_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    // Configure tone amplitude and frequency  CH0
    env.mng.RegWrite32(`DAC_TPL + (30'h0100<<2),
                       `SET_dac_channel_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h4000));
    env.mng.RegWrite32(`DAC_TPL + (30'h0101<<2),
                       `SET_dac_channel_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h28f5));
    // Select DDS as source CH31
    env.mng.RegWrite32(`DAC_TPL + (30'h02F6<<2),
                       `SET_dac_channel_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    // Configure tone amplitude and frequency  CH31
    env.mng.RegWrite32(`DAC_TPL + (30'h02F0<<2),
                       `SET_dac_channel_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h4000));
    env.mng.RegWrite32(`DAC_TPL + (30'h02F1<<2),
                       `SET_dac_channel_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h3333));
 
    // Pull out TPL cores from reset
    env.mng.RegWrite32(`DAC_TPL+GetAddrs(dac_common_REG_RSTN),
                       `SET_dac_common_REG_RSTN_RSTN(1));
    env.mng.RegWrite32(`ADC_TPL+GetAddrs(adc_common_REG_RSTN),
                       `SET_adc_common_REG_RSTN_RSTN(1)); 
    // Sync DDS cores
    env.mng.RegWrite32(`DAC_TPL+GetAddrs(dac_common_REG_CNTRL_1),
                       `SET_dac_common_REG_CNTRL_1_SYNC(1));

    //
    // Configure Link Layer
    //

    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(jesd_rx_LINK_DISABLE),
                       `SET_jesd_rx_LINK_DISABLE_LINK_DISABLE(1));
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_DISABLE),
                       `SET_jesd_tx_LINK_DISABLE_LINK_DISABLE(1));
    //SYSREFCONF
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(jesd_rx_SYSREF_CONF),
                       `SET_jesd_rx_SYSREF_CONF_SYSREF_DISABLE(0)); 
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(jesd_tx_SYSREF_CONF),
                       `SET_jesd_tx_SYSREF_CONF_SYSREF_DISABLE(0));
    //CONF0
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(jesd_rx_LINK_CONF0),
                       `SET_jesd_rx_LINK_CONF0_OCTETS_PER_FRAME('h3) | 
                       `SET_jesd_rx_LINK_CONF0_OCTETS_PER_MULTIFRAME('h7f));
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_CONF0),
                       `SET_jesd_tx_LINK_CONF0_OCTETS_PER_FRAME('h3) | 
                       `SET_jesd_tx_LINK_CONF0_OCTETS_PER_MULTIFRAME('h7f));
    //CONF1
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(jesd_rx_LINK_CONF1),
                       `SET_jesd_rx_LINK_CONF1_DESCRAMBLER_DISABLE(0)); 
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_CONF1),
                       `SET_jesd_tx_LINK_CONF1_SCRAMBLER_DISABLE(0));
    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(jesd_rx_LINK_DISABLE),
                       `SET_jesd_rx_LINK_DISABLE_LINK_DISABLE(0));
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_DISABLE),
                       `SET_jesd_tx_LINK_DISABLE_LINK_DISABLE(0));

    //XCVR INIT
    //REG CTRL
    env.mng.RegWrite32(`RX_XCVR+32'h0020,32'h00001004);   // RXOUTCLK uses DIV2
    env.mng.RegWrite32(`TX_XCVR+32'h0020,32'h00001004);

    env.mng.RegWrite32(`RX_XCVR+32'h0010,32'h00000001);
    env.mng.RegWrite32(`TX_XCVR+32'h0010,32'h00000001);

    #35us;

    //Read status back
    // Check SYSREF_STATUS
    env.mng.RegReadVerify32(`AXI_JESD_TX+GetAddrs(jesd_tx_SYSREF_STATUS),
                            `SET_jesd_tx_SYSREF_STATUS_SYSREF_DETECTED(1));
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(jesd_rx_SYSREF_STATUS),
                            `SET_jesd_rx_SYSREF_STATUS_SYSREF_DETECTED(1));
    // Check if in DATA state and SYNC is 1
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(jesd_rx_LINK_STATUS),
                            `SET_jesd_rx_LINK_STATUS_STATUS_STATE('h3));
    env.mng.RegReadVerify32(`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_STATUS),
                            `SET_jesd_tx_LINK_STATUS_STATUS_STATE('h3) | 
                            `SET_jesd_tx_LINK_STATUS_STATUS_SYNC('hf));
    //LINK DISABLE
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(jesd_rx_LINK_DISABLE),
                       `SET_jesd_rx_LINK_DISABLE_LINK_DISABLE(1));
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_DISABLE),
                       `SET_jesd_tx_LINK_DISABLE_LINK_DISABLE(1));
    //  -------------------------------------------------------
    //  Test DAC FIFO path
    //  -------------------------------------------------------

    // Init test data
    //
    for (int i=0;i<1024;i=i+2) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(i*2,(((i+1)*16) << 16) | (i*16) ,15);
    end

    // Configure TX DMA
    env.mng.RegWrite32(`TX_DMA+GetAddrs(dmac_CONTROL),
                       `SET_dmac_CONTROL_ENABLE(1));
    env.mng.RegWrite32(`TX_DMA+GetAddrs(dmac_FLAGS),
                       `SET_dmac_FLAGS_TLAST(1));
    env.mng.RegWrite32(`TX_DMA+GetAddrs(dmac_X_LENGTH),
                       `SET_dmac_X_LENGTH_X_LENGTH(32'h000003FF));
    env.mng.RegWrite32(`TX_DMA+GetAddrs(dmac_TRANSFER_SUBMIT),
                       `SET_dmac_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));   
    #5us;

    // Configure Transport Layer for DMA  CH0
    env.mng.RegWrite32(`DAC_TPL+(30'h0106<<2), 32'h00000002);
    // Configure Transport Layer for DMA  CH31
    env.mng.RegWrite32(`DAC_TPL+(30'h02F6<<2), 32'h00000002);

    #1us;

    //LINK ENABLE
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(jesd_rx_LINK_DISABLE),
                       `SET_jesd_rx_LINK_DISABLE_LINK_DISABLE(0));
    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_DISABLE),
                       `SET_jesd_tx_LINK_DISABLE_LINK_DISABLE(0));

    #15us;

    //Read status back
    // Check SYSREF_STATUS
    env.mng.RegReadVerify32(`AXI_JESD_TX+GetAddrs(jesd_tx_SYSREF_STATUS),
                            `SET_jesd_tx_SYSREF_STATUS_SYSREF_DETECTED(1));
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(jesd_rx_SYSREF_STATUS),
                            `SET_jesd_rx_SYSREF_STATUS_SYSREF_DETECTED(1));

    #1us;

    // Check if in DATA state and SYNC is 1
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(jesd_rx_LINK_STATUS),
                            `SET_jesd_rx_LINK_STATUS_STATUS_STATE('h3));
    env.mng.RegReadVerify32(`AXI_JESD_TX+GetAddrs(jesd_tx_LINK_STATUS),
                            `SET_jesd_tx_LINK_STATUS_STATUS_STATE('h3) | 
                            `SET_jesd_tx_LINK_STATUS_STATUS_SYNC('hf));

    #2us;

  end

endprogram
