// ***************************************************************************
// ***************************************************************************
// Copyright 2021 (c) Analog Devices, Inc. All rights reserved.
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

`define DO_ADDR_VERSION                 32'h00000
`define DO_ADDR_ID                      32'h00004
`define DO_ADDR_SCRATCH                 32'h00008
`define DO_ADDR_MAGIC                   32'h0000C
`define DO_ADDR_MEM_TYPE                32'h00010
`define DO_ADDR_MEM_SIZE_LSB            32'h00014
`define DO_ADDR_MEM_SIZE_MSB            32'h00018
`define DO_ADDR_TRANSFER_LENGTH         32'h0001C
`define DO_ADDR_DDR_CALIB_DONE          32'h00080
`define DO_ADDR_CONTROL_1               32'h00084
`define DO_ADDR_CONTROL_2               32'h00088
`define DO_ADDR_SYNC                    32'h00100
`define DO_ADDR_SYNC_CONFIG             32'h00104
`define DO_ADDR_DBG_FSM                 32'h00200
`define DO_ADDR_DBG_SMP_LSB_COUNTER     32'h00204
`define DO_ADDR_DBG_SMP_MSB_COUNTER     32'h00208

`define	DO_CORE_VERSION 			          32'h00000100
`define	DO_CORE_MAGIC   			          32'h44414F46

package data_offload_pkg;

  import axi_vip_pkg::*;
  import reg_accessor_pkg::*;
  import logger_pkg::*;

  class data_offload;
    reg_accessor  bus;
    xil_axi_ulong base_address;

    bit [1:0] reg_control;

    function new (reg_accessor bus, xil_axi_ulong base_address);
      this.bus = bus;
      this.base_address = base_address;
    endfunction

    task set_oneshot(input bit oneshot);
      this.reg_control[1] = oneshot;
      this.bus.RegWrite32(this.base_address + `DO_ADDR_CONTROL_2, {30'b0, this.reg_control});
    endtask : set_oneshot;

    task set_bypass(input bit bypass);
      this.reg_control[0] = bypass;
      this.bus.RegWrite32(this.base_address + `DO_ADDR_CONTROL_2, {30'b0, this.reg_control});
    endtask : set_bypass;

    task set_resetn(input bit resetn);
      this.bus.RegWrite32(this.base_address + `DO_ADDR_CONTROL_1, {31'b0, resetn});
    endtask : set_resetn;

    task set_transfer_length(input bit [33:0] length);
      if (length & 34'h3f) begin
        // Transfer length not divisble by 64
        `ERROR(("data_offload: Attempted to set transfer_length %x mod 64 != 0!", length));
      end
      `INFO(("data_offload: Writing transfer length! %x", length));
      this.bus.RegWrite32(this.base_address + `DO_ADDR_TRANSFER_LENGTH, length >> 6);
    endtask : set_transfer_length;

    task set_sync_config(input bit [1:0] sync_config);
      if (sync_config == 3)
        `ERROR(("data_offload: Invalid sync_config mode 3 requested!"));

      this.bus.RegWrite32(this.base_address + `DO_ADDR_SYNC_CONFIG, {30'h0, sync_config});
    endtask : set_sync_config;

    task trigger_sync();
      this.bus.RegWrite32(this.base_address + `DO_ADDR_SYNC_CONFIG, 32'h1);
    endtask : trigger_sync;

  endclass

endpackage
