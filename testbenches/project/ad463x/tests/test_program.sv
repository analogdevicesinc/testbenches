// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2025 Analog Devices, Inc. All rights reserved.
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
//

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
program test_program (
  input ad463x_irq,
  output logic ad463x_echo_sclk,
  input ad463x_spi_sclk,
  input ad463x_spi_cs,
  input ad463x_spi_clk,
  input [(`NUM_OF_SDI - 1):0] ad463x_spi_sdi);

  timeunit 1ns;
  timeprecision 100ps;

  // declare the class instances
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  spi_environment spi_env;
  spi_engine_api spi_api;
  dmac_api dma_api;
  pwm_gen_api pwm_api;
  clk_gen_api clkgen_api;

  //---------------------------------------------------------------------------
  // Echo SCLK generation - we need this only if ECHO_SCLK is enabled
  //---------------------------------------------------------------------------
  // `ifdef DEF_ECHO_SCLK
    // assign #(`ECHO_SCLK_DELAY * 1ns) ad463x_echo_sclk = ad463x_spi_sclk;
  // `endif
  // assign #18ns ad463x_echo_sclk = ad463x_spi_sclk;
  // initial begin
  //   forever begin
  //     ad463x_echo_sclk = 0;
  //     @(ad463x_spi_sclk);
  //     #18ns ad463x_echo_sclk = ad463x_spi_sclk;
  //   end
  // end

  // --------------------------
  // Wrapper function for SPI receive (from DUT)
  // --------------------------
  task automatic spi_receive(
      ref int unsigned  data[]);
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

  bit   [              7:0]  sdi_lane_mask;
  bit   [              7:0]  sdo_lane_mask;
  bit   [`DATA_DLENGTH-1:0]  sdi_fifo_data [];
  bit   [`DATA_DLENGTH-1:0]  sdo_fifo_data [];
  bit   [`DATA_DLENGTH-1:0]  sdi_fifo_data_store [];
  bit   [`DATA_DLENGTH-1:0]  sdo_fifo_data_store [];
  bit   [`DATA_DLENGTH-1:0]  rx_data [];
  bit   [`DATA_DLENGTH-1:0]  tx_data [];
  logic [  `DATA_WIDTH-1:0]  rx_data_cast [];
  int unsigned               tx_data_cast [];
  int unsigned               receive_data [];
  int num_of_active_sdo_lanes = $countones(`SDO_LANE_MASK);

  // --------------------------
  // Main procedure
  // --------------------------
  initial begin

    setLoggerVerbosity(ADI_VERBOSITY_HIGH);

    //creating environment
    base_env = new("AD463X Environment",
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
                  `SPI_AD463X_REGMAP_BA);

    dma_api = new("RX DMA API",
                  base_env.mng.sequencer,
                  `AD463X_DMA_BA);

    clkgen_api = new("CLKGEN API",
                    base_env.mng.sequencer,
                    `AD463X_AXI_CLKGEN_BA);

    pwm_api = new("PWM API",
                  base_env.mng.sequencer,
                  `AD463X_PWM_GEN_BA);

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

    #100ns;

    sdi_lane_mask = {`NUM_OF_SDI{1'b1}};
    sdo_lane_mask = 8'h1;
    num_of_active_sdo_lanes = $countones(sdo_lane_mask);
    // spi_api.fifo_command(`SET_SDI_LANE_MASK(sdi_lane_mask));//guarantee all SDI lanes must be active
    // spi_api.fifo_command(`SET_SDO_LANE_MASK(sdo_lane_mask));
    // fifo_spi_test();

    #100ns;

    offload_spi_test();

    spi_env.stop();
    base_env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  //---------------------------------------------------------------------------
  // SPI Engine generate transfer
  //---------------------------------------------------------------------------
  task generate_transfer_cmd(
      input [7:0] sync_id,
      input [7:0] sdi_lane_mask,
      input [7:0] sdo_lane_mask);

    // define spi lane mask
    spi_api.fifo_command(`SET_SDI_LANE_MASK(sdi_lane_mask));
    spi_api.fifo_command(`SET_SDO_LANE_MASK(sdo_lane_mask));
    // assert CSN
    spi_api.fifo_command(`SET_CS(8'hFE));
    // transfer data
    spi_api.fifo_command(`INST_WRD);
    // de-assert CSN
    spi_api.fifo_command(`SET_CS(8'hFF));
    // SYNC command to generate interrupt
    spi_api.fifo_command((`INST_SYNC | sync_id));
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // IRQ callback
  //---------------------------------------------------------------------------
  reg [4:0] irq_pending = 0;
  reg [7:0] sync_id = 0;

  initial begin
    forever begin
      @(posedge ad463x_irq);
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
  // Sanity Tests
  //---------------------------------------------------------------------------
  task sanity_tests();
    spi_api.sanity_test();
    dma_api.sanity_test();
    pwm_api.sanity_test();
  endtask

  //---------------------------------------------------------------------------
  // Offload SPI Test
  //---------------------------------------------------------------------------
  localparam int num_of_dma_transfers = (`NUM_OF_SDI > 1) ? 2 : 1;
  localparam int num_of_spi_transfers = (`DDR_EN) ? 2 * `NUM_OF_TRANSFERS : `NUM_OF_TRANSFERS;
  localparam int local_data_width = (`NUM_OF_SDI > 1) ? (`NUM_OF_SDI * 32) : 64;

  int index;
  bit [   `DATA_DLENGTH-1:0] sdi_read_data [];
  bit [   `DATA_DLENGTH-1:0] sdi_read_data_store [];
  bit [     `DATA_WIDTH-1:0] sdo_write_data [];
  bit [   `DATA_DLENGTH-1:0] sdo_write_data_store [];
  bit [local_data_width-1:0] data_unscrambled;

  bit [63:0] data_scrambled;
  // this mask is based on the spi_axis_reorder.v scrambling patterns
  bit [31:0] data_mask = (`NUM_OF_SDI == 4) ? (32'hFFFF) :
                         (`NUM_OF_SDI == 8) ? (32'hFF) : 32'hFFFFFFFF;

  task offload_spi_test();

    rx_data              = new [`NUM_OF_SDI];
    sdi_read_data        = new [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*(`NUM_OF_SDI)];
    sdi_read_data_store  = new [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*(`NUM_OF_SDI)];

    //Configure DMA
    dma_api.enable_dma();
    dma_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1)
    );
    dma_api.set_lengths(((`NUM_OF_TRANSFERS) * (`NUM_OF_WORDS) * num_of_dma_transfers * (`DATA_WIDTH/8))-1,0); // X_LENGTH = 1024-1
    dma_api.set_dest_addr(`DDR_BA);
    dma_api.transfer_start();

    // Configure the Offload module
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

    // Enqueue transfers to DUT
    for (int i = 0, idx = 0; i < (num_of_spi_transfers*(`NUM_OF_WORDS)); i++) begin
      // only even i's are actually stored, odd i's are dummy reads for the DDR
      // this is a workaround for the SPI VIP/SPI offload not supporting DDR,
      // so we need to generate double of SPI transfers
      for (int j = 0; j < (`NUM_OF_SDI); j++) begin
        rx_data[j] = {$urandom} & data_mask;
        if (`DDR_EN) begin
          if (i % 2 == 0) begin
            sdi_read_data_store[idx * (`NUM_OF_SDI) + j]  = rx_data[j];
          end
        end else begin
          sdi_read_data_store[i * (`NUM_OF_SDI) + j]  = rx_data[j];
        end
      end
      if (i % 2 == 0) begin
        idx++;
      end

      spi_send(rx_data);
    end

    #100ns;
    spi_api.start_offload();
    `INFO(("Offload started."), ADI_VERBOSITY_LOW);
    spi_wait_send();
    spi_api.stop_offload();
    `INFO(("Offload stopped."), ADI_VERBOSITY_LOW);

    #2000ns;

    if (irq_pending == 'h0) begin
      `FATAL(("IRQ Test FAILED"));
    end else begin
      `INFO(("IRQ Test PASSED"), ADI_VERBOSITY_LOW);
    end

    for (int i = 0, offset = 0; i < ((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*num_of_dma_transfers); i+=2, offset+=(`NUM_OF_SDI)) begin
      // it is necessary to read 64 bits (two four-byte reads) for unscrambling, the output may be
      // 1, 2, 3 or 4 SDI lanes. Each one has its own scrambling pattern based on spi_axis_reorder.sv
      data_scrambled = {base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(xil_axi_uint'(`DDR_BA + 4*(i+1))),
              base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(xil_axi_uint'(`DDR_BA + 4*i))};
        `INFO(("data_scrambled[63:32]: %x;", data_scrambled[63:32]), ADI_VERBOSITY_LOW);
        `INFO(("data_scrambled[31:0]: %x", data_scrambled[31:0]), ADI_VERBOSITY_LOW);
        `INFO(("data_scrambled[63:0]: %x;", data_scrambled[63:0]), ADI_VERBOSITY_LOW);

      if (`NUM_OF_SDI == 1) begin
        // For 1 SDI lane, there are two possible outputs
        // NO_REORDER == 1, bypass the spi_axis_reorder.sv module
        // NO_REORDER == 0, data needs to be unscrambled
        data_unscrambled = 0;
        for (int k = 0; k < 32; k++) begin
          data_unscrambled[2*k]   = data_scrambled[32+k]; //even bits
          data_unscrambled[2*k+1] = data_scrambled[k];    //odd bits
        end

        for (int j = 0; j < 2; j++) begin
          sdi_read_data[i + j] = (`NO_REORDER) ? data_scrambled[j*32+:32] : data_unscrambled[j*32+:32];
          `INFO(("sdi_read_data[%d]: %x", i + j, sdi_read_data[i + j]), ADI_VERBOSITY_LOW);
          `INFO(("sdi_read_data_store[%d]: %x", i + j, sdi_read_data_store[i + j]), ADI_VERBOSITY_LOW);
        end
      end else if (`NUM_OF_SDI == 2) begin
        // For 2 SDI lanes, spi_axis_reorder.sv does not scramble
        for (int j = 0; j < `NUM_OF_SDI; j++) begin
          sdi_read_data[i + j] = data_scrambled[j*32+:32];
          `INFO(("sdi_read_data[%d]: %x", i + j, sdi_read_data[i + j]), ADI_VERBOSITY_LOW);
          `INFO(("sdi_read_data_store[%d]: %x", i + j, sdi_read_data_store[i + j]), ADI_VERBOSITY_LOW);
        end
      end else if (`NUM_OF_SDI == 4) begin
        // For 4 SDI lanes, data needs to be unscrambled
        // Every 16 bits represents a lane
        data_unscrambled = 0;
        for (int k = 0; k < 16; k++) begin
          data_unscrambled[k]    = data_scrambled[2*k+1];
          data_unscrambled[32+k] = data_scrambled[2*k];
          data_unscrambled[64+k] = data_scrambled[2*k+33];
          data_unscrambled[96+k] = data_scrambled[2*k+32];
        end

        for (int j = 0; j < `NUM_OF_SDI; j++) begin
          sdi_read_data[offset + j] = data_unscrambled[j*32+:32];
          `INFO(("sdi_read_data[%d]: %x", offset + j, sdi_read_data[offset + j]), ADI_VERBOSITY_LOW);
          `INFO(("sdi_read_data_store[%d]: %x", offset + j, sdi_read_data_store[offset + j]), ADI_VERBOSITY_LOW);
        end
      end else if (`NUM_OF_SDI == 8) begin
        // For 4 SDI lanes, data needs to be unscrambled
        // Every 8 bits represents a lane
        data_unscrambled = 0;
        for (int k = 0; k < 8; k++) begin
          data_unscrambled[k]     = data_scrambled[4*k+3];
          data_unscrambled[32+k]  = data_scrambled[4*k+2];
          data_unscrambled[64+k]  = data_scrambled[4*k+1];
          data_unscrambled[96+k]  = data_scrambled[4*k];
          data_unscrambled[128+k] = data_scrambled[4*k+35];
          data_unscrambled[160+k] = data_scrambled[4*k+34];
          data_unscrambled[192+k] = data_scrambled[4*k+33];
          data_unscrambled[224+k] = data_scrambled[4*k+32];
        end
        for (int j = 0; j < `NUM_OF_SDI; j++) begin
          sdi_read_data[offset + j] = data_unscrambled[j*32+:32];
          `INFO(("sdi_read_data[%d]: %x", offset + j, sdi_read_data[offset + j]), ADI_VERBOSITY_LOW);
          `INFO(("sdi_read_data_store[%d]: %x", offset + j, sdi_read_data_store[offset + j]), ADI_VERBOSITY_LOW);
        end
      end
      index = (`NUM_OF_SDI == 1) ? i : offset;
      for (int j = 0; j < `NUM_OF_SDI; j++) begin
        if (sdi_read_data[index + j] != sdi_read_data_store[index + j]) begin //one word at a time comparison
          `INFO(("sdi_read_data[%d]: %x; sdi_read_data_store[%d]: %x",
          index + j, sdi_read_data[index + j],
          index + j, sdi_read_data_store[index + j]), ADI_VERBOSITY_LOW);
          `FATAL(("Offload Read Test FAILED"));
        end
      end
    end

    `INFO(("Offload Read Test PASSED"), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // FIFO SPI Test
  //---------------------------------------------------------------------------
  task fifo_spi_test();

    rx_data_cast        = new [(`NUM_OF_SDI)];
    rx_data             = new [(`NUM_OF_SDI)];
    sdi_fifo_data       = new [(`NUM_OF_SDI) * `NUM_OF_WORDS];
    sdi_fifo_data_store = new [(`NUM_OF_SDI) * `NUM_OF_WORDS];
    tx_data             = new [num_of_active_sdo_lanes];
    tx_data_cast        = new [num_of_active_sdo_lanes];
    receive_data        = new [`NUM_OF_SDO];
    sdo_fifo_data       = new [`NUM_OF_SDO * `NUM_OF_WORDS];
    sdo_fifo_data_store = new [`NUM_OF_SDO * `NUM_OF_WORDS];

    // Generate a FIFO transaction, write SDO first
    for (int i = 0; i < (`NUM_OF_WORDS); i++) begin
      for (int j = 0; j < (`NUM_OF_SDI); j++) begin
        rx_data[j]      = sdo_lane_mask[j] ? 16'habcd : `SDO_IDLE_STATE;//$urandom : `SDO_IDLE_STATE;
        sdi_fifo_data_store[i * (`NUM_OF_SDI) + j] = rx_data[j];
      end

      for (int j = 0; j < num_of_active_sdo_lanes; j++) begin
        tx_data[j]      = $urandom;
        tx_data_cast[j] = tx_data[j]; //a cast is necessary for the SPI API
      end

      for (int j = 0, k = 0; j < `NUM_OF_SDO; j++) begin
        if (sdo_lane_mask[j]) begin
          sdo_fifo_data_store[i * `NUM_OF_SDO + j] = tx_data[k];
          k++;
        end else begin
          sdo_fifo_data_store[i * `NUM_OF_SDO + j] = `SDO_IDLE_STATE;
        end
      end

      spi_api.sdo_fifo_write((tx_data_cast));// << API is expecting 32 bits, only active lanes are written
      spi_send(rx_data);
    end

    generate_transfer_cmd(1, sdi_lane_mask, sdo_lane_mask); //generate transfer with specific spi lane mask

    `INFO(("Waiting for SPI VIP send..."), ADI_VERBOSITY_LOW);
    spi_wait_send();
    `INFO(("SPI sent"), ADI_VERBOSITY_LOW);

    for (int i = 0; i < (`NUM_OF_WORDS); i++) begin
      spi_api.sdi_fifo_read(rx_data_cast); //API always returns 32 bits
      spi_receive(receive_data);
      for (int j = 0; j < (`NUM_OF_SDI); j++) begin
        sdi_fifo_data[i * (`NUM_OF_SDI) + j] = rx_data_cast[j];
      end
      for (int j = 0; j < (`NUM_OF_SDO); j++) begin
        sdo_fifo_data[i * (`NUM_OF_SDO) + j] = receive_data[j];
      end
    end

    foreach (sdi_fifo_data[i]) begin
      if (sdi_fifo_data[i] !== sdi_fifo_data_store[i]) begin
        `INFO(("sdi_fifo_data: %x; sdi_fifo_data_store %x", sdi_fifo_data[i], sdi_fifo_data_store[i]), ADI_VERBOSITY_LOW);
        `FATAL(("Fifo Read Test FAILED"));
      end
    end
    `INFO(("Fifo Read Test PASSED"), ADI_VERBOSITY_LOW);

    foreach (sdo_fifo_data[i]) begin
      if (sdo_fifo_data[i] !== sdo_fifo_data_store[i]) begin
        `INFO(("sdo_fifo_data: %x; sdo_fifo_data_store %x", sdo_fifo_data[i], sdo_fifo_data_store[i]), ADI_VERBOSITY_LOW);
        `FATAL(("Fifo Write Test FAILED"));
      end
    end
    `INFO(("Fifo Write Test PASSED"), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // Test initialization
  //---------------------------------------------------------------------------
  task init();
    // Start spi clk generator
    clkgen_api.enable_clkgen();

    // Config pwm
    pwm_api.reset();
    pwm_api.pulse_period_config(0, ('h64 * 'd16) - 'h0); // config channel 0 period
    pwm_api.pulse_period_config(1, ('h64 * 'd4) - 'h0); // config channel 1 period
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

endprogram
