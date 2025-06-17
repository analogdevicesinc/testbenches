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

program test_slowdata (
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

    #100ns;

    fifo_init_test();

    #100ns;

    fifo_single_read_test();

    #100ns;

    fifo_double_write_test();

    #100ns;

    fifo_double_read_test();

    #100ns;

    fifo_double_write_test();

    #100ns;

    offload_spi_test();

    #100ns;

    spi_env.stop();
    base_env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  //---------------------------------------------------------------------------
  // SPI Engine generate transfer
  //---------------------------------------------------------------------------

  task generate_init_transfer_cmd(
      input [7:0] sync_id);
    // configure cs
    if (`CS_ACTIVE_HIGH) begin
      spi_api.fifo_command(`SET_CS_INV_MASK(8'hFF));
    end
    // write cfg
    spi_api.fifo_command(`INST_CFG);
    // assert CSN
    spi_api.fifo_command(`SET_CS(8'hFE));
    // write prescaler
    spi_api.fifo_command(`INST_PRESCALE);
    // write dlen
    spi_api.fifo_command(`INST_DLENGTH);
    // transfer data
    spi_api.fifo_command(`INST_WR);
    // de-assert CSN
    spi_api.fifo_command(`SET_CS(8'hFF));
    // SYNC command to generate interrupt
    spi_api.fifo_command(`INST_SYNC | sync_id);
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
  endtask

  task generate_single_rtransfer_cmd(
      input [7:0] sync_id);
    // configure cs
    if (`CS_ACTIVE_HIGH) begin
      spi_api.fifo_command(`SET_CS_INV_MASK(8'hFF));
    end
    // write cfg
    spi_api.fifo_command(`INST_CFG);
    // assert CSN
    spi_api.fifo_command(`SET_CS(8'hFE));
    // write prescaler
    spi_api.fifo_command(`INST_PRESCALE);
    // write dlen
    spi_api.fifo_command(`INST_DLENGTH);
    // transfer data
    spi_api.fifo_command(`INST_RD & 16'hFF00);
    // de-assert CSN
    spi_api.fifo_command(`SET_CS(8'hFF));
    // SYNC command to generate interrupt
    spi_api.fifo_command(`INST_SYNC | sync_id);
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
  endtask


  task generate_double_rtransfer_cmd(
      input [7:0] sync_id);
    // configure cs
    if (`CS_ACTIVE_HIGH) begin
      spi_api.fifo_command(`SET_CS_INV_MASK(8'hFF));
    end
    // write cfg
    spi_api.fifo_command(`INST_CFG);
    // assert CSN
    spi_api.fifo_command(`SET_CS(8'hFE));
    // write prescaler
    spi_api.fifo_command(`INST_PRESCALE);
    // write dlen
    spi_api.fifo_command(`INST_DLENGTH);
    // transfer data
    spi_api.fifo_command(`INST_RD & 16'hFF00);
    // transfer data
    spi_api.fifo_command(`INST_RD & 16'hFF00);
    // de-assert CSN
    spi_api.fifo_command(`SET_CS(8'hFF));
    // SYNC command to generate interrupt
    spi_api.fifo_command(`INST_SYNC | sync_id);
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
  endtask

  task generate_double_wtransfer_cmd(
      input [7:0] sync_id);
    // configure cs
    if (`CS_ACTIVE_HIGH) begin
      spi_api.fifo_command(`SET_CS_INV_MASK(8'hFF));
    end
    // write cfg
    spi_api.fifo_command(`INST_CFG);
    // assert CSN
    spi_api.fifo_command(`SET_CS(8'hFE));
    // write prescaler
    spi_api.fifo_command(`INST_PRESCALE);
    // write dlen
    spi_api.fifo_command(`INST_DLENGTH);
    // transfer data
    spi_api.fifo_command(`INST_WR & 16'hFF00);
    // transfer data
    spi_api.fifo_command(`INST_WR & 16'hFF00);
    // de-assert CSN
    spi_api.fifo_command(`SET_CS(8'hFF));
    // SYNC command to generate interrupt
    spi_api.fifo_command(`INST_SYNC | sync_id);
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
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
  // SPI Engine SDO data
  //---------------------------------------------------------------------------

  task sdo_stream_gen(
      input [`DATA_DLENGTH:0]  tx_data);
    xil_axi4stream_data_byte data[(`DATA_WIDTH/8)-1:0];
    `ifdef DEF_SDO_STREAMING
      for (int i = 0; i<(`DATA_WIDTH/8);i++) begin
        data[i] = (tx_data & (8'hFF << 8*i)) >> 8*i;
        spi_env.sdo_src_agent.sequencer.push_byte_for_stream(data[i]);
      end
      spi_env.sdo_src_agent.sequencer.add_xfer_descriptor_byte_count((`DATA_WIDTH/8),0,0);
    `endif
  endtask

  //---------------------------------------------------------------------------
  // Echo SCLK generation - we need this only if ECHO_SCLK is enabled
  //---------------------------------------------------------------------------
  `ifdef DEF_ECHO_SCLK
    assign #(`ECHO_SCLK_DELAY * 1ns) spi_engine_echo_sclk = spi_engine_spi_sclk;
  `endif

  //---------------------------------------------------------------------------
  // FIFO SPI Test
  //---------------------------------------------------------------------------

  bit   [`DATA_DLENGTH-1:0]  sdi_fifo_data [`NUM_OF_WORDS-1:0]= '{default:'0};
  bit   [`DATA_DLENGTH-1:0]  sdo_fifo_data [`NUM_OF_WORDS-1:0]= '{default:'0};
  bit   [`DATA_DLENGTH-1:0]  sdi_fifo_data_store [`NUM_OF_WORDS-1:0];
  bit   [`DATA_DLENGTH-1:0]  sdo_fifo_data_store [`NUM_OF_WORDS-1:0];
  bit [`DATA_DLENGTH-1:0] rx_data;
  bit [`DATA_DLENGTH-1:0] tx_data;

  task fifo_init_test();

    // send cmd before data
    generate_init_transfer_cmd(1);

    // write sdo fifo
    for (int i = 0; i<(`NUM_OF_WORDS) ; i=i+1) begin
      tx_data = ((i%6) == 5) ? 8'hFE : 8'hFF;
      spi_api.sdo_fifo_write(tx_data);// << (`DATA_WIDTH - `DATA_DLENGTH)));
      sdo_fifo_data_store[i] = tx_data;
    end

    `INFO(("Wait for SPI VIP receiving data"), ADI_VERBOSITY_LOW);
    for (int i = 0; i<(`NUM_OF_WORDS) ; i=i+1) begin
      spi_receive(sdo_fifo_data[i]);
    end

    if (sdo_fifo_data !== sdo_fifo_data_store) begin
      `INFO(("sdo_fifo_data: %x; sdo_fifo_data_store %x", sdo_fifo_data, sdo_fifo_data_store), ADI_VERBOSITY_LOW);
      `FATAL(("Fifo Write Test FAILED"));
    end
    `INFO(("Fifo Write Test PASSED"), ADI_VERBOSITY_LOW);
  endtask

  bit   [`DATA_DLENGTH-1:0]  sdo_2_fifo_data [2-1:0]= '{default:'0};
  bit   [`DATA_DLENGTH-1:0]  sdo_2_fifo_data_store [2-1:0];
  task fifo_double_write_test();

    // send cmd before data
    generate_double_wtransfer_cmd(1);

    // write sdo fifo
    for (int i = 0; i<(2) ; i=i+1) begin
      tx_data = $urandom;
      spi_api.sdo_fifo_write(tx_data);// << (`DATA_WIDTH - `DATA_DLENGTH)));
      sdo_2_fifo_data_store[i] = tx_data;
    end

    `INFO(("Wait for SPI VIP receiving data"), ADI_VERBOSITY_LOW);
    for (int i = 0; i<(2) ; i=i+1) begin
      spi_receive(sdo_2_fifo_data[i]);
    end

    if (sdo_2_fifo_data !== sdo_2_fifo_data_store) begin
      `INFO(("sdo_2_fifo_data: %x; sdo_2_fifo_data_store %x", sdo_2_fifo_data, sdo_2_fifo_data_store), ADI_VERBOSITY_LOW);
      `FATAL(("Double Write Test FAILED"));
    end
    `INFO(("Double Write Test PASSED"), ADI_VERBOSITY_LOW);
  endtask

  bit   [`DATA_DLENGTH-1:0]  sdi_2_fifo_data [2-1:0]= '{default:'0};
  bit   [`DATA_DLENGTH-1:0]  sdi_2_fifo_data_store [2-1:0];
  bit   [`DATA_DLENGTH-1:0]  foo;

  task fifo_double_read_test();

    for (int i = 0; i<(2) ; i=i+1) begin
      rx_data = $urandom;
      spi_send(rx_data);
      sdi_2_fifo_data_store[i] = rx_data;
    end

    generate_double_rtransfer_cmd(1);

    `INFO(("Wait for SPI VIP data send"), ADI_VERBOSITY_LOW);
    spi_wait_send();
    `INFO(("SPI sent"), ADI_VERBOSITY_LOW);

    for (int i = 0; i<(2) ; i=i+1) begin
      spi_receive(foo); // dummy tx, just for clearing the VIP queue
      spi_api.sdi_fifo_read(sdi_2_fifo_data[i]);
    end

    if (sdi_2_fifo_data !== sdi_2_fifo_data_store) begin
      `INFO(("sdi_2_fifo_data: %x; sdi_2_fifo_data_store %x", sdi_2_fifo_data, sdi_2_fifo_data_store), ADI_VERBOSITY_LOW);
      `FATAL(("Double Read Test FAILED"));
    end
    `INFO(("Double Read Test PASSED"), ADI_VERBOSITY_LOW);
  endtask

  bit   [`DATA_DLENGTH-1:0]  sdi_1_fifo_data = '{default:'0};
  bit   [`DATA_DLENGTH-1:0]  sdi_1_fifo_data_store ;
  task fifo_single_read_test();

    rx_data = $urandom;
    spi_send(rx_data);
    sdi_1_fifo_data_store = rx_data;

    generate_single_rtransfer_cmd(1);

    `INFO(("Wait for SPI VIP data send"), ADI_VERBOSITY_LOW);
    spi_wait_send();
    `INFO(("SPI sent"), ADI_VERBOSITY_LOW);

    spi_receive(foo); // dummy tx, just for clearing the VIP queue
    spi_api.sdi_fifo_read(sdi_1_fifo_data);

    if (sdi_1_fifo_data !== sdi_1_fifo_data_store) begin
      `INFO(("sdi_1_fifo_data: %x; sdi_1_fifo_data_store %x", sdi_1_fifo_data, sdi_1_fifo_data_store), ADI_VERBOSITY_LOW);
      `FATAL(("Single Read Test FAILED"));
    end
    `INFO(("Single Read Test PASSED"), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // Offload SPI Test
  //---------------------------------------------------------------------------

  bit [`DATA_DLENGTH-1:0] sdi_read_data [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1 :0] = '{default:'0};
  bit [`DATA_DLENGTH-1:0] sdo_write_data [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1 :0] = '{default:'0};
  bit [`DATA_DLENGTH-1:0] sdi_read_data_store [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1 :0];
  bit [`DATA_DLENGTH-1:0] sdo_write_data_store [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1 :0];
  bit [`DATA_DLENGTH-1:0] rx_data;
  bit [`DATA_DLENGTH-1:0] tx_data;

  task offload_spi_test();

    // Config pwm
    pwm_api.reset();
    pwm_api.pulse_period_config(0,'d105); // config channel 0 period
    pwm_api.load_config();
    pwm_api.start();
    `INFO(("axi_pwm_gen started."), ADI_VERBOSITY_LOW);

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

    // Enqueue transfers transfers to DUT
    for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
      rx_data = $urandom;
      spi_send(rx_data);
      sdi_read_data_store[i]  = rx_data;
      tx_data = $urandom;
      `ifdef DEF_SDO_STREAMING
          sdo_stream_gen(tx_data);
          sdo_write_data_store[i] = tx_data;
      `else
        if (i<(`NUM_OF_WORDS)) begin
          sdo_write_data_store[i] = tx_data;
          spi_api.sdo_offload_fifo_write(sdo_write_data_store[i]);
        end else begin
          sdo_write_data_store[i] = sdo_write_data_store[i%(`NUM_OF_WORDS)];
        end
      `endif
    end

    // Start the offload
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

    for (int i=0; i<=((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1); i=i+1) begin
      sdi_read_data[i] = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(xil_axi_uint'(`DDR_BA + 4*i));
      if (sdi_read_data[i] != sdi_read_data_store[i]) begin
        `INFO(("sdi_read_data[%d]: %x; sdi_read_data_store[%d]: %x", i, sdi_read_data[i], i, sdi_read_data_store[i]), ADI_VERBOSITY_LOW);
        `FATAL(("Offload Read Test FAILED"));
      end
    end
    `INFO(("Offload Read Test PASSED"), ADI_VERBOSITY_LOW);

    for (int i=0; i<=((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1); i=i+1) begin
      spi_receive(sdo_write_data[i]);
      if (sdo_write_data[i] != sdo_write_data_store[i]) begin
        `INFO(("sdo_write_data[%d]: %x; sdo_write_data_store[%d]: %x", i, sdo_write_data[i], i, sdo_write_data_store[i]), ADI_VERBOSITY_LOW);
        `FATAL(("Offload Write Test FAILED"));
      end
    end
    `INFO(("Offload Write Test PASSED"), ADI_VERBOSITY_LOW);
  endtask

    //---------------------------------------------------------------------------
  // Test initialization
  //---------------------------------------------------------------------------

  task init();
    // Start spi clk generator
    clkgen_api.enable_clkgen();
    // Enable SPI Engine
    spi_api.enable_spi_engine();
    // Set up the interrupts
    spi_api.set_interrup_mask(.sync_event(1'b1),.offload_sync_id_pending(1'b1));
  endtask

endprogram
