// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2024 Analog Devices, Inc. All rights reserved.
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
/* Auto generated Register Map */
/* Sat Apr 20 14:16:29 2024 */

package adi_regmap_i3c_controller_pkg;
  import adi_regmap_pkg::*;


/* I3C Controller (i3c_controller_host_interface) */

  const reg_t i3c_controller_host_interface_VERSION = '{ 'h0000, "VERSION" , '{
    "VERSION_MAJOR": '{ 31, 16, RO, 'h01 },
    "VERSION_MINOR": '{ 15, 8, RO, 'h00 },
    "VERSION_PATCH": '{ 7, 0, RO, 'h01 }}};
  `define SET_i3c_controller_host_interface_VERSION_VERSION_MAJOR(x) SetField(i3c_controller_host_interface_VERSION,"VERSION_MAJOR",x)
  `define GET_i3c_controller_host_interface_VERSION_VERSION_MAJOR(x) GetField(i3c_controller_host_interface_VERSION,"VERSION_MAJOR",x)
  `define DEFAULT_i3c_controller_host_interface_VERSION_VERSION_MAJOR GetResetValue(i3c_controller_host_interface_VERSION,"VERSION_MAJOR")
  `define UPDATE_i3c_controller_host_interface_VERSION_VERSION_MAJOR(x,y) UpdateField(i3c_controller_host_interface_VERSION,"VERSION_MAJOR",x,y)
  `define SET_i3c_controller_host_interface_VERSION_VERSION_MINOR(x) SetField(i3c_controller_host_interface_VERSION,"VERSION_MINOR",x)
  `define GET_i3c_controller_host_interface_VERSION_VERSION_MINOR(x) GetField(i3c_controller_host_interface_VERSION,"VERSION_MINOR",x)
  `define DEFAULT_i3c_controller_host_interface_VERSION_VERSION_MINOR GetResetValue(i3c_controller_host_interface_VERSION,"VERSION_MINOR")
  `define UPDATE_i3c_controller_host_interface_VERSION_VERSION_MINOR(x,y) UpdateField(i3c_controller_host_interface_VERSION,"VERSION_MINOR",x,y)
  `define SET_i3c_controller_host_interface_VERSION_VERSION_PATCH(x) SetField(i3c_controller_host_interface_VERSION,"VERSION_PATCH",x)
  `define GET_i3c_controller_host_interface_VERSION_VERSION_PATCH(x) GetField(i3c_controller_host_interface_VERSION,"VERSION_PATCH",x)
  `define DEFAULT_i3c_controller_host_interface_VERSION_VERSION_PATCH GetResetValue(i3c_controller_host_interface_VERSION,"VERSION_PATCH")
  `define UPDATE_i3c_controller_host_interface_VERSION_VERSION_PATCH(x,y) UpdateField(i3c_controller_host_interface_VERSION,"VERSION_PATCH",x,y)

  const reg_t i3c_controller_host_interface_DEVICE_ID = '{ 'h0004, "DEVICE_ID" , '{
    "DEVICE_ID": '{ 31, 0, RO, 0 }}};
  `define SET_i3c_controller_host_interface_DEVICE_ID_DEVICE_ID(x) SetField(i3c_controller_host_interface_DEVICE_ID,"DEVICE_ID",x)
  `define GET_i3c_controller_host_interface_DEVICE_ID_DEVICE_ID(x) GetField(i3c_controller_host_interface_DEVICE_ID,"DEVICE_ID",x)
  `define DEFAULT_i3c_controller_host_interface_DEVICE_ID_DEVICE_ID GetResetValue(i3c_controller_host_interface_DEVICE_ID,"DEVICE_ID")
  `define UPDATE_i3c_controller_host_interface_DEVICE_ID_DEVICE_ID(x,y) UpdateField(i3c_controller_host_interface_DEVICE_ID,"DEVICE_ID",x,y)

  const reg_t i3c_controller_host_interface_SCRATCH = '{ 'h0008, "SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_SCRATCH_SCRATCH(x) SetField(i3c_controller_host_interface_SCRATCH,"SCRATCH",x)
  `define GET_i3c_controller_host_interface_SCRATCH_SCRATCH(x) GetField(i3c_controller_host_interface_SCRATCH,"SCRATCH",x)
  `define DEFAULT_i3c_controller_host_interface_SCRATCH_SCRATCH GetResetValue(i3c_controller_host_interface_SCRATCH,"SCRATCH")
  `define UPDATE_i3c_controller_host_interface_SCRATCH_SCRATCH(x,y) UpdateField(i3c_controller_host_interface_SCRATCH,"SCRATCH",x,y)

  const reg_t i3c_controller_host_interface_ENABLE = '{ 'h0040, "ENABLE" , '{
    "ENABLE": '{ 0, 0, RW, 'h1 }}};
  `define SET_i3c_controller_host_interface_ENABLE_ENABLE(x) SetField(i3c_controller_host_interface_ENABLE,"ENABLE",x)
  `define GET_i3c_controller_host_interface_ENABLE_ENABLE(x) GetField(i3c_controller_host_interface_ENABLE,"ENABLE",x)
  `define DEFAULT_i3c_controller_host_interface_ENABLE_ENABLE GetResetValue(i3c_controller_host_interface_ENABLE,"ENABLE")
  `define UPDATE_i3c_controller_host_interface_ENABLE_ENABLE(x,y) UpdateField(i3c_controller_host_interface_ENABLE,"ENABLE",x,y)

  const reg_t i3c_controller_host_interface_IRQ_MASK = '{ 'h0080, "IRQ_MASK" , '{
    "DAA_PENDING": '{ 7, 7, RW, 'h0 },
    "IBI_PENDING": '{ 6, 6, RW, 'h0 },
    "CMDR_PENDING": '{ 5, 5, RW, 'h0 },
    "IBI_ALMOST_FULL": '{ 4, 4, RW, 'h0 },
    "SDI_ALMOST_FULL": '{ 3, 3, RW, 'h0 },
    "SDO_ALMOST_EMPTY": '{ 2, 2, RW, 'h0 },
    "CMDR_ALMOST_FULL": '{ 1, 1, RW, 'h0 },
    "CMD_ALMOST_EMPTY": '{ 0, 0, RW, 'h0 }}};
  `define SET_i3c_controller_host_interface_IRQ_MASK_DAA_PENDING(x) SetField(i3c_controller_host_interface_IRQ_MASK,"DAA_PENDING",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_DAA_PENDING(x) GetField(i3c_controller_host_interface_IRQ_MASK,"DAA_PENDING",x)
  `define DEFAULT_i3c_controller_host_interface_IRQ_MASK_DAA_PENDING GetResetValue(i3c_controller_host_interface_IRQ_MASK,"DAA_PENDING")
  `define UPDATE_i3c_controller_host_interface_IRQ_MASK_DAA_PENDING(x,y) UpdateField(i3c_controller_host_interface_IRQ_MASK,"DAA_PENDING",x,y)
  `define SET_i3c_controller_host_interface_IRQ_MASK_IBI_PENDING(x) SetField(i3c_controller_host_interface_IRQ_MASK,"IBI_PENDING",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_IBI_PENDING(x) GetField(i3c_controller_host_interface_IRQ_MASK,"IBI_PENDING",x)
  `define DEFAULT_i3c_controller_host_interface_IRQ_MASK_IBI_PENDING GetResetValue(i3c_controller_host_interface_IRQ_MASK,"IBI_PENDING")
  `define UPDATE_i3c_controller_host_interface_IRQ_MASK_IBI_PENDING(x,y) UpdateField(i3c_controller_host_interface_IRQ_MASK,"IBI_PENDING",x,y)
  `define SET_i3c_controller_host_interface_IRQ_MASK_CMDR_PENDING(x) SetField(i3c_controller_host_interface_IRQ_MASK,"CMDR_PENDING",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_CMDR_PENDING(x) GetField(i3c_controller_host_interface_IRQ_MASK,"CMDR_PENDING",x)
  `define DEFAULT_i3c_controller_host_interface_IRQ_MASK_CMDR_PENDING GetResetValue(i3c_controller_host_interface_IRQ_MASK,"CMDR_PENDING")
  `define UPDATE_i3c_controller_host_interface_IRQ_MASK_CMDR_PENDING(x,y) UpdateField(i3c_controller_host_interface_IRQ_MASK,"CMDR_PENDING",x,y)
  `define SET_i3c_controller_host_interface_IRQ_MASK_IBI_ALMOST_FULL(x) SetField(i3c_controller_host_interface_IRQ_MASK,"IBI_ALMOST_FULL",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_IBI_ALMOST_FULL(x) GetField(i3c_controller_host_interface_IRQ_MASK,"IBI_ALMOST_FULL",x)
  `define DEFAULT_i3c_controller_host_interface_IRQ_MASK_IBI_ALMOST_FULL GetResetValue(i3c_controller_host_interface_IRQ_MASK,"IBI_ALMOST_FULL")
  `define UPDATE_i3c_controller_host_interface_IRQ_MASK_IBI_ALMOST_FULL(x,y) UpdateField(i3c_controller_host_interface_IRQ_MASK,"IBI_ALMOST_FULL",x,y)
  `define SET_i3c_controller_host_interface_IRQ_MASK_SDI_ALMOST_FULL(x) SetField(i3c_controller_host_interface_IRQ_MASK,"SDI_ALMOST_FULL",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_SDI_ALMOST_FULL(x) GetField(i3c_controller_host_interface_IRQ_MASK,"SDI_ALMOST_FULL",x)
  `define DEFAULT_i3c_controller_host_interface_IRQ_MASK_SDI_ALMOST_FULL GetResetValue(i3c_controller_host_interface_IRQ_MASK,"SDI_ALMOST_FULL")
  `define UPDATE_i3c_controller_host_interface_IRQ_MASK_SDI_ALMOST_FULL(x,y) UpdateField(i3c_controller_host_interface_IRQ_MASK,"SDI_ALMOST_FULL",x,y)
  `define SET_i3c_controller_host_interface_IRQ_MASK_SDO_ALMOST_EMPTY(x) SetField(i3c_controller_host_interface_IRQ_MASK,"SDO_ALMOST_EMPTY",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_SDO_ALMOST_EMPTY(x) GetField(i3c_controller_host_interface_IRQ_MASK,"SDO_ALMOST_EMPTY",x)
  `define DEFAULT_i3c_controller_host_interface_IRQ_MASK_SDO_ALMOST_EMPTY GetResetValue(i3c_controller_host_interface_IRQ_MASK,"SDO_ALMOST_EMPTY")
  `define UPDATE_i3c_controller_host_interface_IRQ_MASK_SDO_ALMOST_EMPTY(x,y) UpdateField(i3c_controller_host_interface_IRQ_MASK,"SDO_ALMOST_EMPTY",x,y)
  `define SET_i3c_controller_host_interface_IRQ_MASK_CMDR_ALMOST_FULL(x) SetField(i3c_controller_host_interface_IRQ_MASK,"CMDR_ALMOST_FULL",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_CMDR_ALMOST_FULL(x) GetField(i3c_controller_host_interface_IRQ_MASK,"CMDR_ALMOST_FULL",x)
  `define DEFAULT_i3c_controller_host_interface_IRQ_MASK_CMDR_ALMOST_FULL GetResetValue(i3c_controller_host_interface_IRQ_MASK,"CMDR_ALMOST_FULL")
  `define UPDATE_i3c_controller_host_interface_IRQ_MASK_CMDR_ALMOST_FULL(x,y) UpdateField(i3c_controller_host_interface_IRQ_MASK,"CMDR_ALMOST_FULL",x,y)
  `define SET_i3c_controller_host_interface_IRQ_MASK_CMD_ALMOST_EMPTY(x) SetField(i3c_controller_host_interface_IRQ_MASK,"CMD_ALMOST_EMPTY",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_CMD_ALMOST_EMPTY(x) GetField(i3c_controller_host_interface_IRQ_MASK,"CMD_ALMOST_EMPTY",x)
  `define DEFAULT_i3c_controller_host_interface_IRQ_MASK_CMD_ALMOST_EMPTY GetResetValue(i3c_controller_host_interface_IRQ_MASK,"CMD_ALMOST_EMPTY")
  `define UPDATE_i3c_controller_host_interface_IRQ_MASK_CMD_ALMOST_EMPTY(x,y) UpdateField(i3c_controller_host_interface_IRQ_MASK,"CMD_ALMOST_EMPTY",x,y)

  const reg_t i3c_controller_host_interface_IRQ_PENDING = '{ 'h0084, "IRQ_PENDING" , '{
    "IRQ_PENDING": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_IRQ_PENDING_IRQ_PENDING(x) SetField(i3c_controller_host_interface_IRQ_PENDING,"IRQ_PENDING",x)
  `define GET_i3c_controller_host_interface_IRQ_PENDING_IRQ_PENDING(x) GetField(i3c_controller_host_interface_IRQ_PENDING,"IRQ_PENDING",x)
  `define DEFAULT_i3c_controller_host_interface_IRQ_PENDING_IRQ_PENDING GetResetValue(i3c_controller_host_interface_IRQ_PENDING,"IRQ_PENDING")
  `define UPDATE_i3c_controller_host_interface_IRQ_PENDING_IRQ_PENDING(x,y) UpdateField(i3c_controller_host_interface_IRQ_PENDING,"IRQ_PENDING",x,y)

  const reg_t i3c_controller_host_interface_IRQ_SOURCE = '{ 'h0088, "IRQ_SOURCE" , '{
    "IRQ_SOURCE": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_IRQ_SOURCE_IRQ_SOURCE(x) SetField(i3c_controller_host_interface_IRQ_SOURCE,"IRQ_SOURCE",x)
  `define GET_i3c_controller_host_interface_IRQ_SOURCE_IRQ_SOURCE(x) GetField(i3c_controller_host_interface_IRQ_SOURCE,"IRQ_SOURCE",x)
  `define DEFAULT_i3c_controller_host_interface_IRQ_SOURCE_IRQ_SOURCE GetResetValue(i3c_controller_host_interface_IRQ_SOURCE,"IRQ_SOURCE")
  `define UPDATE_i3c_controller_host_interface_IRQ_SOURCE_IRQ_SOURCE(x,y) UpdateField(i3c_controller_host_interface_IRQ_SOURCE,"IRQ_SOURCE",x,y)

  const reg_t i3c_controller_host_interface_CMD_FIFO_ROOM = '{ 'h00c0, "CMD_FIFO_ROOM" , '{
    "CMD_FIFO_ROOM": '{ 31, 0, RO, 'hXXXXXXXX }}};
  `define SET_i3c_controller_host_interface_CMD_FIFO_ROOM_CMD_FIFO_ROOM(x) SetField(i3c_controller_host_interface_CMD_FIFO_ROOM,"CMD_FIFO_ROOM",x)
  `define GET_i3c_controller_host_interface_CMD_FIFO_ROOM_CMD_FIFO_ROOM(x) GetField(i3c_controller_host_interface_CMD_FIFO_ROOM,"CMD_FIFO_ROOM",x)
  `define DEFAULT_i3c_controller_host_interface_CMD_FIFO_ROOM_CMD_FIFO_ROOM GetResetValue(i3c_controller_host_interface_CMD_FIFO_ROOM,"CMD_FIFO_ROOM")
  `define UPDATE_i3c_controller_host_interface_CMD_FIFO_ROOM_CMD_FIFO_ROOM(x,y) UpdateField(i3c_controller_host_interface_CMD_FIFO_ROOM,"CMD_FIFO_ROOM",x,y)

  const reg_t i3c_controller_host_interface_CMDR_FIFO_LEVEL = '{ 'h00c4, "CMDR_FIFO_LEVEL" , '{
    "CMDR_FIFO_LEVEL": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_CMDR_FIFO_LEVEL_CMDR_FIFO_LEVEL(x) SetField(i3c_controller_host_interface_CMDR_FIFO_LEVEL,"CMDR_FIFO_LEVEL",x)
  `define GET_i3c_controller_host_interface_CMDR_FIFO_LEVEL_CMDR_FIFO_LEVEL(x) GetField(i3c_controller_host_interface_CMDR_FIFO_LEVEL,"CMDR_FIFO_LEVEL",x)
  `define DEFAULT_i3c_controller_host_interface_CMDR_FIFO_LEVEL_CMDR_FIFO_LEVEL GetResetValue(i3c_controller_host_interface_CMDR_FIFO_LEVEL,"CMDR_FIFO_LEVEL")
  `define UPDATE_i3c_controller_host_interface_CMDR_FIFO_LEVEL_CMDR_FIFO_LEVEL(x,y) UpdateField(i3c_controller_host_interface_CMDR_FIFO_LEVEL,"CMDR_FIFO_LEVEL",x,y)

  const reg_t i3c_controller_host_interface_SDO_FIFO_ROOM = '{ 'h00c8, "SDO_FIFO_ROOM" , '{
    "SDO_FIFO_ROOM": '{ 31, 0, RO, 'hXXXXXXXX }}};
  `define SET_i3c_controller_host_interface_SDO_FIFO_ROOM_SDO_FIFO_ROOM(x) SetField(i3c_controller_host_interface_SDO_FIFO_ROOM,"SDO_FIFO_ROOM",x)
  `define GET_i3c_controller_host_interface_SDO_FIFO_ROOM_SDO_FIFO_ROOM(x) GetField(i3c_controller_host_interface_SDO_FIFO_ROOM,"SDO_FIFO_ROOM",x)
  `define DEFAULT_i3c_controller_host_interface_SDO_FIFO_ROOM_SDO_FIFO_ROOM GetResetValue(i3c_controller_host_interface_SDO_FIFO_ROOM,"SDO_FIFO_ROOM")
  `define UPDATE_i3c_controller_host_interface_SDO_FIFO_ROOM_SDO_FIFO_ROOM(x,y) UpdateField(i3c_controller_host_interface_SDO_FIFO_ROOM,"SDO_FIFO_ROOM",x,y)

  const reg_t i3c_controller_host_interface_SDI_FIFO_LEVEL = '{ 'h00cc, "SDI_FIFO_LEVEL" , '{
    "SDI_FIFO_LEVEL": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_SDI_FIFO_LEVEL_SDI_FIFO_LEVEL(x) SetField(i3c_controller_host_interface_SDI_FIFO_LEVEL,"SDI_FIFO_LEVEL",x)
  `define GET_i3c_controller_host_interface_SDI_FIFO_LEVEL_SDI_FIFO_LEVEL(x) GetField(i3c_controller_host_interface_SDI_FIFO_LEVEL,"SDI_FIFO_LEVEL",x)
  `define DEFAULT_i3c_controller_host_interface_SDI_FIFO_LEVEL_SDI_FIFO_LEVEL GetResetValue(i3c_controller_host_interface_SDI_FIFO_LEVEL,"SDI_FIFO_LEVEL")
  `define UPDATE_i3c_controller_host_interface_SDI_FIFO_LEVEL_SDI_FIFO_LEVEL(x,y) UpdateField(i3c_controller_host_interface_SDI_FIFO_LEVEL,"SDI_FIFO_LEVEL",x,y)

  const reg_t i3c_controller_host_interface_IBI_FIFO_LEVEL = '{ 'h00d0, "IBI_FIFO_LEVEL" , '{
    "IBI_FIFO_LEVEL": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_IBI_FIFO_LEVEL_IBI_FIFO_LEVEL(x) SetField(i3c_controller_host_interface_IBI_FIFO_LEVEL,"IBI_FIFO_LEVEL",x)
  `define GET_i3c_controller_host_interface_IBI_FIFO_LEVEL_IBI_FIFO_LEVEL(x) GetField(i3c_controller_host_interface_IBI_FIFO_LEVEL,"IBI_FIFO_LEVEL",x)
  `define DEFAULT_i3c_controller_host_interface_IBI_FIFO_LEVEL_IBI_FIFO_LEVEL GetResetValue(i3c_controller_host_interface_IBI_FIFO_LEVEL,"IBI_FIFO_LEVEL")
  `define UPDATE_i3c_controller_host_interface_IBI_FIFO_LEVEL_IBI_FIFO_LEVEL(x,y) UpdateField(i3c_controller_host_interface_IBI_FIFO_LEVEL,"IBI_FIFO_LEVEL",x,y)

  const reg_t i3c_controller_host_interface_CMD_FIFO = '{ 'h00d4, "CMD_FIFO" , '{
    "CMD_IS_CCC": '{ 22, 22, WO, 'hX },
    "CMD_BCAST_HEADER": '{ 21, 21, WO, 'hX },
    "CMD_SR": '{ 20, 20, WO, 'hX },
    "CMD_BUFFER_LENGHT": '{ 19, 8, WO, 'hXXX },
    "CMD_DA": '{ 7, 1, WO, 'hXX },
    "CMD_RNW": '{ 0, 0, WO, 'hX }}};
  `define SET_i3c_controller_host_interface_CMD_FIFO_CMD_IS_CCC(x) SetField(i3c_controller_host_interface_CMD_FIFO,"CMD_IS_CCC",x)
  `define GET_i3c_controller_host_interface_CMD_FIFO_CMD_IS_CCC(x) GetField(i3c_controller_host_interface_CMD_FIFO,"CMD_IS_CCC",x)
  `define DEFAULT_i3c_controller_host_interface_CMD_FIFO_CMD_IS_CCC GetResetValue(i3c_controller_host_interface_CMD_FIFO,"CMD_IS_CCC")
  `define UPDATE_i3c_controller_host_interface_CMD_FIFO_CMD_IS_CCC(x,y) UpdateField(i3c_controller_host_interface_CMD_FIFO,"CMD_IS_CCC",x,y)
  `define SET_i3c_controller_host_interface_CMD_FIFO_CMD_BCAST_HEADER(x) SetField(i3c_controller_host_interface_CMD_FIFO,"CMD_BCAST_HEADER",x)
  `define GET_i3c_controller_host_interface_CMD_FIFO_CMD_BCAST_HEADER(x) GetField(i3c_controller_host_interface_CMD_FIFO,"CMD_BCAST_HEADER",x)
  `define DEFAULT_i3c_controller_host_interface_CMD_FIFO_CMD_BCAST_HEADER GetResetValue(i3c_controller_host_interface_CMD_FIFO,"CMD_BCAST_HEADER")
  `define UPDATE_i3c_controller_host_interface_CMD_FIFO_CMD_BCAST_HEADER(x,y) UpdateField(i3c_controller_host_interface_CMD_FIFO,"CMD_BCAST_HEADER",x,y)
  `define SET_i3c_controller_host_interface_CMD_FIFO_CMD_SR(x) SetField(i3c_controller_host_interface_CMD_FIFO,"CMD_SR",x)
  `define GET_i3c_controller_host_interface_CMD_FIFO_CMD_SR(x) GetField(i3c_controller_host_interface_CMD_FIFO,"CMD_SR",x)
  `define DEFAULT_i3c_controller_host_interface_CMD_FIFO_CMD_SR GetResetValue(i3c_controller_host_interface_CMD_FIFO,"CMD_SR")
  `define UPDATE_i3c_controller_host_interface_CMD_FIFO_CMD_SR(x,y) UpdateField(i3c_controller_host_interface_CMD_FIFO,"CMD_SR",x,y)
  `define SET_i3c_controller_host_interface_CMD_FIFO_CMD_BUFFER_LENGHT(x) SetField(i3c_controller_host_interface_CMD_FIFO,"CMD_BUFFER_LENGHT",x)
  `define GET_i3c_controller_host_interface_CMD_FIFO_CMD_BUFFER_LENGHT(x) GetField(i3c_controller_host_interface_CMD_FIFO,"CMD_BUFFER_LENGHT",x)
  `define DEFAULT_i3c_controller_host_interface_CMD_FIFO_CMD_BUFFER_LENGHT GetResetValue(i3c_controller_host_interface_CMD_FIFO,"CMD_BUFFER_LENGHT")
  `define UPDATE_i3c_controller_host_interface_CMD_FIFO_CMD_BUFFER_LENGHT(x,y) UpdateField(i3c_controller_host_interface_CMD_FIFO,"CMD_BUFFER_LENGHT",x,y)
  `define SET_i3c_controller_host_interface_CMD_FIFO_CMD_DA(x) SetField(i3c_controller_host_interface_CMD_FIFO,"CMD_DA",x)
  `define GET_i3c_controller_host_interface_CMD_FIFO_CMD_DA(x) GetField(i3c_controller_host_interface_CMD_FIFO,"CMD_DA",x)
  `define DEFAULT_i3c_controller_host_interface_CMD_FIFO_CMD_DA GetResetValue(i3c_controller_host_interface_CMD_FIFO,"CMD_DA")
  `define UPDATE_i3c_controller_host_interface_CMD_FIFO_CMD_DA(x,y) UpdateField(i3c_controller_host_interface_CMD_FIFO,"CMD_DA",x,y)
  `define SET_i3c_controller_host_interface_CMD_FIFO_CMD_RNW(x) SetField(i3c_controller_host_interface_CMD_FIFO,"CMD_RNW",x)
  `define GET_i3c_controller_host_interface_CMD_FIFO_CMD_RNW(x) GetField(i3c_controller_host_interface_CMD_FIFO,"CMD_RNW",x)
  `define DEFAULT_i3c_controller_host_interface_CMD_FIFO_CMD_RNW GetResetValue(i3c_controller_host_interface_CMD_FIFO,"CMD_RNW")
  `define UPDATE_i3c_controller_host_interface_CMD_FIFO_CMD_RNW(x,y) UpdateField(i3c_controller_host_interface_CMD_FIFO,"CMD_RNW",x,y)

  const reg_t i3c_controller_host_interface_CMDR_FIFO = '{ 'h00d8, "CMDR_FIFO" , '{
    "CMDR_FIFO_ERROR": '{ 23, 0, RO, 'h?? },
    "CMDR_FIFO_BUFFER_LENGTH": '{ 19, 8, RO, 'h?? },
    "CMDR_FIFO_SYNC": '{ 7, 0, RO, 'h?? }}};
  `define SET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_ERROR(x) SetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_ERROR",x)
  `define GET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_ERROR(x) GetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_ERROR",x)
  `define DEFAULT_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_ERROR GetResetValue(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_ERROR")
  `define UPDATE_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_ERROR(x,y) UpdateField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_ERROR",x,y)
  `define SET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_BUFFER_LENGTH(x) SetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_BUFFER_LENGTH",x)
  `define GET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_BUFFER_LENGTH(x) GetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_BUFFER_LENGTH",x)
  `define DEFAULT_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_BUFFER_LENGTH GetResetValue(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_BUFFER_LENGTH")
  `define UPDATE_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_BUFFER_LENGTH(x,y) UpdateField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_BUFFER_LENGTH",x,y)
  `define SET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_SYNC(x) SetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_SYNC",x)
  `define GET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_SYNC(x) GetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_SYNC",x)
  `define DEFAULT_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_SYNC GetResetValue(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_SYNC")
  `define UPDATE_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_SYNC(x,y) UpdateField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_SYNC",x,y)

  const reg_t i3c_controller_host_interface_SDO_FIFO = '{ 'h00dc, "SDO_FIFO" , '{
    "SDO_FIFO_BYTE_3": '{ 31, 24, RO, 'hXX },
    "SDO_FIFO_BYTE_2": '{ 23, 16, RO, 'hXX },
    "SDO_FIFO_BYTE_1": '{ 15, 8, RO, 'hXX },
    "SDO_FIFO_BYTE_0": '{ 7, 0, RO, 'hXX }}};
  `define SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_3(x) SetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_3",x)
  `define GET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_3(x) GetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_3",x)
  `define DEFAULT_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_3 GetResetValue(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_3")
  `define UPDATE_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_3(x,y) UpdateField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_3",x,y)
  `define SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_2(x) SetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_2",x)
  `define GET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_2(x) GetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_2",x)
  `define DEFAULT_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_2 GetResetValue(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_2")
  `define UPDATE_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_2(x,y) UpdateField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_2",x,y)
  `define SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_1(x) SetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_1",x)
  `define GET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_1(x) GetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_1",x)
  `define DEFAULT_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_1 GetResetValue(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_1")
  `define UPDATE_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_1(x,y) UpdateField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_1",x,y)
  `define SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_0(x) SetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_0",x)
  `define GET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_0(x) GetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_0",x)
  `define DEFAULT_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_0 GetResetValue(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_0")
  `define UPDATE_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_0(x,y) UpdateField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_0",x,y)

  const reg_t i3c_controller_host_interface_SDI_FIFO = '{ 'h00e0, "SDI_FIFO" , '{
    "SDI_FIFO": '{ 31, 0, RO, 'hXXXXXXXX }}};
  `define SET_i3c_controller_host_interface_SDI_FIFO_SDI_FIFO(x) SetField(i3c_controller_host_interface_SDI_FIFO,"SDI_FIFO",x)
  `define GET_i3c_controller_host_interface_SDI_FIFO_SDI_FIFO(x) GetField(i3c_controller_host_interface_SDI_FIFO,"SDI_FIFO",x)
  `define DEFAULT_i3c_controller_host_interface_SDI_FIFO_SDI_FIFO GetResetValue(i3c_controller_host_interface_SDI_FIFO,"SDI_FIFO")
  `define UPDATE_i3c_controller_host_interface_SDI_FIFO_SDI_FIFO(x,y) UpdateField(i3c_controller_host_interface_SDI_FIFO,"SDI_FIFO",x,y)

  const reg_t i3c_controller_host_interface_IBI_FIFO = '{ 'h00e4, "IBI_FIFO" , '{
    "IBI_FIFO_DA": '{ 23, 17, RO, 'hXX },
    "IBI_FIFO_MDB": '{ 15, 8, RO, 'hXX },
    "IBI_FIFO_SYNC": '{ 7, 0, RO, 'hXX }}};
  `define SET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_DA(x) SetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_DA",x)
  `define GET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_DA(x) GetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_DA",x)
  `define DEFAULT_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_DA GetResetValue(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_DA")
  `define UPDATE_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_DA(x,y) UpdateField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_DA",x,y)
  `define SET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_MDB(x) SetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_MDB",x)
  `define GET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_MDB(x) GetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_MDB",x)
  `define DEFAULT_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_MDB GetResetValue(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_MDB")
  `define UPDATE_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_MDB(x,y) UpdateField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_MDB",x,y)
  `define SET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_SYNC(x) SetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_SYNC",x)
  `define GET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_SYNC(x) GetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_SYNC",x)
  `define DEFAULT_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_SYNC GetResetValue(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_SYNC")
  `define UPDATE_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_SYNC(x,y) UpdateField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_SYNC",x,y)

  const reg_t i3c_controller_host_interface_FIFO_STATUS = '{ 'h00e8, "FIFO_STATUS" , '{
    "SDI_EMPTY": '{ 2, 2, RO, 'h1 },
    "IBI_EMPTY": '{ 1, 1, RO, 'h1 },
    "CMDR_EMPTY": '{ 0, 0, RO, 'h1 }}};
  `define SET_i3c_controller_host_interface_FIFO_STATUS_SDI_EMPTY(x) SetField(i3c_controller_host_interface_FIFO_STATUS,"SDI_EMPTY",x)
  `define GET_i3c_controller_host_interface_FIFO_STATUS_SDI_EMPTY(x) GetField(i3c_controller_host_interface_FIFO_STATUS,"SDI_EMPTY",x)
  `define DEFAULT_i3c_controller_host_interface_FIFO_STATUS_SDI_EMPTY GetResetValue(i3c_controller_host_interface_FIFO_STATUS,"SDI_EMPTY")
  `define UPDATE_i3c_controller_host_interface_FIFO_STATUS_SDI_EMPTY(x,y) UpdateField(i3c_controller_host_interface_FIFO_STATUS,"SDI_EMPTY",x,y)
  `define SET_i3c_controller_host_interface_FIFO_STATUS_IBI_EMPTY(x) SetField(i3c_controller_host_interface_FIFO_STATUS,"IBI_EMPTY",x)
  `define GET_i3c_controller_host_interface_FIFO_STATUS_IBI_EMPTY(x) GetField(i3c_controller_host_interface_FIFO_STATUS,"IBI_EMPTY",x)
  `define DEFAULT_i3c_controller_host_interface_FIFO_STATUS_IBI_EMPTY GetResetValue(i3c_controller_host_interface_FIFO_STATUS,"IBI_EMPTY")
  `define UPDATE_i3c_controller_host_interface_FIFO_STATUS_IBI_EMPTY(x,y) UpdateField(i3c_controller_host_interface_FIFO_STATUS,"IBI_EMPTY",x,y)
  `define SET_i3c_controller_host_interface_FIFO_STATUS_CMDR_EMPTY(x) SetField(i3c_controller_host_interface_FIFO_STATUS,"CMDR_EMPTY",x)
  `define GET_i3c_controller_host_interface_FIFO_STATUS_CMDR_EMPTY(x) GetField(i3c_controller_host_interface_FIFO_STATUS,"CMDR_EMPTY",x)
  `define DEFAULT_i3c_controller_host_interface_FIFO_STATUS_CMDR_EMPTY GetResetValue(i3c_controller_host_interface_FIFO_STATUS,"CMDR_EMPTY")
  `define UPDATE_i3c_controller_host_interface_FIFO_STATUS_CMDR_EMPTY(x,y) UpdateField(i3c_controller_host_interface_FIFO_STATUS,"CMDR_EMPTY",x,y)

  const reg_t i3c_controller_host_interface_OPS = '{ 'h0100, "OPS" , '{
    "OPS_STATUS_NOP": '{ 7, 7, RO, 'h0 },
    "OPS_SPEED_GRADE": '{ 6, 5, RW, 'h0 },
    "OPS_OFFLOAD_LENGTH": '{ 4, 1, RW, 'h0 },
    "OPS_MODE": '{ 0, 0, RW, 'h0 }}};
  `define SET_i3c_controller_host_interface_OPS_OPS_STATUS_NOP(x) SetField(i3c_controller_host_interface_OPS,"OPS_STATUS_NOP",x)
  `define GET_i3c_controller_host_interface_OPS_OPS_STATUS_NOP(x) GetField(i3c_controller_host_interface_OPS,"OPS_STATUS_NOP",x)
  `define DEFAULT_i3c_controller_host_interface_OPS_OPS_STATUS_NOP GetResetValue(i3c_controller_host_interface_OPS,"OPS_STATUS_NOP")
  `define UPDATE_i3c_controller_host_interface_OPS_OPS_STATUS_NOP(x,y) UpdateField(i3c_controller_host_interface_OPS,"OPS_STATUS_NOP",x,y)
  `define SET_i3c_controller_host_interface_OPS_OPS_SPEED_GRADE(x) SetField(i3c_controller_host_interface_OPS,"OPS_SPEED_GRADE",x)
  `define GET_i3c_controller_host_interface_OPS_OPS_SPEED_GRADE(x) GetField(i3c_controller_host_interface_OPS,"OPS_SPEED_GRADE",x)
  `define DEFAULT_i3c_controller_host_interface_OPS_OPS_SPEED_GRADE GetResetValue(i3c_controller_host_interface_OPS,"OPS_SPEED_GRADE")
  `define UPDATE_i3c_controller_host_interface_OPS_OPS_SPEED_GRADE(x,y) UpdateField(i3c_controller_host_interface_OPS,"OPS_SPEED_GRADE",x,y)
  `define SET_i3c_controller_host_interface_OPS_OPS_OFFLOAD_LENGTH(x) SetField(i3c_controller_host_interface_OPS,"OPS_OFFLOAD_LENGTH",x)
  `define GET_i3c_controller_host_interface_OPS_OPS_OFFLOAD_LENGTH(x) GetField(i3c_controller_host_interface_OPS,"OPS_OFFLOAD_LENGTH",x)
  `define DEFAULT_i3c_controller_host_interface_OPS_OPS_OFFLOAD_LENGTH GetResetValue(i3c_controller_host_interface_OPS,"OPS_OFFLOAD_LENGTH")
  `define UPDATE_i3c_controller_host_interface_OPS_OPS_OFFLOAD_LENGTH(x,y) UpdateField(i3c_controller_host_interface_OPS,"OPS_OFFLOAD_LENGTH",x,y)
  `define SET_i3c_controller_host_interface_OPS_OPS_MODE(x) SetField(i3c_controller_host_interface_OPS,"OPS_MODE",x)
  `define GET_i3c_controller_host_interface_OPS_OPS_MODE(x) GetField(i3c_controller_host_interface_OPS,"OPS_MODE",x)
  `define DEFAULT_i3c_controller_host_interface_OPS_OPS_MODE GetResetValue(i3c_controller_host_interface_OPS,"OPS_MODE")
  `define UPDATE_i3c_controller_host_interface_OPS_OPS_MODE(x,y) UpdateField(i3c_controller_host_interface_OPS,"OPS_MODE",x,y)

  const reg_t i3c_controller_host_interface_IBI_CONFIG = '{ 'h0140, "IBI_CONFIG" , '{
    "IBI_CONFIG_LISTEN": '{ 1, 1, WO, 'h0 },
    "IBI_CONFIG_ENABLE": '{ 0, 0, WO, 'h0 }}};
  `define SET_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_LISTEN(x) SetField(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_LISTEN",x)
  `define GET_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_LISTEN(x) GetField(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_LISTEN",x)
  `define DEFAULT_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_LISTEN GetResetValue(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_LISTEN")
  `define UPDATE_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_LISTEN(x,y) UpdateField(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_LISTEN",x,y)
  `define SET_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_ENABLE(x) SetField(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_ENABLE",x)
  `define GET_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_ENABLE(x) GetField(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_ENABLE",x)
  `define DEFAULT_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_ENABLE GetResetValue(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_ENABLE")
  `define UPDATE_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_ENABLE(x,y) UpdateField(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_ENABLE",x,y)

  const reg_t i3c_controller_host_interface_DEV_CHAR = '{ 'h0180, "DEV_CHAR" , '{
    "DEV_CHAR_ADDR": '{ 15, 9, RW, 'h00 },
    "DEV_CHAR_WEN": '{ 8, 8, W, 'hX },
    "DEV_CHAR_HAS_IBI_MDB": '{ 3, 3, RW, 'h0 },
    "DEV_CHAR_IS_IBI_CAPABLE": '{ 2, 2, RW, 'h0 },
    "DEV_CHAR_IS_ATTACHED": '{ 1, 1, RW, 'h0 },
    "DEV_CHAR_IS_I2C": '{ 0, 0, RW, 'h0 }}};
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_ADDR(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_ADDR",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_ADDR(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_ADDR",x)
  `define DEFAULT_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_ADDR GetResetValue(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_ADDR")
  `define UPDATE_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_ADDR(x,y) UpdateField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_ADDR",x,y)
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_WEN(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_WEN",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_WEN(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_WEN",x)
  `define DEFAULT_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_WEN GetResetValue(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_WEN")
  `define UPDATE_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_WEN(x,y) UpdateField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_WEN",x,y)
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_HAS_IBI_MDB(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_HAS_IBI_MDB",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_HAS_IBI_MDB(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_HAS_IBI_MDB",x)
  `define DEFAULT_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_HAS_IBI_MDB GetResetValue(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_HAS_IBI_MDB")
  `define UPDATE_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_HAS_IBI_MDB(x,y) UpdateField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_HAS_IBI_MDB",x,y)
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_IBI_CAPABLE(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_IBI_CAPABLE",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_IBI_CAPABLE(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_IBI_CAPABLE",x)
  `define DEFAULT_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_IBI_CAPABLE GetResetValue(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_IBI_CAPABLE")
  `define UPDATE_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_IBI_CAPABLE(x,y) UpdateField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_IBI_CAPABLE",x,y)
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_ATTACHED(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_ATTACHED",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_ATTACHED(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_ATTACHED",x)
  `define DEFAULT_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_ATTACHED GetResetValue(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_ATTACHED")
  `define UPDATE_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_ATTACHED(x,y) UpdateField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_ATTACHED",x,y)
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_I2C(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_I2C",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_I2C(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_I2C",x)
  `define DEFAULT_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_I2C GetResetValue(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_I2C")
  `define UPDATE_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_I2C(x,y) UpdateField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_I2C",x,y)

  const reg_t i3c_controller_host_interface_OFFLOAD_CMD_n = '{ 'h02c0, "OFFLOAD_CMD_n" , '{
    "OFFLOAD_CMD": '{ 31, 0, RW, 'h00 }}};
  `define SET_i3c_controller_host_interface_OFFLOAD_CMD_n_OFFLOAD_CMD(x) SetField(i3c_controller_host_interface_OFFLOAD_CMD_n,"OFFLOAD_CMD",x)
  `define GET_i3c_controller_host_interface_OFFLOAD_CMD_n_OFFLOAD_CMD(x) GetField(i3c_controller_host_interface_OFFLOAD_CMD_n,"OFFLOAD_CMD",x)
  `define DEFAULT_i3c_controller_host_interface_OFFLOAD_CMD_n_OFFLOAD_CMD GetResetValue(i3c_controller_host_interface_OFFLOAD_CMD_n,"OFFLOAD_CMD")
  `define UPDATE_i3c_controller_host_interface_OFFLOAD_CMD_n_OFFLOAD_CMD(x,y) UpdateField(i3c_controller_host_interface_OFFLOAD_CMD_n,"OFFLOAD_CMD",x,y)

  const reg_t i3c_controller_host_interface_OFFLOAD_SDO_n = '{ 'h0300, "OFFLOAD_SDO_n" , '{
    "OFFLOAD_SDO_BYTE_3": '{ 31, 24, RO, 'h00 },
    "OFFLOAD_SDO_BYTE_2": '{ 23, 16, RO, 'h00 },
    "OFFLOAD_SDO_BYTE_1": '{ 15, 8, RO, 'h00 },
    "OFFLOAD_SDO_BYTE_0": '{ 7, 0, RO, 'h00 }}};
  `define SET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_3(x) SetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_3",x)
  `define GET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_3(x) GetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_3",x)
  `define DEFAULT_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_3 GetResetValue(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_3")
  `define UPDATE_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_3(x,y) UpdateField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_3",x,y)
  `define SET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_2(x) SetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_2",x)
  `define GET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_2(x) GetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_2",x)
  `define DEFAULT_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_2 GetResetValue(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_2")
  `define UPDATE_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_2(x,y) UpdateField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_2",x,y)
  `define SET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_1(x) SetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_1",x)
  `define GET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_1(x) GetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_1",x)
  `define DEFAULT_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_1 GetResetValue(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_1")
  `define UPDATE_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_1(x,y) UpdateField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_1",x,y)
  `define SET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_0(x) SetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_0",x)
  `define GET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_0(x) GetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_0",x)
  `define DEFAULT_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_0 GetResetValue(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_0")
  `define UPDATE_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_0(x,y) UpdateField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_0",x,y)


endpackage
