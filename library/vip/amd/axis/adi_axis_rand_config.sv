// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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

package adi_axis_rand_config_pkg;

  import logger_pkg::*;
  import adi_object_pkg::*;


  class adi_axis_rand_config extends adi_object;

    rand bit [1:0] TDATA_MODE;        // 0 - random
                                      // 1 - ramp
                                      // 2 - constant
    rand bit [1:0] TKEEP_MODE;        // 0 - random
                                      // 1 - constant
                                      // 2 - partial, coherent
    rand bit [1:0] TSTRB_MODE;        // 0 - random
                                      // 1 - constant
                                      // 2 - position/data ping-pong
    rand bit [1:0] TUSER_BYTE_MODE;   // 0 - random
                                      // 1 - ramp
                                      // 2 - constant
    rand bit [2:0] TID_MODE;          // 0 - random
                                      // 1 - ramp, change after transaction
                                      // 2 - ramp, change after packet
                                      // 3 - ramp, change after frame
                                      // 4 - constant
    rand bit [2:0] TDEST_MODE;        // 0 - random
                                      // 1 - ramp, change after transaction
                                      // 2 - ramp, change after packet
                                      // 3 - ramp, change after frame
                                      // 4 - constant
    rand bit [1:0] TUSER_TX_MODE;     // 0 - random
                                      // 1 - ramp
                                      // 2 - constant

    constraint c_tdata { this.TDATA_MODE < 3; }
    constraint c_tkeep { this.TKEEP_MODE < 3; }
    constraint c_tstrb { this.TSTRB_MODE < 3; }
    constraint c_tuser_byte { this.TUSER_BYTE_MODE < 3; }
    constraint c_tid { this.TID_MODE < 5; }
    constraint c_tdest { this.TDEST_MODE < 5; }
    constraint c_tuser_tx { this.TUSER_TX_MODE < 3; }

    function new(
      input string name = "",
      input bit [1:0] TDATA_MODE = 0,
      input bit TKEEP_MODE = 0,
      input bit [1:0] TSTRB_MODE = 0,
      input bit [1:0] TUSER_BYTE_MODE = 0,
      input bit [1:0] TID_MODE = 0,
      input bit [1:0] TDEST_MODE = 0,
      input bit [1:0] TUSER_TX_MODE = 0);

      super.new(name);

      this.TDATA_MODE = TDATA_MODE;
      this.TKEEP_MODE = TKEEP_MODE;
      this.TSTRB_MODE = TSTRB_MODE;
      this.TUSER_BYTE_MODE = TUSER_BYTE_MODE;
      this.TID_MODE = TID_MODE;
      this.TDEST_MODE = TDEST_MODE;
      this.TUSER_TX_MODE = TUSER_TX_MODE;
    endfunction: new

    function void randomize_configuration();
      if (!this.randomize()) begin
        `FATAL(("Randomization failed!"));
      end
    endfunction: randomize_configuration

    function void update_config_class(input adi_axis_rand_config cfg_info);
      this.TDATA_MODE = cfg_info.TDATA_MODE;
      this.TKEEP_MODE = cfg_info.TKEEP_MODE;
      this.TSTRB_MODE = cfg_info.TSTRB_MODE;
      this.TUSER_BYTE_MODE = cfg_info.TUSER_BYTE_MODE;
      this.TID_MODE = cfg_info.TID_MODE;
      this.TDEST_MODE = cfg_info.TDEST_MODE;
      this.TUSER_TX_MODE = cfg_info.TUSER_TX_MODE;
    endfunction: update_config_class

    virtual function adi_object clone();
      adi_axis_rand_config object;
      object = new(.name(this.name));
      this.copy(object);
      return object;
    endfunction: clone

    virtual function string convert2string();
      string str;
      str = {"ADI AXIS Configuration\n",
        $sformatf("name: %s\n", this.name)};
      return(str);
    endfunction: convert2string

    virtual function void do_copy(input adi_object object);
      adi_axis_rand_config cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      cast_object.update_config_class(.cfg_info(this));
    endfunction: do_copy

    virtual function bit do_compare(input adi_object object);
      adi_axis_rand_config cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      if (this.TDATA_MODE != cast_object.TDATA_MODE ||
        (this.TKEEP_MODE != cast_object.TKEEP_MODE) ||
        (this.TSTRB_MODE != cast_object.TSTRB_MODE) ||
        (this.TUSER_BYTE_MODE != cast_object.TUSER_BYTE_MODE) ||
        (this.TID_MODE != cast_object.TID_MODE) ||
        (this.TDEST_MODE != cast_object.TDEST_MODE) ||
        (this.TUSER_TX_MODE != cast_object.TUSER_TX_MODE)) begin

        return 0;
      end
      return 1;
    endfunction: do_compare

  endclass: adi_axis_rand_config

endpackage: adi_axis_rand_config_pkg
