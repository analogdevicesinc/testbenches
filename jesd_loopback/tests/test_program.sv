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

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_jesd_tx_pkg::*;
import adi_regmap_jesd_rx_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_dac_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_jesd204_pkg::*;
import adi_xcvr_pkg::*;

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

  const int MODE_8B10B=1;
  const int MODE_64B66B=2;

  test_harness_env env;
  bit [31:0] val;
  reg [15:0] drp_val;

  jesd_link link;
  rx_link_layer rx_ll;
  tx_link_layer tx_ll;
  xcvr rx_xcvr;
  xcvr tx_xcvr;

  int use_dds = 0;
  bit [31:0] lane_rate_khz = `LANE_RATE*1000000;
  longint lane_rate = lane_rate_khz*1000;

  task drp_cm_write(input bit [31:0] xcvr_base,
                 input bit [7:0]  cm_sel,
                 input bit [11:0] cm_addr,
                 input bit [15:0] cm_wdata );

    env.mng.RegWrite32(xcvr_base+32'h0040,cm_sel);
    env.mng.RegWrite32(xcvr_base+32'h0044,cm_wdata | cm_addr << 16 | 1 <<28);

  endtask

  task drp_ch_write(input bit [31:0] xcvr_base,
                 input bit [7:0]  ch_sel,
                 input bit [11:0] ch_addr,
                 input bit [15:0] ch_wdata );

    env.mng.RegWrite32(xcvr_base+32'h0060,ch_sel);
    env.mng.RegWrite32(xcvr_base+32'h0064,ch_wdata | ch_addr << 16 | 1 <<28);

  endtask

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

    link = new;
    link.set_L(`JESD_L);
    link.set_M(`JESD_M);
    link.set_F(`JESD_F);
    link.set_S(`JESD_S);
    link.set_K(`JESD_K);
    link.set_N(`JESD_NP);
    link.set_NP(`JESD_NP);
    link.set_encoding(`LINK_MODE == MODE_8B10B ? enc8b10b : enc64b66b);
    link.set_lane_rate(lane_rate);

    rx_ll = new(env.mng, `AXI_JESD_RX, link);
    rx_ll.probe();

    tx_ll = new(env.mng, `AXI_JESD_TX, link);
    tx_ll.probe();

    rx_xcvr = new(env.mng, `ADC_XCVR);
    rx_xcvr.probe();

    tx_xcvr = new(env.mng, `DAC_XCVR);
    tx_xcvr.probe();

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));
    `TH.`DEVICE_CLK.inst.IF.set_clk_frq(.user_frequency(rx_ll.calc_device_clk()));
    `TH.`SYSREF_CLK.inst.IF.set_clk_frq(.user_frequency(rx_ll.calc_sysref_clk()));

    `TH.`REF_CLK.inst.IF.start_clock;
    `TH.`DEVICE_CLK.inst.IF.start_clock;
    `TH.`SYSREF_CLK.inst.IF.start_clock;

    // =======================
    // PRBS TEST
    // ======================= 
    prbs_test();

    // -----------------------
    // TX PHY INIT
    // -----------------------

    // DRP to QPLL
    // for 204C set divider to 33   (0014h [7:0] = 31)
    // for 204B set divider to 20   (0014h [7:0] = 18)
    if (`LINK_MODE == MODE_8B10B) begin
      drp_val = 18;
    end else begin
      drp_val = 31;
    end

    drp_cm_write(.xcvr_base(`DAC_XCVR),
              .cm_sel('hFF),
              .cm_addr('h014),
              .cm_wdata (drp_val));

    // DRP PROG DIVIDER for CH0
    // for 204C set divider to 33
    //     0xC208 for GTH3
    //     0xE218 for GTH4
    // for 204B set divider to 20
    //     for GTH3 57762
    //     for GTH4 'b1110000001100010
    if (`LINK_MODE == MODE_8B10B) begin
      drp_val = 'b1110000001100010;
    end else begin
      drp_val = 'hE218;
    end

    drp_ch_write(.xcvr_base(`DAC_XCVR),
              .ch_sel('h0),
              .ch_addr('h03E),
              .ch_wdata (drp_val));

    drp_ch_write(.xcvr_base(`ADC_XCVR),
              .ch_sel('h0),
              .ch_addr('h0C6),
              .ch_wdata (drp_val));

    env.mng.RegWrite32(`DAC_XCVR+32'h0020,32'h00001035);   // QPLL0; RXOUTCLK uses PROGDIVCLK
    tx_xcvr.up();

    // -----------------------
    // Configure TPL
    // -----------------------
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

    env.mng.RegWrite32(`DAC_TPL+GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    // Sync DDS cores
    env.mng.RegWrite32(`DAC_TPL+GetAddrs(DAC_COMMON_REG_CNTRL_1),
                       `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));

    tx_ll.link_up();

    // -----------------------
    // RX PHY INIT
    // -----------------------
    env.mng.RegWrite32(`ADC_XCVR+32'h0020,32'h00001035);   // QPLL0; RXOUTCLK uses PROGDIVCLK
    rx_xcvr.up();

    // -----------------------
    // Configure ADC TPL
    // -----------------------

    for (int i = 0; i < `JESD_M; i++) begin
      env.mng.RegWrite32(`ADC_TPL+'h40*i+GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end

    env.mng.RegWrite32(`ADC_TPL+GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    rx_ll.link_up();

    rx_ll.wait_link_up();
    tx_ll.wait_link_up();

    // Move data around for a while
    #5us;


    // =======================
    // Test SYSREF alignment 
    // ======================= 

    // Drift SYSREF with one device clock
    //
    system_tb.sysref_dly_sel = 2'b01;
    #1us;
    // Check SYSREF alignment ERROR
    env.mng.RegReadVerify32(`AXI_JESD_TX+GetAddrs(JESD_TX_SYSREF_STATUS),
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(JESD_RX_SYSREF_STATUS),
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));

    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(JESD_TX_SYSREF_STATUS),
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(JESD_RX_SYSREF_STATUS),
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));

    // Invert SYSREF
    //
    system_tb.sysref_dly_sel = 2'b10;
    #1us;
    // Check SYSREF alignment ERROR
    env.mng.RegReadVerify32(`AXI_JESD_TX+GetAddrs(JESD_TX_SYSREF_STATUS),
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));
    env.mng.RegReadVerify32(`AXI_JESD_RX+GetAddrs(JESD_RX_SYSREF_STATUS),
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));

    env.mng.RegWrite32(`AXI_JESD_TX+GetAddrs(JESD_TX_SYSREF_STATUS),
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));
    env.mng.RegWrite32(`AXI_JESD_RX+GetAddrs(JESD_RX_SYSREF_STATUS),
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));

    #1us;

  end


  // -----------------
  //
  // -----------------
  task prbs_test();

    fork
      rx_xcvr.up();
      tx_xcvr.up();
    join

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
    // No error should be detected, Lock should be set
    env.mng.RegReadVerify32(`ADC_XCVR+32'h0184,0<<8 | 1);

    // -----------------------
    // Check Error injection
    // -----------------------
    env.mng.RegWrite32(`DAC_XCVR+32'h0180, `PRBS_7 | 1<<16 ); // Enable Error inject
    env.mng.RegWrite32(`ADC_XCVR+32'h0180, 1 << 8); // Clear prbs err
    env.mng.RegWrite32(`ADC_XCVR+32'h0180, `PRBS_7);

    #1us;
    // Error should be detected
    env.mng.RegReadVerify32(`ADC_XCVR+32'h0184,1<<8 | 0);

    env.mng.RegWrite32(`DAC_XCVR+32'h0180, `PRBS_OFF);
    env.mng.RegWrite32(`ADC_XCVR+32'h0180, 1 << 8); // Clear prbs err
    env.mng.RegWrite32(`ADC_XCVR+32'h0180, `PRBS_OFF);

    rx_xcvr.down();
    tx_xcvr.down();

  endtask

endprogram
