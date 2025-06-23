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
program test_lanes (
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
  bit   [`DATA_DLENGTH-1:0]  tx_data [];
  logic [  `DATA_WIDTH-1:0]  rx_data_cast [];
  int unsigned               tx_data_cast [];
  int unsigned               receive_data [];
  int num_of_active_sdi_lanes = $countones(`SDI_LANE_MASK);
  int num_of_active_sdo_lanes = $countones(`SDO_LANE_MASK);

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

    #100ns;

    fifo_spi_test();
    sdi_lane_mask = (2 ** `NUM_OF_SDI)-1;
    sdo_lane_mask = (2 ** `NUM_OF_SDO)-1;
    spi_api.fifo_command(`SET_SDI_LANE_MASK(sdi_lane_mask));//guarantee all SDI lanes must be active
    spi_api.fifo_command(`SET_SDO_LANE_MASK(sdo_lane_mask));//guarantee all SDO lanes must be active

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
    spi_api.fifo_command(`INST_SYNC | sync_id);
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
  // Offload SPI Test
  //---------------------------------------------------------------------------
  bit [`DATA_DLENGTH-1:0] sdi_read_data [];
  bit [`DATA_DLENGTH-1:0] sdi_read_data_store [];
  bit [  `DATA_WIDTH-1:0] sdo_write_data [];
  bit [`DATA_DLENGTH-1:0] sdo_write_data_store [];

  task offload_spi_test();

    tx_data_cast         = new [`NUM_OF_SDO];
    tx_data              = new [`NUM_OF_SDO];
    sdo_write_data       = new [`NUM_OF_SDO];
    rx_data              = new [`NUM_OF_SDI];
    sdi_read_data        = new [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*(`NUM_OF_SDI)];
    sdi_read_data_store  = new [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*(`NUM_OF_SDI)];

    `ifdef DEF_SDO_STREAMING
      sdo_write_data_store = new [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*(`NUM_OF_SDO)];
    `else
      sdo_write_data_store = new [(`NUM_OF_WORDS)*(`NUM_OF_SDO)];
    `endif

    //Configure DMA
    dma_api.enable_dma();
    dma_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1)
    );
    dma_api.set_lengths(((`NUM_OF_TRANSFERS) * (`NUM_OF_WORDS) * (`NUM_OF_SDI) * (`DATA_WIDTH/8))-1,0);
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
    spi_api.fifo_offload_command(`INST_WRD);
    spi_api.fifo_offload_command(`SET_CS(8'hFF));
    spi_api.fifo_offload_command(`INST_SYNC | 2);

    // Enqueue transfers to DUT
    for (int i = 0; i < ((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)); i++) begin
      for (int j = 0; j < (`NUM_OF_SDI); j++) begin
        rx_data[j] = $urandom;
        sdi_read_data_store[i * (`NUM_OF_SDI) + j]  = rx_data[j];
      end

      spi_send(rx_data);

      for (int j = 0; j < (`NUM_OF_SDO); j++) begin
        tx_data[j] = $urandom;
        tx_data_cast[j] = tx_data[j];
      end
      
      `ifdef DEF_SDO_STREAMING
        sdo_stream_gen(tx_data);
        for (int j = 0; j < `NUM_OF_SDO; j++) begin
          sdo_write_data_store[i * (`NUM_OF_SDO) + j] = tx_data[j]; // all of the random words will be used
        end
      `else
        if (i < (`NUM_OF_WORDS)) begin
          for (int j = 0; j < `NUM_OF_SDO; j++) begin
            sdo_write_data_store[i * (`NUM_OF_SDO) + j] = tx_data[j]; //only the first NUM_OF_WORDS random words will be used for all transfers
          end
          spi_api.sdo_offload_fifo_write(tx_data_cast);
        end
      `endif
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

    for (int i = 0; i < ((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*(`NUM_OF_SDI)); i++) begin
      sdi_read_data[i] = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(xil_axi_uint'(`DDR_BA + 4*i));
      if (sdi_read_data[i] != sdi_read_data_store[i]) begin //one word at a time comparison
        `INFO(("sdi_read_data[%d]: %x; sdi_read_data_store[%d]: %x",
        i, sdi_read_data[i],
        i, sdi_read_data_store[i]), ADI_VERBOSITY_LOW);
        `FATAL(("Offload Read Test FAILED"));
      end
    end
    `INFO(("Offload Read Test PASSED"), ADI_VERBOSITY_LOW);

    for (int i = 0; i < (`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS); i++) begin
      spi_receive(sdo_write_data);
      for (int j = 0; j < `NUM_OF_SDO; j++) begin
        `ifdef DEF_SDO_STREAMING
          if (sdo_write_data[j] != sdo_write_data_store[(i * `NUM_OF_SDO + j)]) begin
            `INFO(("sdo_write_data[%d]: %x; sdo_write_data_store[%d]: %x",
                        j, sdo_write_data[j],
                        (i * `NUM_OF_SDO + j),
                        sdo_write_data_store[(i * `NUM_OF_SDO + j)]), ADI_VERBOSITY_LOW);
            `FATAL(("Offload Write Test FAILED"));
          end
        `else
          if (sdo_write_data[j] != sdo_write_data_store[(i * `NUM_OF_SDO + j) % (`NUM_OF_WORDS * `NUM_OF_SDO)]) begin
            `INFO(("sdo_write_data[%d]: %x; sdo_write_data_store[%d]: %x",
                        j, sdo_write_data[j],
                        ((i * `NUM_OF_SDO + j) % (`NUM_OF_WORDS * `NUM_OF_SDO)),
                        sdo_write_data_store[(i * `NUM_OF_SDO + j) % (`NUM_OF_WORDS * `NUM_OF_SDO)]), ADI_VERBOSITY_LOW);
            `FATAL(("Offload Write Test FAILED"));
          end
        `endif
      end
    end
    `INFO(("Offload Write Test PASSED"), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // FIFO SPI Test
  //---------------------------------------------------------------------------
  task fifo_spi_test();

    //This test forces a wrong lane mask, then generates data
    //and much time later starts execution with the correct lane mask
    spi_api.fifo_command(`SET_SDI_LANE_MASK(8'hC)); //wrong lane mask on purpose
    spi_api.fifo_command(`SET_SDO_LANE_MASK(8'hE)); //wrong lane mask on purpose
    sdi_lane_mask       = 8'h1; //new mask defining the active lanes (right lane mask)
    sdo_lane_mask       = 8'h8; //new mask defining the active lanes (right lane mask)
    num_of_active_sdi_lanes = $countones(sdi_lane_mask);
    num_of_active_sdo_lanes = $countones(sdo_lane_mask);

    rx_data_cast        = new [num_of_active_sdi_lanes];
    rx_data             = new [(`NUM_OF_SDI)];
    sdi_fifo_data       = new [num_of_active_sdi_lanes * `NUM_OF_WORDS];
    sdi_fifo_data_store = new [num_of_active_sdi_lanes * `NUM_OF_WORDS];
    tx_data             = new [num_of_active_sdo_lanes];
    tx_data_cast        = new [num_of_active_sdo_lanes];
    receive_data        = new [`NUM_OF_SDO];
    sdo_fifo_data       = new [`NUM_OF_SDO * `NUM_OF_WORDS];
    sdo_fifo_data_store = new [`NUM_OF_SDO * `NUM_OF_WORDS];
    
    // Generate a FIFO transaction, write SDO first
    for (int i = 0; i < (`NUM_OF_WORDS); i++) begin
      for (int j = 0, k = 0; j < (`NUM_OF_SDI); j++) begin
        rx_data[j]      = sdi_lane_mask[j] ? $urandom : `SDO_IDLE_STATE; //easier to debug
        if (sdi_lane_mask[j]) begin
          sdi_fifo_data_store[i * num_of_active_sdi_lanes + k] = rx_data[j];
          k++;
        end
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

    //wait a long time before starting execution with the correct lane mask
    #500ns;
    generate_transfer_cmd(1, sdi_lane_mask, sdo_lane_mask); //generate transfer with specific spi lane mask

    `INFO(("Waiting for SPI VIP send..."), ADI_VERBOSITY_LOW);
    spi_wait_send();
    `INFO(("SPI sent"), ADI_VERBOSITY_LOW);

    for (int i = 0; i < (`NUM_OF_WORDS); i++) begin
      spi_api.sdi_fifo_read(rx_data_cast); //API always returns 32 bits
      spi_receive(receive_data);
      for (int j = 0; j < num_of_active_sdi_lanes; j++) begin
        sdi_fifo_data[i * num_of_active_sdi_lanes + j] = rx_data_cast[j];
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

endprogram
