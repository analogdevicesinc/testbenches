// ***************************************************************************
// ***************************************************************************
// Copyright 2014 _ 2018 (c) Analog Devices, Inc. All rights reserved.
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
//      <https://www.gnu.org/licenses/old_licenses/gpl_2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on_line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
/* Auto generated Register Map */
/* Fri May 28 12:27:32 2021 */

package adi_regmap_spi_engine_pkg;
  import adi_regmap_pkg::*;


/* SPI Engine (axi_spi_engine) */

  const reg_t axi_spi_engine_VERSION = '{ 'h0000, "VERSION" , '{
    "VERSION_MAJOR": '{ 31, 16, RO, 'h01 },
    "VERSION_MINOR": '{ 15, 8, RO, 'h00 },
    "VERSION_PATCH": '{ 7, 0, RO, 'h71 }}};
  `define SET_axi_spi_engine_VERSION_VERSION_MAJOR(x) SetField(axi_spi_engine_VERSION,"VERSION_MAJOR",x)
  `define GET_axi_spi_engine_VERSION_VERSION_MAJOR(x) GetField(axi_spi_engine_VERSION,"VERSION_MAJOR",x)
  `define SET_axi_spi_engine_VERSION_VERSION_MINOR(x) SetField(axi_spi_engine_VERSION,"VERSION_MINOR",x)
  `define GET_axi_spi_engine_VERSION_VERSION_MINOR(x) GetField(axi_spi_engine_VERSION,"VERSION_MINOR",x)
  `define SET_axi_spi_engine_VERSION_VERSION_PATCH(x) SetField(axi_spi_engine_VERSION,"VERSION_PATCH",x)
  `define GET_axi_spi_engine_VERSION_VERSION_PATCH(x) GetField(axi_spi_engine_VERSION,"VERSION_PATCH",x)

  const reg_t axi_spi_engine_PERIPHERAL_ID = '{ 'h0004, "PERIPHERAL_ID" , '{
    "PERIPHERAL_ID": '{ 31, 0, RO, 0 }}};
  `define SET_axi_spi_engine_PERIPHERAL_ID_PERIPHERAL_ID(x) SetField(axi_spi_engine_PERIPHERAL_ID,"PERIPHERAL_ID",x)
  `define GET_axi_spi_engine_PERIPHERAL_ID_PERIPHERAL_ID(x) GetField(axi_spi_engine_PERIPHERAL_ID,"PERIPHERAL_ID",x)

  const reg_t axi_spi_engine_SCRATCH = '{ 'h0008, "SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_axi_spi_engine_SCRATCH_SCRATCH(x) SetField(axi_spi_engine_SCRATCH,"SCRATCH",x)
  `define GET_axi_spi_engine_SCRATCH_SCRATCH(x) GetField(axi_spi_engine_SCRATCH,"SCRATCH",x)

  const reg_t axi_spi_engine_DATA_WIDTH = '{ 'h000c, "DATA_WIDTH" , '{
    "DATA_WIDTH": '{ 31, 0, RO, 'h00000008 }}};
  `define SET_axi_spi_engine_DATA_WIDTH_DATA_WIDTH(x) SetField(axi_spi_engine_DATA_WIDTH,"DATA_WIDTH",x)
  `define GET_axi_spi_engine_DATA_WIDTH_DATA_WIDTH(x) GetField(axi_spi_engine_DATA_WIDTH,"DATA_WIDTH",x)

  const reg_t axi_spi_engine_ENABLE = '{ 'h0040, "ENABLE" , '{
    "ENABLE": '{ 31, 0, RW, 'h00000001 }}};
  `define SET_axi_spi_engine_ENABLE_ENABLE(x) SetField(axi_spi_engine_ENABLE,"ENABLE",x)
  `define GET_axi_spi_engine_ENABLE_ENABLE(x) GetField(axi_spi_engine_ENABLE,"ENABLE",x)

  const reg_t axi_spi_engine_IRQ_MASK = '{ 'h0080, "IRQ_MASK" , '{
    "CMD_ALMOST_EMPTY": '{ 0, 0, RW, 'h00 },
    "SDO_ALMOST_EMPTY": '{ 1, 1, RW, 'h00 },
    "SDI_ALMOST_FULL": '{ 2, 2, RW, 'h00 },
    "SYNC_EVENT": '{ 3, 3, RW, 'h00 }}};
  `define SET_axi_spi_engine_IRQ_MASK_CMD_ALMOST_EMPTY(x) SetField(axi_spi_engine_IRQ_MASK,"CMD_ALMOST_EMPTY",x)
  `define GET_axi_spi_engine_IRQ_MASK_CMD_ALMOST_EMPTY(x) GetField(axi_spi_engine_IRQ_MASK,"CMD_ALMOST_EMPTY",x)
  `define SET_axi_spi_engine_IRQ_MASK_SDO_ALMOST_EMPTY(x) SetField(axi_spi_engine_IRQ_MASK,"SDO_ALMOST_EMPTY",x)
  `define GET_axi_spi_engine_IRQ_MASK_SDO_ALMOST_EMPTY(x) GetField(axi_spi_engine_IRQ_MASK,"SDO_ALMOST_EMPTY",x)
  `define SET_axi_spi_engine_IRQ_MASK_SDI_ALMOST_FULL(x) SetField(axi_spi_engine_IRQ_MASK,"SDI_ALMOST_FULL",x)
  `define GET_axi_spi_engine_IRQ_MASK_SDI_ALMOST_FULL(x) GetField(axi_spi_engine_IRQ_MASK,"SDI_ALMOST_FULL",x)
  `define SET_axi_spi_engine_IRQ_MASK_SYNC_EVENT(x) SetField(axi_spi_engine_IRQ_MASK,"SYNC_EVENT",x)
  `define GET_axi_spi_engine_IRQ_MASK_SYNC_EVENT(x) GetField(axi_spi_engine_IRQ_MASK,"SYNC_EVENT",x)

  const reg_t axi_spi_engine_IRQ_PENDING = '{ 'h0084, "IRQ_PENDING" , '{
    "IRQ_PENDING": '{ 31, 0, RW1C, 'h00000000 }}};
  `define SET_axi_spi_engine_IRQ_PENDING_IRQ_PENDING(x) SetField(axi_spi_engine_IRQ_PENDING,"IRQ_PENDING",x)
  `define GET_axi_spi_engine_IRQ_PENDING_IRQ_PENDING(x) GetField(axi_spi_engine_IRQ_PENDING,"IRQ_PENDING",x)

  const reg_t axi_spi_engine_IRQ_SOURCE = '{ 'h0088, "IRQ_SOURCE" , '{
    "IRQ_SOURCE": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_spi_engine_IRQ_SOURCE_IRQ_SOURCE(x) SetField(axi_spi_engine_IRQ_SOURCE,"IRQ_SOURCE",x)
  `define GET_axi_spi_engine_IRQ_SOURCE_IRQ_SOURCE(x) GetField(axi_spi_engine_IRQ_SOURCE,"IRQ_SOURCE",x)

  const reg_t axi_spi_engine_SYNC_ID = '{ 'h00c0, "SYNC_ID" , '{
    "SYNC_ID": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_spi_engine_SYNC_ID_SYNC_ID(x) SetField(axi_spi_engine_SYNC_ID,"SYNC_ID",x)
  `define GET_axi_spi_engine_SYNC_ID_SYNC_ID(x) GetField(axi_spi_engine_SYNC_ID,"SYNC_ID",x)

  const reg_t axi_spi_engine_CMD_FIFO_ROOM = '{ 'h00d0, "CMD_FIFO_ROOM" , '{
    "CMD_FIFO_ROOM": '{ 31, 0, RO, 'h???????? }}};
  `define SET_axi_spi_engine_CMD_FIFO_ROOM_CMD_FIFO_ROOM(x) SetField(axi_spi_engine_CMD_FIFO_ROOM,"CMD_FIFO_ROOM",x)
  `define GET_axi_spi_engine_CMD_FIFO_ROOM_CMD_FIFO_ROOM(x) GetField(axi_spi_engine_CMD_FIFO_ROOM,"CMD_FIFO_ROOM",x)

  const reg_t axi_spi_engine_SDO_FIFO_ROOM = '{ 'h00d4, "SDO_FIFO_ROOM" , '{
    "SDO_FIFO_ROOM": '{ 31, 0, RO, 'h???????? }}};
  `define SET_axi_spi_engine_SDO_FIFO_ROOM_SDO_FIFO_ROOM(x) SetField(axi_spi_engine_SDO_FIFO_ROOM,"SDO_FIFO_ROOM",x)
  `define GET_axi_spi_engine_SDO_FIFO_ROOM_SDO_FIFO_ROOM(x) GetField(axi_spi_engine_SDO_FIFO_ROOM,"SDO_FIFO_ROOM",x)

  const reg_t axi_spi_engine_SDI_FIFO_LEVEL = '{ 'h00d8, "SDI_FIFO_LEVEL" , '{
    "SDI_FIFO_LEVEL": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_spi_engine_SDI_FIFO_LEVEL_SDI_FIFO_LEVEL(x) SetField(axi_spi_engine_SDI_FIFO_LEVEL,"SDI_FIFO_LEVEL",x)
  `define GET_axi_spi_engine_SDI_FIFO_LEVEL_SDI_FIFO_LEVEL(x) GetField(axi_spi_engine_SDI_FIFO_LEVEL,"SDI_FIFO_LEVEL",x)

  const reg_t axi_spi_engine_CMD_FIFO = '{ 'h00e0, "CMD_FIFO" , '{
    "CMD_FIFO": '{ 31, 0, WO, 'h????????? }}};
  `define SET_axi_spi_engine_CMD_FIFO_CMD_FIFO(x) SetField(axi_spi_engine_CMD_FIFO,"CMD_FIFO",x)
  `define GET_axi_spi_engine_CMD_FIFO_CMD_FIFO(x) GetField(axi_spi_engine_CMD_FIFO,"CMD_FIFO",x)

  const reg_t axi_spi_engine_SDO_FIFO = '{ 'h00e4, "SDO_FIFO" , '{
    "SDO_FIFO": '{ 31, 0, WO, 'h????????? }}};
  `define SET_axi_spi_engine_SDO_FIFO_SDO_FIFO(x) SetField(axi_spi_engine_SDO_FIFO,"SDO_FIFO",x)
  `define GET_axi_spi_engine_SDO_FIFO_SDO_FIFO(x) GetField(axi_spi_engine_SDO_FIFO,"SDO_FIFO",x)

  const reg_t axi_spi_engine_SDI_FIFO = '{ 'h00e8, "SDI_FIFO" , '{
    "SDI_FIFO": '{ 31, 0, RO, 'h????????? }}};
  `define SET_axi_spi_engine_SDI_FIFO_SDI_FIFO(x) SetField(axi_spi_engine_SDI_FIFO,"SDI_FIFO",x)
  `define GET_axi_spi_engine_SDI_FIFO_SDI_FIFO(x) GetField(axi_spi_engine_SDI_FIFO,"SDI_FIFO",x)

  const reg_t axi_spi_engine_SDI_FIFO_PEEK = '{ 'h00f0, "SDI_FIFO_PEEK" , '{
    "SDI_FIFO_PEEK": '{ 31, 0, RO, 'h????????? }}};
  `define SET_axi_spi_engine_SDI_FIFO_PEEK_SDI_FIFO_PEEK(x) SetField(axi_spi_engine_SDI_FIFO_PEEK,"SDI_FIFO_PEEK",x)
  `define GET_axi_spi_engine_SDI_FIFO_PEEK_SDI_FIFO_PEEK(x) GetField(axi_spi_engine_SDI_FIFO_PEEK,"SDI_FIFO_PEEK",x)

  const reg_t axi_spi_engine_OFFLOAD0_EN = '{ 'h0100, "OFFLOAD0_EN" , '{
    "OFFLOAD0_EN": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_axi_spi_engine_OFFLOAD0_EN_OFFLOAD0_EN(x) SetField(axi_spi_engine_OFFLOAD0_EN,"OFFLOAD0_EN",x)
  `define GET_axi_spi_engine_OFFLOAD0_EN_OFFLOAD0_EN(x) GetField(axi_spi_engine_OFFLOAD0_EN,"OFFLOAD0_EN",x)

  const reg_t axi_spi_engine_OFFLOAD0_STATUS = '{ 'h0104, "OFFLOAD0_STATUS" , '{
    "OFFLOAD0_STATUS": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_spi_engine_OFFLOAD0_STATUS_OFFLOAD0_STATUS(x) SetField(axi_spi_engine_OFFLOAD0_STATUS,"OFFLOAD0_STATUS",x)
  `define GET_axi_spi_engine_OFFLOAD0_STATUS_OFFLOAD0_STATUS(x) GetField(axi_spi_engine_OFFLOAD0_STATUS,"OFFLOAD0_STATUS",x)

  const reg_t axi_spi_engine_OFFLOAD0_MEM_RESET = '{ 'h0108, "OFFLOAD0_MEM_RESET" , '{
    "OFFLOAD0_MEM_RESET": '{ 31, 0, WO, 'h00000000 }}};
  `define SET_axi_spi_engine_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(x) SetField(axi_spi_engine_OFFLOAD0_MEM_RESET,"OFFLOAD0_MEM_RESET",x)
  `define GET_axi_spi_engine_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(x) GetField(axi_spi_engine_OFFLOAD0_MEM_RESET,"OFFLOAD0_MEM_RESET",x)

  const reg_t axi_spi_engine_OFFLOAD0_CDM_FIFO = '{ 'h0110, "OFFLOAD0_CDM_FIFO" , '{
    "OFFLOAD0_CDM_FIFO": '{ 31, 0, WO, 'h???????? }}};
  `define SET_axi_spi_engine_OFFLOAD0_CDM_FIFO_OFFLOAD0_CDM_FIFO(x) SetField(axi_spi_engine_OFFLOAD0_CDM_FIFO,"OFFLOAD0_CDM_FIFO",x)
  `define GET_axi_spi_engine_OFFLOAD0_CDM_FIFO_OFFLOAD0_CDM_FIFO(x) GetField(axi_spi_engine_OFFLOAD0_CDM_FIFO,"OFFLOAD0_CDM_FIFO",x)

  const reg_t axi_spi_engine_OFFLOAD0_SDO_FIFO = '{ 'h0114, "OFFLOAD0_SDO_FIFO" , '{
    "OFFLOAD0_SDO_FIFO": '{ 31, 0, WO, 'h???????? }}};
  `define SET_axi_spi_engine_OFFLOAD0_SDO_FIFO_OFFLOAD0_SDO_FIFO(x) SetField(axi_spi_engine_OFFLOAD0_SDO_FIFO,"OFFLOAD0_SDO_FIFO",x)
  `define GET_axi_spi_engine_OFFLOAD0_SDO_FIFO_OFFLOAD0_SDO_FIFO(x) GetField(axi_spi_engine_OFFLOAD0_SDO_FIFO,"OFFLOAD0_SDO_FIFO",x)

  const reg_t axi_spi_engine_PULSE_GEN_PERIOD = '{ 'h0120, "PULSE_GEN_PERIOD" , '{
    "PULSE_GEN_PERIOD": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_axi_spi_engine_PULSE_GEN_PERIOD_PULSE_GEN_PERIOD(x) SetField(axi_spi_engine_PULSE_GEN_PERIOD,"PULSE_GEN_PERIOD",x)
  `define GET_axi_spi_engine_PULSE_GEN_PERIOD_PULSE_GEN_PERIOD(x) GetField(axi_spi_engine_PULSE_GEN_PERIOD,"PULSE_GEN_PERIOD",x)


endpackage
