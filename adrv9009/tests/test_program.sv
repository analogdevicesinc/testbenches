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
import adi_jesd204_pkg::*;
import adi_xcvr_pkg::*;


`define JESD_PHY    32'h44a6_0000
`define AXI_JESD_RX 32'h44a9_0000
`define AXI_JESD_TX 32'h44b9_0000
`define ADC_TPL     32'h44a1_0000
`define DAC_TPL     32'h44b1_0000

`define EX_AXI_XCVR_RX 32'h44a2_0000
`define EX_AXI_XCVR_TX 32'h44a5_0000
`define EX_AXI_JESD_RX 32'h44A0_0000
`define EX_AXI_JESD_TX 32'h44A4_0000

`define LINK_MODE 2
`define MODE_8B10B 1
`define MODE_64B66B 2

program test_program;

  test_harness_env env;
  // bit [31:0] val;

  // bit [31:0] lane_rate_khz = `LANE_RATE*1000000;
  // longint lane_rate = lane_rate_khz*1000;

  // int use_dds = 0;

  // jesd_link link;
  // rx_link_layer ex_rx_ll;
  // tx_link_layer ex_tx_ll;
  // xcvr ex_rx_xcvr;
  // xcvr ex_tx_xcvr;

  // rx_link_layer dut_rx_ll;
  // tx_link_layer dut_tx_ll;


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

    // link = new;
    // link.set_L(`JESD_L);
    // link.set_M(`JESD_M);
    // link.set_F(`JESD_F);
    // link.set_S(`JESD_S);
    // link.set_K(`JESD_K);
    // link.set_N(`JESD_NP);
    // link.set_NP(`JESD_NP);
    // link.set_encoding(`LINK_MODE == `MODE_8B10B ? enc8b10b : enc64b66b);
    // link.set_lane_rate(lane_rate);

    // ex_rx_ll = new("RX_LINK_LAYER", env.mng, `EX_AXI_JESD_RX, link);
    // ex_rx_ll.probe();

    // ex_tx_ll = new("TX_LINK_LAYER", env.mng, `EX_AXI_JESD_TX, link);
    // ex_tx_ll.probe();

    // ex_rx_xcvr = new("RX_XCVR", env.mng, `EX_AXI_XCVR_RX);
    // ex_rx_xcvr.probe();

    // ex_tx_xcvr = new("TX_XCVR", env.mng, `EX_AXI_XCVR_TX);
    // ex_tx_xcvr.probe();


    // dut_rx_ll = new("DUT RX_LINK_LAYER", env.mng, `AXI_JESD_RX, link);
    // dut_rx_ll.probe();

    // dut_tx_ll = new("DUT TX_LINK_LAYER", env.mng, `AXI_JESD_TX, link);
    // dut_tx_ll.probe();

    // `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));
    // `TH.`DEVICE_CLK.inst.IF.set_clk_frq(.user_frequency(ex_rx_ll.calc_device_clk()));
    // `TH.`SYSREF_CLK.inst.IF.set_clk_frq(.user_frequency(ex_rx_ll.calc_sysref_clk()));

    // `TH.`REF_CLK.inst.IF.start_clock;
    // `TH.`DEVICE_CLK.inst.IF.start_clock;
    // `TH.`SYSREF_CLK.inst.IF.start_clock;

    // ex_rx_xcvr.setup_clocks(lane_rate,
    //                         `REF_CLK_RATE*1000000);

    // ex_tx_xcvr.setup_clocks(lane_rate,
    //                        `REF_CLK_RATE*1000000);

    // for (int i = 0; i < `JESD_M; i++) begin
    //   if (use_dds) begin
    //     // Select DDS as source
    //     env.mng.RegWrite32(`DAC_TPL+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
    //                        `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    //     // Configure tone amplitude and frequency
    //     env.mng.RegWrite32(`DAC_TPL+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
    //                        `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
    //     env.mng.RegWrite32(`DAC_TPL+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
    //                        `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));

    //   end else begin
    //     // Set DMA as source for DAC TPL
    //     env.mng.RegWrite32(`DAC_TPL+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
    //                        `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
    //   end
    // end

    // for (int i = 0; i < `JESD_M; i++) begin
    //   env.mng.RegWrite32(`ADC_TPL+'h40*i+GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
    //                      `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    // end


    // env.mng.RegWrite32(`DAC_TPL+GetAddrs(DAC_COMMON_REG_RSTN),
    //                    `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    // env.mng.RegWrite32(`ADC_TPL+GetAddrs(ADC_COMMON_REG_RSTN),
    //                    `SET_ADC_COMMON_REG_RSTN_RSTN(1));


    // // Sync DDS cores
    // env.mng.RegWrite32(`DAC_TPL+GetAddrs(DAC_COMMON_REG_CNTRL_1),
    //                    `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));


    // // -----------------------
    // // bringup DUT TX path
    // // -----------------------
    // dut_tx_ll.link_up();

    // ex_rx_xcvr.up();
    // ex_rx_ll.link_up();

    // dut_tx_ll.wait_link_up();
    // ex_rx_ll.wait_link_up();


    // // -----------------------
    // // bringup DUT RX path
    // // -----------------------
    // ex_tx_xcvr.up();
    // ex_tx_ll.link_up();

    // dut_rx_ll.link_up();

    // ex_tx_ll.wait_link_up();
    // dut_rx_ll.wait_link_up();


    // // Move data around
    // #10us;

    // ex_rx_xcvr.down();
    // ex_tx_xcvr.down();

    // `INFO(("======================="));
    // `INFO(("  JESD LINK TEST DONE  "));
    // `INFO(("======================="));


  end

endprogram
