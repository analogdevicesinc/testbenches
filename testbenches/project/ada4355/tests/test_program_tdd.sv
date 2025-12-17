// ***************************************************************************
// ***************************************************************************
// Copyright 2025 (c) Analog Devices, Inc. All rights reserved.
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

`include "utils.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import dmac_api_pkg::*;
import adc_api_pkg::*;
import tdd_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

//---------------------------------------------------------------------------
// Timing parameters
//---------------------------------------------------------------------------
localparam DCO_HALF_PERIOD = 1;   // Period 2 ns -> 500 MHz DCO
localparam FRAME_HALF_PERIOD = 4; // Period 8 ns -> 125 MHz Frame
localparam FRAME_DELAY = FRAME_HALF_PERIOD + (8 - `FRAME_SHIFT_CNT) * DCO_HALF_PERIOD
                         + ((`FRAME_SHIFT_CNT % 2) * DCO_HALF_PERIOD);
localparam DATA_DELAY = FRAME_DELAY;

program test_program_tdd (
  output reg dco_p,
  output reg dco_n,
  output reg da_p,
  output reg da_n,
  output reg db_p,
  output reg db_n,
  output reg sync_n,
  output reg frame_p,
  output reg frame_n,
  output reg tdd_ext_sync
);

  timeunit 1ns;
  timeprecision 1ps;

  // Module-level constants used in tasks
  localparam int num_lanes = 2;
  localparam int sdr_ddr_n = 0;

  // Sine wave generation parameters
  localparam real PI = 3.14159265358979;
  localparam SINE_AMPLITUDE = 8191;   // Full 14-bit scale
  localparam SINE_OFFSET = 8192;      // Mid-scale for 14-bit (2^13)
  localparam SINE_PERIOD = 64;        // Samples per sine period

  test_harness_env env;
  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  // API instances
  dmac_api rx_dma_api;
  adc_api rx_adc_api;
  tdd_api tdd;

  //---------------------------------------------------------------------------
  // Internal signals for stimulus generation
  //---------------------------------------------------------------------------
  reg sync_n_d = 1'b0;
  reg ssi_clk = 1'b0;
  reg frame_clk = 1'b1;  // Start HIGH for 0xF0 pattern
  reg [2:0] ssi_edge_cnt = 3'd0;

  reg [15:0] sample;
  reg da_p_int = 1'b0;
  reg db_p_int = 1'b0;
  reg [31:0] sample_count = 0;

  //---------------------------------------------------------------------------
  // TDD LiDAR debug markers
  //---------------------------------------------------------------------------
  reg tdd_ch0_d = 0;
  reg [15:0] sample_at_laser_fire = 0;
  reg [15:0] sample_at_gate_open = 0;
  reg [31:0] samples_captured_count = 0;
  reg laser_fired_marker = 0;
  reg gate_opened_marker = 0;
  reg tdd_ch1_d = 0;
  reg dma_capture_active = 0;
  reg dma_ch1_d = 0;

  // CH0 (laser trigger) rising edge detection + marker
  initial forever begin
    @(posedge `TH.axi_tdd_0.clk);
    if (`TH.axi_tdd_0.tdd_channel_0 && !tdd_ch0_d) begin
      sample_at_laser_fire = `TH.axi_ada4355_adc.adc_data[15:0];
      laser_fired_marker = 1'b1;
      `INFO(("LASER FIRED at sample_count=%0d, adc_data=0x%04h",
              sample_count, `TH.axi_ada4355_adc.adc_data[15:0]), ADI_VERBOSITY_LOW);
    end else begin
      laser_fired_marker = 1'b0;
    end
    tdd_ch0_d = `TH.axi_tdd_0.tdd_channel_0;
  end

  // CH1 (DMA sync) rising edge detection + marker
  initial forever begin
    @(posedge `TH.axi_tdd_0.clk);
    if (`TH.axi_tdd_0.tdd_channel_1 && !tdd_ch1_d) begin
      sample_at_gate_open = `TH.axi_ada4355_adc.adc_data[15:0];
      gate_opened_marker = 1'b1;
      `INFO(("ADC GATE OPENED at sample_count=%0d, adc_data=0x%04h",
              sample_count, `TH.axi_ada4355_adc.adc_data[15:0]), ADI_VERBOSITY_LOW);
    end else begin
      gate_opened_marker = 1'b0;
    end
    tdd_ch1_d = `TH.axi_tdd_0.tdd_channel_1;
  end

  // DMA capture counter - tracks actual samples written after sync trigger
  initial forever begin
    @(posedge `TH.axi_ada4355_dma.fifo_wr_clk);
    if (`TH.axi_tdd_0.tdd_channel_1 && !dma_ch1_d) begin
      dma_capture_active = 1;
      samples_captured_count = 0;
    end else if (dma_capture_active && `TH.axi_ada4355_dma.fifo_wr_en) begin
      samples_captured_count = samples_captured_count + 1;
      if (samples_captured_count < 3) begin
        `INFO(("SAMPLE CAPTURED #%0d: 0x%04h", samples_captured_count, `TH.axi_ada4355_dma.fifo_wr_din), ADI_VERBOSITY_LOW);
      end
    end
    dma_ch1_d = `TH.axi_tdd_0.tdd_channel_1;
  end

  //---------------------------------------------------------------------------
  // Initialize TDD external sync to avoid x in CDC synchronizer
  //---------------------------------------------------------------------------
  initial begin
    tdd_ext_sync = 1'b0;
  end

  //---------------------------------------------------------------------------
  // Transport delay for sync_n (simulates PCB and clock chip propagation)
  //---------------------------------------------------------------------------
  initial begin
    sync_n <= 1'b0;
    forever begin
      @(sync_n);
      sync_n_d <= #25ns sync_n;
    end
  end

  //---------------------------------------------------------------------------
  // Transport delay for DCO clock (simulates internal FPGA clock path delay)
  //---------------------------------------------------------------------------
  initial begin
    dco_p <= 1'b0;
    dco_n <= 1'b1;
    forever begin
      @(ssi_clk);
      dco_p <= #3ns ssi_clk;
      dco_n <= #3ns ~ssi_clk;
    end
  end

  //---------------------------------------------------------------------------
  // Transport delay for frame clock
  //---------------------------------------------------------------------------
  initial begin
    frame_p <= 1'b0;
    frame_n <= 1'b1;
    forever begin
      @(frame_clk);
      frame_p <= #3.5ns frame_clk;
      frame_n <= #3.5ns ~frame_clk;
    end
  end

  //---------------------------------------------------------------------------
  // Transport delay for data signals
  //---------------------------------------------------------------------------
  initial begin
    da_p <= 1'b0;
    da_n <= 1'b1;
    forever begin
      @(da_p_int);
      da_p <= #3.5ns da_p_int;
      da_n <= #3.5ns ~da_p_int;
    end
  end

  initial begin
    db_p <= 1'b0;
    db_n <= 1'b1;
    forever begin
      @(db_p_int);
      db_p <= #3.5ns db_p_int;
      db_n <= #3.5ns ~db_p_int;
    end
  end

  //---------------------------------------------------------------------------
  // SSI clock generator (500 MHz) - derives frame clock to prevent drift
  //---------------------------------------------------------------------------
  initial begin
    @(posedge sync_n_d);
    `INFO(("FRAME_SHIFT_CNT=%0d, FRAME_DELAY=%0d ns", `FRAME_SHIFT_CNT, FRAME_DELAY), ADI_VERBOSITY_LOW);

    // Initial delay to set frame/data phase offset
    repeat(FRAME_DELAY + FRAME_HALF_PERIOD) begin
      #(DCO_HALF_PERIOD * 1ns);
      ssi_clk = ~ssi_clk;
    end

    // Toggle frame and start synchronized generation
    frame_clk = ~frame_clk;
    ssi_edge_cnt = 3'd0;

    forever begin
      #(DCO_HALF_PERIOD * 1ns);
      ssi_clk = ~ssi_clk;

      // Derive frame from SSI: toggle every 4 edges
      if (ssi_edge_cnt == 3'd3) begin
        ssi_edge_cnt = 3'd0;
        frame_clk = ~frame_clk;
      end else begin
        ssi_edge_cnt = ssi_edge_cnt + 1;
      end
    end
  end

  //---------------------------------------------------------------------------
  // Function to calculate sine sample value
  //---------------------------------------------------------------------------
  function [15:0] calc_sine_sample(input [31:0] idx);
    real angle;
    real sine_val;
    integer result;
    begin
      angle = 2.0 * PI * $itor(idx) / $itor(SINE_PERIOD);
      sine_val = $sin(angle);
      result = SINE_OFFSET + $rtoi(sine_val * $itor(SINE_AMPLITUDE));
      if (result < 0) result = 0;
      if (result > 16383) result = 16383;
      calc_sine_sample = result[15:0];
    end
  endfunction

  //---------------------------------------------------------------------------
  // Data generation - sine wave pattern
  //---------------------------------------------------------------------------
  initial begin
    @(posedge sync_n_d);

    sample = calc_sine_sample(0);

    `INFO(("Starting sine wave data generation"), ADI_VERBOSITY_LOW);
    `INFO(("FRAME_SHIFT_CNT=%0d, DATA_DELAY=%0d ns", `FRAME_SHIFT_CNT, DATA_DELAY), ADI_VERBOSITY_LOW);

    #(DATA_DELAY * 1ns);

    da_p_int <= sample[14];
    db_p_int <= sample[15];

    forever begin
      @(posedge ssi_clk);
      da_p_int <= sample[12];
      db_p_int <= sample[13];

      @(negedge ssi_clk);
      da_p_int <= sample[10];
      db_p_int <= sample[11];

      @(posedge ssi_clk);
      da_p_int <= sample[8];
      db_p_int <= sample[9];

      @(negedge ssi_clk);
      da_p_int <= sample[6];
      db_p_int <= sample[7];

      @(posedge ssi_clk);
      da_p_int <= sample[4];
      db_p_int <= sample[5];

      @(negedge ssi_clk);
      da_p_int <= sample[2];
      db_p_int <= sample[3];

      @(posedge ssi_clk);
      da_p_int <= sample[0];
      db_p_int <= sample[1];

      @(negedge ssi_clk);
      sample_count <= sample_count + 1;

      da_p_int <= sample[14];
      db_p_int <= sample[15];

      sample <= calc_sine_sample(sample_count + 1);
    end
  end

