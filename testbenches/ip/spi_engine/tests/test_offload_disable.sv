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
//
// Test: Offload Disable Edge Cases
// This test verifies the SPI Engine offload module behavior when the offload
// disable command arrives under non-ideal conditions.
//

`include "utils.svh"
`include "axi_definitions.svh"
`include "axis_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import spi_environment_pkg::*;
import axi4stream_vip_pkg::*;
import spi_engine_api_pkg::*;
import dmac_api_pkg::*;
import pwm_gen_api_pkg::*;
import clk_gen_api_pkg::*;
import spi_engine_instr_pkg::*;
import adi_spi_vip_pkg::*;
import axi_vip_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

//---------------------------------------------------------------------------
// Test parameters
//---------------------------------------------------------------------------

// base test parameters
localparam TEST1_NUM_XFERS      = 2;     // Transfers per trigger (will go on the same offload program/sdo fifo mem, make sure DUT is parametrized to fit)
localparam TEST1_SLEEP_PARAM    = 254;   // SLEEP parameter (max for reliable mid-program disable window)

localparam TEST2_CS_DELAY       = 2'h3; // CS deassert delay for stressing transfer-to-CS transitions

localparam TEST3_ITERATIONS     = 3;
localparam TEST3_MIN_TRANSFERS  = 4;

localparam TEST4_SLEEP_PARAM    = 254;
localparam TEST4_SLEEP_CYCLES   = 2 + (TEST4_SLEEP_PARAM + 1) * (`CLOCK_DIVIDER + 1) * 2;
localparam PWM_PERIOD_TEST4     = (TEST4_SLEEP_CYCLES + 100) * 2;
localparam TEST4_SYNC_TIMEOUT_NS = PWM_PERIOD_TEST4 * 3 * 10;

