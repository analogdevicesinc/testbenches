// ***************************************************************************
// ***************************************************************************
// Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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


module adi_spi_bfm #(
  parameter MODE        = "SLAVE",
  parameter CPOL        = 0,
  parameter CPHA        = 0,
  parameter INV_CS      = 0,
  parameter realtime SLAVE_TSU   = 0ns,
  parameter realtime SLAVE_TH    = 0ns,
  parameter realtime MASTER_TSU  = 0ns,
  parameter realtime MASTER_TH   = 0ns,
  parameter realtime CS_TO_MISO  = 0ns,
  parameter DATA_DLENGTH  = 16,
  parameter DEFAULT_MISO_DATA = 'hDEADCAFE
)  (
  inout   logic sclk,
  inout   wire  mosi,
  inout   wire  miso,
  inout   logic cs
);

  import adi_spi_bfm_pkg::*;
  
  spi_bfm_if `SPI_VIF_PARAM_ORDER IF ();

  initial begin : ASSERT_PARAMETERS
    assert (MODE == "SLAVE") 
    else   begin
      `ERROR(("Unsupported mode %s",MODE));
    end
  end : ASSERT_PARAMETERS

  generate
    if (MODE=="SLAVE") begin
      assign miso = IF.miso;
      assign IF.mosi = mosi;
      assign IF.sclk = sclk;
      assign IF.cs = cs;
      initial begin
        IF.set_slave_mode();
      end      
    end else if (MODE=="MASTER") begin
      assign IF.miso = miso;
      assign mosi = IF.mosi;
      assign IF.sclk = sclk;
      assign IF.cs = cs;
      initial begin
        IF.set_master_mode();
      end
    end else if (MODE=="MONITOR") begin
      assign IF.miso = miso;
      assign IF.mosi = mosi;
      assign IF.miso = miso;
      assign IF.cs   = cs;
      initial begin
        IF.intf_monitor_mode();
      end
    end
  endgenerate

  

endmodule