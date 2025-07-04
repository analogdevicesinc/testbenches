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
import adi_regmap_tdd_gen_pkg::*;
import adi_jesd204_pkg::*;
import adi_xcvr_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program;

  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  bit [31:0] val;
  bit [63:0] val64;

  jesd_link link;
  rx_link_layer rx_ll;
  tx_link_layer tx_ll;
  xcvr rx_xcvr;
  xcvr tx_xcvr;

  int use_dds = 1;
  int has_fsrc = `FSRC_ENABLE;
  bit [31:0] lane_rate_khz = `RX_LANE_RATE*1000000;
  longint unsigned lane_rate = lane_rate_khz*1000;

  localparam TX_FSRC_ACCUM_WIDTH = `ACCUM_WIDTH;
  localparam TX_FSRC_CHANNEL_TO_SAMPLE_RATE_RATIO = 0.6666667;
  localparam logic [TX_FSRC_ACCUM_WIDTH:0] ONE_FIXED = {1'b1, {TX_FSRC_ACCUM_WIDTH{1'b0}}};
  localparam logic [TX_FSRC_ACCUM_WIDTH-1:0] TX_FSRC_CHANNEL_TO_SAMPLE_RATE_RATIO_FIXED = ONE_FIXED * TX_FSRC_CHANNEL_TO_SAMPLE_RATE_RATIO;

  initial begin

    //creating environment
    base_env = new("Base Environment",
                    `TH.`SYS_CLK.inst.IF,
                    `TH.`DMA_CLK.inst.IF,
                    `TH.`DDR_CLK.inst.IF,
                    `TH.`SYS_RST.inst.IF,
                    `TH.`MNG_AXI.inst.IF,
                    `TH.`DDR_AXI.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_MEDIUM);

    base_env.start();
    base_env.sys_reset();

    link = new;
    link.set_L(`RX_JESD_L);
    link.set_M(`RX_JESD_M);
    link.set_F(`RX_JESD_F);
    link.set_S(`RX_JESD_S);
    link.set_K(`RX_JESD_K);
    link.set_N(`RX_JESD_NP);
    link.set_NP(`RX_JESD_NP);
    link.set_encoding(`JESD_MODE != "64B66B" ? enc8b10b : enc64b66b);
    link.set_lane_rate(lane_rate);

    rx_ll = new("RX_LINK_LAYER", base_env.mng.sequencer, `AXI_JESD_RX_BA, link);
    rx_ll.probe();

    tx_ll = new("TX_LINK_LAYER", base_env.mng.sequencer, `AXI_JESD_TX_BA, link);
    tx_ll.probe();

    rx_xcvr = new("RX_XCVR", base_env.mng.sequencer, `RX_XCVR_BA);
    rx_xcvr.probe();

    tx_xcvr = new("TX_XCVR", base_env.mng.sequencer, `TX_XCVR_BA);
    tx_xcvr.probe();

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));
    `TH.`DEVICE_CLK.inst.IF.set_clk_frq(.user_frequency(rx_ll.calc_device_clk()));
    `TH.`SYSREF_CLK.inst.IF.set_clk_frq(.user_frequency(rx_ll.calc_sysref_clk()));
    `TH.`DMA_CLK.inst.IF.set_clk_frq(.user_frequency(rx_ll.calc_device_clk()));

    `TH.`REF_CLK.inst.IF.start_clock();
    `TH.`DEVICE_CLK.inst.IF.start_clock();
    `TH.`SYSREF_CLK.inst.IF.start_clock();

    rx_xcvr.setup_clocks(lane_rate,
                         `REF_CLK_RATE*1000000);

    tx_xcvr.setup_clocks(lane_rate,
                         `REF_CLK_RATE*1000000);


    // Configure FSRC RX
    // Nothing todo

    // Configure FSRC TX

    // =======================
    // JESD LINK TEST - DDS
    // =======================
    // jesd_link_test(1);

    // =======================
    // JESD LINK TEST - DMA
    // =======================
    jesd_link_test(0,0,0,0,1);

    // =======================
    // JESD LINK TEST - DMA - RX/TX BYPASS
    // =======================
    // jesd_link_test(0,1,1);

    // =======================
    // JESD LINK TEST - DMA - DO -TDD
    // =======================
    // jesd_link_test(0,0,0,1);

    // =======================
    // JESD LINK TEST - DDS - EXT_SYNC
    // =======================
    // jesd_link_test_ext_sync(1);

    // =======================
    // JESD LINK TEST - DMA - EXT_SYNC
    // =======================
    // jesd_link_test_ext_sync(0);

    // base_env.mng.sequencer.RegWrite32(`FSRC_RX_BA + 'h10, 32'd0);

    base_env.stop();

    `TH.`REF_CLK.inst.IF.stop_clock();
    `TH.`DEVICE_CLK.inst.IF.stop_clock();
    `TH.`SYSREF_CLK.inst.IF.stop_clock();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  // -----------------
  //
  // -----------------
  task configure_fsrc_sequencer();
    `INFO(("Configure FSRC Squencer"), ADI_VERBOSITY_NONE);
    base_env.mng.sequencer.RegWrite32(`FSRC_CTRL_BA + 'h14, {16'd1002, 16'd1002}); // SEQ_CTRL_2
    base_env.mng.sequencer.RegWrite32(`FSRC_CTRL_BA + 'h18, {16'd1102, 16'd0}); // SEQ_CTRL_3
    base_env.mng.sequencer.RegWrite32(`FSRC_CTRL_BA + 'h1c, {16'd2102, 16'b0}); // SEQ_CTRL_4
    base_env.mng.sequencer.RegWrite32(`FSRC_CTRL_BA + 'h18, {16'd1102, 16'b10}); // SEQ_CTRL_3
  endtask : configure_fsrc_sequencer

  // -----------------
  //
  // -----------------
  task configure_tx_fsrc();
    `INFO(("Configure TX FSRC"), ADI_VERBOSITY_NONE);
    // NS is 0 (NS_PARAM = 0)
    base_env.mng.sequencer.RegWrite32(`FSRC_TX_BA + 'h18, 32'hFF); // CONV_MAS
    `INFO(("sample_rate_fixed %h", TX_FSRC_CHANNEL_TO_SAMPLE_RATE_RATIO_FIXED), ADI_VERBOSITY_MEDIUM);
    for (int i = 0; i <= 15; i++) begin
      val64 = (~TX_FSRC_CHANNEL_TO_SAMPLE_RATE_RATIO_FIXED + 64'b1) + (i * TX_FSRC_CHANNEL_TO_SAMPLE_RATE_RATIO_FIXED);
      `INFO(("val64 %h", val64), ADI_VERBOSITY_MEDIUM);
      base_env.mng.sequencer.RegWrite32(`FSRC_TX_BA + 'h28, val64[31:0]);
      base_env.mng.sequencer.RegWrite32(`FSRC_TX_BA + 'h2c, val64[63:32]);
      base_env.mng.sequencer.RegWrite32(`FSRC_TX_BA + 'h24, i);
    end
    val64 = TX_FSRC_CHANNEL_TO_SAMPLE_RATE_RATIO_FIXED;
    base_env.mng.sequencer.RegWrite32(`FSRC_TX_BA + 'h1c, val64[31:0]); // Add val
    base_env.mng.sequencer.RegWrite32(`FSRC_TX_BA + 'h20, val64[63:32]); // Add val
    base_env.mng.sequencer.RegWrite32(`FSRC_TX_BA + 'h14, {32'b100}); // CTRL_TRANSMIT SET
  endtask : configure_tx_fsrc

  // -----------------
  //
  // -----------------
  task enable_and_start_tx_fsrc();
    `INFO(("Enable TX FSRC"), ADI_VERBOSITY_NONE);
    // AXI_FSRC_TX_ENABLE
    base_env.mng.sequencer.RegWrite32(`FSRC_TX_BA + 'h10, 32'b1); // TX_EN
    base_env.mng.sequencer.RegWrite32(`FSRC_TX_BA + 'h14, 32'b1); // CTRL_TRANSMIT@start
  endtask : enable_and_start_tx_fsrc

  // -----------------
  //
  // -----------------
  task enable_rx_fsrc();
    `INFO(("Enable REG FSRC"), ADI_VERBOSITY_NONE);
    base_env.mng.sequencer.RegWrite32(`FSRC_RX_BA + 'h10, 32'd1);
  endtask : enable_rx_fsrc

  // -----------------
  //
  // -----------------
  task enable_and_start_seq_fsrc();
    `INFO(("Enable Seq FSRC"), ADI_VERBOSITY_NONE);
    // Uncomment to use trig_in instead of reg access ctrl_3.seq_start
    //base_env.mng.sequencer.RegWrite32(`FSRC_CTRL_BA + 'h1c, {16'd2102, 16'b01}); // SEQ_CTRL_4@ext_trig_en
    base_env.mng.sequencer.RegWrite32(`FSRC_CTRL_BA + 'h18, {16'd1102, 16'b10}); // SEQ_CTRL_3@seq_start
    base_env.mng.sequencer.RegWrite32(`FSRC_CTRL_BA + 'h18, {16'd1102, 16'b11}); // SEQ_CTRL_3@seq_start
  endtask : enable_and_start_seq_fsrc


  // -----------------
  //
  // -----------------
  task stop_and_disable_tx_fsrc();
    `INFO(("Stop TX FSRC"), ADI_VERBOSITY_NONE);
    base_env.mng.sequencer.RegWrite32(`FSRC_TX_BA + 'h14, 32'b10); // CTRL_TRANSMIT@stop
    base_env.mng.sequencer.RegWrite32(`FSRC_TX_BA + 'h10, 32'b0); // TX_EN
  endtask : stop_and_disable_tx_fsrc

  // -----------------
  //
  // -----------------
  task jesd_link_test(input use_dds = 1,
                      input rx_bypass = 0,
                      input tx_bypass = 0,
                      input tdd_enabled = 0,
		      input use_fsrc = 0);

    `INFO(("======================="), ADI_VERBOSITY_LOW);
    `INFO(("      JESD TEST        "+(use_dds ? "DDS" : "DMA")), ADI_VERBOSITY_LOW);
    `INFO(("======================="), ADI_VERBOSITY_LOW);

    // -----------------------
    // TX PHY INIT
    // -----------------------
    tx_xcvr.up();

    // -----------------------
    // Configure TPL
    // -----------------------
    for (int i = 0; i < `RX_JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
        // Configure tone amplitude and frequency
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));
      end else begin
        // Set DMA as source for DAC TPL
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      end
    end

    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));

    if (use_dds) begin
      // Sync DDS cores
      base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),
                         `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    end

    //
    // Configure Offload
    //
    // Transfer length
    //base_env.mng.sequencer.RegWrite32(`RX_OFFLOAD_BA+'h1C, 'h1000/64);
    // Set One shot and bypass
    base_env.mng.sequencer.RegWrite32(`RX_OFFLOAD_BA+'h88, 2 | rx_bypass);

    // Set Tx offload bypass
    // for TDD set single shot
    base_env.mng.sequencer.RegWrite32(`TX_OFFLOAD_BA+'h88, 2*tdd_enabled | tx_bypass);
    // Sync option set for hw sync
    base_env.mng.sequencer.RegWrite32(`TX_OFFLOAD_BA+'h104, tdd_enabled);
    base_env.mng.sequencer.RegWrite32(`RX_OFFLOAD_BA+'h104, tdd_enabled);

    if (tdd_enabled) begin
      base_env.mng.sequencer.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_FRAME_LENGTH),
                         `SET_TDDN_CNTRL_FRAME_LENGTH_FRAME_LENGTH(2048));

      base_env.mng.sequencer.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH0_ON),
                         `SET_TDDN_CNTRL_CH0_ON_CH0_ON(0));

      base_env.mng.sequencer.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH0_OFF),
                         `SET_TDDN_CNTRL_CH0_OFF_CH0_OFF(10));

      // Trigger RX capture later due rountrip latency ~96 cycles
      base_env.mng.sequencer.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH1_ON),
                         `SET_TDDN_CNTRL_CH1_ON_CH1_ON(96));

      base_env.mng.sequencer.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH1_OFF),
                         `SET_TDDN_CNTRL_CH1_OFF_CH1_OFF(106));

      base_env.mng.sequencer.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_ENABLE),
                         `SET_TDDN_CNTRL_CHANNEL_ENABLE_CHANNEL_ENABLE(3));

      base_env.mng.sequencer.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_SYNC_COUNTER_LOW),
                         `SET_TDDN_CNTRL_SYNC_COUNTER_LOW_SYNC_COUNTER_LOW(8192));

      base_env.mng.sequencer.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                         `SET_TDDN_CNTRL_CONTROL_SYNC_INT(1) |
                         `SET_TDDN_CNTRL_CONTROL_ENABLE(1));
    end

    if (~use_dds) begin

      // Init test data
      // .step (1),
      // .max_sample(2048)
      for (int i=0;i<2048*2 ;i=i+2) begin
        if (`TX_JESD_NP == 12) begin
          base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),(((i+1)) << 20) | (i << 4) ,15);
        end else begin
          // if (i % 8 == 0) begin
          //   base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),(((i+1)) << 16) | i , 15);
          //   // base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2), 16'h8000 , 15);
          // end else begin
          // base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),(((i+1)) << 16) | i , 15);
          // base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2), i, 15);
          if (i % 32 == 0) begin
            base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2), (16'h8000 << 16) | 16'h8000, 15);
          end else if (i % 32 == 1) begin
            base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2), (16'h8000 << 16) | 16'h8000, 15);
          end else begin
            base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2), ((i + 1) << 16) | i, 15);
          end

        end
      end
      // Configure TX DMA
      base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_CYCLIC(tx_bypass) |
                         `SET_DMAC_FLAGS_TLAST(1));
      base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h00001FFF));
      base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_SRC_ADDRESS),
                         `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BA+32'h00000000));
      base_env.mng.sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      // Configure RX DMA
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_TLAST(1));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h000007FF));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_DEST_ADDRESS),
                         `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA+32'h00002000));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      // Wait until data propagates through the dma+offload
      #5us;
    end

    tx_ll.link_up();

    // -----------------------
    // RX PHY INIT
    // -----------------------
    rx_xcvr.up();

    // -----------------------
    // Configure ADC TPL
    // -----------------------
    for (int i = 0; i < `RX_JESD_M; i++) begin
      base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + 'h40 * i + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end

    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));
    if (has_fsrc) begin
	configure_fsrc_sequencer();
	configure_tx_fsrc();
    end
    rx_ll.link_up();

    rx_ll.wait_link_up();
    tx_ll.wait_link_up();

    if (has_fsrc && use_fsrc) begin
      enable_rx_fsrc();
      enable_and_start_tx_fsrc();
      enable_and_start_seq_fsrc();
    end

    // Move data around for a while
    #5us;

    if (~use_dds) begin
      check_captured_data(
        .address (`DDR_BA+'h00002000),
        .length (1024),
        .step (1),
        .max_sample(4096)
      );
    end

    if (tdd_enabled) begin
      base_env.mng.sequencer.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                         `SET_TDDN_CNTRL_CONTROL_ENABLE(0));
    end

    rx_ll.link_down();
    tx_ll.link_down();

    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(0));

    if (has_fsrc && use_fsrc) begin
      stop_and_disable_tx_fsrc();
    end

    rx_xcvr.down();
    tx_xcvr.down();

    `INFO(("======================="), ADI_VERBOSITY_LOW);
    `INFO(("  JESD LINK TEST DONE  "), ADI_VERBOSITY_LOW);
    `INFO(("======================="), ADI_VERBOSITY_LOW);

  endtask : jesd_link_test

  // -----------------
  //
  // -----------------
  task jesd_link_test_ext_sync(input use_dds = 1);

    `INFO(("======================="), ADI_VERBOSITY_LOW);
    `INFO(("      JESD TEST  EXT SYNC      "+(use_dds ? "DDS" : "DMA")), ADI_VERBOSITY_LOW);
    `INFO(("======================="), ADI_VERBOSITY_LOW);
    // -----------------------
    // TX PHY INIT
    // -----------------------
    tx_xcvr.up();

    // -----------------------
    // Configure TPL
    // -----------------------
    for (int i = 0; i < `RX_JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
        // Configure tone amplitude and frequency
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));
      end else begin
        // Set DMA as source for DAC TPL
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      end
    end

    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));

    if (use_dds) begin
      // Sync DDS cores
      base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),
                         `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    end

    //
    // Configure Offload
    //
    // Transfer length
    base_env.mng.sequencer.RegWrite32(`RX_OFFLOAD_BA+'h1C, 'h1000/64);
    // One shot
    base_env.mng.sequencer.RegWrite32(`RX_OFFLOAD_BA+'h88, 2);

    tx_ll.link_up();

    // -----------------------
    // RX PHY INIT
    // -----------------------
    rx_xcvr.up();

    // -----------------------
    // Configure ADC TPL
    // -----------------------
    for (int i = 0; i < `RX_JESD_M; i++) begin
      base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + 'h40 * i + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end

    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    rx_ll.link_up();

    rx_ll.wait_link_up();
    tx_ll.wait_link_up();

    // Move data around for a while
    #5us;

    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),2);
    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + 'h48,2);
    #1us;
    // Check if armed
    base_env.mng.sequencer.RegReadVerify32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_SYNC_STATUS),
                            `SET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(1));
    base_env.mng.sequencer.RegReadVerify32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_SYNC_STATUS),
                            `SET_ADC_COMMON_REG_SYNC_STATUS_ADC_SYNC(1));
    #1us;

    if (~use_dds) begin

      // Init test data
      // .step (1),
      // .max_sample(2048)
      for (int i=0;i<2048*2 ;i=i+2) begin
        if (`TX_JESD_NP == 12) begin
          base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),(((i+1)) << 20) | (i << 4) ,15);
        end else begin
          if (i % 32 == 0) begin
            base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2), ((i + 1) << 16) | 16'h8000, 15);
          end else begin
            base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2), ((i + 1) << 16) | i, 15);
          end
        end
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
      // Configure RX DMA
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_TLAST(1));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003DF));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_DEST_ADDRESS),
                         `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA+32'h00002000));
      base_env.mng.sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      // Wait until data propagates through the dma+offload
      #5us;
    end

    // Trigger external sync
    @(posedge system_tb.device_clk);
    system_tb.ext_sync <= 1'b1;
    @(posedge system_tb.device_clk);
    system_tb.ext_sync <= 1'b0;

    #1us;
    // Check if trigger captured
    base_env.mng.sequencer.RegReadVerify32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_SYNC_STATUS),
                            `SET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(0));
    base_env.mng.sequencer.RegReadVerify32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_SYNC_STATUS),
                            `SET_ADC_COMMON_REG_SYNC_STATUS_ADC_SYNC(0));
    #5us;

    rx_ll.link_down();
    tx_ll.link_down();

    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(0));

    rx_xcvr.down();
    tx_xcvr.down();

    `INFO(("======================="), ADI_VERBOSITY_LOW);
    `INFO(("  JESD LINK TEST DONE  "), ADI_VERBOSITY_LOW);
    `INFO(("======================="), ADI_VERBOSITY_LOW);

  endtask : jesd_link_test_ext_sync

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
    bit [15:0] first;

    for (int i=0;i<length/2;i=i+2) begin
      current_address = address+(i*2);
      captured_word = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(current_address);
      if (i==0) begin
        first = captured_word[15:0];
      end else begin
        if ((i % 32 == 0) || (i % 32 == 1)) begin
          continue;
          // reference_word = (((first + (i+2)*step)%max_sample) << 16) | ((first + ((i + 1)*step))%max_sample);
        end else begin
          reference_word = (((first + (i+1)*step)%max_sample) << 16) | ((first + (i*step))%max_sample);
        end
        if (captured_word !== reference_word) begin
          `WARNING(("Address 0x%h Expected 0x%h found 0x%h",current_address,reference_word,captured_word));
        end
      end
    end
  endtask

endprogram
