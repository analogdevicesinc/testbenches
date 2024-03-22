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

`include "utils.svh"

package data_offload_api_pkg;

  import logger_pkg::*;
  import adi_peripheral_pkg::*;
  import adi_regmap_data_offload_pkg::*;
  import adi_regmap_pkg::*;
  import reg_accessor_pkg::*;

  import regmap_pkg::*;
  import do_regmap_pkg::*;

  class data_offload_api extends adi_peripheral;

    DO_REGMAP #(0,0,0,0) do_regmap;

    // -----------------
    function new(string name, reg_accessor bus, bit [31:0] base_address);
      super.new(name, bus, base_address);
      this.do_regmap = new;
    endfunction

    // -----------------
    task sanity_test();
      this.axi_verify(this.do_regmap.VERSION_R.get_address(), this.do_regmap.VERSION_R.get_reset_value());
      `INFO(("Version register before: %h", this.do_regmap.VERSION_R.get()));
      this.axi_read(this.do_regmap.VERSION_R.get_address(), this.do_regmap.VERSION_R.value);
      `INFO(("Version register after: %h", this.do_regmap.VERSION_R.get()));
    endtask

    // -----------------
    task set_transfer_length(input int length);
      this.do_regmap.TRANSFER_LENGTH_R.PARTIAL_LENGTH_F.set(length-1);
      this.axi_write(this.do_regmap.TRANSFER_LENGTH_R.get_address(), this.do_regmap.TRANSFER_LENGTH_R.get());
    endtask

    // -----------------
    task enable_oneshot_mode();
      this.do_regmap.CONTROL_R.ONESHOT_EN_F.set(1);
      this.axi_write(this.do_regmap.CONTROL_R.get_address(), this.do_regmap.CONTROL_R.get());
    endtask

    // -----------------
    task disable_oneshot_mode();
      this.do_regmap.CONTROL_R.ONESHOT_EN_F.set(0);
      this.axi_write(this.do_regmap.CONTROL_R.get_address(), this.do_regmap.CONTROL_R.get());
    endtask

    // -----------------
    task enable_bypass_mode();
      this.do_regmap.CONTROL_R.OFFLOAD_BYPASS_F.set(1);
      this.axi_write(this.do_regmap.CONTROL_R.get_address(), this.do_regmap.CONTROL_R.get());
    endtask

    // -----------------
    task disable_bypass_mode();
      this.do_regmap.CONTROL_R.OFFLOAD_BYPASS_F.set(0);
      this.axi_write(this.do_regmap.CONTROL_R.get_address(), this.do_regmap.CONTROL_R.get());
    endtask

    // -----------------
    task assert_reset();
      this.do_regmap.RESETN_OFFLOAD_R.RESETN_F.set(0);
      this.axi_write(this.do_regmap.RESETN_OFFLOAD_R.get_address(), this.do_regmap.RESETN_OFFLOAD_R.get());
    endtask

    // -----------------
    task deassert_reset();
      this.do_regmap.RESETN_OFFLOAD_R.RESETN_F.set(1);
      this.axi_write(this.do_regmap.RESETN_OFFLOAD_R.get_address(), this.do_regmap.RESETN_OFFLOAD_R.get());
    endtask

  endclass

endpackage