// --------------------------
// Main procedure
// --------------------------

initial begin

  //creating environment
  env = new(
    .name("Test Environment"),
    .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
    .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
    .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
    .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
    .irq_base_address(`IRQ_C_BA),
    .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

  mng = new(.name(""), .master_vip_if(`TH.`MNG_AXI.inst.IF));
  ddr = new(.name(""), .slave_vip_if(`TH.`DDR_AXI.inst.IF));

  `LINK(mng, env, mng)
  `LINK(ddr, env, ddr)

  // Initialize API instances
  rx_dma_api = new(.name("RX DMA API"),
                   .bus(env.mng.master_sequencer),
                   .base_address(`ADA4355_DMA_BA));

  rx_adc_api = new(.name("RX ADC API"),
                   .bus(env.mng.master_sequencer),
                   .base_address(`ADA4355_ADC_BA));

  tdd = new(.name("TDD API"),
            .bus(env.mng.master_sequencer),
            .base_address(`AXI_TDD_BA));

  setLoggerVerbosity(ADI_VERBOSITY_NONE);
  env.start();

  // System reset
  env.sys_reset();

  sanity_test();

  dma_test();

  resync();

  tdd_lidar_test();

  env.stop();
  `INFO(("Test Done"), ADI_VERBOSITY_NONE);
  $finish();

end

// --------------------------
// Sanity test reg interface
// --------------------------

task sanity_test();
  // TODO: use rx_adc_api.sanity_test() when adc_api supports it
  // rx_adc_api.sanity_test();

  // Run DMA sanity test
  rx_dma_api.sanity_test();

  `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
