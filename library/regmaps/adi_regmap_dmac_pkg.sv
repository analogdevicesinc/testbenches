// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2024 Analog Devices, Inc. All rights reserved.
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
/* Thu May  9 16:11:55 2024 */

package adi_regmap_dmac_pkg;
  import adi_regmap_pkg::*;


/* DMA Controller (axi_dmac) */

  const reg_t DMAC_VERSION = '{ 'h0000, "VERSION" , '{
    "VERSION_MAJOR": '{ 31, 16, RO, 'h04 },
    "VERSION_MINOR": '{ 15, 8, RO, 'h05 },
    "VERSION_PATCH": '{ 7, 0, RO, 'h64 }}};
  `define SET_DMAC_VERSION_VERSION_MAJOR(x) SetField(DMAC_VERSION,"VERSION_MAJOR",x)
  `define GET_DMAC_VERSION_VERSION_MAJOR(x) GetField(DMAC_VERSION,"VERSION_MAJOR",x)
  `define DEFAULT_DMAC_VERSION_VERSION_MAJOR GetResetValue(DMAC_VERSION,"VERSION_MAJOR")
  `define UPDATE_DMAC_VERSION_VERSION_MAJOR(x,y) UpdateField(DMAC_VERSION,"VERSION_MAJOR",x,y)
  `define SET_DMAC_VERSION_VERSION_MINOR(x) SetField(DMAC_VERSION,"VERSION_MINOR",x)
  `define GET_DMAC_VERSION_VERSION_MINOR(x) GetField(DMAC_VERSION,"VERSION_MINOR",x)
  `define DEFAULT_DMAC_VERSION_VERSION_MINOR GetResetValue(DMAC_VERSION,"VERSION_MINOR")
  `define UPDATE_DMAC_VERSION_VERSION_MINOR(x,y) UpdateField(DMAC_VERSION,"VERSION_MINOR",x,y)
  `define SET_DMAC_VERSION_VERSION_PATCH(x) SetField(DMAC_VERSION,"VERSION_PATCH",x)
  `define GET_DMAC_VERSION_VERSION_PATCH(x) GetField(DMAC_VERSION,"VERSION_PATCH",x)
  `define DEFAULT_DMAC_VERSION_VERSION_PATCH GetResetValue(DMAC_VERSION,"VERSION_PATCH")
  `define UPDATE_DMAC_VERSION_VERSION_PATCH(x,y) UpdateField(DMAC_VERSION,"VERSION_PATCH",x,y)

  const reg_t DMAC_PERIPHERAL_ID = '{ 'h0004, "PERIPHERAL_ID" , '{
    "PERIPHERAL_ID": '{ 31, 0, RO, 0 }}};
  `define SET_DMAC_PERIPHERAL_ID_PERIPHERAL_ID(x) SetField(DMAC_PERIPHERAL_ID,"PERIPHERAL_ID",x)
  `define GET_DMAC_PERIPHERAL_ID_PERIPHERAL_ID(x) GetField(DMAC_PERIPHERAL_ID,"PERIPHERAL_ID",x)
  `define DEFAULT_DMAC_PERIPHERAL_ID_PERIPHERAL_ID GetResetValue(DMAC_PERIPHERAL_ID,"PERIPHERAL_ID")
  `define UPDATE_DMAC_PERIPHERAL_ID_PERIPHERAL_ID(x,y) UpdateField(DMAC_PERIPHERAL_ID,"PERIPHERAL_ID",x,y)

  const reg_t DMAC_SCRATCH = '{ 'h0008, "SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_DMAC_SCRATCH_SCRATCH(x) SetField(DMAC_SCRATCH,"SCRATCH",x)
  `define GET_DMAC_SCRATCH_SCRATCH(x) GetField(DMAC_SCRATCH,"SCRATCH",x)
  `define DEFAULT_DMAC_SCRATCH_SCRATCH GetResetValue(DMAC_SCRATCH,"SCRATCH")
  `define UPDATE_DMAC_SCRATCH_SCRATCH(x,y) UpdateField(DMAC_SCRATCH,"SCRATCH",x,y)

  const reg_t DMAC_IDENTIFICATION = '{ 'h000c, "IDENTIFICATION" , '{
    "IDENTIFICATION": '{ 31, 0, RO, 'h444D4143 }}};
  `define SET_DMAC_IDENTIFICATION_IDENTIFICATION(x) SetField(DMAC_IDENTIFICATION,"IDENTIFICATION",x)
  `define GET_DMAC_IDENTIFICATION_IDENTIFICATION(x) GetField(DMAC_IDENTIFICATION,"IDENTIFICATION",x)
  `define DEFAULT_DMAC_IDENTIFICATION_IDENTIFICATION GetResetValue(DMAC_IDENTIFICATION,"IDENTIFICATION")
  `define UPDATE_DMAC_IDENTIFICATION_IDENTIFICATION(x,y) UpdateField(DMAC_IDENTIFICATION,"IDENTIFICATION",x,y)

  const reg_t DMAC_INTERFACE_DESCRIPTION_1 = '{ 'h0010, "INTERFACE_DESCRIPTION_1" , '{
    "MAX_NUM_FRAMES": '{ 31, 27, R, 0 },
    "DMA_2D_TLAST_MODE": '{ 26, 26, R, 0 },
    "USE_EXT_SYNC": '{ 25, 25, R, 0 },
    "HAS_AUTORUN": '{ 24, 24, R, 0 },
    "BYTES_PER_BURST_WIDTH": '{ 19, 16, R, 0 },
    "DMA_TYPE_SRC": '{ 13, 12, R, 0 },
    "BYTES_PER_BEAT_SRC_LOG2": '{ 11, 8, R, 0 },
    "DMA_TYPE_DEST": '{ 5, 4, R, 0 },
    "BYTES_PER_BEAT_DEST_LOG2": '{ 3, 0, R, 0 }}};
  `define SET_DMAC_INTERFACE_DESCRIPTION_1_MAX_NUM_FRAMES(x) SetField(DMAC_INTERFACE_DESCRIPTION_1,"MAX_NUM_FRAMES",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_1_MAX_NUM_FRAMES(x) GetField(DMAC_INTERFACE_DESCRIPTION_1,"MAX_NUM_FRAMES",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_1_MAX_NUM_FRAMES GetResetValue(DMAC_INTERFACE_DESCRIPTION_1,"MAX_NUM_FRAMES")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_1_MAX_NUM_FRAMES(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_1,"MAX_NUM_FRAMES",x,y)
  `define SET_DMAC_INTERFACE_DESCRIPTION_1_DMA_2D_TLAST_MODE(x) SetField(DMAC_INTERFACE_DESCRIPTION_1,"DMA_2D_TLAST_MODE",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_1_DMA_2D_TLAST_MODE(x) GetField(DMAC_INTERFACE_DESCRIPTION_1,"DMA_2D_TLAST_MODE",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_1_DMA_2D_TLAST_MODE GetResetValue(DMAC_INTERFACE_DESCRIPTION_1,"DMA_2D_TLAST_MODE")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_1_DMA_2D_TLAST_MODE(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_1,"DMA_2D_TLAST_MODE",x,y)
  `define SET_DMAC_INTERFACE_DESCRIPTION_1_USE_EXT_SYNC(x) SetField(DMAC_INTERFACE_DESCRIPTION_1,"USE_EXT_SYNC",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_1_USE_EXT_SYNC(x) GetField(DMAC_INTERFACE_DESCRIPTION_1,"USE_EXT_SYNC",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_1_USE_EXT_SYNC GetResetValue(DMAC_INTERFACE_DESCRIPTION_1,"USE_EXT_SYNC")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_1_USE_EXT_SYNC(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_1,"USE_EXT_SYNC",x,y)
  `define SET_DMAC_INTERFACE_DESCRIPTION_1_HAS_AUTORUN(x) SetField(DMAC_INTERFACE_DESCRIPTION_1,"HAS_AUTORUN",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_1_HAS_AUTORUN(x) GetField(DMAC_INTERFACE_DESCRIPTION_1,"HAS_AUTORUN",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_1_HAS_AUTORUN GetResetValue(DMAC_INTERFACE_DESCRIPTION_1,"HAS_AUTORUN")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_1_HAS_AUTORUN(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_1,"HAS_AUTORUN",x,y)
  `define SET_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BURST_WIDTH(x) SetField(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BURST_WIDTH",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BURST_WIDTH(x) GetField(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BURST_WIDTH",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BURST_WIDTH GetResetValue(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BURST_WIDTH")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BURST_WIDTH(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BURST_WIDTH",x,y)
  `define SET_DMAC_INTERFACE_DESCRIPTION_1_DMA_TYPE_SRC(x) SetField(DMAC_INTERFACE_DESCRIPTION_1,"DMA_TYPE_SRC",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_1_DMA_TYPE_SRC(x) GetField(DMAC_INTERFACE_DESCRIPTION_1,"DMA_TYPE_SRC",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_1_DMA_TYPE_SRC GetResetValue(DMAC_INTERFACE_DESCRIPTION_1,"DMA_TYPE_SRC")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_1_DMA_TYPE_SRC(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_1,"DMA_TYPE_SRC",x,y)
  `define SET_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BEAT_SRC_LOG2(x) SetField(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BEAT_SRC_LOG2",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BEAT_SRC_LOG2(x) GetField(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BEAT_SRC_LOG2",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BEAT_SRC_LOG2 GetResetValue(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BEAT_SRC_LOG2")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BEAT_SRC_LOG2(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BEAT_SRC_LOG2",x,y)
  `define SET_DMAC_INTERFACE_DESCRIPTION_1_DMA_TYPE_DEST(x) SetField(DMAC_INTERFACE_DESCRIPTION_1,"DMA_TYPE_DEST",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_1_DMA_TYPE_DEST(x) GetField(DMAC_INTERFACE_DESCRIPTION_1,"DMA_TYPE_DEST",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_1_DMA_TYPE_DEST GetResetValue(DMAC_INTERFACE_DESCRIPTION_1,"DMA_TYPE_DEST")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_1_DMA_TYPE_DEST(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_1,"DMA_TYPE_DEST",x,y)
  `define SET_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BEAT_DEST_LOG2(x) SetField(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BEAT_DEST_LOG2",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BEAT_DEST_LOG2(x) GetField(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BEAT_DEST_LOG2",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BEAT_DEST_LOG2 GetResetValue(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BEAT_DEST_LOG2")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BEAT_DEST_LOG2(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_1,"BYTES_PER_BEAT_DEST_LOG2",x,y)

  const reg_t DMAC_INTERFACE_DESCRIPTION_2 = '{ 'h0014, "INTERFACE_DESCRIPTION_2" , '{
    "CACHE_COHERENT": '{ 0, 0, R, 0 },
    "AXI_AXCACHE": '{ 7, 4, R, 0 },
    "AXI_AXPROT": '{ 10, 8, R, 0 }}};
  `define SET_DMAC_INTERFACE_DESCRIPTION_2_CACHE_COHERENT(x) SetField(DMAC_INTERFACE_DESCRIPTION_2,"CACHE_COHERENT",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_2_CACHE_COHERENT(x) GetField(DMAC_INTERFACE_DESCRIPTION_2,"CACHE_COHERENT",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_2_CACHE_COHERENT GetResetValue(DMAC_INTERFACE_DESCRIPTION_2,"CACHE_COHERENT")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_2_CACHE_COHERENT(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_2,"CACHE_COHERENT",x,y)
  `define SET_DMAC_INTERFACE_DESCRIPTION_2_AXI_AXCACHE(x) SetField(DMAC_INTERFACE_DESCRIPTION_2,"AXI_AXCACHE",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_2_AXI_AXCACHE(x) GetField(DMAC_INTERFACE_DESCRIPTION_2,"AXI_AXCACHE",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_2_AXI_AXCACHE GetResetValue(DMAC_INTERFACE_DESCRIPTION_2,"AXI_AXCACHE")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_2_AXI_AXCACHE(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_2,"AXI_AXCACHE",x,y)
  `define SET_DMAC_INTERFACE_DESCRIPTION_2_AXI_AXPROT(x) SetField(DMAC_INTERFACE_DESCRIPTION_2,"AXI_AXPROT",x)
  `define GET_DMAC_INTERFACE_DESCRIPTION_2_AXI_AXPROT(x) GetField(DMAC_INTERFACE_DESCRIPTION_2,"AXI_AXPROT",x)
  `define DEFAULT_DMAC_INTERFACE_DESCRIPTION_2_AXI_AXPROT GetResetValue(DMAC_INTERFACE_DESCRIPTION_2,"AXI_AXPROT")
  `define UPDATE_DMAC_INTERFACE_DESCRIPTION_2_AXI_AXPROT(x,y) UpdateField(DMAC_INTERFACE_DESCRIPTION_2,"AXI_AXPROT",x,y)

  const reg_t DMAC_IRQ_MASK = '{ 'h0080, "IRQ_MASK" , '{
    "TRANSFER_COMPLETED": '{ 1, 1, RW, 'h1 },
    "TRANSFER_QUEUED": '{ 0, 0, RW, 'h1 }}};
  `define SET_DMAC_IRQ_MASK_TRANSFER_COMPLETED(x) SetField(DMAC_IRQ_MASK,"TRANSFER_COMPLETED",x)
  `define GET_DMAC_IRQ_MASK_TRANSFER_COMPLETED(x) GetField(DMAC_IRQ_MASK,"TRANSFER_COMPLETED",x)
  `define DEFAULT_DMAC_IRQ_MASK_TRANSFER_COMPLETED GetResetValue(DMAC_IRQ_MASK,"TRANSFER_COMPLETED")
  `define UPDATE_DMAC_IRQ_MASK_TRANSFER_COMPLETED(x,y) UpdateField(DMAC_IRQ_MASK,"TRANSFER_COMPLETED",x,y)
  `define SET_DMAC_IRQ_MASK_TRANSFER_QUEUED(x) SetField(DMAC_IRQ_MASK,"TRANSFER_QUEUED",x)
  `define GET_DMAC_IRQ_MASK_TRANSFER_QUEUED(x) GetField(DMAC_IRQ_MASK,"TRANSFER_QUEUED",x)
  `define DEFAULT_DMAC_IRQ_MASK_TRANSFER_QUEUED GetResetValue(DMAC_IRQ_MASK,"TRANSFER_QUEUED")
  `define UPDATE_DMAC_IRQ_MASK_TRANSFER_QUEUED(x,y) UpdateField(DMAC_IRQ_MASK,"TRANSFER_QUEUED",x,y)

  const reg_t DMAC_IRQ_PENDING = '{ 'h0084, "IRQ_PENDING" , '{
    "TRANSFER_COMPLETED": '{ 1, 1, RW1C, 'h0 },
    "TRANSFER_QUEUED": '{ 0, 0, RW1C, 'h0 }}};
  `define SET_DMAC_IRQ_PENDING_TRANSFER_COMPLETED(x) SetField(DMAC_IRQ_PENDING,"TRANSFER_COMPLETED",x)
  `define GET_DMAC_IRQ_PENDING_TRANSFER_COMPLETED(x) GetField(DMAC_IRQ_PENDING,"TRANSFER_COMPLETED",x)
  `define DEFAULT_DMAC_IRQ_PENDING_TRANSFER_COMPLETED GetResetValue(DMAC_IRQ_PENDING,"TRANSFER_COMPLETED")
  `define UPDATE_DMAC_IRQ_PENDING_TRANSFER_COMPLETED(x,y) UpdateField(DMAC_IRQ_PENDING,"TRANSFER_COMPLETED",x,y)
  `define SET_DMAC_IRQ_PENDING_TRANSFER_QUEUED(x) SetField(DMAC_IRQ_PENDING,"TRANSFER_QUEUED",x)
  `define GET_DMAC_IRQ_PENDING_TRANSFER_QUEUED(x) GetField(DMAC_IRQ_PENDING,"TRANSFER_QUEUED",x)
  `define DEFAULT_DMAC_IRQ_PENDING_TRANSFER_QUEUED GetResetValue(DMAC_IRQ_PENDING,"TRANSFER_QUEUED")
  `define UPDATE_DMAC_IRQ_PENDING_TRANSFER_QUEUED(x,y) UpdateField(DMAC_IRQ_PENDING,"TRANSFER_QUEUED",x,y)

  const reg_t DMAC_IRQ_SOURCE = '{ 'h0088, "IRQ_SOURCE" , '{
    "TRANSFER_COMPLETED": '{ 1, 1, RO, 'h0 },
    "TRANSFER_QUEUED": '{ 0, 0, RO, 'h0 }}};
  `define SET_DMAC_IRQ_SOURCE_TRANSFER_COMPLETED(x) SetField(DMAC_IRQ_SOURCE,"TRANSFER_COMPLETED",x)
  `define GET_DMAC_IRQ_SOURCE_TRANSFER_COMPLETED(x) GetField(DMAC_IRQ_SOURCE,"TRANSFER_COMPLETED",x)
  `define DEFAULT_DMAC_IRQ_SOURCE_TRANSFER_COMPLETED GetResetValue(DMAC_IRQ_SOURCE,"TRANSFER_COMPLETED")
  `define UPDATE_DMAC_IRQ_SOURCE_TRANSFER_COMPLETED(x,y) UpdateField(DMAC_IRQ_SOURCE,"TRANSFER_COMPLETED",x,y)
  `define SET_DMAC_IRQ_SOURCE_TRANSFER_QUEUED(x) SetField(DMAC_IRQ_SOURCE,"TRANSFER_QUEUED",x)
  `define GET_DMAC_IRQ_SOURCE_TRANSFER_QUEUED(x) GetField(DMAC_IRQ_SOURCE,"TRANSFER_QUEUED",x)
  `define DEFAULT_DMAC_IRQ_SOURCE_TRANSFER_QUEUED GetResetValue(DMAC_IRQ_SOURCE,"TRANSFER_QUEUED")
  `define UPDATE_DMAC_IRQ_SOURCE_TRANSFER_QUEUED(x,y) UpdateField(DMAC_IRQ_SOURCE,"TRANSFER_QUEUED",x,y)

  const reg_t DMAC_CONTROL = '{ 'h0400, "CONTROL" , '{
    "FRAMELOCK": '{ 3, 3, RW, 'h0 },
    "HWDESC": '{ 2, 2, RW, 'h0 },
    "PAUSE": '{ 1, 1, RW, 'h0 },
    "ENABLE": '{ 0, 0, RW, 'h0 }}};
  `define SET_DMAC_CONTROL_FRAMELOCK(x) SetField(DMAC_CONTROL,"FRAMELOCK",x)
  `define GET_DMAC_CONTROL_FRAMELOCK(x) GetField(DMAC_CONTROL,"FRAMELOCK",x)
  `define DEFAULT_DMAC_CONTROL_FRAMELOCK GetResetValue(DMAC_CONTROL,"FRAMELOCK")
  `define UPDATE_DMAC_CONTROL_FRAMELOCK(x,y) UpdateField(DMAC_CONTROL,"FRAMELOCK",x,y)
  `define SET_DMAC_CONTROL_HWDESC(x) SetField(DMAC_CONTROL,"HWDESC",x)
  `define GET_DMAC_CONTROL_HWDESC(x) GetField(DMAC_CONTROL,"HWDESC",x)
  `define DEFAULT_DMAC_CONTROL_HWDESC GetResetValue(DMAC_CONTROL,"HWDESC")
  `define UPDATE_DMAC_CONTROL_HWDESC(x,y) UpdateField(DMAC_CONTROL,"HWDESC",x,y)
  `define SET_DMAC_CONTROL_PAUSE(x) SetField(DMAC_CONTROL,"PAUSE",x)
  `define GET_DMAC_CONTROL_PAUSE(x) GetField(DMAC_CONTROL,"PAUSE",x)
  `define DEFAULT_DMAC_CONTROL_PAUSE GetResetValue(DMAC_CONTROL,"PAUSE")
  `define UPDATE_DMAC_CONTROL_PAUSE(x,y) UpdateField(DMAC_CONTROL,"PAUSE",x,y)
  `define SET_DMAC_CONTROL_ENABLE(x) SetField(DMAC_CONTROL,"ENABLE",x)
  `define GET_DMAC_CONTROL_ENABLE(x) GetField(DMAC_CONTROL,"ENABLE",x)
  `define DEFAULT_DMAC_CONTROL_ENABLE GetResetValue(DMAC_CONTROL,"ENABLE")
  `define UPDATE_DMAC_CONTROL_ENABLE(x,y) UpdateField(DMAC_CONTROL,"ENABLE",x,y)

  const reg_t DMAC_TRANSFER_ID = '{ 'h0404, "TRANSFER_ID" , '{
    "TRANSFER_ID": '{ 1, 0, RO, 'h00 }}};
  `define SET_DMAC_TRANSFER_ID_TRANSFER_ID(x) SetField(DMAC_TRANSFER_ID,"TRANSFER_ID",x)
  `define GET_DMAC_TRANSFER_ID_TRANSFER_ID(x) GetField(DMAC_TRANSFER_ID,"TRANSFER_ID",x)
  `define DEFAULT_DMAC_TRANSFER_ID_TRANSFER_ID GetResetValue(DMAC_TRANSFER_ID,"TRANSFER_ID")
  `define UPDATE_DMAC_TRANSFER_ID_TRANSFER_ID(x,y) UpdateField(DMAC_TRANSFER_ID,"TRANSFER_ID",x,y)

  const reg_t DMAC_TRANSFER_SUBMIT = '{ 'h0408, "TRANSFER_SUBMIT" , '{
    "TRANSFER_SUBMIT": '{ 0, 0, RW, 'h0 }}};
  `define SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(x) SetField(DMAC_TRANSFER_SUBMIT,"TRANSFER_SUBMIT",x)
  `define GET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(x) GetField(DMAC_TRANSFER_SUBMIT,"TRANSFER_SUBMIT",x)
  `define DEFAULT_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT GetResetValue(DMAC_TRANSFER_SUBMIT,"TRANSFER_SUBMIT")
  `define UPDATE_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(x,y) UpdateField(DMAC_TRANSFER_SUBMIT,"TRANSFER_SUBMIT",x,y)

  const reg_t DMAC_FLAGS = '{ 'h040c, "FLAGS" , '{
    "PARTIAL_REPORTING_EN": '{ 2, 2, RW, 0 },
    "TLAST": '{ 1, 1, RW, 0 },
    "CYCLIC": '{ 0, 0, RW, 0 }}};
  `define SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(x) SetField(DMAC_FLAGS,"PARTIAL_REPORTING_EN",x)
  `define GET_DMAC_FLAGS_PARTIAL_REPORTING_EN(x) GetField(DMAC_FLAGS,"PARTIAL_REPORTING_EN",x)
  `define DEFAULT_DMAC_FLAGS_PARTIAL_REPORTING_EN GetResetValue(DMAC_FLAGS,"PARTIAL_REPORTING_EN")
  `define UPDATE_DMAC_FLAGS_PARTIAL_REPORTING_EN(x,y) UpdateField(DMAC_FLAGS,"PARTIAL_REPORTING_EN",x,y)
  `define SET_DMAC_FLAGS_TLAST(x) SetField(DMAC_FLAGS,"TLAST",x)
  `define GET_DMAC_FLAGS_TLAST(x) GetField(DMAC_FLAGS,"TLAST",x)
  `define DEFAULT_DMAC_FLAGS_TLAST GetResetValue(DMAC_FLAGS,"TLAST")
  `define UPDATE_DMAC_FLAGS_TLAST(x,y) UpdateField(DMAC_FLAGS,"TLAST",x,y)
  `define SET_DMAC_FLAGS_CYCLIC(x) SetField(DMAC_FLAGS,"CYCLIC",x)
  `define GET_DMAC_FLAGS_CYCLIC(x) GetField(DMAC_FLAGS,"CYCLIC",x)
  `define DEFAULT_DMAC_FLAGS_CYCLIC GetResetValue(DMAC_FLAGS,"CYCLIC")
  `define UPDATE_DMAC_FLAGS_CYCLIC(x,y) UpdateField(DMAC_FLAGS,"CYCLIC",x,y)

  const reg_t DMAC_DEST_ADDRESS = '{ 'h0410, "DEST_ADDRESS" , '{
    "DEST_ADDRESS": '{ 31, 0, RW, 0 }}};
  `define SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(x) SetField(DMAC_DEST_ADDRESS,"DEST_ADDRESS",x)
  `define GET_DMAC_DEST_ADDRESS_DEST_ADDRESS(x) GetField(DMAC_DEST_ADDRESS,"DEST_ADDRESS",x)
  `define DEFAULT_DMAC_DEST_ADDRESS_DEST_ADDRESS GetResetValue(DMAC_DEST_ADDRESS,"DEST_ADDRESS")
  `define UPDATE_DMAC_DEST_ADDRESS_DEST_ADDRESS(x,y) UpdateField(DMAC_DEST_ADDRESS,"DEST_ADDRESS",x,y)

  const reg_t DMAC_SRC_ADDRESS = '{ 'h0414, "SRC_ADDRESS" , '{
    "SRC_ADDRESS": '{ 31, 0, RW, 0 }}};
  `define SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(x) SetField(DMAC_SRC_ADDRESS,"SRC_ADDRESS",x)
  `define GET_DMAC_SRC_ADDRESS_SRC_ADDRESS(x) GetField(DMAC_SRC_ADDRESS,"SRC_ADDRESS",x)
  `define DEFAULT_DMAC_SRC_ADDRESS_SRC_ADDRESS GetResetValue(DMAC_SRC_ADDRESS,"SRC_ADDRESS")
  `define UPDATE_DMAC_SRC_ADDRESS_SRC_ADDRESS(x,y) UpdateField(DMAC_SRC_ADDRESS,"SRC_ADDRESS",x,y)

  const reg_t DMAC_X_LENGTH = '{ 'h0418, "X_LENGTH" , '{
    "X_LENGTH": '{ 23, 0, RW, 0 }}};
  `define SET_DMAC_X_LENGTH_X_LENGTH(x) SetField(DMAC_X_LENGTH,"X_LENGTH",x)
  `define GET_DMAC_X_LENGTH_X_LENGTH(x) GetField(DMAC_X_LENGTH,"X_LENGTH",x)
  `define DEFAULT_DMAC_X_LENGTH_X_LENGTH GetResetValue(DMAC_X_LENGTH,"X_LENGTH")
  `define UPDATE_DMAC_X_LENGTH_X_LENGTH(x,y) UpdateField(DMAC_X_LENGTH,"X_LENGTH",x,y)

  const reg_t DMAC_Y_LENGTH = '{ 'h041c, "Y_LENGTH" , '{
    "Y_LENGTH": '{ 23, 0, RW, 0 }}};
  `define SET_DMAC_Y_LENGTH_Y_LENGTH(x) SetField(DMAC_Y_LENGTH,"Y_LENGTH",x)
  `define GET_DMAC_Y_LENGTH_Y_LENGTH(x) GetField(DMAC_Y_LENGTH,"Y_LENGTH",x)
  `define DEFAULT_DMAC_Y_LENGTH_Y_LENGTH GetResetValue(DMAC_Y_LENGTH,"Y_LENGTH")
  `define UPDATE_DMAC_Y_LENGTH_Y_LENGTH(x,y) UpdateField(DMAC_Y_LENGTH,"Y_LENGTH",x,y)

  const reg_t DMAC_DEST_STRIDE = '{ 'h0420, "DEST_STRIDE" , '{
    "DEST_STRIDE": '{ 23, 0, RW, 0 }}};
  `define SET_DMAC_DEST_STRIDE_DEST_STRIDE(x) SetField(DMAC_DEST_STRIDE,"DEST_STRIDE",x)
  `define GET_DMAC_DEST_STRIDE_DEST_STRIDE(x) GetField(DMAC_DEST_STRIDE,"DEST_STRIDE",x)
  `define DEFAULT_DMAC_DEST_STRIDE_DEST_STRIDE GetResetValue(DMAC_DEST_STRIDE,"DEST_STRIDE")
  `define UPDATE_DMAC_DEST_STRIDE_DEST_STRIDE(x,y) UpdateField(DMAC_DEST_STRIDE,"DEST_STRIDE",x,y)

  const reg_t DMAC_SRC_STRIDE = '{ 'h0424, "SRC_STRIDE" , '{
    "SRC_STRIDE": '{ 23, 0, RW, 0 }}};
  `define SET_DMAC_SRC_STRIDE_SRC_STRIDE(x) SetField(DMAC_SRC_STRIDE,"SRC_STRIDE",x)
  `define GET_DMAC_SRC_STRIDE_SRC_STRIDE(x) GetField(DMAC_SRC_STRIDE,"SRC_STRIDE",x)
  `define DEFAULT_DMAC_SRC_STRIDE_SRC_STRIDE GetResetValue(DMAC_SRC_STRIDE,"SRC_STRIDE")
  `define UPDATE_DMAC_SRC_STRIDE_SRC_STRIDE(x,y) UpdateField(DMAC_SRC_STRIDE,"SRC_STRIDE",x,y)

  const reg_t DMAC_TRANSFER_DONE = '{ 'h0428, "TRANSFER_DONE" , '{
    "TRANSFER_0_DONE": '{ 0, 0, RO, 'h0 },
    "TRANSFER_1_DONE": '{ 1, 1, RO, 'h0 },
    "TRANSFER_2_DONE": '{ 2, 2, RO, 'h0 },
    "TRANSFER_3_DONE": '{ 3, 3, RO, 'h0 },
    "PARTIAL_TRANSFER_DONE": '{ 31, 31, RO, 'h0 }}};
  `define SET_DMAC_TRANSFER_DONE_TRANSFER_0_DONE(x) SetField(DMAC_TRANSFER_DONE,"TRANSFER_0_DONE",x)
  `define GET_DMAC_TRANSFER_DONE_TRANSFER_0_DONE(x) GetField(DMAC_TRANSFER_DONE,"TRANSFER_0_DONE",x)
  `define DEFAULT_DMAC_TRANSFER_DONE_TRANSFER_0_DONE GetResetValue(DMAC_TRANSFER_DONE,"TRANSFER_0_DONE")
  `define UPDATE_DMAC_TRANSFER_DONE_TRANSFER_0_DONE(x,y) UpdateField(DMAC_TRANSFER_DONE,"TRANSFER_0_DONE",x,y)
  `define SET_DMAC_TRANSFER_DONE_TRANSFER_1_DONE(x) SetField(DMAC_TRANSFER_DONE,"TRANSFER_1_DONE",x)
  `define GET_DMAC_TRANSFER_DONE_TRANSFER_1_DONE(x) GetField(DMAC_TRANSFER_DONE,"TRANSFER_1_DONE",x)
  `define DEFAULT_DMAC_TRANSFER_DONE_TRANSFER_1_DONE GetResetValue(DMAC_TRANSFER_DONE,"TRANSFER_1_DONE")
  `define UPDATE_DMAC_TRANSFER_DONE_TRANSFER_1_DONE(x,y) UpdateField(DMAC_TRANSFER_DONE,"TRANSFER_1_DONE",x,y)
  `define SET_DMAC_TRANSFER_DONE_TRANSFER_2_DONE(x) SetField(DMAC_TRANSFER_DONE,"TRANSFER_2_DONE",x)
  `define GET_DMAC_TRANSFER_DONE_TRANSFER_2_DONE(x) GetField(DMAC_TRANSFER_DONE,"TRANSFER_2_DONE",x)
  `define DEFAULT_DMAC_TRANSFER_DONE_TRANSFER_2_DONE GetResetValue(DMAC_TRANSFER_DONE,"TRANSFER_2_DONE")
  `define UPDATE_DMAC_TRANSFER_DONE_TRANSFER_2_DONE(x,y) UpdateField(DMAC_TRANSFER_DONE,"TRANSFER_2_DONE",x,y)
  `define SET_DMAC_TRANSFER_DONE_TRANSFER_3_DONE(x) SetField(DMAC_TRANSFER_DONE,"TRANSFER_3_DONE",x)
  `define GET_DMAC_TRANSFER_DONE_TRANSFER_3_DONE(x) GetField(DMAC_TRANSFER_DONE,"TRANSFER_3_DONE",x)
  `define DEFAULT_DMAC_TRANSFER_DONE_TRANSFER_3_DONE GetResetValue(DMAC_TRANSFER_DONE,"TRANSFER_3_DONE")
  `define UPDATE_DMAC_TRANSFER_DONE_TRANSFER_3_DONE(x,y) UpdateField(DMAC_TRANSFER_DONE,"TRANSFER_3_DONE",x,y)
  `define SET_DMAC_TRANSFER_DONE_PARTIAL_TRANSFER_DONE(x) SetField(DMAC_TRANSFER_DONE,"PARTIAL_TRANSFER_DONE",x)
  `define GET_DMAC_TRANSFER_DONE_PARTIAL_TRANSFER_DONE(x) GetField(DMAC_TRANSFER_DONE,"PARTIAL_TRANSFER_DONE",x)
  `define DEFAULT_DMAC_TRANSFER_DONE_PARTIAL_TRANSFER_DONE GetResetValue(DMAC_TRANSFER_DONE,"PARTIAL_TRANSFER_DONE")
  `define UPDATE_DMAC_TRANSFER_DONE_PARTIAL_TRANSFER_DONE(x,y) UpdateField(DMAC_TRANSFER_DONE,"PARTIAL_TRANSFER_DONE",x,y)

  const reg_t DMAC_ACTIVE_TRANSFER_ID = '{ 'h042c, "ACTIVE_TRANSFER_ID" , '{
    "ACTIVE_TRANSFER_ID": '{ 4, 0, RO, 'h00 }}};
  `define SET_DMAC_ACTIVE_TRANSFER_ID_ACTIVE_TRANSFER_ID(x) SetField(DMAC_ACTIVE_TRANSFER_ID,"ACTIVE_TRANSFER_ID",x)
  `define GET_DMAC_ACTIVE_TRANSFER_ID_ACTIVE_TRANSFER_ID(x) GetField(DMAC_ACTIVE_TRANSFER_ID,"ACTIVE_TRANSFER_ID",x)
  `define DEFAULT_DMAC_ACTIVE_TRANSFER_ID_ACTIVE_TRANSFER_ID GetResetValue(DMAC_ACTIVE_TRANSFER_ID,"ACTIVE_TRANSFER_ID")
  `define UPDATE_DMAC_ACTIVE_TRANSFER_ID_ACTIVE_TRANSFER_ID(x,y) UpdateField(DMAC_ACTIVE_TRANSFER_ID,"ACTIVE_TRANSFER_ID",x,y)

  const reg_t DMAC_STATUS = '{ 'h0430, "STATUS" , '{
    "RESERVED": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_DMAC_STATUS_RESERVED(x) SetField(DMAC_STATUS,"RESERVED",x)
  `define GET_DMAC_STATUS_RESERVED(x) GetField(DMAC_STATUS,"RESERVED",x)
  `define DEFAULT_DMAC_STATUS_RESERVED GetResetValue(DMAC_STATUS,"RESERVED")
  `define UPDATE_DMAC_STATUS_RESERVED(x,y) UpdateField(DMAC_STATUS,"RESERVED",x,y)

  const reg_t DMAC_CURRENT_DEST_ADDRESS = '{ 'h0434, "CURRENT_DEST_ADDRESS" , '{
    "CURRENT_DEST_ADDRESS": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_DMAC_CURRENT_DEST_ADDRESS_CURRENT_DEST_ADDRESS(x) SetField(DMAC_CURRENT_DEST_ADDRESS,"CURRENT_DEST_ADDRESS",x)
  `define GET_DMAC_CURRENT_DEST_ADDRESS_CURRENT_DEST_ADDRESS(x) GetField(DMAC_CURRENT_DEST_ADDRESS,"CURRENT_DEST_ADDRESS",x)
  `define DEFAULT_DMAC_CURRENT_DEST_ADDRESS_CURRENT_DEST_ADDRESS GetResetValue(DMAC_CURRENT_DEST_ADDRESS,"CURRENT_DEST_ADDRESS")
  `define UPDATE_DMAC_CURRENT_DEST_ADDRESS_CURRENT_DEST_ADDRESS(x,y) UpdateField(DMAC_CURRENT_DEST_ADDRESS,"CURRENT_DEST_ADDRESS",x,y)

  const reg_t DMAC_CURRENT_SRC_ADDRESS = '{ 'h0438, "CURRENT_SRC_ADDRESS" , '{
    "CURRENT_SRC_ADDRESS": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_DMAC_CURRENT_SRC_ADDRESS_CURRENT_SRC_ADDRESS(x) SetField(DMAC_CURRENT_SRC_ADDRESS,"CURRENT_SRC_ADDRESS",x)
  `define GET_DMAC_CURRENT_SRC_ADDRESS_CURRENT_SRC_ADDRESS(x) GetField(DMAC_CURRENT_SRC_ADDRESS,"CURRENT_SRC_ADDRESS",x)
  `define DEFAULT_DMAC_CURRENT_SRC_ADDRESS_CURRENT_SRC_ADDRESS GetResetValue(DMAC_CURRENT_SRC_ADDRESS,"CURRENT_SRC_ADDRESS")
  `define UPDATE_DMAC_CURRENT_SRC_ADDRESS_CURRENT_SRC_ADDRESS(x,y) UpdateField(DMAC_CURRENT_SRC_ADDRESS,"CURRENT_SRC_ADDRESS",x,y)

  const reg_t DMAC_TRANSFER_PROGRESS = '{ 'h0448, "TRANSFER_PROGRESS" , '{
    "TRANSFER_PROGRESS": '{ 23, 0, RO, 'h000000 }}};
  `define SET_DMAC_TRANSFER_PROGRESS_TRANSFER_PROGRESS(x) SetField(DMAC_TRANSFER_PROGRESS,"TRANSFER_PROGRESS",x)
  `define GET_DMAC_TRANSFER_PROGRESS_TRANSFER_PROGRESS(x) GetField(DMAC_TRANSFER_PROGRESS,"TRANSFER_PROGRESS",x)
  `define DEFAULT_DMAC_TRANSFER_PROGRESS_TRANSFER_PROGRESS GetResetValue(DMAC_TRANSFER_PROGRESS,"TRANSFER_PROGRESS")
  `define UPDATE_DMAC_TRANSFER_PROGRESS_TRANSFER_PROGRESS(x,y) UpdateField(DMAC_TRANSFER_PROGRESS,"TRANSFER_PROGRESS",x,y)

  const reg_t DMAC_PARTIAL_TRANSFER_LENGTH = '{ 'h044c, "PARTIAL_TRANSFER_LENGTH" , '{
    "PARTIAL_LENGTH": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_DMAC_PARTIAL_TRANSFER_LENGTH_PARTIAL_LENGTH(x) SetField(DMAC_PARTIAL_TRANSFER_LENGTH,"PARTIAL_LENGTH",x)
  `define GET_DMAC_PARTIAL_TRANSFER_LENGTH_PARTIAL_LENGTH(x) GetField(DMAC_PARTIAL_TRANSFER_LENGTH,"PARTIAL_LENGTH",x)
  `define DEFAULT_DMAC_PARTIAL_TRANSFER_LENGTH_PARTIAL_LENGTH GetResetValue(DMAC_PARTIAL_TRANSFER_LENGTH,"PARTIAL_LENGTH")
  `define UPDATE_DMAC_PARTIAL_TRANSFER_LENGTH_PARTIAL_LENGTH(x,y) UpdateField(DMAC_PARTIAL_TRANSFER_LENGTH,"PARTIAL_LENGTH",x,y)

  const reg_t DMAC_PARTIAL_TRANSFER_ID = '{ 'h0450, "PARTIAL_TRANSFER_ID" , '{
    "PARTIAL_TRANSFER_ID": '{ 1, 0, RO, 'h0 }}};
  `define SET_DMAC_PARTIAL_TRANSFER_ID_PARTIAL_TRANSFER_ID(x) SetField(DMAC_PARTIAL_TRANSFER_ID,"PARTIAL_TRANSFER_ID",x)
  `define GET_DMAC_PARTIAL_TRANSFER_ID_PARTIAL_TRANSFER_ID(x) GetField(DMAC_PARTIAL_TRANSFER_ID,"PARTIAL_TRANSFER_ID",x)
  `define DEFAULT_DMAC_PARTIAL_TRANSFER_ID_PARTIAL_TRANSFER_ID GetResetValue(DMAC_PARTIAL_TRANSFER_ID,"PARTIAL_TRANSFER_ID")
  `define UPDATE_DMAC_PARTIAL_TRANSFER_ID_PARTIAL_TRANSFER_ID(x,y) UpdateField(DMAC_PARTIAL_TRANSFER_ID,"PARTIAL_TRANSFER_ID",x,y)

  const reg_t DMAC_DESCRIPTOR_ID = '{ 'h0454, "DESCRIPTOR_ID" , '{
    "DESCRIPTOR_ID": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_DMAC_DESCRIPTOR_ID_DESCRIPTOR_ID(x) SetField(DMAC_DESCRIPTOR_ID,"DESCRIPTOR_ID",x)
  `define GET_DMAC_DESCRIPTOR_ID_DESCRIPTOR_ID(x) GetField(DMAC_DESCRIPTOR_ID,"DESCRIPTOR_ID",x)
  `define DEFAULT_DMAC_DESCRIPTOR_ID_DESCRIPTOR_ID GetResetValue(DMAC_DESCRIPTOR_ID,"DESCRIPTOR_ID")
  `define UPDATE_DMAC_DESCRIPTOR_ID_DESCRIPTOR_ID(x,y) UpdateField(DMAC_DESCRIPTOR_ID,"DESCRIPTOR_ID",x,y)

  const reg_t DMAC_FRAMELOCK_CONFIG = '{ 'h0458, "FRAMELOCK_CONFIG" , '{
    "DISTANCE": '{ 23, 16, RW, 0 },
    "FRAMENUM": '{ 15, 8, RW, 0 },
    "WAIT_WRITER": '{ 1, 1, RW, 0 },
    "MODE": '{ 0, 0, RW, 0 }}};
  `define SET_DMAC_FRAMELOCK_CONFIG_DISTANCE(x) SetField(DMAC_FRAMELOCK_CONFIG,"DISTANCE",x)
  `define GET_DMAC_FRAMELOCK_CONFIG_DISTANCE(x) GetField(DMAC_FRAMELOCK_CONFIG,"DISTANCE",x)
  `define DEFAULT_DMAC_FRAMELOCK_CONFIG_DISTANCE GetResetValue(DMAC_FRAMELOCK_CONFIG,"DISTANCE")
  `define UPDATE_DMAC_FRAMELOCK_CONFIG_DISTANCE(x,y) UpdateField(DMAC_FRAMELOCK_CONFIG,"DISTANCE",x,y)
  `define SET_DMAC_FRAMELOCK_CONFIG_FRAMENUM(x) SetField(DMAC_FRAMELOCK_CONFIG,"FRAMENUM",x)
  `define GET_DMAC_FRAMELOCK_CONFIG_FRAMENUM(x) GetField(DMAC_FRAMELOCK_CONFIG,"FRAMENUM",x)
  `define DEFAULT_DMAC_FRAMELOCK_CONFIG_FRAMENUM GetResetValue(DMAC_FRAMELOCK_CONFIG,"FRAMENUM")
  `define UPDATE_DMAC_FRAMELOCK_CONFIG_FRAMENUM(x,y) UpdateField(DMAC_FRAMELOCK_CONFIG,"FRAMENUM",x,y)
  `define SET_DMAC_FRAMELOCK_CONFIG_WAIT_WRITER(x) SetField(DMAC_FRAMELOCK_CONFIG,"WAIT_WRITER",x)
  `define GET_DMAC_FRAMELOCK_CONFIG_WAIT_WRITER(x) GetField(DMAC_FRAMELOCK_CONFIG,"WAIT_WRITER",x)
  `define DEFAULT_DMAC_FRAMELOCK_CONFIG_WAIT_WRITER GetResetValue(DMAC_FRAMELOCK_CONFIG,"WAIT_WRITER")
  `define UPDATE_DMAC_FRAMELOCK_CONFIG_WAIT_WRITER(x,y) UpdateField(DMAC_FRAMELOCK_CONFIG,"WAIT_WRITER",x,y)
  `define SET_DMAC_FRAMELOCK_CONFIG_MODE(x) SetField(DMAC_FRAMELOCK_CONFIG,"MODE",x)
  `define GET_DMAC_FRAMELOCK_CONFIG_MODE(x) GetField(DMAC_FRAMELOCK_CONFIG,"MODE",x)
  `define DEFAULT_DMAC_FRAMELOCK_CONFIG_MODE GetResetValue(DMAC_FRAMELOCK_CONFIG,"MODE")
  `define UPDATE_DMAC_FRAMELOCK_CONFIG_MODE(x,y) UpdateField(DMAC_FRAMELOCK_CONFIG,"MODE",x,y)

  const reg_t DMAC_FRAMELOCK_STRIDE = '{ 'h045c, "FRAMELOCK_STRIDE" , '{
    "STRIDE": '{ 31, 0, RW, 0 }}};
  `define SET_DMAC_FRAMELOCK_STRIDE_STRIDE(x) SetField(DMAC_FRAMELOCK_STRIDE,"STRIDE",x)
  `define GET_DMAC_FRAMELOCK_STRIDE_STRIDE(x) GetField(DMAC_FRAMELOCK_STRIDE,"STRIDE",x)
  `define DEFAULT_DMAC_FRAMELOCK_STRIDE_STRIDE GetResetValue(DMAC_FRAMELOCK_STRIDE,"STRIDE")
  `define UPDATE_DMAC_FRAMELOCK_STRIDE_STRIDE(x,y) UpdateField(DMAC_FRAMELOCK_STRIDE,"STRIDE",x,y)

  const reg_t DMAC_SG_ADDRESS = '{ 'h047c, "SG_ADDRESS" , '{
    "SG_ADDRESS": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_DMAC_SG_ADDRESS_SG_ADDRESS(x) SetField(DMAC_SG_ADDRESS,"SG_ADDRESS",x)
  `define GET_DMAC_SG_ADDRESS_SG_ADDRESS(x) GetField(DMAC_SG_ADDRESS,"SG_ADDRESS",x)
  `define DEFAULT_DMAC_SG_ADDRESS_SG_ADDRESS GetResetValue(DMAC_SG_ADDRESS,"SG_ADDRESS")
  `define UPDATE_DMAC_SG_ADDRESS_SG_ADDRESS(x,y) UpdateField(DMAC_SG_ADDRESS,"SG_ADDRESS",x,y)

  const reg_t DMAC_DEST_ADDRESS_HIGH = '{ 'h0490, "DEST_ADDRESS_HIGH" , '{
    "DEST_ADDRESS_HIGH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_DMAC_DEST_ADDRESS_HIGH_DEST_ADDRESS_HIGH(x) SetField(DMAC_DEST_ADDRESS_HIGH,"DEST_ADDRESS_HIGH",x)
  `define GET_DMAC_DEST_ADDRESS_HIGH_DEST_ADDRESS_HIGH(x) GetField(DMAC_DEST_ADDRESS_HIGH,"DEST_ADDRESS_HIGH",x)
  `define DEFAULT_DMAC_DEST_ADDRESS_HIGH_DEST_ADDRESS_HIGH GetResetValue(DMAC_DEST_ADDRESS_HIGH,"DEST_ADDRESS_HIGH")
  `define UPDATE_DMAC_DEST_ADDRESS_HIGH_DEST_ADDRESS_HIGH(x,y) UpdateField(DMAC_DEST_ADDRESS_HIGH,"DEST_ADDRESS_HIGH",x,y)

  const reg_t DMAC_SRC_ADDRESS_HIGH = '{ 'h0494, "SRC_ADDRESS_HIGH" , '{
    "SRC_ADDRESS_HIGH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_DMAC_SRC_ADDRESS_HIGH_SRC_ADDRESS_HIGH(x) SetField(DMAC_SRC_ADDRESS_HIGH,"SRC_ADDRESS_HIGH",x)
  `define GET_DMAC_SRC_ADDRESS_HIGH_SRC_ADDRESS_HIGH(x) GetField(DMAC_SRC_ADDRESS_HIGH,"SRC_ADDRESS_HIGH",x)
  `define DEFAULT_DMAC_SRC_ADDRESS_HIGH_SRC_ADDRESS_HIGH GetResetValue(DMAC_SRC_ADDRESS_HIGH,"SRC_ADDRESS_HIGH")
  `define UPDATE_DMAC_SRC_ADDRESS_HIGH_SRC_ADDRESS_HIGH(x,y) UpdateField(DMAC_SRC_ADDRESS_HIGH,"SRC_ADDRESS_HIGH",x,y)

  const reg_t DMAC_CURRENT_DEST_ADDRESS_HIGH = '{ 'h0498, "CURRENT_DEST_ADDRESS_HIGH" , '{
    "CURRENT_DEST_ADDRESS_HIGH": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_DMAC_CURRENT_DEST_ADDRESS_HIGH_CURRENT_DEST_ADDRESS_HIGH(x) SetField(DMAC_CURRENT_DEST_ADDRESS_HIGH,"CURRENT_DEST_ADDRESS_HIGH",x)
  `define GET_DMAC_CURRENT_DEST_ADDRESS_HIGH_CURRENT_DEST_ADDRESS_HIGH(x) GetField(DMAC_CURRENT_DEST_ADDRESS_HIGH,"CURRENT_DEST_ADDRESS_HIGH",x)
  `define DEFAULT_DMAC_CURRENT_DEST_ADDRESS_HIGH_CURRENT_DEST_ADDRESS_HIGH GetResetValue(DMAC_CURRENT_DEST_ADDRESS_HIGH,"CURRENT_DEST_ADDRESS_HIGH")
  `define UPDATE_DMAC_CURRENT_DEST_ADDRESS_HIGH_CURRENT_DEST_ADDRESS_HIGH(x,y) UpdateField(DMAC_CURRENT_DEST_ADDRESS_HIGH,"CURRENT_DEST_ADDRESS_HIGH",x,y)

  const reg_t DMAC_CURRENT_SRC_ADDRESS_HIGH = '{ 'h049c, "CURRENT_SRC_ADDRESS_HIGH" , '{
    "CURRENT_SRC_ADDRESS_HIGH": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_DMAC_CURRENT_SRC_ADDRESS_HIGH_CURRENT_SRC_ADDRESS_HIGH(x) SetField(DMAC_CURRENT_SRC_ADDRESS_HIGH,"CURRENT_SRC_ADDRESS_HIGH",x)
  `define GET_DMAC_CURRENT_SRC_ADDRESS_HIGH_CURRENT_SRC_ADDRESS_HIGH(x) GetField(DMAC_CURRENT_SRC_ADDRESS_HIGH,"CURRENT_SRC_ADDRESS_HIGH",x)
  `define DEFAULT_DMAC_CURRENT_SRC_ADDRESS_HIGH_CURRENT_SRC_ADDRESS_HIGH GetResetValue(DMAC_CURRENT_SRC_ADDRESS_HIGH,"CURRENT_SRC_ADDRESS_HIGH")
  `define UPDATE_DMAC_CURRENT_SRC_ADDRESS_HIGH_CURRENT_SRC_ADDRESS_HIGH(x,y) UpdateField(DMAC_CURRENT_SRC_ADDRESS_HIGH,"CURRENT_SRC_ADDRESS_HIGH",x,y)

  const reg_t DMAC_SG_ADDRESS_HIGH = '{ 'h04bc, "SG_ADDRESS_HIGH" , '{
    "SG_ADDRESS_HIGH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_DMAC_SG_ADDRESS_HIGH_SG_ADDRESS_HIGH(x) SetField(DMAC_SG_ADDRESS_HIGH,"SG_ADDRESS_HIGH",x)
  `define GET_DMAC_SG_ADDRESS_HIGH_SG_ADDRESS_HIGH(x) GetField(DMAC_SG_ADDRESS_HIGH,"SG_ADDRESS_HIGH",x)
  `define DEFAULT_DMAC_SG_ADDRESS_HIGH_SG_ADDRESS_HIGH GetResetValue(DMAC_SG_ADDRESS_HIGH,"SG_ADDRESS_HIGH")
  `define UPDATE_DMAC_SG_ADDRESS_HIGH_SG_ADDRESS_HIGH(x,y) UpdateField(DMAC_SG_ADDRESS_HIGH,"SG_ADDRESS_HIGH",x,y)


endpackage
