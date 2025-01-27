// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2025 Analog Devices, Inc. All rights reserved.
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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"
`include "axi_definitions.svh"

package s_axi_sequencer_pkg;

  import axi_vip_pkg::*;
  import adi_vip_pkg::*;
  import logger_pkg::*;


  class s_axi_sequencer_base extends adi_sequencer;

    function new(
      input string name,
      input adi_agent parent = null);
      
      super.new(name, parent);
    endfunction: new

    virtual task get_byte_from_mem(
      input xil_axi_ulong addr,
      output bit [7:0] data);

      this.fatal($sformatf("Base class was instantiated instead of the parameterized class!"));
    endtask: get_byte_from_mem

    virtual task set_byte_in_mem(
      input xil_axi_ulong addr,
      input bit [7:0] data);
      
      this.fatal($sformatf("Base class was instantiated instead of the parameterized class!"));
    endtask: set_byte_in_mem

    virtual task verify_byte(
      input xil_axi_ulong addr,
      input bit [7:0] refdata);
      
      this.fatal($sformatf("Base class was instantiated instead of the parameterized class!"));
    endtask: verify_byte

  endclass: s_axi_sequencer_base


  class s_axi_sequencer #(`AXI_VIP_PARAM_DECL(AXI)) extends s_axi_sequencer_base;

    xil_axi_slv_mem_model #(`AXI_VIP_PARAM_ORDER(AXI)) mem_model;

    function new(
      input string name,
      input xil_axi_slv_mem_model #(`AXI_VIP_PARAM_ORDER(AXI)) mem_model,
      input adi_agent parent = null);

      super.new(name, parent);
      
      this.mem_model = mem_model;
    endfunction: new

    task get_byte_from_mem(
      input xil_axi_ulong addr,
      output bit [7:0] data);

      bit [31:0] four_bytes;
      four_bytes = this.mem_model.backdoor_memory_read_4byte(addr);
      case (addr[1:0])
        2'b00: data = four_bytes[0+:8];
        2'b01: data = four_bytes[8+:8];
        2'b10: data = four_bytes[16+:8];
        2'b11: data = four_bytes[24+:8];
      endcase
    endtask: get_byte_from_mem

    task set_byte_in_mem(
      input xil_axi_ulong addr,
      input bit [7:0] data);

      bit [3:0] strb;
      case (addr[1:0])
        2'b00: strb = 'b0001;
        2'b01: strb = 'b0010;
        2'b10: strb = 'b0100;
        2'b11: strb = 'b1000;
      endcase
      this.mem_model.backdoor_memory_write_4byte(.addr(addr),
                                                  .payload({4{data}}),
                                                  .strb(strb));
    endtask: set_byte_in_mem

    task verify_byte(
      input xil_axi_ulong addr,
      input bit [7:0] refdata);
      
      bit [7:0] data;

      get_byte_from_mem (addr, data);
      if (data !== refdata) begin
        this.error($sformatf("Unexpected value at address %0h . Expected: %0h Found: %0h", addr, refdata, data));
      end
    endtask: verify_byte

  endclass: s_axi_sequencer

endpackage: s_axi_sequencer_pkg
