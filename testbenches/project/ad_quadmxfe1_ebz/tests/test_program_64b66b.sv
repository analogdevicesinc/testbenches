// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2018 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
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

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

`define PHY121 32'h44A4_0000
`define PHY125 32'h44A5_0000


program test_program_64b66b;

  timeunit 1ns;
  timeprecision 1ps;

  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  int tmp;

  initial begin

    // create environment
    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(`IRQ_C_BA),
      .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

    mng = new("", `TH.`MNG_AXI.inst.IF);
    ddr = new("", `TH.`DDR_AXI.inst.IF);

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    `TH.`DEVICE_CLK.inst.IF.start_clock();
    `TH.`REF_CLK.inst.IF.start_clock();
    `TH.`DRP_CLK.inst.IF.start_clock();
    `TH.`SYSREF_CLK.inst.IF.start_clock();

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    base_env.sys_reset();

    #1us;
    base_env.mng.master_sequencer.RegRead32(`DAC_TPL_BA+'h0c,tmp);
    `INFO(("DAC TPL CONFIG is %h",tmp), ADI_VERBOSITY_LOW);
    base_env.mng.master_sequencer.RegRead32(`DAC_TPL_BA+'h418,tmp);
    `INFO(("DAC TPL CH0 SEL is %h",tmp), ADI_VERBOSITY_LOW);
    base_env.mng.master_sequencer.RegRead32(`DAC_TPL_BA+'h458,tmp);
    `INFO(("DAC TPL CH1 SEL is %h",tmp), ADI_VERBOSITY_LOW);

    base_env.mng.master_sequencer.RegRead32(`RX_DMA_BA+32'h0010,tmp);
   `INFO(("RX_DMA_BA interface setup is %h",tmp), ADI_VERBOSITY_LOW);
    base_env.mng.master_sequencer.RegRead32(`TX_DMA_BA+32'h0010,tmp);
   `INFO(("TX_DMA_BA interface setup is %h",tmp), ADI_VERBOSITY_LOW);

    //  -------------------------------------------------------
    //  Test DDS path
    //  -------------------------------------------------------

    // Configure Transport Layer for DDS
    //

    // Enable Rx channel CH0
    base_env.mng.master_sequencer.RegWrite32(`ADC_TPL_BA+(30'h0100<<2),
                       `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    // Enable Rx channel CH31
    base_env.mng.master_sequencer.RegWrite32(`ADC_TPL_BA+(30'h02F0<<2),
                       `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));

    // Enable Rx channel CH63
    base_env.mng.master_sequencer.RegWrite32(`ADC_TPL_BA+(30'h04F0<<2),
                       `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));

    // Select DDS as source CH0
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + (30'h0106<<2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    // Configure tone amplitude and frequency  CH0
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + (30'h0100<<2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h4000));
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + (30'h0101<<2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h28f5));
    // Select DDS as source CH31
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + (30'h02F6<<2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    // Select DDS as source CH63
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + (30'h04F6<<2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    // Configure tone amplitude and frequency  CH31
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + (30'h02F0<<2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h4000));
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + (30'h02F1<<2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h3333));
    // Configure tone amplitude and frequency  CH63
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + (30'h04F0<<2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h02ff));
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + (30'h04F1<<2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0020));

    // Arm external sync
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),
                       `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    base_env.mng.master_sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_CNTRL),
                       `SET_ADC_COMMON_REG_CNTRL_SYNC(1));


    // Configure RX DMA
    base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_CONTROL),
                       `SET_DMAC_CONTROL_ENABLE(1));
    base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003FF));
    base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    base_env.mng.master_sequencer.RegWrite32(`ADC_TPL_BA +  GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));
    // Sync DDS cores
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),
                       `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));

    //
    // Configure Link Layer
    //

    //LINK DISABLE
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));

    //SYSREFCONF
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_SYSREF_CONF),
                       `SET_JESD_RX_SYSREF_CONF_SYSREF_DISABLE(0));
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_SYSREF_CONF),
                       `SET_JESD_TX_SYSREF_CONF_SYSREF_DISABLE(0));
    //CONF0
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_CONF0),
                       `SET_JESD_TX_LINK_CONF0_OCTETS_PER_FRAME('h3) |
                       `SET_JESD_TX_LINK_CONF0_OCTETS_PER_MULTIFRAME('hff));
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_CONF0),
                       `SET_JESD_RX_LINK_CONF0_OCTETS_PER_FRAME('h3) |
                       `SET_JESD_RX_LINK_CONF0_OCTETS_PER_MULTIFRAME('hff));

    //CONF1
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_CONF1),
                       `SET_JESD_TX_LINK_CONF1_SCRAMBLER_DISABLE(0));
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_CONF1),
                       `SET_JESD_RX_LINK_CONF1_DESCRAMBLER_DISABLE(0));
    //LINK ENABLE
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(0));
    //enable near end loopback
