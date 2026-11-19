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

// Bound into every altera_avalon_mm_master_bfm instance (see
// adi_intel_vip_bind), it reaches the BFM API through an upward reference to
// the bind target. The master BFM is expected in SYMBOLS addressing mode.
interface adi_avmm_master_bfm_if;

  import adi_avmm_bfm_if_base_pkg::*;
  import avalon_mm_pkg::*;

  semaphore transfer_s = new(1);

  // One transaction in flight at a time, so the response that is popped is
  // always the one of the command that was pushed.
  task automatic transfer(
    input Request_t request,
    input bit [63:0] addr,
    inout bit [31:0] data);

    transfer_s.get(1);

    altera_avalon_mm_master_bfm.set_command_request(request);
    altera_avalon_mm_master_bfm.set_command_address(addr);
    altera_avalon_mm_master_bfm.set_command_byte_enable('1, 0);
    altera_avalon_mm_master_bfm.set_command_burst_count(1);
    altera_avalon_mm_master_bfm.set_command_burst_size(1);
    altera_avalon_mm_master_bfm.set_command_data(data, 0);
    altera_avalon_mm_master_bfm.set_command_idle(0, 0);
    altera_avalon_mm_master_bfm.set_command_init_latency(0);
    altera_avalon_mm_master_bfm.push_command();

    while (altera_avalon_mm_master_bfm.get_response_queue_size() == 0) begin
      @(posedge altera_avalon_mm_master_bfm.clk);
    end
    altera_avalon_mm_master_bfm.pop_response();

    if (request == REQ_READ) begin
      data = altera_avalon_mm_master_bfm.get_response_data(0);
    end

    transfer_s.put(1);
  endtask: transfer

  class adi_avmm_master_bfm_if_class extends adi_avmm_master_bfm_if_base;

    function new();
    endfunction

    virtual task write32(
      input bit [63:0] addr,
      input bit [31:0] data);

      bit [31:0] wdata = data;

      transfer(REQ_WRITE, addr, wdata);
    endtask: write32

    virtual task read32(
      input bit [63:0] addr,
      output bit [31:0] data);

      bit [31:0] rdata = '0;

      transfer(REQ_READ, addr, rdata);
      data = rdata;
    endtask: read32

  endclass: adi_avmm_master_bfm_if_class

  adi_avmm_master_bfm_if_class vif = new();

endinterface: adi_avmm_master_bfm_if
