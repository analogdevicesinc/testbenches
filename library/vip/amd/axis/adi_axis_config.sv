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

package adi_axis_config_pkg;

  import logger_pkg::*;
  import adi_object_pkg::*;


  class adi_axis_config extends adi_object;

    int BYTES_PER_TRANSACTION;
    bit EN_TKEEP;
    bit EN_TSTRB;
    bit EN_TLAST;
    bit EN_TUSER;
    bit EN_TID;
    bit EN_TDEST;
    bit TUSER_BYTE_BASED;
    int TID_WIDTH;
    int TDEST_WIDTH;
    int TUSER_WIDTH;

    function new(
      input string name = "",
      input int BYTES_PER_TRANSACTION,
      input bit EN_TKEEP = 0,
      input bit EN_TSTRB = 0,
      input bit EN_TLAST = 0,
      input bit EN_TUSER = 0,
      input bit EN_TID = 0,
      input bit EN_TDEST = 0,
      input bit TUSER_BYTE_BASED = 0,
      input int TID_WIDTH = 0,
      input int TDEST_WIDTH = 0,
      input int TUSER_WIDTH = 0);

      super.new(name);

      this.BYTES_PER_TRANSACTION = BYTES_PER_TRANSACTION;
      this.EN_TKEEP = EN_TKEEP;
      this.EN_TSTRB = EN_TSTRB;
      this.EN_TLAST = EN_TLAST;
      this.EN_TUSER = EN_TUSER;
      this.EN_TID = EN_TID;
      this.EN_TDEST = EN_TDEST;
      this.TUSER_BYTE_BASED = TUSER_BYTE_BASED;
      this.TID_WIDTH = TID_WIDTH;
      this.TDEST_WIDTH = TDEST_WIDTH;
      this.TUSER_WIDTH = TUSER_WIDTH;
    endfunction: new

    function void update_config_class(input adi_axis_config cfg_info);
      this.BYTES_PER_TRANSACTION = cfg_info.BYTES_PER_TRANSACTION;
      this.EN_TKEEP = cfg_info.EN_TKEEP;
      this.EN_TSTRB = cfg_info.EN_TSTRB;
      this.EN_TLAST = cfg_info.EN_TLAST;
      this.EN_TUSER = cfg_info.EN_TUSER;
      this.EN_TID = cfg_info.EN_TID;
      this.EN_TDEST = cfg_info.EN_TDEST;
      this.TUSER_BYTE_BASED = cfg_info.TUSER_BYTE_BASED;
      this.TID_WIDTH = cfg_info.TID_WIDTH;
      this.TDEST_WIDTH = cfg_info.TDEST_WIDTH;
      this.TUSER_WIDTH = cfg_info.TUSER_WIDTH;
    endfunction: update_config_class

    virtual function adi_object clone();
      adi_axis_config object;
      object = new(
        .name(this.name),
        .BYTES_PER_TRANSACTION(BYTES_PER_TRANSACTION),
        .EN_TKEEP(EN_TKEEP),
        .EN_TSTRB(EN_TSTRB),
        .EN_TLAST(EN_TLAST),
        .EN_TUSER(EN_TUSER),
        .EN_TID(EN_TID),
        .EN_TDEST(EN_TDEST),
        .TUSER_BYTE_BASED(TUSER_BYTE_BASED),
        .TID_WIDTH(TID_WIDTH),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH));
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
      adi_axis_config cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      cast_object.update_config_class(
        .cfg_info(this));
    endfunction: do_copy

    virtual function bit do_compare(input adi_object object);
      adi_axis_config cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      if (this.BYTES_PER_TRANSACTION != cast_object.BYTES_PER_TRANSACTION ||
        (this.EN_TKEEP != cast_object.EN_TKEEP) ||
        (this.EN_TSTRB != cast_object.EN_TSTRB) ||
        (this.EN_TLAST != cast_object.EN_TLAST) ||
        (this.EN_TUSER != cast_object.EN_TUSER) ||
        (this.EN_TID != cast_object.EN_TID) ||
        (this.EN_TDEST != cast_object.EN_TDEST) ||
        (this.TUSER_BYTE_BASED != cast_object.TUSER_BYTE_BASED) ||
        (this.TID_WIDTH != cast_object.TID_WIDTH) ||
        (this.TDEST_WIDTH != cast_object.TDEST_WIDTH) ||
        (this.TUSER_WIDTH != cast_object.TUSER_WIDTH)) begin

        return 0;
      end
      return 1;
    endfunction: do_compare

  endclass: adi_axis_config

endpackage: adi_axis_config_pkg
