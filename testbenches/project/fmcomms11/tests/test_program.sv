// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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
import adi_regmap_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import adi_regmap_data_offload_pkg::*;
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

program test_program;

  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env; 
  bit [31:0] val;

  jesd_link tx_link;
  jesd_link rx_link;

  tx_link_layer dut_tx_ll;
  rx_link_layer dut_rx_ll;
  xcvr dut_tx_xcvr;
  xcvr dut_rx_xcvr;

  tx_link_layer ex_tx_ll;
  rx_link_layer ex_rx_ll;
  xcvr ex_tx_xcvr;
  xcvr ex_rx_xcvr;

  bit [31:0] tx_lane_rate_khz = `TX_LANE_RATE*1000000;
  bit [31:0] rx_lane_rate_khz = `RX_LANE_RATE*1000000;
  longint unsigned tx_lane_rate = tx_lane_rate_khz*1000;
  longint unsigned rx_lane_rate = rx_lane_rate_khz*1000;
  real rx_device_clk, tx_device_clk;

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
    base_env.sys_reset();

    tx_link = new;
    tx_link.set_L(`TX_JESD_L);
    tx_link.set_M(`TX_JESD_M);
    tx_link.set_F(`TX_JESD_F);
    tx_link.set_S(`TX_JESD_S);
    tx_link.set_K(`TX_JESD_K);
    tx_link.set_N(`TX_JESD_NP);
    tx_link.set_NP(`TX_JESD_NP);
    tx_link.set_encoding(enc8b10b);
    tx_link.set_lane_rate(tx_lane_rate);
    tx_link.set_SUBCLASSV(sc0);

    rx_link = new;
    rx_link.set_L(`RX_JESD_L);
    rx_link.set_M(`RX_JESD_M);
    rx_link.set_F(`RX_JESD_F);
    rx_link.set_S(`RX_JESD_S);
    rx_link.set_K(`RX_JESD_K);
    rx_link.set_N(`RX_JESD_NP);
    rx_link.set_NP(`RX_JESD_NP);
    rx_link.set_encoding(enc8b10b);
    rx_link.set_lane_rate(rx_lane_rate);
    rx_link.set_SUBCLASSV(sc0);

    dut_tx_ll = new("DUT TX_LINK_LAYER", base_env.mng.sequencer, `DUT_TX_AXI_JESD_BA, tx_link);
    dut_tx_ll.probe();

    dut_rx_ll = new("DUT RX_LINK_LAYER", base_env.mng.sequencer, `DUT_RX_AXI_JESD_BA, rx_link);
    dut_rx_ll.probe();

    dut_tx_xcvr = new("DUT TX_XCVR", base_env.mng.sequencer, `DUT_TX_XCVR_BA);
    dut_tx_xcvr.probe();

    dut_rx_xcvr = new("DUT RX_XCVR", base_env.mng.sequencer, `DUT_RX_XCVR_BA);
    dut_rx_xcvr.probe();

    ex_tx_ll = new("EX TX_LINK_LAYER", base_env.mng.sequencer, `EX_TX_AXI_JESD_BA, rx_link);
    ex_tx_ll.probe();

    ex_rx_ll = new("EX RX_LINK_LAYER", base_env.mng.sequencer, `EX_RX_AXI_JESD_BA, tx_link);
    ex_rx_ll.probe();

    ex_tx_xcvr = new("EX TX_XCVR", base_env.mng.sequencer, `EX_TX_XCVR_BA);
    ex_tx_xcvr.probe();

    ex_rx_xcvr = new("EX RX_XCVR", base_env.mng.sequencer, `EX_RX_XCVR_BA);
    ex_rx_xcvr.probe();

    rx_device_clk = ex_rx_ll.calc_device_clk();
    tx_device_clk = ex_tx_ll.calc_device_clk();

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));
    `TH.`RX_DEVICE_CLK.inst.IF.set_clk_frq(rx_device_clk);
    `TH.`TX_DEVICE_CLK.inst.IF.set_clk_frq(tx_device_clk);

    `TH.`REF_CLK.inst.IF.start_clock();
    `TH.`RX_DEVICE_CLK.inst.IF.start_clock();
    `TH.`TX_DEVICE_CLK.inst.IF.start_clock();

    dut_tx_xcvr.setup_clocks(tx_lane_rate,
                            `REF_CLK_RATE*1000000, '{QPLL0, QPLL1});

    dut_rx_xcvr.setup_clocks(rx_lane_rate,
                            `REF_CLK_RATE*1000000, '{CPLL});

    ex_tx_xcvr.setup_clocks(rx_lane_rate,
                            `REF_CLK_RATE*1000000);

    ex_rx_xcvr.setup_clocks(tx_lane_rate,
                            `REF_CLK_RATE*1000000);

    jesd_tx_test(0);
    jesd_rx_test(0);

    base_env.stop();

    `TH.`REF_CLK.inst.IF.stop_clock();
    `TH.`RX_DEVICE_CLK.inst.IF.stop_clock();
    `TH.`TX_DEVICE_CLK.inst.IF.stop_clock();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  // -----------------
  // TX DATAPATH TEST
  // -----------------
  task jesd_tx_test(int use_dds);

    if (!use_dds) begin
      for (int i=0;i<2048*2 ;i=i+2) begin
        base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),(((i+1)) << 16) | i ,15);
      end

      // Configure TX DMA
      base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_TLAST(1));
      base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h00000FFF));
      base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_SRC_ADDRESS),
                         `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BA+32'h00000000));
      base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      #5us;
    end

    for (int i = 0; i < `TX_JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        base_env.mng.sequencer.RegWrite32(`DUT_DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
        // Configure tone amplitude and frequency
        base_env.mng.sequencer.RegWrite32(`DUT_DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
        base_env.mng.sequencer.RegWrite32(`DUT_DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));

      end else begin
        // Set DMA as source for DAC TPL
        base_env.mng.sequencer.RegWrite32(`DUT_DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      end
    end

    for (int i = 0; i < `TX_JESD_M; i++) begin
      base_env.mng.sequencer.RegWrite32(`EX_ADC_TPL_BA+'h40*i+GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end


    base_env.mng.sequencer.RegWrite32(`DUT_DAC_TPL_BA+GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    base_env.mng.sequencer.RegWrite32(`EX_ADC_TPL_BA+GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    if (use_dds) begin
      // Sync DDS cores
      base_env.mng.sequencer.RegWrite32(`DUT_DAC_TPL_BA+GetAddrs(DAC_COMMON_REG_CNTRL_1),
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

  endtask : jesd_tx_test

  // -----------------
  // RX DATAPATH TEST
  // -----------------
  task jesd_rx_test(int use_dds);

    for (int i = 0; i < `RX_JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        base_env.mng.sequencer.RegWrite32(`EX_DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
        // Configure tone amplitude and frequency
        base_env.mng.sequencer.RegWrite32(`EX_DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
        base_env.mng.sequencer.RegWrite32(`EX_DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));

      end else begin
        // Set DMA as source for DAC TPL
        base_env.mng.sequencer.RegWrite32(`EX_DAC_TPL_BA+'h40*i+GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      end
    end

    for (int i = 0; i < `RX_JESD_M; i++) begin
      base_env.mng.sequencer.RegWrite32(`DUT_ADC_TPL_BA+'h40*i+GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end

    base_env.mng.sequencer.RegWrite32(`EX_DAC_TPL_BA+GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    base_env.mng.sequencer.RegWrite32(`DUT_ADC_TPL_BA+GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    // -----------------------
    // bringup DUT RX path
    // -----------------------
    ex_tx_xcvr.up();
    ex_tx_ll.link_up();

    dut_rx_xcvr.up();
    dut_rx_ll.link_up();

    ex_tx_ll.wait_link_up();
    dut_rx_ll.wait_link_up();

    #10us;

    // Configure RX Offload
    base_env.mng.sequencer.RegWrite32(`RX_OFFLOAD_BA + GetAddrs(DO_CONTROL),
                       `SET_DO_CONTROL_ONESHOT_EN(1));
    base_env.mng.sequencer.RegWrite32(`RX_OFFLOAD_BA + GetAddrs(DO_TRANSFER_LENGTH),
                       `SET_DO_TRANSFER_LENGTH_PARTIAL_LENGTH(32'h0000000F));

    // Configure RX DMA
    if (!use_dds) begin
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_TLAST(1));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003DF));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_DEST_ADDRESS),
                         `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA+32'h00001000));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

      #5us;

      check_captured_data(
        .address (`DDR_BA+'h00001000),
        .length (992),
        .step (1),
        .max_sample(2048)
      );

      #10us;
    end

    dut_rx_xcvr.down();
    ex_tx_xcvr.down();

  endtask : jesd_rx_test

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
    bit [7:0] first, second;

    for (int i=0;i<length/2;i=i+2) begin
      current_address = address+(i*2);
      captured_word = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(current_address);
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
  endtask : check_captured_data

endprogram
