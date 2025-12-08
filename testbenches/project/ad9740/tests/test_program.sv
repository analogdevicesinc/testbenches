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
//
// Unified Data Path Validation Test for AD974x DAC Family
// Supports: AD9748 (8-bit), AD9740 (10-bit), AD9742 (12-bit), AD9744 (14-bit)
//
// The DEVICE parameter is set via cfg file and passed to system_bd.tcl which
// configures the DAC_RESOLUTION in the axi_ad974x IP. This test uses +DEVICE
// plusarg to determine the resolution for verification.
//
// ***************************************************************************

`include "utils.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_dmac_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

//---------------------------------------------------------------------------
// Unified Data Path Validation Test Program
//---------------------------------------------------------------------------

program test_program (
  input  wire        ad974x_clk,
  input  wire [13:0] ad974x_data
);

timeunit 1ns;
timeprecision 100ps;

// Base addresses
localparam AD974X_DMA_BA = 32'h44A40000;
localparam AD974X_DAC_BA = 32'h44A70000;
localparam DDR_BASE      = 32'h80000000;

// AD974x register offsets
localparam REG_VERSION      = 32'h000;
localparam REG_ID           = 32'h004;
localparam REG_SCRATCH      = 32'h008;
localparam REG_RSTN         = 32'h040;
localparam REG_CNTRL_1      = 32'h044;
localparam REG_CNTRL_2      = 32'h048;
localparam REG_RATECNTRL    = 32'h04C;
localparam REG_CLK_FREQ     = 32'h054;
localparam REG_CLK_RATIO    = 32'h058;
localparam REG_STATUS       = 32'h05C;
localparam REG_CHAN_CNTRL_1 = 32'h400;
localparam REG_CHAN_CNTRL_2 = 32'h404;
localparam REG_CHAN_CNTRL_3 = 32'h408;
localparam REG_CHAN_CNTRL_4 = 32'h40C;
localparam REG_CHAN_CNTRL_5 = 32'h410;
localparam REG_CHAN_CNTRL_6 = 32'h414;
localparam REG_CHAN_CNTRL_7 = 32'h418;

// DMAC register offsets
localparam DMAC_REG_CONTROL        = 32'h400;
localparam DMAC_REG_TRANSFER_ID    = 32'h404;
localparam DMAC_REG_TRANSFER_SUBMIT = 32'h408;
localparam DMAC_REG_FLAGS          = 32'h40C;
localparam DMAC_REG_DEST_ADDRESS   = 32'h410;
localparam DMAC_REG_SRC_ADDRESS    = 32'h414;
localparam DMAC_REG_X_LENGTH       = 32'h418;
localparam DMAC_REG_Y_LENGTH       = 32'h41C;
localparam DMAC_REG_DEST_STRIDE    = 32'h420;
localparam DMAC_REG_SRC_STRIDE     = 32'h424;
localparam DMAC_REG_TRANSFER_DONE  = 32'h428;

// Data source selection values (REG_CHAN_CNTRL_7[3:0])
localparam DATA_SEL_DDS     = 4'h0;
localparam DATA_SEL_SED     = 4'h1;
localparam DATA_SEL_DMA     = 4'h2;
localparam DATA_SEL_ZERO    = 4'h3;
localparam DATA_SEL_RAMP    = 4'hB;

// Test parameters
localparam TEST_SAMPLES   = 1024;
localparam TOLERANCE      = 2;

// Capture samples scaled by resolution (more samples for higher resolution DACs)
// AD9748: 256, AD9740: 256, AD9742: 512, AD9744: 1024
bit [15:0] verify_samples;

// Ramp capture samples - needs to be large enough to see full scale ramp cycle
// Set to max_dac_value + margin to capture at least one full ramp cycle
bit [15:0] ramp_capture_samples;

test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

// Device identifiers - used for case matching with DEVICE define
localparam AD9748 = 0;
localparam AD9740 = 1;
localparam AD9742 = 2;
localparam AD9744 = 3;

// Runtime parameters - determined from DEVICE define set by cfg file
bit [3:0]  dac_resolution;
bit [15:0] max_dac_value;
bit [3:0]  dma_shift;
bit [3:0]  internal_shift;
string device_name;
string data_format_name;

// Data arrays
bit [15:0] dma_data[TEST_SAMPLES];
bit [13:0] captured_data[$];
bit [15:0] errors = 0;

// --------------------------
// AXI helper tasks
// --------------------------
task axi_write(input [31:0] addr, input [31:0] data);
  base_env.mng.sequencer.RegWrite32(addr, data);
endtask

task axi_read(input [31:0] addr, output [31:0] data);
  base_env.mng.sequencer.RegRead32(addr, data);
endtask

// --------------------------
// Determine DAC resolution from DEVICE define
// --------------------------
task determine_dac_config();
  // Use DEVICE define from cfg file (set via adi_sim_add_define)
  // DEVICE expands to bare identifier (e.g., AD9740) which matches localparam
  case (`DEVICE)
    AD9748: begin
      dac_resolution = 8;
      max_dac_value = 255;
      dma_shift = 8;
      internal_shift = 6;
      verify_samples = 256;
      ramp_capture_samples = 320;  // 256 + margin for full 8-bit ramp cycle
      device_name = "AD9748";
    end
    AD9740: begin
      dac_resolution = 10;
      max_dac_value = 1023;
      dma_shift = 6;
      internal_shift = 4;
      verify_samples = 256;
      ramp_capture_samples = 1100;  // 1024 + margin for full 10-bit ramp cycle
      device_name = "AD9740";
    end
    AD9742: begin
      dac_resolution = 12;
      max_dac_value = 4095;
      dma_shift = 4;
      internal_shift = 2;
      verify_samples = 512;
      ramp_capture_samples = 4200;  // 4096 + margin for full 12-bit ramp cycle
      device_name = "AD9742";
    end
    default: begin
      dac_resolution = 14;
      max_dac_value = 16383;
      dma_shift = 0;  // 14-bit DAC uses lower 14 bits directly, no shift needed
      internal_shift = 0;
      verify_samples = 1024;
      ramp_capture_samples = 16500;  // 16384 + margin for full 14-bit ramp cycle
      device_name = "AD9744";
    end
  endcase

  // Set data format name based on DAC_DATAFMT define from cfg file
  // DAC_DATAFMT=0: unsigned, DAC_DATAFMT=1: signed (two's complement)
  if (`DAC_DATAFMT == 1) begin
    data_format_name = "signed";
  end else begin
    data_format_name = "unsigned";
  end
endtask

// --------------------------
// Generate ramp pattern for DMA (MSB-aligned)
// --------------------------
task generate_ramp_pattern();
  `INFO(($sformatf("Generating %s ramp pattern for DMA test", data_format_name)), ADI_VERBOSITY_NONE);
  for (int i = 0; i < TEST_SAMPLES; i++) begin
    automatic int dac_val;
    // Scale ramp to full range: sample 0 = min, sample (TEST_SAMPLES-1) = max
    automatic real scale = real'(i) / real'(TEST_SAMPLES - 1);
    if (`DAC_DATAFMT == 1) begin
      // Signed mode: full scale ramp from -half_max to +half_max-1
      automatic int half_max = (max_dac_value + 1) / 2;
      automatic int signed_val = int'(scale * max_dac_value) - half_max;
      dac_val = signed_val & max_dac_value;  // Mask to proper width (two's complement)
    end else begin
      // Unsigned mode: full scale ramp from 0 to max_dac_value
      dac_val = int'(scale * max_dac_value);
    end
    dma_data[i] = dac_val << dma_shift;
  end
endtask

// --------------------------
// Generate sine pattern for DMA (MSB-aligned)
// --------------------------
task generate_sine_pattern();
  `INFO(($sformatf("Generating %s sine pattern for DMA test", data_format_name)), ADI_VERBOSITY_NONE);
  for (int i = 0; i < TEST_SAMPLES; i++) begin
    automatic real phase = 2.0 * 3.14159265 * i / 64.0;
    automatic int dac_val;
    if (`DAC_DATAFMT == 1) begin
      // Signed mode: full scale sine
      // Range: -(half_max) to +(half_max-1) for full signed range
      automatic int half_max = (max_dac_value + 1) / 2;
      automatic int signed_val = int'($sin(phase) * (half_max - 1));
      dac_val = signed_val & max_dac_value;  // Mask to proper width (two's complement)
    end else begin
      // Unsigned mode: full scale sine from 0 to max_dac_value
      automatic real sine_val = ($sin(phase) + 1.0) / 2.0;
      dac_val = int'(sine_val * max_dac_value);
    end
    // DMA data: place dac_val in upper bits of 16-bit word (MSB-aligned)
    // The DAC extracts bits based on resolution
    dma_data[i] = dac_val << dma_shift;
  end
endtask

// --------------------------
// Write test data to DDR
// --------------------------
task write_dma_data_to_ddr();
  bit [31:0] data32;
  `INFO(($sformatf("Writing %0d samples to DDR at 0x%08x", TEST_SAMPLES, DDR_BASE)), ADI_VERBOSITY_NONE);
  for (int i = 0; i < TEST_SAMPLES; i += 2) begin
    data32 = {dma_data[i+1], dma_data[i]};
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(DDR_BASE + i*2, data32, 4'hF);
  end
endtask

// --------------------------
// Initialize DAC
// --------------------------
task init_dac();
  bit [31:0] regval;

  `INFO(($sformatf("Initializing DAC (data format: %s)", data_format_name)), ADI_VERBOSITY_NONE);

  // Reset sequence
  axi_write(AD974X_DAC_BA + REG_RSTN, 32'h0);
  #500ns;
  axi_write(AD974X_DAC_BA + REG_RSTN, 32'h3);
  #500ns;

  // For DMA/RAMP modes, set dac_datafmt=0 (no conversion)
  // The data format (signed/unsigned) is determined by DMA data, passed through as-is
  // DDS mode will set dac_datafmt=1 separately since CORDIC outputs signed data
  axi_write(AD974X_DAC_BA + REG_CNTRL_2, 32'h00000000);  // dac_datafmt = 0 (pass-through)

  // Read version
  axi_read(AD974X_DAC_BA + REG_VERSION, regval);
  `INFO(($sformatf("DAC Version: 0x%08x", regval)), ADI_VERBOSITY_NONE);
endtask

// --------------------------
// Configure DAC data source
// --------------------------
task set_data_source(input [3:0] source);
  case (source)
    DATA_SEL_DDS:  `INFO(("Setting data source: DDS"), ADI_VERBOSITY_NONE);
    DATA_SEL_DMA:  `INFO(("Setting data source: DMA"), ADI_VERBOSITY_NONE);
    DATA_SEL_RAMP: `INFO(("Setting data source: RAMP"), ADI_VERBOSITY_NONE);
    DATA_SEL_ZERO: `INFO(("Setting data source: ZERO"), ADI_VERBOSITY_NONE);
    default:       `INFO(($sformatf("Setting data source: 0x%x", source)), ADI_VERBOSITY_NONE);
  endcase

  // Write data source selection to REG_CHAN_CNTRL_7 (0x418)
  // Only bits [3:0] are used for dac_data_sel, write directly to avoid X values from read
  axi_write(AD974X_DAC_BA + REG_CHAN_CNTRL_7, {28'h0, source});

  // Wait for CDC (up_xfer_cntrl) to propagate the new data_sel to DAC clock domain
  #2us;
endtask

// --------------------------
// Start DMA transfer
// --------------------------
task start_dma_transfer(input [31:0] src_addr, input [31:0] length);
  `INFO(($sformatf("Starting DMA: src=0x%08x, len=%0d bytes", src_addr, length)), ADI_VERBOSITY_NONE);

  axi_write(AD974X_DMA_BA + DMAC_REG_CONTROL, 32'h0);
  axi_write(AD974X_DMA_BA + DMAC_REG_CONTROL, 32'h1);
  axi_write(AD974X_DMA_BA + DMAC_REG_FLAGS, 32'h1);
  axi_write(AD974X_DMA_BA + DMAC_REG_SRC_ADDRESS, src_addr);
  axi_write(AD974X_DMA_BA + DMAC_REG_X_LENGTH, length - 1);
  axi_write(AD974X_DMA_BA + DMAC_REG_Y_LENGTH, 32'h0);
  axi_write(AD974X_DMA_BA + DMAC_REG_TRANSFER_SUBMIT, 32'h1);
endtask

// --------------------------
// Capture DAC output
// --------------------------
task capture_dac_output(input bit [15:0] num_samples);
  captured_data.delete();
  `INFO(($sformatf("Capturing %0d DAC output samples", num_samples)), ADI_VERBOSITY_NONE);

  for (int i = 0; i < num_samples; i++) begin
    @(posedge ad974x_clk);
    captured_data.push_back(ad974x_data);
  end
endtask

// --------------------------
// Verify DMA data path
// --------------------------
task verify_dma_datapath();
  automatic bit [15:0] expected_14bit, actual_14bit;
  automatic bit [15:0] expected_dac, actual_dac;
  automatic bit [15:0] local_errors = 0;

  `INFO(("Verifying DMA data path..."), ADI_VERBOSITY_NONE);

  if (captured_data.size() < verify_samples) begin
    `INFO(($sformatf("ERROR: Insufficient samples: %0d < %0d", captured_data.size(), verify_samples)), ADI_VERBOSITY_NONE);
    errors++;
    return;
  end

  for (int i = 8; i < verify_samples && i < captured_data.size(); i++) begin
    // Calculate expected: MSB-aligned DMA data
    // DMA data is MSB-aligned in 16-bit word, we extract and shift to 14-bit bus position
    // Use shift operations instead of variable-width part-select (which requires constants)
    expected_14bit = (dma_data[(i-8) % TEST_SAMPLES] >> dma_shift) << internal_shift;
    actual_14bit = captured_data[i];

    expected_dac = expected_14bit >> internal_shift;
    actual_dac = actual_14bit >> internal_shift;

    if (i < 16) begin
      `INFO(($sformatf("  [%3d]: DMA=0x%04x -> Exp=0x%04x, Act=0x%04x (DAC: %03x vs %03x)",
                       i, dma_data[(i-8) % TEST_SAMPLES], expected_14bit, actual_14bit,
                       expected_dac, actual_dac)), ADI_VERBOSITY_NONE);
    end

    if ((actual_dac > expected_dac ? actual_dac - expected_dac : expected_dac - actual_dac) > TOLERANCE) begin
      local_errors++;
      if (local_errors <= 5) begin
        `INFO(($sformatf("  MISMATCH [%3d]: Exp=0x%03x, Act=0x%03x", i, expected_dac, actual_dac)), ADI_VERBOSITY_NONE);
      end
    end
  end

  errors += local_errors;
  if (local_errors == 0) begin
    `INFO(("DMA data path: PASSED"), ADI_VERBOSITY_NONE);
  end else begin
    `INFO(($sformatf("DMA data path: FAILED (%0d errors)", local_errors)), ADI_VERBOSITY_NONE);
  end
endtask

// --------------------------
// Verify RAMP mode data path
// --------------------------
task verify_ramp_datapath();
  automatic bit [15:0] actual_dac, prev_dac;
  automatic bit [15:0] local_errors = 0;
  automatic bit [15:0] valid_transitions = 0;
  automatic bit [15:0] check_samples;
  automatic bit [15:0] max_val_seen = 0;
  automatic bit [15:0] min_val_seen = max_dac_value;

  `INFO(("Verifying RAMP data path..."), ADI_VERBOSITY_NONE);

  check_samples = ramp_capture_samples;
  if (captured_data.size() < check_samples) begin
    `INFO(($sformatf("ERROR: Insufficient samples: %0d < %0d", captured_data.size(), check_samples)), ADI_VERBOSITY_NONE);
    errors++;
    return;
  end

  for (int i = 1; i < check_samples && i < captured_data.size(); i++) begin
    actual_dac = captured_data[i] >> internal_shift;
    prev_dac = captured_data[i-1] >> internal_shift;

    // Track min/max values seen
    if (actual_dac > max_val_seen) max_val_seen = actual_dac;
    if (actual_dac < min_val_seen) min_val_seen = actual_dac;

    if (i < 10) begin
      `INFO(($sformatf("  Ramp[%3d]: 0x%03x (14-bit: 0x%04x)", i, actual_dac, captured_data[i])), ADI_VERBOSITY_NONE);
    end

    // Valid ramp: increment by 1 or wrap
    if (actual_dac == prev_dac + 1 || (prev_dac == max_dac_value && actual_dac == 0)) begin
      valid_transitions++;
    end else if (actual_dac != prev_dac && i > 4) begin
      local_errors++;
      if (local_errors <= 5) begin
        `INFO(($sformatf("  RAMP ERROR [%3d]: prev=0x%03x, curr=0x%03x", i, prev_dac, actual_dac)), ADI_VERBOSITY_NONE);
      end
    end
  end

  `INFO(($sformatf("  Ramp range: min=0x%03x, max=0x%03x (expected max=0x%03x)", min_val_seen, max_val_seen, max_dac_value)), ADI_VERBOSITY_NONE);

  errors += local_errors;
  if (local_errors == 0 && valid_transitions > check_samples/2) begin
    `INFO(($sformatf("RAMP data path: PASSED (%0d valid transitions)", valid_transitions)), ADI_VERBOSITY_NONE);
  end else begin
    `INFO(($sformatf("RAMP data path: FAILED (%0d errors, %0d valid)", local_errors, valid_transitions)), ADI_VERBOSITY_NONE);
  end
endtask

// --------------------------
// Test DDS mode
// --------------------------
task test_dds_mode();
  automatic bit [15:0] nonzero_samples = 0;

  `INFO(("Testing DDS mode..."), ADI_VERBOSITY_NONE);

  // Follow jesd_loopback pattern: configure DDS BEFORE releasing reset
  // 1. Put DAC in reset
  // 2. Configure DDS parameters
  // 3. Select DDS as data source
  // 4. Release reset
  // 5. Sync DDS cores

  // Step 1: Put DAC in reset
  axi_write(AD974X_DAC_BA + REG_RSTN, 32'h0);
  #100ns;

  // Configure tone 1: scale=0x4000 (half scale), freq_word=0x0100, init_phase=0
  axi_write(AD974X_DAC_BA + REG_CHAN_CNTRL_1, 32'h00004000);  // scale_1 = 0x4000 (half scale)
  axi_write(AD974X_DAC_BA + REG_CHAN_CNTRL_2, 32'h00000100);  // init_1=0, incr_1=0x0100

  // Disable tone 2 (scale=0)
  axi_write(AD974X_DAC_BA + REG_CHAN_CNTRL_3, 32'h00000000);  // scale_2 = 0
  axi_write(AD974X_DAC_BA + REG_CHAN_CNTRL_4, 32'h00000000);  // init_2=0, incr_2=0

  // Step 3: Select DDS as data source (data_sel = 0)
  axi_write(AD974X_DAC_BA + REG_CHAN_CNTRL_7, 32'h00000000);  // data_sel = 0 (DDS)

  // Step 3b: Set data format for DDS based on DAC_DATAFMT
  // CORDIC/DDS always outputs signed (two's complement) data
  // - DAC_DATAFMT=0 (unsigned mode): set dac_datafmt=1 to convert signed->unsigned
  // - DAC_DATAFMT=1 (signed mode): set dac_datafmt=0, no conversion needed
  if (`DAC_DATAFMT == 1) begin
    axi_write(AD974X_DAC_BA + REG_CNTRL_2, 32'h00000000);  // dac_datafmt = 0 (pass-through signed)
  end else begin
    axi_write(AD974X_DAC_BA + REG_CNTRL_2, 32'h00000010);  // dac_datafmt = 1 (convert to unsigned)
  end

  // Step 4: Release reset
  axi_write(AD974X_DAC_BA + REG_RSTN, 32'h3);
  #100ns;

  // Step 5: Sync DDS cores
  axi_write(AD974X_DAC_BA + REG_CNTRL_1, 32'h1);  // sync = 1
  #1us;

  capture_dac_output(256);

  for (int i = 0; i < captured_data.size(); i++) begin
    if (captured_data[i] != 0) nonzero_samples++;
  end

  if (nonzero_samples > captured_data.size() / 2) begin
    `INFO(($sformatf("DDS mode: PASSED (%0d/%0d non-zero)", nonzero_samples, captured_data.size())), ADI_VERBOSITY_NONE);
  end else begin
    `INFO(($sformatf("DDS mode: FAILED (%0d/%0d non-zero)", nonzero_samples, captured_data.size())), ADI_VERBOSITY_NONE);
    errors++;
  end
endtask

// --------------------------
// Main test sequence
// --------------------------
initial begin

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

  // Determine DAC configuration from DEVICE plusarg
  determine_dac_config();

  #1us;

  `INFO(("=========================================================="), ADI_VERBOSITY_NONE);
  `INFO(($sformatf("  AD974x Data Path Validation - %s (%0d-bit, %s)", device_name, dac_resolution, data_format_name)), ADI_VERBOSITY_NONE);
  `INFO(("=========================================================="), ADI_VERBOSITY_NONE);
  `INFO(($sformatf("  MAX_DAC_VALUE    = %0d (0x%x)", max_dac_value, max_dac_value)), ADI_VERBOSITY_NONE);
  `INFO(($sformatf("  DMA_SHIFT        = %0d", dma_shift)), ADI_VERBOSITY_NONE);
  `INFO(($sformatf("  INTERNAL_SHIFT   = %0d", internal_shift)), ADI_VERBOSITY_NONE);
  `INFO(($sformatf("  VERIFY_SAMPLES   = %0d", verify_samples)), ADI_VERBOSITY_NONE);
  `INFO(($sformatf("  RAMP_CAPTURE     = %0d", ramp_capture_samples)), ADI_VERBOSITY_NONE);
  `INFO(($sformatf("  DATA_FORMAT      = %s", data_format_name)), ADI_VERBOSITY_NONE);
  `INFO(("=========================================================="), ADI_VERBOSITY_NONE);

  init_dac();

  //-------------------------------------------
  // Test 1: RAMP mode (internal counter)
  //-------------------------------------------
  `INFO((""), ADI_VERBOSITY_NONE);
  `INFO(("----------------------------------------------------------"), ADI_VERBOSITY_NONE);
  `INFO(("  TEST 1: Internal RAMP Generator"), ADI_VERBOSITY_NONE);
  `INFO(("----------------------------------------------------------"), ADI_VERBOSITY_NONE);

  set_data_source(DATA_SEL_RAMP);
  #5us;  // Allow ramp generator to stabilize
  capture_dac_output(ramp_capture_samples);
  verify_ramp_datapath();

  //-------------------------------------------
  // Test 2: DMA mode with ramp pattern
  //-------------------------------------------
  `INFO((""), ADI_VERBOSITY_NONE);
  `INFO(("----------------------------------------------------------"), ADI_VERBOSITY_NONE);
  `INFO(("  TEST 2: DMA Mode - Ramp Pattern"), ADI_VERBOSITY_NONE);
  `INFO(("----------------------------------------------------------"), ADI_VERBOSITY_NONE);

  generate_ramp_pattern();
  write_dma_data_to_ddr();
  set_data_source(DATA_SEL_DMA);
  start_dma_transfer(DDR_BASE, TEST_SAMPLES * 2);
  #8us;  // Wait for DMA pipeline to fill
  capture_dac_output(verify_samples + 16);
  verify_dma_datapath();

  //-------------------------------------------
  // Test 3: DMA mode with sine pattern
  //-------------------------------------------
  `INFO((""), ADI_VERBOSITY_NONE);
  `INFO(("----------------------------------------------------------"), ADI_VERBOSITY_NONE);
  `INFO(("  TEST 3: DMA Mode - Sine Pattern"), ADI_VERBOSITY_NONE);
  `INFO(("----------------------------------------------------------"), ADI_VERBOSITY_NONE);

  generate_sine_pattern();

  // Debug: print first 64 generated DMA sine samples
  `INFO(("Generated DMA sine samples (first 64):"), ADI_VERBOSITY_NONE);
  for (int i = 0; i < 64; i++) begin
    `INFO(($sformatf("  DMA[%2d]: 0x%04x (%0d)", i, dma_data[i], dma_data[i])), ADI_VERBOSITY_NONE);
  end

  write_dma_data_to_ddr();
  start_dma_transfer(DDR_BASE, TEST_SAMPLES * 2);
  #15us;  // Wait longer for DMA pipeline to fill (scaled for larger captures)
  capture_dac_output(verify_samples + 16);

  // Debug: print first 64 captured sine samples
  `INFO(("Captured sine samples (first 64):"), ADI_VERBOSITY_NONE);
  for (int i = 0; i < 64 && i < captured_data.size(); i++) begin
    `INFO(($sformatf("  SINE[%2d]: 0x%04x (%0d)", i, captured_data[i], captured_data[i])), ADI_VERBOSITY_NONE);
  end

  verify_dma_datapath();

  //-------------------------------------------
  // Test 4: DDS mode
  //-------------------------------------------
  `INFO((""), ADI_VERBOSITY_NONE);
  `INFO(("----------------------------------------------------------"), ADI_VERBOSITY_NONE);
  `INFO(("  TEST 4: DDS Mode"), ADI_VERBOSITY_NONE);
  `INFO(("----------------------------------------------------------"), ADI_VERBOSITY_NONE);

  test_dds_mode();

  //-------------------------------------------
  // Final Summary
  //-------------------------------------------
  `INFO((""), ADI_VERBOSITY_NONE);
  `INFO(("=========================================================="), ADI_VERBOSITY_NONE);
  if (errors == 0) begin
    `INFO(($sformatf("  %s (%s) DATA PATH VALIDATION: ALL TESTS PASSED", device_name, data_format_name)), ADI_VERBOSITY_NONE);
  end else begin
    `INFO(($sformatf("  %s (%s) DATA PATH VALIDATION: FAILED (%0d errors)", device_name, data_format_name, errors)), ADI_VERBOSITY_NONE);
  end
  `INFO(("=========================================================="), ADI_VERBOSITY_NONE);

//  base_env.stop();
  $finish();
end

endprogram
