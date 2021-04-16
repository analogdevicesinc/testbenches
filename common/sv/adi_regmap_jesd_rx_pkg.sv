// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018 (c) Analog Devices, Inc. All rights reserved.
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

/* Auto generated Register Map */
/* Thu May  6 07:15:12 2021 */

package adi_regmap_jesd_rx_pkg;
  import adi_regmap_pkg::*;


/* JESD204 RX (axi_jesd204_rx) */

  const reg_t jesd_rx_VERSION = '{ 'h0000, "VERSION" , '{
    "VERSION_MAJOR": '{ 31, 16, RO, 'h0001 },
    "VERSION_MINOR": '{ 15, 8, RO, 'h03 },
    "VERSION_PATCH": '{ 7, 0, RO, 'h61 }}};
  `define SET_jesd_rx_VERSION_VERSION_MAJOR(x) SetField(jesd_rx_VERSION,"VERSION_MAJOR",x)
  `define GET_jesd_rx_VERSION_VERSION_MAJOR(x) GetField(jesd_rx_VERSION,"VERSION_MAJOR",x)
  `define SET_jesd_rx_VERSION_VERSION_MINOR(x) SetField(jesd_rx_VERSION,"VERSION_MINOR",x)
  `define GET_jesd_rx_VERSION_VERSION_MINOR(x) GetField(jesd_rx_VERSION,"VERSION_MINOR",x)
  `define SET_jesd_rx_VERSION_VERSION_PATCH(x) SetField(jesd_rx_VERSION,"VERSION_PATCH",x)
  `define GET_jesd_rx_VERSION_VERSION_PATCH(x) GetField(jesd_rx_VERSION,"VERSION_PATCH",x)

  const reg_t jesd_rx_PERIPHERAL_ID = '{ 'h0004, "PERIPHERAL_ID" , '{
    "PERIPHERAL_ID": '{ 31, 0, RO, 'h???????? }}};
  `define SET_jesd_rx_PERIPHERAL_ID_PERIPHERAL_ID(x) SetField(jesd_rx_PERIPHERAL_ID,"PERIPHERAL_ID",x)
  `define GET_jesd_rx_PERIPHERAL_ID_PERIPHERAL_ID(x) GetField(jesd_rx_PERIPHERAL_ID,"PERIPHERAL_ID",x)

  const reg_t jesd_rx_SCRATCH = '{ 'h0008, "SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_jesd_rx_SCRATCH_SCRATCH(x) SetField(jesd_rx_SCRATCH,"SCRATCH",x)
  `define GET_jesd_rx_SCRATCH_SCRATCH(x) GetField(jesd_rx_SCRATCH,"SCRATCH",x)

  const reg_t jesd_rx_IDENTIFICATION = '{ 'h000c, "IDENTIFICATION" , '{
    "IDENTIFICATION": '{ 31, 0, RO, 'h32303452 }}};
  `define SET_jesd_rx_IDENTIFICATION_IDENTIFICATION(x) SetField(jesd_rx_IDENTIFICATION,"IDENTIFICATION",x)
  `define GET_jesd_rx_IDENTIFICATION_IDENTIFICATION(x) GetField(jesd_rx_IDENTIFICATION,"IDENTIFICATION",x)

  const reg_t jesd_rx_SYNTH_NUM_LANES = '{ 'h0010, "SYNTH_NUM_LANES" , '{
    "SYNTH_NUM_LANES": '{ 31, 0, RO, 'h???????? }}};
  `define SET_jesd_rx_SYNTH_NUM_LANES_SYNTH_NUM_LANES(x) SetField(jesd_rx_SYNTH_NUM_LANES,"SYNTH_NUM_LANES",x)
  `define GET_jesd_rx_SYNTH_NUM_LANES_SYNTH_NUM_LANES(x) GetField(jesd_rx_SYNTH_NUM_LANES,"SYNTH_NUM_LANES",x)

  const reg_t jesd_rx_SYNTH_DATA_PATH_WIDTH = '{ 'h0014, "SYNTH_DATA_PATH_WIDTH" , '{
    "Reserved": '{ 31, 16, RO, 'h0000 },
    "TPL_DATA_PATH_WIDTH": '{ 15, 8, RO, 'h00000002 },
    "SYNTH_DATA_PATH_WIDTH": '{ 7, 0, RO, 'h00000002 }}};
  `define SET_jesd_rx_SYNTH_DATA_PATH_WIDTH_Reserved(x) SetField(jesd_rx_SYNTH_DATA_PATH_WIDTH,"Reserved",x)
  `define GET_jesd_rx_SYNTH_DATA_PATH_WIDTH_Reserved(x) GetField(jesd_rx_SYNTH_DATA_PATH_WIDTH,"Reserved",x)
  `define SET_jesd_rx_SYNTH_DATA_PATH_WIDTH_TPL_DATA_PATH_WIDTH(x) SetField(jesd_rx_SYNTH_DATA_PATH_WIDTH,"TPL_DATA_PATH_WIDTH",x)
  `define GET_jesd_rx_SYNTH_DATA_PATH_WIDTH_TPL_DATA_PATH_WIDTH(x) GetField(jesd_rx_SYNTH_DATA_PATH_WIDTH,"TPL_DATA_PATH_WIDTH",x)
  `define SET_jesd_rx_SYNTH_DATA_PATH_WIDTH_SYNTH_DATA_PATH_WIDTH(x) SetField(jesd_rx_SYNTH_DATA_PATH_WIDTH,"SYNTH_DATA_PATH_WIDTH",x)
  `define GET_jesd_rx_SYNTH_DATA_PATH_WIDTH_SYNTH_DATA_PATH_WIDTH(x) GetField(jesd_rx_SYNTH_DATA_PATH_WIDTH,"SYNTH_DATA_PATH_WIDTH",x)

  const reg_t jesd_rx_SYNTH_REG_1 = '{ 'h0018, "SYNTH_REG_1" , '{
    "Reserved": '{ 31, 19, RO, 'h0000 },
    "ENABLE_CHAR_REPLACE": '{ 18, 18, RO, 'h00 },
    "ENABLE_FRAME_ALIGN_ERR_RESET": '{ 17, 17, RO, 'h00 },
    "ENABLE_FRAME_ALIGN_CHECK": '{ 16, 16, RO, 'h00 },
    "ASYNC_CLK": '{ 12, 12, RO, 0 },
    "DECODER": '{ 9, 8, RO, 'h?? },
    "NUM_LINKS": '{ 7, 0, RO, 'h?? }}};
  `define SET_jesd_rx_SYNTH_REG_1_Reserved(x) SetField(jesd_rx_SYNTH_REG_1,"Reserved",x)
  `define GET_jesd_rx_SYNTH_REG_1_Reserved(x) GetField(jesd_rx_SYNTH_REG_1,"Reserved",x)
  `define SET_jesd_rx_SYNTH_REG_1_ENABLE_CHAR_REPLACE(x) SetField(jesd_rx_SYNTH_REG_1,"ENABLE_CHAR_REPLACE",x)
  `define GET_jesd_rx_SYNTH_REG_1_ENABLE_CHAR_REPLACE(x) GetField(jesd_rx_SYNTH_REG_1,"ENABLE_CHAR_REPLACE",x)
  `define SET_jesd_rx_SYNTH_REG_1_ENABLE_FRAME_ALIGN_ERR_RESET(x) SetField(jesd_rx_SYNTH_REG_1,"ENABLE_FRAME_ALIGN_ERR_RESET",x)
  `define GET_jesd_rx_SYNTH_REG_1_ENABLE_FRAME_ALIGN_ERR_RESET(x) GetField(jesd_rx_SYNTH_REG_1,"ENABLE_FRAME_ALIGN_ERR_RESET",x)
  `define SET_jesd_rx_SYNTH_REG_1_ENABLE_FRAME_ALIGN_CHECK(x) SetField(jesd_rx_SYNTH_REG_1,"ENABLE_FRAME_ALIGN_CHECK",x)
  `define GET_jesd_rx_SYNTH_REG_1_ENABLE_FRAME_ALIGN_CHECK(x) GetField(jesd_rx_SYNTH_REG_1,"ENABLE_FRAME_ALIGN_CHECK",x)
  `define SET_jesd_rx_SYNTH_REG_1_ASYNC_CLK(x) SetField(jesd_rx_SYNTH_REG_1,"ASYNC_CLK",x)
  `define GET_jesd_rx_SYNTH_REG_1_ASYNC_CLK(x) GetField(jesd_rx_SYNTH_REG_1,"ASYNC_CLK",x)
  `define SET_jesd_rx_SYNTH_REG_1_DECODER(x) SetField(jesd_rx_SYNTH_REG_1,"DECODER",x)
  `define GET_jesd_rx_SYNTH_REG_1_DECODER(x) GetField(jesd_rx_SYNTH_REG_1,"DECODER",x)
  `define SET_jesd_rx_SYNTH_REG_1_NUM_LINKS(x) SetField(jesd_rx_SYNTH_REG_1,"NUM_LINKS",x)
  `define GET_jesd_rx_SYNTH_REG_1_NUM_LINKS(x) GetField(jesd_rx_SYNTH_REG_1,"NUM_LINKS",x)

  const reg_t jesd_rx_SYNTH_ELASTIC_BUFFER_SIZE = '{ 'h0040, "SYNTH_ELASTIC_BUFFER_SIZE" , '{
    "SYNTH_ELASTIC_BUFFER_SIZE": '{ 31, 0, RO, 'h00000100 }}};
  `define SET_jesd_rx_SYNTH_ELASTIC_BUFFER_SIZE_SYNTH_ELASTIC_BUFFER_SIZE(x) SetField(jesd_rx_SYNTH_ELASTIC_BUFFER_SIZE,"SYNTH_ELASTIC_BUFFER_SIZE",x)
  `define GET_jesd_rx_SYNTH_ELASTIC_BUFFER_SIZE_SYNTH_ELASTIC_BUFFER_SIZE(x) GetField(jesd_rx_SYNTH_ELASTIC_BUFFER_SIZE,"SYNTH_ELASTIC_BUFFER_SIZE",x)

  const reg_t jesd_rx_IRQ_ENABLE = '{ 'h0080, "IRQ_ENABLE" , '{
    "IRQ_ENABLE": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_jesd_rx_IRQ_ENABLE_IRQ_ENABLE(x) SetField(jesd_rx_IRQ_ENABLE,"IRQ_ENABLE",x)
  `define GET_jesd_rx_IRQ_ENABLE_IRQ_ENABLE(x) GetField(jesd_rx_IRQ_ENABLE,"IRQ_ENABLE",x)

  const reg_t jesd_rx_IRQ_PENDING = '{ 'h0084, "IRQ_PENDING" , '{
    "IRQ_PENDING": '{ 31, 0, RW1CV, 'h00000000 }}};
  `define SET_jesd_rx_IRQ_PENDING_IRQ_PENDING(x) SetField(jesd_rx_IRQ_PENDING,"IRQ_PENDING",x)
  `define GET_jesd_rx_IRQ_PENDING_IRQ_PENDING(x) GetField(jesd_rx_IRQ_PENDING,"IRQ_PENDING",x)

  const reg_t jesd_rx_IRQ_SOURCE = '{ 'h0088, "IRQ_SOURCE" , '{
    "IRQ_SOURCE": '{ 31, 0, RW1CV, 'h00000000 }}};
  `define SET_jesd_rx_IRQ_SOURCE_IRQ_SOURCE(x) SetField(jesd_rx_IRQ_SOURCE,"IRQ_SOURCE",x)
  `define GET_jesd_rx_IRQ_SOURCE_IRQ_SOURCE(x) GetField(jesd_rx_IRQ_SOURCE,"IRQ_SOURCE",x)

  const reg_t jesd_rx_LINK_DISABLE = '{ 'h00c0, "LINK_DISABLE" , '{
    "Reserved": '{ 31, 1, RO, 'h00 },
    "LINK_DISABLE": '{ 0, 0, RW, 'h1 }}};
  `define SET_jesd_rx_LINK_DISABLE_Reserved(x) SetField(jesd_rx_LINK_DISABLE,"Reserved",x)
  `define GET_jesd_rx_LINK_DISABLE_Reserved(x) GetField(jesd_rx_LINK_DISABLE,"Reserved",x)
  `define SET_jesd_rx_LINK_DISABLE_LINK_DISABLE(x) SetField(jesd_rx_LINK_DISABLE,"LINK_DISABLE",x)
  `define GET_jesd_rx_LINK_DISABLE_LINK_DISABLE(x) GetField(jesd_rx_LINK_DISABLE,"LINK_DISABLE",x)

  const reg_t jesd_rx_LINK_STATE = '{ 'h00c4, "LINK_STATE" , '{
    "Reserved": '{ 31, 2, RO, 'h00 },
    "EXTERNAL_RESET": '{ 1, 1, RO, 'h? },
    "LINK_STATE": '{ 0, 0, RO, 'h1 }}};
  `define SET_jesd_rx_LINK_STATE_Reserved(x) SetField(jesd_rx_LINK_STATE,"Reserved",x)
  `define GET_jesd_rx_LINK_STATE_Reserved(x) GetField(jesd_rx_LINK_STATE,"Reserved",x)
  `define SET_jesd_rx_LINK_STATE_EXTERNAL_RESET(x) SetField(jesd_rx_LINK_STATE,"EXTERNAL_RESET",x)
  `define GET_jesd_rx_LINK_STATE_EXTERNAL_RESET(x) GetField(jesd_rx_LINK_STATE,"EXTERNAL_RESET",x)
  `define SET_jesd_rx_LINK_STATE_LINK_STATE(x) SetField(jesd_rx_LINK_STATE,"LINK_STATE",x)
  `define GET_jesd_rx_LINK_STATE_LINK_STATE(x) GetField(jesd_rx_LINK_STATE,"LINK_STATE",x)

  const reg_t jesd_rx_LINK_CLK_FREQ = '{ 'h00c8, "LINK_CLK_FREQ" , '{
    "LINK_CLK_FREQ": '{ 20, 0, ROV, 'h????????? }}};
  `define SET_jesd_rx_LINK_CLK_FREQ_LINK_CLK_FREQ(x) SetField(jesd_rx_LINK_CLK_FREQ,"LINK_CLK_FREQ",x)
  `define GET_jesd_rx_LINK_CLK_FREQ_LINK_CLK_FREQ(x) GetField(jesd_rx_LINK_CLK_FREQ,"LINK_CLK_FREQ",x)

  const reg_t jesd_rx_DEVICE_CLK_FREQ = '{ 'h00cc, "DEVICE_CLK_FREQ" , '{
    "DEVICE_CLK_FREQ": '{ 20, 0, ROV, 'h????????? }}};
  `define SET_jesd_rx_DEVICE_CLK_FREQ_DEVICE_CLK_FREQ(x) SetField(jesd_rx_DEVICE_CLK_FREQ,"DEVICE_CLK_FREQ",x)
  `define GET_jesd_rx_DEVICE_CLK_FREQ_DEVICE_CLK_FREQ(x) GetField(jesd_rx_DEVICE_CLK_FREQ,"DEVICE_CLK_FREQ",x)

  const reg_t jesd_rx_SYSREF_CONF = '{ 'h0100, "SYSREF_CONF" , '{
    "Reserved": '{ 31, 2, RO, 'h00 },
    "SYSREF_ONESHOT": '{ 1, 1, RW, 'h0 },
    "SYSREF_DISABLE": '{ 0, 0, RW, 'h0 }}};
  `define SET_jesd_rx_SYSREF_CONF_Reserved(x) SetField(jesd_rx_SYSREF_CONF,"Reserved",x)
  `define GET_jesd_rx_SYSREF_CONF_Reserved(x) GetField(jesd_rx_SYSREF_CONF,"Reserved",x)
  `define SET_jesd_rx_SYSREF_CONF_SYSREF_ONESHOT(x) SetField(jesd_rx_SYSREF_CONF,"SYSREF_ONESHOT",x)
  `define GET_jesd_rx_SYSREF_CONF_SYSREF_ONESHOT(x) GetField(jesd_rx_SYSREF_CONF,"SYSREF_ONESHOT",x)
  `define SET_jesd_rx_SYSREF_CONF_SYSREF_DISABLE(x) SetField(jesd_rx_SYSREF_CONF,"SYSREF_DISABLE",x)
  `define GET_jesd_rx_SYSREF_CONF_SYSREF_DISABLE(x) GetField(jesd_rx_SYSREF_CONF,"SYSREF_DISABLE",x)

  const reg_t jesd_rx_SYSREF_LMFC_OFFSET = '{ 'h0104, "SYSREF_LMFC_OFFSET" , '{
    "Reserved": '{ 31, 10, RO, 'h00 },
    "SYSREF_LMFC_OFFSET": '{ 9, 0, RW, 'h00 }}};
  `define SET_jesd_rx_SYSREF_LMFC_OFFSET_Reserved(x) SetField(jesd_rx_SYSREF_LMFC_OFFSET,"Reserved",x)
  `define GET_jesd_rx_SYSREF_LMFC_OFFSET_Reserved(x) GetField(jesd_rx_SYSREF_LMFC_OFFSET,"Reserved",x)
  `define SET_jesd_rx_SYSREF_LMFC_OFFSET_SYSREF_LMFC_OFFSET(x) SetField(jesd_rx_SYSREF_LMFC_OFFSET,"SYSREF_LMFC_OFFSET",x)
  `define GET_jesd_rx_SYSREF_LMFC_OFFSET_SYSREF_LMFC_OFFSET(x) GetField(jesd_rx_SYSREF_LMFC_OFFSET,"SYSREF_LMFC_OFFSET",x)

  const reg_t jesd_rx_SYSREF_STATUS = '{ 'h0108, "SYSREF_STATUS" , '{
    "Reserved": '{ 31, 2, RO, 'h00 },
    "SYSREF_ALIGNMENT_ERROR": '{ 1, 1, RW1CV, 'h0 },
    "SYSREF_DETECTED": '{ 0, 0, RW1CV, 'h0 }}};
  `define SET_jesd_rx_SYSREF_STATUS_Reserved(x) SetField(jesd_rx_SYSREF_STATUS,"Reserved",x)
  `define GET_jesd_rx_SYSREF_STATUS_Reserved(x) GetField(jesd_rx_SYSREF_STATUS,"Reserved",x)
  `define SET_jesd_rx_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(x) SetField(jesd_rx_SYSREF_STATUS,"SYSREF_ALIGNMENT_ERROR",x)
  `define GET_jesd_rx_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(x) GetField(jesd_rx_SYSREF_STATUS,"SYSREF_ALIGNMENT_ERROR",x)
  `define SET_jesd_rx_SYSREF_STATUS_SYSREF_DETECTED(x) SetField(jesd_rx_SYSREF_STATUS,"SYSREF_DETECTED",x)
  `define GET_jesd_rx_SYSREF_STATUS_SYSREF_DETECTED(x) GetField(jesd_rx_SYSREF_STATUS,"SYSREF_DETECTED",x)

  const reg_t jesd_rx_LANES_DISABLE = '{ 'h0200, "LANES_DISABLE" , '{
    "LANE_DISABLE1": '{ 1, 1, RW, 'h0 },
    "LANE_DISABLE0": '{ 0, 0, RW, 'h0 }}};
  `define SET_jesd_rx_LANES_DISABLE_LANE_DISABLE1(x) SetField(jesd_rx_LANES_DISABLE,"LANE_DISABLE1",x)
  `define GET_jesd_rx_LANES_DISABLE_LANE_DISABLE1(x) GetField(jesd_rx_LANES_DISABLE,"LANE_DISABLE1",x)
  `define SET_jesd_rx_LANES_DISABLE_LANE_DISABLE0(x) SetField(jesd_rx_LANES_DISABLE,"LANE_DISABLE0",x)
  `define GET_jesd_rx_LANES_DISABLE_LANE_DISABLE0(x) GetField(jesd_rx_LANES_DISABLE,"LANE_DISABLE0",x)

  const reg_t jesd_rx_LINK_CONF0 = '{ 'h0210, "LINK_CONF0" , '{
    "Reserved": '{ 31, 19, RO, 'h00 },
    "OCTETS_PER_FRAME": '{ 18, 16, RW, 'h00 },
    "Reserved": '{ 15, 10, RO, 'h00 },
    "OCTETS_PER_MULTIFRAME": '{ 9, 0, RW, 'h03 }}};
  `define SET_jesd_rx_LINK_CONF0_Reserved(x) SetField(jesd_rx_LINK_CONF0,"Reserved",x)
  `define GET_jesd_rx_LINK_CONF0_Reserved(x) GetField(jesd_rx_LINK_CONF0,"Reserved",x)
  `define SET_jesd_rx_LINK_CONF0_OCTETS_PER_FRAME(x) SetField(jesd_rx_LINK_CONF0,"OCTETS_PER_FRAME",x)
  `define GET_jesd_rx_LINK_CONF0_OCTETS_PER_FRAME(x) GetField(jesd_rx_LINK_CONF0,"OCTETS_PER_FRAME",x)
  `define SET_jesd_rx_LINK_CONF0_Reserved(x) SetField(jesd_rx_LINK_CONF0,"Reserved",x)
  `define GET_jesd_rx_LINK_CONF0_Reserved(x) GetField(jesd_rx_LINK_CONF0,"Reserved",x)
  `define SET_jesd_rx_LINK_CONF0_OCTETS_PER_MULTIFRAME(x) SetField(jesd_rx_LINK_CONF0,"OCTETS_PER_MULTIFRAME",x)
  `define GET_jesd_rx_LINK_CONF0_OCTETS_PER_MULTIFRAME(x) GetField(jesd_rx_LINK_CONF0,"OCTETS_PER_MULTIFRAME",x)

  const reg_t jesd_rx_LINK_CONF1 = '{ 'h0214, "LINK_CONF1" , '{
    "Reserved": '{ 31, 2, RO, 'h0 },
    "CHAR_REPLACEMENT_DISABLE": '{ 1, 1, RW, 'h0 },
    "DESCRAMBLER_DISABLE": '{ 0, 0, RW, 'h0 }}};
  `define SET_jesd_rx_LINK_CONF1_Reserved(x) SetField(jesd_rx_LINK_CONF1,"Reserved",x)
  `define GET_jesd_rx_LINK_CONF1_Reserved(x) GetField(jesd_rx_LINK_CONF1,"Reserved",x)
  `define SET_jesd_rx_LINK_CONF1_CHAR_REPLACEMENT_DISABLE(x) SetField(jesd_rx_LINK_CONF1,"CHAR_REPLACEMENT_DISABLE",x)
  `define GET_jesd_rx_LINK_CONF1_CHAR_REPLACEMENT_DISABLE(x) GetField(jesd_rx_LINK_CONF1,"CHAR_REPLACEMENT_DISABLE",x)
  `define SET_jesd_rx_LINK_CONF1_DESCRAMBLER_DISABLE(x) SetField(jesd_rx_LINK_CONF1,"DESCRAMBLER_DISABLE",x)
  `define GET_jesd_rx_LINK_CONF1_DESCRAMBLER_DISABLE(x) GetField(jesd_rx_LINK_CONF1,"DESCRAMBLER_DISABLE",x)

  const reg_t jesd_rx_MULTI_LINK_DISABLE = '{ 'h0218, "MULTI_LINK_DISABLE" , '{
    "LINK_DISABLE1": '{ 1, 1, RW, 'h0 },
    "LINK_DISABLE0": '{ 0, 0, RW, 'h0 }}};
  `define SET_jesd_rx_MULTI_LINK_DISABLE_LINK_DISABLE1(x) SetField(jesd_rx_MULTI_LINK_DISABLE,"LINK_DISABLE1",x)
  `define GET_jesd_rx_MULTI_LINK_DISABLE_LINK_DISABLE1(x) GetField(jesd_rx_MULTI_LINK_DISABLE,"LINK_DISABLE1",x)
  `define SET_jesd_rx_MULTI_LINK_DISABLE_LINK_DISABLE0(x) SetField(jesd_rx_MULTI_LINK_DISABLE,"LINK_DISABLE0",x)
  `define GET_jesd_rx_MULTI_LINK_DISABLE_LINK_DISABLE0(x) GetField(jesd_rx_MULTI_LINK_DISABLE,"LINK_DISABLE0",x)

  const reg_t jesd_rx_LINK_CONF4 = '{ 'h021c, "LINK_CONF4" , '{
    "Reserved": '{ 31, 8, RO, 'h0 },
    "TPL_BEATS_PER_MULTIFRAME": '{ 7, 0, RW, 'h00 }}};
  `define SET_jesd_rx_LINK_CONF4_Reserved(x) SetField(jesd_rx_LINK_CONF4,"Reserved",x)
  `define GET_jesd_rx_LINK_CONF4_Reserved(x) GetField(jesd_rx_LINK_CONF4,"Reserved",x)
  `define SET_jesd_rx_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME(x) SetField(jesd_rx_LINK_CONF4,"TPL_BEATS_PER_MULTIFRAME",x)
  `define GET_jesd_rx_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME(x) GetField(jesd_rx_LINK_CONF4,"TPL_BEATS_PER_MULTIFRAME",x)

  const reg_t jesd_rx_LINK_CONF2 = '{ 'h0240, "LINK_CONF2" , '{
    "Reserved": '{ 31, 17, RO, 'h0 },
    "BUFFER_EARLY_RELEASE": '{ 16, 16, RW, 'h0 },
    "Reserved": '{ 15, 10, RO, 'h0 },
    "BUFFER_DEALY": '{ 9, 0, RW, 'h0 }}};
  `define SET_jesd_rx_LINK_CONF2_Reserved(x) SetField(jesd_rx_LINK_CONF2,"Reserved",x)
  `define GET_jesd_rx_LINK_CONF2_Reserved(x) GetField(jesd_rx_LINK_CONF2,"Reserved",x)
  `define SET_jesd_rx_LINK_CONF2_BUFFER_EARLY_RELEASE(x) SetField(jesd_rx_LINK_CONF2,"BUFFER_EARLY_RELEASE",x)
  `define GET_jesd_rx_LINK_CONF2_BUFFER_EARLY_RELEASE(x) GetField(jesd_rx_LINK_CONF2,"BUFFER_EARLY_RELEASE",x)
  `define SET_jesd_rx_LINK_CONF2_Reserved(x) SetField(jesd_rx_LINK_CONF2,"Reserved",x)
  `define GET_jesd_rx_LINK_CONF2_Reserved(x) GetField(jesd_rx_LINK_CONF2,"Reserved",x)
  `define SET_jesd_rx_LINK_CONF2_BUFFER_DEALY(x) SetField(jesd_rx_LINK_CONF2,"BUFFER_DEALY",x)
  `define GET_jesd_rx_LINK_CONF2_BUFFER_DEALY(x) GetField(jesd_rx_LINK_CONF2,"BUFFER_DEALY",x)

  const reg_t jesd_rx_LINK_CONF3 = '{ 'h0244, "LINK_CONF3" , '{
    "Reserved": '{ 31, 15, RO, 'h0 },
    "MASK_INVALID_HEADER": '{ 14, 14, RW, 'h0 },
    "MASK_UNEXPECTED_EOMB": '{ 13, 13, RW, 'h0 },
    "MASK_UNEXPECTED_EOEMB": '{ 12, 12, RW, 'h0 },
    "MASK_CRC_MISMATCH": '{ 11, 11, RW, 'h0 },
    "MASK_UNEXPECTEDK": '{ 10, 10, RW, 'h0 },
    "MASK_NOTINTABLE": '{ 9, 9, RW, 'h0 },
    "MASK_DISPERR": '{ 8, 8, RW, 'h0 },
    "Reserved": '{ 7, 1, RO, 'h0 },
    "RESET_COUNTER": '{ 0, 0, RW, 'h0 }}};
  `define SET_jesd_rx_LINK_CONF3_Reserved(x) SetField(jesd_rx_LINK_CONF3,"Reserved",x)
  `define GET_jesd_rx_LINK_CONF3_Reserved(x) GetField(jesd_rx_LINK_CONF3,"Reserved",x)
  `define SET_jesd_rx_LINK_CONF3_MASK_INVALID_HEADER(x) SetField(jesd_rx_LINK_CONF3,"MASK_INVALID_HEADER",x)
  `define GET_jesd_rx_LINK_CONF3_MASK_INVALID_HEADER(x) GetField(jesd_rx_LINK_CONF3,"MASK_INVALID_HEADER",x)
  `define SET_jesd_rx_LINK_CONF3_MASK_UNEXPECTED_EOMB(x) SetField(jesd_rx_LINK_CONF3,"MASK_UNEXPECTED_EOMB",x)
  `define GET_jesd_rx_LINK_CONF3_MASK_UNEXPECTED_EOMB(x) GetField(jesd_rx_LINK_CONF3,"MASK_UNEXPECTED_EOMB",x)
  `define SET_jesd_rx_LINK_CONF3_MASK_UNEXPECTED_EOEMB(x) SetField(jesd_rx_LINK_CONF3,"MASK_UNEXPECTED_EOEMB",x)
  `define GET_jesd_rx_LINK_CONF3_MASK_UNEXPECTED_EOEMB(x) GetField(jesd_rx_LINK_CONF3,"MASK_UNEXPECTED_EOEMB",x)
  `define SET_jesd_rx_LINK_CONF3_MASK_CRC_MISMATCH(x) SetField(jesd_rx_LINK_CONF3,"MASK_CRC_MISMATCH",x)
  `define GET_jesd_rx_LINK_CONF3_MASK_CRC_MISMATCH(x) GetField(jesd_rx_LINK_CONF3,"MASK_CRC_MISMATCH",x)
  `define SET_jesd_rx_LINK_CONF3_MASK_UNEXPECTEDK(x) SetField(jesd_rx_LINK_CONF3,"MASK_UNEXPECTEDK",x)
  `define GET_jesd_rx_LINK_CONF3_MASK_UNEXPECTEDK(x) GetField(jesd_rx_LINK_CONF3,"MASK_UNEXPECTEDK",x)
  `define SET_jesd_rx_LINK_CONF3_MASK_NOTINTABLE(x) SetField(jesd_rx_LINK_CONF3,"MASK_NOTINTABLE",x)
  `define GET_jesd_rx_LINK_CONF3_MASK_NOTINTABLE(x) GetField(jesd_rx_LINK_CONF3,"MASK_NOTINTABLE",x)
  `define SET_jesd_rx_LINK_CONF3_MASK_DISPERR(x) SetField(jesd_rx_LINK_CONF3,"MASK_DISPERR",x)
  `define GET_jesd_rx_LINK_CONF3_MASK_DISPERR(x) GetField(jesd_rx_LINK_CONF3,"MASK_DISPERR",x)
  `define SET_jesd_rx_LINK_CONF3_Reserved(x) SetField(jesd_rx_LINK_CONF3,"Reserved",x)
  `define GET_jesd_rx_LINK_CONF3_Reserved(x) GetField(jesd_rx_LINK_CONF3,"Reserved",x)
  `define SET_jesd_rx_LINK_CONF3_RESET_COUNTER(x) SetField(jesd_rx_LINK_CONF3,"RESET_COUNTER",x)
  `define GET_jesd_rx_LINK_CONF3_RESET_COUNTER(x) GetField(jesd_rx_LINK_CONF3,"RESET_COUNTER",x)

  const reg_t jesd_rx_LINK_STATUS = '{ 'h0280, "LINK_STATUS" , '{
    "Reserved": '{ 31, 2, RO, 'h00 },
    "STATUS_STATE": '{ 1, 0, ROV, 'h00 }}};
  `define SET_jesd_rx_LINK_STATUS_Reserved(x) SetField(jesd_rx_LINK_STATUS,"Reserved",x)
  `define GET_jesd_rx_LINK_STATUS_Reserved(x) GetField(jesd_rx_LINK_STATUS,"Reserved",x)
  `define SET_jesd_rx_LINK_STATUS_STATUS_STATE(x) SetField(jesd_rx_LINK_STATUS,"STATUS_STATE",x)
  `define GET_jesd_rx_LINK_STATUS_STATUS_STATE(x) GetField(jesd_rx_LINK_STATUS,"STATUS_STATE",x)

  const reg_t jesd_rx_LANEn_STATUS = '{ 'h0300, "LANEn_STATUS" , '{
    "Reserved": '{ 31, 11, RO, 'h0 },
    "EMB_STATE": '{ 10, 8, RO, 'h0 },
    "Reserved": '{ 7, 6, RO, 'h0 },
    "ILAS_READY": '{ 5, 5, ROV, 'h0 },
    "IFS_READY": '{ 4, 4, ROV, 'h0 },
    "Reserved": '{ 3, 2, RO, 'h0 },
    "CGS_STATE": '{ 1, 0, ROV, 'h0 }}};
  `define SET_jesd_rx_LANEn_STATUS_Reserved(x) SetField(jesd_rx_LANEn_STATUS,"Reserved",x)
  `define GET_jesd_rx_LANEn_STATUS_Reserved(x) GetField(jesd_rx_LANEn_STATUS,"Reserved",x)
  `define SET_jesd_rx_LANEn_STATUS_EMB_STATE(x) SetField(jesd_rx_LANEn_STATUS,"EMB_STATE",x)
  `define GET_jesd_rx_LANEn_STATUS_EMB_STATE(x) GetField(jesd_rx_LANEn_STATUS,"EMB_STATE",x)
  `define SET_jesd_rx_LANEn_STATUS_Reserved(x) SetField(jesd_rx_LANEn_STATUS,"Reserved",x)
  `define GET_jesd_rx_LANEn_STATUS_Reserved(x) GetField(jesd_rx_LANEn_STATUS,"Reserved",x)
  `define SET_jesd_rx_LANEn_STATUS_ILAS_READY(x) SetField(jesd_rx_LANEn_STATUS,"ILAS_READY",x)
  `define GET_jesd_rx_LANEn_STATUS_ILAS_READY(x) GetField(jesd_rx_LANEn_STATUS,"ILAS_READY",x)
  `define SET_jesd_rx_LANEn_STATUS_IFS_READY(x) SetField(jesd_rx_LANEn_STATUS,"IFS_READY",x)
  `define GET_jesd_rx_LANEn_STATUS_IFS_READY(x) GetField(jesd_rx_LANEn_STATUS,"IFS_READY",x)
  `define SET_jesd_rx_LANEn_STATUS_Reserved(x) SetField(jesd_rx_LANEn_STATUS,"Reserved",x)
  `define GET_jesd_rx_LANEn_STATUS_Reserved(x) GetField(jesd_rx_LANEn_STATUS,"Reserved",x)
  `define SET_jesd_rx_LANEn_STATUS_CGS_STATE(x) SetField(jesd_rx_LANEn_STATUS,"CGS_STATE",x)
  `define GET_jesd_rx_LANEn_STATUS_CGS_STATE(x) GetField(jesd_rx_LANEn_STATUS,"CGS_STATE",x)

  const reg_t jesd_rx_LANEn_LATENCY = '{ 'h0304, "LANEn_LATENCY" , '{
    "Reserved": '{ 31, 14, RO, 'h0 },
    "LATENCY": '{ 13, 0, ROV, 'h0 }}};
  `define SET_jesd_rx_LANEn_LATENCY_Reserved(x) SetField(jesd_rx_LANEn_LATENCY,"Reserved",x)
  `define GET_jesd_rx_LANEn_LATENCY_Reserved(x) GetField(jesd_rx_LANEn_LATENCY,"Reserved",x)
  `define SET_jesd_rx_LANEn_LATENCY_LATENCY(x) SetField(jesd_rx_LANEn_LATENCY,"LATENCY",x)
  `define GET_jesd_rx_LANEn_LATENCY_LATENCY(x) GetField(jesd_rx_LANEn_LATENCY,"LATENCY",x)

  const reg_t jesd_rx_LANEn_ERROR_STATISTICS = '{ 'h0308, "LANEn_ERROR_STATISTICS" , '{
    "ERROR_REGISTER": '{ 31, 0, RO, 'h0 }}};
  `define SET_jesd_rx_LANEn_ERROR_STATISTICS_ERROR_REGISTER(x) SetField(jesd_rx_LANEn_ERROR_STATISTICS,"ERROR_REGISTER",x)
  `define GET_jesd_rx_LANEn_ERROR_STATISTICS_ERROR_REGISTER(x) GetField(jesd_rx_LANEn_ERROR_STATISTICS,"ERROR_REGISTER",x)

  const reg_t jesd_rx_LANEn_LANE_FRAME_ALIGN_ERR_CNT = '{ 'h030c, "LANEn_LANE_FRAME_ALIGN_ERR_CNT" , '{
    "ERROR_REGISTER": '{ 7, 0, RO, 'h0 }}};
  `define SET_jesd_rx_LANEn_LANE_FRAME_ALIGN_ERR_CNT_ERROR_REGISTER(x) SetField(jesd_rx_LANEn_LANE_FRAME_ALIGN_ERR_CNT,"ERROR_REGISTER",x)
  `define GET_jesd_rx_LANEn_LANE_FRAME_ALIGN_ERR_CNT_ERROR_REGISTER(x) GetField(jesd_rx_LANEn_LANE_FRAME_ALIGN_ERR_CNT,"ERROR_REGISTER",x)

  const reg_t jesd_rx_LANEn_ILAS0 = '{ 'h0310, "LANEn_ILAS0" , '{
    "Reserved": '{ 31, 28, RO, 'h0 },
    "BID": '{ 27, 24, RO, 'h0 },
    "DID": '{ 23, 16, RO, 'h00 },
    "Reserved": '{ 15, 0, RO, 'h0000 }}};
  `define SET_jesd_rx_LANEn_ILAS0_Reserved(x) SetField(jesd_rx_LANEn_ILAS0,"Reserved",x)
  `define GET_jesd_rx_LANEn_ILAS0_Reserved(x) GetField(jesd_rx_LANEn_ILAS0,"Reserved",x)
  `define SET_jesd_rx_LANEn_ILAS0_BID(x) SetField(jesd_rx_LANEn_ILAS0,"BID",x)
  `define GET_jesd_rx_LANEn_ILAS0_BID(x) GetField(jesd_rx_LANEn_ILAS0,"BID",x)
  `define SET_jesd_rx_LANEn_ILAS0_DID(x) SetField(jesd_rx_LANEn_ILAS0,"DID",x)
  `define GET_jesd_rx_LANEn_ILAS0_DID(x) GetField(jesd_rx_LANEn_ILAS0,"DID",x)
  `define SET_jesd_rx_LANEn_ILAS0_Reserved(x) SetField(jesd_rx_LANEn_ILAS0,"Reserved",x)
  `define GET_jesd_rx_LANEn_ILAS0_Reserved(x) GetField(jesd_rx_LANEn_ILAS0,"Reserved",x)

  const reg_t jesd_rx_LANEn_ILAS1 = '{ 'h0314, "LANEn_ILAS1" , '{
    "Reserved": '{ 31, 29, RO, 'h00 },
    "K": '{ 28, 24, RO, 'h00 },
    "F": '{ 23, 16, RO, 'h00 },
    "SCR": '{ 15, 15, RO, 'h0 },
    "Reserved": '{ 14, 13, RO, 'h0 },
    "L": '{ 12, 8, RO, 'h00 },
    "Reserved": '{ 7, 5, RO, 'h0 },
    "LID": '{ 4, 0, RO, 'h00 }}};
  `define SET_jesd_rx_LANEn_ILAS1_Reserved(x) SetField(jesd_rx_LANEn_ILAS1,"Reserved",x)
  `define GET_jesd_rx_LANEn_ILAS1_Reserved(x) GetField(jesd_rx_LANEn_ILAS1,"Reserved",x)
  `define SET_jesd_rx_LANEn_ILAS1_K(x) SetField(jesd_rx_LANEn_ILAS1,"K",x)
  `define GET_jesd_rx_LANEn_ILAS1_K(x) GetField(jesd_rx_LANEn_ILAS1,"K",x)
  `define SET_jesd_rx_LANEn_ILAS1_F(x) SetField(jesd_rx_LANEn_ILAS1,"F",x)
  `define GET_jesd_rx_LANEn_ILAS1_F(x) GetField(jesd_rx_LANEn_ILAS1,"F",x)
  `define SET_jesd_rx_LANEn_ILAS1_SCR(x) SetField(jesd_rx_LANEn_ILAS1,"SCR",x)
  `define GET_jesd_rx_LANEn_ILAS1_SCR(x) GetField(jesd_rx_LANEn_ILAS1,"SCR",x)
  `define SET_jesd_rx_LANEn_ILAS1_Reserved(x) SetField(jesd_rx_LANEn_ILAS1,"Reserved",x)
  `define GET_jesd_rx_LANEn_ILAS1_Reserved(x) GetField(jesd_rx_LANEn_ILAS1,"Reserved",x)
  `define SET_jesd_rx_LANEn_ILAS1_L(x) SetField(jesd_rx_LANEn_ILAS1,"L",x)
  `define GET_jesd_rx_LANEn_ILAS1_L(x) GetField(jesd_rx_LANEn_ILAS1,"L",x)
  `define SET_jesd_rx_LANEn_ILAS1_Reserved(x) SetField(jesd_rx_LANEn_ILAS1,"Reserved",x)
  `define GET_jesd_rx_LANEn_ILAS1_Reserved(x) GetField(jesd_rx_LANEn_ILAS1,"Reserved",x)
  `define SET_jesd_rx_LANEn_ILAS1_LID(x) SetField(jesd_rx_LANEn_ILAS1,"LID",x)
  `define GET_jesd_rx_LANEn_ILAS1_LID(x) GetField(jesd_rx_LANEn_ILAS1,"LID",x)

  const reg_t jesd_rx_LANEn_ILAS2 = '{ 'h0318, "LANEn_ILAS2" , '{
    "JESDV": '{ 31, 29, RO, 'h0 },
    "S": '{ 28, 24, RO, 'h00 },
    "SUBCLASSV": '{ 23, 21, RO, 'h0 },
    "NP": '{ 20, 16, RO, 'h00 },
    "CS": '{ 15, 14, RO, 'h0 },
    "Reserved": '{ 13, 13, RO, 'h0 },
    "N": '{ 12, 8, RO, 'h00 },
    "M": '{ 7, 0, RO, 'h00 }}};
  `define SET_jesd_rx_LANEn_ILAS2_JESDV(x) SetField(jesd_rx_LANEn_ILAS2,"JESDV",x)
  `define GET_jesd_rx_LANEn_ILAS2_JESDV(x) GetField(jesd_rx_LANEn_ILAS2,"JESDV",x)
  `define SET_jesd_rx_LANEn_ILAS2_S(x) SetField(jesd_rx_LANEn_ILAS2,"S",x)
  `define GET_jesd_rx_LANEn_ILAS2_S(x) GetField(jesd_rx_LANEn_ILAS2,"S",x)
  `define SET_jesd_rx_LANEn_ILAS2_SUBCLASSV(x) SetField(jesd_rx_LANEn_ILAS2,"SUBCLASSV",x)
  `define GET_jesd_rx_LANEn_ILAS2_SUBCLASSV(x) GetField(jesd_rx_LANEn_ILAS2,"SUBCLASSV",x)
  `define SET_jesd_rx_LANEn_ILAS2_NP(x) SetField(jesd_rx_LANEn_ILAS2,"NP",x)
  `define GET_jesd_rx_LANEn_ILAS2_NP(x) GetField(jesd_rx_LANEn_ILAS2,"NP",x)
  `define SET_jesd_rx_LANEn_ILAS2_CS(x) SetField(jesd_rx_LANEn_ILAS2,"CS",x)
  `define GET_jesd_rx_LANEn_ILAS2_CS(x) GetField(jesd_rx_LANEn_ILAS2,"CS",x)
  `define SET_jesd_rx_LANEn_ILAS2_Reserved(x) SetField(jesd_rx_LANEn_ILAS2,"Reserved",x)
  `define GET_jesd_rx_LANEn_ILAS2_Reserved(x) GetField(jesd_rx_LANEn_ILAS2,"Reserved",x)
  `define SET_jesd_rx_LANEn_ILAS2_N(x) SetField(jesd_rx_LANEn_ILAS2,"N",x)
  `define GET_jesd_rx_LANEn_ILAS2_N(x) GetField(jesd_rx_LANEn_ILAS2,"N",x)
  `define SET_jesd_rx_LANEn_ILAS2_M(x) SetField(jesd_rx_LANEn_ILAS2,"M",x)
  `define GET_jesd_rx_LANEn_ILAS2_M(x) GetField(jesd_rx_LANEn_ILAS2,"M",x)

  const reg_t jesd_rx_LANEn_ILAS3 = '{ 'h031c, "LANEn_ILAS3" , '{
    "FCHK": '{ 31, 24, RO, 'h00 },
    "Reserved": '{ 23, 8, RO, 'h0 },
    "HD": '{ 7, 7, RO, 'h0 },
    "Reserved": '{ 6, 5, RO, 'h0 },
    "CF": '{ 4, 0, RO, 'h00 }}};
  `define SET_jesd_rx_LANEn_ILAS3_FCHK(x) SetField(jesd_rx_LANEn_ILAS3,"FCHK",x)
  `define GET_jesd_rx_LANEn_ILAS3_FCHK(x) GetField(jesd_rx_LANEn_ILAS3,"FCHK",x)
  `define SET_jesd_rx_LANEn_ILAS3_Reserved(x) SetField(jesd_rx_LANEn_ILAS3,"Reserved",x)
  `define GET_jesd_rx_LANEn_ILAS3_Reserved(x) GetField(jesd_rx_LANEn_ILAS3,"Reserved",x)
  `define SET_jesd_rx_LANEn_ILAS3_HD(x) SetField(jesd_rx_LANEn_ILAS3,"HD",x)
  `define GET_jesd_rx_LANEn_ILAS3_HD(x) GetField(jesd_rx_LANEn_ILAS3,"HD",x)
  `define SET_jesd_rx_LANEn_ILAS3_Reserved(x) SetField(jesd_rx_LANEn_ILAS3,"Reserved",x)
  `define GET_jesd_rx_LANEn_ILAS3_Reserved(x) GetField(jesd_rx_LANEn_ILAS3,"Reserved",x)
  `define SET_jesd_rx_LANEn_ILAS3_CF(x) SetField(jesd_rx_LANEn_ILAS3,"CF",x)
  `define GET_jesd_rx_LANEn_ILAS3_CF(x) GetField(jesd_rx_LANEn_ILAS3,"CF",x)


endpackage
