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
import adi_regmap_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_pwm_gen_pkg::*;
import adi_regmap_spi_engine_pkg::*;
import spi_engine_instr_pkg::*;
import adi_spi_vip_pkg::*;
import axi_vip_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

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

  // --------------------------
  // Wrapper function for AXI read verify
  // --------------------------
  task axi_read_v(
      input   [31:0]  raddr,
      input   [31:0]  vdata);
    base_env.mng.sequencer.RegReadVerify32(raddr,vdata);
  endtask

  task axi_read(
      input   [31:0]  raddr,
      output  [31:0]  data);
    base_env.mng.sequencer.RegRead32(raddr,data);
  endtask

  // --------------------------
  // Wrapper function for AXI write
  // --------------------------
  task axi_write(
      input [31:0]  waddr,
      input [31:0]  wdata);
    base_env.mng.sequencer.RegWrite32(waddr,wdata);
  endtask

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

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

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

    sanity_test();

    #100ns

    fifo_init_test();

    fifo_single_read_test();

    fifo_double_write_test();

    fifo_double_read_test();

    fifo_double_write_test();

    offload_spi_test();

    #100ns

    spi_env.stop();
    base_env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  //---------------------------------------------------------------------------
  // Sanity test reg interface
  //---------------------------------------------------------------------------

  task sanity_test();
    bit [31:0] pcore_version = (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_PATCH)
                              | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MINOR)<<8
                              | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MAJOR)<<16;
    //axi_read_v (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_VERSION), pcore_version);
    axi_write  (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
    axi_read_v (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
    `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // SPI Engine generate transfer
  //---------------------------------------------------------------------------

  task generate_init_transfer_cmd(
      input [7:0] sync_id);
    // configure cs
    if (`CS_ACTIVE_HIGH) begin
      axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS_INV_MASK(8'hFF));
    end
    // write cfg
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_CFG);
    // assert CSN
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS(8'hFE));
    // write prescaler
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_PRESCALE);
    // write dlen
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_DLENGTH);
    // transfer data
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_WR);
    // de-assert CSN
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS(8'hFF));
    // SYNC command to generate interrupt
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`INST_SYNC | sync_id));
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
  endtask

  task generate_single_rtransfer_cmd(
      input [7:0] sync_id);
    // configure cs
    if (`CS_ACTIVE_HIGH) begin
      axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS_INV_MASK(8'hFF));
    end
    // write cfg
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_CFG);
    // assert CSN
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS(8'hFE));
    // write prescaler
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_PRESCALE);
    // write dlen
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_DLENGTH);
    // transfer data
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`INST_RD & 16'hFF00));
    // de-assert CSN
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS(8'hFF));
    // SYNC command to generate interrupt
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`INST_SYNC | sync_id));
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
  endtask


  task generate_double_rtransfer_cmd(
      input [7:0] sync_id);
    // configure cs
    if (`CS_ACTIVE_HIGH) begin
      axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS_INV_MASK(8'hFF));
    end
    // write cfg
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_CFG);
    // assert CSN
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS(8'hFE));
    // write prescaler
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_PRESCALE);
    // write dlen
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_DLENGTH);
    // transfer data
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`INST_RD & 16'hFF00));
    // transfer data
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`INST_RD & 16'hFF00));
    // de-assert CSN
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS(8'hFF));
    // SYNC command to generate interrupt
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`INST_SYNC | sync_id));
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
  endtask

  task generate_double_wtransfer_cmd(
      input [7:0] sync_id);
    // configure cs
    if (`CS_ACTIVE_HIGH) begin
      axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS_INV_MASK(8'hFF));
    end
    // write cfg
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_CFG);
    // assert CSN
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS(8'hFE));
    // write prescaler
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_PRESCALE);
    // write dlen
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_DLENGTH);
    // transfer data
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`INST_WR & 16'hFF00));
    // transfer data
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`INST_WR & 16'hFF00));
    // de-assert CSN
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS(8'hFF));
    // SYNC command to generate interrupt
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`INST_SYNC | sync_id));
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

      axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
      // IRQ launched by Offload SYNC command
      if (irq_pending & 5'b10000) begin
        axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
        `INFO(("Offload SYNC %d IRQ. An offload transfer just finished.",  sync_id), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by SYNC command
      if (irq_pending & 5'b01000) begin
        axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
        `INFO(("SYNC %d IRQ. FIFO transfer just finished.", sync_id), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by SDI FIFO
      if (irq_pending & 5'b00100) begin
        `INFO(("SDI FIFO IRQ."), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by SDO FIFO
      if (irq_pending & 5'b00010) begin
        `INFO(("SDO FIFO IRQ."), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by SDO FIFO
      if (irq_pending & 5'b00001) begin
        `INFO(("CMD FIFO IRQ."), ADI_VERBOSITY_LOW);
      end
      // Clear all pending IRQs
      axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
    end
  end

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
    // Start spi clk generator
    axi_write (`SPI_ENGINE_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
      `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
      `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
      );

    // Enable SPI Engine
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));

    // Set up the interrupts
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_MASK),
      `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(1) |
      `SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(1)
      );

    #100ns

    // send cmd before data
    generate_init_transfer_cmd(1);

    // write sdo fifo
    for (int i = 0; i<(`NUM_OF_WORDS) ; i=i+1) begin
      tx_data = ((i%6) == 5) ? 8'hFE : 8'hFF;
      axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDO_FIFO), (tx_data));// << (`DATA_WIDTH - `DATA_DLENGTH)));
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

    #100ns

    // send cmd before data
    generate_double_wtransfer_cmd(1);

    // write sdo fifo
    for (int i = 0; i<(2) ; i=i+1) begin
      tx_data = $urandom;
      axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDO_FIFO), (tx_data));// << (`DATA_WIDTH - `DATA_DLENGTH)));
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

    #100ns



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
      axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDI_FIFO), sdi_2_fifo_data[i]);
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

    #100ns

    rx_data = $urandom;
    spi_send(rx_data);
    sdi_1_fifo_data_store = rx_data;

    generate_single_rtransfer_cmd(1);

    `INFO(("Wait for SPI VIP data send"), ADI_VERBOSITY_LOW);
    spi_wait_send();
    `INFO(("SPI sent"), ADI_VERBOSITY_LOW);

    spi_receive(foo); // dummy tx, just for clearing the VIP queue
    axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDI_FIFO), sdi_1_fifo_data);

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
    axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
    axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('d105)); // set PWM period
    axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
    `INFO(("axi_pwm_gen started."), ADI_VERBOSITY_LOW);

    //Configure DMA
    base_env.mng.sequencer.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1));
    base_env.mng.sequencer.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_FLAGS),
      `SET_DMAC_FLAGS_TLAST(1) |
      `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
      ); // Use TLAST
    base_env.mng.sequencer.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH(((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*4)-1));
    base_env.mng.sequencer.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_DEST_ADDRESS), `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA));
    base_env.mng.sequencer.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    // Configure the Offload module
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_CFG);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS(8'hFE));
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_PRESCALE);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_DLENGTH);
    if (`CS_ACTIVE_HIGH) begin
      axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS_INV_MASK(8'hFF));
    end
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_WRD);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS(8'hFF));
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_DLENGTH);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_SYNC | 2);

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
          axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO), sdo_write_data_store[i]);
        end else begin
          sdo_write_data_store[i] = sdo_write_data_store[i%(`NUM_OF_WORDS)];
        end
      `endif
    end

    // Start the offload
    #100ns
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(1));
    `INFO(("Offload started."), ADI_VERBOSITY_LOW);

    spi_wait_send();

    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(0));

    `INFO(("Offload stopped."), ADI_VERBOSITY_LOW);

    #2000ns

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

endprogram
