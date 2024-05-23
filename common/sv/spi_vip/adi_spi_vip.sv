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

module adi_spi_vip #(
  parameter MODE          = 0, // SLAVE=0
  parameter CPOL          = 0,
  parameter CPHA          = 0,
  parameter INV_CS        = 0,
  parameter DATA_DLENGTH  = 16,
  parameter SLAVE_TIN     = 0,
  parameter SLAVE_TOUT    = 0,
  parameter MASTER_TIN    = 0,
  parameter MASTER_TOUT   = 0,
  parameter CS_TO_MISO    = 0,
  parameter DEFAULT_MISO_DATA = 'hCAFE
)  (
  input   logic s_spi_sclk,
  input   wire  s_spi_mosi,
  output  wire  s_spi_miso,
  input   logic s_spi_cs,
  output  logic m_spi_sclk,
  output  wire  m_spi_mosi,
  input   wire  m_spi_miso,
  output  logic m_spi_cs
);

  localparam MODE_SLAVE   = 0;
  localparam MODE_MASTER  = 1;
  localparam MODE_MONITOR = 2;
  import logger_pkg::*;
  
  spi_vip_if #(
    .CPOL               (CPOL),
    .CPHA               (CPHA),
    .INV_CS             (INV_CS),
    .DATA_DLENGTH       (DATA_DLENGTH),
    .SLAVE_TIN          (SLAVE_TIN),
    .SLAVE_TOUT         (SLAVE_TOUT),
    .MASTER_TIN         (MASTER_TIN),
    .MASTER_TOUT        (MASTER_TOUT),
    .CS_TO_MISO         (CS_TO_MISO),
    .DEFAULT_MISO_DATA  (DEFAULT_MISO_DATA)
  ) IF ();

  initial begin : ASSERT_PARAMETERS
    assert (MODE == MODE_SLAVE) 
    else   begin
      `ERROR(("Unsupported mode %s. Valid values are 0=SLAVE, 1=MASTER, 2=MONITOR. Only 0(SLAVE) is currently supported.",MODE));
    end
  end : ASSERT_PARAMETERS

  generate
    if (MODE == MODE_SLAVE) begin
      assign s_spi_miso = IF.miso;
      assign IF.mosi = s_spi_mosi;
      assign IF.sclk = s_spi_sclk;
      assign IF.cs = s_spi_cs;
      initial begin
        IF.set_slave_mode();
      end      
    end else if (MODE == MODE_MASTER) begin
      assign IF.miso = m_spi_miso;
      assign m_spi_mosi = IF.mosi;
      assign m_spi_sclk = IF.sclk;
      assign m_spi_cs = IF.cs;
      initial begin
        IF.set_master_mode();
      end
    end else if (MODE == MODE_MONITOR) begin
      assign IF.miso = m_spi_miso;
      assign IF.mosi = s_spi_mosi;
      assign IF.miso = s_spi_miso;
      assign IF.cs   = s_spi_cs;
      assign s_spi_miso = m_spi_miso;
      assign m_spi_mosi = s_spi_mosi;
      assign m_spi_sclk = s_spi_sclk;
      assign m_spi_cs   = s_spi_cs;
      initial begin
        IF.intf_monitor_mode();
      end
    end
  endgenerate

endmodule