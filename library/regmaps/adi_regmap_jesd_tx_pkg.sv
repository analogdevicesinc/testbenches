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
/* Thu Mar 28 13:22:23 2024 */

package adi_regmap_jesd_tx_pkg;
  import adi_regmap_pkg::*;


/* JESD204 TX (axi_jesd204_tx) */

  const reg_t JESD_TX_VERSION = '{ 'h0000, "VERSION" , '{
    "VERSION_MAJOR": '{ 31, 16, RO, 'h0001 },
    "VERSION_MINOR": '{ 15, 8, RO, 'h03 },
    "VERSION_PATCH": '{ 7, 0, RO, 'h61 }}};
  `define SET_JESD_TX_VERSION_VERSION_MAJOR(x) SetField(JESD_TX_VERSION,"VERSION_MAJOR",x)
  `define GET_JESD_TX_VERSION_VERSION_MAJOR(x) GetField(JESD_TX_VERSION,"VERSION_MAJOR",x)
  `define DEFAULT_JESD_TX_VERSION_VERSION_MAJOR GetResetValue(JESD_TX_VERSION,"VERSION_MAJOR")
  `define UPDATE_JESD_TX_VERSION_VERSION_MAJOR(x,y) UpdateField(JESD_TX_VERSION,"VERSION_MAJOR",x,y)
  `define SET_JESD_TX_VERSION_VERSION_MINOR(x) SetField(JESD_TX_VERSION,"VERSION_MINOR",x)
  `define GET_JESD_TX_VERSION_VERSION_MINOR(x) GetField(JESD_TX_VERSION,"VERSION_MINOR",x)
  `define DEFAULT_JESD_TX_VERSION_VERSION_MINOR GetResetValue(JESD_TX_VERSION,"VERSION_MINOR")
  `define UPDATE_JESD_TX_VERSION_VERSION_MINOR(x,y) UpdateField(JESD_TX_VERSION,"VERSION_MINOR",x,y)
  `define SET_JESD_TX_VERSION_VERSION_PATCH(x) SetField(JESD_TX_VERSION,"VERSION_PATCH",x)
  `define GET_JESD_TX_VERSION_VERSION_PATCH(x) GetField(JESD_TX_VERSION,"VERSION_PATCH",x)
  `define DEFAULT_JESD_TX_VERSION_VERSION_PATCH GetResetValue(JESD_TX_VERSION,"VERSION_PATCH")
  `define UPDATE_JESD_TX_VERSION_VERSION_PATCH(x,y) UpdateField(JESD_TX_VERSION,"VERSION_PATCH",x,y)

  const reg_t JESD_TX_PERIPHERAL_ID = '{ 'h0004, "PERIPHERAL_ID" , '{
    "PERIPHERAL_ID": '{ 31, 0, RO, 'h???????? }}};
  `define SET_JESD_TX_PERIPHERAL_ID_PERIPHERAL_ID(x) SetField(JESD_TX_PERIPHERAL_ID,"PERIPHERAL_ID",x)
  `define GET_JESD_TX_PERIPHERAL_ID_PERIPHERAL_ID(x) GetField(JESD_TX_PERIPHERAL_ID,"PERIPHERAL_ID",x)
  `define DEFAULT_JESD_TX_PERIPHERAL_ID_PERIPHERAL_ID GetResetValue(JESD_TX_PERIPHERAL_ID,"PERIPHERAL_ID")
  `define UPDATE_JESD_TX_PERIPHERAL_ID_PERIPHERAL_ID(x,y) UpdateField(JESD_TX_PERIPHERAL_ID,"PERIPHERAL_ID",x,y)

  const reg_t JESD_TX_SCRATCH = '{ 'h0008, "SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_JESD_TX_SCRATCH_SCRATCH(x) SetField(JESD_TX_SCRATCH,"SCRATCH",x)
  `define GET_JESD_TX_SCRATCH_SCRATCH(x) GetField(JESD_TX_SCRATCH,"SCRATCH",x)
  `define DEFAULT_JESD_TX_SCRATCH_SCRATCH GetResetValue(JESD_TX_SCRATCH,"SCRATCH")
  `define UPDATE_JESD_TX_SCRATCH_SCRATCH(x,y) UpdateField(JESD_TX_SCRATCH,"SCRATCH",x,y)

  const reg_t JESD_TX_IDENTIFICATION = '{ 'h000c, "IDENTIFICATION" , '{
    "IDENTIFICATION": '{ 31, 0, RO, 'h32303454 }}};
  `define SET_JESD_TX_IDENTIFICATION_IDENTIFICATION(x) SetField(JESD_TX_IDENTIFICATION,"IDENTIFICATION",x)
  `define GET_JESD_TX_IDENTIFICATION_IDENTIFICATION(x) GetField(JESD_TX_IDENTIFICATION,"IDENTIFICATION",x)
  `define DEFAULT_JESD_TX_IDENTIFICATION_IDENTIFICATION GetResetValue(JESD_TX_IDENTIFICATION,"IDENTIFICATION")
  `define UPDATE_JESD_TX_IDENTIFICATION_IDENTIFICATION(x,y) UpdateField(JESD_TX_IDENTIFICATION,"IDENTIFICATION",x,y)

  const reg_t JESD_TX_SYNTH_NUM_LANES = '{ 'h0010, "SYNTH_NUM_LANES" , '{
    "SYNTH_NUM_LANES": '{ 31, 0, RO, 'h???????? }}};
  `define SET_JESD_TX_SYNTH_NUM_LANES_SYNTH_NUM_LANES(x) SetField(JESD_TX_SYNTH_NUM_LANES,"SYNTH_NUM_LANES",x)
  `define GET_JESD_TX_SYNTH_NUM_LANES_SYNTH_NUM_LANES(x) GetField(JESD_TX_SYNTH_NUM_LANES,"SYNTH_NUM_LANES",x)
  `define DEFAULT_JESD_TX_SYNTH_NUM_LANES_SYNTH_NUM_LANES GetResetValue(JESD_TX_SYNTH_NUM_LANES,"SYNTH_NUM_LANES")
  `define UPDATE_JESD_TX_SYNTH_NUM_LANES_SYNTH_NUM_LANES(x,y) UpdateField(JESD_TX_SYNTH_NUM_LANES,"SYNTH_NUM_LANES",x,y)

  const reg_t JESD_TX_SYNTH_DATA_PATH_WIDTH = '{ 'h0014, "SYNTH_DATA_PATH_WIDTH" , '{
    "TPL_DATA_PATH_WIDTH": '{ 15, 8, RO, 'h00000002 },
    "SYNTH_DATA_PATH_WIDTH": '{ 7, 0, RO, 'h00000002 }}};
  `define SET_JESD_TX_SYNTH_DATA_PATH_WIDTH_TPL_DATA_PATH_WIDTH(x) SetField(JESD_TX_SYNTH_DATA_PATH_WIDTH,"TPL_DATA_PATH_WIDTH",x)
  `define GET_JESD_TX_SYNTH_DATA_PATH_WIDTH_TPL_DATA_PATH_WIDTH(x) GetField(JESD_TX_SYNTH_DATA_PATH_WIDTH,"TPL_DATA_PATH_WIDTH",x)
  `define DEFAULT_JESD_TX_SYNTH_DATA_PATH_WIDTH_TPL_DATA_PATH_WIDTH GetResetValue(JESD_TX_SYNTH_DATA_PATH_WIDTH,"TPL_DATA_PATH_WIDTH")
  `define UPDATE_JESD_TX_SYNTH_DATA_PATH_WIDTH_TPL_DATA_PATH_WIDTH(x,y) UpdateField(JESD_TX_SYNTH_DATA_PATH_WIDTH,"TPL_DATA_PATH_WIDTH",x,y)
  `define SET_JESD_TX_SYNTH_DATA_PATH_WIDTH_SYNTH_DATA_PATH_WIDTH(x) SetField(JESD_TX_SYNTH_DATA_PATH_WIDTH,"SYNTH_DATA_PATH_WIDTH",x)
  `define GET_JESD_TX_SYNTH_DATA_PATH_WIDTH_SYNTH_DATA_PATH_WIDTH(x) GetField(JESD_TX_SYNTH_DATA_PATH_WIDTH,"SYNTH_DATA_PATH_WIDTH",x)
  `define DEFAULT_JESD_TX_SYNTH_DATA_PATH_WIDTH_SYNTH_DATA_PATH_WIDTH GetResetValue(JESD_TX_SYNTH_DATA_PATH_WIDTH,"SYNTH_DATA_PATH_WIDTH")
  `define UPDATE_JESD_TX_SYNTH_DATA_PATH_WIDTH_SYNTH_DATA_PATH_WIDTH(x,y) UpdateField(JESD_TX_SYNTH_DATA_PATH_WIDTH,"SYNTH_DATA_PATH_WIDTH",x,y)

  const reg_t JESD_TX_SYNTH_REG_1 = '{ 'h0018, "SYNTH_REG_1" , '{
    "ENABLE_CHAR_REPLACE": '{ 18, 18, RO, 'h00 },
    "ASYNC_CLK": '{ 12, 12, RO, 0 },
    "ENCODER": '{ 9, 8, RO, 'h?? },
    "NUM_LINKS": '{ 7, 0, RO, 'h?? }}};
  `define SET_JESD_TX_SYNTH_REG_1_ENABLE_CHAR_REPLACE(x) SetField(JESD_TX_SYNTH_REG_1,"ENABLE_CHAR_REPLACE",x)
  `define GET_JESD_TX_SYNTH_REG_1_ENABLE_CHAR_REPLACE(x) GetField(JESD_TX_SYNTH_REG_1,"ENABLE_CHAR_REPLACE",x)
  `define DEFAULT_JESD_TX_SYNTH_REG_1_ENABLE_CHAR_REPLACE GetResetValue(JESD_TX_SYNTH_REG_1,"ENABLE_CHAR_REPLACE")
  `define UPDATE_JESD_TX_SYNTH_REG_1_ENABLE_CHAR_REPLACE(x,y) UpdateField(JESD_TX_SYNTH_REG_1,"ENABLE_CHAR_REPLACE",x,y)
  `define SET_JESD_TX_SYNTH_REG_1_ASYNC_CLK(x) SetField(JESD_TX_SYNTH_REG_1,"ASYNC_CLK",x)
  `define GET_JESD_TX_SYNTH_REG_1_ASYNC_CLK(x) GetField(JESD_TX_SYNTH_REG_1,"ASYNC_CLK",x)
  `define DEFAULT_JESD_TX_SYNTH_REG_1_ASYNC_CLK GetResetValue(JESD_TX_SYNTH_REG_1,"ASYNC_CLK")
  `define UPDATE_JESD_TX_SYNTH_REG_1_ASYNC_CLK(x,y) UpdateField(JESD_TX_SYNTH_REG_1,"ASYNC_CLK",x,y)
  `define SET_JESD_TX_SYNTH_REG_1_ENCODER(x) SetField(JESD_TX_SYNTH_REG_1,"ENCODER",x)
  `define GET_JESD_TX_SYNTH_REG_1_ENCODER(x) GetField(JESD_TX_SYNTH_REG_1,"ENCODER",x)
  `define DEFAULT_JESD_TX_SYNTH_REG_1_ENCODER GetResetValue(JESD_TX_SYNTH_REG_1,"ENCODER")
  `define UPDATE_JESD_TX_SYNTH_REG_1_ENCODER(x,y) UpdateField(JESD_TX_SYNTH_REG_1,"ENCODER",x,y)
  `define SET_JESD_TX_SYNTH_REG_1_NUM_LINKS(x) SetField(JESD_TX_SYNTH_REG_1,"NUM_LINKS",x)
  `define GET_JESD_TX_SYNTH_REG_1_NUM_LINKS(x) GetField(JESD_TX_SYNTH_REG_1,"NUM_LINKS",x)
  `define DEFAULT_JESD_TX_SYNTH_REG_1_NUM_LINKS GetResetValue(JESD_TX_SYNTH_REG_1,"NUM_LINKS")
  `define UPDATE_JESD_TX_SYNTH_REG_1_NUM_LINKS(x,y) UpdateField(JESD_TX_SYNTH_REG_1,"NUM_LINKS",x,y)

  const reg_t JESD_TX_IRQ_ENABLE = '{ 'h0080, "IRQ_ENABLE" , '{
    "IRQ_ENABLE": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_JESD_TX_IRQ_ENABLE_IRQ_ENABLE(x) SetField(JESD_TX_IRQ_ENABLE,"IRQ_ENABLE",x)
  `define GET_JESD_TX_IRQ_ENABLE_IRQ_ENABLE(x) GetField(JESD_TX_IRQ_ENABLE,"IRQ_ENABLE",x)
  `define DEFAULT_JESD_TX_IRQ_ENABLE_IRQ_ENABLE GetResetValue(JESD_TX_IRQ_ENABLE,"IRQ_ENABLE")
  `define UPDATE_JESD_TX_IRQ_ENABLE_IRQ_ENABLE(x,y) UpdateField(JESD_TX_IRQ_ENABLE,"IRQ_ENABLE",x,y)

  const reg_t JESD_TX_IRQ_PENDING = '{ 'h0084, "IRQ_PENDING" , '{
    "IRQ_PENDING": '{ 31, 0, RW1CV, 'h00000000 }}};
  `define SET_JESD_TX_IRQ_PENDING_IRQ_PENDING(x) SetField(JESD_TX_IRQ_PENDING,"IRQ_PENDING",x)
  `define GET_JESD_TX_IRQ_PENDING_IRQ_PENDING(x) GetField(JESD_TX_IRQ_PENDING,"IRQ_PENDING",x)
  `define DEFAULT_JESD_TX_IRQ_PENDING_IRQ_PENDING GetResetValue(JESD_TX_IRQ_PENDING,"IRQ_PENDING")
  `define UPDATE_JESD_TX_IRQ_PENDING_IRQ_PENDING(x,y) UpdateField(JESD_TX_IRQ_PENDING,"IRQ_PENDING",x,y)

  const reg_t JESD_TX_IRQ_SOURCE = '{ 'h0088, "IRQ_SOURCE" , '{
    "IRQ_SOURCE": '{ 31, 0, RW1CV, 'h00000000 }}};
  `define SET_JESD_TX_IRQ_SOURCE_IRQ_SOURCE(x) SetField(JESD_TX_IRQ_SOURCE,"IRQ_SOURCE",x)
  `define GET_JESD_TX_IRQ_SOURCE_IRQ_SOURCE(x) GetField(JESD_TX_IRQ_SOURCE,"IRQ_SOURCE",x)
  `define DEFAULT_JESD_TX_IRQ_SOURCE_IRQ_SOURCE GetResetValue(JESD_TX_IRQ_SOURCE,"IRQ_SOURCE")
  `define UPDATE_JESD_TX_IRQ_SOURCE_IRQ_SOURCE(x,y) UpdateField(JESD_TX_IRQ_SOURCE,"IRQ_SOURCE",x,y)

  const reg_t JESD_TX_LINK_DISABLE = '{ 'h00c0, "LINK_DISABLE" , '{
    "LINK_DISABLE": '{ 0, 0, RW, 'h1 }}};
  `define SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(x) SetField(JESD_TX_LINK_DISABLE,"LINK_DISABLE",x)
  `define GET_JESD_TX_LINK_DISABLE_LINK_DISABLE(x) GetField(JESD_TX_LINK_DISABLE,"LINK_DISABLE",x)
  `define DEFAULT_JESD_TX_LINK_DISABLE_LINK_DISABLE GetResetValue(JESD_TX_LINK_DISABLE,"LINK_DISABLE")
  `define UPDATE_JESD_TX_LINK_DISABLE_LINK_DISABLE(x,y) UpdateField(JESD_TX_LINK_DISABLE,"LINK_DISABLE",x,y)

  const reg_t JESD_TX_LINK_STATE = '{ 'h00c4, "LINK_STATE" , '{
    "EXTERNAL_RESET": '{ 1, 1, RO, 'h? },
    "LINK_STATE": '{ 0, 0, RO, 'h1 }}};
  `define SET_JESD_TX_LINK_STATE_EXTERNAL_RESET(x) SetField(JESD_TX_LINK_STATE,"EXTERNAL_RESET",x)
  `define GET_JESD_TX_LINK_STATE_EXTERNAL_RESET(x) GetField(JESD_TX_LINK_STATE,"EXTERNAL_RESET",x)
  `define DEFAULT_JESD_TX_LINK_STATE_EXTERNAL_RESET GetResetValue(JESD_TX_LINK_STATE,"EXTERNAL_RESET")
  `define UPDATE_JESD_TX_LINK_STATE_EXTERNAL_RESET(x,y) UpdateField(JESD_TX_LINK_STATE,"EXTERNAL_RESET",x,y)
  `define SET_JESD_TX_LINK_STATE_LINK_STATE(x) SetField(JESD_TX_LINK_STATE,"LINK_STATE",x)
  `define GET_JESD_TX_LINK_STATE_LINK_STATE(x) GetField(JESD_TX_LINK_STATE,"LINK_STATE",x)
  `define DEFAULT_JESD_TX_LINK_STATE_LINK_STATE GetResetValue(JESD_TX_LINK_STATE,"LINK_STATE")
  `define UPDATE_JESD_TX_LINK_STATE_LINK_STATE(x,y) UpdateField(JESD_TX_LINK_STATE,"LINK_STATE",x,y)

  const reg_t JESD_TX_LINK_CLK_FREQ = '{ 'h00c8, "LINK_CLK_FREQ" , '{
    "LINK_CLK_FREQ": '{ 31, 0, ROV, 'h????????? }}};
  `define SET_JESD_TX_LINK_CLK_FREQ_LINK_CLK_FREQ(x) SetField(JESD_TX_LINK_CLK_FREQ,"LINK_CLK_FREQ",x)
  `define GET_JESD_TX_LINK_CLK_FREQ_LINK_CLK_FREQ(x) GetField(JESD_TX_LINK_CLK_FREQ,"LINK_CLK_FREQ",x)
  `define DEFAULT_JESD_TX_LINK_CLK_FREQ_LINK_CLK_FREQ GetResetValue(JESD_TX_LINK_CLK_FREQ,"LINK_CLK_FREQ")
  `define UPDATE_JESD_TX_LINK_CLK_FREQ_LINK_CLK_FREQ(x,y) UpdateField(JESD_TX_LINK_CLK_FREQ,"LINK_CLK_FREQ",x,y)

  const reg_t JESD_TX_DEVICE_CLK_FREQ = '{ 'h00cc, "DEVICE_CLK_FREQ" , '{
    "DEVICE_CLK_FREQ": '{ 20, 0, ROV, 'h????????? }}};
  `define SET_JESD_TX_DEVICE_CLK_FREQ_DEVICE_CLK_FREQ(x) SetField(JESD_TX_DEVICE_CLK_FREQ,"DEVICE_CLK_FREQ",x)
  `define GET_JESD_TX_DEVICE_CLK_FREQ_DEVICE_CLK_FREQ(x) GetField(JESD_TX_DEVICE_CLK_FREQ,"DEVICE_CLK_FREQ",x)
  `define DEFAULT_JESD_TX_DEVICE_CLK_FREQ_DEVICE_CLK_FREQ GetResetValue(JESD_TX_DEVICE_CLK_FREQ,"DEVICE_CLK_FREQ")
  `define UPDATE_JESD_TX_DEVICE_CLK_FREQ_DEVICE_CLK_FREQ(x,y) UpdateField(JESD_TX_DEVICE_CLK_FREQ,"DEVICE_CLK_FREQ",x,y)

  const reg_t JESD_TX_SYSREF_CONF = '{ 'h0100, "SYSREF_CONF" , '{
    "SYSREF_ONESHOT": '{ 1, 1, RW, 'h0 },
    "SYSREF_DISABLE": '{ 0, 0, RW, 'h0 }}};
  `define SET_JESD_TX_SYSREF_CONF_SYSREF_ONESHOT(x) SetField(JESD_TX_SYSREF_CONF,"SYSREF_ONESHOT",x)
  `define GET_JESD_TX_SYSREF_CONF_SYSREF_ONESHOT(x) GetField(JESD_TX_SYSREF_CONF,"SYSREF_ONESHOT",x)
  `define DEFAULT_JESD_TX_SYSREF_CONF_SYSREF_ONESHOT GetResetValue(JESD_TX_SYSREF_CONF,"SYSREF_ONESHOT")
  `define UPDATE_JESD_TX_SYSREF_CONF_SYSREF_ONESHOT(x,y) UpdateField(JESD_TX_SYSREF_CONF,"SYSREF_ONESHOT",x,y)
  `define SET_JESD_TX_SYSREF_CONF_SYSREF_DISABLE(x) SetField(JESD_TX_SYSREF_CONF,"SYSREF_DISABLE",x)
  `define GET_JESD_TX_SYSREF_CONF_SYSREF_DISABLE(x) GetField(JESD_TX_SYSREF_CONF,"SYSREF_DISABLE",x)
  `define DEFAULT_JESD_TX_SYSREF_CONF_SYSREF_DISABLE GetResetValue(JESD_TX_SYSREF_CONF,"SYSREF_DISABLE")
  `define UPDATE_JESD_TX_SYSREF_CONF_SYSREF_DISABLE(x,y) UpdateField(JESD_TX_SYSREF_CONF,"SYSREF_DISABLE",x,y)

  const reg_t JESD_TX_SYSREF_LMFC_OFFSET = '{ 'h0104, "SYSREF_LMFC_OFFSET" , '{
    "SYSREF_LMFC_OFFSET": '{ 9, 0, RW, 'h00 }}};
  `define SET_JESD_TX_SYSREF_LMFC_OFFSET_SYSREF_LMFC_OFFSET(x) SetField(JESD_TX_SYSREF_LMFC_OFFSET,"SYSREF_LMFC_OFFSET",x)
  `define GET_JESD_TX_SYSREF_LMFC_OFFSET_SYSREF_LMFC_OFFSET(x) GetField(JESD_TX_SYSREF_LMFC_OFFSET,"SYSREF_LMFC_OFFSET",x)
  `define DEFAULT_JESD_TX_SYSREF_LMFC_OFFSET_SYSREF_LMFC_OFFSET GetResetValue(JESD_TX_SYSREF_LMFC_OFFSET,"SYSREF_LMFC_OFFSET")
  `define UPDATE_JESD_TX_SYSREF_LMFC_OFFSET_SYSREF_LMFC_OFFSET(x,y) UpdateField(JESD_TX_SYSREF_LMFC_OFFSET,"SYSREF_LMFC_OFFSET",x,y)

  const reg_t JESD_TX_SYSREF_STATUS = '{ 'h0108, "SYSREF_STATUS" , '{
    "SYSREF_ALIGNMENT_ERROR": '{ 1, 1, RW1CV, 'h0 },
    "SYSREF_DETECTED": '{ 0, 0, RW1CV, 'h0 }}};
  `define SET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(x) SetField(JESD_TX_SYSREF_STATUS,"SYSREF_ALIGNMENT_ERROR",x)
  `define GET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(x) GetField(JESD_TX_SYSREF_STATUS,"SYSREF_ALIGNMENT_ERROR",x)
  `define DEFAULT_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR GetResetValue(JESD_TX_SYSREF_STATUS,"SYSREF_ALIGNMENT_ERROR")
  `define UPDATE_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(x,y) UpdateField(JESD_TX_SYSREF_STATUS,"SYSREF_ALIGNMENT_ERROR",x,y)
  `define SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(x) SetField(JESD_TX_SYSREF_STATUS,"SYSREF_DETECTED",x)
  `define GET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(x) GetField(JESD_TX_SYSREF_STATUS,"SYSREF_DETECTED",x)
  `define DEFAULT_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED GetResetValue(JESD_TX_SYSREF_STATUS,"SYSREF_DETECTED")
  `define UPDATE_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(x,y) UpdateField(JESD_TX_SYSREF_STATUS,"SYSREF_DETECTED",x,y)

  const reg_t JESD_TX_LANES_DISABLE = '{ 'h0200, "LANES_DISABLE" , '{
    "LANE_DISABLEn": '{ n, n, RW, 'h0 }}};
  `define SET_JESD_TX_LANES_DISABLE_LANE_DISABLEn(x) SetField(JESD_TX_LANES_DISABLE,"LANE_DISABLEn",x)
  `define GET_JESD_TX_LANES_DISABLE_LANE_DISABLEn(x) GetField(JESD_TX_LANES_DISABLE,"LANE_DISABLEn",x)
  `define DEFAULT_JESD_TX_LANES_DISABLE_LANE_DISABLEn GetResetValue(JESD_TX_LANES_DISABLE,"LANE_DISABLEn")
  `define UPDATE_JESD_TX_LANES_DISABLE_LANE_DISABLEn(x,y) UpdateField(JESD_TX_LANES_DISABLE,"LANE_DISABLEn",x,y)

  const reg_t JESD_TX_LINK_CONF0 = '{ 'h0210, "LINK_CONF0" , '{
    "OCTETS_PER_FRAME": '{ 18, 16, RW, 'h00 },
    "OCTETS_PER_MULTIFRAME": '{ 9, 0, RW, 'h03 }}};
  `define SET_JESD_TX_LINK_CONF0_OCTETS_PER_FRAME(x) SetField(JESD_TX_LINK_CONF0,"OCTETS_PER_FRAME",x)
  `define GET_JESD_TX_LINK_CONF0_OCTETS_PER_FRAME(x) GetField(JESD_TX_LINK_CONF0,"OCTETS_PER_FRAME",x)
  `define DEFAULT_JESD_TX_LINK_CONF0_OCTETS_PER_FRAME GetResetValue(JESD_TX_LINK_CONF0,"OCTETS_PER_FRAME")
  `define UPDATE_JESD_TX_LINK_CONF0_OCTETS_PER_FRAME(x,y) UpdateField(JESD_TX_LINK_CONF0,"OCTETS_PER_FRAME",x,y)
  `define SET_JESD_TX_LINK_CONF0_OCTETS_PER_MULTIFRAME(x) SetField(JESD_TX_LINK_CONF0,"OCTETS_PER_MULTIFRAME",x)
  `define GET_JESD_TX_LINK_CONF0_OCTETS_PER_MULTIFRAME(x) GetField(JESD_TX_LINK_CONF0,"OCTETS_PER_MULTIFRAME",x)
  `define DEFAULT_JESD_TX_LINK_CONF0_OCTETS_PER_MULTIFRAME GetResetValue(JESD_TX_LINK_CONF0,"OCTETS_PER_MULTIFRAME")
  `define UPDATE_JESD_TX_LINK_CONF0_OCTETS_PER_MULTIFRAME(x,y) UpdateField(JESD_TX_LINK_CONF0,"OCTETS_PER_MULTIFRAME",x,y)

  const reg_t JESD_TX_LINK_CONF1 = '{ 'h0214, "LINK_CONF1" , '{
    "CHAR_REPLACEMENT_DISABLE": '{ 1, 1, RW, 'h0 },
    "SCRAMBLER_DISABLE": '{ 0, 0, RW, 'h0 }}};
  `define SET_JESD_TX_LINK_CONF1_CHAR_REPLACEMENT_DISABLE(x) SetField(JESD_TX_LINK_CONF1,"CHAR_REPLACEMENT_DISABLE",x)
  `define GET_JESD_TX_LINK_CONF1_CHAR_REPLACEMENT_DISABLE(x) GetField(JESD_TX_LINK_CONF1,"CHAR_REPLACEMENT_DISABLE",x)
  `define DEFAULT_JESD_TX_LINK_CONF1_CHAR_REPLACEMENT_DISABLE GetResetValue(JESD_TX_LINK_CONF1,"CHAR_REPLACEMENT_DISABLE")
  `define UPDATE_JESD_TX_LINK_CONF1_CHAR_REPLACEMENT_DISABLE(x,y) UpdateField(JESD_TX_LINK_CONF1,"CHAR_REPLACEMENT_DISABLE",x,y)
  `define SET_JESD_TX_LINK_CONF1_SCRAMBLER_DISABLE(x) SetField(JESD_TX_LINK_CONF1,"SCRAMBLER_DISABLE",x)
  `define GET_JESD_TX_LINK_CONF1_SCRAMBLER_DISABLE(x) GetField(JESD_TX_LINK_CONF1,"SCRAMBLER_DISABLE",x)
  `define DEFAULT_JESD_TX_LINK_CONF1_SCRAMBLER_DISABLE GetResetValue(JESD_TX_LINK_CONF1,"SCRAMBLER_DISABLE")
  `define UPDATE_JESD_TX_LINK_CONF1_SCRAMBLER_DISABLE(x,y) UpdateField(JESD_TX_LINK_CONF1,"SCRAMBLER_DISABLE",x,y)

  const reg_t JESD_TX_MULTI_LINK_DISABLE = '{ 'h0218, "MULTI_LINK_DISABLE" , '{
    "LINK_DISABLEn": '{ n, n, RW, 'h0 }}};
  `define SET_JESD_TX_MULTI_LINK_DISABLE_LINK_DISABLEn(x) SetField(JESD_TX_MULTI_LINK_DISABLE,"LINK_DISABLEn",x)
  `define GET_JESD_TX_MULTI_LINK_DISABLE_LINK_DISABLEn(x) GetField(JESD_TX_MULTI_LINK_DISABLE,"LINK_DISABLEn",x)
  `define DEFAULT_JESD_TX_MULTI_LINK_DISABLE_LINK_DISABLEn GetResetValue(JESD_TX_MULTI_LINK_DISABLE,"LINK_DISABLEn")
  `define UPDATE_JESD_TX_MULTI_LINK_DISABLE_LINK_DISABLEn(x,y) UpdateField(JESD_TX_MULTI_LINK_DISABLE,"LINK_DISABLEn",x,y)

  const reg_t JESD_TX_LINK_CONF4 = '{ 'h021c, "LINK_CONF4" , '{
    "TPL_BEATS_PER_MULTIFRAME": '{ 7, 0, RW, 'h00 }}};
  `define SET_JESD_TX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME(x) SetField(JESD_TX_LINK_CONF4,"TPL_BEATS_PER_MULTIFRAME",x)
  `define GET_JESD_TX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME(x) GetField(JESD_TX_LINK_CONF4,"TPL_BEATS_PER_MULTIFRAME",x)
  `define DEFAULT_JESD_TX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME GetResetValue(JESD_TX_LINK_CONF4,"TPL_BEATS_PER_MULTIFRAME")
  `define UPDATE_JESD_TX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME(x,y) UpdateField(JESD_TX_LINK_CONF4,"TPL_BEATS_PER_MULTIFRAME",x,y)

  const reg_t JESD_TX_LINK_CONF2 = '{ 'h0240, "LINK_CONF2" , '{
    "SKIP_ILAS": '{ 2, 2, RW, 'h0 },
    "CONTINUOUS_ILAS": '{ 1, 1, RW, 'h0 },
    "CONTINUOUS_CGS": '{ 0, 0, RW, 'h0 }}};
  `define SET_JESD_TX_LINK_CONF2_SKIP_ILAS(x) SetField(JESD_TX_LINK_CONF2,"SKIP_ILAS",x)
  `define GET_JESD_TX_LINK_CONF2_SKIP_ILAS(x) GetField(JESD_TX_LINK_CONF2,"SKIP_ILAS",x)
  `define DEFAULT_JESD_TX_LINK_CONF2_SKIP_ILAS GetResetValue(JESD_TX_LINK_CONF2,"SKIP_ILAS")
  `define UPDATE_JESD_TX_LINK_CONF2_SKIP_ILAS(x,y) UpdateField(JESD_TX_LINK_CONF2,"SKIP_ILAS",x,y)
  `define SET_JESD_TX_LINK_CONF2_CONTINUOUS_ILAS(x) SetField(JESD_TX_LINK_CONF2,"CONTINUOUS_ILAS",x)
  `define GET_JESD_TX_LINK_CONF2_CONTINUOUS_ILAS(x) GetField(JESD_TX_LINK_CONF2,"CONTINUOUS_ILAS",x)
  `define DEFAULT_JESD_TX_LINK_CONF2_CONTINUOUS_ILAS GetResetValue(JESD_TX_LINK_CONF2,"CONTINUOUS_ILAS")
  `define UPDATE_JESD_TX_LINK_CONF2_CONTINUOUS_ILAS(x,y) UpdateField(JESD_TX_LINK_CONF2,"CONTINUOUS_ILAS",x,y)
  `define SET_JESD_TX_LINK_CONF2_CONTINUOUS_CGS(x) SetField(JESD_TX_LINK_CONF2,"CONTINUOUS_CGS",x)
  `define GET_JESD_TX_LINK_CONF2_CONTINUOUS_CGS(x) GetField(JESD_TX_LINK_CONF2,"CONTINUOUS_CGS",x)
  `define DEFAULT_JESD_TX_LINK_CONF2_CONTINUOUS_CGS GetResetValue(JESD_TX_LINK_CONF2,"CONTINUOUS_CGS")
  `define UPDATE_JESD_TX_LINK_CONF2_CONTINUOUS_CGS(x,y) UpdateField(JESD_TX_LINK_CONF2,"CONTINUOUS_CGS",x,y)

  const reg_t JESD_TX_LINK_CONF3 = '{ 'h0244, "LINK_CONF3" , '{
    "MFRAMES_PER_ILAS": '{ 7, 0, RW, 'h03 }}};
  `define SET_JESD_TX_LINK_CONF3_MFRAMES_PER_ILAS(x) SetField(JESD_TX_LINK_CONF3,"MFRAMES_PER_ILAS",x)
  `define GET_JESD_TX_LINK_CONF3_MFRAMES_PER_ILAS(x) GetField(JESD_TX_LINK_CONF3,"MFRAMES_PER_ILAS",x)
  `define DEFAULT_JESD_TX_LINK_CONF3_MFRAMES_PER_ILAS GetResetValue(JESD_TX_LINK_CONF3,"MFRAMES_PER_ILAS")
  `define UPDATE_JESD_TX_LINK_CONF3_MFRAMES_PER_ILAS(x,y) UpdateField(JESD_TX_LINK_CONF3,"MFRAMES_PER_ILAS",x,y)

  const reg_t JESD_TX_MANUAL_SYNC_REQUEST = '{ 'h0248, "MANUAL_SYNC_REQUEST" , '{
    "MANUAL_SYNC_REQUEST": '{ 0, 0, W1S, 'h0 }}};
  `define SET_JESD_TX_MANUAL_SYNC_REQUEST_MANUAL_SYNC_REQUEST(x) SetField(JESD_TX_MANUAL_SYNC_REQUEST,"MANUAL_SYNC_REQUEST",x)
  `define GET_JESD_TX_MANUAL_SYNC_REQUEST_MANUAL_SYNC_REQUEST(x) GetField(JESD_TX_MANUAL_SYNC_REQUEST,"MANUAL_SYNC_REQUEST",x)
  `define DEFAULT_JESD_TX_MANUAL_SYNC_REQUEST_MANUAL_SYNC_REQUEST GetResetValue(JESD_TX_MANUAL_SYNC_REQUEST,"MANUAL_SYNC_REQUEST")
  `define UPDATE_JESD_TX_MANUAL_SYNC_REQUEST_MANUAL_SYNC_REQUEST(x,y) UpdateField(JESD_TX_MANUAL_SYNC_REQUEST,"MANUAL_SYNC_REQUEST",x,y)

  const reg_t JESD_TX_LINK_STATUS = '{ 'h0280, "LINK_STATUS" , '{
    "STATUS_SYNC": '{ 11, 4, ROV, 'h?? },
    "STATUS_STATE": '{ 1, 0, ROV, 'h00 }}};
  `define SET_JESD_TX_LINK_STATUS_STATUS_SYNC(x) SetField(JESD_TX_LINK_STATUS,"STATUS_SYNC",x)
  `define GET_JESD_TX_LINK_STATUS_STATUS_SYNC(x) GetField(JESD_TX_LINK_STATUS,"STATUS_SYNC",x)
  `define DEFAULT_JESD_TX_LINK_STATUS_STATUS_SYNC GetResetValue(JESD_TX_LINK_STATUS,"STATUS_SYNC")
  `define UPDATE_JESD_TX_LINK_STATUS_STATUS_SYNC(x,y) UpdateField(JESD_TX_LINK_STATUS,"STATUS_SYNC",x,y)
  `define SET_JESD_TX_LINK_STATUS_STATUS_STATE(x) SetField(JESD_TX_LINK_STATUS,"STATUS_STATE",x)
  `define GET_JESD_TX_LINK_STATUS_STATUS_STATE(x) GetField(JESD_TX_LINK_STATUS,"STATUS_STATE",x)
  `define DEFAULT_JESD_TX_LINK_STATUS_STATUS_STATE GetResetValue(JESD_TX_LINK_STATUS,"STATUS_STATE")
  `define UPDATE_JESD_TX_LINK_STATUS_STATUS_STATE(x,y) UpdateField(JESD_TX_LINK_STATUS,"STATUS_STATE",x,y)

  const reg_t JESD_TX_LANEn_ILAS0 = '{ 'h0310 + 'h20*n, "LANEn_ILAS0" , '{
    "BID": '{ 27, 24, RW, 'h0 },
    "DID": '{ 23, 16, RW, 'h00 }}};
  `define SET_JESD_TX_LANEn_ILAS0_BID(x) SetField(JESD_TX_LANEn_ILAS0,"BID",x)
  `define GET_JESD_TX_LANEn_ILAS0_BID(x) GetField(JESD_TX_LANEn_ILAS0,"BID",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS0_BID GetResetValue(JESD_TX_LANEn_ILAS0,"BID")
  `define UPDATE_JESD_TX_LANEn_ILAS0_BID(x,y) UpdateField(JESD_TX_LANEn_ILAS0,"BID",x,y)
  `define SET_JESD_TX_LANEn_ILAS0_DID(x) SetField(JESD_TX_LANEn_ILAS0,"DID",x)
  `define GET_JESD_TX_LANEn_ILAS0_DID(x) GetField(JESD_TX_LANEn_ILAS0,"DID",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS0_DID GetResetValue(JESD_TX_LANEn_ILAS0,"DID")
  `define UPDATE_JESD_TX_LANEn_ILAS0_DID(x,y) UpdateField(JESD_TX_LANEn_ILAS0,"DID",x,y)

  const reg_t JESD_TX_LANEn_ILAS1 = '{ 'h0314 + 'h20*n, "LANEn_ILAS1" , '{
    "K": '{ 28, 24, RW, 'h00 },
    "F": '{ 23, 16, RW, 'h00 },
    "SCR": '{ 15, 15, RW, 'h0 },
    "L": '{ 12, 8, RW, 'h00 },
    "LID": '{ 4, 0, RW, 'h00 }}};
  `define SET_JESD_TX_LANEn_ILAS1_K(x) SetField(JESD_TX_LANEn_ILAS1,"K",x)
  `define GET_JESD_TX_LANEn_ILAS1_K(x) GetField(JESD_TX_LANEn_ILAS1,"K",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS1_K GetResetValue(JESD_TX_LANEn_ILAS1,"K")
  `define UPDATE_JESD_TX_LANEn_ILAS1_K(x,y) UpdateField(JESD_TX_LANEn_ILAS1,"K",x,y)
  `define SET_JESD_TX_LANEn_ILAS1_F(x) SetField(JESD_TX_LANEn_ILAS1,"F",x)
  `define GET_JESD_TX_LANEn_ILAS1_F(x) GetField(JESD_TX_LANEn_ILAS1,"F",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS1_F GetResetValue(JESD_TX_LANEn_ILAS1,"F")
  `define UPDATE_JESD_TX_LANEn_ILAS1_F(x,y) UpdateField(JESD_TX_LANEn_ILAS1,"F",x,y)
  `define SET_JESD_TX_LANEn_ILAS1_SCR(x) SetField(JESD_TX_LANEn_ILAS1,"SCR",x)
  `define GET_JESD_TX_LANEn_ILAS1_SCR(x) GetField(JESD_TX_LANEn_ILAS1,"SCR",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS1_SCR GetResetValue(JESD_TX_LANEn_ILAS1,"SCR")
  `define UPDATE_JESD_TX_LANEn_ILAS1_SCR(x,y) UpdateField(JESD_TX_LANEn_ILAS1,"SCR",x,y)
  `define SET_JESD_TX_LANEn_ILAS1_L(x) SetField(JESD_TX_LANEn_ILAS1,"L",x)
  `define GET_JESD_TX_LANEn_ILAS1_L(x) GetField(JESD_TX_LANEn_ILAS1,"L",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS1_L GetResetValue(JESD_TX_LANEn_ILAS1,"L")
  `define UPDATE_JESD_TX_LANEn_ILAS1_L(x,y) UpdateField(JESD_TX_LANEn_ILAS1,"L",x,y)
  `define SET_JESD_TX_LANEn_ILAS1_LID(x) SetField(JESD_TX_LANEn_ILAS1,"LID",x)
  `define GET_JESD_TX_LANEn_ILAS1_LID(x) GetField(JESD_TX_LANEn_ILAS1,"LID",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS1_LID GetResetValue(JESD_TX_LANEn_ILAS1,"LID")
  `define UPDATE_JESD_TX_LANEn_ILAS1_LID(x,y) UpdateField(JESD_TX_LANEn_ILAS1,"LID",x,y)

  const reg_t JESD_TX_LANEn_ILAS2 = '{ 'h0318 + 'h20*n, "LANEn_ILAS2" , '{
    "JESDV": '{ 31, 29, RW, 'h0 },
    "S": '{ 28, 24, RW, 'h00 },
    "SUBCLASSV": '{ 23, 21, RW, 'h0 },
    "NP": '{ 20, 16, RW, 'h00 },
    "CS": '{ 15, 14, RW, 'h0 },
    "N": '{ 12, 8, RW, 'h00 },
    "M": '{ 7, 0, RW, 'h00 }}};
  `define SET_JESD_TX_LANEn_ILAS2_JESDV(x) SetField(JESD_TX_LANEn_ILAS2,"JESDV",x)
  `define GET_JESD_TX_LANEn_ILAS2_JESDV(x) GetField(JESD_TX_LANEn_ILAS2,"JESDV",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS2_JESDV GetResetValue(JESD_TX_LANEn_ILAS2,"JESDV")
  `define UPDATE_JESD_TX_LANEn_ILAS2_JESDV(x,y) UpdateField(JESD_TX_LANEn_ILAS2,"JESDV",x,y)
  `define SET_JESD_TX_LANEn_ILAS2_S(x) SetField(JESD_TX_LANEn_ILAS2,"S",x)
  `define GET_JESD_TX_LANEn_ILAS2_S(x) GetField(JESD_TX_LANEn_ILAS2,"S",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS2_S GetResetValue(JESD_TX_LANEn_ILAS2,"S")
  `define UPDATE_JESD_TX_LANEn_ILAS2_S(x,y) UpdateField(JESD_TX_LANEn_ILAS2,"S",x,y)
  `define SET_JESD_TX_LANEn_ILAS2_SUBCLASSV(x) SetField(JESD_TX_LANEn_ILAS2,"SUBCLASSV",x)
  `define GET_JESD_TX_LANEn_ILAS2_SUBCLASSV(x) GetField(JESD_TX_LANEn_ILAS2,"SUBCLASSV",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS2_SUBCLASSV GetResetValue(JESD_TX_LANEn_ILAS2,"SUBCLASSV")
  `define UPDATE_JESD_TX_LANEn_ILAS2_SUBCLASSV(x,y) UpdateField(JESD_TX_LANEn_ILAS2,"SUBCLASSV",x,y)
  `define SET_JESD_TX_LANEn_ILAS2_NP(x) SetField(JESD_TX_LANEn_ILAS2,"NP",x)
  `define GET_JESD_TX_LANEn_ILAS2_NP(x) GetField(JESD_TX_LANEn_ILAS2,"NP",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS2_NP GetResetValue(JESD_TX_LANEn_ILAS2,"NP")
  `define UPDATE_JESD_TX_LANEn_ILAS2_NP(x,y) UpdateField(JESD_TX_LANEn_ILAS2,"NP",x,y)
  `define SET_JESD_TX_LANEn_ILAS2_CS(x) SetField(JESD_TX_LANEn_ILAS2,"CS",x)
  `define GET_JESD_TX_LANEn_ILAS2_CS(x) GetField(JESD_TX_LANEn_ILAS2,"CS",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS2_CS GetResetValue(JESD_TX_LANEn_ILAS2,"CS")
  `define UPDATE_JESD_TX_LANEn_ILAS2_CS(x,y) UpdateField(JESD_TX_LANEn_ILAS2,"CS",x,y)
  `define SET_JESD_TX_LANEn_ILAS2_N(x) SetField(JESD_TX_LANEn_ILAS2,"N",x)
  `define GET_JESD_TX_LANEn_ILAS2_N(x) GetField(JESD_TX_LANEn_ILAS2,"N",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS2_N GetResetValue(JESD_TX_LANEn_ILAS2,"N")
  `define UPDATE_JESD_TX_LANEn_ILAS2_N(x,y) UpdateField(JESD_TX_LANEn_ILAS2,"N",x,y)
  `define SET_JESD_TX_LANEn_ILAS2_M(x) SetField(JESD_TX_LANEn_ILAS2,"M",x)
  `define GET_JESD_TX_LANEn_ILAS2_M(x) GetField(JESD_TX_LANEn_ILAS2,"M",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS2_M GetResetValue(JESD_TX_LANEn_ILAS2,"M")
  `define UPDATE_JESD_TX_LANEn_ILAS2_M(x,y) UpdateField(JESD_TX_LANEn_ILAS2,"M",x,y)

  const reg_t JESD_TX_LANEn_ILAS3 = '{ 'h031c + 'h20*n, "LANEn_ILAS3" , '{
    "FCHK": '{ 31, 24, RW, 'h00 },
    "HD": '{ 7, 7, RW, 'h0 },
    "CF": '{ 4, 0, RO, 'h00 }}};
  `define SET_JESD_TX_LANEn_ILAS3_FCHK(x) SetField(JESD_TX_LANEn_ILAS3,"FCHK",x)
  `define GET_JESD_TX_LANEn_ILAS3_FCHK(x) GetField(JESD_TX_LANEn_ILAS3,"FCHK",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS3_FCHK GetResetValue(JESD_TX_LANEn_ILAS3,"FCHK")
  `define UPDATE_JESD_TX_LANEn_ILAS3_FCHK(x,y) UpdateField(JESD_TX_LANEn_ILAS3,"FCHK",x,y)
  `define SET_JESD_TX_LANEn_ILAS3_HD(x) SetField(JESD_TX_LANEn_ILAS3,"HD",x)
  `define GET_JESD_TX_LANEn_ILAS3_HD(x) GetField(JESD_TX_LANEn_ILAS3,"HD",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS3_HD GetResetValue(JESD_TX_LANEn_ILAS3,"HD")
  `define UPDATE_JESD_TX_LANEn_ILAS3_HD(x,y) UpdateField(JESD_TX_LANEn_ILAS3,"HD",x,y)
  `define SET_JESD_TX_LANEn_ILAS3_CF(x) SetField(JESD_TX_LANEn_ILAS3,"CF",x)
  `define GET_JESD_TX_LANEn_ILAS3_CF(x) GetField(JESD_TX_LANEn_ILAS3,"CF",x)
  `define DEFAULT_JESD_TX_LANEn_ILAS3_CF GetResetValue(JESD_TX_LANEn_ILAS3,"CF")
  `define UPDATE_JESD_TX_LANEn_ILAS3_CF(x,y) UpdateField(JESD_TX_LANEn_ILAS3,"CF",x,y)


endpackage
