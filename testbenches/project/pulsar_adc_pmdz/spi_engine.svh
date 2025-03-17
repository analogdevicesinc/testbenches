// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2023 Analog Devices, Inc. All rights reserved.
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

`timescale 1ns/1ps

`ifndef _SPI_ENGINE_SVH_
`define _SPI_ENGINE_SVH_

`define SPI_ENG_ADDR_VERSION        32'h0000_0000
`define SPI_ENG_ADDR_ID             32'h0000_0004
`define SPI_ENG_ADDR_SCRATCH        32'h0000_0008
`define SPI_ENG_ADDR_ENABLE         32'h0000_0040
`define SPI_ENG_ADDR_IRQMASK        32'h0000_0080
`define SPI_ENG_ADDR_IRQPEND        32'h0000_0084
`define SPI_ENG_ADDR_IRQSRC         32'h0000_0088
`define SPI_ENG_ADDR_SYNCID         32'h0000_00C0
`define SPI_ENG_ADDR_CMDFIFO_ROOM   32'h0000_00D0
`define SPI_ENG_ADDR_SDOFIFO_ROOM   32'h0000_00D4
`define SPI_ENG_ADDR_SDIFIFO_LEVEL  32'h0000_00D8
`define SPI_ENG_ADDR_CMDFIFO        32'h0000_00E0
`define SPI_ENG_ADDR_SDOFIFO        32'h0000_00E4
`define SPI_ENG_ADDR_SDIFIFO        32'h0000_00E8
`define SPI_ENG_ADDR_SDIFIFO_PEEK   32'h0000_00F0
`define SPI_ENG_ADDR_OFFLOAD_EN     32'h0000_0100
`define SPI_ENG_ADDR_OFFLOAD_RESET  32'h0000_0108
`define SPI_ENG_ADDR_OFFLOAD_CMD    32'h0000_0110
`define SPI_ENG_ADDR_OFFLOAD_SDO    32'h0000_0114


`endif
