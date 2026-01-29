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
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import dmac_api_pkg::*;
import pwm_gen_api_pkg::*;
import clk_gen_api_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_common_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program_cmos (
    input scki_tp,
    input cnvs_tp,
    output busy_tp,
    output scko_tp,
    output adc_lane_0_tp,
    output adc_lane_1_tp,
    output adc_lane_2_tp,
    output adc_lane_3_tp,
    output adc_lane_4_tp,
    output adc_lane_5_tp,
    output adc_lane_6_tp,
    output adc_lane_7_tp
);

  timeunit 1ns;
  timeprecision 1ps;

  // Declare the class instances
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  dmac_api dma_api;
  pwm_gen_api pwm_api;
  clk_gen_api clkgen_api;

  localparam             NUMB_OF_CH = `NUMB_OF_CH;
  localparam             OCTA_CHANNEL = `OCTA_CHANNEL; // 1 - 8ch+meta; 0 - 4ch+meta
  localparam             RESOLUTION = `RESOLUTION;
  localparam             DW = RESOLUTION == 16 ? 16 : 32;
  localparam             PERIOD = `PERIOD_T;
  localparam             NO_OF_T = 32;
  localparam             NO_OF_B = (NUMB_OF_CH * DW * NO_OF_T / 8) - 1;
  localparam             MAXR_INDEX = OCTA_CHANNEL ? 8 : 4;
  localparam             MAXC_INDEX = OCTA_CHANNEL ? 9 : 5;

  // Runtime parameters

  //Packet format  AD4851/3/5/7  AD4852/4/6/8
  //      0          16 bits        20 bits
  //      1          24 bits        24 bits
  //     2/3           ---          32 bits
  reg         [ 1:0]     packet_format = 0;
  reg                    crc_en = 0;
  reg                    oversampling_en = 0;
  reg         [31:0]     testpattern_en = 1;

  reg         [7:0]      adc_custom_ctrl = 0;
  reg         [31:0]     packet_sz = 20;

  reg         [15:0]     oversampling_counter = 'd0;
  reg         [15:0]     busy_counter = 'd0;

  reg         [31:0]     rx_db_i[0:8];
  reg         [ 5:0]     db_i_index = 0;
  reg         [ 3:0]     ring_buffer_index = 0;
  reg         [ 7:0]     db_i_shift = 0;

  reg                    busy = 0;
  reg                    busy_d = 0;
  reg                    busy_os = 0;
  reg                    cnvs_d = 0;
  reg                    scki_d = 'd0;
  reg                    scki_d2 = 'd0;
  reg         [31:0]     scki_counter = 'd0;
  reg         [31:0]     scki_edges = 'd0;

  // According to the datasheet, the typical tCONV = 665ns, which corresponds to 133 clock periods (665ns / 5ns)
  wire        [ 9:0]     busy_period = oversampling_en == 0 ? 132 : 114;
  wire        [ 3:0]     ch_index_lane [7:0];

  bit         [12:0]     crc_err = 0;
  bit                    crc_err_found = 0;
  bit         [3:0]      transfer_id;
  bit                    packet_formats = RESOLUTION == 16 ? 1: 0;
  bit         [DW-1:0]   expected_adc_data [0:NO_OF_T-1][0:NUMB_OF_CH-1];
  bit         [DW-1:0]   captured_conv_data [0:NO_OF_T-1][0:NUMB_OF_CH-1];
  bit         [31:0]     word;
  bit                    expected_conv = 1;
  bit                    complete_data_aq = 1; // 1-yes; 0-no

  // --------------------------
  // Wrapper function for AXI read verif
  // --------------------------
  task axi_read_v(
      input   [31:0]  raddr,
      input   [31:0]  vdata);

    base_env.mng.sequencer.RegReadVerify32(raddr,vdata);
  endtask: axi_read_v

  task axi_read(
      input   [31:0]  raddr,
      output  [31:0]  data);

    base_env.mng.sequencer.RegRead32(raddr,data);
  endtask: axi_read

  // --------------------------
  // Wrapper function for AXI write
  // --------------------------
  task axi_write(
    input [31:0]  waddr,
    input [31:0]  wdata);

    base_env.mng.sequencer.RegWrite32(waddr,wdata);
  endtask: axi_write

  // Process variables
  process current_process;
  string current_process_random_state;

  initial begin

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    current_process = process::self();
    current_process_random_state = current_process.get_randstate();
    `INFO(("Randomization state: %s", current_process_random_state), ADI_VERBOSITY_NONE);

    // Create environment
    base_env = new("Base Environment",
              `TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    dma_api = new("RX DMA API",
                  base_env.mng.sequencer,
                  `AD485X_DMA_BA);

    clkgen_api = new("CLKGEN API",
                    base_env.mng.sequencer,
                    `AD485X_ADC_CLKGEN_BA);

    pwm_api = new("PWM API",
                  base_env.mng.sequencer,
                  `AD485X_AXI_PWM_GEN_BA);

    base_env.start();
    base_env.sys_reset();

    sanity_test();

    configure_axi();
    #500ns;

    enable_adc_ch();
    #500ns;

    prepare_data();

    transmission_config();

    capture_data();
    #100ns;

    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task sanity_test_axi();
    axi_write(`AXI_AD485X_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
    axi_read_v(`AXI_AD485X_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
  endtask: sanity_test_axi

  task sanity_test();
    `INFO(("Running sanity tests"), ADI_VERBOSITY_LOW);
    dma_api.sanity_test();
    pwm_api.sanity_test();
    sanity_test_axi();
  endtask: sanity_test

  task configure_axi();
    // Reset ADC core first
    axi_write (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    #100ns;
    axi_write (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(1));
    #100ns;

    // Configure ADC parameters
    adc_custom_ctrl[2] = oversampling_en;
    adc_custom_ctrl[1:0] = packet_format;

    axi_write (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_CNTRL_3),`SET_ADC_COMMON_REG_CNTRL_3_CRC_EN(crc_en) | `SET_ADC_COMMON_REG_CNTRL_3_CUSTOM_CONTROL(adc_custom_ctrl));
    axi_write (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_CNTRL), `SET_ADC_COMMON_REG_CNTRL_NUM_LANES(NUMB_OF_CH));

    axi_read_v (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_CNTRL_3),`SET_ADC_COMMON_REG_CNTRL_3_CRC_EN(crc_en) | `SET_ADC_COMMON_REG_CNTRL_3_CUSTOM_CONTROL(adc_custom_ctrl));
    axi_read_v (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_CNTRL), `SET_ADC_COMMON_REG_CNTRL_NUM_LANES(NUMB_OF_CH));
  endtask: configure_axi


  task enable_adc_ch();
    // Enable ADC channels
    for (int i = 0; i < NUMB_OF_CH; i=i+1) begin
        axi_write (`AXI_AD485X_BA + i*'h40 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL), `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end

    // Verify channel enables
    for (int i = 0; i < NUMB_OF_CH; i=i+1) begin
        axi_read_v(`AXI_AD485X_BA + i*'h40 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL), `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end
  endtask: enable_adc_ch

  task transmission_config();
    // Start ADC clk generator
    clkgen_api.enable_clkgen();

    // DMA
    dma_api.enable_dma();
    dma_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b0));
    dma_api.set_lengths(
      .xfer_length_x(NO_OF_B),
      .xfer_length_y(32'h0));
      dma_api.set_dest_addr(xil_axi_uint'(`DDR_BA));
    dma_api.transfer_start();
    dma_api.transfer_id_get(transfer_id);

    // PWM
    pwm_api.reset();
    #100ns;
    pwm_api.pulse_period_config(0,PERIOD);
    pwm_api.pulse_width_config(0,'d8);
    pwm_api.load_config();
    pwm_api.start();
  endtask: transmission_config

  task prepare_data();
    reg [31:0] expected_rx ;

    case ({packet_format,packet_formats})
      3'h0 : packet_sz = 20;  // 00 - 20b, 0 - 20b resolution
      3'h1 : packet_sz = 16;  // 00 - 16b, 1 - 16b
      3'h2 : packet_sz = 24;  // 01 - 24b, 0 - 20b
      3'h3 : packet_sz = 24;  // 01 - 24b, 1 - 16b
      3'h4 : packet_sz = 32;  // 10 - 32b, 0 - 20b
      3'h5 : packet_sz = 24;  // 10 - 32b, 1 - 16b
      3'h6 : packet_sz = 32;  // 11 - 32b, 0 - 20b
      3'h7 : packet_sz = 24;  // 11 - 32b, 1 - 16b
    endcase

    #5ns;
    db_i_index = packet_sz;
    scki_edges = packet_sz * (1 + crc_en);

    if (testpattern_en == 1) begin
      if (packet_sz == 16) begin
        // AD4851/3/5/7
        rx_db_i[0] = 'h0ACE;
        rx_db_i[1] = 'h1ACE;
        rx_db_i[2] = 'h2ACE;
        rx_db_i[3] = 'h3ACE;
        rx_db_i[4] = OCTA_CHANNEL ? 'h4ACE : 'h709c; // channel or CRC (Quad channels)
        rx_db_i[5] = 'h5ACE;
        rx_db_i[6] = 'h6ACE;
        rx_db_i[7] = 'h7ACE;
        rx_db_i[8] = 'hf1be;
      end else if (packet_sz == 20) begin
        rx_db_i[0] = 'h0ACE3;
        rx_db_i[1] = 'h1ACE3;
        rx_db_i[2] = 'h2ACE3;
        rx_db_i[3] = 'h3ACE3;
        rx_db_i[4] = OCTA_CHANNEL ? 'h4ACE3 : 'h7696;
        rx_db_i[5] = 'h5ACE3;
        rx_db_i[6] = 'h6ACE3;
        rx_db_i[7] = 'h7ACE3;
        rx_db_i[8] = 'h4c3b;
      end else if (packet_sz == 24) begin
        rx_db_i[0] = 'h0ACE3C;
        rx_db_i[1] = 'h1ACE3C;
        rx_db_i[2] = 'h2ACE3C;
        rx_db_i[3] = 'h3ACE3C;
        rx_db_i[4] = OCTA_CHANNEL ? 'h4ACE3C : 'h25e2;
        rx_db_i[5] = 'h5ACE3C;
        rx_db_i[6] = 'h6ACE3C;
        rx_db_i[7] = 'h7ACE3C;
        rx_db_i[8] = 'h5435;
      end else if (packet_sz == 32) begin
        rx_db_i[0] = 'h0ACE3C2A;
        rx_db_i[1] = 'h1ACE3C2A;
        rx_db_i[2] = 'h2ACE3C2A;
        rx_db_i[3] = 'h3ACE3C2A;
        rx_db_i[4] = OCTA_CHANNEL ? 'h4ACE3C2A : 'h78ee;
        rx_db_i[5] = 'h5ACE3C2A;
        rx_db_i[6] = 'h6ACE3C2A;
        rx_db_i[7] = 'h7ACE3C2A;
        rx_db_i[8] = 'h2118;
      end
    end
    else begin
      rx_db_i[0] = 'h80000;
      rx_db_i[1] = 'h80001;
      rx_db_i[2] = 'h80002;
      rx_db_i[3] = 'h80003;
      rx_db_i[4] = 'h80004;
      rx_db_i[5] = 'h80005;
      rx_db_i[6] = 'h80006;
      rx_db_i[7] = 'h80007;
      rx_db_i[8] = 'h0; // crc gen will not be implemented
    end

    for (int conv = 0; conv < NO_OF_T; conv = conv + 1) begin
      for (int i = 0; i < NUMB_OF_CH; i =i +1 ) begin
        if (testpattern_en ==1) begin
          expected_rx = rx_db_i[i];
        end else begin
          expected_rx = rx_db_i[i] + conv;
        end
        case ({packet_format,packet_formats,oversampling_en})                 // Packet format  Resolution  OS En(N/Y)
          4'h0, 4'h1 : expected_adc_data[conv][i] = {12'd0,expected_rx[19:0]};     // 00 - 20b        0 - 20b      0/1
          4'h2, 4'h3 : expected_adc_data[conv][i] = expected_rx[15:0];             // 00 - 16b        1 - 16b      0/1
          4'h4 : expected_adc_data[conv][i] = {12'd0,expected_rx[23:4]};           // 01 - 24b        0 - 20b      0
          4'h5 : expected_adc_data[conv][i] = {8'd0,expected_rx[23:0]};            // 01 - 24b        0 - 20b      1
          4'h6 : expected_adc_data[conv][i] = expected_rx[23:8];                   // 01 - 24b        1 - 16b      0
          4'h7 : expected_adc_data[conv][i] = expected_rx[23:8];                   // 01 - 24b        1 - 16b      1
          4'h8, 4'h12 : expected_adc_data[conv][i] = {12'd0, expected_rx[31:12]};  // 10/11 - 32b     0 - 20b      0
          4'h9, 4'h13 : expected_adc_data[conv][i] = {8'd0, expected_rx[31:8]};    // 10/11 - 32b     0 - 20b      1
          default: expected_adc_data[conv][i] = expected_rx[23:8];                 // 10/11 - 24b     1 - 16b      0/1
        endcase
      end
    end
  endtask: prepare_data

  task capture_data();
    int word_addr;

    repeat (NO_OF_T) begin
      @(negedge `TH.axi_ad485x_adc_valid);
    end
    #200ns; // Extra delay for DMA write completion
    pwm_api.reset();

    if (DW == 16) begin
      for (int conv=0; conv<NO_OF_T; conv=conv+1) begin
        for (int i=0; i<NUMB_OF_CH; i=i+2) begin
          word_addr = conv * (NUMB_OF_CH/2) + (i/2);
          word = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(
            xil_axi_uint'(`DDR_BA) + xil_axi_uint'(4 * word_addr));
          captured_conv_data[conv][i]   = word[15:0];
          captured_conv_data[conv][i+1] = word[31:16];
        end
      end
    end else begin
      for (int conv=0; conv<NO_OF_T; conv=conv+1) begin
        for (int i=0; i<NUMB_OF_CH; i=i+1) begin
          word_addr = conv * NUMB_OF_CH + i;
          captured_conv_data[conv][i] = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(
            xil_axi_uint'(`DDR_BA) + xil_axi_uint'(4 * word_addr));
        end
      end
    end

    `INFO(("Verifying first conversion out of %d captured", NO_OF_T), ADI_VERBOSITY_LOW);
    `INFO(("Expected first conversion: %x", expected_adc_data), ADI_VERBOSITY_LOW);

    // Check that the captured data matches the expected values
    for (int conv=0; conv<NO_OF_T; conv=conv+1) begin
      for (int i=0; i<NUMB_OF_CH; i=i+1) begin
        if (captured_conv_data[conv][i] != expected_adc_data[conv][i]) begin
          `ERROR(("Conversion mismatch on channel %d: expected %x, got %x",
                  i, expected_adc_data[conv][i], captured_conv_data[conv][i]));
          expected_conv = 0;
        end else begin
          `INFO(("Channel %d OK: %x", i, captured_conv_data[conv][i]), ADI_VERBOSITY_LOW);
        end
      end
    end

    if (expected_conv) begin
      `INFO(("DMA Test PASSED - All conversions were captured correctly"), ADI_VERBOSITY_NONE);
    end else begin
      `ERROR(("DMA Test FAILED - Conversion data mismatch"));
    end

    // CRC check
    if (crc_en == 1) begin
      for (int i = 0; i < NUMB_OF_CH; i=i+1) begin
        axi_read(`AXI_AD485X_BA + i*'h40 + GetAddrs(ADC_CHANNEL_REG_CHAN_STATUS), crc_err);
        if (crc_err[12] == 1) begin
          crc_err_found = 1;
          `ERROR(("CRC error detected on channel %d after %d conversions", i, NO_OF_T));
          break;
        end
      end

      if (crc_err_found == 1) begin
        `ERROR(("CRC check FAILED"));
      end else begin
        `INFO(("CRC check PASSED for all %d conversions", NO_OF_T), ADI_VERBOSITY_NONE);
      end
    end

    // Check the data acquisition completeness
    if (complete_data_aq == 0) begin
      `INFO(("CRITICAL WARNING: Data transaction doesn't meet the minimum timing requirement between the last SCKI edge and the CNV signal according to the datasheet!"), ADI_VERBOSITY_NONE);
    end
  endtask: capture_data

  initial begin
    forever begin
    @(posedge `TH.adc_clk);

      if ((~cnvs_d & cnvs_tp && busy == 0) && oversampling_en == 0) begin
         if (scki_counter > 0 && scki_counter < scki_edges) begin
          complete_data_aq = 0;
        end
        else if(scki_counter == 0) begin
          complete_data_aq = 1;
        end
      end

      if ((~cnvs_d & cnvs_tp && busy == 0) || busy_os == 1) begin
        busy_counter = 'd0;
        busy = 1'b1;
      end
      else if (busy_counter == busy_period) begin
        busy_counter = 'd0;
        busy = busy_os;
      end
      else if (busy == 1'b1) begin
        busy_counter = 1 + busy_counter;
        busy = 1'b1;
      end

      if (oversampling_en == 1) begin
        if (oversampling_counter == 'd4) begin
          oversampling_counter = 'd0;
          busy_os = 1'b0;
        end else if (~cnvs_tp & cnvs_d && oversampling_counter < 'd4 && busy == 1'b1) begin
          oversampling_counter = oversampling_counter +1;
          busy_os = 1'b1;
        end
      end
      cnvs_d = cnvs_tp;

      if (busy_d & !busy) begin
        db_i_index = packet_sz - 1;
        ring_buffer_index = 0;
        scki_counter = scki_edges;

        db_i_shift[0] = db_i_shift[0];
        db_i_shift[1] = db_i_shift[1];
        db_i_shift[2] = db_i_shift[2];
        db_i_shift[3] = db_i_shift[3];
        db_i_shift[4] = db_i_shift[4];
        db_i_shift[5] = db_i_shift[5];
        db_i_shift[6] = db_i_shift[6];
        db_i_shift[7] = db_i_shift[7];

      end else if (~scki_tp & scki_d) begin
        db_i_index = (db_i_index != 'd0) ? db_i_index - 1 : packet_sz -1;
        ring_buffer_index = (db_i_index == 'd0) ? ring_buffer_index +1 : (ring_buffer_index == MAXR_INDEX) ? 0 : ring_buffer_index;

        if (scki_counter > 0) begin
          scki_counter = scki_counter - 1;
        end

        for (int i=0; i<8; i=i+1) begin
          if (i < NUMB_OF_CH) begin
            db_i_shift[i] = rx_db_i[ch_index_lane[i]][db_i_index];
          end else begin
            db_i_shift[i] = 0;
          end
        end

      end

      busy_d = busy;
      scki_d = scki_tp;
      scki_d2 = scki_d;

      if (`TH.axi_ad485x_adc_valid && `TH.axi_ad485x_adc_data_0 ==
          rx_db_i[0] && testpattern_en == 0) begin
        rx_db_i[0] = rx_db_i[0] + 1;
        rx_db_i[1] = rx_db_i[1] + 1;
        rx_db_i[2] = rx_db_i[2] + 1;
        rx_db_i[3] = rx_db_i[3] + 1;
        rx_db_i[4] = rx_db_i[4] + 1;
        rx_db_i[5] = rx_db_i[5] + 1;
        rx_db_i[6] = rx_db_i[6] + 1;
        rx_db_i[7] = rx_db_i[7] + 1;
      end

    end
  end

generate
  for (genvar i=0; i<8; i=i+1) begin
    assign ch_index_lane[i] = (i + ring_buffer_index) == MAXC_INDEX ? 0 : (i + ring_buffer_index) > MAXC_INDEX ? (i + ring_buffer_index) - 8 : i + ring_buffer_index;
  end
endgenerate

assign adc_lane_0_tp = db_i_shift[0];
assign adc_lane_1_tp = db_i_shift[1];
assign adc_lane_2_tp = db_i_shift[2];
assign adc_lane_3_tp = db_i_shift[3];
assign adc_lane_4_tp = db_i_shift[4];
assign adc_lane_5_tp = db_i_shift[5];
assign adc_lane_6_tp = db_i_shift[6];
assign adc_lane_7_tp = db_i_shift[7];

assign busy_tp = busy;
assign scko_tp = scki_d2;
endprogram
