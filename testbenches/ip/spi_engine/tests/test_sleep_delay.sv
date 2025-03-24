// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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
`include "axi_definitions.svh"
`include "axis_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
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
// SPI Engine configuration parameters
//---------------------------------------------------------------------------

program test_sleep_delay (
  inout spi_engine_irq,
  inout spi_engine_spi_sclk,
  inout [(`NUM_OF_CS - 1):0] spi_engine_spi_cs,
  inout spi_engine_spi_clk,
  `ifdef DEF_ECHO_SCLK
    inout spi_engine_echo_sclk,
  `endif
  inout [(`NUM_OF_SDI - 1):0] spi_engine_spi_sdi);

  timeunit 1ns;
  timeprecision 100ps;

  // declare the class instances
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  spi_environment spi_env;
  spi_engine_api spi_api;
  dmac_api dma_api;
  pwm_gen_api pwm_api;
  clk_gen_api clkgen_api;

  // --------------------------
  // Wrapper function for SPI receive (from DUT)
  // --------------------------
  task spi_receive(
      output [`DATA_DLENGTH:0]  data);
    spi_env.spi_agent.sequencer.receive_data(data);
  endtask

  // --------------------------
  // Wrapper function for SPI send (to DUT)
  // --------------------------
  task spi_send(
      input [`DATA_DLENGTH:0]  data);
    spi_env.spi_agent.sequencer.send_data(data);
  endtask

  // --------------------------
  // Wrapper function for waiting for all SPI
  // --------------------------
  task spi_wait_send();
    spi_env.spi_agent.sequencer.flush_send();
  endtask


  // --------------------------
  // Main procedure
  // --------------------------
  initial begin

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    //creating environment
    base_env = new("Base Environment",
                      `TH.`SYS_CLK.inst.IF,
                      `TH.`DMA_CLK.inst.IF,
                      `TH.`DDR_CLK.inst.IF,
                      `TH.`SYS_RST.inst.IF,
                      `TH.`MNG_AXI.inst.IF,
                      `TH.`DDR_AXI.inst.IF);

    spi_env = new("SPI Engine Environment",
              `ifdef DEF_SDO_STREAMING
                `TH.`SDO_SRC.inst.IF,
              `endif
              `TH.`SPI_S.inst.IF.vif);

    spi_api = new("SPI Engine API",
                  base_env.mng.sequencer,
                  `SPI_ENGINE_SPI_REGMAP_BA);

    dma_api = new("RX DMA API",
                  base_env.mng.sequencer,
                  `SPI_ENGINE_DMA_BA);

    clkgen_api = new("CLKGEN API",
                    base_env.mng.sequencer,
                    `SPI_ENGINE_AXI_CLKGEN_BA);

    pwm_api = new("PWM API",
                  base_env.mng.sequencer,
                  `SPI_ENGINE_PWM_GEN_BA);

    base_env.start();
    spi_env.start();

    base_env.sys_reset();

    spi_env.configure();

    spi_env.run();

    spi_env.spi_agent.sequencer.set_default_miso_data('h2AA55);

    // start sdo source (will wait for data enqueued)
    `ifdef DEF_SDO_STREAMING
      spi_env.sdo_src_agent.sequencer.start();
    `endif

    sanity_tests();

    init();

    #100ns

    sleep_delay_test(7);

    cs_delay_test(3,3);

    spi_env.stop();
    base_env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  //---------------------------------------------------------------------------
  // IRQ callback
  //---------------------------------------------------------------------------

  reg [4:0] irq_pending = 0;
  reg [7:0] sync_id = 0;

  initial begin
    forever begin
      @(posedge spi_engine_irq);
      // read pending IRQs
      spi_api.get_irq_pending(irq_pending);
      // IRQ launched by Offload SYNC command
      if (spi_api.check_irq_offload_sync_id_pending(irq_pending)) begin
        spi_api.get_sync_id(sync_id);
        `INFO(("Offload SYNC %d IRQ. An offload transfer just finished.",  sync_id), ADI_VERBOSITY_LOW);
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
  // Echo SCLK generation - we need this only if ECHO_SCLK is enabled
  //---------------------------------------------------------------------------
  `ifdef DEF_ECHO_SCLK
    assign #(`ECHO_SCLK_DELAY * 1ns) spi_engine_echo_sclk = spi_engine_spi_sclk;
  `endif

  //---------------------------------------------------------------------------
  // Sleep and Chip Select Instruction time counter
  //---------------------------------------------------------------------------

  int sleep_instr_time[$];
  int sleep_duration;
  int sleep_current_duration;
  bit sleeping;
  int cs_instr_time[$];
  int cs_current_duration;
  int cs_duration;
  bit cs_sleeping;
  wire [15:0] cmd, cmd_d1;
  wire cmd_valid, cmd_ready;
  wire idle;

  assign cmd          = `TH.spi_engine.spi_engine_execution.inst.cmd;
  assign cmd_d1       = `TH.spi_engine.spi_engine_execution.inst.cmd_d1;
  assign cmd_valid    = `TH.spi_engine.spi_engine_execution.inst.cmd_valid;
  assign cmd_ready    = `TH.spi_engine.spi_engine_execution.inst.cmd_ready;
  assign idle         = `TH.spi_engine.spi_engine_execution.inst.idle;

  initial begin
    sleep_current_duration = 0;
    sleep_duration = 0;
    sleeping = 1'b0;
    cs_current_duration = 0;
    cs_duration = 0;
    cs_sleeping = 1'b0;
    forever begin
      @(posedge spi_engine_spi_clk);
        if (idle && (cmd_d1[15:8] == 8'h31) && sleeping) begin
          sleeping <= 1'b0;
          sleep_duration = sleep_current_duration+1;
          sleep_instr_time.push_front(sleep_current_duration+1); // add one to account for this cycle
        end
        if (cmd_valid && cmd_ready && (cmd[15:8] == 8'h31)) begin
          sleep_current_duration <= 0;
          sleeping <= 1'b1;
        end else begin
          sleep_current_duration <= sleep_current_duration+1;
        end
        if (idle && (cmd_d1[15:10] == 6'h4) && cs_sleeping) begin
          cs_sleeping = 1'b0;
          cs_duration = cs_current_duration+1;
          cs_instr_time.push_front(cs_current_duration+1); // add one to account for this cycle
        end
        if (cmd_valid && cmd_ready && (cmd[15:10] == 6'h4)) begin
          cs_current_duration <= 0;
          cs_sleeping <= 1'b1;
        end else begin
          cs_current_duration <= cs_current_duration+1;
        end
    end
  end

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
        // Start spi clk generator
    clkgen_api.enable_clkgen();

    // Config pwm
    pwm_api.reset();
    pwm_api.pulse_period_config(0,'d121); // config channel 0 period
    pwm_api.load_config();
    pwm_api.start();
    `INFO(("axi_pwm_gen started."), ADI_VERBOSITY_LOW);

    // Enable SPI Engine
    spi_api.enable_spi_engine();

    // Configure the execution module
    spi_api.fifo_command(`INST_CFG);
    spi_api.fifo_command(`INST_PRESCALE);
    spi_api.fifo_command(`INST_DLENGTH);
    if (`CS_ACTIVE_HIGH) begin
      spi_api.fifo_command(`SET_CS_INV_MASK(8'hFF));
    end

    // Set up the interrupts
    spi_api.set_interrup_mask(.sync_event(1'b1),.offload_sync_id_pending(1'b1));

  endtask

  //---------------------------------------------------------------------------
  // Sleep delay Test
  //---------------------------------------------------------------------------

  int sleep_time;
  int expected_sleep_time;

  task sleep_delay_test(
      input [7:0] sleep_param);

    expected_sleep_time = 2+(sleep_param+1)*((`CLOCK_DIVIDER+1)*2);
    // Start the test
    spi_api.fifo_command(`SLEEP(sleep_param));

    #2000ns
    sleep_time = sleep_instr_time.pop_back();
    if ((sleep_time != expected_sleep_time)) begin
      `FATAL(("Sleep Test FAILED: unexpected sleep instruction duration. Expected=%d, Got=%d",expected_sleep_time,sleep_time));
    end
    // change the SPI word size (this should not affect sleep delay)
    spi_api.fifo_command(`INST_DLENGTH);
    spi_api.fifo_command(`SLEEP(sleep_param));
    spi_api.fifo_command(`INST_SYNC | 1);
    #2000ns
    sleep_time = sleep_instr_time.pop_back();
    #100ns
    if ((sleep_time != expected_sleep_time)) begin
      `FATAL(("Sleep Test FAILED: unexpected sleep instruction duration. Expected=%d, Got=%d",expected_sleep_time,sleep_time));
    end else begin
      `INFO(("Sleep Test PASSED"), ADI_VERBOSITY_LOW);
    end
  endtask

  //---------------------------------------------------------------------------
  // CS delay Test
  //---------------------------------------------------------------------------

  bit [`DATA_DLENGTH:0] offload_captured_word_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)-1:0];
  bit [`DATA_DLENGTH:0] offload_sdi_data_store_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)-1:0];
  int cs_activate_time;
  int expected_cs_activate_time;
  int cs_deactivate_time;
  int expected_cs_deactivate_time;
  bit [`DATA_DLENGTH-1:0] temp_data;

  task cs_delay_test(
      input [1:0] cs_activate_delay,
      input [1:0] cs_deactivate_delay);

    //Configure DMA
    dma_api.enable_dma();
    dma_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    dma_api.set_lengths(((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*4)-1,0);
    dma_api.set_dest_addr(`DDR_BA);
    dma_api.transfer_start();

    // Configure the Offload module
    spi_api.offload_mem_assert_reset();
    spi_api.offload_mem_deassert_reset();
    spi_api.fifo_offload_command(`INST_CFG);
    spi_api.fifo_offload_command(`INST_PRESCALE);
    spi_api.fifo_offload_command(`INST_DLENGTH);
    if (`CS_ACTIVE_HIGH) begin
      spi_api.fifo_offload_command(`SET_CS_INV_MASK(8'hFF));
    end
    spi_api.fifo_offload_command(`SET_CS(8'hFE));
    spi_api.fifo_offload_command(`INST_RD);
    spi_api.fifo_offload_command(`SET_CS(8'hFF));
    spi_api.fifo_offload_command(`INST_SYNC | 2);

    expected_cs_activate_time = 2;
    expected_cs_deactivate_time = 2;

    // Enqueue transfers to DUT
    for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
      temp_data = $urandom;
      spi_send(temp_data);
      offload_sdi_data_store_arr[i] = temp_data;
    end

    #100ns
    spi_api.start_offload();
    `INFO(("Offload started (no delay on CS change)."), ADI_VERBOSITY_LOW);

    spi_wait_send();

    spi_api.stop_offload();
    `INFO(("Offload stopped (no delay on CS change)."), ADI_VERBOSITY_LOW);

    #2000ns

    for (int i=0; i<=(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS); i=i+1) begin
      offload_captured_word_arr[i][`DATA_DLENGTH-1:0] = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(xil_axi_uint'(`DDR_BA + 4*i));
    end

    if (irq_pending == 'h0) begin
      `FATAL(("IRQ Test FAILED"));
    end else begin
      `INFO(("IRQ Test PASSED"), ADI_VERBOSITY_LOW);
    end

    if (offload_captured_word_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) - 1:0] !== offload_sdi_data_store_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) - 1:0]) begin
      `FATAL(("CS Delay Test FAILED: bad data"));
    end

    repeat (`NUM_OF_TRANSFERS) begin
      cs_activate_time = cs_instr_time.pop_back();
      cs_deactivate_time = cs_instr_time.pop_back();
    end
    if ((cs_activate_time != expected_cs_activate_time)) begin
      `FATAL(("CS Delay Test FAILED: unexpected chip select activate instruction duration. Expected=%d, Got=%d",expected_cs_activate_time,cs_activate_time));
    end
    if (cs_deactivate_time != expected_cs_deactivate_time) begin
      `FATAL(("CS Delay Test FAILED: unexpected chip select deactivate instruction duration. Expected=%d, Got=%d",expected_cs_deactivate_time,cs_deactivate_time));
    end
    `INFO(("CS Delay Test PASSED"), ADI_VERBOSITY_LOW);

    #2000ns
    dma_api.transfer_start();

    spi_api.offload_mem_assert_reset();
    spi_api.offload_mem_deassert_reset();
    spi_api.fifo_offload_command(`SET_CS_DELAY(8'hFE,cs_activate_delay));
    spi_api.fifo_offload_command(`INST_RD);
    spi_api.fifo_offload_command(`SET_CS_DELAY(8'hFF,cs_deactivate_delay));
    spi_api.fifo_offload_command(`INST_SYNC | 2);

    // breakdown: cs_activate_delay*(1+`CLOCK_DIVIDER)*2, times 2 since it's before and after cs transition, and added 3 cycles (1 for each timer comparison, plus one for fetching next instruction)
    expected_cs_activate_time = 2+2*cs_activate_delay*(1+`CLOCK_DIVIDER)*2;
    expected_cs_deactivate_time = 2+2*cs_deactivate_delay*(1+`CLOCK_DIVIDER)*2;

    // Enqueue transfers to DUT
    for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
      temp_data = $urandom;
      spi_send(temp_data);
      offload_sdi_data_store_arr[i] = temp_data;
    end

    #100ns
    spi_api.start_offload();
    `INFO(("Offload started (with delay on CS change)."), ADI_VERBOSITY_LOW);

    spi_wait_send();

    spi_api.stop_offload();
    `INFO(("Offload stopped (with delay on CS change)."), ADI_VERBOSITY_LOW);

    #2000ns

    for (int i=0; i<=((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1); i=i+1) begin
      offload_captured_word_arr[i][`DATA_DLENGTH-1:0] = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(xil_axi_uint'(`DDR_BA + 4*i));
    end

    if (irq_pending == 'h0) begin
      `FATAL(("IRQ Test FAILED"));
    end else begin
      `INFO(("IRQ Test PASSED"), ADI_VERBOSITY_LOW);
    end

    if (offload_captured_word_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) - 1:0] !== offload_sdi_data_store_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) - 1:0]) begin
      `FATAL(("CS Delay Test FAILED: bad data"));
    end
    repeat (`NUM_OF_TRANSFERS) begin
      cs_activate_time = cs_instr_time.pop_back();
      cs_deactivate_time = cs_instr_time.pop_back();
    end
    if ((cs_activate_time != expected_cs_activate_time)) begin
      `FATAL(("CS Delay Test FAILED: unexpected chip select activate instruction duration. Expected=%d, Got=%d",expected_cs_activate_time,cs_activate_time));
    end
    if (cs_deactivate_time != expected_cs_deactivate_time) begin
      `FATAL(("CS Delay Test FAILED: unexpected chip select deactivate instruction duration. Expected=%d, Got=%d",expected_cs_deactivate_time,cs_deactivate_time));
    end
    `INFO(("CS Delay Test PASSED"), ADI_VERBOSITY_LOW);
  endtask

endprogram
