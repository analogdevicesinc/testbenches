// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2023-2025 Analog Devices, Inc. All rights reserved.
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
program test_david (
  inout spi_engine_irq,
  inout spi_engine_spi_sclk,
  inout [(`NUM_OF_CS - 1):0] spi_engine_spi_cs,
  inout spi_engine_spi_clk,
  `ifdef DEF_ECHO_SCLK
    inout spi_engine_echo_sclk,
  `endif
  inout [(`NUM_OF_SDI-1):0] spi_engine_spi_sdi);

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
  `ifdef DEF_ECHO_SCLK
    assign #(`ECHO_SCLK_DELAY * 1ns) spi_engine_echo_sclk = spi_engine_spi_sclk;
  `endif

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
  bit   [`DATA_DLENGTH-1:0]  dummy_rx_data [];
  bit   [`DATA_DLENGTH-1:0]  tx_data [];
  logic [  `DATA_WIDTH-1:0]  rx_data_cast [];
  logic [  `DATA_WIDTH-1:0]  dummy_rx_data_cast [];
  int unsigned               tx_data_cast [];
  int unsigned               receive_data [];
  int num_of_active_sdi_lanes = $countones(`SDI_LANE_MASK);
  int num_of_active_sdo_lanes = $countones(`SDO_LANE_MASK);
  logic [31:0] sdi_fifo_level;

  // --------------------------
  // Main procedure
  // --------------------------
  initial begin

    setLoggerVerbosity(ADI_VERBOSITY_LOW);

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

    #100ns;

    fifo_spi_test();

    #1000ns

    fifo_spi_test();

    spi_env.stop();
    base_env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  //---------------------------------------------------------------------------
  // SPI Engine generate transfer
  //---------------------------------------------------------------------------
  task generate_transfer_cmd(
      input [7:0] sync_id);

    // config CPOL=1, CPHA=0
    spi_api.fifo_command(`INST_CFG);
    // assert CSN
    spi_api.fifo_command(`SET_CS(8'hFE));
    // sleep a while
    spi_api.fifo_command(`SLEEP(8'h0E));
    // deassert CSN
    spi_api.fifo_command(`SET_CS(8'hFF));
    // sleep a while
    spi_api.fifo_command(`SLEEP(8'h00));
    // assert CSN again
    spi_api.fifo_command(`SET_CS(8'hFE));
    // set lane masks
    spi_api.fifo_command(`SET_SDI_LANE_MASK(8'h0F));
    spi_api.fifo_command(`SET_SDO_LANE_MASK(8'h0F));
    // config xfer len
    spi_api.fifo_command(`INST_DLENGTH);
    // transfer data
    spi_api.fifo_command(`INST_RD);
    // de-assert CSN
    spi_api.fifo_command(`SET_CS(8'hFF));
    // set lane masks
    spi_api.fifo_command(`SET_SDI_LANE_MASK(8'h01));
    spi_api.fifo_command(`SET_SDO_LANE_MASK(8'h01));
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // SPI Engine SDO data
  //---------------------------------------------------------------------------
  task sdo_stream_gen(
      input [`DATA_DLENGTH-1:0] tx_data[]);
    xil_axi4stream_data_byte data[((`DATA_WIDTH/8) * (`NUM_OF_SDO))-1:0];
    `ifdef DEF_SDO_STREAMING
      for (int i = 0; i < `NUM_OF_SDO; i++) begin
        for (int j = 0; j < (`DATA_WIDTH/8); j++) begin
          data[i * (`DATA_WIDTH/8) + j] = (tx_data[i] & (8'hFF << 8*j)) >> 8*j;
          spi_env.sdo_src_agent.sequencer.push_byte_for_stream(data[i * (`DATA_WIDTH/8) + j]);
        end
      end
      spi_env.sdo_src_agent.sequencer.add_xfer_descriptor_byte_count((`DATA_WIDTH/8) * (`NUM_OF_SDO),0,0);
    `endif
  endtask

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
  // Sanity Tests
  //---------------------------------------------------------------------------
  task sanity_tests();
    spi_api.sanity_test();
    dma_api.sanity_test();
    pwm_api.sanity_test();
  endtask

  //---------------------------------------------------------------------------
  // FIFO SPI Test
  //---------------------------------------------------------------------------
  task fifo_spi_test();

    sdi_lane_mask       = {`NUM_OF_SDI{1'b1}};
    sdo_lane_mask       = {`NUM_OF_SDO{1'b1}};
    num_of_active_sdi_lanes = $countones(sdi_lane_mask);
    num_of_active_sdo_lanes = $countones(sdo_lane_mask);

    rx_data_cast        = new [num_of_active_sdi_lanes];
    rx_data             = new [(`NUM_OF_SDI)];
    dummy_rx_data       = new [(`NUM_OF_SDI)]; // gen data for all lanes, even if we're using a single one
    dummy_rx_data_cast  = new [1];
    sdi_fifo_data       = new [num_of_active_sdi_lanes * `NUM_OF_WORDS];
    sdi_fifo_data_store = new [num_of_active_sdi_lanes * `NUM_OF_WORDS];
    tx_data             = new [num_of_active_sdo_lanes];
    tx_data_cast        = new [num_of_active_sdo_lanes];
    receive_data        = new [`NUM_OF_SDO];
    sdo_fifo_data       = new [`NUM_OF_SDO * `NUM_OF_WORDS];
    sdo_fifo_data_store = new [`NUM_OF_SDO * `NUM_OF_WORDS];

    // simple single lane transfer before the actual test
    for (int i = 0; i < (`NUM_OF_SDI); i++) begin
      dummy_rx_data[i] = $urandom; // gen data for all lanes, even if we're using a single one
    end
    spi_send(dummy_rx_data);
    spi_api.fifo_command(`SET_CS(8'hFE));
    // set lane masks
    spi_api.fifo_command(`SET_SDI_LANE_MASK(8'h01));
    spi_api.fifo_command(`SET_SDO_LANE_MASK(8'h01));
    // transfer data
    spi_api.fifo_command(`INST_RD);
    // deassert CSN
    spi_api.fifo_command(`SET_CS(8'hFF));
    spi_wait_send();
    spi_api.sdi_fifo_read(dummy_rx_data_cast);

    sdi_fifo_data[0] = dummy_rx_data_cast[0];

    if (sdi_fifo_data[0] != dummy_rx_data[0]) begin
      `INFO(("rx_data_cast: %x; dummy_rx_data: %x", rx_data_cast, dummy_rx_data[0]), ADI_VERBOSITY_LOW);
      `INFO(("Dummy Fifo Read FAILED ???"), ADI_VERBOSITY_LOW);
    end

    // wait a looong time
    #10000ns

    // Generate a FIFO transaction, write SDO first
    for (int i = 0; i < (`NUM_OF_WORDS); i++) begin
      for (int j = 0, k = 0; j < (`NUM_OF_SDI); j++) begin
        rx_data[j]      = sdi_lane_mask[j] ? $urandom : `SDO_IDLE_STATE; //easier to debug
        if (sdi_lane_mask[j]) begin
          sdi_fifo_data_store[i * num_of_active_sdi_lanes + k] = rx_data[j];
          k++;
        end
      end

      // for (int j = 0; j < num_of_active_sdo_lanes; j++) begin
      //   tx_data[j]      = $urandom;
      //   tx_data_cast[j] = tx_data[j]; //a cast is necessary for the SPI API
      // end

      // for (int j = 0, k = 0; j < `NUM_OF_SDO; j++) begin
      //   if (sdo_lane_mask[j]) begin
      //     sdo_fifo_data_store[i * `NUM_OF_SDO + j] = tx_data[k];
      //     k++;
      //   end else begin
      //     sdo_fifo_data_store[i * `NUM_OF_SDO + j] = `SDO_IDLE_STATE;
      //   end
      // end

      // spi_api.sdo_fifo_write((tx_data_cast));// << API is expecting 32 bits, only active lanes are written
      spi_send(rx_data);
    end

    spi_api.get_sdi_fifo_level(sdi_fifo_level);
    `INFO(("sdi_fifo_level before transfer: %d", sdi_fifo_level), ADI_VERBOSITY_LOW);
    generate_transfer_cmd(1);

    `INFO(("Waiting for SPI VIP send..."), ADI_VERBOSITY_LOW);
    spi_wait_send();
    `INFO(("SPI sent"), ADI_VERBOSITY_LOW);

    spi_api.get_sdi_fifo_level(sdi_fifo_level);
    `INFO(("sdi_fifo_level after transfer: %d", sdi_fifo_level), ADI_VERBOSITY_LOW);

    for (int i = 0; i < (`NUM_OF_WORDS); i++) begin
      spi_api.sdi_fifo_read(rx_data_cast); //API always returns 32 bits
      // spi_receive(receive_data);
      for (int j = 0; j < num_of_active_sdi_lanes; j++) begin
        sdi_fifo_data[i * num_of_active_sdi_lanes + j] = rx_data_cast[j];
      end
      // for (int j = 0; j < (`NUM_OF_SDO); j++) begin
      //   sdo_fifo_data[i * (`NUM_OF_SDO) + j] = receive_data[j];
      // end
    end

    foreach (sdi_fifo_data[i]) begin
      if (sdi_fifo_data[i] !== sdi_fifo_data_store[i]) begin
        `INFO(("sdi_fifo_data[%d]: %x; sdi_fifo_data_store[%d]: %x", i, sdi_fifo_data[i], i, sdi_fifo_data_store[i]), ADI_VERBOSITY_LOW);
        `FATAL(("Fifo Read Test FAILED"));
      end
    end
    `INFO(("Fifo Read Test PASSED"), ADI_VERBOSITY_LOW);

    // foreach (sdo_fifo_data[i]) begin
    //   if (sdo_fifo_data[i] !== sdo_fifo_data_store[i]) begin
    //     `INFO(("sdo_fifo_data[%d]: %x; sdo_fifo_data_store[%d] %x", i, sdo_fifo_data[i], i, sdo_fifo_data_store[i]), ADI_VERBOSITY_LOW);
    //     `FATAL(("Fifo Write Test FAILED"));
    //   end
    // end
    // `INFO(("Fifo Write Test PASSED"), ADI_VERBOSITY_LOW);
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


    // Set up the interrupts
    spi_api.set_interrup_mask(.sync_event(1'b1),.offload_sync_id_pending(1'b1));

  endtask

endprogram
