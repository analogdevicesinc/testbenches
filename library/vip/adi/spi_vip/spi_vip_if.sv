// ***************************************************************************
// Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
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

interface spi_vip_if #(
  int MODE              = 0,
      CPOL              = 0,
      CPHA              = 0,
      INV_CS            = 0,
      DATA_DLENGTH      = 16,
      SLAVE_TIN         = 0,
      SLAVE_TOUT        = 0,
      MASTER_TIN        = 0,
      MASTER_TOUT       = 0,
      CS_TO_MISO        = 0,
      DEFAULT_MISO_DATA = 'hCAFE
) ();
  import adi_spi_vip_if_base_pkg::*;

  logic sclk;
  wire  miso; // need net types here in case tb wants to tristate this
  wire  mosi; // need net types here in case tb wants to tristate this
  logic cs;

  // internal
  logic intf_slave_mode;
  logic intf_master_mode;
  logic intf_monitor_mode;
  logic miso_oen;
  logic miso_drive;
  logic cs_active;
  logic mosi_delayed;
  localparam CS_ACTIVE_LEVEL = (INV_CS) ? 1'b1 : 1'b0;

  // hack for parameterized edge. TODO: improve this
  logic sample_edge, drive_edge;
  assign sample_edge  = (CPOL^CPHA) ? !sclk : sclk;
  assign drive_edge   = (CPOL^CPHA) ? sclk : !sclk;
  assign cs_active = (cs == CS_ACTIVE_LEVEL);

  // miso tri-state handling
  assign miso = (!intf_slave_mode)  ? 'z
              : (miso_oen)          ? miso_drive
                /*default*/         : 'z;

  // mosi delay
  assign #(SLAVE_TIN*1ns) mosi_delayed =  mosi;

  class adi_spi_vip_if #(int dummy = 10) extends adi_spi_vip_if_base;

    function new();
    endfunction

    virtual function int get_param_MODE();
      return MODE;
    endfunction

    virtual function int get_param_CPOL();
      return CPOL;
    endfunction

    virtual function int get_param_CPHA();
      return CPHA;
    endfunction

    virtual function int get_param_INV_CS();
      return INV_CS;
    endfunction

    virtual function int get_param_DATA_DLENGTH();
      return DATA_DLENGTH;
    endfunction

    virtual function int get_param_SLAVE_TIN();
      return SLAVE_TIN;
    endfunction

    virtual function int get_param_SLAVE_TOUT();
      return SLAVE_TOUT;
    endfunction

    virtual function int get_param_MASTER_TIN();
      return MASTER_TIN;
    endfunction

    virtual function int get_param_MASTER_TOUT();
      return MASTER_TOUT;
    endfunction

    virtual function int get_param_CS_TO_MISO();
      return CS_TO_MISO;
    endfunction

    virtual function int get_param_DEFAULT_MISO_DATA();
      return DEFAULT_MISO_DATA;
    endfunction

    virtual function int get_slave_mode();
      return intf_slave_mode;
    endfunction

  endclass: adi_spi_vip_if

  adi_spi_vip_if vif = new();

  function void set_slave_mode();
    intf_slave_mode   = 1;
    intf_master_mode  = 0;
    intf_monitor_mode = 0;
  endfunction : set_slave_mode

  function void set_master_mode();
    intf_slave_mode   = 0;
    intf_master_mode  = 1;
    intf_monitor_mode = 0;
    `ERRORV(("Unsupported mode master")); //TODO
  endfunction : set_master_mode

  function void set_monitor_mode();
    intf_slave_mode   = 0;
    intf_master_mode  = 0;
    intf_monitor_mode = 1;
    `ERRORV(("Unsupported mode monitor")); //TODO
  endfunction : set_monitor_mode

endinterface