endtask

// --------------------------
// Setup link
// --------------------------

task link_setup();
  // Configure Rx interface
  rx_adc_api.set_common_control(
    .pin_mode(1'b0),
    .ddr_edgesel(1'b0),
    .r1_mode(1'b0),
    .sync(1'b0),
    .num_lanes(num_lanes),
    .symb_8_16b(1'b0),
    .symb_op(1'b0),
    .sdr_ddr_n(sdr_ddr_n));

  // pull out RX of reset
  rx_adc_api.reset(.ce_n(1'b1), .mmcm_rstn(1'b1), .rstn(1'b1));

  sync_n = 1'b1;
endtask

task resync();

  `INFO(("Triggering resync via sync_n pulse"), ADI_VERBOSITY_LOW);

  // Directly control sync_n to trigger FSM reset
  sync_n = 1'b0;

  // Hold sync_n low for enough time for the FSM to reset
  // serdes_reset shift register needs 10 clock cycles (adc_clk_div = 125MHz = 8ns)
  #100ns;

  // Release sync_n to allow FSM to re-align
  sync_n = 1'b1;

  // Wait for FSM to complete alignment search
  // FSM takes ~3 cycles per shift value, 8 values max = 24 cycles = ~200ns
  #300ns;

  `INFO(("Resync complete - FSM should have re-aligned"), ADI_VERBOSITY_LOW);

  // Write to the register for consistency with real HW flow
  rx_adc_api.set_common_control(
    .pin_mode(1'b0),
    .ddr_edgesel(1'b0),
    .r1_mode(1'b0),
    .sync(1'b1),
    .num_lanes(num_lanes),
    .symb_8_16b(1'b0),
    .symb_op(1'b0),
    .sdr_ddr_n(sdr_ddr_n));
endtask

// --------------------------
// Enable pattern
// --------------------------

task enable_pattern();
  logic sync_stat;

  rx_adc_api.set_common_control_3(.crc_en(1'b0), .custom_control(8'h2));

  rx_adc_api.set_common_control(
    .pin_mode(1'b0),
    .ddr_edgesel(1'b0),
    .r1_mode(1'b0),
    .sync(1'b1),
    .num_lanes(num_lanes),
    .symb_8_16b(1'b0),
    .symb_op(1'b0),
    .sdr_ddr_n(sdr_ddr_n));

  rx_adc_api.get_sync_status(sync_stat);
  `INFO(("Sync status = %0d", sync_stat), ADI_VERBOSITY_LOW);

  // Wait for FSM to stabilize (50 cycles at 125MHz = 400ns)
  #400ns;
endtask

// --------------------------
// DMA test procedure
// --------------------------

task dma_test();
  logic [3:0] transfer_id;
  localparam TRANSFER_LENGTH = 64*4;  // 64 samples * 4 bytes
  localparam DMA_DEST_ADDR = `DDR_BA + 32'h00002000;

  link_setup();

  `INFO(("Link Setup Done"), ADI_VERBOSITY_LOW);

  // Configure TDD for basic DMA test
  // Channel 1: DMA sync pulse - required because DMA has SYNC_TRANSFER_START=1
  // Use software sync to trigger AFTER DMA is armed
  tdd.set_control(.sync_soft(0), .sync_ext(0), .sync_int(0), .sync_rst(0), .enable(0));
  tdd.set_startup_delay(0);
  tdd.set_frame_length(32'hFFFFFFFF);
  tdd.set_burst_count(1);

  // Channel 1: Generate sync pulse for DMA (pulse at start of frame)
  tdd.set_channel_on(.channel(1), .value(10));
  tdd.set_channel_off(.channel(1), .value(20));

  tdd.set_channel_enable(32'h2);
  tdd.set_channel_polarity(32'h0);

  `INFO(("TDD configured (not enabled yet - waiting for DMA setup)"), ADI_VERBOSITY_LOW);

  // Configure RX DMA
  rx_dma_api.enable_dma();
  rx_dma_api.set_flags(
    .cyclic(1'b0),
    .tlast(1'b1),
    .partial_reporting_en(1'b0));
  rx_dma_api.set_lengths(.xfer_length_x(TRANSFER_LENGTH-1), .xfer_length_y(0));
  rx_dma_api.set_dest_addr(.xfer_addr(DMA_DEST_ADDR));

  // Get transfer ID and start
  rx_dma_api.transfer_id_get(transfer_id);
  rx_dma_api.transfer_start();

  `INFO(("Configure RX DMA Done, transfer_id=%0d", transfer_id), ADI_VERBOSITY_LOW);

  enable_pattern();

  `INFO(("Enable Pattern Done"), ADI_VERBOSITY_LOW);

  // Now trigger TDD with external sync (DMA is armed and waiting for sync pulse)
  tdd.set_control(.sync_soft(0), .sync_ext(1), .sync_int(0), .sync_rst(0), .enable(1));

  #200ns;  // Wait for TDD FSM to reach ARMED state

  trigger_tdd_sync();  // Pulse external sync via testbench
  `INFO(("TDD triggered with external sync - CH1 pulse will trigger DMA"), ADI_VERBOSITY_LOW);

  // Wait for DMA transfer to complete
  rx_dma_api.wait_transfer_done(.transfer_id(transfer_id), .timeut_in_us(5000));

  `INFO(("DMA Transfer Complete"), ADI_VERBOSITY_LOW);

  // Debug: dump first 16 words of raw data to analyze pattern
  dump_raw_data(.address(DMA_DEST_ADDR), .length(16));

  // Verify captured data
  check_captured_data(
    .address(DMA_DEST_ADDR),
    .length(TRANSFER_LENGTH/4)
  );

  disable_tdd();
  `INFO(("DMA test complete"), ADI_VERBOSITY_LOW);
endtask

// Check captured data - verify sine wave pattern
// Data format: Each 32-bit word contains 2 x 16-bit samples
// Word[31:16] = sample[2*i+1], Word[15:0] = sample[2*i]
task check_captured_data(input bit [31:0] address,
                         input int length = 64);

  bit [31:0] current_address;
  bit [31:0] captured_word;
  bit [15:0] sample_lo, sample_hi;
  bit [15:0] expected_lo, expected_hi;
  int sample_index;
  int start_offset;
  automatic bit offset_found = 1'b0;

  `INFO(("Checking captured SINE WAVE data at address 0x%h, length=%0d words", address, length), ADI_VERBOSITY_LOW);

  // Auto-detect starting offset by matching first two captured samples
  captured_word = env.ddr.slave_sequencer.BackdoorRead32(address);
  sample_lo = captured_word[15:0];
  sample_hi = captured_word[31:16];

  for (int offset = 0; offset < SINE_PERIOD; offset++) begin
    if (calc_sine_sample(offset) == sample_lo &&
        calc_sine_sample(offset + 1) == sample_hi) begin
      start_offset = offset;
      offset_found = 1;
      `INFO(("Auto-detected start_offset=%0d", start_offset), ADI_VERBOSITY_LOW);
      break;
    end
  end

  if (!offset_found) begin
    `FATAL(("Could not auto-detect start offset! First samples 0x%04h/0x%04h don't match any sine values", sample_hi, sample_lo));
  end

  for (int i = 0; i < length; i = i + 1) begin
    current_address = address + (i * 4);
    captured_word = env.ddr.slave_sequencer.BackdoorRead32(current_address);

    // Extract the two 16-bit samples from the 32-bit word
    sample_lo = captured_word[15:0];
    sample_hi = captured_word[31:16];

    // Calculate expected sine values for this word
    // Each word contains 2 samples: sample[2*i] and sample[2*i+1]
    // Account for start_offset to handle latency between testbench start and DMA capture
    sample_index = 2 * i;
    expected_lo = calc_sine_sample(start_offset + sample_index);
    expected_hi = calc_sine_sample(start_offset + sample_index + 1);

    // Verify samples match expected sine values
    if (sample_lo !== expected_lo) begin
      `ERROR(("Word %0d [15:0]: Address 0x%h Value 0x%h, expected 0x%h (sample %0d, sine_idx=%0d)",
              i, current_address, sample_lo, expected_lo, sample_index, (start_offset + sample_index) % SINE_PERIOD));
    end
    if (sample_hi !== expected_hi) begin
      `ERROR(("Word %0d [31:16]: Address 0x%h Value 0x%h, expected 0x%h (sample %0d, sine_idx=%0d)",
              i, current_address, sample_hi, expected_hi, sample_index+1, (start_offset + sample_index + 1) % SINE_PERIOD));
    end

    // Log first few samples for debugging
    if (i < 5) begin
      `INFO(("Word %0d: 0x%08h -> [15:0]=0x%04h (expect 0x%04h), [31:16]=0x%04h (expect 0x%04h)",
             i, captured_word, sample_lo, expected_lo, sample_hi, expected_hi), ADI_VERBOSITY_LOW);
    end
  end

endtask

// Debug task: dump raw captured data to analyze bit patterns
task dump_raw_data(input bit [31:0] address, input int length = 16);
  bit [31:0] current_address;
  bit [31:0] captured_word;
  bit [15:0] sample_lo, sample_hi;

  `INFO(("=== RAW DATA DUMP from address 0x%h ===", address), ADI_VERBOSITY_LOW);
  `INFO(("Word | Address    | Raw 32-bit | [31:16]  | [15:0]"), ADI_VERBOSITY_LOW);
  `INFO(("-----|------------|------------|----------|----------"), ADI_VERBOSITY_LOW);

  for (int i = 0; i < length; i++) begin
    current_address = address + (i * 4);
    captured_word = env.ddr.slave_sequencer.BackdoorRead32(current_address);
    sample_lo = captured_word[15:0];
    sample_hi = captured_word[31:16];

    `INFO(("%4d | 0x%08h | 0x%08h | 0x%04h   | 0x%04h",
           i, current_address, captured_word, sample_hi, sample_lo), ADI_VERBOSITY_LOW);
  end
  `INFO(("=== END RAW DATA DUMP ==="), ADI_VERBOSITY_LOW);
endtask

task disable_tdd();
  `INFO(("Disabling TDD"), ADI_VERBOSITY_LOW);
  tdd.set_channel_enable(32'h0);
  tdd.set_control(.sync_soft(0), .sync_ext(0), .sync_int(0), .sync_rst(1), .enable(0));
  #50ns;
  tdd.set_control(.sync_soft(0), .sync_ext(0), .sync_int(0), .sync_rst(0), .enable(0));
endtask

task trigger_tdd_sync();
  `INFO(("Triggering TDD external sync pulse"), ADI_VERBOSITY_LOW);
  tdd_ext_sync = 1'b1;
  #50ns;
  tdd_ext_sync = 1'b0;
  `INFO(("TDD sync pulse complete"), ADI_VERBOSITY_LOW);
endtask

// --------------------------
// TDD LiDAR test procedure
// --------------------------
task tdd_lidar_test();
  logic [3:0] transfer_id;
  bit [31:0] val;

  localparam LASER_ON_TIME = 0;
  localparam LASER_OFF_TIME = 2;
  localparam GATE_ON_TIME = 13;
  localparam FRAME_LENGTH = 12500;

  localparam CAPTURE_SAMPLES = 12;
  localparam TRANSFER_LENGTH = CAPTURE_SAMPLES * 2;
  localparam DMA_DEST_ADDR = `DDR_BA + 32'h00003000;

  `INFO(("=== TDD LiDAR Test Started (Realistic Timing) ==="), ADI_VERBOSITY_LOW);
  `INFO(("LiDAR parameters: Laser pulse 0-%0d, DMA sync at %0d (%0d samples)",
         LASER_OFF_TIME, GATE_ON_TIME, CAPTURE_SAMPLES), ADI_VERBOSITY_LOW);
  `INFO(("Physics: DMA triggered at %0dns (~15m reflection)",
         GATE_ON_TIME * 8), ADI_VERBOSITY_LOW);

  link_setup();

  // Force frame to end quickly so FSM can reach IDLE
  tdd.set_frame_length(10);

  tdd.set_channel_enable(32'h0);
  tdd.set_control(.sync_soft(0), .sync_ext(0), .sync_int(0), .sync_rst(0), .enable(0));

  `INFO(("TDD reset complete, configuring for LiDAR operation"), ADI_VERBOSITY_LOW);

  // Use SYNC_RST to reset TDD FSM
  tdd.set_control(.sync_soft(0), .sync_ext(0), .sync_int(0), .sync_rst(1), .enable(0));
  #200ns;
  tdd.set_control(.sync_soft(0), .sync_ext(0), .sync_int(0), .sync_rst(0), .enable(0));
  #200ns;

  // Configure timing
  tdd.set_startup_delay(0);
  tdd.set_frame_length(FRAME_LENGTH);
  tdd.set_burst_count(1);

  // CH0: Laser trigger pulse
  tdd.set_channel_on(.channel(0), .value(LASER_ON_TIME));
  tdd.set_channel_off(.channel(0), .value(LASER_OFF_TIME));

  // CH1: DMA sync
  tdd.set_channel_on(.channel(1), .value(GATE_ON_TIME));
  tdd.set_channel_off(.channel(1), .value(GATE_ON_TIME + 10));

  // Enable CH0 + CH1
  tdd.set_channel_enable(32'h3);
  tdd.set_channel_polarity(32'h0);

  `INFO(("TDD configured: FRAME=%0d, CH0 laser 0-%0d, CH1 sync %0d-%0d",
         FRAME_LENGTH, LASER_OFF_TIME, GATE_ON_TIME, GATE_ON_TIME + 10), ADI_VERBOSITY_LOW);

  rx_dma_api.set_control(4'b0000);  // Disable DMA

  rx_dma_api.enable_dma();
  rx_dma_api.set_flags(
    .cyclic(1'b0),
    .tlast(1'b1),
    .partial_reporting_en(1'b0));
  rx_dma_api.set_lengths(.xfer_length_x(TRANSFER_LENGTH-1), .xfer_length_y(0));
  rx_dma_api.set_dest_addr(.xfer_addr(DMA_DEST_ADDR));

  rx_dma_api.transfer_id_get(transfer_id);
  rx_dma_api.transfer_start();

  `INFO(("DMA Started (transfer_id=%0d)", transfer_id), ADI_VERBOSITY_LOW);

  enable_pattern();

  `INFO(("Pattern enabled"), ADI_VERBOSITY_LOW);

  // Trigger TDD with SYNC_EXT mode
  tdd.set_control(.sync_soft(0), .sync_ext(1), .sync_int(0), .sync_rst(0), .enable(1));
  #200ns;
  trigger_tdd_sync();
  `INFO(("TDD triggered with external sync"), ADI_VERBOSITY_LOW);

  // Debug: Read back TDD registers
  tdd.get_channel_enable(val);
  `INFO(("TDD_CHANNEL_ENABLE: 0x%08h (expect 0x3)", val), ADI_VERBOSITY_LOW);

  // Wait for DMA
  rx_dma_api.wait_transfer_done(.transfer_id(transfer_id), .timeut_in_us(5000));

  `INFO(("DMA Transfer Complete"), ADI_VERBOSITY_LOW);

  dump_raw_data(.address(DMA_DEST_ADDR), .length(TRANSFER_LENGTH/4));

  check_captured_data(
    .address(DMA_DEST_ADDR),
    .length(TRANSFER_LENGTH/4));

  disable_tdd();

  `INFO(("=== TDD LiDAR Test Complete ==="), ADI_VERBOSITY_LOW);
endtask

endprogram
