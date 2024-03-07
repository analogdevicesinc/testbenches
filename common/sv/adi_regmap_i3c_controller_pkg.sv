// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2024 (c) Analog Devices, Inc. All rights reserved.
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
/* Auto generated Register Map */
/* Wed Mar  6 20:03:21 2024 */

package adi_regmap_i3c_controller_pkg;
  import adi_regmap_pkg::*;


/* I3C Controller (i3c_controller_host_interface) */

  const reg_t i3c_controller_host_interface_VERSION = '{ 'h0000, "VERSION" , '{
    "VERSION_MAJOR": '{ 31, 16, RO, 'h00 },
    "VERSION_MINOR": '{ 15, 8, RO, 'h01 },
    "VERSION_PATCH": '{ 7, 0, RO, 'h00 }}};
  `define SET_i3c_controller_host_interface_VERSION_VERSION_MAJOR(x) SetField(i3c_controller_host_interface_VERSION,"VERSION_MAJOR",x)
  `define GET_i3c_controller_host_interface_VERSION_VERSION_MAJOR(x) GetField(i3c_controller_host_interface_VERSION,"VERSION_MAJOR",x)
  `define SET_i3c_controller_host_interface_VERSION_VERSION_MINOR(x) SetField(i3c_controller_host_interface_VERSION,"VERSION_MINOR",x)
  `define GET_i3c_controller_host_interface_VERSION_VERSION_MINOR(x) GetField(i3c_controller_host_interface_VERSION,"VERSION_MINOR",x)
  `define SET_i3c_controller_host_interface_VERSION_VERSION_PATCH(x) SetField(i3c_controller_host_interface_VERSION,"VERSION_PATCH",x)
  `define GET_i3c_controller_host_interface_VERSION_VERSION_PATCH(x) GetField(i3c_controller_host_interface_VERSION,"VERSION_PATCH",x)

  const reg_t i3c_controller_host_interface_DEVICE_ID = '{ 'h0004, "DEVICE_ID" , '{
    "DEVICE_ID": '{ 31, 0, RO, 0 }}};
  `define SET_i3c_controller_host_interface_DEVICE_ID_DEVICE_ID(x) SetField(i3c_controller_host_interface_DEVICE_ID,"DEVICE_ID",x)
  `define GET_i3c_controller_host_interface_DEVICE_ID_DEVICE_ID(x) GetField(i3c_controller_host_interface_DEVICE_ID,"DEVICE_ID",x)

  const reg_t i3c_controller_host_interface_SCRATCH = '{ 'h0008, "SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_SCRATCH_SCRATCH(x) SetField(i3c_controller_host_interface_SCRATCH,"SCRATCH",x)
  `define GET_i3c_controller_host_interface_SCRATCH_SCRATCH(x) GetField(i3c_controller_host_interface_SCRATCH,"SCRATCH",x)

  const reg_t i3c_controller_host_interface_ENABLE = '{ 'h0040, "ENABLE" , '{
    "ENABLE": '{ 0, 0, RW, 'h1 }}};
  `define SET_i3c_controller_host_interface_ENABLE_ENABLE(x) SetField(i3c_controller_host_interface_ENABLE,"ENABLE",x)
  `define GET_i3c_controller_host_interface_ENABLE_ENABLE(x) GetField(i3c_controller_host_interface_ENABLE,"ENABLE",x)

  const reg_t i3c_controller_host_interface_IRQ_MASK = '{ 'h0080, "IRQ_MASK" , '{
    "CMD_ALMOST_EMPTY": '{ 0, 0, RW, 'h00 },
    "CMDR_ALMOST_FULL": '{ 1, 1, RW, 'h00 },
    "SDO_ALMOST_EMPTY": '{ 2, 2, RW, 'h00 },
    "SDI_ALMOST_FULL": '{ 3, 3, RW, 'h00 },
    "IBI_ALMOST_FULL": '{ 4, 4, RW, 'h00 },
    "CMDR_PENDING": '{ 5, 5, RW, 'h00 },
    "IBI_PENDING": '{ 6, 6, RW, 'h00 },
    "DAA_PENDING": '{ 7, 7, RW, 'h00 }}};
  `define SET_i3c_controller_host_interface_IRQ_MASK_CMD_ALMOST_EMPTY(x) SetField(i3c_controller_host_interface_IRQ_MASK,"CMD_ALMOST_EMPTY",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_CMD_ALMOST_EMPTY(x) GetField(i3c_controller_host_interface_IRQ_MASK,"CMD_ALMOST_EMPTY",x)
  `define SET_i3c_controller_host_interface_IRQ_MASK_CMDR_ALMOST_FULL(x) SetField(i3c_controller_host_interface_IRQ_MASK,"CMDR_ALMOST_FULL",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_CMDR_ALMOST_FULL(x) GetField(i3c_controller_host_interface_IRQ_MASK,"CMDR_ALMOST_FULL",x)
  `define SET_i3c_controller_host_interface_IRQ_MASK_SDO_ALMOST_EMPTY(x) SetField(i3c_controller_host_interface_IRQ_MASK,"SDO_ALMOST_EMPTY",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_SDO_ALMOST_EMPTY(x) GetField(i3c_controller_host_interface_IRQ_MASK,"SDO_ALMOST_EMPTY",x)
  `define SET_i3c_controller_host_interface_IRQ_MASK_SDI_ALMOST_FULL(x) SetField(i3c_controller_host_interface_IRQ_MASK,"SDI_ALMOST_FULL",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_SDI_ALMOST_FULL(x) GetField(i3c_controller_host_interface_IRQ_MASK,"SDI_ALMOST_FULL",x)
  `define SET_i3c_controller_host_interface_IRQ_MASK_IBI_ALMOST_FULL(x) SetField(i3c_controller_host_interface_IRQ_MASK,"IBI_ALMOST_FULL",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_IBI_ALMOST_FULL(x) GetField(i3c_controller_host_interface_IRQ_MASK,"IBI_ALMOST_FULL",x)
  `define SET_i3c_controller_host_interface_IRQ_MASK_CMDR_PENDING(x) SetField(i3c_controller_host_interface_IRQ_MASK,"CMDR_PENDING",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_CMDR_PENDING(x) GetField(i3c_controller_host_interface_IRQ_MASK,"CMDR_PENDING",x)
  `define SET_i3c_controller_host_interface_IRQ_MASK_IBI_PENDING(x) SetField(i3c_controller_host_interface_IRQ_MASK,"IBI_PENDING",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_IBI_PENDING(x) GetField(i3c_controller_host_interface_IRQ_MASK,"IBI_PENDING",x)
  `define SET_i3c_controller_host_interface_IRQ_MASK_DAA_PENDING(x) SetField(i3c_controller_host_interface_IRQ_MASK,"DAA_PENDING",x)
  `define GET_i3c_controller_host_interface_IRQ_MASK_DAA_PENDING(x) GetField(i3c_controller_host_interface_IRQ_MASK,"DAA_PENDING",x)

  const reg_t i3c_controller_host_interface_IRQ_PENDING = '{ 'h0084, "IRQ_PENDING" , '{
    "IRQ_PENDING": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_IRQ_PENDING_IRQ_PENDING(x) SetField(i3c_controller_host_interface_IRQ_PENDING,"IRQ_PENDING",x)
  `define GET_i3c_controller_host_interface_IRQ_PENDING_IRQ_PENDING(x) GetField(i3c_controller_host_interface_IRQ_PENDING,"IRQ_PENDING",x)

  const reg_t i3c_controller_host_interface_IRQ_SOURCE = '{ 'h0088, "IRQ_SOURCE" , '{
    "IRQ_SOURCE": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_IRQ_SOURCE_IRQ_SOURCE(x) SetField(i3c_controller_host_interface_IRQ_SOURCE,"IRQ_SOURCE",x)
  `define GET_i3c_controller_host_interface_IRQ_SOURCE_IRQ_SOURCE(x) GetField(i3c_controller_host_interface_IRQ_SOURCE,"IRQ_SOURCE",x)

  const reg_t i3c_controller_host_interface_CMD_FIFO_ROOM = '{ 'h00c0, "CMD_FIFO_ROOM" , '{
    "CMD_FIFO_ROOM": '{ 31, 0, RO, 'h00 }}};
  `define SET_i3c_controller_host_interface_CMD_FIFO_ROOM_CMD_FIFO_ROOM(x) SetField(i3c_controller_host_interface_CMD_FIFO_ROOM,"CMD_FIFO_ROOM",x)
  `define GET_i3c_controller_host_interface_CMD_FIFO_ROOM_CMD_FIFO_ROOM(x) GetField(i3c_controller_host_interface_CMD_FIFO_ROOM,"CMD_FIFO_ROOM",x)

  const reg_t i3c_controller_host_interface_CMDR_FIFO_LEVEL = '{ 'h00c4, "CMDR_FIFO_LEVEL" , '{
    "CMDR_FIFO_LEVEL": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_CMDR_FIFO_LEVEL_CMDR_FIFO_LEVEL(x) SetField(i3c_controller_host_interface_CMDR_FIFO_LEVEL,"CMDR_FIFO_LEVEL",x)
  `define GET_i3c_controller_host_interface_CMDR_FIFO_LEVEL_CMDR_FIFO_LEVEL(x) GetField(i3c_controller_host_interface_CMDR_FIFO_LEVEL,"CMDR_FIFO_LEVEL",x)

  const reg_t i3c_controller_host_interface_SDO_FIFO_ROOM = '{ 'h00c8, "SDO_FIFO_ROOM" , '{
    "SDO_FIFO_ROOM": '{ 31, 0, RO, 'h00 }}};
  `define SET_i3c_controller_host_interface_SDO_FIFO_ROOM_SDO_FIFO_ROOM(x) SetField(i3c_controller_host_interface_SDO_FIFO_ROOM,"SDO_FIFO_ROOM",x)
  `define GET_i3c_controller_host_interface_SDO_FIFO_ROOM_SDO_FIFO_ROOM(x) GetField(i3c_controller_host_interface_SDO_FIFO_ROOM,"SDO_FIFO_ROOM",x)

  const reg_t i3c_controller_host_interface_SDI_FIFO_LEVEL = '{ 'h00cc, "SDI_FIFO_LEVEL" , '{
    "SDI_FIFO_LEVEL": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_SDI_FIFO_LEVEL_SDI_FIFO_LEVEL(x) SetField(i3c_controller_host_interface_SDI_FIFO_LEVEL,"SDI_FIFO_LEVEL",x)
  `define GET_i3c_controller_host_interface_SDI_FIFO_LEVEL_SDI_FIFO_LEVEL(x) GetField(i3c_controller_host_interface_SDI_FIFO_LEVEL,"SDI_FIFO_LEVEL",x)

  const reg_t i3c_controller_host_interface_IBI_FIFO_LEVEL = '{ 'h00d0, "IBI_FIFO_LEVEL" , '{
    "IBI_FIFO_LEVEL": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_i3c_controller_host_interface_IBI_FIFO_LEVEL_IBI_FIFO_LEVEL(x) SetField(i3c_controller_host_interface_IBI_FIFO_LEVEL,"IBI_FIFO_LEVEL",x)
  `define GET_i3c_controller_host_interface_IBI_FIFO_LEVEL_IBI_FIFO_LEVEL(x) GetField(i3c_controller_host_interface_IBI_FIFO_LEVEL,"IBI_FIFO_LEVEL",x)

  const reg_t i3c_controller_host_interface_CMD_FIFO = '{ 'h00d4, "CMD_FIFO" , '{
    "CMD_FIFO": '{ 31, 0, WO, 'h00 }}};
  `define SET_i3c_controller_host_interface_CMD_FIFO_CMD_FIFO(x) SetField(i3c_controller_host_interface_CMD_FIFO,"CMD_FIFO",x)
  `define GET_i3c_controller_host_interface_CMD_FIFO_CMD_FIFO(x) GetField(i3c_controller_host_interface_CMD_FIFO,"CMD_FIFO",x)

  const reg_t i3c_controller_host_interface_CMDR_FIFO = '{ 'h00d8, "CMDR_FIFO" , '{
    "CMDR_FIFO": '{ 31, 0, RO, 'h?? },
    "CMDR_FIFO_ERROR": '{ 27, 24, RO, 'h?? },
    "CMDR_FIFO_BUFFER_LENGTH": '{ 19, 8, RO, 'h?? },
    "CMDR_FIFO_SYNC": '{ 7, 0, RO, 'h?? }}};
  `define SET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO(x) SetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO",x)
  `define GET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO(x) GetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO",x)
  `define SET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_ERROR(x) SetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_ERROR",x)
  `define GET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_ERROR(x) GetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_ERROR",x)
  `define SET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_BUFFER_LENGTH(x) SetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_BUFFER_LENGTH",x)
  `define GET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_BUFFER_LENGTH(x) GetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_BUFFER_LENGTH",x)
  `define SET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_SYNC(x) SetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_SYNC",x)
  `define GET_i3c_controller_host_interface_CMDR_FIFO_CMDR_FIFO_SYNC(x) GetField(i3c_controller_host_interface_CMDR_FIFO,"CMDR_FIFO_SYNC",x)

  const reg_t i3c_controller_host_interface_SDO_FIFO = '{ 'h00dc, "SDO_FIFO" , '{
    "SDO_FIFO_BYTE_3": '{ 31, 24, RO, 'h?? },
    "SDO_FIFO_BYTE_2": '{ 23, 16, RO, 'h?? },
    "SDO_FIFO_BYTE_1": '{ 15, 8, RO, 'h?? },
    "SDO_FIFO_BYTE_0": '{ 7, 0, RO, 'h?? }}};
  `define SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_3(x) SetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_3",x)
  `define GET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_3(x) GetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_3",x)
  `define SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_2(x) SetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_2",x)
  `define GET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_2(x) GetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_2",x)
  `define SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_1(x) SetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_1",x)
  `define GET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_1(x) GetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_1",x)
  `define SET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_0(x) SetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_0",x)
  `define GET_i3c_controller_host_interface_SDO_FIFO_SDO_FIFO_BYTE_0(x) GetField(i3c_controller_host_interface_SDO_FIFO,"SDO_FIFO_BYTE_0",x)

  const reg_t i3c_controller_host_interface_SDI_FIFO = '{ 'h00e0, "SDI_FIFO" , '{
    "SDI_FIFO": '{ 31, 0, RO, 'h???????? }}};
  `define SET_i3c_controller_host_interface_SDI_FIFO_SDI_FIFO(x) SetField(i3c_controller_host_interface_SDI_FIFO,"SDI_FIFO",x)
  `define GET_i3c_controller_host_interface_SDI_FIFO_SDI_FIFO(x) GetField(i3c_controller_host_interface_SDI_FIFO,"SDI_FIFO",x)

  const reg_t i3c_controller_host_interface_IBI_FIFO = '{ 'h00e4, "IBI_FIFO" , '{
    "IBI_FIFO_DA": '{ 23, 17, RO, 'h?? },
    "IBI_FIFO_MDB": '{ 15, 8, RO, 'h?? },
    "IBI_FIFO_SYNC": '{ 7, 0, RO, 'h?? }}};
  `define SET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_DA(x) SetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_DA",x)
  `define GET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_DA(x) GetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_DA",x)
  `define SET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_MDB(x) SetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_MDB",x)
  `define GET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_MDB(x) GetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_MDB",x)
  `define SET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_SYNC(x) SetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_SYNC",x)
  `define GET_i3c_controller_host_interface_IBI_FIFO_IBI_FIFO_SYNC(x) GetField(i3c_controller_host_interface_IBI_FIFO,"IBI_FIFO_SYNC",x)

  const reg_t i3c_controller_host_interface_FIFO_STATUS = '{ 'h00e8, "FIFO_STATUS" , '{
    "CMDR_EMPTY": '{ 0, 0, RO, 'h1 },
    "IBI_EMPTY": '{ 1, 1, RO, 'h1 },
    "SDI_EMPTY": '{ 2, 2, RO, 'h1 }}};
  `define SET_i3c_controller_host_interface_FIFO_STATUS_CMDR_EMPTY(x) SetField(i3c_controller_host_interface_FIFO_STATUS,"CMDR_EMPTY",x)
  `define GET_i3c_controller_host_interface_FIFO_STATUS_CMDR_EMPTY(x) GetField(i3c_controller_host_interface_FIFO_STATUS,"CMDR_EMPTY",x)
  `define SET_i3c_controller_host_interface_FIFO_STATUS_IBI_EMPTY(x) SetField(i3c_controller_host_interface_FIFO_STATUS,"IBI_EMPTY",x)
  `define GET_i3c_controller_host_interface_FIFO_STATUS_IBI_EMPTY(x) GetField(i3c_controller_host_interface_FIFO_STATUS,"IBI_EMPTY",x)
  `define SET_i3c_controller_host_interface_FIFO_STATUS_SDI_EMPTY(x) SetField(i3c_controller_host_interface_FIFO_STATUS,"SDI_EMPTY",x)
  `define GET_i3c_controller_host_interface_FIFO_STATUS_SDI_EMPTY(x) GetField(i3c_controller_host_interface_FIFO_STATUS,"SDI_EMPTY",x)

  const reg_t i3c_controller_host_interface_OPS = '{ 'h0100, "OPS" , '{
    "OPS_MODE": '{ 0, 0, RW, 'h0 },
    "OPS_OFFLOAD_LENGTH": '{ 4, 1, RW, 'h0 },
    "OPS_SPEED_GRADE": '{ 6, 5, RW, 'h00 }}};
  `define SET_i3c_controller_host_interface_OPS_OPS_MODE(x) SetField(i3c_controller_host_interface_OPS,"OPS_MODE",x)
  `define GET_i3c_controller_host_interface_OPS_OPS_MODE(x) GetField(i3c_controller_host_interface_OPS,"OPS_MODE",x)
  `define SET_i3c_controller_host_interface_OPS_OPS_OFFLOAD_LENGTH(x) SetField(i3c_controller_host_interface_OPS,"OPS_OFFLOAD_LENGTH",x)
  `define GET_i3c_controller_host_interface_OPS_OPS_OFFLOAD_LENGTH(x) GetField(i3c_controller_host_interface_OPS,"OPS_OFFLOAD_LENGTH",x)
  `define SET_i3c_controller_host_interface_OPS_OPS_SPEED_GRADE(x) SetField(i3c_controller_host_interface_OPS,"OPS_SPEED_GRADE",x)
  `define GET_i3c_controller_host_interface_OPS_OPS_SPEED_GRADE(x) GetField(i3c_controller_host_interface_OPS,"OPS_SPEED_GRADE",x)

  const reg_t i3c_controller_host_interface_IBI_CONFIG = '{ 'h0140, "IBI_CONFIG" , '{
    "IBI_CONFIG_ENABLE": '{ 0, 0, WO, 'h0 },
    "IBI_CONFIG_AUTO": '{ 1, 1, WO, 'h0 }}};
  `define SET_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_ENABLE(x) SetField(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_ENABLE",x)
  `define GET_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_ENABLE(x) GetField(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_ENABLE",x)
  `define SET_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_AUTO(x) SetField(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_AUTO",x)
  `define GET_i3c_controller_host_interface_IBI_CONFIG_IBI_CONFIG_AUTO(x) GetField(i3c_controller_host_interface_IBI_CONFIG,"IBI_CONFIG_AUTO",x)

  const reg_t i3c_controller_host_interface_DEV_CHAR = '{ 'h0180, "DEV_CHAR" , '{
    "DEV_CHAR_IS_I2C": '{ 0, 0, RW, 'h0 },
    "DEV_CHAR_IS_ATTACHED": '{ 1, 1, RW, 'h0 },
    "DEV_CHAR_IS_IBI_CAPABLE": '{ 2, 2, RW, 'h0 },
    "DEV_CHAR_HAS_IBI_MDB": '{ 3, 3, RW, 'h0 },
    "DEV_CHAR_WEN": '{ 8, 8, W, 'hX },
    "DEV_CHAR_ADDR": '{ 15, 9, RW, 'h?? }}};
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_I2C(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_I2C",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_I2C(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_I2C",x)
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_ATTACHED(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_ATTACHED",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_ATTACHED(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_ATTACHED",x)
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_IBI_CAPABLE(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_IBI_CAPABLE",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_IS_IBI_CAPABLE(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_IS_IBI_CAPABLE",x)
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_HAS_IBI_MDB(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_HAS_IBI_MDB",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_HAS_IBI_MDB(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_HAS_IBI_MDB",x)
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_WEN(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_WEN",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_WEN(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_WEN",x)
  `define SET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_ADDR(x) SetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_ADDR",x)
  `define GET_i3c_controller_host_interface_DEV_CHAR_DEV_CHAR_ADDR(x) GetField(i3c_controller_host_interface_DEV_CHAR,"DEV_CHAR_ADDR",x)

  const reg_t i3c_controller_host_interface_OFFLOAD_CMD_n = '{ 'h02c0 + 'h04*n, "OFFLOAD_CMD_n" , '{
    "OFFLOAD_CMD": '{ 31, 0, RW, 'h?????? }}};
  `define SET_i3c_controller_host_interface_OFFLOAD_CMD_n_OFFLOAD_CMD(x) SetField(i3c_controller_host_interface_OFFLOAD_CMD_n,"OFFLOAD_CMD",x)
  `define GET_i3c_controller_host_interface_OFFLOAD_CMD_n_OFFLOAD_CMD(x) GetField(i3c_controller_host_interface_OFFLOAD_CMD_n,"OFFLOAD_CMD",x)

  const reg_t i3c_controller_host_interface_OFFLOAD_SDO_n = '{ 'h0300 + 'h04*n, "OFFLOAD_SDO_n" , '{
    "OFFLOAD_SDO_BYTE_3": '{ 31, 24, RO, 'h?? },
    "OFFLOAD_SDO_BYTE_2": '{ 23, 16, RO, 'h?? },
    "OFFLOAD_SDO_BYTE_1": '{ 15, 8, RO, 'h?? },
    "OFFLOAD_SDO_BYTE_0": '{ 7, 0, RO, 'h?? }}};
  `define SET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_3(x) SetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_3",x)
  `define GET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_3(x) GetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_3",x)
  `define SET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_2(x) SetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_2",x)
  `define GET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_2(x) GetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_2",x)
  `define SET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_1(x) SetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_1",x)
  `define GET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_1(x) GetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_1",x)
  `define SET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_0(x) SetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_0",x)
  `define GET_i3c_controller_host_interface_OFFLOAD_SDO_n_OFFLOAD_SDO_BYTE_0(x) GetField(i3c_controller_host_interface_OFFLOAD_SDO_n,"OFFLOAD_SDO_BYTE_0",x)


endpackage
