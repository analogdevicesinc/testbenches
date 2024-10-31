// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018 (c) Analog Devices, Inc. All rights reserved.
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

package reg_accessor_pkg;

  import axi_vip_pkg::*;
  import logger_pkg::*;

  class reg_accessor extends adi_component;

    function new(
      input string name,
      input adi_component parent = null);
      
      super.new(name, parent);
    endfunction

    virtual task automatic RegWrite32(input xil_axi_ulong addr =0,
                                           input bit [31:0]    data);
    endtask: RegWrite32

    virtual task automatic RegRead32(input xil_axi_ulong  addr =0,
                                          output bit [31:0]    data);
    endtask: RegRead32

    virtual task automatic RegReadVerify32(input xil_axi_ulong  addr =0,
                                                input bit [31:0]     data);
    endtask: RegReadVerify32

  endclass

endpackage
