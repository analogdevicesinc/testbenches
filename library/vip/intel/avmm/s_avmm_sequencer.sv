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

package s_avmm_sequencer_pkg;

  import adi_vip_pkg::*;
  import logger_pkg::*;
  import adi_avmm_bfm_if_base_pkg::*;


  virtual class s_avmm_sequencer_base extends adi_sequencer;

    function new(
      input string name,
      input adi_agent parent = null);

      super.new(name, parent);
    endfunction: new

    pure virtual function void SetDebug(input bit enable);
    pure virtual function void ClearStats();
    pure virtual function string GetStats();

    pure virtual function logic [31:0] BackdoorRead32(input bit [63:0] addr);

    pure virtual function void BackdoorWrite32(
      input bit [63:0] addr,
      input logic [31:0] data,
      input bit [3:0] strb);

  endclass: s_avmm_sequencer_base


  class s_avmm_sequencer extends s_avmm_sequencer_base;

    protected adi_avmm_slave_bfm_if_base bfm_if;

    function new(
      input string name,
      input adi_avmm_slave_bfm_if_base bfm_if,
      input adi_agent parent = null);

      super.new(name, parent);

      this.bfm_if = bfm_if;
    endfunction: new

    virtual function void SetDebug(input bit enable);
      this.bfm_if.set_debug(enable);
    endfunction: SetDebug

    virtual function void ClearStats();
      this.bfm_if.clear_stats();
    endfunction: ClearStats

    virtual function string GetStats();
      return this.bfm_if.get_stats();
    endfunction: GetStats

    virtual function logic [31:0] BackdoorRead32(input bit [63:0] addr);
      return this.bfm_if.backdoor_read32(addr);
    endfunction: BackdoorRead32

    virtual function void BackdoorWrite32(
      input bit [63:0] addr,
      input logic [31:0] data,
      input bit [3:0] strb);

      this.bfm_if.backdoor_write32(
        .addr(addr),
        .data(data),
        .strb(strb));
    endfunction: BackdoorWrite32

  endclass: s_avmm_sequencer

endpackage: s_avmm_sequencer_pkg
