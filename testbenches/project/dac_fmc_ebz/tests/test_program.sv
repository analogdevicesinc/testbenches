// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2024 Analog Devices, Inc. All rights reserved.
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
import adi_jesd204_pkg::*;
import adi_xcvr_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

`define LINK_MODE 2
`define MODE_8B10B 1
`define MODE_64B66B 2

`define fmod(A, B) (A - (B * $floor(A / B)))

program test_program;

  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  bit [31:0] lane_rate_khz = `LANE_RATE*1000000;
  longint lane_rate = lane_rate_khz*1000;

  real rx_device_clk, sysref_clk;

  jesd_link tx_link;
  jesd_link rx_link;

  rx_link_layer ex_rx_ll;
  tx_link_layer ex_tx_ll;
  xcvr ex_rx_xcvr;
  xcvr ex_tx_xcvr;

  rx_link_layer dut_rx_ll;
  tx_link_layer dut_tx_ll;
  xcvr dut_rx_xcvr;
  xcvr dut_tx_xcvr;

  initial begin

    //creating environment
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

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    base_env.sys_reset();

    tx_link = new;
    tx_link.set_L(`JESD_L);
    tx_link.set_M(`JESD_M);
    tx_link.set_F(`JESD_F);
    tx_link.set_S(`JESD_S);
    tx_link.set_K(32);
    tx_link.set_N(`JESD_NP);
    tx_link.set_NP(`JESD_NP);
    tx_link.set_encoding(enc8b10b);
    tx_link.set_lane_rate(lane_rate);

    ex_rx_ll = new("EX RX_LINK_LAYER", base_env.mng.master_sequencer, `EX_AXI_JESD_RX_BA, tx_link);
    ex_rx_ll.probe();

    ex_rx_xcvr = new("EX RX_XCVR", base_env.mng.master_sequencer, `EX_AXI_XCVR_RX_BA);
    ex_rx_xcvr.probe();

    dut_tx_xcvr = new("DUT TX_XCVR", base_env.mng.master_sequencer, `DUT_AXI_XCVR_TX_BA);
    dut_tx_xcvr.probe();

    dut_tx_ll = new("DUT TX_LINK_LAYER", base_env.mng.master_sequencer, `AXI_JESD_TX_BA, tx_link);
    dut_tx_ll.probe();

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));

    rx_device_clk = ex_rx_ll.calc_device_clk();
    sysref_clk = ex_rx_ll.calc_sysref_clk();

    `TH.`RX_DEVICE_CLK.inst.IF.set_clk_frq(rx_device_clk);
    `TH.`SYSREF_CLK.inst.IF.set_clk_frq(.user_frequency(sysref_clk));

    `TH.`REF_CLK.inst.IF.start_clock();
    `TH.`RX_DEVICE_CLK.inst.IF.start_clock();
    `TH.`SYSREF_CLK.inst.IF.start_clock();

    ex_rx_xcvr.setup_clocks(lane_rate,
                            `REF_CLK_RATE*1000000);

    dut_tx_xcvr.setup_clocks(lane_rate,
                            `REF_CLK_RATE*1000000, '{QPLL0, QPLL1});

    tx_tpl_test(.use_dds(0));

    base_env.stop();

    `TH.`REF_CLK.inst.IF.stop_clock();
    `TH.`RX_DEVICE_CLK.inst.IF.stop_clock();
    `TH.`SYSREF_CLK.inst.IF.stop_clock();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task tx_tpl_test(int use_dds);
    if (!use_dds) begin
      for (int i=0;i<2048*2 ;i=i+2) begin
        base_env.ddr.slave_sequencer.BackdoorWrite32(xil_axi_uint'(`DDR_BA+i*2),(((i+1)) << 16) | i ,15);
      end

      // Configure TX DMA
      base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_TLAST(1));
      base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h00000FFF));
      base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_SRC_ADDRESS),
                         `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BA+32'h00000000));
      base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      #5us;
    end

    for (int i = 0; i < `JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
        // Configure tone amplitude and frequency
        base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
        base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));

      end else begin
        // Set DMA as source for DAC TPL
        base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      end
    end

    for (int i = 0; i < `JESD_M; i++) begin
      base_env.mng.master_sequencer.RegWrite32(`EX_ADC_TPL_BA+'h40*i+GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end


    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA+GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    base_env.mng.master_sequencer.RegWrite32(`EX_ADC_TPL_BA+GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    if (use_dds) begin
      // Sync DDS cores
      base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA+GetAddrs(DAC_COMMON_REG_CNTRL_1),
                         `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    end

    // -----------------------
    // bringup DUT TX path
    // -----------------------
    dut_tx_xcvr.up();
    dut_tx_ll.link_up();

    ex_rx_xcvr.up();
    ex_rx_ll.link_up();

    dut_tx_ll.wait_link_up();
    ex_rx_ll.wait_link_up();

    #10us;

    ex_rx_xcvr.down();
    dut_tx_xcvr.down();
  endtask

  task check_captured_data(bit [31:0] address,
                           int length = 1024,
                           int step = 1,
                           int max_sample = 2048
                          );

    bit [31:0] current_address;
    bit [31:0] captured_word;
    bit [31:0] reference_word;
    bit [7:0] first, second;

    for (int i=0;i<length/2;i=i+2) begin
      current_address = address+(i*2);
      captured_word = base_env.ddr.slave_sequencer.BackdoorRead32(current_address);
      if (i==0) begin
        first = captured_word[15:8];
        second = captured_word[7:0];

      end else begin
        second = (second + 8'h02);
        reference_word = {first, (second+ 8'h01), first, second};

        if (second == 8'hfe) begin
          first = (first + 8'h01);
        end

        `INFO(("Address 0x%h Expected 0x%h found 0x%h",current_address,reference_word,captured_word), ADI_VERBOSITY_LOW);

        if (i > 20 && captured_word !== reference_word) begin
          `ERROR(("Address 0x%h Expected 0x%h found 0x%h",current_address,reference_word,captured_word));
        end
      end
    end
  endtask

endprogram