// Derived minimum requirements
localparam TEST2_TRANSFERS      = (`NUM_OF_TRANSFERS > 1) ? `NUM_OF_TRANSFERS : 2;
localparam TEST2_DATA_TRANSFERS = TEST2_TRANSFERS - 1; // at least one data transfer, always less than total number of SPI transfers to ensure backpressure
localparam TEST3_TRANSFERS      = (`NUM_OF_TRANSFERS > TEST3_MIN_TRANSFERS) ? `NUM_OF_TRANSFERS : TEST3_MIN_TRANSFERS;

// Bytes per word based on DATA_WIDTH
localparam BYTES_PER_WORD = (`DATA_WIDTH / 8);

// PWM period calculation based on SPI timing parameters
// Base period: enough time for one complete SPI transaction
// Formula: DATA_DLENGTH bits * (CLOCK_DIVIDER + 1) * 2 (for full SCLK cycle) + overhead
localparam PWM_BASE_PERIOD = (`DATA_DLENGTH * `NUM_OF_WORDS * (`CLOCK_DIVIDER + 1) * 2) + 100;
localparam PWM_PERIOD_NORMAL = PWM_BASE_PERIOD * 2;         // 2x margin for normal tests
localparam PWM_PERIOD_NO_TRIGGER = PWM_BASE_PERIOD * 1000; // Very long period to prevent any trigger

// Test 1: specific PWM period (multi-transfer offload program with SLEEP between transfers)
localparam TEST1_SLEEP_CYCLES = 2 + (TEST1_SLEEP_PARAM + 1) * (`CLOCK_DIVIDER + 1) * 2;
localparam PWM_PERIOD_TEST1 = (PWM_BASE_PERIOD * TEST1_NUM_XFERS + TEST1_SLEEP_CYCLES) * 2;

program test_offload_disable (
  inout spi_engine_irq,
  inout spi_engine_spi_sclk,
  inout [(`NUM_OF_CS - 1):0] spi_engine_spi_cs,
  inout spi_engine_spi_clk,
  `ifdef DEF_ECHO_SCLK
    output reg spi_engine_echo_sclk,
  `endif
  inout [(`NUM_OF_MISO - 1):0] spi_engine_spi_sdi);

  timeunit 1ns;
  timeprecision 100ps;

  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  spi_environment spi_env;
  spi_engine_api spi_api;
  dmac_api dma_api;
  pwm_gen_api pwm_api;
  clk_gen_api clkgen_api;

  // Probe offload internal signals (Test 4)
  wire last_cmd_probe;
  wire spi_active_probe;
  assign last_cmd_probe   = `TH.spi_engine.spi_engine_offload.inst.last_cmd;
  assign spi_active_probe = `TH.spi_engine.spi_engine_offload.inst.spi_active;

  bit   [              7:0]  sdi_lane_mask;
  bit   [              7:0]  sdo_lane_mask;
  bit   [`DATA_DLENGTH-1:0]  rx_data [];
  bit   [`DATA_DLENGTH-1:0]  tx_data [];
  int unsigned               tx_data_cast [];
  int unsigned               receive_data [];

  // --------------------------
  // Wrapper function for SPI receive (from DUT)
  // --------------------------
  task automatic spi_receive(
      ref int unsigned data[]);
    spi_env.spi_agent.sequencer.receive_data(data);
  endtask

  // --------------------------
  // Wrapper function for SPI send (to DUT)
  // --------------------------
  task spi_send(
      input [`DATA_DLENGTH-1:0] data[]);
    spi_env.spi_agent.sequencer.send_data(data);
  endtask

  // --------------------------
  // Wrapper function for waiting for all SPI
  // --------------------------
  task spi_wait_send();
    spi_env.spi_agent.sequencer.flush_send();
  endtask

  task spi_discard_mosi();
    spi_env.spi_agent.sequencer.flush_receive();
  endtask

  // --------------------------
  // Main procedure
  // --------------------------
  initial begin

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

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

    spi_env = new("SPI Engine Environment",
                  `ifdef DEF_SDO_STREAMING
                    `TH.`SDO_SRC.inst.IF,
                  `endif
                  `TH.`SPI_S.inst.IF.vif);

    spi_api = new("SPI Engine API",
                  base_env.mng.master_sequencer,
                  `SPI_ENGINE_SPI_REGMAP_BA);

    dma_api = new("RX DMA API",
                  base_env.mng.master_sequencer,
                  `SPI_ENGINE_DMA_BA);

    clkgen_api = new("CLKGEN API",
                    base_env.mng.master_sequencer,
                    `SPI_ENGINE_AXI_CLKGEN_BA);

    pwm_api = new("PWM API",
                  base_env.mng.master_sequencer,
                  `SPI_ENGINE_PWM_GEN_BA);

    base_env.start();
    spi_env.start();

    base_env.sys_reset();

    spi_env.configure();

    spi_env.spi_agent.sequencer.set_default_miso_data('h2AA55);

    `ifdef DEF_SDO_STREAMING
      spi_env.sdo_src_agent.master_sequencer.start();
    `endif

    sanity_tests();

    init();

    #100ns;

    test_early_offload_disable();

    #100ns;

    test_disable_during_backpressure();

    #100ns;

    test_rapid_enable_disable();

    #100ns;

    test_short_program_completion();

    spi_env.stop();
    base_env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  //---------------------------------------------------------------------------
  // IRQ handling
  //---------------------------------------------------------------------------

  reg [4:0] irq_pending = 0;
  reg [7:0] sync_id = 0;
  int offload_sync_count = 0;

  initial begin
    forever begin
      @(posedge spi_engine_irq);
      // read pending IRQs
      spi_api.get_irq_pending(irq_pending);
      // IRQ launched by Offload SYNC command
      if (spi_api.check_irq_offload_sync_id_pending(irq_pending)) begin
        spi_api.get_offload_sync_id(sync_id);
        offload_sync_count++;
        `INFO(("Offload SYNC %d IRQ. Count: %d", sync_id, offload_sync_count), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by SYNC command
      if (spi_api.check_irq_sync_event(irq_pending)) begin
        spi_api.get_sync_id(sync_id);
        `INFO(("SYNC %d IRQ. FIFO transfer just finished.", sync_id), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by SDI FIFO
      if (spi_api.check_irq_sdi_almost_full(irq_pending)) begin
        `INFO(("SDI FIFO IRQ."), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by SDO FIFO
      if (spi_api.check_irq_sdo_almost_empty(irq_pending)) begin
        `INFO(("SDO FIFO IRQ."), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by CMD FIFO
      if (spi_api.check_irq_cmd_almost_empty(irq_pending)) begin
        `INFO(("CMD FIFO IRQ."), ADI_VERBOSITY_LOW);
      end
      // Clear all pending IRQs
      spi_api.clear_irq_pending(irq_pending);
    end
  end

  //---------------------------------------------------------------------------
  // Echo SCLK generation
  //---------------------------------------------------------------------------
  `ifdef DEF_ECHO_SCLK
    initial begin
      forever @(spi_engine_spi_sclk) begin
        spi_engine_echo_sclk <= #(`ECHO_SCLK_DELAY * 1ns) spi_engine_spi_sclk;
      end
    end
  `endif

  //---------------------------------------------------------------------------
  // Sanity Tests
  //---------------------------------------------------------------------------
  task sanity_tests();
    spi_api.sanity_test();
    dma_api.sanity_test();
    pwm_api.sanity_test();
  endtask

  //---------------------------------------------------------------------------
  // Test initialization
  //---------------------------------------------------------------------------
  task init();
    clkgen_api.enable_clkgen();
    spi_api.enable_spi_engine();

    // Configure the execution module
    spi_api.fifo_command(`INST_CFG);
    spi_api.fifo_command(`INST_PRESCALE);
    spi_api.fifo_command(`INST_DLENGTH);
    if (`CS_ACTIVE_HIGH) begin
      spi_api.fifo_command(`SET_CS_INV_MASK(8'hFF));
    end

    sdi_lane_mask = (2 ** `NUM_OF_MISO) - 1;
    sdo_lane_mask = (2 ** `NUM_OF_MOSI) - 1;
    spi_api.fifo_command(`SET_SDI_LANE_MASK(sdi_lane_mask));
    spi_api.fifo_command(`SET_SDO_LANE_MASK(sdo_lane_mask));

    spi_api.set_interrup_mask(.sync_event(1'b1), .offload_sync_id_pending(1'b1));
  endtask

  //---------------------------------------------------------------------------
  // Helper: Reset offload memory and DMA between tests
  //---------------------------------------------------------------------------
  task reset_offload_and_dma();
    spi_api.offload_mem_assert_reset();
    #100ns;
    spi_api.offload_mem_deassert_reset();
    dma_api.disable_dma();
    #100ns;
  endtask

  //---------------------------------------------------------------------------
  // Helper: Program offload commands
  //---------------------------------------------------------------------------
  task program_offload_commands(input int transfer_type = `INST_WRD, input [1:0] cs_deassert_delay = 2'h0);
    spi_api.fifo_offload_command(`INST_CFG);
    spi_api.fifo_offload_command(`INST_PRESCALE);
    spi_api.fifo_offload_command(`INST_DLENGTH);
    if (`CS_ACTIVE_HIGH) begin
      spi_api.fifo_offload_command(`SET_CS_INV_MASK(8'hFF));
    end
    spi_api.fifo_offload_command(`SET_CS(8'hFE));
    spi_api.fifo_offload_command(transfer_type);
    spi_api.fifo_offload_command(`SET_CS_DELAY(8'hFF, cs_deassert_delay));
    spi_api.fifo_offload_command(`INST_SYNC | 2);
  endtask

  //---------------------------------------------------------------------------
  // Helper: Configure and start PWM
  //---------------------------------------------------------------------------
  task configure_pwm(input int period);
    pwm_api.reset();
    pwm_api.pulse_period_config(0, period);
    pwm_api.load_config();
    pwm_api.start();
  endtask

  //---------------------------------------------------------------------------
  // Helper: Wait for specific number of offload syncs
  //---------------------------------------------------------------------------
  task wait_for_offload_syncs(input int count);
    int start_count;
    start_count = offload_sync_count;
    while ((offload_sync_count - start_count) < count) begin
      #100ns;
    end
  endtask

  //---------------------------------------------------------------------------
  // Helper: Wait for offload sync with timeout
  //---------------------------------------------------------------------------
  task automatic wait_for_offload_sync_timeout(
      input int expected_count,
      input int timeout_ns,
      output bit timed_out);
    int start_count;
    start_count = offload_sync_count;
    timed_out = 0;
    fork
      begin
        while ((offload_sync_count - start_count) < expected_count)
          #100ns;
      end
      begin
        #(timeout_ns);
        timed_out = 1;
      end
    join_any
    disable fork;
  endtask

  //---------------------------------------------------------------------------
  // Helper: Verify FIFO mode is operational
  //---------------------------------------------------------------------------
  task verify_fifo_mode_operational();

    bit   [`DATA_DLENGTH-1:0]  v_rx [];
    bit   [`DATA_DLENGTH-1:0]  v_tx [];
    int unsigned               v_tx_cast [];
    logic [  `DATA_WIDTH-1:0]  v_sdi_raw [];
    logic [`DATA_DLENGTH-1:0]  v_sdi [];
    int unsigned               v_sdo [];
    bit   [`DATA_DLENGTH-1:0]  v_rx_store [];
    bit   [`DATA_DLENGTH-1:0]  v_tx_store [];

    `INFO(("Verifying FIFO mode operational..."), ADI_VERBOSITY_LOW);

    v_rx       = new [`NUM_OF_MISO];
    v_tx       = new [`NUM_OF_MOSI];
    v_tx_cast  = new [`NUM_OF_MOSI];
    v_sdi_raw  = new [`NUM_OF_MISO];
    v_sdi      = new [`NUM_OF_MISO];
    v_sdo      = new [`NUM_OF_MOSI];
    v_rx_store = new [`NUM_OF_WORDS * `NUM_OF_MISO];
    v_tx_store = new [`NUM_OF_WORDS * `NUM_OF_MOSI];

    for (int i = 0; i < `NUM_OF_WORDS; i++) begin
      for (int j = 0; j < `NUM_OF_MOSI; j++) begin
        v_tx[j] = $urandom;
        v_tx_cast[j] = v_tx[j];
        v_tx_store[i * `NUM_OF_MOSI + j] = v_tx[j];
      end
      spi_api.sdo_fifo_write(v_tx_cast);

      for (int j = 0; j < `NUM_OF_MISO; j++) begin
        v_rx[j] = $urandom;
        v_rx_store[i * `NUM_OF_MISO + j] = v_rx[j];
      end
      spi_send(v_rx);
    end

    spi_api.fifo_command(`INST_CFG);

    // The SPI engine reset/cfg change may cause spurious SCLK edges that the
    // VIP interprets as a partial transfer depending on CPOL/CPHA, leaving
    // stale data in the MOSI mailbox. Flush it before the FIFO mode check.
    // This is benign, since it only happens because the execution module is
    // currently not instantiated with the correct default CPOL/CPHA config.
    spi_discard_mosi();

    spi_api.fifo_command(`INST_PRESCALE);
    spi_api.fifo_command(`INST_DLENGTH);
    if (`CS_ACTIVE_HIGH) begin
      spi_api.fifo_command(`SET_CS_INV_MASK(8'hFF));
    end
    spi_api.fifo_command(`SET_SDI_LANE_MASK(sdi_lane_mask));
    spi_api.fifo_command(`SET_SDO_LANE_MASK(sdo_lane_mask));
    spi_api.fifo_command(`SET_CS(8'hFE));
    spi_api.fifo_command(`INST_WRD);
    spi_api.fifo_command(`SET_CS(8'hFF));
    spi_api.fifo_command(`INST_SYNC | 1);

    spi_wait_send();
    #500ns;

    for (int i = 0; i < `NUM_OF_WORDS; i++) begin
      spi_api.sdi_fifo_read(v_sdi_raw);
      spi_receive(v_sdo);
      for (int j = 0; j < `NUM_OF_MISO; j++) begin
        v_sdi[j] = v_sdi_raw[j];
        if (v_sdi[j] !== v_rx_store[i * `NUM_OF_MISO + j]) begin
          `FATAL(("FIFO verify: SDI mismatch at word %0d lane %0d. Expected: %x, Got: %x",
                  i, j, v_rx_store[i * `NUM_OF_MISO + j], v_sdi[j]));
        end
      end
      for (int j = 0; j < `NUM_OF_MOSI; j++) begin
        if (v_sdo[j] !== v_tx_store[i * `NUM_OF_MOSI + j]) begin
          `FATAL(("FIFO verify: SDO mismatch at word %0d lane %0d. Expected: %x, Got: %x",
                  i, j, v_tx_store[i * `NUM_OF_MOSI + j], v_sdo[j]));
        end
      end
    end
    `INFO(("FIFO mode operational - verified."), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // Helper: SDO streaming generation
  //---------------------------------------------------------------------------
  task sdo_stream_gen(
      input [`DATA_DLENGTH-1:0] tx_data[]);
    xil_axi4stream_data_byte data[((`DATA_WIDTH/8) * (`NUM_OF_MOSI))-1:0];
    `ifdef DEF_SDO_STREAMING
      for (int i = 0; i < `NUM_OF_MOSI; i++) begin
        for (int j = 0; j < (`DATA_WIDTH/8); j++) begin
          data[i * (`DATA_WIDTH/8) + j] = (tx_data[i] & (8'hFF << 8*j)) >> 8*j;
          spi_env.sdo_src_agent.master_sequencer.push_byte_for_stream(data[i * (`DATA_WIDTH/8) + j]);
        end
      end
      spi_env.sdo_src_agent.master_sequencer.add_xfer_descriptor_byte_count((`DATA_WIDTH/8) * (`NUM_OF_MOSI), 0, 0);
    `endif
  endtask

  //---------------------------------------------------------------------------
  // Test 1: Early Offload Disable (Mid-Program)
  //---------------------------------------------------------------------------


  task test_early_offload_disable();

    bit [`DATA_DLENGTH-1:0] test1_sdi_data [];
    bit [`DATA_DLENGTH-1:0] test1_sdo_data [];


    `INFO(("===== Test 1: Early Offload Disable (Mid-Program) ====="), ADI_VERBOSITY_NONE);

    rx_data        = new [`NUM_OF_MISO];
    tx_data        = new [`NUM_OF_MOSI];
    tx_data_cast   = new [`NUM_OF_MOSI];
    receive_data   = new [`NUM_OF_MOSI];
    test1_sdi_data = new [TEST1_NUM_XFERS * `NUM_OF_WORDS * `NUM_OF_MISO];
    test1_sdo_data = new [TEST1_NUM_XFERS * `NUM_OF_WORDS * `NUM_OF_MOSI];

    reset_offload_and_dma();
    offload_sync_count = 0;

    // Configure DMA for both transfers from a single trigger
    dma_api.enable_dma();
    dma_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    dma_api.set_lengths((TEST1_NUM_XFERS * `NUM_OF_WORDS * `NUM_OF_MISO * BYTES_PER_WORD) - 1, 0);
    dma_api.set_dest_addr(`DDR_BA);
    dma_api.transfer_start();

    // Program offload with multi-transfer sequence:
    // Setup → Transfer 1 → SYNC → SLEEP(255) → Transfer 2 → SYNC
    // The SLEEP creates a window where the program is mid-execution,
    // allowing us to issue stop_offload() before all commands complete.
    spi_api.fifo_offload_command(`INST_CFG);
    spi_api.fifo_offload_command(`INST_PRESCALE);
    spi_api.fifo_offload_command(`INST_DLENGTH);
    if (`CS_ACTIVE_HIGH) begin
      spi_api.fifo_offload_command(`SET_CS_INV_MASK(8'hFF));
    end
    // Transfer 1
    spi_api.fifo_offload_command(`SET_CS(8'hFE));
    spi_api.fifo_offload_command(`INST_WRD);
    spi_api.fifo_offload_command(`SET_CS(8'hFF));
    spi_api.fifo_offload_command(`INST_SYNC | 1);
    // Long sleep to create a reliable mid-program disable window
    spi_api.fifo_offload_command(`SLEEP(TEST1_SLEEP_PARAM));
    // Other transfers (should still execute despite mid-program disable)
    for (int i = 1; i < TEST1_NUM_XFERS; i++) begin
      spi_api.fifo_offload_command(`SET_CS(8'hFE));
      spi_api.fifo_offload_command(`INST_WRD);
      spi_api.fifo_offload_command(`SET_CS(8'hFF));
      spi_api.fifo_offload_command(`INST_SYNC | (i+1));
    end

    // Enqueue data for all transfers.
    // In non-streaming mode, the SDO memory read pointer advances
    // sequentially through the program (doesn't reset between WRDs
    // within a single trigger), so we write TEST1_NUM_XFERS × NUM_OF_WORDS entries.
    for (int i = 0; i < (TEST1_NUM_XFERS * `NUM_OF_WORDS); i++) begin
      for (int j = 0; j < `NUM_OF_MISO; j++) begin
        rx_data[j] = $urandom;
        test1_sdi_data[i * `NUM_OF_MISO + j] = rx_data[j];
      end
      spi_send(rx_data);

      for (int j = 0; j < `NUM_OF_MOSI; j++) begin
        tx_data[j] = $urandom;
        tx_data_cast[j] = tx_data[j];
      end

      `ifdef DEF_SDO_STREAMING
        sdo_stream_gen(tx_data);
        for (int j = 0; j < `NUM_OF_MOSI; j++) begin
          test1_sdo_data[i * `NUM_OF_MOSI + j] = tx_data[j];
        end
      `else
        spi_api.sdo_offload_fifo_write(tx_data_cast);
        for (int j = 0; j < `NUM_OF_MOSI; j++) begin
          test1_sdo_data[i * `NUM_OF_MOSI + j] = tx_data[j];
        end
      `endif
    end

    // Configure PWM (period longer than full program to avoid extra triggers)
    configure_pwm(PWM_PERIOD_TEST1);

    spi_api.start_offload();
    `INFO(("Offload started with multi-transfer program."), ADI_VERBOSITY_LOW);

    // Wait for 1st SYNC (Transfer 1 complete, now executing SLEEP)
    wait_for_offload_syncs(1);

    // Stop offload mid-program (during SLEEP, before Transfer 2 commands execute)
    spi_api.stop_offload();
    `INFO(("Offload stop requested mid-program (during SLEEP between transfers)."), ADI_VERBOSITY_LOW);

    // Wait for offload to fully disable
    // The offload module completes the current program despite disable,
    // so all transfers should execute before offload goes inactive.
    spi_api.wait_offload_disabled();
    `INFO(("Offload disabled."), ADI_VERBOSITY_LOW);

    pwm_api.reset();

    #1000ns;

    // Verify program ran to completion (all transfers despite mid-program disable)
    if (offload_sync_count !== TEST1_NUM_XFERS) begin
      `FATAL(("Test 1: Expected %0d syncs (full program completion), got %0d", TEST1_NUM_XFERS, offload_sync_count));
    end
    `INFO(("Test 1: %0d syncs verified (program completed despite mid-program disable).", offload_sync_count), ADI_VERBOSITY_LOW);

    // Verify SDI data integrity for both transfers
    for (int i = 0; i < (TEST1_NUM_XFERS * `NUM_OF_WORDS * `NUM_OF_MISO); i++) begin
      logic [`DATA_DLENGTH-1:0] read_data;
      read_data = base_env.ddr.slave_sequencer.BackdoorRead32(xil_axi_uint'(`DDR_BA + 4*i));
      if (read_data !== test1_sdi_data[i]) begin
        `FATAL(("Test 1: SDI data mismatch at index %d. Expected: %x, Got: %x", i, test1_sdi_data[i], read_data));
      end
    end
    `INFO(("Test 1: SDI data verified for %d transfers.", TEST1_NUM_XFERS), ADI_VERBOSITY_LOW);

    // Verify SDO data for all transfers
    for (int i = 0; i < (TEST1_NUM_XFERS * `NUM_OF_WORDS); i++) begin
      spi_receive(receive_data);
      for (int j = 0; j < `NUM_OF_MOSI; j++) begin
        if (receive_data[j] !== test1_sdo_data[i * `NUM_OF_MOSI + j]) begin
          `FATAL(("Test 1: SDO data mismatch at word %d, lane %d. Expected: %x, Got: %x",
                  i, j, test1_sdo_data[i * `NUM_OF_MOSI + j], receive_data[j]));
        end
      end
    end
    `INFO(("Test 1: SDO data verified for %d transfers.", TEST1_NUM_XFERS), ADI_VERBOSITY_LOW);

    // Verify FIFO mode is operational
    verify_fifo_mode_operational();

    `INFO(("===== Test 1: PASSED ====="), ADI_VERBOSITY_NONE);
  endtask

  //---------------------------------------------------------------------------
  // Test 2: Disable During Backpressure
  //---------------------------------------------------------------------------

  bit [`DATA_DLENGTH-1:0] test2_sdi_data [];
  bit [`DATA_DLENGTH-1:0] test2_sdo_data [];

  task test_disable_during_backpressure();

    `INFO(("===== Test 2: Disable During Backpressure ====="), ADI_VERBOSITY_NONE);

    // --- SDI Backpressure (DMA Buffer Full) ---
    `INFO(("SDI backpressure (DMA buffer full)."), ADI_VERBOSITY_LOW);

    rx_data        = new [`NUM_OF_MISO];
    tx_data        = new [`NUM_OF_MOSI];
    tx_data_cast   = new [`NUM_OF_MOSI];
    receive_data   = new [`NUM_OF_MOSI];
    test2_sdi_data = new [TEST2_TRANSFERS * `NUM_OF_WORDS * `NUM_OF_MISO];
    test2_sdo_data = new [TEST2_TRANSFERS * `NUM_OF_WORDS * `NUM_OF_MOSI];

    reset_offload_and_dma();
    offload_sync_count = 0;

    // Configure DMA for smaller buffer than full offload
    dma_api.enable_dma();
    dma_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    dma_api.set_lengths((TEST2_DATA_TRANSFERS * `NUM_OF_WORDS * `NUM_OF_MISO * BYTES_PER_WORD) - 1, 0);
    dma_api.set_dest_addr(`DDR_BA);
    dma_api.transfer_start();

    // Program offload with non-zero CS deassert delay to stress the
    // transfer-to-chipselect transition under backpressure.
    program_offload_commands(.transfer_type(`INST_WRD), .cs_deassert_delay(TEST2_CS_DELAY));

    // Enqueue data to SPI VIP for more transfers than DMA can hold
    for (int i = 0; i < (TEST2_TRANSFERS * `NUM_OF_WORDS); i++) begin
      for (int j = 0; j < `NUM_OF_MISO; j++) begin
        rx_data[j] = $urandom;
        test2_sdi_data[i * `NUM_OF_MISO + j] = rx_data[j];
      end
      spi_send(rx_data);

      for (int j = 0; j < `NUM_OF_MOSI; j++) begin
        tx_data[j] = $urandom;
        tx_data_cast[j] = tx_data[j];
      end

      `ifdef DEF_SDO_STREAMING
        sdo_stream_gen(tx_data);
        for (int j = 0; j < `NUM_OF_MOSI; j++) begin
          test2_sdo_data[i * `NUM_OF_MOSI + j] = tx_data[j];
        end
      `else
        if (i < `NUM_OF_WORDS) begin
          for (int j = 0; j < `NUM_OF_MOSI; j++) begin
            test2_sdo_data[i * `NUM_OF_MOSI + j] = tx_data[j];
          end
          spi_api.sdo_offload_fifo_write(tx_data_cast);
        end else begin
          for (int j = 0; j < `NUM_OF_MOSI; j++) begin
            test2_sdo_data[i * `NUM_OF_MOSI + j] = test2_sdo_data[(i % `NUM_OF_WORDS) * `NUM_OF_MOSI + j];
          end
        end
      `endif
    end

    // Configure PWM with appropriate period
    configure_pwm(PWM_PERIOD_NORMAL);

    spi_api.start_offload();
    `INFO(("Offload started."), ADI_VERBOSITY_LOW);

    // Wait for DMA to fill (transfer_done)
    dma_api.wait_transfer_done(.transfer_id(0), .timeut_in_us(5000));
    `INFO(("DMA transfer done - buffer full, backpressure expected."), ADI_VERBOSITY_LOW);

    // Wait for the next offload trigger to start a new transfer.
    // After DMA fill, the next trigger starts a transfer that stalls
    // mid-execution when SDI data can't be pushed to the full DMA.
    // We detect this by waiting for CS activation on the SPI bus,
    // guaranteeing we stop offload during an active transfer, not
    // between triggers.
    if (`CS_ACTIVE_HIGH) begin
      if (spi_engine_spi_cs[0] !== 1'b1)
        @(posedge spi_engine_spi_cs[0]);
    end else begin
      if (spi_engine_spi_cs[0] !== 1'b0)
        @(negedge spi_engine_spi_cs[0]);
    end
    `INFO(("CS asserted after DMA full - transfer stalled mid-execution."), ADI_VERBOSITY_LOW);

    // Stop offload while engine is mid-transfer under backpressure
    spi_api.stop_offload();
    `INFO(("Offload stop requested during mid-transfer backpressure."), ADI_VERBOSITY_LOW);

    // Wait for offload to fully disable
    spi_api.wait_offload_disabled();
    `INFO(("Offload disabled."), ADI_VERBOSITY_LOW);

    #1000ns;

    // Turn off PWM only some time after offload is disabled, extra triggers should have been ignored.
    pwm_api.reset();

    // Verify data integrity for completed transfers (DMA buffer size)
    for (int i = 0; i < (TEST2_DATA_TRANSFERS * `NUM_OF_WORDS * `NUM_OF_MISO); i++) begin
      logic [`DATA_DLENGTH-1:0] read_data;
      read_data = base_env.ddr.slave_sequencer.BackdoorRead32(xil_axi_uint'(`DDR_BA + 4*i));
      if (read_data !== test2_sdi_data[i]) begin
        `FATAL(("Test 2: SDI data mismatch at index %d. Expected: %x, Got: %x", i, test2_sdi_data[i], read_data));
      end
    end
    `INFO(("Test 2: SDI data verified for %d transfers.", TEST2_DATA_TRANSFERS), ADI_VERBOSITY_LOW);

    // Flush out any remaining SDO data for completed transfers from SPI VIP
    spi_discard_mosi();

    // Verify FIFO mode is operational
    verify_fifo_mode_operational();

    #100ns;

    `INFO(("===== Test 2: PASSED ====="), ADI_VERBOSITY_NONE);
  endtask

  //---------------------------------------------------------------------------
  // Test 3: Disable Before First Trigger + Rapid Enable/Disable Cycling
  //---------------------------------------------------------------------------

  task test_rapid_enable_disable();
    int transfers_per_cycle;

    `INFO(("===== Test 3: Rapid Enable/Disable Cycling ====="), ADI_VERBOSITY_NONE);

    // --- Phase 1: Disable Before First Trigger ---
    // Tests the RTL path where spi_active was never asserted and
    // interconnect_dir never switched. The offload is armed but
    // no PWM trigger fires before stop_offload() is called.
    `INFO(("Phase 1: Disable before first trigger."), ADI_VERBOSITY_LOW);

    reset_offload_and_dma();
    offload_sync_count = 0;

    // Configure DMA (even though we're not doing as many transfers)
    dma_api.enable_dma();
    dma_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    dma_api.set_lengths((`NUM_OF_TRANSFERS * `NUM_OF_WORDS * `NUM_OF_MISO * BYTES_PER_WORD) - 1, 0);
    dma_api.set_dest_addr(`DDR_BA);
    dma_api.transfer_start();

    // Program offload with a very minimal program
    // so we maximize its visibility in case it executes (which it shouldn't)
    spi_api.fifo_offload_command(`INST_SYNC | 7);

    // Configure PWM with a very long period so no trigger fires
    configure_pwm(PWM_PERIOD_NO_TRIGGER);

    // Start offload then immediately stop (before any trigger)
    spi_api.start_offload();
    spi_api.stop_offload();
    `INFO(("Offload started and immediately stopped before first trigger."), ADI_VERBOSITY_LOW);

    // Wait for offload to fully disable
    spi_api.wait_offload_disabled();
    `INFO(("Offload disabled (no triggers should have fired)."), ADI_VERBOSITY_LOW);

    pwm_api.reset();

    #500ns;

    // Verify no transfers occurred
    if (offload_sync_count !== 0) begin
      `FATAL(("Test 3 Phase 1: Expected 0 syncs, got %0d", offload_sync_count));
    end
    `INFO(("Test 3 Phase 1: 0 syncs verified (no triggers fired)."), ADI_VERBOSITY_LOW);

    // Flush any queued SPI VIP data from setup
    spi_discard_mosi();

    // Verify FIFO mode is operational after armed-but-never-triggered offload
    verify_fifo_mode_operational();

    `INFO(("Test 3 Phase 1: PASSED."), ADI_VERBOSITY_LOW);

    // --- Phase 2: Rapid Enable/Disable Cycling ---
    `INFO(("Test 3 Phase 2: Rapid enable/disable cycling (%0d iterations).", TEST3_ITERATIONS), ADI_VERBOSITY_LOW);

    for (int cycle = 0; cycle < TEST3_ITERATIONS; cycle++) begin
      `INFO(("Cycle %d of %d", cycle + 1, TEST3_ITERATIONS), ADI_VERBOSITY_LOW);

      // Random amount of transfers
      transfers_per_cycle = $urandom_range(1, TEST3_TRANSFERS);
      `INFO(("Configuring for %d transfers this cycle.", transfers_per_cycle), ADI_VERBOSITY_LOW);

      reset_offload_and_dma();
      offload_sync_count = 0;

      // Configure DMA
      dma_api.enable_dma();
      dma_api.set_flags(
        .cyclic(1'b0),
        .tlast(1'b1),
        .partial_reporting_en(1'b1));
      dma_api.set_lengths((transfers_per_cycle * `NUM_OF_WORDS * `NUM_OF_MISO * BYTES_PER_WORD) - 1, 0);
      dma_api.set_dest_addr(`DDR_BA);
      dma_api.transfer_start();

      // Program offload
      program_offload_commands();

      // Enqueue some data
      for (int i = 0; i < (transfers_per_cycle * `NUM_OF_WORDS); i++) begin
        bit [`DATA_DLENGTH-1:0] local_rx [];
        bit [`DATA_DLENGTH-1:0] local_tx [];
        int unsigned            local_tx_cast [];
        local_rx      = new [`NUM_OF_MISO];
        local_tx      = new [`NUM_OF_MOSI];
        local_tx_cast = new [`NUM_OF_MOSI];

        for (int j = 0; j < `NUM_OF_MISO; j++)
          local_rx[j] = $urandom;
        spi_send(local_rx);

        for (int j = 0; j < `NUM_OF_MOSI; j++) begin
          local_tx[j] = $urandom;
          local_tx_cast[j] = local_tx[j];
        end

        `ifdef DEF_SDO_STREAMING
          sdo_stream_gen(local_tx);
        `else
          if (i < `NUM_OF_WORDS) begin
            spi_api.sdo_offload_fifo_write(local_tx_cast);
          end
        `endif
      end

      // Configure PWM
      configure_pwm(PWM_PERIOD_NORMAL);

      // Start offload
      spi_api.start_offload();

      wait_for_offload_syncs(transfers_per_cycle);

      // Stop offload
      spi_api.stop_offload();

      // Wait for disable
      spi_api.wait_offload_disabled();

      pwm_api.reset();

      spi_wait_send();

      spi_discard_mosi();

      #10ns;
    end

    // Final verification: FIFO mode should still work
    verify_fifo_mode_operational();

    `INFO(("===== Test 3: PASSED ====="), ADI_VERBOSITY_NONE);
  endtask

  //---------------------------------------------------------------------------
  // Test 4: Short Program Completion After SPI Reset
  //
  // Verifies that the offload module has clean internal state after spi_resetn
  // and can correctly complete short programs. Short programs (1-2 commands)
  // exercise the edge of the command-sequencing logic, which tracks program
  // length via a registered lookahead. If any sequencing state survives reset,
  // the program may terminate early or run past its end.
  //
  // Phase 1: Start a 2-command offload, reset the SPI engine mid-execution,
  //          then reprogram and verify the program completes.
  // Phase 2: Same reset procedure, but reprogram with a 1-command offload
  //          to test the minimum program length edge case.
  //---------------------------------------------------------------------------

  task test_short_program_completion();
    bit sync_timed_out;

    `INFO(("===== Test 4: Short Program Completion After SPI Reset ====="), ADI_VERBOSITY_NONE);

    // --- Phase 1: 2-command program after reset ---
    // Program [SLEEP(254), SYNC]. The SLEEP creates a wide window where the
    // command sequencer has accepted all commands but execution is ongoing.
    // Pulsing spi_resetn here forces the sequencing state to be cleared.
    // Then reprogram the same program and verify it completes — a single
    // SYNC IRQ confirms both commands were consumed.

    `INFO(("Phase 1: 2-command program after SPI reset."), ADI_VERBOSITY_LOW);

    reset_offload_and_dma();
    offload_sync_count = 0;

    spi_api.fifo_offload_command(`SLEEP(TEST4_SLEEP_PARAM));
    spi_api.fifo_offload_command(`INST_SYNC | 1);

    configure_pwm(PWM_PERIOD_TEST4);

    spi_api.start_offload();

    @(posedge last_cmd_probe);
    `INFO(("Command sequencing reached end-of-program, pulsing SPI engine reset."), ADI_VERBOSITY_LOW);

    spi_api.disable_spi_engine();
    #200ns;
    spi_api.enable_spi_engine();

    pwm_api.reset();

    #500ns;

    spi_api.set_interrup_mask(.sync_event(1'b1), .offload_sync_id_pending(1'b1));
    offload_sync_count = 0;

    reset_offload_and_dma();

    spi_api.fifo_offload_command(`SLEEP(TEST4_SLEEP_PARAM));
    spi_api.fifo_offload_command(`INST_SYNC | 2);

    configure_pwm(PWM_PERIOD_TEST4);

    spi_api.start_offload();

    // Allow exactly one trigger, then stop PWM to prevent a second trigger
    // from masking a premature termination on the first.
    @(posedge spi_active_probe);
    pwm_api.reset();
    `INFO(("Single trigger fired. Waiting for SYNC..."), ADI_VERBOSITY_LOW);

    wait_for_offload_sync_timeout(1, TEST4_SYNC_TIMEOUT_NS, sync_timed_out);

    spi_api.stop_offload();
    spi_api.wait_offload_disabled();

    #500ns;

    if (sync_timed_out) begin
      `FATAL(("Test 4 Phase 1: SYNC timeout — 2-command program did not complete after reset. offload_sync_count=%0d", offload_sync_count));
    end

    if (offload_sync_count !== 1) begin
      `FATAL(("Test 4 Phase 1: Expected 1 sync, got %0d", offload_sync_count));
    end

    `INFO(("Phase 1: 2-command program completed correctly after reset."), ADI_VERBOSITY_LOW);

    // --- Phase 2: 1-command program after reset ---
    // Reset the SPI engine mid-execution (using a 2-command program for the
    // timing window), then reprogram with a single [SYNC]. This is the
    // shortest possible offload program and an edge case for the command
    // sequencing logic.

    `INFO(("Phase 2: 1-command program after SPI reset."), ADI_VERBOSITY_LOW);

    offload_sync_count = 0;

    reset_offload_and_dma();

    spi_api.fifo_offload_command(`SLEEP(TEST4_SLEEP_PARAM));
    spi_api.fifo_offload_command(`INST_SYNC | 3);

    configure_pwm(PWM_PERIOD_TEST4);

    spi_api.start_offload();

    @(posedge spi_active_probe);
    `INFO(("Trigger fired, pulsing SPI engine reset mid-execution."), ADI_VERBOSITY_LOW);

    spi_api.disable_spi_engine();
    #200ns;
    spi_api.enable_spi_engine();

    pwm_api.reset();

    #500ns;

    spi_api.set_interrup_mask(.sync_event(1'b1), .offload_sync_id_pending(1'b1));
    offload_sync_count = 0;

    reset_offload_and_dma();

    spi_api.fifo_offload_command(`INST_SYNC | 4);

    configure_pwm(PWM_PERIOD_TEST4);

    spi_api.start_offload();

    @(posedge spi_active_probe);
    pwm_api.reset();
    `INFO(("Single trigger fired. Waiting for SYNC from 1-command program..."), ADI_VERBOSITY_LOW);

    wait_for_offload_sync_timeout(1, TEST4_SYNC_TIMEOUT_NS, sync_timed_out);

    spi_api.stop_offload();
    spi_api.wait_offload_disabled();

    #500ns;

    if (sync_timed_out) begin
      `FATAL(("Test 4 Phase 2: SYNC timeout — 1-command program did not complete. offload_sync_count=%0d", offload_sync_count));
    end

    if (offload_sync_count !== 1) begin
      `FATAL(("Test 4 Phase 2: Expected 1 sync, got %0d", offload_sync_count));
    end

    `INFO(("Phase 2: 1-command program completed after reset."), ADI_VERBOSITY_LOW);

    verify_fifo_mode_operational();

    `INFO(("===== Test 4: PASSED ====="), ADI_VERBOSITY_NONE);
  endtask

endprogram
