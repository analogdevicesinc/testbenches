// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2021 (c) Analog Devices, Inc. All rights reserved.
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

package adi_regmap_pkg;

  import logger_pkg::*;

  typedef enum {NA, R, RO, ROV, RW, RW1C, RW1CV, RW1S, W1S, WO} acc_t;

  // Used in generic definitions
  const int n = 0;

  typedef struct {
    int msb;
    int lsb;
    acc_t access;
    int reset_value;
  } field_t;

  typedef struct{
    int addr;
    string name;
    field_t fields[string];
  } reg_t;


  function bit [31:0] SetField(reg_t register,
                               string field,
                               bit [31:0] value);
    bit [31:0] ret = 'h0;
    int lsb, msb;

    if (!register.fields.exists(field))
      `ERROR(("Field %s in reg %s does not exists", field, register.name));

    lsb = register.fields[field].lsb;
    msb = register.fields[field].msb;

    ret = value << lsb;
    for (int i=msb+1;i<=31;i++) begin
      ret[i]=1'b0;
    end

    `INFOV(("Setting reg %s[%0d:%0d] field %s with %h (%h)", register.name, msb, lsb, field, value, ret), 10);

    return ret;
  endfunction;

  function bit [31:0] GetField(reg_t register,
                               string field,
                               bit [31:0] regvalue);
    bit [31:0] ret = 'h0;
    int lsb, msb;

    if (!register.fields.exists(field))
      `ERROR(("Field %s in reg %s does not exists", field, register.name));

    lsb = register.fields[field].lsb;
    msb = register.fields[field].msb;

    for (int i=msb+1;i<=31;i++) begin
      regvalue[i]=1'b0;
    end
    ret = regvalue >> lsb;

//    `INFOV(("Setting reg %s[%0d:%0d] field %s with %h (%h)", register.name, msb, lsb, field, value, ret), 4);

    return ret;
  endfunction;

  function bit [31:0] UpdateRegister(bit [31:0] regvalue,
                                     bit [31:0] fieldvalue,
                                     bit [31:0] mask);
    bit [31:0] ret = regvalue;
    ret = ret & (~mask);
    ret = ret | fieldvalue;

    return ret;
  endfunction;

  function int GetAddrs(reg_t register);
    return register.addr;
  endfunction;

  function int GetResetValue(reg_t register, 
                             string field);
    return register.fields[field].reset_value;
  endfunction;

endpackage
