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

// Bound into every altera_avalon_mm_slave_bfm instance (see
// adi_intel_vip_bind), it answers the BFM commands from a sparse byte memory.
// The slave BFM is expected in SYMBOLS addressing mode, without write
// responses.
interface adi_avmm_slave_bfm_if #(
  int AV_SYMBOL_W = 8,
      AV_NUMSYMBOLS = 4
);

  import adi_avmm_bfm_if_base_pkg::*;
  import avalon_mm_pkg::*;

  localparam AV_DATA_W = AV_SYMBOL_W * AV_NUMSYMBOLS;

  logic [7:0] mem [bit [63:0]];

  bit debug = 0;

  int unsigned wr_beats;
  int unsigned rd_beats;
  bit [63:0] wr_first, wr_last;
  bit [63:0] rd_first, rd_last;

  function automatic void count_access(
    input bit write,
    input bit [63:0] addr,
    input int burst_count);

    bit [63:0] end_addr = addr + burst_count*AV_NUMSYMBOLS - 1;

    if (write) begin
      if (wr_beats == 0 || addr < wr_first) wr_first = addr;
      if (wr_beats == 0 || end_addr > wr_last) wr_last = end_addr;
      wr_beats += burst_count;
    end else begin
      if (rd_beats == 0 || addr < rd_first) rd_first = addr;
      if (rd_beats == 0 || end_addr > rd_last) rd_last = end_addr;
      rd_beats += burst_count;
    end
  endfunction: count_access

  function automatic logic [7:0] mem_read(input bit [63:0] addr);
    return mem.exists(addr) ? mem[addr] : 8'h00;
  endfunction: mem_read

  task automatic serve();
    bit [63:0] addr;
    logic [AV_DATA_W-1:0] data;
    logic [AV_NUMSYMBOLS-1:0] byte_enable;
    int burst_count;

    forever begin
      @(posedge altera_avalon_mm_slave_bfm.clk);
      while (altera_avalon_mm_slave_bfm.get_command_queue_size() > 0) begin
        altera_avalon_mm_slave_bfm.pop_command();
        addr = altera_avalon_mm_slave_bfm.get_command_address();
        burst_count = altera_avalon_mm_slave_bfm.get_command_burst_count();

        if (altera_avalon_mm_slave_bfm.get_command_request() == REQ_WRITE) begin
          count_access(1, addr, burst_count);
          if (debug) begin
            $display("[DDR] @ %0t: write 0x%h, %0d beats, first beat %h", $time, addr, burst_count,
              altera_avalon_mm_slave_bfm.get_command_data(0));
          end
          for (int beat = 0; beat < burst_count; beat++) begin
            data = altera_avalon_mm_slave_bfm.get_command_data(beat);
            byte_enable = altera_avalon_mm_slave_bfm.get_command_byte_enable(beat);
            for (int i = 0; i < AV_NUMSYMBOLS; i++) begin
              if (byte_enable[i]) begin
                mem[addr + beat*AV_NUMSYMBOLS + i] = data[8*i+:8];
              end
            end
          end
        end else begin
          count_access(0, addr, burst_count);
          if (debug) begin
            $display("[DDR] @ %0t: read 0x%h, %0d beats", $time, addr, burst_count);
          end
          // The request type has to be set first, the latency setter checks it.
          altera_avalon_mm_slave_bfm.set_response_request(REQ_READ);
          altera_avalon_mm_slave_bfm.set_response_burst_size(burst_count);
          for (int beat = 0; beat < burst_count; beat++) begin
            for (int i = 0; i < AV_NUMSYMBOLS; i++) begin
              data[8*i+:8] = mem_read(addr + beat*AV_NUMSYMBOLS + i);
            end
            altera_avalon_mm_slave_bfm.set_response_data(data, beat);
            altera_avalon_mm_slave_bfm.set_response_latency(0, beat);
          end
          altera_avalon_mm_slave_bfm.push_response();
        end
      end
    end
  endtask: serve

  class adi_avmm_slave_bfm_if_class extends adi_avmm_slave_bfm_if_base;

    protected process serve_p;

    function new();
    endfunction

    virtual task start();
      fork
        begin
          this.serve_p = process::self();
          serve();
        end
      join_none
    endtask: start

    virtual task stop();
      if (this.serve_p != null) begin
        this.serve_p.kill();
        this.serve_p = null;
      end
    endtask: stop

    virtual function void set_debug(input bit enable);
      debug = enable;
    endfunction: set_debug

    virtual function void clear_stats();
      wr_beats = 0;
      rd_beats = 0;
    endfunction: clear_stats

    virtual function string get_stats();
      return $sformatf("%0d write beats [0x%h - 0x%h], %0d read beats [0x%h - 0x%h], %0d bytes per beat",
        wr_beats, wr_first, wr_last, rd_beats, rd_first, rd_last, AV_NUMSYMBOLS);
    endfunction: get_stats

    virtual function logic [31:0] backdoor_read32(input bit [63:0] addr);
      for (int i = 0; i < 4; i++) begin
        backdoor_read32[8*i+:8] = mem_read(addr + i);
      end
    endfunction: backdoor_read32

    virtual function void backdoor_write32(
      input bit [63:0] addr,
      input logic [31:0] data,
      input bit [3:0] strb);

      for (int i = 0; i < 4; i++) begin
        if (strb[i]) begin
          mem[addr + i] = data[8*i+:8];
        end
      end
    endfunction: backdoor_write32

  endclass: adi_avmm_slave_bfm_if_class

  adi_avmm_slave_bfm_if_class vif = new();

endinterface: adi_avmm_slave_bfm_if
