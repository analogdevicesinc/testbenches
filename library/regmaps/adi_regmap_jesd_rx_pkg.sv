// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2025 Analog Devices, Inc. All rights reserved.
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
/* Jan 28 13:30:17 2025 v0.3.55 */

package adi_regmap_jesd_rx_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_jesd_rx extends adi_regmap;

    /* JESD204 RX (axi_jesd204_rx) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_MAJOR_F;
      field_base VERSION_MINOR_F;
      field_base VERSION_PATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_MAJOR_F = new("VERSION_MAJOR", 31, 16, RO, 'h1, this);
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h3, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h61, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VERSION_CLASS

    class PERIPHERAL_ID_CLASS extends register_base;
      field_base PERIPHERAL_ID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PERIPHERAL_ID_F = new("PERIPHERAL_ID", 31, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PERIPHERAL_ID_CLASS

    class SCRATCH_CLASS extends register_base;
      field_base SCRATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SCRATCH_CLASS

    class IDENTIFICATION_CLASS extends register_base;
      field_base IDENTIFICATION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IDENTIFICATION_F = new("IDENTIFICATION", 31, 0, RO, 'h32303452, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IDENTIFICATION_CLASS

    class SYNTH_NUM_LANES_CLASS extends register_base;
      field_base SYNTH_NUM_LANES_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SYNTH_NUM_LANES_F = new("SYNTH_NUM_LANES", 31, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SYNTH_NUM_LANES_CLASS

    class SYNTH_DATA_PATH_WIDTH_CLASS extends register_base;
      field_base TPL_DATA_PATH_WIDTH_F;
      field_base SYNTH_DATA_PATH_WIDTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TPL_DATA_PATH_WIDTH_F = new("TPL_DATA_PATH_WIDTH", 15, 8, RO, 'h2, this);
        this.SYNTH_DATA_PATH_WIDTH_F = new("SYNTH_DATA_PATH_WIDTH", 7, 0, RO, 'h2, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SYNTH_DATA_PATH_WIDTH_CLASS

    class SYNTH_1_CLASS extends register_base;
      field_base ENABLE_CHAR_REPLACE_F;
      field_base ENABLE_FRAME_ALIGN_ERR_RESET_F;
      field_base ENABLE_FRAME_ALIGN_CHECK_F;
      field_base ASYNC_CLK_F;
      field_base DECODER_F;
      field_base NUM_LINKS_F;

      function new(
        input string name,
        input int address,
        input int ASYNC_CLK,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ENABLE_CHAR_REPLACE_F = new("ENABLE_CHAR_REPLACE", 18, 18, RO, 'h0, this);
        this.ENABLE_FRAME_ALIGN_ERR_RESET_F = new("ENABLE_FRAME_ALIGN_ERR_RESET", 17, 17, RO, 'h0, this);
        this.ENABLE_FRAME_ALIGN_CHECK_F = new("ENABLE_FRAME_ALIGN_CHECK", 16, 16, RO, 'h1, this);
        this.ASYNC_CLK_F = new("ASYNC_CLK", 12, 12, RO, ASYNC_CLK, this);
        this.DECODER_F = new("DECODER", 9, 8, RO, 'hXXXXXXXX, this);
        this.NUM_LINKS_F = new("NUM_LINKS", 7, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SYNTH_1_CLASS

    class SYNTH_ELASTIC_BUFFER_SIZE_CLASS extends register_base;
      field_base SYNTH_ELASTIC_BUFFER_SIZE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SYNTH_ELASTIC_BUFFER_SIZE_F = new("SYNTH_ELASTIC_BUFFER_SIZE", 31, 0, RO, 'h100, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SYNTH_ELASTIC_BUFFER_SIZE_CLASS

    class IRQ_ENABLE_CLASS extends register_base;
      field_base IRQ_ENABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IRQ_ENABLE_F = new("IRQ_ENABLE", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_ENABLE_CLASS

    class IRQ_PENDING_CLASS extends register_base;
      field_base IRQ_PENDING_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IRQ_PENDING_F = new("IRQ_PENDING", 31, 0, RW1CV, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_PENDING_CLASS

    class IRQ_SOURCE_CLASS extends register_base;
      field_base IRQ_SOURCE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IRQ_SOURCE_F = new("IRQ_SOURCE", 31, 0, RW1CV, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_SOURCE_CLASS

    class LINK_DISABLE_CLASS extends register_base;
      field_base LINK_DISABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.LINK_DISABLE_F = new("LINK_DISABLE", 0, 0, RW, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LINK_DISABLE_CLASS

    class LINK_STATE_CLASS extends register_base;
      field_base EXTERNAL_RESET_F;
      field_base LINK_STATE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.EXTERNAL_RESET_F = new("EXTERNAL_RESET", 1, 1, RO, 'hXXXXXXXX, this);
        this.LINK_STATE_F = new("LINK_STATE", 0, 0, RO, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LINK_STATE_CLASS

    class LINK_CLK_FREQ_CLASS extends register_base;
      field_base LINK_CLK_FREQ_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.LINK_CLK_FREQ_F = new("LINK_CLK_FREQ", 20, 0, ROV, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LINK_CLK_FREQ_CLASS

    class DEVICE_CLK_FREQ_CLASS extends register_base;
      field_base DEVICE_CLK_FREQ_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DEVICE_CLK_FREQ_F = new("DEVICE_CLK_FREQ", 20, 0, ROV, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DEVICE_CLK_FREQ_CLASS

    class SYSREF_CONF_CLASS extends register_base;
      field_base SYSREF_ONESHOT_F;
      field_base SYSREF_DISABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SYSREF_ONESHOT_F = new("SYSREF_ONESHOT", 1, 1, RW, 'h0, this);
        this.SYSREF_DISABLE_F = new("SYSREF_DISABLE", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SYSREF_CONF_CLASS

    class SYSREF_LMFC_OFFSET_CLASS extends register_base;
      field_base SYSREF_LMFC_OFFSET_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SYSREF_LMFC_OFFSET_F = new("SYSREF_LMFC_OFFSET", 9, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SYSREF_LMFC_OFFSET_CLASS

    class SYSREF_STATUS_CLASS extends register_base;
      field_base SYSREF_ALIGNMENT_ERROR_F;
      field_base SYSREF_DETECTED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SYSREF_ALIGNMENT_ERROR_F = new("SYSREF_ALIGNMENT_ERROR", 1, 1, RW1CV, 'h0, this);
        this.SYSREF_DETECTED_F = new("SYSREF_DETECTED", 0, 0, RW1CV, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SYSREF_STATUS_CLASS

    class LANES_DISABLE_CLASS extends register_base;
      field_base LANE_DISABLE0_F;
      field_base LANE_DISABLE1_F;
      field_base LANE_DISABLE2_F;
      field_base LANE_DISABLE3_F;
      field_base LANE_DISABLE4_F;
      field_base LANE_DISABLE5_F;
      field_base LANE_DISABLE6_F;
      field_base LANE_DISABLE7_F;
      field_base LANE_DISABLE8_F;
      field_base LANE_DISABLE9_F;
      field_base LANE_DISABLE10_F;
      field_base LANE_DISABLE11_F;
      field_base LANE_DISABLE12_F;
      field_base LANE_DISABLE13_F;
      field_base LANE_DISABLE14_F;
      field_base LANE_DISABLE15_F;
      field_base LANE_DISABLE16_F;
      field_base LANE_DISABLE17_F;
      field_base LANE_DISABLE18_F;
      field_base LANE_DISABLE19_F;
      field_base LANE_DISABLE20_F;
      field_base LANE_DISABLE21_F;
      field_base LANE_DISABLE22_F;
      field_base LANE_DISABLE23_F;
      field_base LANE_DISABLE24_F;
      field_base LANE_DISABLE25_F;
      field_base LANE_DISABLE26_F;
      field_base LANE_DISABLE27_F;
      field_base LANE_DISABLE28_F;
      field_base LANE_DISABLE29_F;
      field_base LANE_DISABLE30_F;
      field_base LANE_DISABLE31_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.LANE_DISABLE0_F = new("LANE_DISABLE0", 0, 0, RW, 'h0, this);
        this.LANE_DISABLE1_F = new("LANE_DISABLE1", 1, 1, RW, 'h0, this);
        this.LANE_DISABLE2_F = new("LANE_DISABLE2", 2, 2, RW, 'h0, this);
        this.LANE_DISABLE3_F = new("LANE_DISABLE3", 3, 3, RW, 'h0, this);
        this.LANE_DISABLE4_F = new("LANE_DISABLE4", 4, 4, RW, 'h0, this);
        this.LANE_DISABLE5_F = new("LANE_DISABLE5", 5, 5, RW, 'h0, this);
        this.LANE_DISABLE6_F = new("LANE_DISABLE6", 6, 6, RW, 'h0, this);
        this.LANE_DISABLE7_F = new("LANE_DISABLE7", 7, 7, RW, 'h0, this);
        this.LANE_DISABLE8_F = new("LANE_DISABLE8", 8, 8, RW, 'h0, this);
        this.LANE_DISABLE9_F = new("LANE_DISABLE9", 9, 9, RW, 'h0, this);
        this.LANE_DISABLE10_F = new("LANE_DISABLE10", 10, 10, RW, 'h0, this);
        this.LANE_DISABLE11_F = new("LANE_DISABLE11", 11, 11, RW, 'h0, this);
        this.LANE_DISABLE12_F = new("LANE_DISABLE12", 12, 12, RW, 'h0, this);
        this.LANE_DISABLE13_F = new("LANE_DISABLE13", 13, 13, RW, 'h0, this);
        this.LANE_DISABLE14_F = new("LANE_DISABLE14", 14, 14, RW, 'h0, this);
        this.LANE_DISABLE15_F = new("LANE_DISABLE15", 15, 15, RW, 'h0, this);
        this.LANE_DISABLE16_F = new("LANE_DISABLE16", 16, 16, RW, 'h0, this);
        this.LANE_DISABLE17_F = new("LANE_DISABLE17", 17, 17, RW, 'h0, this);
        this.LANE_DISABLE18_F = new("LANE_DISABLE18", 18, 18, RW, 'h0, this);
        this.LANE_DISABLE19_F = new("LANE_DISABLE19", 19, 19, RW, 'h0, this);
        this.LANE_DISABLE20_F = new("LANE_DISABLE20", 20, 20, RW, 'h0, this);
        this.LANE_DISABLE21_F = new("LANE_DISABLE21", 21, 21, RW, 'h0, this);
        this.LANE_DISABLE22_F = new("LANE_DISABLE22", 22, 22, RW, 'h0, this);
        this.LANE_DISABLE23_F = new("LANE_DISABLE23", 23, 23, RW, 'h0, this);
        this.LANE_DISABLE24_F = new("LANE_DISABLE24", 24, 24, RW, 'h0, this);
        this.LANE_DISABLE25_F = new("LANE_DISABLE25", 25, 25, RW, 'h0, this);
        this.LANE_DISABLE26_F = new("LANE_DISABLE26", 26, 26, RW, 'h0, this);
        this.LANE_DISABLE27_F = new("LANE_DISABLE27", 27, 27, RW, 'h0, this);
        this.LANE_DISABLE28_F = new("LANE_DISABLE28", 28, 28, RW, 'h0, this);
        this.LANE_DISABLE29_F = new("LANE_DISABLE29", 29, 29, RW, 'h0, this);
        this.LANE_DISABLE30_F = new("LANE_DISABLE30", 30, 30, RW, 'h0, this);
        this.LANE_DISABLE31_F = new("LANE_DISABLE31", 31, 31, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LANES_DISABLE_CLASS

    class LINK_CONF0_CLASS extends register_base;
      field_base OCTETS_PER_FRAME_F;
      field_base OCTETS_PER_MULTIFRAME_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OCTETS_PER_FRAME_F = new("OCTETS_PER_FRAME", 18, 16, RW, 'h0, this);
        this.OCTETS_PER_MULTIFRAME_F = new("OCTETS_PER_MULTIFRAME", 9, 0, RW, 'h3, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LINK_CONF0_CLASS

    class LINK_CONF1_CLASS extends register_base;
      field_base CHAR_REPLACEMENT_DISABLE_F;
      field_base DESCRAMBLER_DISABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CHAR_REPLACEMENT_DISABLE_F = new("CHAR_REPLACEMENT_DISABLE", 1, 1, RW, 'h0, this);
        this.DESCRAMBLER_DISABLE_F = new("DESCRAMBLER_DISABLE", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LINK_CONF1_CLASS

    class MULTI_LINK_DISABLE_CLASS extends register_base;
      field_base LINK_DISABLE0_F;
      field_base LINK_DISABLE1_F;
      field_base LINK_DISABLE2_F;
      field_base LINK_DISABLE3_F;
      field_base LINK_DISABLE4_F;
      field_base LINK_DISABLE5_F;
      field_base LINK_DISABLE6_F;
      field_base LINK_DISABLE7_F;
      field_base LINK_DISABLE8_F;
      field_base LINK_DISABLE9_F;
      field_base LINK_DISABLE10_F;
      field_base LINK_DISABLE11_F;
      field_base LINK_DISABLE12_F;
      field_base LINK_DISABLE13_F;
      field_base LINK_DISABLE14_F;
      field_base LINK_DISABLE15_F;
      field_base LINK_DISABLE16_F;
      field_base LINK_DISABLE17_F;
      field_base LINK_DISABLE18_F;
      field_base LINK_DISABLE19_F;
      field_base LINK_DISABLE20_F;
      field_base LINK_DISABLE21_F;
      field_base LINK_DISABLE22_F;
      field_base LINK_DISABLE23_F;
      field_base LINK_DISABLE24_F;
      field_base LINK_DISABLE25_F;
      field_base LINK_DISABLE26_F;
      field_base LINK_DISABLE27_F;
      field_base LINK_DISABLE28_F;
      field_base LINK_DISABLE29_F;
      field_base LINK_DISABLE30_F;
      field_base LINK_DISABLE31_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.LINK_DISABLE0_F = new("LINK_DISABLE0", 0, 0, RW, 'h0, this);
        this.LINK_DISABLE1_F = new("LINK_DISABLE1", 1, 1, RW, 'h0, this);
        this.LINK_DISABLE2_F = new("LINK_DISABLE2", 2, 2, RW, 'h0, this);
        this.LINK_DISABLE3_F = new("LINK_DISABLE3", 3, 3, RW, 'h0, this);
        this.LINK_DISABLE4_F = new("LINK_DISABLE4", 4, 4, RW, 'h0, this);
        this.LINK_DISABLE5_F = new("LINK_DISABLE5", 5, 5, RW, 'h0, this);
        this.LINK_DISABLE6_F = new("LINK_DISABLE6", 6, 6, RW, 'h0, this);
        this.LINK_DISABLE7_F = new("LINK_DISABLE7", 7, 7, RW, 'h0, this);
        this.LINK_DISABLE8_F = new("LINK_DISABLE8", 8, 8, RW, 'h0, this);
        this.LINK_DISABLE9_F = new("LINK_DISABLE9", 9, 9, RW, 'h0, this);
        this.LINK_DISABLE10_F = new("LINK_DISABLE10", 10, 10, RW, 'h0, this);
        this.LINK_DISABLE11_F = new("LINK_DISABLE11", 11, 11, RW, 'h0, this);
        this.LINK_DISABLE12_F = new("LINK_DISABLE12", 12, 12, RW, 'h0, this);
        this.LINK_DISABLE13_F = new("LINK_DISABLE13", 13, 13, RW, 'h0, this);
        this.LINK_DISABLE14_F = new("LINK_DISABLE14", 14, 14, RW, 'h0, this);
        this.LINK_DISABLE15_F = new("LINK_DISABLE15", 15, 15, RW, 'h0, this);
        this.LINK_DISABLE16_F = new("LINK_DISABLE16", 16, 16, RW, 'h0, this);
        this.LINK_DISABLE17_F = new("LINK_DISABLE17", 17, 17, RW, 'h0, this);
        this.LINK_DISABLE18_F = new("LINK_DISABLE18", 18, 18, RW, 'h0, this);
        this.LINK_DISABLE19_F = new("LINK_DISABLE19", 19, 19, RW, 'h0, this);
        this.LINK_DISABLE20_F = new("LINK_DISABLE20", 20, 20, RW, 'h0, this);
        this.LINK_DISABLE21_F = new("LINK_DISABLE21", 21, 21, RW, 'h0, this);
        this.LINK_DISABLE22_F = new("LINK_DISABLE22", 22, 22, RW, 'h0, this);
        this.LINK_DISABLE23_F = new("LINK_DISABLE23", 23, 23, RW, 'h0, this);
        this.LINK_DISABLE24_F = new("LINK_DISABLE24", 24, 24, RW, 'h0, this);
        this.LINK_DISABLE25_F = new("LINK_DISABLE25", 25, 25, RW, 'h0, this);
        this.LINK_DISABLE26_F = new("LINK_DISABLE26", 26, 26, RW, 'h0, this);
        this.LINK_DISABLE27_F = new("LINK_DISABLE27", 27, 27, RW, 'h0, this);
        this.LINK_DISABLE28_F = new("LINK_DISABLE28", 28, 28, RW, 'h0, this);
        this.LINK_DISABLE29_F = new("LINK_DISABLE29", 29, 29, RW, 'h0, this);
        this.LINK_DISABLE30_F = new("LINK_DISABLE30", 30, 30, RW, 'h0, this);
        this.LINK_DISABLE31_F = new("LINK_DISABLE31", 31, 31, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: MULTI_LINK_DISABLE_CLASS

    class LINK_CONF4_CLASS extends register_base;
      field_base TPL_BEATS_PER_MULTIFRAME_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TPL_BEATS_PER_MULTIFRAME_F = new("TPL_BEATS_PER_MULTIFRAME", 7, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LINK_CONF4_CLASS

    class LINK_CONF2_CLASS extends register_base;
      field_base BUFFER_EARLY_RELEASE_F;
      field_base BUFFER_DELAY_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.BUFFER_EARLY_RELEASE_F = new("BUFFER_EARLY_RELEASE", 16, 16, RW, 'h0, this);
        this.BUFFER_DELAY_F = new("BUFFER_DELAY", 9, 2, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LINK_CONF2_CLASS

    class LINK_CONF3_CLASS extends register_base;
      field_base MASK_INVALID_HEADER_F;
      field_base MASK_UNEXPECTED_EOMB_F;
      field_base MASK_UNEXPECTED_EOEMB_F;
      field_base MASK_CRC_MISMATCH_F;
      field_base MASK_UNEXPECTEDK_F;
      field_base MASK_NOTINTABLE_F;
      field_base MASK_DISPERR_F;
      field_base RESET_COUNTER_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.MASK_INVALID_HEADER_F = new("MASK_INVALID_HEADER", 14, 14, RW, 'h0, this);
        this.MASK_UNEXPECTED_EOMB_F = new("MASK_UNEXPECTED_EOMB", 13, 13, RW, 'h0, this);
        this.MASK_UNEXPECTED_EOEMB_F = new("MASK_UNEXPECTED_EOEMB", 12, 12, RW, 'h0, this);
        this.MASK_CRC_MISMATCH_F = new("MASK_CRC_MISMATCH", 11, 11, RW, 'h0, this);
        this.MASK_UNEXPECTEDK_F = new("MASK_UNEXPECTEDK", 10, 10, RW, 'h0, this);
        this.MASK_NOTINTABLE_F = new("MASK_NOTINTABLE", 9, 9, RW, 'h0, this);
        this.MASK_DISPERR_F = new("MASK_DISPERR", 8, 8, RW, 'h0, this);
        this.RESET_COUNTER_F = new("RESET_COUNTER", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LINK_CONF3_CLASS

    class LINK_STATUS_CLASS extends register_base;
      field_base STATUS_STATE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.STATUS_STATE_F = new("STATUS_STATE", 1, 0, ROV, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LINK_STATUS_CLASS

    class LANEn_STATUS_CLASS extends register_base;
      field_base EMB_STATE_F;
      field_base ILAS_READY_F;
      field_base IFS_READY_F;
      field_base CGS_STATE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.EMB_STATE_F = new("EMB_STATE", 10, 8, RO, 'h0, this);
        this.ILAS_READY_F = new("ILAS_READY", 5, 5, ROV, 'h0, this);
        this.IFS_READY_F = new("IFS_READY", 4, 4, ROV, 'h0, this);
        this.CGS_STATE_F = new("CGS_STATE", 1, 0, ROV, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LANEn_STATUS_CLASS

    class LANEn_LATENCY_CLASS extends register_base;
      field_base LATENCY_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.LATENCY_F = new("LATENCY", 13, 0, ROV, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LANEn_LATENCY_CLASS

    class LANEn_ERROR_STATISTICS_CLASS extends register_base;
      field_base ERROR_REGISTER_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ERROR_REGISTER_F = new("ERROR_REGISTER", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LANEn_ERROR_STATISTICS_CLASS

    class LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS extends register_base;
      field_base ERROR_REGISTER_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ERROR_REGISTER_F = new("ERROR_REGISTER", 7, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS

    class LANEn_ILAS0_CLASS extends register_base;
      field_base BID_F;
      field_base DID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.BID_F = new("BID", 27, 24, RO, 'h0, this);
        this.DID_F = new("DID", 23, 16, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LANEn_ILAS0_CLASS

    class LANEn_ILAS1_CLASS extends register_base;
      field_base K_F;
      field_base F_F;
      field_base SCR_F;
      field_base L_F;
      field_base LID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.K_F = new("K", 28, 24, RO, 'h0, this);
        this.F_F = new("F", 23, 16, RO, 'h0, this);
        this.SCR_F = new("SCR", 15, 15, RO, 'h0, this);
        this.L_F = new("L", 12, 8, RO, 'h0, this);
        this.LID_F = new("LID", 4, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LANEn_ILAS1_CLASS

    class LANEn_ILAS2_CLASS extends register_base;
      field_base JESDV_F;
      field_base S_F;
      field_base SUBCLASSV_F;
      field_base NP_F;
      field_base CS_F;
      field_base N_F;
      field_base M_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.JESDV_F = new("JESDV", 31, 29, RO, 'h0, this);
        this.S_F = new("S", 28, 24, RO, 'h0, this);
        this.SUBCLASSV_F = new("SUBCLASSV", 23, 21, RO, 'h0, this);
        this.NP_F = new("NP", 20, 16, RO, 'h0, this);
        this.CS_F = new("CS", 15, 14, RO, 'h0, this);
        this.N_F = new("N", 12, 8, RO, 'h0, this);
        this.M_F = new("M", 7, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LANEn_ILAS2_CLASS

    class LANEn_ILAS3_CLASS extends register_base;
      field_base FCHK_F;
      field_base HD_F;
      field_base CF_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FCHK_F = new("FCHK", 31, 24, RO, 'h0, this);
        this.HD_F = new("HD", 7, 7, RO, 'h0, this);
        this.CF_F = new("CF", 4, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LANEn_ILAS3_CLASS

    VERSION_CLASS VERSION_R;
    PERIPHERAL_ID_CLASS PERIPHERAL_ID_R;
    SCRATCH_CLASS SCRATCH_R;
    IDENTIFICATION_CLASS IDENTIFICATION_R;
    SYNTH_NUM_LANES_CLASS SYNTH_NUM_LANES_R;
    SYNTH_DATA_PATH_WIDTH_CLASS SYNTH_DATA_PATH_WIDTH_R;
    SYNTH_1_CLASS SYNTH_1_R;
    SYNTH_ELASTIC_BUFFER_SIZE_CLASS SYNTH_ELASTIC_BUFFER_SIZE_R;
    IRQ_ENABLE_CLASS IRQ_ENABLE_R;
    IRQ_PENDING_CLASS IRQ_PENDING_R;
    IRQ_SOURCE_CLASS IRQ_SOURCE_R;
    LINK_DISABLE_CLASS LINK_DISABLE_R;
    LINK_STATE_CLASS LINK_STATE_R;
    LINK_CLK_FREQ_CLASS LINK_CLK_FREQ_R;
    DEVICE_CLK_FREQ_CLASS DEVICE_CLK_FREQ_R;
    SYSREF_CONF_CLASS SYSREF_CONF_R;
    SYSREF_LMFC_OFFSET_CLASS SYSREF_LMFC_OFFSET_R;
    SYSREF_STATUS_CLASS SYSREF_STATUS_R;
    LANES_DISABLE_CLASS LANES_DISABLE_R;
    LINK_CONF0_CLASS LINK_CONF0_R;
    LINK_CONF1_CLASS LINK_CONF1_R;
    MULTI_LINK_DISABLE_CLASS MULTI_LINK_DISABLE_R;
    LINK_CONF4_CLASS LINK_CONF4_R;
    LINK_CONF2_CLASS LINK_CONF2_R;
    LINK_CONF3_CLASS LINK_CONF3_R;
    LINK_STATUS_CLASS LINK_STATUS_R;
    LANEn_STATUS_CLASS LANE0_STATUS_R;
    LANEn_STATUS_CLASS LANE1_STATUS_R;
    LANEn_STATUS_CLASS LANE2_STATUS_R;
    LANEn_STATUS_CLASS LANE3_STATUS_R;
    LANEn_STATUS_CLASS LANE4_STATUS_R;
    LANEn_STATUS_CLASS LANE5_STATUS_R;
    LANEn_STATUS_CLASS LANE6_STATUS_R;
    LANEn_STATUS_CLASS LANE7_STATUS_R;
    LANEn_STATUS_CLASS LANE8_STATUS_R;
    LANEn_STATUS_CLASS LANE9_STATUS_R;
    LANEn_STATUS_CLASS LANE10_STATUS_R;
    LANEn_STATUS_CLASS LANE11_STATUS_R;
    LANEn_STATUS_CLASS LANE12_STATUS_R;
    LANEn_STATUS_CLASS LANE13_STATUS_R;
    LANEn_STATUS_CLASS LANE14_STATUS_R;
    LANEn_STATUS_CLASS LANE15_STATUS_R;
    LANEn_STATUS_CLASS LANE16_STATUS_R;
    LANEn_STATUS_CLASS LANE17_STATUS_R;
    LANEn_STATUS_CLASS LANE18_STATUS_R;
    LANEn_STATUS_CLASS LANE19_STATUS_R;
    LANEn_STATUS_CLASS LANE20_STATUS_R;
    LANEn_STATUS_CLASS LANE21_STATUS_R;
    LANEn_STATUS_CLASS LANE22_STATUS_R;
    LANEn_STATUS_CLASS LANE23_STATUS_R;
    LANEn_STATUS_CLASS LANE24_STATUS_R;
    LANEn_STATUS_CLASS LANE25_STATUS_R;
    LANEn_STATUS_CLASS LANE26_STATUS_R;
    LANEn_STATUS_CLASS LANE27_STATUS_R;
    LANEn_STATUS_CLASS LANE28_STATUS_R;
    LANEn_STATUS_CLASS LANE29_STATUS_R;
    LANEn_STATUS_CLASS LANE30_STATUS_R;
    LANEn_STATUS_CLASS LANE31_STATUS_R;
    LANEn_LATENCY_CLASS LANE0_LATENCY_R;
    LANEn_LATENCY_CLASS LANE1_LATENCY_R;
    LANEn_LATENCY_CLASS LANE2_LATENCY_R;
    LANEn_LATENCY_CLASS LANE3_LATENCY_R;
    LANEn_LATENCY_CLASS LANE4_LATENCY_R;
    LANEn_LATENCY_CLASS LANE5_LATENCY_R;
    LANEn_LATENCY_CLASS LANE6_LATENCY_R;
    LANEn_LATENCY_CLASS LANE7_LATENCY_R;
    LANEn_LATENCY_CLASS LANE8_LATENCY_R;
    LANEn_LATENCY_CLASS LANE9_LATENCY_R;
    LANEn_LATENCY_CLASS LANE10_LATENCY_R;
    LANEn_LATENCY_CLASS LANE11_LATENCY_R;
    LANEn_LATENCY_CLASS LANE12_LATENCY_R;
    LANEn_LATENCY_CLASS LANE13_LATENCY_R;
    LANEn_LATENCY_CLASS LANE14_LATENCY_R;
    LANEn_LATENCY_CLASS LANE15_LATENCY_R;
    LANEn_LATENCY_CLASS LANE16_LATENCY_R;
    LANEn_LATENCY_CLASS LANE17_LATENCY_R;
    LANEn_LATENCY_CLASS LANE18_LATENCY_R;
    LANEn_LATENCY_CLASS LANE19_LATENCY_R;
    LANEn_LATENCY_CLASS LANE20_LATENCY_R;
    LANEn_LATENCY_CLASS LANE21_LATENCY_R;
    LANEn_LATENCY_CLASS LANE22_LATENCY_R;
    LANEn_LATENCY_CLASS LANE23_LATENCY_R;
    LANEn_LATENCY_CLASS LANE24_LATENCY_R;
    LANEn_LATENCY_CLASS LANE25_LATENCY_R;
    LANEn_LATENCY_CLASS LANE26_LATENCY_R;
    LANEn_LATENCY_CLASS LANE27_LATENCY_R;
    LANEn_LATENCY_CLASS LANE28_LATENCY_R;
    LANEn_LATENCY_CLASS LANE29_LATENCY_R;
    LANEn_LATENCY_CLASS LANE30_LATENCY_R;
    LANEn_LATENCY_CLASS LANE31_LATENCY_R;
    LANEn_ERROR_STATISTICS_CLASS LANE0_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE1_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE2_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE3_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE4_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE5_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE6_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE7_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE8_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE9_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE10_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE11_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE12_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE13_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE14_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE15_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE16_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE17_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE18_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE19_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE20_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE21_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE22_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE23_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE24_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE25_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE26_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE27_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE28_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE29_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE30_ERROR_STATISTICS_R;
    LANEn_ERROR_STATISTICS_CLASS LANE31_ERROR_STATISTICS_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE0_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE1_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE2_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE3_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE4_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE5_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE6_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE7_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE8_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE9_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE10_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE11_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE12_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE13_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE14_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE15_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE16_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE17_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE18_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE19_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE20_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE21_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE22_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE23_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE24_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE25_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE26_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE27_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE28_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE29_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE30_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANE31_LANE_FRAME_ALIGN_ERR_CNT_R;
    LANEn_ILAS0_CLASS LANE0_ILAS0_R;
    LANEn_ILAS0_CLASS LANE1_ILAS0_R;
    LANEn_ILAS0_CLASS LANE2_ILAS0_R;
    LANEn_ILAS0_CLASS LANE3_ILAS0_R;
    LANEn_ILAS0_CLASS LANE4_ILAS0_R;
    LANEn_ILAS0_CLASS LANE5_ILAS0_R;
    LANEn_ILAS0_CLASS LANE6_ILAS0_R;
    LANEn_ILAS0_CLASS LANE7_ILAS0_R;
    LANEn_ILAS0_CLASS LANE8_ILAS0_R;
    LANEn_ILAS0_CLASS LANE9_ILAS0_R;
    LANEn_ILAS0_CLASS LANE10_ILAS0_R;
    LANEn_ILAS0_CLASS LANE11_ILAS0_R;
    LANEn_ILAS0_CLASS LANE12_ILAS0_R;
    LANEn_ILAS0_CLASS LANE13_ILAS0_R;
    LANEn_ILAS0_CLASS LANE14_ILAS0_R;
    LANEn_ILAS0_CLASS LANE15_ILAS0_R;
    LANEn_ILAS0_CLASS LANE16_ILAS0_R;
    LANEn_ILAS0_CLASS LANE17_ILAS0_R;
    LANEn_ILAS0_CLASS LANE18_ILAS0_R;
    LANEn_ILAS0_CLASS LANE19_ILAS0_R;
    LANEn_ILAS0_CLASS LANE20_ILAS0_R;
    LANEn_ILAS0_CLASS LANE21_ILAS0_R;
    LANEn_ILAS0_CLASS LANE22_ILAS0_R;
    LANEn_ILAS0_CLASS LANE23_ILAS0_R;
    LANEn_ILAS0_CLASS LANE24_ILAS0_R;
    LANEn_ILAS0_CLASS LANE25_ILAS0_R;
    LANEn_ILAS0_CLASS LANE26_ILAS0_R;
    LANEn_ILAS0_CLASS LANE27_ILAS0_R;
    LANEn_ILAS0_CLASS LANE28_ILAS0_R;
    LANEn_ILAS0_CLASS LANE29_ILAS0_R;
    LANEn_ILAS0_CLASS LANE30_ILAS0_R;
    LANEn_ILAS0_CLASS LANE31_ILAS0_R;
    LANEn_ILAS1_CLASS LANE0_ILAS1_R;
    LANEn_ILAS1_CLASS LANE1_ILAS1_R;
    LANEn_ILAS1_CLASS LANE2_ILAS1_R;
    LANEn_ILAS1_CLASS LANE3_ILAS1_R;
    LANEn_ILAS1_CLASS LANE4_ILAS1_R;
    LANEn_ILAS1_CLASS LANE5_ILAS1_R;
    LANEn_ILAS1_CLASS LANE6_ILAS1_R;
    LANEn_ILAS1_CLASS LANE7_ILAS1_R;
    LANEn_ILAS1_CLASS LANE8_ILAS1_R;
    LANEn_ILAS1_CLASS LANE9_ILAS1_R;
    LANEn_ILAS1_CLASS LANE10_ILAS1_R;
    LANEn_ILAS1_CLASS LANE11_ILAS1_R;
    LANEn_ILAS1_CLASS LANE12_ILAS1_R;
    LANEn_ILAS1_CLASS LANE13_ILAS1_R;
    LANEn_ILAS1_CLASS LANE14_ILAS1_R;
    LANEn_ILAS1_CLASS LANE15_ILAS1_R;
    LANEn_ILAS1_CLASS LANE16_ILAS1_R;
    LANEn_ILAS1_CLASS LANE17_ILAS1_R;
    LANEn_ILAS1_CLASS LANE18_ILAS1_R;
    LANEn_ILAS1_CLASS LANE19_ILAS1_R;
    LANEn_ILAS1_CLASS LANE20_ILAS1_R;
    LANEn_ILAS1_CLASS LANE21_ILAS1_R;
    LANEn_ILAS1_CLASS LANE22_ILAS1_R;
    LANEn_ILAS1_CLASS LANE23_ILAS1_R;
    LANEn_ILAS1_CLASS LANE24_ILAS1_R;
    LANEn_ILAS1_CLASS LANE25_ILAS1_R;
    LANEn_ILAS1_CLASS LANE26_ILAS1_R;
    LANEn_ILAS1_CLASS LANE27_ILAS1_R;
    LANEn_ILAS1_CLASS LANE28_ILAS1_R;
    LANEn_ILAS1_CLASS LANE29_ILAS1_R;
    LANEn_ILAS1_CLASS LANE30_ILAS1_R;
    LANEn_ILAS1_CLASS LANE31_ILAS1_R;
    LANEn_ILAS2_CLASS LANE0_ILAS2_R;
    LANEn_ILAS2_CLASS LANE1_ILAS2_R;
    LANEn_ILAS2_CLASS LANE2_ILAS2_R;
    LANEn_ILAS2_CLASS LANE3_ILAS2_R;
    LANEn_ILAS2_CLASS LANE4_ILAS2_R;
    LANEn_ILAS2_CLASS LANE5_ILAS2_R;
    LANEn_ILAS2_CLASS LANE6_ILAS2_R;
    LANEn_ILAS2_CLASS LANE7_ILAS2_R;
    LANEn_ILAS2_CLASS LANE8_ILAS2_R;
    LANEn_ILAS2_CLASS LANE9_ILAS2_R;
    LANEn_ILAS2_CLASS LANE10_ILAS2_R;
    LANEn_ILAS2_CLASS LANE11_ILAS2_R;
    LANEn_ILAS2_CLASS LANE12_ILAS2_R;
    LANEn_ILAS2_CLASS LANE13_ILAS2_R;
    LANEn_ILAS2_CLASS LANE14_ILAS2_R;
    LANEn_ILAS2_CLASS LANE15_ILAS2_R;
    LANEn_ILAS2_CLASS LANE16_ILAS2_R;
    LANEn_ILAS2_CLASS LANE17_ILAS2_R;
    LANEn_ILAS2_CLASS LANE18_ILAS2_R;
    LANEn_ILAS2_CLASS LANE19_ILAS2_R;
    LANEn_ILAS2_CLASS LANE20_ILAS2_R;
    LANEn_ILAS2_CLASS LANE21_ILAS2_R;
    LANEn_ILAS2_CLASS LANE22_ILAS2_R;
    LANEn_ILAS2_CLASS LANE23_ILAS2_R;
    LANEn_ILAS2_CLASS LANE24_ILAS2_R;
    LANEn_ILAS2_CLASS LANE25_ILAS2_R;
    LANEn_ILAS2_CLASS LANE26_ILAS2_R;
    LANEn_ILAS2_CLASS LANE27_ILAS2_R;
    LANEn_ILAS2_CLASS LANE28_ILAS2_R;
    LANEn_ILAS2_CLASS LANE29_ILAS2_R;
    LANEn_ILAS2_CLASS LANE30_ILAS2_R;
    LANEn_ILAS2_CLASS LANE31_ILAS2_R;
    LANEn_ILAS3_CLASS LANE0_ILAS3_R;
    LANEn_ILAS3_CLASS LANE1_ILAS3_R;
    LANEn_ILAS3_CLASS LANE2_ILAS3_R;
    LANEn_ILAS3_CLASS LANE3_ILAS3_R;
    LANEn_ILAS3_CLASS LANE4_ILAS3_R;
    LANEn_ILAS3_CLASS LANE5_ILAS3_R;
    LANEn_ILAS3_CLASS LANE6_ILAS3_R;
    LANEn_ILAS3_CLASS LANE7_ILAS3_R;
    LANEn_ILAS3_CLASS LANE8_ILAS3_R;
    LANEn_ILAS3_CLASS LANE9_ILAS3_R;
    LANEn_ILAS3_CLASS LANE10_ILAS3_R;
    LANEn_ILAS3_CLASS LANE11_ILAS3_R;
    LANEn_ILAS3_CLASS LANE12_ILAS3_R;
    LANEn_ILAS3_CLASS LANE13_ILAS3_R;
    LANEn_ILAS3_CLASS LANE14_ILAS3_R;
    LANEn_ILAS3_CLASS LANE15_ILAS3_R;
    LANEn_ILAS3_CLASS LANE16_ILAS3_R;
    LANEn_ILAS3_CLASS LANE17_ILAS3_R;
    LANEn_ILAS3_CLASS LANE18_ILAS3_R;
    LANEn_ILAS3_CLASS LANE19_ILAS3_R;
    LANEn_ILAS3_CLASS LANE20_ILAS3_R;
    LANEn_ILAS3_CLASS LANE21_ILAS3_R;
    LANEn_ILAS3_CLASS LANE22_ILAS3_R;
    LANEn_ILAS3_CLASS LANE23_ILAS3_R;
    LANEn_ILAS3_CLASS LANE24_ILAS3_R;
    LANEn_ILAS3_CLASS LANE25_ILAS3_R;
    LANEn_ILAS3_CLASS LANE26_ILAS3_R;
    LANEn_ILAS3_CLASS LANE27_ILAS3_R;
    LANEn_ILAS3_CLASS LANE28_ILAS3_R;
    LANEn_ILAS3_CLASS LANE29_ILAS3_R;
    LANEn_ILAS3_CLASS LANE30_ILAS3_R;
    LANEn_ILAS3_CLASS LANE31_ILAS3_R;

    function new(
      input string name,
      input int address,
      input int ASYNC_CLK,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.PERIPHERAL_ID_R = new("PERIPHERAL_ID", 'h4, this);
      this.SCRATCH_R = new("SCRATCH", 'h8, this);
      this.IDENTIFICATION_R = new("IDENTIFICATION", 'hc, this);
      this.SYNTH_NUM_LANES_R = new("SYNTH_NUM_LANES", 'h10, this);
      this.SYNTH_DATA_PATH_WIDTH_R = new("SYNTH_DATA_PATH_WIDTH", 'h14, this);
      this.SYNTH_1_R = new("SYNTH_1", 'h18, ASYNC_CLK, this);
      this.SYNTH_ELASTIC_BUFFER_SIZE_R = new("SYNTH_ELASTIC_BUFFER_SIZE", 'h40, this);
      this.IRQ_ENABLE_R = new("IRQ_ENABLE", 'h80, this);
      this.IRQ_PENDING_R = new("IRQ_PENDING", 'h84, this);
      this.IRQ_SOURCE_R = new("IRQ_SOURCE", 'h88, this);
      this.LINK_DISABLE_R = new("LINK_DISABLE", 'hc0, this);
      this.LINK_STATE_R = new("LINK_STATE", 'hc4, this);
      this.LINK_CLK_FREQ_R = new("LINK_CLK_FREQ", 'hc8, this);
      this.DEVICE_CLK_FREQ_R = new("DEVICE_CLK_FREQ", 'hcc, this);
      this.SYSREF_CONF_R = new("SYSREF_CONF", 'h100, this);
      this.SYSREF_LMFC_OFFSET_R = new("SYSREF_LMFC_OFFSET", 'h104, this);
      this.SYSREF_STATUS_R = new("SYSREF_STATUS", 'h108, this);
      this.LANES_DISABLE_R = new("LANES_DISABLE", 'h200, this);
      this.LINK_CONF0_R = new("LINK_CONF0", 'h210, this);
      this.LINK_CONF1_R = new("LINK_CONF1", 'h214, this);
      this.MULTI_LINK_DISABLE_R = new("MULTI_LINK_DISABLE", 'h218, this);
      this.LINK_CONF4_R = new("LINK_CONF4", 'h21c, this);
      this.LINK_CONF2_R = new("LINK_CONF2", 'h240, this);
      this.LINK_CONF3_R = new("LINK_CONF3", 'h244, this);
      this.LINK_STATUS_R = new("LINK_STATUS", 'h280, this);
      this.LANE0_STATUS_R = new("LANE0_STATUS", 'h300, this);
      this.LANE1_STATUS_R = new("LANE1_STATUS", 'h320, this);
      this.LANE2_STATUS_R = new("LANE2_STATUS", 'h340, this);
      this.LANE3_STATUS_R = new("LANE3_STATUS", 'h360, this);
      this.LANE4_STATUS_R = new("LANE4_STATUS", 'h380, this);
      this.LANE5_STATUS_R = new("LANE5_STATUS", 'h3a0, this);
      this.LANE6_STATUS_R = new("LANE6_STATUS", 'h3c0, this);
      this.LANE7_STATUS_R = new("LANE7_STATUS", 'h3e0, this);
      this.LANE8_STATUS_R = new("LANE8_STATUS", 'h400, this);
      this.LANE9_STATUS_R = new("LANE9_STATUS", 'h420, this);
      this.LANE10_STATUS_R = new("LANE10_STATUS", 'h440, this);
      this.LANE11_STATUS_R = new("LANE11_STATUS", 'h460, this);
      this.LANE12_STATUS_R = new("LANE12_STATUS", 'h480, this);
      this.LANE13_STATUS_R = new("LANE13_STATUS", 'h4a0, this);
      this.LANE14_STATUS_R = new("LANE14_STATUS", 'h4c0, this);
      this.LANE15_STATUS_R = new("LANE15_STATUS", 'h4e0, this);
      this.LANE16_STATUS_R = new("LANE16_STATUS", 'h500, this);
      this.LANE17_STATUS_R = new("LANE17_STATUS", 'h520, this);
      this.LANE18_STATUS_R = new("LANE18_STATUS", 'h540, this);
      this.LANE19_STATUS_R = new("LANE19_STATUS", 'h560, this);
      this.LANE20_STATUS_R = new("LANE20_STATUS", 'h580, this);
      this.LANE21_STATUS_R = new("LANE21_STATUS", 'h5a0, this);
      this.LANE22_STATUS_R = new("LANE22_STATUS", 'h5c0, this);
      this.LANE23_STATUS_R = new("LANE23_STATUS", 'h5e0, this);
      this.LANE24_STATUS_R = new("LANE24_STATUS", 'h600, this);
      this.LANE25_STATUS_R = new("LANE25_STATUS", 'h620, this);
      this.LANE26_STATUS_R = new("LANE26_STATUS", 'h640, this);
      this.LANE27_STATUS_R = new("LANE27_STATUS", 'h660, this);
      this.LANE28_STATUS_R = new("LANE28_STATUS", 'h680, this);
      this.LANE29_STATUS_R = new("LANE29_STATUS", 'h6a0, this);
      this.LANE30_STATUS_R = new("LANE30_STATUS", 'h6c0, this);
      this.LANE31_STATUS_R = new("LANE31_STATUS", 'h6e0, this);
      this.LANE0_LATENCY_R = new("LANE0_LATENCY", 'h304, this);
      this.LANE1_LATENCY_R = new("LANE1_LATENCY", 'h324, this);
      this.LANE2_LATENCY_R = new("LANE2_LATENCY", 'h344, this);
      this.LANE3_LATENCY_R = new("LANE3_LATENCY", 'h364, this);
      this.LANE4_LATENCY_R = new("LANE4_LATENCY", 'h384, this);
      this.LANE5_LATENCY_R = new("LANE5_LATENCY", 'h3a4, this);
      this.LANE6_LATENCY_R = new("LANE6_LATENCY", 'h3c4, this);
      this.LANE7_LATENCY_R = new("LANE7_LATENCY", 'h3e4, this);
      this.LANE8_LATENCY_R = new("LANE8_LATENCY", 'h404, this);
      this.LANE9_LATENCY_R = new("LANE9_LATENCY", 'h424, this);
      this.LANE10_LATENCY_R = new("LANE10_LATENCY", 'h444, this);
      this.LANE11_LATENCY_R = new("LANE11_LATENCY", 'h464, this);
      this.LANE12_LATENCY_R = new("LANE12_LATENCY", 'h484, this);
      this.LANE13_LATENCY_R = new("LANE13_LATENCY", 'h4a4, this);
      this.LANE14_LATENCY_R = new("LANE14_LATENCY", 'h4c4, this);
      this.LANE15_LATENCY_R = new("LANE15_LATENCY", 'h4e4, this);
      this.LANE16_LATENCY_R = new("LANE16_LATENCY", 'h504, this);
      this.LANE17_LATENCY_R = new("LANE17_LATENCY", 'h524, this);
      this.LANE18_LATENCY_R = new("LANE18_LATENCY", 'h544, this);
      this.LANE19_LATENCY_R = new("LANE19_LATENCY", 'h564, this);
      this.LANE20_LATENCY_R = new("LANE20_LATENCY", 'h584, this);
      this.LANE21_LATENCY_R = new("LANE21_LATENCY", 'h5a4, this);
      this.LANE22_LATENCY_R = new("LANE22_LATENCY", 'h5c4, this);
      this.LANE23_LATENCY_R = new("LANE23_LATENCY", 'h5e4, this);
      this.LANE24_LATENCY_R = new("LANE24_LATENCY", 'h604, this);
      this.LANE25_LATENCY_R = new("LANE25_LATENCY", 'h624, this);
      this.LANE26_LATENCY_R = new("LANE26_LATENCY", 'h644, this);
      this.LANE27_LATENCY_R = new("LANE27_LATENCY", 'h664, this);
      this.LANE28_LATENCY_R = new("LANE28_LATENCY", 'h684, this);
      this.LANE29_LATENCY_R = new("LANE29_LATENCY", 'h6a4, this);
      this.LANE30_LATENCY_R = new("LANE30_LATENCY", 'h6c4, this);
      this.LANE31_LATENCY_R = new("LANE31_LATENCY", 'h6e4, this);
      this.LANE0_ERROR_STATISTICS_R = new("LANE0_ERROR_STATISTICS", 'h308, this);
      this.LANE1_ERROR_STATISTICS_R = new("LANE1_ERROR_STATISTICS", 'h328, this);
      this.LANE2_ERROR_STATISTICS_R = new("LANE2_ERROR_STATISTICS", 'h348, this);
      this.LANE3_ERROR_STATISTICS_R = new("LANE3_ERROR_STATISTICS", 'h368, this);
      this.LANE4_ERROR_STATISTICS_R = new("LANE4_ERROR_STATISTICS", 'h388, this);
      this.LANE5_ERROR_STATISTICS_R = new("LANE5_ERROR_STATISTICS", 'h3a8, this);
      this.LANE6_ERROR_STATISTICS_R = new("LANE6_ERROR_STATISTICS", 'h3c8, this);
      this.LANE7_ERROR_STATISTICS_R = new("LANE7_ERROR_STATISTICS", 'h3e8, this);
      this.LANE8_ERROR_STATISTICS_R = new("LANE8_ERROR_STATISTICS", 'h408, this);
      this.LANE9_ERROR_STATISTICS_R = new("LANE9_ERROR_STATISTICS", 'h428, this);
      this.LANE10_ERROR_STATISTICS_R = new("LANE10_ERROR_STATISTICS", 'h448, this);
      this.LANE11_ERROR_STATISTICS_R = new("LANE11_ERROR_STATISTICS", 'h468, this);
      this.LANE12_ERROR_STATISTICS_R = new("LANE12_ERROR_STATISTICS", 'h488, this);
      this.LANE13_ERROR_STATISTICS_R = new("LANE13_ERROR_STATISTICS", 'h4a8, this);
      this.LANE14_ERROR_STATISTICS_R = new("LANE14_ERROR_STATISTICS", 'h4c8, this);
      this.LANE15_ERROR_STATISTICS_R = new("LANE15_ERROR_STATISTICS", 'h4e8, this);
      this.LANE16_ERROR_STATISTICS_R = new("LANE16_ERROR_STATISTICS", 'h508, this);
      this.LANE17_ERROR_STATISTICS_R = new("LANE17_ERROR_STATISTICS", 'h528, this);
      this.LANE18_ERROR_STATISTICS_R = new("LANE18_ERROR_STATISTICS", 'h548, this);
      this.LANE19_ERROR_STATISTICS_R = new("LANE19_ERROR_STATISTICS", 'h568, this);
      this.LANE20_ERROR_STATISTICS_R = new("LANE20_ERROR_STATISTICS", 'h588, this);
      this.LANE21_ERROR_STATISTICS_R = new("LANE21_ERROR_STATISTICS", 'h5a8, this);
      this.LANE22_ERROR_STATISTICS_R = new("LANE22_ERROR_STATISTICS", 'h5c8, this);
      this.LANE23_ERROR_STATISTICS_R = new("LANE23_ERROR_STATISTICS", 'h5e8, this);
      this.LANE24_ERROR_STATISTICS_R = new("LANE24_ERROR_STATISTICS", 'h608, this);
      this.LANE25_ERROR_STATISTICS_R = new("LANE25_ERROR_STATISTICS", 'h628, this);
      this.LANE26_ERROR_STATISTICS_R = new("LANE26_ERROR_STATISTICS", 'h648, this);
      this.LANE27_ERROR_STATISTICS_R = new("LANE27_ERROR_STATISTICS", 'h668, this);
      this.LANE28_ERROR_STATISTICS_R = new("LANE28_ERROR_STATISTICS", 'h688, this);
      this.LANE29_ERROR_STATISTICS_R = new("LANE29_ERROR_STATISTICS", 'h6a8, this);
      this.LANE30_ERROR_STATISTICS_R = new("LANE30_ERROR_STATISTICS", 'h6c8, this);
      this.LANE31_ERROR_STATISTICS_R = new("LANE31_ERROR_STATISTICS", 'h6e8, this);
      this.LANE0_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE0_LANE_FRAME_ALIGN_ERR_CNT", 'h30c, this);
      this.LANE1_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE1_LANE_FRAME_ALIGN_ERR_CNT", 'h32c, this);
      this.LANE2_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE2_LANE_FRAME_ALIGN_ERR_CNT", 'h34c, this);
      this.LANE3_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE3_LANE_FRAME_ALIGN_ERR_CNT", 'h36c, this);
      this.LANE4_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE4_LANE_FRAME_ALIGN_ERR_CNT", 'h38c, this);
      this.LANE5_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE5_LANE_FRAME_ALIGN_ERR_CNT", 'h3ac, this);
      this.LANE6_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE6_LANE_FRAME_ALIGN_ERR_CNT", 'h3cc, this);
      this.LANE7_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE7_LANE_FRAME_ALIGN_ERR_CNT", 'h3ec, this);
      this.LANE8_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE8_LANE_FRAME_ALIGN_ERR_CNT", 'h40c, this);
      this.LANE9_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE9_LANE_FRAME_ALIGN_ERR_CNT", 'h42c, this);
      this.LANE10_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE10_LANE_FRAME_ALIGN_ERR_CNT", 'h44c, this);
      this.LANE11_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE11_LANE_FRAME_ALIGN_ERR_CNT", 'h46c, this);
      this.LANE12_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE12_LANE_FRAME_ALIGN_ERR_CNT", 'h48c, this);
      this.LANE13_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE13_LANE_FRAME_ALIGN_ERR_CNT", 'h4ac, this);
      this.LANE14_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE14_LANE_FRAME_ALIGN_ERR_CNT", 'h4cc, this);
      this.LANE15_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE15_LANE_FRAME_ALIGN_ERR_CNT", 'h4ec, this);
      this.LANE16_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE16_LANE_FRAME_ALIGN_ERR_CNT", 'h50c, this);
      this.LANE17_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE17_LANE_FRAME_ALIGN_ERR_CNT", 'h52c, this);
      this.LANE18_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE18_LANE_FRAME_ALIGN_ERR_CNT", 'h54c, this);
      this.LANE19_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE19_LANE_FRAME_ALIGN_ERR_CNT", 'h56c, this);
      this.LANE20_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE20_LANE_FRAME_ALIGN_ERR_CNT", 'h58c, this);
      this.LANE21_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE21_LANE_FRAME_ALIGN_ERR_CNT", 'h5ac, this);
      this.LANE22_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE22_LANE_FRAME_ALIGN_ERR_CNT", 'h5cc, this);
      this.LANE23_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE23_LANE_FRAME_ALIGN_ERR_CNT", 'h5ec, this);
      this.LANE24_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE24_LANE_FRAME_ALIGN_ERR_CNT", 'h60c, this);
      this.LANE25_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE25_LANE_FRAME_ALIGN_ERR_CNT", 'h62c, this);
      this.LANE26_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE26_LANE_FRAME_ALIGN_ERR_CNT", 'h64c, this);
      this.LANE27_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE27_LANE_FRAME_ALIGN_ERR_CNT", 'h66c, this);
      this.LANE28_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE28_LANE_FRAME_ALIGN_ERR_CNT", 'h68c, this);
      this.LANE29_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE29_LANE_FRAME_ALIGN_ERR_CNT", 'h6ac, this);
      this.LANE30_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE30_LANE_FRAME_ALIGN_ERR_CNT", 'h6cc, this);
      this.LANE31_LANE_FRAME_ALIGN_ERR_CNT_R = new("LANE31_LANE_FRAME_ALIGN_ERR_CNT", 'h6ec, this);
      this.LANE0_ILAS0_R = new("LANE0_ILAS0", 'h310, this);
      this.LANE1_ILAS0_R = new("LANE1_ILAS0", 'h330, this);
      this.LANE2_ILAS0_R = new("LANE2_ILAS0", 'h350, this);
      this.LANE3_ILAS0_R = new("LANE3_ILAS0", 'h370, this);
      this.LANE4_ILAS0_R = new("LANE4_ILAS0", 'h390, this);
      this.LANE5_ILAS0_R = new("LANE5_ILAS0", 'h3b0, this);
      this.LANE6_ILAS0_R = new("LANE6_ILAS0", 'h3d0, this);
      this.LANE7_ILAS0_R = new("LANE7_ILAS0", 'h3f0, this);
      this.LANE8_ILAS0_R = new("LANE8_ILAS0", 'h410, this);
      this.LANE9_ILAS0_R = new("LANE9_ILAS0", 'h430, this);
      this.LANE10_ILAS0_R = new("LANE10_ILAS0", 'h450, this);
      this.LANE11_ILAS0_R = new("LANE11_ILAS0", 'h470, this);
      this.LANE12_ILAS0_R = new("LANE12_ILAS0", 'h490, this);
      this.LANE13_ILAS0_R = new("LANE13_ILAS0", 'h4b0, this);
      this.LANE14_ILAS0_R = new("LANE14_ILAS0", 'h4d0, this);
      this.LANE15_ILAS0_R = new("LANE15_ILAS0", 'h4f0, this);
      this.LANE16_ILAS0_R = new("LANE16_ILAS0", 'h510, this);
      this.LANE17_ILAS0_R = new("LANE17_ILAS0", 'h530, this);
      this.LANE18_ILAS0_R = new("LANE18_ILAS0", 'h550, this);
      this.LANE19_ILAS0_R = new("LANE19_ILAS0", 'h570, this);
      this.LANE20_ILAS0_R = new("LANE20_ILAS0", 'h590, this);
      this.LANE21_ILAS0_R = new("LANE21_ILAS0", 'h5b0, this);
      this.LANE22_ILAS0_R = new("LANE22_ILAS0", 'h5d0, this);
      this.LANE23_ILAS0_R = new("LANE23_ILAS0", 'h5f0, this);
      this.LANE24_ILAS0_R = new("LANE24_ILAS0", 'h610, this);
      this.LANE25_ILAS0_R = new("LANE25_ILAS0", 'h630, this);
      this.LANE26_ILAS0_R = new("LANE26_ILAS0", 'h650, this);
      this.LANE27_ILAS0_R = new("LANE27_ILAS0", 'h670, this);
      this.LANE28_ILAS0_R = new("LANE28_ILAS0", 'h690, this);
      this.LANE29_ILAS0_R = new("LANE29_ILAS0", 'h6b0, this);
      this.LANE30_ILAS0_R = new("LANE30_ILAS0", 'h6d0, this);
      this.LANE31_ILAS0_R = new("LANE31_ILAS0", 'h6f0, this);
      this.LANE0_ILAS1_R = new("LANE0_ILAS1", 'h314, this);
      this.LANE1_ILAS1_R = new("LANE1_ILAS1", 'h334, this);
      this.LANE2_ILAS1_R = new("LANE2_ILAS1", 'h354, this);
      this.LANE3_ILAS1_R = new("LANE3_ILAS1", 'h374, this);
      this.LANE4_ILAS1_R = new("LANE4_ILAS1", 'h394, this);
      this.LANE5_ILAS1_R = new("LANE5_ILAS1", 'h3b4, this);
      this.LANE6_ILAS1_R = new("LANE6_ILAS1", 'h3d4, this);
      this.LANE7_ILAS1_R = new("LANE7_ILAS1", 'h3f4, this);
      this.LANE8_ILAS1_R = new("LANE8_ILAS1", 'h414, this);
      this.LANE9_ILAS1_R = new("LANE9_ILAS1", 'h434, this);
      this.LANE10_ILAS1_R = new("LANE10_ILAS1", 'h454, this);
      this.LANE11_ILAS1_R = new("LANE11_ILAS1", 'h474, this);
      this.LANE12_ILAS1_R = new("LANE12_ILAS1", 'h494, this);
      this.LANE13_ILAS1_R = new("LANE13_ILAS1", 'h4b4, this);
      this.LANE14_ILAS1_R = new("LANE14_ILAS1", 'h4d4, this);
      this.LANE15_ILAS1_R = new("LANE15_ILAS1", 'h4f4, this);
      this.LANE16_ILAS1_R = new("LANE16_ILAS1", 'h514, this);
      this.LANE17_ILAS1_R = new("LANE17_ILAS1", 'h534, this);
      this.LANE18_ILAS1_R = new("LANE18_ILAS1", 'h554, this);
      this.LANE19_ILAS1_R = new("LANE19_ILAS1", 'h574, this);
      this.LANE20_ILAS1_R = new("LANE20_ILAS1", 'h594, this);
      this.LANE21_ILAS1_R = new("LANE21_ILAS1", 'h5b4, this);
      this.LANE22_ILAS1_R = new("LANE22_ILAS1", 'h5d4, this);
      this.LANE23_ILAS1_R = new("LANE23_ILAS1", 'h5f4, this);
      this.LANE24_ILAS1_R = new("LANE24_ILAS1", 'h614, this);
      this.LANE25_ILAS1_R = new("LANE25_ILAS1", 'h634, this);
      this.LANE26_ILAS1_R = new("LANE26_ILAS1", 'h654, this);
      this.LANE27_ILAS1_R = new("LANE27_ILAS1", 'h674, this);
      this.LANE28_ILAS1_R = new("LANE28_ILAS1", 'h694, this);
      this.LANE29_ILAS1_R = new("LANE29_ILAS1", 'h6b4, this);
      this.LANE30_ILAS1_R = new("LANE30_ILAS1", 'h6d4, this);
      this.LANE31_ILAS1_R = new("LANE31_ILAS1", 'h6f4, this);
      this.LANE0_ILAS2_R = new("LANE0_ILAS2", 'h318, this);
      this.LANE1_ILAS2_R = new("LANE1_ILAS2", 'h338, this);
      this.LANE2_ILAS2_R = new("LANE2_ILAS2", 'h358, this);
      this.LANE3_ILAS2_R = new("LANE3_ILAS2", 'h378, this);
      this.LANE4_ILAS2_R = new("LANE4_ILAS2", 'h398, this);
      this.LANE5_ILAS2_R = new("LANE5_ILAS2", 'h3b8, this);
      this.LANE6_ILAS2_R = new("LANE6_ILAS2", 'h3d8, this);
      this.LANE7_ILAS2_R = new("LANE7_ILAS2", 'h3f8, this);
      this.LANE8_ILAS2_R = new("LANE8_ILAS2", 'h418, this);
      this.LANE9_ILAS2_R = new("LANE9_ILAS2", 'h438, this);
      this.LANE10_ILAS2_R = new("LANE10_ILAS2", 'h458, this);
      this.LANE11_ILAS2_R = new("LANE11_ILAS2", 'h478, this);
      this.LANE12_ILAS2_R = new("LANE12_ILAS2", 'h498, this);
      this.LANE13_ILAS2_R = new("LANE13_ILAS2", 'h4b8, this);
      this.LANE14_ILAS2_R = new("LANE14_ILAS2", 'h4d8, this);
      this.LANE15_ILAS2_R = new("LANE15_ILAS2", 'h4f8, this);
      this.LANE16_ILAS2_R = new("LANE16_ILAS2", 'h518, this);
      this.LANE17_ILAS2_R = new("LANE17_ILAS2", 'h538, this);
      this.LANE18_ILAS2_R = new("LANE18_ILAS2", 'h558, this);
      this.LANE19_ILAS2_R = new("LANE19_ILAS2", 'h578, this);
      this.LANE20_ILAS2_R = new("LANE20_ILAS2", 'h598, this);
      this.LANE21_ILAS2_R = new("LANE21_ILAS2", 'h5b8, this);
      this.LANE22_ILAS2_R = new("LANE22_ILAS2", 'h5d8, this);
      this.LANE23_ILAS2_R = new("LANE23_ILAS2", 'h5f8, this);
      this.LANE24_ILAS2_R = new("LANE24_ILAS2", 'h618, this);
      this.LANE25_ILAS2_R = new("LANE25_ILAS2", 'h638, this);
      this.LANE26_ILAS2_R = new("LANE26_ILAS2", 'h658, this);
      this.LANE27_ILAS2_R = new("LANE27_ILAS2", 'h678, this);
      this.LANE28_ILAS2_R = new("LANE28_ILAS2", 'h698, this);
      this.LANE29_ILAS2_R = new("LANE29_ILAS2", 'h6b8, this);
      this.LANE30_ILAS2_R = new("LANE30_ILAS2", 'h6d8, this);
      this.LANE31_ILAS2_R = new("LANE31_ILAS2", 'h6f8, this);
      this.LANE0_ILAS3_R = new("LANE0_ILAS3", 'h31c, this);
      this.LANE1_ILAS3_R = new("LANE1_ILAS3", 'h33c, this);
      this.LANE2_ILAS3_R = new("LANE2_ILAS3", 'h35c, this);
      this.LANE3_ILAS3_R = new("LANE3_ILAS3", 'h37c, this);
      this.LANE4_ILAS3_R = new("LANE4_ILAS3", 'h39c, this);
      this.LANE5_ILAS3_R = new("LANE5_ILAS3", 'h3bc, this);
      this.LANE6_ILAS3_R = new("LANE6_ILAS3", 'h3dc, this);
      this.LANE7_ILAS3_R = new("LANE7_ILAS3", 'h3fc, this);
      this.LANE8_ILAS3_R = new("LANE8_ILAS3", 'h41c, this);
      this.LANE9_ILAS3_R = new("LANE9_ILAS3", 'h43c, this);
      this.LANE10_ILAS3_R = new("LANE10_ILAS3", 'h45c, this);
      this.LANE11_ILAS3_R = new("LANE11_ILAS3", 'h47c, this);
      this.LANE12_ILAS3_R = new("LANE12_ILAS3", 'h49c, this);
      this.LANE13_ILAS3_R = new("LANE13_ILAS3", 'h4bc, this);
      this.LANE14_ILAS3_R = new("LANE14_ILAS3", 'h4dc, this);
      this.LANE15_ILAS3_R = new("LANE15_ILAS3", 'h4fc, this);
      this.LANE16_ILAS3_R = new("LANE16_ILAS3", 'h51c, this);
      this.LANE17_ILAS3_R = new("LANE17_ILAS3", 'h53c, this);
      this.LANE18_ILAS3_R = new("LANE18_ILAS3", 'h55c, this);
      this.LANE19_ILAS3_R = new("LANE19_ILAS3", 'h57c, this);
      this.LANE20_ILAS3_R = new("LANE20_ILAS3", 'h59c, this);
      this.LANE21_ILAS3_R = new("LANE21_ILAS3", 'h5bc, this);
      this.LANE22_ILAS3_R = new("LANE22_ILAS3", 'h5dc, this);
      this.LANE23_ILAS3_R = new("LANE23_ILAS3", 'h5fc, this);
      this.LANE24_ILAS3_R = new("LANE24_ILAS3", 'h61c, this);
      this.LANE25_ILAS3_R = new("LANE25_ILAS3", 'h63c, this);
      this.LANE26_ILAS3_R = new("LANE26_ILAS3", 'h65c, this);
      this.LANE27_ILAS3_R = new("LANE27_ILAS3", 'h67c, this);
      this.LANE28_ILAS3_R = new("LANE28_ILAS3", 'h69c, this);
      this.LANE29_ILAS3_R = new("LANE29_ILAS3", 'h6bc, this);
      this.LANE30_ILAS3_R = new("LANE30_ILAS3", 'h6dc, this);
      this.LANE31_ILAS3_R = new("LANE31_ILAS3", 'h6fc, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_jesd_rx

endpackage: adi_regmap_jesd_rx_pkg
