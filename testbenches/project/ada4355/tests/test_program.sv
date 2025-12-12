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
//
//

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

  // Initialize API instances
  rx_dma_api = new(.name("RX DMA API"),
                   .bus(env.mng.master_sequencer),
                   .base_address(`ADA4355_DMA_BA));

  rx_adc_api = new(.name("RX ADC API"),
                   .bus(env.mng.master_sequencer),
                   .base_address(BASE));

  rx_common_api = new(.name("RX Common API"),
                      .bus(env.mng.master_sequencer),
                      .base_address(BASE));

  setLoggerVerbosity(ADI_VERBOSITY_NONE);
  env.start();

  // System reset
  env.sys_reset();

  sanity_test;

  dma_test;

  #1000ns;

  resync;

  // Extended delay to observe FSM stability after resync
  #5000ns;

  `INFO(("Test Done"), ADI_VERBOSITY_NONE);
  $finish;

end

// --------------------------
// Sanity test reg interface
// --------------------------

task sanity_test;
begin
  // check ADC VERSION
  env.mng.master_sequencer.RegReadVerify32(BASE + GetAddrs(COMMON_REG_VERSION),
                  `SET_COMMON_REG_VERSION_VERSION('h000a0300));

  // Run DMA sanity test
  rx_dma_api.sanity_test();

  `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
end
endtask

// --------------------------
// Setup link
// --------------------------

task link_setup;
begin

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

task ada4355_regmap;
begin
  bit [31:0] regmap_val;

  `INFO(("Inside ada4355_regmap task"), ADI_VERBOSITY_LOW);
  env.mng.master_sequencer.RegWrite32(REGMAP_ENABLE, 4);
  `INFO(("After write ada4355_regmap task"), ADI_VERBOSITY_LOW);
  env.mng.master_sequencer.RegRead32(REGMAP_ENABLE, regmap_val);
  `INFO(("Regmap Value 0x%h", regmap_val), ADI_VERBOSITY_LOW);
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

endprogram
