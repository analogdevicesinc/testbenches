// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2025 (c) Analog Devices, Inc. All rights reserved.
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

package spi_engine_api_pkg;

  import logger_pkg::*;
  import adi_api_pkg::*;
  import adi_regmap_spi_engine_pkg::*;
  import adi_regmap_pkg::*;
  import m_axi_sequencer_pkg::*;

  class spi_engine_api extends adi_api;

    protected logic [31:0] val;

    function new(
      input string name,
      input m_axi_sequencer_base bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, bus, base_address, parent);
    endfunction


    task sanity_test();
      reg [31:0] data;
      // version
      this.axi_verify(GetAddrs(AXI_SPI_ENGINE_VERSION),
        `SET_AXI_SPI_ENGINE_VERSION_VERSION_MAJOR(`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MAJOR) |
        `SET_AXI_SPI_ENGINE_VERSION_VERSION_MINOR(`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MINOR) |
        `SET_AXI_SPI_ENGINE_VERSION_VERSION_PATCH(`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_PATCH));
      // scratch
      data = 32'hdeadbeef;
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_SCRATCH), `SET_AXI_SPI_ENGINE_SCRATCH_SCRATCH(data));
      this.axi_verify(GetAddrs(AXI_SPI_ENGINE_SCRATCH), `SET_AXI_SPI_ENGINE_SCRATCH_SCRATCH(data));
    endtask

    task enable_spi_engine();
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));
    endtask

    task disable_spi_engine();
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(1));
    endtask

    task fifo_command(input bit [31:0] cmd);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_AXI_SPI_ENGINE_CMD_FIFO_CMD_FIFO(cmd));
    endtask

    task fifo_offload_command(input bit [31:0] cmd);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO_OFFLOAD0_CDM_FIFO(cmd));
    endtask

    task sdo_offload_fifo_write(input bit [31:0] data);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO), `SET_AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO_OFFLOAD0_SDO_FIFO(data));
    endtask

    task sdo_fifo_write(input bit [31:0] data);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_SDO_FIFO), `SET_AXI_SPI_ENGINE_SDO_FIFO_SDO_FIFO(data));
    endtask

    task sdi_fifo_read(output logic [31:0] data);
      this.axi_read(GetAddrs(AXI_SPI_ENGINE_SDI_FIFO), val);
      data = `GET_AXI_SPI_ENGINE_SDI_FIFO_SDI_FIFO(val);
    endtask

    task start_offload();
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(1));
    endtask

    task stop_offload();
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(0));
    endtask

    task get_sync_id(output logic [31:0] sync_id);
      this.axi_read(GetAddrs(AXI_SPI_ENGINE_SYNC_ID), val);
      sync_id = `GET_AXI_SPI_ENGINE_SYNC_ID_SYNC_ID(val);
    endtask

    task get_irq_pending(output logic [31:0] irq_pending);
      this.axi_read(GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), val);
      irq_pending = `GET_AXI_SPI_ENGINE_IRQ_PENDING_IRQ_PENDING(val);
    endtask

    task clear_irq_pending(input bit [31:0] irq_pending);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), `SET_AXI_SPI_ENGINE_IRQ_PENDING_IRQ_PENDING(irq_pending));
    endtask

    task set_interrup_mask(
      input bit cmd_almost_empty = 1'b0,
      input bit sdo_almost_empty = 1'b0,
      input bit sdi_almost_full = 1'b0,
      input bit sync_event = 1'b0,
      input bit offload_sync_id_pending = 1'b0);

      this.axi_write(GetAddrs(AXI_SPI_ENGINE_IRQ_MASK),
        `SET_AXI_SPI_ENGINE_IRQ_MASK_CMD_ALMOST_EMPTY(cmd_almost_empty) |
        `SET_AXI_SPI_ENGINE_IRQ_MASK_SDO_ALMOST_EMPTY(sdo_almost_empty) |
        `SET_AXI_SPI_ENGINE_IRQ_MASK_SDI_ALMOST_FULL(sdi_almost_full) |
        `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(sync_event) |
        `SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(offload_sync_id_pending));
    endtask

    function bit[31:0] check_irq_cmd_almost_empty(input bit[31:0] irq_pending);
      return `SET_AXI_SPI_ENGINE_IRQ_MASK_CMD_ALMOST_EMPTY(irq_pending);
    endfunction

    function bit[31:0] check_irq_sdo_almost_empty(input bit[31:0] irq_pending);
      return `SET_AXI_SPI_ENGINE_IRQ_MASK_SDO_ALMOST_EMPTY(irq_pending);
    endfunction

    function bit[31:0] check_irq_sdi_almost_full(input bit[31:0] irq_pending);
      return `SET_AXI_SPI_ENGINE_IRQ_MASK_SDI_ALMOST_FULL(irq_pending);
    endfunction

    function bit[31:0] check_irq_sync_event(input bit[31:0] irq_pending);
      return `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(irq_pending);
    endfunction

    function bit[31:0] check_irq_offload_sync_id_pending(input bit[31:0] irq_pending);
      return `GET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(irq_pending);
    endfunction

    task peek_sdi_fifo(output logic [31:0] data);
      this.axi_read(GetAddrs(AXI_SPI_ENGINE_SDI_FIFO_PEEK), val);
      data = `GET_AXI_SPI_ENGINE_SDI_FIFO_PEEK_SDI_FIFO_PEEK(val);
    endtask

  endclass

endpackage
