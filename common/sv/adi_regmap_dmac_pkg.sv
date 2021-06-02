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

package adi_regmap_dmac_pkg;
  import adi_regmap_pkg::*;


/* DMA Controller (axi_dmac) */

  const reg_t dmac_VERSION = '{ 'h0000, "VERSION" , '{
    "VERSION_MAJOR": '{ 31, 16, RO, 'h04 },
    "VERSION_MINOR": '{ 15, 8, RO, 'h03 },
    "VERSION_PATCH": '{ 7, 0, RO, 'h61 }}};
  `define SET_dmac_VERSION_VERSION_MAJOR(x) SetField(dmac_VERSION,"VERSION_MAJOR",x)
  `define GET_dmac_VERSION_VERSION_MAJOR(x) GetField(dmac_VERSION,"VERSION_MAJOR",x)
  `define SET_dmac_VERSION_VERSION_MINOR(x) SetField(dmac_VERSION,"VERSION_MINOR",x)
  `define GET_dmac_VERSION_VERSION_MINOR(x) GetField(dmac_VERSION,"VERSION_MINOR",x)
  `define SET_dmac_VERSION_VERSION_PATCH(x) SetField(dmac_VERSION,"VERSION_PATCH",x)
  `define GET_dmac_VERSION_VERSION_PATCH(x) GetField(dmac_VERSION,"VERSION_PATCH",x)

  const reg_t dmac_PERIPHERAL_ID = '{ 'h0004, "PERIPHERAL_ID" , '{
    "PERIPHERAL_ID": '{ 31, 0, RO, 0 }}};
  `define SET_dmac_PERIPHERAL_ID_PERIPHERAL_ID(x) SetField(dmac_PERIPHERAL_ID,"PERIPHERAL_ID",x)
  `define GET_dmac_PERIPHERAL_ID_PERIPHERAL_ID(x) GetField(dmac_PERIPHERAL_ID,"PERIPHERAL_ID",x)

  const reg_t dmac_SCRATCH = '{ 'h0008, "SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_dmac_SCRATCH_SCRATCH(x) SetField(dmac_SCRATCH,"SCRATCH",x)
  `define GET_dmac_SCRATCH_SCRATCH(x) GetField(dmac_SCRATCH,"SCRATCH",x)

  const reg_t dmac_IDENTIFICATION = '{ 'h000c, "IDENTIFICATION" , '{
    "IDENTIFICATION": '{ 31, 0, RO, 'h444D4143 }}};
  `define SET_dmac_IDENTIFICATION_IDENTIFICATION(x) SetField(dmac_IDENTIFICATION,"IDENTIFICATION",x)
  `define GET_dmac_IDENTIFICATION_IDENTIFICATION(x) GetField(dmac_IDENTIFICATION,"IDENTIFICATION",x)

  const reg_t dmac_INTERFACE_DESCRIPTION = '{ 'h0010, "INTERFACE_DESCRIPTION" , '{
    "BYTES_PER_BEAT_DEST_LOG2": '{ 3, 0, R, 0 },
    "DMA_TYPE_DEST": '{ 5, 4, R, 0 },
    "BYTES_PER_BEAT_SRC_LOG2": '{ 11, 8, R, 0 },
    "DMA_TYPE_SRC": '{ 13, 12, R, 0 }}};
  `define SET_dmac_INTERFACE_DESCRIPTION_BYTES_PER_BEAT_DEST_LOG2(x) SetField(dmac_INTERFACE_DESCRIPTION,"BYTES_PER_BEAT_DEST_LOG2",x)
  `define GET_dmac_INTERFACE_DESCRIPTION_BYTES_PER_BEAT_DEST_LOG2(x) GetField(dmac_INTERFACE_DESCRIPTION,"BYTES_PER_BEAT_DEST_LOG2",x)
  `define SET_dmac_INTERFACE_DESCRIPTION_DMA_TYPE_DEST(x) SetField(dmac_INTERFACE_DESCRIPTION,"DMA_TYPE_DEST",x)
  `define GET_dmac_INTERFACE_DESCRIPTION_DMA_TYPE_DEST(x) GetField(dmac_INTERFACE_DESCRIPTION,"DMA_TYPE_DEST",x)
  `define SET_dmac_INTERFACE_DESCRIPTION_BYTES_PER_BEAT_SRC_LOG2(x) SetField(dmac_INTERFACE_DESCRIPTION,"BYTES_PER_BEAT_SRC_LOG2",x)
  `define GET_dmac_INTERFACE_DESCRIPTION_BYTES_PER_BEAT_SRC_LOG2(x) GetField(dmac_INTERFACE_DESCRIPTION,"BYTES_PER_BEAT_SRC_LOG2",x)
  `define SET_dmac_INTERFACE_DESCRIPTION_DMA_TYPE_SRC(x) SetField(dmac_INTERFACE_DESCRIPTION,"DMA_TYPE_SRC",x)
  `define GET_dmac_INTERFACE_DESCRIPTION_DMA_TYPE_SRC(x) GetField(dmac_INTERFACE_DESCRIPTION,"DMA_TYPE_SRC",x)

  const reg_t dmac_IRQ_MASK = '{ 'h0080, "IRQ_MASK" , '{
    "TRANSFER_COMPLETED": '{ 1, 1, RW, 'h1 },
    "TRANSFER_QUEUED": '{ 0, 0, RW, 'h1 }}};
  `define SET_dmac_IRQ_MASK_TRANSFER_COMPLETED(x) SetField(dmac_IRQ_MASK,"TRANSFER_COMPLETED",x)
  `define GET_dmac_IRQ_MASK_TRANSFER_COMPLETED(x) GetField(dmac_IRQ_MASK,"TRANSFER_COMPLETED",x)
  `define SET_dmac_IRQ_MASK_TRANSFER_QUEUED(x) SetField(dmac_IRQ_MASK,"TRANSFER_QUEUED",x)
  `define GET_dmac_IRQ_MASK_TRANSFER_QUEUED(x) GetField(dmac_IRQ_MASK,"TRANSFER_QUEUED",x)

  const reg_t dmac_IRQ_PENDING = '{ 'h0084, "IRQ_PENDING" , '{
    "TRANSFER_COMPLETED": '{ 1, 1, RW1C, 'h0 },
    "TRANSFER_QUEUED": '{ 0, 0, RW1C, 'h0 }}};
  `define SET_dmac_IRQ_PENDING_TRANSFER_COMPLETED(x) SetField(dmac_IRQ_PENDING,"TRANSFER_COMPLETED",x)
  `define GET_dmac_IRQ_PENDING_TRANSFER_COMPLETED(x) GetField(dmac_IRQ_PENDING,"TRANSFER_COMPLETED",x)
  `define SET_dmac_IRQ_PENDING_TRANSFER_QUEUED(x) SetField(dmac_IRQ_PENDING,"TRANSFER_QUEUED",x)
  `define GET_dmac_IRQ_PENDING_TRANSFER_QUEUED(x) GetField(dmac_IRQ_PENDING,"TRANSFER_QUEUED",x)

  const reg_t dmac_IRQ_SOURCE = '{ 'h0088, "IRQ_SOURCE" , '{
    "TRANSFER_COMPLETED": '{ 1, 1, RO, 'h0 },
    "TRANSFER_QUEUED": '{ 0, 0, RO, 'h0 }}};
  `define SET_dmac_IRQ_SOURCE_TRANSFER_COMPLETED(x) SetField(dmac_IRQ_SOURCE,"TRANSFER_COMPLETED",x)
  `define GET_dmac_IRQ_SOURCE_TRANSFER_COMPLETED(x) GetField(dmac_IRQ_SOURCE,"TRANSFER_COMPLETED",x)
  `define SET_dmac_IRQ_SOURCE_TRANSFER_QUEUED(x) SetField(dmac_IRQ_SOURCE,"TRANSFER_QUEUED",x)
  `define GET_dmac_IRQ_SOURCE_TRANSFER_QUEUED(x) GetField(dmac_IRQ_SOURCE,"TRANSFER_QUEUED",x)

  const reg_t dmac_CONTROL = '{ 'h0400, "CONTROL" , '{
    "PAUSE": '{ 1, 1, RW, 'h0 },
    "ENABLE": '{ 0, 0, RW, 'h0 }}};
  `define SET_dmac_CONTROL_PAUSE(x) SetField(dmac_CONTROL,"PAUSE",x)
  `define GET_dmac_CONTROL_PAUSE(x) GetField(dmac_CONTROL,"PAUSE",x)
  `define SET_dmac_CONTROL_ENABLE(x) SetField(dmac_CONTROL,"ENABLE",x)
  `define GET_dmac_CONTROL_ENABLE(x) GetField(dmac_CONTROL,"ENABLE",x)

  const reg_t dmac_TRANSFER_ID = '{ 'h0404, "TRANSFER_ID" , '{
    "TRANSFER_ID": '{ 1, 0, RO, 'h00 }}};
  `define SET_dmac_TRANSFER_ID_TRANSFER_ID(x) SetField(dmac_TRANSFER_ID,"TRANSFER_ID",x)
  `define GET_dmac_TRANSFER_ID_TRANSFER_ID(x) GetField(dmac_TRANSFER_ID,"TRANSFER_ID",x)

  const reg_t dmac_TRANSFER_SUBMIT = '{ 'h0408, "TRANSFER_SUBMIT" , '{
    "TRANSFER_SUBMIT": '{ 0, 0, RW, 'h00 }}};
  `define SET_dmac_TRANSFER_SUBMIT_TRANSFER_SUBMIT(x) SetField(dmac_TRANSFER_SUBMIT,"TRANSFER_SUBMIT",x)
  `define GET_dmac_TRANSFER_SUBMIT_TRANSFER_SUBMIT(x) GetField(dmac_TRANSFER_SUBMIT,"TRANSFER_SUBMIT",x)

  const reg_t dmac_FLAGS = '{ 'h040c, "FLAGS" , '{
    "CYCLIC": '{ 0, 0, RW, 0 },
    "TLAST": '{ 1, 1, RW, 'h1 },
    "PARTIAL_REPORTING_EN": '{ 2, 2, RW, 'h0 }}};
  `define SET_dmac_FLAGS_CYCLIC(x) SetField(dmac_FLAGS,"CYCLIC",x)
  `define GET_dmac_FLAGS_CYCLIC(x) GetField(dmac_FLAGS,"CYCLIC",x)
  `define SET_dmac_FLAGS_TLAST(x) SetField(dmac_FLAGS,"TLAST",x)
  `define GET_dmac_FLAGS_TLAST(x) GetField(dmac_FLAGS,"TLAST",x)
  `define SET_dmac_FLAGS_PARTIAL_REPORTING_EN(x) SetField(dmac_FLAGS,"PARTIAL_REPORTING_EN",x)
  `define GET_dmac_FLAGS_PARTIAL_REPORTING_EN(x) GetField(dmac_FLAGS,"PARTIAL_REPORTING_EN",x)

  const reg_t dmac_DEST_ADDRESS = '{ 'h0410, "DEST_ADDRESS" , '{
    "DEST_ADDRESS": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_dmac_DEST_ADDRESS_DEST_ADDRESS(x) SetField(dmac_DEST_ADDRESS,"DEST_ADDRESS",x)
  `define GET_dmac_DEST_ADDRESS_DEST_ADDRESS(x) GetField(dmac_DEST_ADDRESS,"DEST_ADDRESS",x)

  const reg_t dmac_SRC_ADDRESS = '{ 'h0414, "SRC_ADDRESS" , '{
    "SRC_ADDRESS": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_dmac_SRC_ADDRESS_SRC_ADDRESS(x) SetField(dmac_SRC_ADDRESS,"SRC_ADDRESS",x)
  `define GET_dmac_SRC_ADDRESS_SRC_ADDRESS(x) GetField(dmac_SRC_ADDRESS,"SRC_ADDRESS",x)

  const reg_t dmac_X_LENGTH = '{ 'h0418, "X_LENGTH" , '{
    "X_LENGTH": '{ 23, 0, RW, 0 }}};
  `define SET_dmac_X_LENGTH_X_LENGTH(x) SetField(dmac_X_LENGTH,"X_LENGTH",x)
  `define GET_dmac_X_LENGTH_X_LENGTH(x) GetField(dmac_X_LENGTH,"X_LENGTH",x)

  const reg_t dmac_Y_LENGTH = '{ 'h041c, "Y_LENGTH" , '{
    "Y_LENGTH": '{ 23, 0, RW, 'h000000 }}};
  `define SET_dmac_Y_LENGTH_Y_LENGTH(x) SetField(dmac_Y_LENGTH,"Y_LENGTH",x)
  `define GET_dmac_Y_LENGTH_Y_LENGTH(x) GetField(dmac_Y_LENGTH,"Y_LENGTH",x)

  const reg_t dmac_DEST_STRIDE = '{ 'h0420, "DEST_STRIDE" , '{
    "DEST_STRIDE": '{ 23, 0, RW, 'h000000 }}};
  `define SET_dmac_DEST_STRIDE_DEST_STRIDE(x) SetField(dmac_DEST_STRIDE,"DEST_STRIDE",x)
  `define GET_dmac_DEST_STRIDE_DEST_STRIDE(x) GetField(dmac_DEST_STRIDE,"DEST_STRIDE",x)

  const reg_t dmac_SRC_STRIDE = '{ 'h0424, "SRC_STRIDE" , '{
    "SRC_STRIDE": '{ 23, 0, RW, 'h000000 }}};
  `define SET_dmac_SRC_STRIDE_SRC_STRIDE(x) SetField(dmac_SRC_STRIDE,"SRC_STRIDE",x)
  `define GET_dmac_SRC_STRIDE_SRC_STRIDE(x) GetField(dmac_SRC_STRIDE,"SRC_STRIDE",x)

  const reg_t dmac_TRANSFER_DONE = '{ 'h0428, "TRANSFER_DONE" , '{
    "TRANSFER_0_DONE": '{ 0, 0, RO, 'h0 },
    "TRANSFER_1_DONE": '{ 1, 1, RO, 'h0 },
    "TRANSFER_2_DONE": '{ 2, 2, RO, 'h0 },
    "TRANSFER_3_DONE": '{ 3, 3, RO, 'h0 },
    "PARTIAL_TRANSFER_DONE": '{ 31, 31, RO, 'h0 }}};
  `define SET_dmac_TRANSFER_DONE_TRANSFER_0_DONE(x) SetField(dmac_TRANSFER_DONE,"TRANSFER_0_DONE",x)
  `define GET_dmac_TRANSFER_DONE_TRANSFER_0_DONE(x) GetField(dmac_TRANSFER_DONE,"TRANSFER_0_DONE",x)
  `define SET_dmac_TRANSFER_DONE_TRANSFER_1_DONE(x) SetField(dmac_TRANSFER_DONE,"TRANSFER_1_DONE",x)
  `define GET_dmac_TRANSFER_DONE_TRANSFER_1_DONE(x) GetField(dmac_TRANSFER_DONE,"TRANSFER_1_DONE",x)
  `define SET_dmac_TRANSFER_DONE_TRANSFER_2_DONE(x) SetField(dmac_TRANSFER_DONE,"TRANSFER_2_DONE",x)
  `define GET_dmac_TRANSFER_DONE_TRANSFER_2_DONE(x) GetField(dmac_TRANSFER_DONE,"TRANSFER_2_DONE",x)
  `define SET_dmac_TRANSFER_DONE_TRANSFER_3_DONE(x) SetField(dmac_TRANSFER_DONE,"TRANSFER_3_DONE",x)
  `define GET_dmac_TRANSFER_DONE_TRANSFER_3_DONE(x) GetField(dmac_TRANSFER_DONE,"TRANSFER_3_DONE",x)
  `define SET_dmac_TRANSFER_DONE_PARTIAL_TRANSFER_DONE(x) SetField(dmac_TRANSFER_DONE,"PARTIAL_TRANSFER_DONE",x)
  `define GET_dmac_TRANSFER_DONE_PARTIAL_TRANSFER_DONE(x) GetField(dmac_TRANSFER_DONE,"PARTIAL_TRANSFER_DONE",x)

  const reg_t dmac_ACTIVE_TRANSFER_ID = '{ 'h042c, "ACTIVE_TRANSFER_ID" , '{
    "ACTIVE_TRANSFER_ID": '{ 4, 0, RO, 'h00 }}};
  `define SET_dmac_ACTIVE_TRANSFER_ID_ACTIVE_TRANSFER_ID(x) SetField(dmac_ACTIVE_TRANSFER_ID,"ACTIVE_TRANSFER_ID",x)
  `define GET_dmac_ACTIVE_TRANSFER_ID_ACTIVE_TRANSFER_ID(x) GetField(dmac_ACTIVE_TRANSFER_ID,"ACTIVE_TRANSFER_ID",x)

  const reg_t dmac_STATUS = '{ 'h0430, "STATUS" , '{
    "RESERVED": '{ 31, 0, RO, 'h00 }}};
  `define SET_dmac_STATUS_RESERVED(x) SetField(dmac_STATUS,"RESERVED",x)
  `define GET_dmac_STATUS_RESERVED(x) GetField(dmac_STATUS,"RESERVED",x)

  const reg_t dmac_CURRENT_DEST_ADDRESS = '{ 'h0434, "CURRENT_DEST_ADDRESS" , '{
    "CURRENT_DEST_ADDRESS": '{ 31, 0, RO, 'h00 }}};
  `define SET_dmac_CURRENT_DEST_ADDRESS_CURRENT_DEST_ADDRESS(x) SetField(dmac_CURRENT_DEST_ADDRESS,"CURRENT_DEST_ADDRESS",x)
  `define GET_dmac_CURRENT_DEST_ADDRESS_CURRENT_DEST_ADDRESS(x) GetField(dmac_CURRENT_DEST_ADDRESS,"CURRENT_DEST_ADDRESS",x)

  const reg_t dmac_CURRENT_SRC_ADDRESS = '{ 'h0438, "CURRENT_SRC_ADDRESS" , '{
    "CURRENT_SRC_ADDRESS": '{ 31, 0, RO, 'h00 }}};
  `define SET_dmac_CURRENT_SRC_ADDRESS_CURRENT_SRC_ADDRESS(x) SetField(dmac_CURRENT_SRC_ADDRESS,"CURRENT_SRC_ADDRESS",x)
  `define GET_dmac_CURRENT_SRC_ADDRESS_CURRENT_SRC_ADDRESS(x) GetField(dmac_CURRENT_SRC_ADDRESS,"CURRENT_SRC_ADDRESS",x)

  const reg_t dmac_TRANSFER_PROGRESS = '{ 'h0448, "TRANSFER_PROGRESS" , '{
    "TRANSFER_PROGRESS": '{ 23, 0, RO, 'h000000 }}};
  `define SET_dmac_TRANSFER_PROGRESS_TRANSFER_PROGRESS(x) SetField(dmac_TRANSFER_PROGRESS,"TRANSFER_PROGRESS",x)
  `define GET_dmac_TRANSFER_PROGRESS_TRANSFER_PROGRESS(x) GetField(dmac_TRANSFER_PROGRESS,"TRANSFER_PROGRESS",x)

  const reg_t dmac_PARTIAL_TRANSFER_LENGTH = '{ 'h044c, "PARTIAL_TRANSFER_LENGTH" , '{
    "PARTIAL_LENGTH": '{ 31, 0, RO, 'h000000 }}};
  `define SET_dmac_PARTIAL_TRANSFER_LENGTH_PARTIAL_LENGTH(x) SetField(dmac_PARTIAL_TRANSFER_LENGTH,"PARTIAL_LENGTH",x)
  `define GET_dmac_PARTIAL_TRANSFER_LENGTH_PARTIAL_LENGTH(x) GetField(dmac_PARTIAL_TRANSFER_LENGTH,"PARTIAL_LENGTH",x)

  const reg_t dmac_PARTIAL_TRANSFER_ID = '{ 'h0450, "PARTIAL_TRANSFER_ID" , '{
    "PARTIAL_TRANSFER_ID": '{ 1, 0, RO, 'h0 }}};
  `define SET_dmac_PARTIAL_TRANSFER_ID_PARTIAL_TRANSFER_ID(x) SetField(dmac_PARTIAL_TRANSFER_ID,"PARTIAL_TRANSFER_ID",x)
  `define GET_dmac_PARTIAL_TRANSFER_ID_PARTIAL_TRANSFER_ID(x) GetField(dmac_PARTIAL_TRANSFER_ID,"PARTIAL_TRANSFER_ID",x)


endpackage
