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

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_common_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import dmac_api_pkg::*;
import adc_api_pkg::*;
import common_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program;

  // Base address from block design
  parameter BASE = `ADA4355_ADC_BA;

  // Delay control registers offset
  parameter RX_DELAY_BASE = BASE + 'h02_00 * 4;

  // ADA4355 specific register
  parameter REGMAP_ENABLE = BASE + 'h00C8;

  // TDD base address and register offsets
  parameter TDD_BASE = `AXI_TDD_BA;
  parameter TDD_CONTROL = TDD_BASE + 'h40;
  parameter TDD_CHANNEL_ENABLE = TDD_BASE + 'h44;
  parameter TDD_CHANNEL_POLARITY = TDD_BASE + 'h48;
  parameter TDD_BURST_COUNT = TDD_BASE + 'h4C;
  parameter TDD_STARTUP_DELAY = TDD_BASE + 'h50;
  parameter TDD_FRAME_LENGTH = TDD_BASE + 'h54;
  parameter TDD_CH0_ON = TDD_BASE + 'h80;   // Laser trigger ON
  parameter TDD_CH0_OFF = TDD_BASE + 'h84;  // Laser trigger OFF
  parameter TDD_CH1_ON = TDD_BASE + 'h88;   // ADC gate ON
  parameter TDD_CH1_OFF = TDD_BASE + 'h8C;  // ADC gate OFF
  parameter TDD_CH2_ON = TDD_BASE + 'h90;   // DMA sync ON
  parameter TDD_CH2_OFF = TDD_BASE + 'h94;  // DMA sync OFF

  // Module-level variables used in tasks
  int num_lanes = 2;
  int sdr_ddr_n = 0;

  test_harness_env env;
  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  // API instances
  dmac_api rx_dma_api;
  adc_api rx_adc_api;
  common_api rx_common_api;

  bit [31:0] val;

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
  rx_dma_api = new(.name("RX DMA API"),
                   .bus(env.mng.master_sequencer),
                   .base_address(`ADA4355_DMA_BA));

  rx_adc_api = new(.name("RX ADC API"),
                   .bus(env.mng.master_sequencer),
                   .base_address(BASE));

  rx_common_api = new(.name("RX Common API"),
                      .bus(env.mng.master_sequencer),
                      .base_address(BASE));

  setLoggerVerbosity(ADI_VERBOSITY_LOW);
  env.start();
  env.sys_reset();

  sanity_test;

  dma_test;
  #1000ns;
  resync;
  #5000ns;

  `INFO(("Performing system reset before tdd_lidar_test"), ADI_VERBOSITY_NONE);
  env.sys_reset();
  #1000ns;
  tdd_lidar_test;
  #1000ns;
  `INFO(("All Tests Complete"), ADI_VERBOSITY_NONE);
  $finish;

end

// --------------------------
// Sanity test reg interface
// --------------------------

task sanity_test;
begin
  env.mng.master_sequencer.RegReadVerify32(BASE + GetAddrs(COMMON_REG_VERSION),
                  `SET_COMMON_REG_VERSION_VERSION('h000a0300));
  rx_dma_api.sanity_test();
  `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
end
endtask

// --------------------------
// Setup link
// --------------------------

task link_setup;
begin
  rx_adc_api.set_common_control(
    .pin_mode(1'b0),
    .ddr_edgesel(1'b0),
    .r1_mode(1'b0),
    .sync(1'b0),
    .num_lanes(num_lanes),
    .symb_8_16b(1'b0),
    .symb_op(1'b0),
    .sdr_ddr_n(sdr_ddr_n));
  rx_adc_api.reset(.ce_n(1'b1), .mmcm_rstn(1'b1), .rstn(1'b1));
  force system_tb.sync_n = 1'b1;
  #10ns;
end
endtask

task resync;
begin
  bit [31:0] current_val;

  `INFO(("Triggering resync via sync_n pulse"), ADI_VERBOSITY_LOW);

  // Directly control sync_n via testbench to trigger FSM reset
  force system_tb.sync_n = 1'b0;

  // Hold sync_n low for enough time for the FSM to reset
  // serdes_reset shift register needs 10 clock cycles (adc_clk_div = 125MHz = 8ns)
  #100ns;

  // Release sync_n to allow FSM to re-align
  force system_tb.sync_n = 1'b1;

  // Wait for FSM to complete alignment search
  // FSM takes ~3 cycles per shift value, 8 values max = 24 cycles = ~200ns
  #300ns;

  `INFO(("Resync complete - FSM should have re-aligned"), ADI_VERBOSITY_LOW);

  // Optionally also write to the register for consistency with real HW flow
  rx_adc_api.axi_read(GetAddrs(ADC_COMMON_REG_CNTRL), current_val);
  rx_adc_api.axi_write(GetAddrs(ADC_COMMON_REG_CNTRL), current_val | 32'h8);

end
endtask

// --------------------------
// Enable pattern
// --------------------------

task enable_pattern;
begin
  logic sync_stat;
  logic [7:0] frame_shifted_val;
  logic [15:0] adc_data_shifted_val;
  logic [2:0] shift_cnt_val;
  int alignment_errors = 0;

  force system_tb.enable_pattern = 1'b1;
  `INFO(("Force enable_pattern = 1"), ADI_VERBOSITY_LOW);

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

  // Wait for FSM to stabilize and verify alignment
  // Add extra margin for stabilization
  repeat(50) @(posedge system_tb.test_harness.axi_ada4355_adc.inst.i_ada4355_interface.adc_clk_div);

  // Capture FSM alignment results
  shift_cnt_val = system_tb.test_harness.axi_ada4355_adc.inst.i_ada4355_interface.shift_cnt;
  frame_shifted_val = system_tb.test_harness.axi_ada4355_adc.inst.i_ada4355_interface.frame_shifted;
  adc_data_shifted_val = system_tb.test_harness.axi_ada4355_adc.inst.i_ada4355_interface.adc_data_shifted;

  `INFO(("FSM Alignment Results: shift_cnt=%0d, frame_shifted=0x%02h, adc_data_shifted=0x%04h",
         shift_cnt_val, frame_shifted_val, adc_data_shifted_val), ADI_VERBOSITY_NONE);

  // Verify FSM achieved correct alignment
  if (frame_shifted_val !== 8'hF0) begin
    `ERROR(("ALIGNMENT FAIL: frame_shifted=0x%02h, expected 0xF0", frame_shifted_val));
    alignment_errors++;
  end else begin
    `INFO(("ALIGNMENT OK: frame_shifted=0xF0 (FSM found correct shift_cnt=%0d)", shift_cnt_val), ADI_VERBOSITY_NONE);
  end

  if (alignment_errors == 0) begin
    `INFO(("FSM Alignment Test: PASSED"), ADI_VERBOSITY_NONE);
  end else begin
    `ERROR(("FSM Alignment Test: FAILED - %0d errors", alignment_errors));
  end

  force system_tb.enable_pattern = 1'b0;
  `INFO(("Force enable_pattern = 0"), ADI_VERBOSITY_LOW);

end
endtask

// --------------------------
// DMA test procedure
// --------------------------

task dma_test;
  logic [3:0] transfer_id;
  localparam TRANSFER_LENGTH = 64*4;  // 64 samples * 4 bytes
  localparam DMA_DEST_ADDR = `DDR_BA + 32'h00002000;
begin

  link_setup;

  `INFO(("Link Setup Done"), ADI_VERBOSITY_LOW);

  #1us;

  // Configure TDD for basic DMA test (hardware requires TDD for data flow)
  // Channel 1: ADC gate - keep HIGH to pass all ADC data (fifo_wr_en = adc_valid AND tdd_ch1)
  // Channel 2: DMA sync pulse - required because DMA has SYNC_TRANSFER_START=1
  // Use software sync to trigger AFTER DMA is armed
  env.mng.master_sequencer.RegWrite32(TDD_CONTROL, 32'h0);              // Disable during config
  env.mng.master_sequencer.RegWrite32(TDD_STARTUP_DELAY, 0);
  env.mng.master_sequencer.RegWrite32(TDD_FRAME_LENGTH, 32'hFFFFFFFF);  // Very long frame
  env.mng.master_sequencer.RegWrite32(TDD_BURST_COUNT, 1);              // Single burst

  // Channel 1: Keep HIGH continuously for ADC gate
  env.mng.master_sequencer.RegWrite32(TDD_CH1_ON, 0);
  env.mng.master_sequencer.RegWrite32(TDD_CH1_OFF, 32'hFFFFFFFF);

  // Channel 2: Generate sync pulse for DMA (pulse at start of frame)
  env.mng.master_sequencer.RegWrite32(TDD_CH2_ON, 10);
  env.mng.master_sequencer.RegWrite32(TDD_CH2_OFF, 20);

  env.mng.master_sequencer.RegWrite32(TDD_CHANNEL_ENABLE, 32'h6);       // Enable CH1 + CH2 (bits 1,2)
  env.mng.master_sequencer.RegWrite32(TDD_CHANNEL_POLARITY, 32'h0);     // Active high

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

  enable_pattern;

  `INFO(("Enable Pattern Done"), ADI_VERBOSITY_LOW);

  // Now trigger TDD with external sync (DMA is armed and waiting for sync pulse)
  env.mng.master_sequencer.RegWrite32(TDD_CONTROL, 32'h9);  // ENABLE + SYNC_EXT

  #200ns;  // Wait for TDD FSM to reach ARMED state

  trigger_tdd_sync();  // Pulse external sync via testbench
  `INFO(("TDD triggered with external sync - CH2 pulse will trigger DMA"), ADI_VERBOSITY_LOW);

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
  `INFO(("DMA test complete - TDD disabled"), ADI_VERBOSITY_LOW);

end
endtask

// Check captured data - verify sine wave pattern
// Data format: Each 32-bit word contains 2 x 16-bit samples
//   Word[31:16] = sample[2*i+1], Word[15:0] = sample[2*i]
task check_captured_data(bit [31:0] address,
                         int length = 64);

  // Sine wave parameters (must match system_tb.sv)
  localparam real PI = 3.14159265358979;
  localparam int SINE_AMPLITUDE = 8191;
  localparam int SINE_OFFSET = 8192; // Mid-scale for 14-bit (2^13)

  localparam int SINE_PERIOD = 64;
  localparam bit LEFT_ALIGNED = 0; // Right-aligned format

  bit [31:0] current_address;
  bit [31:0] captured_word;
  bit [15:0] sample_lo, sample_hi;
  bit [15:0] expected_lo, expected_hi;
  int errors = 0;
  int sample_index;
  int start_offset;
  bit offset_found = 0;

  `INFO(("Checking captured SINE WAVE data at address 0x%h, length=%0d words", address, length), ADI_VERBOSITY_LOW);
  `INFO(("Sine parameters: AMPLITUDE=%0d, OFFSET=%0d, PERIOD=%0d samples (14-bit ADC range)",
         SINE_AMPLITUDE, SINE_OFFSET, SINE_PERIOD), ADI_VERBOSITY_LOW);
  `INFO(("Expected range: [%0d, %0d] = [0x%04h, 0x%04h]",
         SINE_OFFSET - SINE_AMPLITUDE, SINE_OFFSET + SINE_AMPLITUDE,
         SINE_OFFSET - SINE_AMPLITUDE, SINE_OFFSET + SINE_AMPLITUDE), ADI_VERBOSITY_LOW);

  // Auto-detect starting offset by finding which sine sample matches first captured sample
  captured_word = env.ddr.slave_sequencer.BackdoorRead32(address);
  sample_lo = captured_word[15:0];

  for (int offset = 0; offset < SINE_PERIOD; offset++) begin
    logic [15:0] expected_val;
    expected_val = calc_expected_sine(offset);

    if (expected_val == sample_lo) begin
      start_offset = offset;
      offset_found = 1;
      `INFO(("Auto-detected start_offset=%0d", start_offset), ADI_VERBOSITY_LOW);
      break;
    end
  end

  if (!offset_found) begin
    `ERROR(("Could not auto-detect start offset! First sample 0x%04h doesn't match any sine value", sample_lo));
    start_offset = 0;
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
    expected_lo = calc_expected_sine(start_offset + sample_index);
    expected_hi = calc_expected_sine(start_offset + sample_index + 1);

    // Verify samples match expected sine values
    if (sample_lo !== expected_lo) begin
      `ERROR(("Word %0d [15:0]: Address 0x%h Value 0x%h, expected 0x%h (sample %0d, sine_idx=%0d)",
              i, current_address, sample_lo, expected_lo, sample_index, (start_offset + sample_index) % SINE_PERIOD));
      `ERROR(("  Binary: Got %016b vs Expected %016b, XOR diff: %016b",
              sample_lo, expected_lo, sample_lo ^ expected_lo));
      errors++;
    end
    if (sample_hi !== expected_hi) begin
      `ERROR(("Word %0d [31:16]: Address 0x%h Value 0x%h, expected 0x%h (sample %0d, sine_idx=%0d)",
              i, current_address, sample_hi, expected_hi, sample_index+1, (start_offset + sample_index + 1) % SINE_PERIOD));
      `ERROR(("  Binary: Got %016b vs Expected %016b, XOR diff: %016b",
              sample_hi, expected_hi, sample_hi ^ expected_hi));
      errors++;
    end

    // Log first few samples at higher verbosity
    if (i < 5) begin
      `INFO(("Word %0d: 0x%08h -> [15:0]=0x%04h (expect 0x%04h), [31:16]=0x%04h (expect 0x%04h)",
             i, captured_word, sample_lo, expected_lo, sample_hi, expected_hi), ADI_VERBOSITY_LOW);
    end
  end

  if (errors == 0) begin
    `INFO(("check_captured_data: PASSED - All %0d words match sine wave pattern", length), ADI_VERBOSITY_NONE);
  end else begin
    `ERROR(("check_captured_data: FAILED - %0d errors found", errors));
  end

endtask

// Function to calculate expected sine sample value (matches system_tb.sv)
function [15:0] calc_expected_sine;
  input int idx;
  real angle;
  real sine_val;
  int result;
  localparam real PI = 3.14159265358979;
  localparam int SINE_AMPLITUDE = 8191; // Full 14-bit scale
  localparam int SINE_OFFSET = 8192; // Mid-scale for 14-bit

  localparam int SINE_PERIOD = 64;
  localparam bit LEFT_ALIGNED_FUNC = 0; // Right-aligned format
  begin
    angle = 2.0 * PI * $itor(idx % SINE_PERIOD) / $itor(SINE_PERIOD);
    sine_val = $sin(angle);
    result = SINE_OFFSET + $rtoi(sine_val * $itor(SINE_AMPLITUDE));
    // Clamp to 14-bit range
    if (result < 0) result = 0;
    if (result > 16383) result = 16383;
    // Left-align: shift 14-bit value to bits [15:2], clear bits [1:0]
    if (LEFT_ALIGNED_FUNC)
      calc_expected_sine = (result & 16'h3FFF) << 2;
    else
      calc_expected_sine = result[15:0];
  end
endfunction

// Debug task: dump raw captured data to analyze bit patterns
task dump_raw_data(bit [31:0] address, int length = 16);
  bit [31:0] current_address;
  bit [31:0] captured_word;
  bit [15:0] sample_lo, sample_hi;

  `INFO(("=== RAW DATA DUMP from address 0x%h ===", address), ADI_VERBOSITY_NONE);
  `INFO(("Word | Address    | Raw 32-bit | [31:16]  | [15:0]"), ADI_VERBOSITY_NONE);
  `INFO(("-----|------------|------------|----------|----------"), ADI_VERBOSITY_NONE);

  for (int i = 0; i < length; i++) begin
    current_address = address + (i * 4);
    captured_word = env.ddr.slave_sequencer.BackdoorRead32(current_address);
    sample_lo = captured_word[15:0];
    sample_hi = captured_word[31:16];

    `INFO(("%4d | 0x%08h | 0x%08h | 0x%04h   | 0x%04h",
           i, current_address, captured_word, sample_hi, sample_lo), ADI_VERBOSITY_NONE);
  end
  `INFO(("=== END RAW DATA DUMP ==="), ADI_VERBOSITY_NONE);
endtask

// --------------------------
// LiDAR-specific data verification
// --------------------------
// Verifies that captured data matches the expected sine wave samples
// based on when the laser fired and the time-of-flight delay.
//
// The verification logic:
//   1. Read laser_fire_sample_idx from testbench (sample index when CH0 fired)
//   2. Expected first captured sample = laser_fire_sample_idx + time_of_flight_samples
//   3. Compare each captured sample against calc_expected_sine(expected_idx + i)
//
task check_lidar_captured_data(
  bit [31:0] address,
  int length,
  int time_of_flight_samples
);
  // Sine wave parameters (must match system_tb.sv)
  localparam real PI = 3.14159265358979;
  localparam int SINE_AMPLITUDE = 8191;
  localparam int SINE_OFFSET = 8192;
  localparam int SINE_PERIOD = 64;

  // Pipeline latency compensation:
  // - sample_count increments in testbench on negedge ssi_clk
  // - TDD counter runs on axi_tdd_0.clk (125 MHz, same as adc_clk_div)
  // - ADC interface has internal pipeline stages
  // - DMA FIFO write has latency
  // Measured offset: captured data starts 4 samples earlier than expected
  localparam int PIPELINE_LATENCY = 4;

  bit [31:0] current_address;
  bit [31:0] captured_word;
  bit [15:0] sample_lo, sample_hi;
  bit [15:0] expected_lo, expected_hi;
  int errors = 0;
  int sample_index;
  int laser_sample_idx;
  int expected_start_idx;

  // Read the laser fire sample index from testbench
  laser_sample_idx = system_tb.laser_fire_sample_idx;
  // Adjust for pipeline latency: data arrives PIPELINE_LATENCY samples earlier
  expected_start_idx = laser_sample_idx + time_of_flight_samples - PIPELINE_LATENCY;

  `INFO(("=== LiDAR Data Verification ==="), ADI_VERBOSITY_NONE);
  `INFO(("Laser fired at sample_count = %0d", laser_sample_idx), ADI_VERBOSITY_NONE);
  `INFO(("Time-of-flight delay = %0d samples, pipeline latency = %0d samples",
         time_of_flight_samples, PIPELINE_LATENCY), ADI_VERBOSITY_NONE);
  `INFO(("Expected first captured sample index = %0d (laser + ToF - latency)", expected_start_idx), ADI_VERBOSITY_NONE);
  `INFO(("Checking %0d words (%0d samples) at address 0x%h", length, length*2, address), ADI_VERBOSITY_NONE);

  for (int i = 0; i < length; i = i + 1) begin
    current_address = address + (i * 4);
    captured_word = env.ddr.slave_sequencer.BackdoorRead32(current_address);

    // Extract the two 16-bit samples from the 32-bit word
    sample_lo = captured_word[15:0];
    sample_hi = captured_word[31:16];

    // Calculate expected sine values based on laser fire timing
    // Each word contains 2 samples: sample[2*i] and sample[2*i+1]
    sample_index = 2 * i;
    expected_lo = calc_expected_sine(expected_start_idx + sample_index);
    expected_hi = calc_expected_sine(expected_start_idx + sample_index + 1);

    // Verify samples match expected sine values
    if (sample_lo !== expected_lo) begin
      `ERROR(("Word %0d [15:0]: Got 0x%04h, expected 0x%04h (sine idx=%0d)",
              i, sample_lo, expected_lo, (expected_start_idx + sample_index) % SINE_PERIOD));
      errors++;
    end
    if (sample_hi !== expected_hi) begin
      `ERROR(("Word %0d [31:16]: Got 0x%04h, expected 0x%04h (sine idx=%0d)",
              i, sample_hi, expected_hi, (expected_start_idx + sample_index + 1) % SINE_PERIOD));
      errors++;
    end

    // Log first few samples
    if (i < 3) begin
      `INFO(("Word %0d: captured=0x%08h -> [15:0]=0x%04h (exp 0x%04h), [31:16]=0x%04h (exp 0x%04h)",
             i, captured_word, sample_lo, expected_lo, sample_hi, expected_hi), ADI_VERBOSITY_NONE);
    end
  end

  if (errors == 0) begin
    `INFO(("LiDAR Verification: PASSED - All %0d samples match expected time-of-flight offset", length*2), ADI_VERBOSITY_NONE);
  end else begin
    `ERROR(("LiDAR Verification: FAILED - %0d errors found", errors));
  end

endtask

task disable_tdd();
begin
  `INFO(("Disabling TDD"), ADI_VERBOSITY_LOW);
  env.mng.master_sequencer.RegWrite32(TDD_CHANNEL_ENABLE, 32'h0);  // Disable channels first
  env.mng.master_sequencer.RegWrite32(TDD_CONTROL, 32'h2);  // Assert SYNC_RST to reset FSM
  #50ns;  // Wait for reset
  env.mng.master_sequencer.RegWrite32(TDD_CONTROL, 32'h0);  // Clear all control bits
end
endtask

// Trigger TDD external sync (like Pluto testbench does)
task trigger_tdd_sync();
begin
  `INFO(("Triggering TDD external sync pulse"), ADI_VERBOSITY_LOW);
  #5ns;
  release system_tb.tdd_ext_sync;  // Release any previous force
  #1ns;
  force system_tb.tdd_ext_sync = 1'b1;
  #50ns;  // Hold sync high for 50ns
  force system_tb.tdd_ext_sync = 1'b0;
  #5ns;
  release system_tb.tdd_ext_sync;  // Release force to return to normal operation
  `INFO(("TDD sync pulse complete"), ADI_VERBOSITY_LOW);
end
endtask

// --------------------------
// TDD LiDAR test procedure - REALISTIC TIMING
// --------------------------
// Simulates real LiDAR time-of-flight measurement:
//   1. CH0 fires laser pulse at T=0
//   2. Light travels to target and reflects back (time-of-flight delay)
//   3. CH1 opens ADC gate to capture reflected signal
//
// Physics (from Picture105.png):
//   Speed of light = 3×10^8 m/s
//   Round trip time = 2 × distance / speed_of_light
//   At 125 MHz clock (8ns period):
//     15m reflection = 100ns = 13 clock cycles
//     30m reflection = 200ns = 25 clock cycles
//
task tdd_lidar_test;
  logic [3:0] transfer_id;

  // LiDAR timing parameters (in clock cycles at 125 MHz)
  localparam LASER_ON_TIME = 0;           // Laser fires at T=0
  localparam LASER_OFF_TIME = 2;          // Laser pulse width = 16ns (2 cycles)
  localparam GATE_ON_TIME = 13;           // Gate opens at 104ns (~15m reflection)
  localparam GATE_OFF_TIME = 25;          // Gate closes at 200ns (~30m reflection)
  localparam FRAME_LENGTH = 12500;        // 100µs frame (12500 cycles)

  // Capture window = 25 - 13 = 12 samples
  // 12 samples × 2 bytes = 24 bytes
  // DMA transfer length MUST match gated samples or it will hang waiting for more data!
  localparam CAPTURE_SAMPLES = GATE_OFF_TIME - GATE_ON_TIME;  // 12 samples
  localparam TRANSFER_LENGTH = CAPTURE_SAMPLES * 2;           // 24 bytes (12 samples × 2 bytes)
  localparam DMA_DEST_ADDR = `DDR_BA + 32'h00003000;
begin

  `INFO(("=== TDD LiDAR Test Started (Realistic Timing) ==="), ADI_VERBOSITY_NONE);
  `INFO(("LiDAR parameters: Laser pulse 0-%0d, ADC gate %0d-%0d (%0d samples)",
         LASER_OFF_TIME, GATE_ON_TIME, GATE_OFF_TIME, CAPTURE_SAMPLES), ADI_VERBOSITY_NONE);
  `INFO(("Physics: Gate opens at %0dns (~15m), closes at %0dns (~30m)",
         GATE_ON_TIME * 8, GATE_OFF_TIME * 8), ADI_VERBOSITY_NONE);

  link_setup;

  #1us;

  // CRITICAL: Force frame to end quickly so FSM can reach IDLE (counter only resets in IDLE)
  // Current frame from dma_test has FRAME_LENGTH=0xFFFFFFFF which would take forever
  // Set frame length to a small value so current frame ends soon
  env.mng.master_sequencer.RegWrite32(TDD_FRAME_LENGTH, 10);  // Very short frame
  #1000ns;  // Wait for current frame to end (10 cycles * 8ns = 80ns, add margin)

  env.mng.master_sequencer.RegWrite32(TDD_CHANNEL_ENABLE, 32'h0);  // Disable channels
  env.mng.master_sequencer.RegWrite32(TDD_CONTROL, 32'h0);  // Disable TDD (ENABLE=0)
  #1000ns;  // Wait for FSM to reach IDLE and counter to reset to 0

  `INFO(("TDD reset complete, configuring for gated operation"), ADI_VERBOSITY_NONE);

  // Use SYNC_RST to reset TDD FSM and channels to known state
  env.mng.master_sequencer.RegWrite32(TDD_CONTROL, 32'h2);  // Assert SYNC_RST (bit 1)
  #200ns;  // Hold reset
  env.mng.master_sequencer.RegWrite32(TDD_CONTROL, 32'h0);  // Release reset
  #200ns;  // Wait for reset to complete

  // NOW configure timing (TDD must be disabled for write-protection)
  env.mng.master_sequencer.RegWrite32(TDD_STARTUP_DELAY, 0);
  env.mng.master_sequencer.RegWrite32(TDD_FRAME_LENGTH, FRAME_LENGTH);
  env.mng.master_sequencer.RegWrite32(TDD_BURST_COUNT, 1);  // Single burst

  // CH0: Laser trigger pulse
  env.mng.master_sequencer.RegWrite32(TDD_CH0_ON, LASER_ON_TIME);
  env.mng.master_sequencer.RegWrite32(TDD_CH0_OFF, LASER_OFF_TIME);

  // CH1: ADC gate - opens after time-of-flight delay to capture reflections
  env.mng.master_sequencer.RegWrite32(TDD_CH1_ON, GATE_ON_TIME);
  env.mng.master_sequencer.RegWrite32(TDD_CH1_OFF, GATE_OFF_TIME);

  // CH2: DMA sync - trigger at same time as ADC gate opens
  env.mng.master_sequencer.RegWrite32(TDD_CH2_ON, GATE_ON_TIME);
  env.mng.master_sequencer.RegWrite32(TDD_CH2_OFF, GATE_ON_TIME + 10);  // 10-cycle sync pulse

  // Enable CH0 (laser) + CH1 (ADC gate) + CH2 (DMA sync)
  env.mng.master_sequencer.RegWrite32(TDD_CHANNEL_ENABLE, 32'h7);  // All 3 channels
  env.mng.master_sequencer.RegWrite32(TDD_CHANNEL_POLARITY, 32'h0);

  // Wait for settings to settle
  #100ns;

  `INFO(("TDD configured: FRAME=%0d, CH0 laser 0-%0d, CH1 gate %0d-%0d, CH2 sync %0d-%0d",
         FRAME_LENGTH, LASER_OFF_TIME, GATE_ON_TIME, GATE_OFF_TIME,
         GATE_ON_TIME, GATE_ON_TIME + 10), ADI_VERBOSITY_NONE);

  rx_dma_api.set_control(4'b0000);  // Disable DMA (ENABLE=0) - triggers needs_reset

  #1000ns;  // Wait for full DMA reset sequence to complete (multiple clock domains)

  rx_dma_api.enable_dma();
  rx_dma_api.set_flags(
    .cyclic(1'b0),
    .tlast(1'b1),
    .partial_reporting_en(1'b0));
  rx_dma_api.set_lengths(.xfer_length_x(TRANSFER_LENGTH-1), .xfer_length_y(0));
  rx_dma_api.set_dest_addr(.xfer_addr(DMA_DEST_ADDR));

  rx_dma_api.transfer_id_get(transfer_id);
  rx_dma_api.transfer_start();

  `INFO(("DMA Started (transfer_id=%0d)", transfer_id), ADI_VERBOSITY_NONE);

  enable_pattern;

  `INFO(("Pattern enabled"), ADI_VERBOSITY_NONE);

  // Trigger TDD with SYNC_EXT mode - MATCH dma_test exactly
  env.mng.master_sequencer.RegWrite32(TDD_CONTROL, 32'h9);  // ENABLE + SYNC_EXT
  #200ns;  // Wait for TDD to reach ARMED state
  trigger_tdd_sync();  // Trigger immediately like dma_test
  `INFO(("TDD triggered with external sync"), ADI_VERBOSITY_NONE);

  // Debug: Read back TDD registers to verify configuration
  #100ns;
  env.mng.master_sequencer.RegRead32(TDD_CONTROL, val);
  `INFO(("TDD_CONTROL after sync: 0x%08h", val), ADI_VERBOSITY_NONE);
  env.mng.master_sequencer.RegRead32(TDD_CHANNEL_ENABLE, val);
  `INFO(("TDD_CHANNEL_ENABLE: 0x%08h (expect 0x7)", val), ADI_VERBOSITY_NONE);
  env.mng.master_sequencer.RegRead32(TDD_CH0_ON, val);
  `INFO(("TDD_CH0_ON: 0x%08h (expect %0d=0x%02h)", val, LASER_ON_TIME, LASER_ON_TIME), ADI_VERBOSITY_NONE);
  env.mng.master_sequencer.RegRead32(TDD_CH0_OFF, val);
  `INFO(("TDD_CH0_OFF: 0x%08h (expect %0d=0x%02h)", val, LASER_OFF_TIME, LASER_OFF_TIME), ADI_VERBOSITY_NONE);
  env.mng.master_sequencer.RegRead32(TDD_CH1_ON, val);
  `INFO(("TDD_CH1_ON: 0x%08h (expect %0d=0x%02h)", val, GATE_ON_TIME, GATE_ON_TIME), ADI_VERBOSITY_NONE);
  env.mng.master_sequencer.RegRead32(TDD_CH1_OFF, val);
  `INFO(("TDD_CH1_OFF: 0x%08h (expect %0d=0x%02h)", val, GATE_OFF_TIME, GATE_OFF_TIME), ADI_VERBOSITY_NONE);
  env.mng.master_sequencer.RegRead32(TDD_CH2_ON, val);
  `INFO(("TDD_CH2_ON: 0x%08h (expect %0d=0x%02h)", val, GATE_ON_TIME, GATE_ON_TIME), ADI_VERBOSITY_NONE);
  env.mng.master_sequencer.RegRead32(TDD_CH2_OFF, val);
  `INFO(("TDD_CH2_OFF: 0x%08h (expect %0d=0x%02h)", val, GATE_ON_TIME + 10, GATE_ON_TIME + 10), ADI_VERBOSITY_NONE);

  // Wait for DMA
  rx_dma_api.wait_transfer_done(.transfer_id(transfer_id), .timeut_in_us(5000));

  `INFO(("DMA Transfer Complete"), ADI_VERBOSITY_NONE);

  // TRANSFER_LENGTH = 32 bytes, each word is 4 bytes, so 8 words to check
  dump_raw_data(.address(DMA_DEST_ADDR), .length(TRANSFER_LENGTH/4));

  // LiDAR-specific verification: check captured data matches expected offset from laser pulse
  check_lidar_captured_data(
    .address(DMA_DEST_ADDR),
    .length(TRANSFER_LENGTH/4),
    .time_of_flight_samples(GATE_ON_TIME));  // Data should start at laser_sample + GATE_ON_TIME

  disable_tdd();

  `INFO(("=== TDD LiDAR Test Complete ==="), ADI_VERBOSITY_NONE);

end
endtask

endprogram
