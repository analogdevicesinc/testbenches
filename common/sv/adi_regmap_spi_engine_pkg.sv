// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2023 (c) Analog Devices, Inc. All rights reserved.
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
/* Wed Mar 27 10:39:31 2024 */

package adi_regmap_spi_engine_pkg;
  import adi_regmap_pkg::*;


/* SPI Engine (axi_spi_engine) */

  const reg_t AXI_SPI_ENGINE_VERSION = '{ 'h0000, "VERSION" , '{
    "VERSION_MAJOR": '{ 31, 16, RO, 'h01 },
    "VERSION_MINOR": '{ 15, 8, RO, 'h01 },
    "VERSION_PATCH": '{ 7, 0, RO, 'h71 }}};
  `define SET_AXI_SPI_ENGINE_VERSION_VERSION_MAJOR(x) SetField(AXI_SPI_ENGINE_VERSION,"VERSION_MAJOR",x)
  `define GET_AXI_SPI_ENGINE_VERSION_VERSION_MAJOR(x) GetField(AXI_SPI_ENGINE_VERSION,"VERSION_MAJOR",x)
  `define SET_AXI_SPI_ENGINE_VERSION_VERSION_MINOR(x) SetField(AXI_SPI_ENGINE_VERSION,"VERSION_MINOR",x)
  `define GET_AXI_SPI_ENGINE_VERSION_VERSION_MINOR(x) GetField(AXI_SPI_ENGINE_VERSION,"VERSION_MINOR",x)
  `define SET_AXI_SPI_ENGINE_VERSION_VERSION_PATCH(x) SetField(AXI_SPI_ENGINE_VERSION,"VERSION_PATCH",x)
  `define GET_AXI_SPI_ENGINE_VERSION_VERSION_PATCH(x) GetField(AXI_SPI_ENGINE_VERSION,"VERSION_PATCH",x)

  const reg_t AXI_SPI_ENGINE_PERIPHERAL_ID = '{ 'h0004, "PERIPHERAL_ID" , '{
    "PERIPHERAL_ID": '{ 31, 0, RO, 0 }}};
  `define SET_AXI_SPI_ENGINE_PERIPHERAL_ID_PERIPHERAL_ID(x) SetField(AXI_SPI_ENGINE_PERIPHERAL_ID,"PERIPHERAL_ID",x)
  `define GET_AXI_SPI_ENGINE_PERIPHERAL_ID_PERIPHERAL_ID(x) GetField(AXI_SPI_ENGINE_PERIPHERAL_ID,"PERIPHERAL_ID",x)

  const reg_t AXI_SPI_ENGINE_SCRATCH = '{ 'h0008, "SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h0 }}};
  `define SET_AXI_SPI_ENGINE_SCRATCH_SCRATCH(x) SetField(AXI_SPI_ENGINE_SCRATCH,"SCRATCH",x)
  `define GET_AXI_SPI_ENGINE_SCRATCH_SCRATCH(x) GetField(AXI_SPI_ENGINE_SCRATCH,"SCRATCH",x)

  const reg_t AXI_SPI_ENGINE_DATA_WIDTH = '{ 'h000c, "DATA_WIDTH" , '{
    "NUM_OF_SDI": '{ 7, 4, RO, 0 },
    "DATA_WIDTH": '{ 3, 0, RO, 0 }}};
  `define SET_AXI_SPI_ENGINE_DATA_WIDTH_NUM_OF_SDI(x) SetField(AXI_SPI_ENGINE_DATA_WIDTH,"NUM_OF_SDI",x)
  `define GET_AXI_SPI_ENGINE_DATA_WIDTH_NUM_OF_SDI(x) GetField(AXI_SPI_ENGINE_DATA_WIDTH,"NUM_OF_SDI",x)
  `define SET_AXI_SPI_ENGINE_DATA_WIDTH_DATA_WIDTH(x) SetField(AXI_SPI_ENGINE_DATA_WIDTH,"DATA_WIDTH",x)
  `define GET_AXI_SPI_ENGINE_DATA_WIDTH_DATA_WIDTH(x) GetField(AXI_SPI_ENGINE_DATA_WIDTH,"DATA_WIDTH",x)

  const reg_t AXI_SPI_ENGINE_OFFLOAD_MEM_ADDR_WIDTH = '{ 'h0010, "OFFLOAD_MEM_ADDR_WIDTH" , '{
    "SDO_MEM_ADDRESS_WIDTH": '{ 15, 8, RO, 'h04 },
    "CMD_MEM_ADDRESS_WIDTH": '{ 7, 0, RO, 'h04 }}};
  `define SET_AXI_SPI_ENGINE_OFFLOAD_MEM_ADDR_WIDTH_SDO_MEM_ADDRESS_WIDTH(x) SetField(AXI_SPI_ENGINE_OFFLOAD_MEM_ADDR_WIDTH,"SDO_MEM_ADDRESS_WIDTH",x)
  `define GET_AXI_SPI_ENGINE_OFFLOAD_MEM_ADDR_WIDTH_SDO_MEM_ADDRESS_WIDTH(x) GetField(AXI_SPI_ENGINE_OFFLOAD_MEM_ADDR_WIDTH,"SDO_MEM_ADDRESS_WIDTH",x)
  `define SET_AXI_SPI_ENGINE_OFFLOAD_MEM_ADDR_WIDTH_CMD_MEM_ADDRESS_WIDTH(x) SetField(AXI_SPI_ENGINE_OFFLOAD_MEM_ADDR_WIDTH,"CMD_MEM_ADDRESS_WIDTH",x)
  `define GET_AXI_SPI_ENGINE_OFFLOAD_MEM_ADDR_WIDTH_CMD_MEM_ADDRESS_WIDTH(x) GetField(AXI_SPI_ENGINE_OFFLOAD_MEM_ADDR_WIDTH,"CMD_MEM_ADDRESS_WIDTH",x)

  const reg_t AXI_SPI_ENGINE_FIFO_ADDR_WIDTH = '{ 'h0014, "FIFO_ADDR_WIDTH" , '{
    "SDI_FIFO_ADDRESS_WIDTH": '{ 31, 24, RO, 'h05 },
    "SDO_FIFO_ADDRESS_WIDTH": '{ 23, 16, RO, 'h05 },
    "SYNC_FIFO_ADDRESS_WIDTH": '{ 15, 8, RO, 'h04 },
    "CMD_FIFO_ADDRESS_WIDTH": '{ 7, 0, RO, 'h04 }}};
  `define SET_AXI_SPI_ENGINE_FIFO_ADDR_WIDTH_SDI_FIFO_ADDRESS_WIDTH(x) SetField(AXI_SPI_ENGINE_FIFO_ADDR_WIDTH,"SDI_FIFO_ADDRESS_WIDTH",x)
  `define GET_AXI_SPI_ENGINE_FIFO_ADDR_WIDTH_SDI_FIFO_ADDRESS_WIDTH(x) GetField(AXI_SPI_ENGINE_FIFO_ADDR_WIDTH,"SDI_FIFO_ADDRESS_WIDTH",x)
  `define SET_AXI_SPI_ENGINE_FIFO_ADDR_WIDTH_SDO_FIFO_ADDRESS_WIDTH(x) SetField(AXI_SPI_ENGINE_FIFO_ADDR_WIDTH,"SDO_FIFO_ADDRESS_WIDTH",x)
  `define GET_AXI_SPI_ENGINE_FIFO_ADDR_WIDTH_SDO_FIFO_ADDRESS_WIDTH(x) GetField(AXI_SPI_ENGINE_FIFO_ADDR_WIDTH,"SDO_FIFO_ADDRESS_WIDTH",x)
  `define SET_AXI_SPI_ENGINE_FIFO_ADDR_WIDTH_SYNC_FIFO_ADDRESS_WIDTH(x) SetField(AXI_SPI_ENGINE_FIFO_ADDR_WIDTH,"SYNC_FIFO_ADDRESS_WIDTH",x)
  `define GET_AXI_SPI_ENGINE_FIFO_ADDR_WIDTH_SYNC_FIFO_ADDRESS_WIDTH(x) GetField(AXI_SPI_ENGINE_FIFO_ADDR_WIDTH,"SYNC_FIFO_ADDRESS_WIDTH",x)
  `define SET_AXI_SPI_ENGINE_FIFO_ADDR_WIDTH_CMD_FIFO_ADDRESS_WIDTH(x) SetField(AXI_SPI_ENGINE_FIFO_ADDR_WIDTH,"CMD_FIFO_ADDRESS_WIDTH",x)
  `define GET_AXI_SPI_ENGINE_FIFO_ADDR_WIDTH_CMD_FIFO_ADDRESS_WIDTH(x) GetField(AXI_SPI_ENGINE_FIFO_ADDR_WIDTH,"CMD_FIFO_ADDRESS_WIDTH",x)

  const reg_t AXI_SPI_ENGINE_ENABLE = '{ 'h0040, "ENABLE" , '{
    "ENABLE": '{ 31, 0, RW, 'h1 }}};
  `define SET_AXI_SPI_ENGINE_ENABLE_ENABLE(x) SetField(AXI_SPI_ENGINE_ENABLE,"ENABLE",x)
  `define GET_AXI_SPI_ENGINE_ENABLE_ENABLE(x) GetField(AXI_SPI_ENGINE_ENABLE,"ENABLE",x)

  const reg_t AXI_SPI_ENGINE_IRQ_MASK = '{ 'h0080, "IRQ_MASK" , '{
    "CMD_ALMOST_EMPTY": '{ 0, 0, RW, 'h0 },
    "SDO_ALMOST_EMPTY": '{ 1, 1, RW, 'h0 },
    "SDI_ALMOST_FULL": '{ 2, 2, RW, 'h0 },
    "SYNC_EVENT": '{ 3, 3, RW, 'h0 },
    "OFFLOAD_SYNC_ID_PENDING": '{ 4, 4, RW, 'h0 }}};
  `define SET_AXI_SPI_ENGINE_IRQ_MASK_CMD_ALMOST_EMPTY(x) SetField(AXI_SPI_ENGINE_IRQ_MASK,"CMD_ALMOST_EMPTY",x)
  `define GET_AXI_SPI_ENGINE_IRQ_MASK_CMD_ALMOST_EMPTY(x) GetField(AXI_SPI_ENGINE_IRQ_MASK,"CMD_ALMOST_EMPTY",x)
  `define SET_AXI_SPI_ENGINE_IRQ_MASK_SDO_ALMOST_EMPTY(x) SetField(AXI_SPI_ENGINE_IRQ_MASK,"SDO_ALMOST_EMPTY",x)
  `define GET_AXI_SPI_ENGINE_IRQ_MASK_SDO_ALMOST_EMPTY(x) GetField(AXI_SPI_ENGINE_IRQ_MASK,"SDO_ALMOST_EMPTY",x)
  `define SET_AXI_SPI_ENGINE_IRQ_MASK_SDI_ALMOST_FULL(x) SetField(AXI_SPI_ENGINE_IRQ_MASK,"SDI_ALMOST_FULL",x)
  `define GET_AXI_SPI_ENGINE_IRQ_MASK_SDI_ALMOST_FULL(x) GetField(AXI_SPI_ENGINE_IRQ_MASK,"SDI_ALMOST_FULL",x)
  `define SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(x) SetField(AXI_SPI_ENGINE_IRQ_MASK,"SYNC_EVENT",x)
  `define GET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(x) GetField(AXI_SPI_ENGINE_IRQ_MASK,"SYNC_EVENT",x)
  `define SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(x) SetField(AXI_SPI_ENGINE_IRQ_MASK,"OFFLOAD_SYNC_ID_PENDING",x)
  `define GET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(x) GetField(AXI_SPI_ENGINE_IRQ_MASK,"OFFLOAD_SYNC_ID_PENDING",x)

  const reg_t AXI_SPI_ENGINE_IRQ_PENDING = '{ 'h0084, "IRQ_PENDING" , '{
    "IRQ_PENDING": '{ 31, 0, RW1C, 'h0 }}};
  `define SET_AXI_SPI_ENGINE_IRQ_PENDING_IRQ_PENDING(x) SetField(AXI_SPI_ENGINE_IRQ_PENDING,"IRQ_PENDING",x)
  `define GET_AXI_SPI_ENGINE_IRQ_PENDING_IRQ_PENDING(x) GetField(AXI_SPI_ENGINE_IRQ_PENDING,"IRQ_PENDING",x)

  const reg_t AXI_SPI_ENGINE_IRQ_SOURCE = '{ 'h0088, "IRQ_SOURCE" , '{
    "IRQ_SOURCE": '{ 31, 0, RO, 'h0 }}};
  `define SET_AXI_SPI_ENGINE_IRQ_SOURCE_IRQ_SOURCE(x) SetField(AXI_SPI_ENGINE_IRQ_SOURCE,"IRQ_SOURCE",x)
  `define GET_AXI_SPI_ENGINE_IRQ_SOURCE_IRQ_SOURCE(x) GetField(AXI_SPI_ENGINE_IRQ_SOURCE,"IRQ_SOURCE",x)

  const reg_t AXI_SPI_ENGINE_SYNC_ID = '{ 'h00c0, "SYNC_ID" , '{
    "SYNC_ID": '{ 31, 0, RO, 'hXXXXXXXX }}};
  `define SET_AXI_SPI_ENGINE_SYNC_ID_SYNC_ID(x) SetField(AXI_SPI_ENGINE_SYNC_ID,"SYNC_ID",x)
  `define GET_AXI_SPI_ENGINE_SYNC_ID_SYNC_ID(x) GetField(AXI_SPI_ENGINE_SYNC_ID,"SYNC_ID",x)

  const reg_t AXI_SPI_ENGINE_OFFLOAD_SYNC_ID = '{ 'h00c4, "OFFLOAD_SYNC_ID" , '{
    "OFFLOAD_SYNC_ID": '{ 31, 0, RO, 'h0 }}};
  `define SET_AXI_SPI_ENGINE_OFFLOAD_SYNC_ID_OFFLOAD_SYNC_ID(x) SetField(AXI_SPI_ENGINE_OFFLOAD_SYNC_ID,"OFFLOAD_SYNC_ID",x)
  `define GET_AXI_SPI_ENGINE_OFFLOAD_SYNC_ID_OFFLOAD_SYNC_ID(x) GetField(AXI_SPI_ENGINE_OFFLOAD_SYNC_ID,"OFFLOAD_SYNC_ID",x)

  const reg_t AXI_SPI_ENGINE_CMD_FIFO_ROOM = '{ 'h00d0, "CMD_FIFO_ROOM" , '{
    "CMD_FIFO_ROOM": '{ 31, 0, RO, 0 }}};
  `define SET_AXI_SPI_ENGINE_CMD_FIFO_ROOM_CMD_FIFO_ROOM(x) SetField(AXI_SPI_ENGINE_CMD_FIFO_ROOM,"CMD_FIFO_ROOM",x)
  `define GET_AXI_SPI_ENGINE_CMD_FIFO_ROOM_CMD_FIFO_ROOM(x) GetField(AXI_SPI_ENGINE_CMD_FIFO_ROOM,"CMD_FIFO_ROOM",x)

  const reg_t AXI_SPI_ENGINE_SDO_FIFO_ROOM = '{ 'h00d4, "SDO_FIFO_ROOM" , '{
    "SDO_FIFO_ROOM": '{ 31, 0, RO, 0 }}};
  `define SET_AXI_SPI_ENGINE_SDO_FIFO_ROOM_SDO_FIFO_ROOM(x) SetField(AXI_SPI_ENGINE_SDO_FIFO_ROOM,"SDO_FIFO_ROOM",x)
  `define GET_AXI_SPI_ENGINE_SDO_FIFO_ROOM_SDO_FIFO_ROOM(x) GetField(AXI_SPI_ENGINE_SDO_FIFO_ROOM,"SDO_FIFO_ROOM",x)

  const reg_t AXI_SPI_ENGINE_SDI_FIFO_LEVEL = '{ 'h00d8, "SDI_FIFO_LEVEL" , '{
    "SDI_FIFO_LEVEL": '{ 31, 0, RO, 'h0 }}};
  `define SET_AXI_SPI_ENGINE_SDI_FIFO_LEVEL_SDI_FIFO_LEVEL(x) SetField(AXI_SPI_ENGINE_SDI_FIFO_LEVEL,"SDI_FIFO_LEVEL",x)
  `define GET_AXI_SPI_ENGINE_SDI_FIFO_LEVEL_SDI_FIFO_LEVEL(x) GetField(AXI_SPI_ENGINE_SDI_FIFO_LEVEL,"SDI_FIFO_LEVEL",x)

  const reg_t AXI_SPI_ENGINE_CMD_FIFO = '{ 'h00e0, "CMD_FIFO" , '{
    "CMD_FIFO": '{ 31, 0, WO, 'hXXXXXXXX }}};
  `define SET_AXI_SPI_ENGINE_CMD_FIFO_CMD_FIFO(x) SetField(AXI_SPI_ENGINE_CMD_FIFO,"CMD_FIFO",x)
  `define GET_AXI_SPI_ENGINE_CMD_FIFO_CMD_FIFO(x) GetField(AXI_SPI_ENGINE_CMD_FIFO,"CMD_FIFO",x)

  const reg_t AXI_SPI_ENGINE_SDO_FIFO = '{ 'h00e4, "SDO_FIFO" , '{
    "SDO_FIFO": '{ 31, 0, WO, 'hXXXXXXXX }}};
  `define SET_AXI_SPI_ENGINE_SDO_FIFO_SDO_FIFO(x) SetField(AXI_SPI_ENGINE_SDO_FIFO,"SDO_FIFO",x)
  `define GET_AXI_SPI_ENGINE_SDO_FIFO_SDO_FIFO(x) GetField(AXI_SPI_ENGINE_SDO_FIFO,"SDO_FIFO",x)

  const reg_t AXI_SPI_ENGINE_SDI_FIFO = '{ 'h00e8, "SDI_FIFO" , '{
    "SDI_FIFO": '{ 31, 0, RO, 'hXXXXXXXX }}};
  `define SET_AXI_SPI_ENGINE_SDI_FIFO_SDI_FIFO(x) SetField(AXI_SPI_ENGINE_SDI_FIFO,"SDI_FIFO",x)
  `define GET_AXI_SPI_ENGINE_SDI_FIFO_SDI_FIFO(x) GetField(AXI_SPI_ENGINE_SDI_FIFO,"SDI_FIFO",x)

  const reg_t AXI_SPI_ENGINE_SDI_FIFO_MSB = '{ 'h00ec, "SDI_FIFO_MSB" , '{
    "SDI_FIFO_MSB": '{ 31, 0, RO, 'hXXXXXXXX }}};
  `define SET_AXI_SPI_ENGINE_SDI_FIFO_MSB_SDI_FIFO_MSB(x) SetField(AXI_SPI_ENGINE_SDI_FIFO_MSB,"SDI_FIFO_MSB",x)
  `define GET_AXI_SPI_ENGINE_SDI_FIFO_MSB_SDI_FIFO_MSB(x) GetField(AXI_SPI_ENGINE_SDI_FIFO_MSB,"SDI_FIFO_MSB",x)

  const reg_t AXI_SPI_ENGINE_SDI_FIFO_PEEK = '{ 'h00f0, "SDI_FIFO_PEEK" , '{
    "SDI_FIFO_PEEK": '{ 31, 0, RO, 'hXXXXXXXX }}};
  `define SET_AXI_SPI_ENGINE_SDI_FIFO_PEEK_SDI_FIFO_PEEK(x) SetField(AXI_SPI_ENGINE_SDI_FIFO_PEEK,"SDI_FIFO_PEEK",x)
  `define GET_AXI_SPI_ENGINE_SDI_FIFO_PEEK_SDI_FIFO_PEEK(x) GetField(AXI_SPI_ENGINE_SDI_FIFO_PEEK,"SDI_FIFO_PEEK",x)

  const reg_t AXI_SPI_ENGINE_OFFLOAD0_EN = '{ 'h0100, "OFFLOAD0_EN" , '{
    "OFFLOAD0_EN": '{ 31, 0, RW, 'h0 }}};
  `define SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(x) SetField(AXI_SPI_ENGINE_OFFLOAD0_EN,"OFFLOAD0_EN",x)
  `define GET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(x) GetField(AXI_SPI_ENGINE_OFFLOAD0_EN,"OFFLOAD0_EN",x)

  const reg_t AXI_SPI_ENGINE_OFFLOAD0_STATUS = '{ 'h0104, "OFFLOAD0_STATUS" , '{
    "OFFLOAD0_STATUS": '{ 31, 0, RO, 'h0 }}};
  `define SET_AXI_SPI_ENGINE_OFFLOAD0_STATUS_OFFLOAD0_STATUS(x) SetField(AXI_SPI_ENGINE_OFFLOAD0_STATUS,"OFFLOAD0_STATUS",x)
  `define GET_AXI_SPI_ENGINE_OFFLOAD0_STATUS_OFFLOAD0_STATUS(x) GetField(AXI_SPI_ENGINE_OFFLOAD0_STATUS,"OFFLOAD0_STATUS",x)

  const reg_t AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET = '{ 'h0108, "OFFLOAD0_MEM_RESET" , '{
    "OFFLOAD0_MEM_RESET": '{ 31, 0, WO, 'h0 }}};
  `define SET_AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(x) SetField(AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET,"OFFLOAD0_MEM_RESET",x)
  `define GET_AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(x) GetField(AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET,"OFFLOAD0_MEM_RESET",x)

  const reg_t AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO = '{ 'h0110, "OFFLOAD0_CDM_FIFO" , '{
    "OFFLOAD0_CDM_FIFO": '{ 31, 0, WO, 'hXXXXXXXX }}};
  `define SET_AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO_OFFLOAD0_CDM_FIFO(x) SetField(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO,"OFFLOAD0_CDM_FIFO",x)
  `define GET_AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO_OFFLOAD0_CDM_FIFO(x) GetField(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO,"OFFLOAD0_CDM_FIFO",x)

  const reg_t AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO = '{ 'h0114, "OFFLOAD0_SDO_FIFO" , '{
    "OFFLOAD0_SDO_FIFO": '{ 31, 0, WO, 'hXXXXXXXX }}};
  `define SET_AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO_OFFLOAD0_SDO_FIFO(x) SetField(AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO,"OFFLOAD0_SDO_FIFO",x)
  `define GET_AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO_OFFLOAD0_SDO_FIFO(x) GetField(AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO,"OFFLOAD0_SDO_FIFO",x)

  const reg_t AXI_SPI_ENGINE_CFG_INFO_0 = '{ 'h0200, "CFG_INFO_0" , '{
    "CFG_INFO_0": '{ 31, 0, RO, 0 }}};
  `define SET_AXI_SPI_ENGINE_CFG_INFO_0_CFG_INFO_0(x) SetField(AXI_SPI_ENGINE_CFG_INFO_0,"CFG_INFO_0",x)
  `define GET_AXI_SPI_ENGINE_CFG_INFO_0_CFG_INFO_0(x) GetField(AXI_SPI_ENGINE_CFG_INFO_0,"CFG_INFO_0",x)

  const reg_t AXI_SPI_ENGINE_CFG_INFO_1 = '{ 'h0204, "CFG_INFO_1" , '{
    "CFG_INFO_1": '{ 31, 0, RO, 0 }}};
  `define SET_AXI_SPI_ENGINE_CFG_INFO_1_CFG_INFO_1(x) SetField(AXI_SPI_ENGINE_CFG_INFO_1,"CFG_INFO_1",x)
  `define GET_AXI_SPI_ENGINE_CFG_INFO_1_CFG_INFO_1(x) GetField(AXI_SPI_ENGINE_CFG_INFO_1,"CFG_INFO_1",x)

  const reg_t AXI_SPI_ENGINE_CFG_INFO_2 = '{ 'h0208, "CFG_INFO_2" , '{
    "CFG_INFO_2": '{ 31, 0, RO, 0 }}};
  `define SET_AXI_SPI_ENGINE_CFG_INFO_2_CFG_INFO_2(x) SetField(AXI_SPI_ENGINE_CFG_INFO_2,"CFG_INFO_2",x)
  `define GET_AXI_SPI_ENGINE_CFG_INFO_2_CFG_INFO_2(x) GetField(AXI_SPI_ENGINE_CFG_INFO_2,"CFG_INFO_2",x)

  const reg_t AXI_SPI_ENGINE_CFG_INFO_3 = '{ 'h020c, "CFG_INFO_3" , '{
    "CFG_INFO_4": '{ 31, 0, RO, 0 }}};
  `define SET_AXI_SPI_ENGINE_CFG_INFO_3_CFG_INFO_4(x) SetField(AXI_SPI_ENGINE_CFG_INFO_3,"CFG_INFO_4",x)
  `define GET_AXI_SPI_ENGINE_CFG_INFO_3_CFG_INFO_4(x) GetField(AXI_SPI_ENGINE_CFG_INFO_3,"CFG_INFO_4",x)


endpackage
