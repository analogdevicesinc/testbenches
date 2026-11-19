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

`include "utils.svh"

// The package and base class keep the names of their AXI counterparts, the
// register drivers only depend on m_axi_sequencer_base and are shared with the
// AMD flow.
package m_axi_sequencer_pkg;

  import logger_pkg::*;
  import adi_vip_pkg::*;
  import adi_avmm_bfm_if_base_pkg::*;


  virtual class m_axi_sequencer_base extends adi_sequencer;

    local semaphore reader_s;
    local semaphore writer_s;

    local int reader_priority_counter;
    local int writer_priority_counter;

    local event reader_event;
    local event writer_event;

    function new(
      input string name,
      input adi_agent parent = null);

      super.new(name, parent);

      this.reader_s = new(1);
      this.writer_s = new(1);

      this.reader_priority_counter = 0;
      this.writer_priority_counter = 0;
    endfunction: new

    task automatic RegWrite32(
      input bit [63:0] addr = 0,
      input bit [31:0] data,
      input bit priority_packet = 0);

      if (priority_packet) begin
        this.writer_priority_counter++;
      end else begin
        while (this.writer_priority_counter) begin
          @this.writer_event;
        end
      end
      this.writer_s.get(1);
      this.info($sformatf("Writing to address 0x%h, value %h with priority %0x", addr , data, priority_packet), ADI_VERBOSITY_HIGH);

      this.single_write(addr, data);

      if (priority_packet) begin
        this.writer_priority_counter--;
        -> this.writer_event;
      end
      this.writer_s.put(1);
    endtask: RegWrite32

    task automatic RegRead32(
      input bit [63:0] addr = 0,
      output bit [31:0] data,
      input bit priority_packet = 0);

      if (priority_packet) begin
        this.reader_priority_counter++;
      end else begin
        while (this.reader_priority_counter) begin
          @this.reader_event;
        end
      end
      this.reader_s.get(1);

      this.single_read(addr, data);

      if (priority_packet) begin
        this.reader_priority_counter--;
        -> this.reader_event;
      end
      this.reader_s.put(1);

      this.info($sformatf(" Reading data %h from 0x%h with priority %0x", data, addr, priority_packet), ADI_VERBOSITY_HIGH);
    endtask: RegRead32

    task automatic RegReadVerify32(
      input bit [63:0] addr = 0,
      input bit [31:0] data,
      input bit priority_packet = 0);

      bit [31:0] data_out;

      this.RegRead32(
        .addr(addr),
        .data(data_out),
        .priority_packet(priority_packet));

      if (data !== data_out) begin
        this.error($sformatf("Data mismatch at address 0x%h; Read data is %h; expected is %h", addr, data_out, data));
      end
    endtask: RegReadVerify32

    protected pure virtual task automatic single_write(
      input bit [63:0] addr,
      input bit [31:0] data);

    protected pure virtual task automatic single_read(
      input bit [63:0] addr,
      output bit [31:0] data);

  endclass: m_axi_sequencer_base


  class m_avmm_sequencer extends m_axi_sequencer_base;

    protected adi_avmm_master_bfm_if_base bfm_if;

    function new(
      input string name,
      input adi_avmm_master_bfm_if_base bfm_if,
      input adi_agent parent = null);

      super.new(name, parent);

      this.bfm_if = bfm_if;
    endfunction: new

    protected task automatic single_write(
      input bit [63:0] addr,
      input bit [31:0] data);

      this.bfm_if.write32(addr, data);
    endtask: single_write

    protected task automatic single_read(
      input bit [63:0] addr,
      output bit [31:0] data);

      this.bfm_if.read32(addr, data);
    endtask: single_read

  endclass: m_avmm_sequencer

endpackage: m_axi_sequencer_pkg
