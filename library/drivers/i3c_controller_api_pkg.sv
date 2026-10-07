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

package i3c_controller_api_pkg;

  import logger_pkg::*;
  import adi_component_pkg::*;
  import adi_api_pkg::*;
  import adi_regmap_i3c_controller_pkg::*;
  import adi_regmap_pkg::*;
  import m_axi_sequencer_pkg::*;

  class i3c_controller_api extends adi_api;

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
      this.axi_verify(GetAddrs(i3c_controller_host_interface_VERSION),
        `SET_i3c_controller_host_interface_VERSION_VERSION_MAJOR(`DEFAULT_i3c_controller_host_interface_VERSION_VERSION_MAJOR) |
        `SET_i3c_controller_host_interface_VERSION_VERSION_MINOR(`DEFAULT_i3c_controller_host_interface_VERSION_VERSION_MINOR) |
        `SET_i3c_controller_host_interface_VERSION_VERSION_PATCH(`DEFAULT_i3c_controller_host_interface_VERSION_VERSION_PATCH));
      // scratch
      data = 32'hdeadbeef;
      this.axi_write(GetAddrs(i3c_controller_host_interface_SCRATCH), `SET_i3c_controller_host_interface_SCRATCH_SCRATCH(data));
      this.axi_verify(GetAddrs(i3c_controller_host_interface_SCRATCH), `SET_i3c_controller_host_interface_SCRATCH_SCRATCH(data));
    endtask

    task enable_controller();
      this.axi_write(GetAddrs(i3c_controller_host_interface_ENABLE), `SET_i3c_controller_host_interface_ENABLE_ENABLE(1'b0));
    endtask

    task disable_controller();
      this.axi_write(GetAddrs(i3c_controller_host_interface_ENABLE), `SET_i3c_controller_host_interface_ENABLE_ENABLE(1'b1));
    endtask

    task set_ops(
      input bit status_nop,
      input bit [1:0] speed_grade,
      input bit [3:0] offload_length,
      input bit mode);

      this.axi_write(GetAddrs(i3c_controller_host_interface_OPS),
        `SET_i3c_controller_host_interface_OPS_OPS_STATUS_NOP(status_nop) |
        `SET_i3c_controller_host_interface_OPS_OPS_SPEED_GRADE(speed_grade) |
        `SET_i3c_controller_host_interface_OPS_OPS_OFFLOAD_LENGTH(offload_length) |
        `SET_i3c_controller_host_interface_OPS_OPS_MODE(mode));
    endtask

    task get_irq_pending(output logic [31:0] irq_pending);
      this.axi_read(GetAddrs(i3c_controller_host_interface_IRQ_PENDING), irq_pending);
    endtask

    task set_irq_pending(input bit [31:0] irq_pending);
      this.axi_write(GetAddrs(i3c_controller_host_interface_IRQ_PENDING), irq_pending);
    endtask

    task configure_ibi(
      input bit listen,
      input bit enable);

      this.axi_write(GetAddrs(i3c_controller_host_interface_IBI_CONFIG),
        `SET_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_LISTEN(listen) |
        `SET_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_ENABLE(enable));
    endtask

    task set_irq_mask(
      input bit daa_pending,
      input bit ibi_pending,
      input bit cmdr_pending,
      input bit ibi_almost_full,
      input bit sdi_almost_full,
      input bit sdo_almost_empty,
      input bit cmdr_almost_full,
      input bit cmd_almost_empty);

      this.axi_write(GetAddrs(i3c_controller_host_interface_IRQ_MASK),
        `SET_i3c_controller_host_interface_IRQ_MASK_DAA_PENDING(daa_pending) |
        `SET_i3c_controller_host_interface_IRQ_MASK_IBI_PENDING(ibi_pending) |
        `SET_i3c_controller_host_interface_IRQ_MASK_CMDR_PENDING(cmdr_pending) |
        `SET_i3c_controller_host_interface_IRQ_MASK_IBI_ALMOST_FULL(ibi_almost_full) |
        `SET_i3c_controller_host_interface_IRQ_MASK_SDI_ALMOST_FULL(sdi_almost_full) |
        `SET_i3c_controller_host_interface_IRQ_MASK_SDO_ALMOST_EMPTY(sdo_almost_empty) |
        `SET_i3c_controller_host_interface_IRQ_MASK_CMDR_ALMOST_FULL(cmdr_almost_full) |
        `SET_i3c_controller_host_interface_IRQ_MASK_CMD_ALMOST_EMPTY(cmd_almost_empty));
    endtask

    task set_cmd_fifo(
      input bit [31:0] instruction,
      input bit [6:0] address = 7'h0);

      this.axi_write(GetAddrs(i3c_controller_host_interface_CMD_FIFO),
        instruction |
        `SET_i3c_controller_host_interface_CMD_FIFO_CMD_DA(address));
    endtask

    task get_cmdr_fifo(output logic [31:0] data);
      this.axi_read(GetAddrs(i3c_controller_host_interface_CMDR_FIFO), data);
    endtask

    task write_sdo_fifo_data_32_bit(input bit [31:0] data);
      this.axi_write(GetAddrs(i3c_controller_host_interface_SDO_FIFO), data);
    endtask

    task write_sdo_fifo_data_4_byte(
      input bit [7:0] data0,
      input bit [7:0] data1,
      input bit [7:0] data2,
      input bit [7:0] data3);

      this.axi_write(GetAddrs(i3c_controller_host_interface_SDO_FIFO),
        `SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_0(data0) |
        `SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_1(data1) |
        `SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_2(data2) |
        `SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_3(data3));
    endtask

    task read_sdi_fifo(output logic [31:0] data);
      this.axi_read(GetAddrs(i3c_controller_host_interface_SDI_FIFO), data);
    endtask

    task read_ibi_fifo(output logic [31:0] data);
      this.axi_read(GetAddrs(i3c_controller_host_interface_IBI_FIFO), data);
    endtask

    task set_dev_char(
      input bit [6:0] addr,
      input bit wen,
      input bit has_ibi_mdb,
      input bit is_ibi_capable,
      input bit is_attached,
      input bit is_i2c);

      this.axi_write(GetAddrs(i3c_controller_host_interface_DEV_CHAR),
        `SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_ADDR(addr) |
        `SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_WEN(wen) |
        `SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_HAS_IBI_MDB(has_ibi_mdb) |
        `SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_IBI_CAPABLE(is_ibi_capable) |
        `SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_ATTACHED(is_attached) |
        `SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_I2C(is_i2c));
    endtask

    task read_dev_char(output logic [31:0] data);
      this.axi_read(GetAddrs(i3c_controller_host_interface_DEV_CHAR), data);
    endtask

    task write_offload_cmd(
      input bit [3:0] slot,
      input bit [31:0] data);

      this.axi_write(GetAddrs(i3c_controller_host_interface_OFFLOAD_CMD_n) + 'h4 * slot, data);
    endtask

    task write_offload_sdo(
      input bit [3:0] slot,
      input bit [31:0] data);

      this.axi_write(GetAddrs(i3c_controller_host_interface_OFFLOAD_SDO_n) + 'h4 * slot, data);
    endtask

  endclass

endpackage
