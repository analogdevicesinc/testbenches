// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2025 Analog Devices, Inc. All rights reserved.
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

package s_axi_sequencer_pkg;

  import axi_vip_pkg::*;
  import adi_vip_pkg::*;
  import logger_pkg::*;


  virtual class s_axi_sequencer_base extends adi_sequencer;

    function new(
      input string name,
      input adi_agent parent = null);

      super.new(name, parent);
    endfunction: new

    pure virtual function logic [31:0] BackdoorRead32(input xil_axi_ulong addr);

    pure virtual function void BackdoorWrite32(
      input xil_axi_ulong addr,
      input logic [31:0] data,
      input bit [3:0] strb);

    pure virtual task set_backpressure(input xil_axi_ready_gen_policy_t backpressure_policy);

  endclass: s_axi_sequencer_base


  class s_axi_sequencer #(`AXI_VIP_PARAM_DECL(AXI)) extends s_axi_sequencer_base;

    axi_slv_wr_driver #(`AXI_VIP_PARAM_ORDER(AXI)) wr_driver;
    axi_slv_rd_driver #(`AXI_VIP_PARAM_ORDER(AXI)) rd_driver;

    xil_axi_slv_mem_model #(`AXI_VIP_PARAM_ORDER(AXI)) mem_model;

    function new(
      input string name,
      input axi_slv_wr_driver #(`AXI_VIP_PARAM_ORDER(AXI)) wr_driver,
      input axi_slv_rd_driver #(`AXI_VIP_PARAM_ORDER(AXI)) rd_driver,
      input xil_axi_slv_mem_model #(`AXI_VIP_PARAM_ORDER(AXI)) mem_model,
      input adi_agent parent = null);

      super.new(name, parent);

      this.wr_driver = wr_driver;
      this.rd_driver = rd_driver;
      this.mem_model = mem_model;
    endfunction: new

    virtual function logic [31:0] BackdoorRead32(input xil_axi_ulong addr);
      return this.mem_model.backdoor_memory_read_4byte(addr);
    endfunction: BackdoorRead32

    virtual function void BackdoorWrite32(
      input xil_axi_ulong addr,
      input logic [31:0] data,
      input bit [3:0] strb);

      this.mem_model.backdoor_memory_write_4byte(
        .addr(addr),
        .payload(data),
        .strb(strb));
    endfunction: BackdoorWrite32

    virtual task set_backpressure(input xil_axi_ready_gen_policy_t backpressure_policy);
      axi_ready_gen  wready_gen;

      wready_gen = this.wr_driver.create_ready("wready");
      wready_gen.set_ready_policy(backpressure_policy);
      this.wr_driver.send_wready(wready_gen);
    endtask: set_backpressure

  endclass: s_axi_sequencer

endpackage: s_axi_sequencer_pkg