//    for (int i=0;i<8;i++) begin
//        base_env.mng.master_sequencer.RegWrite32(`PHY121+32'h0024, i);
//        base_env.mng.master_sequencer.RegWrite32(`PHY121+32'h041c, 32'h00000001);
//        base_env.mng.master_sequencer.RegWrite32(`PHY125+32'h0024, i);
//        base_env.mng.master_sequencer.RegWrite32(`PHY125+32'h041c, 32'h00000001);
//    end

    //XCVR INIT
    //REG CTRL
//    base_env.mng.master_sequencer.RegWrite32(`RX_XCVR_BA+32'h0020,32'h00001004);   // RXOUTCLK uses DIV2
//    base_env.mng.master_sequencer.RegWrite32(`TX_XCVR_BA+32'h0020,32'h00001004);

//    base_env.mng.master_sequencer.RegWrite32(`RX_XCVR_BA+32'h0010,32'h00000001);
//    base_env.mng.master_sequencer.RegWrite32(`TX_XCVR_BA+32'h0010,32'h00000001);

    #35us;

    //Read status back
    // Check SYSREF_STATUS
    base_env.mng.master_sequencer.RegReadVerify32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_SYSREF_STATUS),
                            `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));
    base_env.mng.master_sequencer.RegReadVerify32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_SYSREF_STATUS),
                            `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));

    // Check if in DATA state
    base_env.mng.master_sequencer.RegReadVerify32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_LINK_STATUS),
                            `SET_JESD_RX_LINK_STATUS_STATUS_STATE(3));
    base_env.mng.master_sequencer.RegReadVerify32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_LINK_STATUS),
                            `SET_JESD_TX_LINK_STATUS_STATUS_STATE(3));

    //LINK DISABLE
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));

    //  -------------------------------------------------------
    //  Test DAC FIFO path
    //  -------------------------------------------------------

    // Init test data
    //

    for (int i=0;i<1024;i=i+2) begin
      base_env.ddr.slave_sequencer.BackdoorWrite32(i*2,(((i+1)*16) << 16) | (i*16) ,15);
    end

    // Arm external sync
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),
                       `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    base_env.mng.master_sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_CNTRL),
                       `SET_ADC_COMMON_REG_CNTRL_SYNC(1));

    // Configure RX DMA
    base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_CONTROL),
                       `SET_DMAC_CONTROL_ENABLE(1));
    base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003FF));
    base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
    // Configure TX DMA
    base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_CONTROL),
                       `SET_DMAC_CONTROL_ENABLE(1));
    base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_FLAGS),
                       `SET_DMAC_FLAGS_TLAST(1));
    base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003FF));
    base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));


    #5us;

    // Configure Transport Layer for DMA  CH0
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA+(30'h0106<<2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
    // Configure Transport Layer for DMA  CH31
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA+(30'h02F6<<2),
                       `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));

    // Enable broadcast of channel 0 to all others
    for (int i = 1; i < 31; i++) begin
      base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA+((30'h0106<<2)+(i*'h40)), 32'h00010000);
    end

    #1us;

    //LINK ENABLE
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_LINK_DISABLE),
                       `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(0));
    base_env.mng.master_sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_LINK_DISABLE),
                       `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));

    #35us;

    //Read status back
    // Check SYSREF_STATUS
    base_env.mng.master_sequencer.RegReadVerify32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_SYSREF_STATUS),
                            `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));
    base_env.mng.master_sequencer.RegReadVerify32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_SYSREF_STATUS),
                            `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));
    #1us;

    // Check if in DATA state
    base_env.mng.master_sequencer.RegReadVerify32(`AXI_JESD_RX_BA+GetAddrs(JESD_RX_LINK_STATUS),
                            `SET_JESD_RX_LINK_STATUS_STATUS_STATE(3));
    base_env.mng.master_sequencer.RegReadVerify32(`AXI_JESD_TX_BA+GetAddrs(JESD_TX_LINK_STATUS),
                            `SET_JESD_TX_LINK_STATUS_STATUS_STATE(3));
    #2us;

    base_env.stop();

    `TH.`DRP_CLK.inst.IF.stop_clock();
    `TH.`REF_CLK.inst.IF.stop_clock();
    `TH.`DEVICE_CLK.inst.IF.stop_clock();
    `TH.`SYSREF_CLK.inst.IF.stop_clock();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
