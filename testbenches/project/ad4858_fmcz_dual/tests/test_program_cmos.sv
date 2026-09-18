// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import axi_vip_pkg::*;
import dmac_api_pkg::*;
import pwm_gen_api_pkg::*;
import clk_gen_api_pkg::*;
import common_api_pkg::*;
import adc_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program_cmos (
    // ADC 0 ports
    input  adc_0_scki_tp,
    input  adc_0_cnvs_tp,
    output adc_0_busy_tp,
    output adc_0_scko_tp,
    output adc_0_lane_0_tp,
    output adc_0_lane_1_tp,
    output adc_0_lane_2_tp,
    output adc_0_lane_3_tp,
    output adc_0_lane_4_tp,
    output adc_0_lane_5_tp,
    output adc_0_lane_6_tp,
    output adc_0_lane_7_tp,
    // ADC 1 ports
    input  adc_1_scki_tp,
    input  adc_1_cnvs_tp,
    output adc_1_busy_tp,
    output adc_1_scko_tp,
    output adc_1_lane_0_tp,
    output adc_1_lane_1_tp,
    output adc_1_lane_2_tp,
    output adc_1_lane_3_tp,
    output adc_1_lane_4_tp,
    output adc_1_lane_5_tp,
    output adc_1_lane_6_tp,
    output adc_1_lane_7_tp
);

  timeunit 1ns;
  timeprecision 1ps;

  // Declare the class instances
  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  // ADC 0 API objects
  dmac_api      dma_0_api;
  pwm_gen_api   pwm_0_api;
  common_api    common_api_ad4858_0;
  adc_api       adc_api_ad4858_0;

  // ADC 1 API objects
  dmac_api      dma_1_api;
  pwm_gen_api   pwm_1_api;
  common_api    common_api_ad4858_1;
  adc_api       adc_api_ad4858_1;

  // Shared clkgen API
  clk_gen_api   clkgen_api;

  // AD4858: 20-bit resolution, 8 channels
  localparam RESOLUTION   = 20;
  localparam NUMB_OF_CH   = 8;
  localparam PERIOD       = 200;
  localparam OCTA_CHANNEL = 1;
  localparam DW           = 32;
  localparam NO_OF_T      = 10;
  localparam NO_OF_B      = (NUMB_OF_CH * DW * NO_OF_T / 8) - 1;
  localparam MAXR_INDEX   = 8;
  localparam MAXC_INDEX   = 9;

  // Runtime parameters
  reg         [31:0]     testpattern_en = 1;

  reg         [7:0]      adc_custom_ctrl = 0;
  reg         [31:0]     packet_sz = 20;

  // ADC 0 model state
  reg         [15:0]     busy_counter_0 = 'd0;
  reg         [15:0]     oversampling_counter_0 = 'd0;
  reg         [31:0]     rx_db_i_0[0:8];
  reg         [ 5:0]     db_i_index_0 = 0;
  reg         [ 3:0]     ring_buffer_index_0 = 0;
  reg         [ 7:0]     db_i_shift_0 = 'd0;
  reg                    busy_0 = 0;
  reg                    busy_d_0 = 0;
  reg                    busy_os_0 = 0;
  reg                    cnvs_d_0 = 0;
  reg                    scki_d_0 = 'd0;
  reg                    scki_d2_0 = 'd0;
  reg         [31:0]     scki_counter_0 = 'd0;
  reg         [31:0]     scki_edges_0 = 'd0;

  // ADC 1 model state
  reg         [15:0]     busy_counter_1 = 'd0;
  reg         [15:0]     oversampling_counter_1 = 'd0;
  reg         [31:0]     rx_db_i_1[0:8];
  reg         [ 5:0]     db_i_index_1 = 0;
  reg         [ 3:0]     ring_buffer_index_1 = 0;
  reg         [ 7:0]     db_i_shift_1 = 'd0;
  reg                    busy_1 = 0;
  reg                    busy_d_1 = 0;
  reg                    busy_os_1 = 0;
  reg                    cnvs_d_1 = 0;
  reg                    scki_d_1 = 'd0;
  reg                    scki_d2_1 = 'd0;
  reg         [31:0]     scki_counter_1 = 'd0;
  reg         [31:0]     scki_edges_1 = 'd0;

  // According to the datasheet, tCONV = 665ns -> 133 clk periods at 5ns
  wire        [ 9:0]     busy_period = current_tc.os_en == 0 ? 132 : 114;
  wire        [ 3:0]     ch_index_lane_0 [7:0];
  wire        [ 3:0]     ch_index_lane_1 [7:0];

  bit         [DW-1:0]   expected_adc_data_0 [0:NO_OF_T-1][0:NUMB_OF_CH-1];
  bit         [DW-1:0]   captured_conv_data_0 [0:NO_OF_T-1][0:NUMB_OF_CH-1];
  bit         [DW-1:0]   expected_adc_data_1 [0:NO_OF_T-1][0:NUMB_OF_CH-1];
  bit         [DW-1:0]   captured_conv_data_1 [0:NO_OF_T-1][0:NUMB_OF_CH-1];
  bit                    complete_data_aq = 1;

  int                    test_idx = 0;
  int                    num_tests = 0;
  int                    dbg_cycle_cnt = 0;
  int                    rx_transfer_id_0;
  int                    rx_transfer_id_1;

  // Define test case structure
  typedef struct {
    bit [1:0] packet_format;
    bit       crc_en;
    bit       os_en;
  } test_case_t;

  test_case_t current_tc;
  test_case_t all_tests[$];

  process current_process;
  string current_process_random_state;

  initial begin

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    current_process = process::self();
    current_process_random_state = current_process.get_randstate();
    `INFO(("Randomization state: %s", current_process_random_state), ADI_VERBOSITY_NONE);

    // Create environment
    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(`IRQ_C_BA),
      .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

    mng = new(
      .name(""),
      .master_vip_if(`TH.`MNG_AXI.inst.IF));
    ddr = new(
      .name(""),
      .slave_vip_if(`TH.`DDR_AXI.inst.IF));

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    // ADC 0 API
    dma_0_api = new(
      .name("RX DMA 0 API"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`AD4858_DMA_0_BA));

    pwm_0_api = new(
      .name("PWM 0 API"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`AD4858_AXI_PWM_GEN_0_BA));

    common_api_ad4858_0 = new(
      .name("AD4858_0 Common API"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`AXI_AD4858_0_BA));

    adc_api_ad4858_0 = new(
      .name("AD4858_0 ADC API"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`AXI_AD4858_0_BA));

    // ADC 1 API
    dma_1_api = new(
      .name("RX DMA 1 API"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`AD4858_DMA_1_BA));

    pwm_1_api = new(
      .name("PWM 1 API"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`AD4858_AXI_PWM_GEN_1_BA));

    common_api_ad4858_1 = new(
      .name("AD4858_1 Common API"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`AXI_AD4858_1_BA));

    adc_api_ad4858_1 = new(
      .name("AD4858_1 ADC API"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`AXI_AD4858_1_BA));

    // Shared clkgen
    clkgen_api = new(
      .name("CLKGEN API"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`AD4858_ADC_CLKGEN_BA));

    `TH.sys_200m_clk_vip.inst.IF.start_clock();
    `TH.adc_clk_vip.inst.IF.start_clock();

    base_env.start();
    base_env.sys_reset();

    base_env.simulation_watchdog.stop();
    base_env.simulation_watchdog.update_timer(300000);

    sanity_test();

    `ifdef PACKET_FORMAT
      `define HAS_TEST_PARAMS
    `endif
    `ifdef CRC_EN
      `define HAS_TEST_PARAMS
    `endif
    `ifdef OS_EN
      `define HAS_TEST_PARAMS
    `endif

    base_env.simulation_watchdog.start();
    `ifdef HAS_TEST_PARAMS
      current_tc.packet_format = `PACKET_FORMAT;
      current_tc.crc_en = `CRC_EN;
      current_tc.os_en = `OS_EN;
      `INFO(("Using cfg PACKET_FORMAT=%0d, CRC_EN=%0d, OS_EN=%0d",
               `PACKET_FORMAT, `CRC_EN, `OS_EN), ADI_VERBOSITY_LOW);
      run_test_case(current_tc);
    `else
      for (int pf = 0; pf <= 3; pf++) begin
        for (int crc = 0; crc <= 1; crc++) begin
          for (int os = 0; os <= 1; os++) begin
            // CRC + oversampling together are not supported: start_transfer
            // fires on every OS sub-conversion, resetting the channel index
            // tracking before the CRC packet can be captured.
            if (crc == 1 && os == 1) continue;
            all_tests.push_back('{packet_format: pf[1:0], crc_en: crc[0], os_en: os[0]});
          end
        end
      end

      num_tests = 2;
      repeat(num_tests) begin
        test_idx = $urandom_range(0, all_tests.size() - 1);

        current_tc = all_tests[test_idx];

        `INFO(("=== AD4858 Dual Test: case %0d (pf=%0d, crc=%0d, os=%0d) ===", test_idx,
              current_tc.packet_format, current_tc.crc_en, current_tc.os_en), ADI_VERBOSITY_LOW);

        base_env.simulation_watchdog.reset();
        run_test_case(current_tc);

        reset_all();
      end
    `endif

    `undef HAS_TEST_PARAMS

    base_env.stop();

    `TH.sys_200m_clk_vip.inst.IF.stop_clock();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task sanity_test();
    `INFO(("Running sanity tests"), ADI_VERBOSITY_LOW);
    dma_0_api.sanity_test();
    dma_1_api.sanity_test();
    pwm_0_api.sanity_test();
    pwm_1_api.sanity_test();
  endtask: sanity_test

  task run_test_case(input test_case_t tc);
    configure_adc(tc);
    enable_adc_ch();
    prepare_data(tc);
    transmission_config();
    capture_data(tc);
  endtask: run_test_case

  task configure_adc(input test_case_t tc);
    `INFO(("configure_adc: start"), ADI_VERBOSITY_NONE);
    // Configure ADC 0
    adc_api_ad4858_0.reset(
      .ce_n(1'b0),
      .mmcm_rstn(1'b1),
      .rstn(1'b1));

    adc_custom_ctrl[2] = tc.os_en;
    adc_custom_ctrl[1:0] = tc.packet_format;

    adc_api_ad4858_0.set_common_control(
      .pin_mode(1'b0),
      .ddr_edgesel(1'b0),
      .r1_mode(1'b0),
      .sync(1'b0),
      .num_lanes(NUMB_OF_CH),
      .symb_8_16b(1'b0),
      .symb_op(1'b0),
      .sdr_ddr_n(1'b0));

    adc_api_ad4858_0.set_common_control_3(
      .crc_en(tc.crc_en),
      .custom_control(adc_custom_ctrl));

    // Configure ADC 1
    adc_api_ad4858_1.reset(
      .ce_n(1'b0),
      .mmcm_rstn(1'b1),
      .rstn(1'b1));

    adc_api_ad4858_1.set_common_control(
      .pin_mode(1'b0),
      .ddr_edgesel(1'b0),
      .r1_mode(1'b0),
      .sync(1'b0),
      .num_lanes(NUMB_OF_CH),
      .symb_8_16b(1'b0),
      .symb_op(1'b0),
      .sdr_ddr_n(1'b0));

    adc_api_ad4858_1.set_common_control_3(
      .crc_en(tc.crc_en),
      .custom_control(adc_custom_ctrl));
    `INFO(("configure_adc: done"), ADI_VERBOSITY_NONE);
  endtask: configure_adc

  task reset_all();
    `INFO(("Resetting for next test case"), ADI_VERBOSITY_LOW);

    pwm_0_api.reset();
    pwm_1_api.reset();
    dma_0_api.disable_dma();
    dma_1_api.disable_dma();

    adc_api_ad4858_0.reset(
      .ce_n(1'b0),
      .mmcm_rstn(1'b0),
      .rstn(1'b0));

    adc_api_ad4858_1.reset(
      .ce_n(1'b0),
      .mmcm_rstn(1'b0),
      .rstn(1'b0));

    for (int i = 0; i < NUMB_OF_CH; i=i+1) begin
      adc_api_ad4858_0.clear_channel_status(i);
      adc_api_ad4858_1.clear_channel_status(i);
    end

    for (int i = 0; i <= NO_OF_B; i += 4) begin
      base_env.ddr.slave_sequencer.BackdoorWrite32(xil_axi_uint'(`DDR_BA + i), 32'h0, 32'hF);
    end

    adc_custom_ctrl = 0;
    packet_sz = 20;

    oversampling_counter_0 = 'd0;
    busy_counter_0 = 'd0;
    db_i_index_0 = 0;
    ring_buffer_index_0 = 0;
    db_i_shift_0 = 'd0;
    busy_0 = 0;
    busy_d_0 = 0;
    busy_os_0 = 0;
    cnvs_d_0 = 0;
    scki_d_0 = 'd0;
    scki_d2_0 = 'd0;
    scki_counter_0 = 'd0;
    scki_edges_0 = 'd0;

    oversampling_counter_1 = 'd0;
    busy_counter_1 = 'd0;
    db_i_index_1 = 0;
    ring_buffer_index_1 = 0;
    db_i_shift_1 = 'd0;
    busy_1 = 0;
    busy_d_1 = 0;
    busy_os_1 = 0;
    cnvs_d_1 = 0;
    scki_d_1 = 'd0;
    scki_d2_1 = 'd0;
    scki_counter_1 = 'd0;
    scki_edges_1 = 'd0;

    complete_data_aq = 1;

    for (int i = 0; i <= 8; i = i + 1) begin
      rx_db_i_0[i] = 32'h0;
      rx_db_i_1[i] = 32'h0;
    end

    for (int i=0; i<NO_OF_T; i=i+1) begin
      for (int j=0;j<NUMB_OF_CH; j=j+1) begin
        expected_adc_data_0[i][j] = 0;
        captured_conv_data_0[i][j] = 0;
        expected_adc_data_1[i][j] = 0;
        captured_conv_data_1[i][j] = 0;
      end
    end
  endtask: reset_all

  task enable_adc_ch();
    `INFO(("enable_adc_ch: start"), ADI_VERBOSITY_NONE);
    for (int i = 0; i < NUMB_OF_CH; i=i+1) begin
      adc_api_ad4858_0.enable_channel(i);
      adc_api_ad4858_1.enable_channel(i);
    end
    `INFO(("enable_adc_ch: done"), ADI_VERBOSITY_NONE);
  endtask: enable_adc_ch

  task transmission_config();
    `INFO(("transmission_config: enabling clkgen"), ADI_VERBOSITY_NONE);
    clkgen_api.enable_clkgen();
    `INFO(("transmission_config: clkgen enabled"), ADI_VERBOSITY_NONE);

    // DMA 0
    dma_0_api.enable_dma();
    dma_0_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b0));
    dma_0_api.set_lengths(
      .xfer_length_x(NO_OF_B),
      .xfer_length_y(32'h0));
    dma_0_api.set_dest_addr(`DDR_BA);
    dma_0_api.transfer_id_get(rx_transfer_id_0);
    dma_0_api.transfer_start();

    // DMA 1
    dma_1_api.enable_dma();
    dma_1_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b0));
    dma_1_api.set_lengths(
      .xfer_length_x(NO_OF_B),
      .xfer_length_y(32'h0));
    dma_1_api.set_dest_addr(`DDR_BA + NO_OF_B + 1);
    dma_1_api.transfer_id_get(rx_transfer_id_1);
    dma_1_api.transfer_start();

    // PWM 0
    pwm_0_api.reset();
    pwm_0_api.pulse_period_config(0, PERIOD);
    pwm_0_api.pulse_width_config(0, 'd8);
    pwm_0_api.load_config();
    pwm_0_api.start();

    // PWM 1
    pwm_1_api.reset();
    pwm_1_api.pulse_period_config(0, PERIOD);
    pwm_1_api.pulse_width_config(0, 'd8);
    pwm_1_api.load_config();
    pwm_1_api.start();
    `INFO(("transmission_config: done, waiting for DMA 0"), ADI_VERBOSITY_NONE);
  endtask: transmission_config

  task prepare_data(input test_case_t tc);
    reg [31:0] expected_rx_0;
    reg [31:0] expected_rx_1;
    automatic bit packet_formats = 0; // AD4858 is always 20-bit

    case ({tc.packet_format, packet_formats})
      3'h0 : packet_sz = 20;  // 00 - 20b, 0 - 20b resolution
      3'h2 : packet_sz = 24;  // 01 - 24b
      3'h4 : packet_sz = 32;  // 10 - 32b
      3'h6 : packet_sz = 32;  // 11 - 32b
      default: packet_sz = 20;
    endcase

    db_i_index_0 = packet_sz;
    db_i_index_1 = packet_sz;
    scki_edges_0 = packet_sz * (1 + tc.crc_en);
    scki_edges_1 = packet_sz * (1 + tc.crc_en);

    if (testpattern_en == 1) begin
      case (packet_sz)
        20: begin
          rx_db_i_0[0] = 32'h0ACE3;  rx_db_i_1[0] = 32'h0ACE3;
          rx_db_i_0[1] = 32'h1ACE3;  rx_db_i_1[1] = 32'h1ACE3;
          rx_db_i_0[2] = 32'h2ACE3;  rx_db_i_1[2] = 32'h2ACE3;
          rx_db_i_0[3] = 32'h3ACE3;  rx_db_i_1[3] = 32'h3ACE3;
          rx_db_i_0[4] = 32'h4ACE3;  rx_db_i_1[4] = 32'h4ACE3;
          rx_db_i_0[5] = 32'h5ACE3;  rx_db_i_1[5] = 32'h5ACE3;
          rx_db_i_0[6] = 32'h6ACE3;  rx_db_i_1[6] = 32'h6ACE3;
          rx_db_i_0[7] = 32'h7ACE3;  rx_db_i_1[7] = 32'h7ACE3;
          rx_db_i_0[8] = 32'h4c3b;   rx_db_i_1[8] = 32'h4c3b;
        end
        24: begin
          rx_db_i_0[0] = 32'h0ACE3C; rx_db_i_1[0] = 32'h0ACE3C;
          rx_db_i_0[1] = 32'h1ACE3C; rx_db_i_1[1] = 32'h1ACE3C;
          rx_db_i_0[2] = 32'h2ACE3C; rx_db_i_1[2] = 32'h2ACE3C;
          rx_db_i_0[3] = 32'h3ACE3C; rx_db_i_1[3] = 32'h3ACE3C;
          rx_db_i_0[4] = 32'h4ACE3C; rx_db_i_1[4] = 32'h4ACE3C;
          rx_db_i_0[5] = 32'h5ACE3C; rx_db_i_1[5] = 32'h5ACE3C;
          rx_db_i_0[6] = 32'h6ACE3C; rx_db_i_1[6] = 32'h6ACE3C;
          rx_db_i_0[7] = 32'h7ACE3C; rx_db_i_1[7] = 32'h7ACE3C;
          rx_db_i_0[8] = 32'h5435;   rx_db_i_1[8] = 32'h5435;
        end
        32: begin
          rx_db_i_0[0] = 32'h0ACE3C2A; rx_db_i_1[0] = 32'h0ACE3C2A;
          rx_db_i_0[1] = 32'h1ACE3C2A; rx_db_i_1[1] = 32'h1ACE3C2A;
          rx_db_i_0[2] = 32'h2ACE3C2A; rx_db_i_1[2] = 32'h2ACE3C2A;
          rx_db_i_0[3] = 32'h3ACE3C2A; rx_db_i_1[3] = 32'h3ACE3C2A;
          rx_db_i_0[4] = 32'h4ACE3C2A; rx_db_i_1[4] = 32'h4ACE3C2A;
          rx_db_i_0[5] = 32'h5ACE3C2A; rx_db_i_1[5] = 32'h5ACE3C2A;
          rx_db_i_0[6] = 32'h6ACE3C2A; rx_db_i_1[6] = 32'h6ACE3C2A;
          rx_db_i_0[7] = 32'h7ACE3C2A; rx_db_i_1[7] = 32'h7ACE3C2A;
          rx_db_i_0[8] = 32'h2118;     rx_db_i_1[8] = 32'h2118;
        end
        default: begin
          `FATAL(("Unsupported packet size %0d", packet_sz));
        end
      endcase
    end
    else begin
      rx_db_i_0[0] = 32'h80000; rx_db_i_1[0] = 32'h80000;
      rx_db_i_0[1] = 32'h80001; rx_db_i_1[1] = 32'h80001;
      rx_db_i_0[2] = 32'h80002; rx_db_i_1[2] = 32'h80002;
      rx_db_i_0[3] = 32'h80003; rx_db_i_1[3] = 32'h80003;
      rx_db_i_0[4] = 32'h80004; rx_db_i_1[4] = 32'h80004;
      rx_db_i_0[5] = 32'h80005; rx_db_i_1[5] = 32'h80005;
      rx_db_i_0[6] = 32'h80006; rx_db_i_1[6] = 32'h80006;
      rx_db_i_0[7] = 32'h80007; rx_db_i_1[7] = 32'h80007;
      rx_db_i_0[8] = 32'h0;     rx_db_i_1[8] = 32'h0;
    end

    for (int conv = 0; conv < NO_OF_T; conv = conv + 1) begin
      for (int i = 0; i < NUMB_OF_CH; i = i + 1) begin
        if (testpattern_en == 1) begin
          expected_rx_0 = rx_db_i_0[i];
          expected_rx_1 = rx_db_i_1[i];
        end else begin
          expected_rx_0 = rx_db_i_0[i] + conv + 1;
          expected_rx_1 = rx_db_i_1[i] + conv + 1;
        end
        case ({tc.packet_format, 1'b0, tc.os_en})  // packet_formats=0 (20b), OS En
          4'h0, 4'h1 : begin
            expected_adc_data_0[conv][i] = {12'd0, expected_rx_0[19:0]};
            expected_adc_data_1[conv][i] = {12'd0, expected_rx_1[19:0]};
          end
          4'h4 : begin
            expected_adc_data_0[conv][i] = {12'd0, expected_rx_0[23:4]};
            expected_adc_data_1[conv][i] = {12'd0, expected_rx_1[23:4]};
          end
          4'h5 : begin
            expected_adc_data_0[conv][i] = {8'd0, expected_rx_0[23:0]};
            expected_adc_data_1[conv][i] = {8'd0, expected_rx_1[23:0]};
          end
          4'h8, 4'hC : begin
            expected_adc_data_0[conv][i] = {12'd0, expected_rx_0[31:12]};
            expected_adc_data_1[conv][i] = {12'd0, expected_rx_1[31:12]};
          end
          4'h9, 4'hD : begin
            expected_adc_data_0[conv][i] = {8'd0, expected_rx_0[31:8]};
            expected_adc_data_1[conv][i] = {8'd0, expected_rx_1[31:8]};
          end
          default: begin
            expected_adc_data_0[conv][i] = {12'd0, expected_rx_0[19:0]};
            expected_adc_data_1[conv][i] = {12'd0, expected_rx_1[19:0]};
          end
        endcase
      end
    end
  endtask: prepare_data

  task capture_data(input test_case_t tc);
    int          word_addr;
    logic crc_err_status;

    `INFO(("capture_data: waiting for DMA 0 transfer %0d", rx_transfer_id_0), ADI_VERBOSITY_NONE);
    dma_0_api.wait_transfer_done(rx_transfer_id_0, , 100);
    `INFO(("capture_data: DMA 0 done, waiting for DMA 1 transfer %0d", rx_transfer_id_1), ADI_VERBOSITY_NONE);
    dma_1_api.wait_transfer_done(rx_transfer_id_1, , 100);
    `INFO(("capture_data: DMA 1 done"), ADI_VERBOSITY_NONE);
    pwm_0_api.reset();
    pwm_1_api.reset();

    // Read ADC 0 data
    for (int conv=0; conv<NO_OF_T; conv=conv+1) begin
      for (int i=0; i<NUMB_OF_CH; i=i+1) begin
        word_addr = conv * NUMB_OF_CH + i;
        captured_conv_data_0[conv][i] = base_env.ddr.slave_sequencer.BackdoorRead32(
          xil_axi_uint'(`DDR_BA + 4 * word_addr));
      end
    end

    // Read ADC 1 data (placed after ADC 0 in DDR)
    for (int conv=0; conv<NO_OF_T; conv=conv+1) begin
      for (int i=0; i<NUMB_OF_CH; i=i+1) begin
        word_addr = conv * NUMB_OF_CH + i;
        captured_conv_data_1[conv][i] = base_env.ddr.slave_sequencer.BackdoorRead32(
          xil_axi_uint'(`DDR_BA + NO_OF_B + 1 + 4 * word_addr));
      end
    end

    `INFO(("Verifying ADC 0 data (%d conversions)", NO_OF_T), ADI_VERBOSITY_LOW);
    for (int conv=0; conv<NO_OF_T; conv=conv+1) begin
      for (int i=0; i<NUMB_OF_CH; i=i+1) begin
        if (captured_conv_data_0[conv][i] != expected_adc_data_0[conv][i]) begin
          `ERROR(("ADC0 Ch%d conv%d mismatch: expected %x, got %x",
                  i, conv, expected_adc_data_0[conv][i], captured_conv_data_0[conv][i]));
        end else begin
          `INFO(("ADC0 Ch%d OK: %x", i, captured_conv_data_0[conv][i]), ADI_VERBOSITY_LOW);
        end
      end
    end

    `INFO(("Verifying ADC 1 data (%d conversions)", NO_OF_T), ADI_VERBOSITY_LOW);
    for (int conv=0; conv<NO_OF_T; conv=conv+1) begin
      for (int i=0; i<NUMB_OF_CH; i=i+1) begin
        if (captured_conv_data_1[conv][i] != expected_adc_data_1[conv][i]) begin
          `ERROR(("ADC1 Ch%d conv%d mismatch: expected %x, got %x",
                  i, conv, expected_adc_data_1[conv][i], captured_conv_data_1[conv][i]));
        end else begin
          `INFO(("ADC1 Ch%d OK: %x", i, captured_conv_data_1[conv][i]), ADI_VERBOSITY_LOW);
        end
      end
    end

    `INFO(("DMA Test done!"), ADI_VERBOSITY_LOW);

    // CRC check
    if (tc.crc_en == 1) begin
      for (int i = 0; i < NUMB_OF_CH; i=i+1) begin
        adc_api_ad4858_0.get_crc_err_channel_status(.channel(i), .crc_err(crc_err_status));
        if (crc_err_status == 1'b1)
          `ERROR(("ADC0 CRC error on channel %d", i));

        adc_api_ad4858_1.get_crc_err_channel_status(.channel(i), .crc_err(crc_err_status));
        if (crc_err_status == 1'b1)
          `ERROR(("ADC1 CRC error on channel %d", i));
      end
      `INFO(("CRC check done!"), ADI_VERBOSITY_LOW);
    end

    if (complete_data_aq == 0) begin
      `WARNING(("Data transaction doesn't meet minimum timing requirement!"));
    end
  endtask: capture_data

  initial begin
    for (int i=0; i<=8; i=i+1) begin
      rx_db_i_0[i] = 0;
      rx_db_i_1[i] = 0;
    end
  end

  // ADC 0 behavioral model
  initial begin
    forever begin
      @(posedge `TH.adc_clk);

      if ((~cnvs_d_0 & adc_0_cnvs_tp && busy_0 == 0) && current_tc.os_en == 0) begin
        if (scki_counter_0 > 0 && scki_counter_0 < scki_edges_0)
          complete_data_aq = 0;
        else if (scki_counter_0 == 0)
          complete_data_aq = 1;
      end

      if (~cnvs_d_0 & adc_0_cnvs_tp && busy_0 == 0) begin
        `INFO(("ADC0 model: CNV rising edge detected"), ADI_VERBOSITY_NONE);
      end

      if ((~cnvs_d_0 & adc_0_cnvs_tp && busy_0 == 0) || busy_os_0 == 1) begin
        busy_counter_0 = 'd0;
        busy_0 = 1'b1;
      end else if (busy_counter_0 == busy_period) begin
        busy_counter_0 = 'd0;
        busy_0 = busy_os_0;
      end else if (busy_0 == 1'b1) begin
        busy_counter_0 = 1 + busy_counter_0;
        busy_0 = 1'b1;
      end

      if (current_tc.os_en == 1) begin
        if (oversampling_counter_0 == 'd4) begin
          oversampling_counter_0 = 'd0;
          busy_os_0 = 1'b0;
        end else if (~adc_0_cnvs_tp & cnvs_d_0 && oversampling_counter_0 < 'd4 && busy_0 == 1'b1) begin
          oversampling_counter_0 = oversampling_counter_0 + 1;
          busy_os_0 = 1'b1;
        end
      end
      cnvs_d_0 = adc_0_cnvs_tp;

      if (busy_d_0 & !busy_0) begin
        `INFO(("ADC0 model: conversion done, scki=%b", adc_0_scki_tp), ADI_VERBOSITY_NONE);
        db_i_index_0 = packet_sz - 1;
        ring_buffer_index_0 = 0;
        scki_counter_0 = scki_edges_0;

        if (testpattern_en == 0) begin
          for (int i = 0; i <= 7; i++) rx_db_i_0[i] = rx_db_i_0[i] + 1;
        end
      end else if (~adc_0_scki_tp & scki_d_0) begin
        for (int i=0; i<8; i=i+1) begin
          db_i_shift_0[i] = rx_db_i_0[ch_index_lane_0[i]][db_i_index_0];
        end
        ring_buffer_index_0 = (db_i_index_0 == 'd0) ? ring_buffer_index_0 + 1 :
                              (ring_buffer_index_0 == MAXR_INDEX) ? 0 : ring_buffer_index_0;
        db_i_index_0 = (db_i_index_0 != 'd0) ? db_i_index_0 - 1 : packet_sz - 1;

        if (scki_counter_0 > 0)
          scki_counter_0 = scki_counter_0 - 1;
      end

      scki_d2_0 = scki_d_0;
      scki_d_0 = adc_0_scki_tp;
      busy_d_0 = busy_0;

      // Debug: on first 3 busy-fall events, print scki/scko from program ports
      if (busy_d_0 & !busy_0) begin
        dbg_cycle_cnt = dbg_cycle_cnt + 1;
        if (dbg_cycle_cnt <= 3) begin
          `INFO(("DBG conv#%0d: port scki=%b scko=%b scki_d=%b scki_d2=%b",
                 dbg_cycle_cnt,
                 adc_0_scki_tp, adc_0_scko_tp, scki_d_0, scki_d2_0), ADI_VERBOSITY_NONE);
        end
      end
    end
  end

  // ADC 1 behavioral model
  initial begin
    forever begin
      @(posedge `TH.adc_clk);

      if ((~cnvs_d_1 & adc_1_cnvs_tp && busy_1 == 0) && current_tc.os_en == 0) begin
        if (scki_counter_1 > 0 && scki_counter_1 < scki_edges_1)
          complete_data_aq = 0;
        else if (scki_counter_1 == 0)
          complete_data_aq = 1;
      end

      if (~cnvs_d_1 & adc_1_cnvs_tp && busy_1 == 0) begin
        `INFO(("ADC1 model: CNV rising edge detected"), ADI_VERBOSITY_LOW);
      end

      if ((~cnvs_d_1 & adc_1_cnvs_tp && busy_1 == 0) || busy_os_1 == 1) begin
        busy_counter_1 = 'd0;
        busy_1 = 1'b1;
      end else if (busy_counter_1 == busy_period) begin
        busy_counter_1 = 'd0;
        busy_1 = busy_os_1;
      end else if (busy_1 == 1'b1) begin
        busy_counter_1 = 1 + busy_counter_1;
        busy_1 = 1'b1;
      end

      if (current_tc.os_en == 1) begin
        if (oversampling_counter_1 == 'd4) begin
          oversampling_counter_1 = 'd0;
          busy_os_1 = 1'b0;
        end else if (~adc_1_cnvs_tp & cnvs_d_1 && oversampling_counter_1 < 'd4 && busy_1 == 1'b1) begin
          oversampling_counter_1 = oversampling_counter_1 + 1;
          busy_os_1 = 1'b1;
        end
      end
      cnvs_d_1 = adc_1_cnvs_tp;

      if (busy_d_1 & !busy_1) begin
        `INFO(("ADC1 model: conversion done, scki=%b", adc_1_scki_tp), ADI_VERBOSITY_LOW);
        db_i_index_1 = packet_sz - 1;
        ring_buffer_index_1 = 0;
        scki_counter_1 = scki_edges_1;

        if (testpattern_en == 0) begin
          for (int i = 0; i <= 7; i++) rx_db_i_1[i] = rx_db_i_1[i] + 1;
        end
      end else if (~adc_1_scki_tp & scki_d_1) begin
        for (int i=0; i<8; i=i+1) begin
          db_i_shift_1[i] = rx_db_i_1[ch_index_lane_1[i]][db_i_index_1];
        end
        ring_buffer_index_1 = (db_i_index_1 == 'd0) ? ring_buffer_index_1 + 1 :
                              (ring_buffer_index_1 == MAXR_INDEX) ? 0 : ring_buffer_index_1;
        db_i_index_1 = (db_i_index_1 != 'd0) ? db_i_index_1 - 1 : packet_sz - 1;

        if (scki_counter_1 > 0)
          scki_counter_1 = scki_counter_1 - 1;
      end

      scki_d2_1 = scki_d_1;
      scki_d_1 = adc_1_scki_tp;
      busy_d_1 = busy_1;
    end
  end


  // Channel index routing for ADC 0
  generate
    for (genvar i=0; i<8; i=i+1) begin
      assign ch_index_lane_0[i] = (i + ring_buffer_index_0) == MAXC_INDEX ? 0 :
                                  (i + ring_buffer_index_0) > MAXC_INDEX  ? (i + ring_buffer_index_0) - 8 :
                                   i + ring_buffer_index_0;
    end
  endgenerate

  // Channel index routing for ADC 1
  generate
    for (genvar i=0; i<8; i=i+1) begin
      assign ch_index_lane_1[i] = (i + ring_buffer_index_1) == MAXC_INDEX ? 0 :
                                  (i + ring_buffer_index_1) > MAXC_INDEX  ? (i + ring_buffer_index_1) - 8 :
                                   i + ring_buffer_index_1;
    end
  endgenerate

  // ADC 0 output assignments
  assign adc_0_lane_0_tp = db_i_shift_0[0];
  assign adc_0_lane_1_tp = db_i_shift_0[1];
  assign adc_0_lane_2_tp = db_i_shift_0[2];
  assign adc_0_lane_3_tp = db_i_shift_0[3];
  assign adc_0_lane_4_tp = db_i_shift_0[4];
  assign adc_0_lane_5_tp = db_i_shift_0[5];
  assign adc_0_lane_6_tp = db_i_shift_0[6];
  assign adc_0_lane_7_tp = db_i_shift_0[7];
  assign adc_0_busy_tp   = busy_0;
  assign adc_0_scko_tp   = scki_d2_0;

  // ADC 1 output assignments
  assign adc_1_lane_0_tp = db_i_shift_1[0];
  assign adc_1_lane_1_tp = db_i_shift_1[1];
  assign adc_1_lane_2_tp = db_i_shift_1[2];
  assign adc_1_lane_3_tp = db_i_shift_1[3];
  assign adc_1_lane_4_tp = db_i_shift_1[4];
  assign adc_1_lane_5_tp = db_i_shift_1[5];
  assign adc_1_lane_6_tp = db_i_shift_1[6];
  assign adc_1_lane_7_tp = db_i_shift_1[7];
  assign adc_1_busy_tp   = busy_1;
  assign adc_1_scko_tp   = scki_d2_1;

endprogram
