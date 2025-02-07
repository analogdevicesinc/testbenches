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
/* Feb 07 11:48:47 2025 v0.4.1 */

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
    LANEn_STATUS_CLASS LANEn_STATUS_R [31:0];
    LANEn_LATENCY_CLASS LANEn_LATENCY_R [31:0];
    LANEn_ERROR_STATISTICS_CLASS LANEn_ERROR_STATISTICS_R [31:0];
    LANEn_LANE_FRAME_ALIGN_ERR_CNT_CLASS LANEn_LANE_FRAME_ALIGN_ERR_CNT_R [31:0];
    LANEn_ILAS0_CLASS LANEn_ILAS0_R [31:0];
    LANEn_ILAS1_CLASS LANEn_ILAS1_R [31:0];
    LANEn_ILAS2_CLASS LANEn_ILAS2_R [31:0];
    LANEn_ILAS3_CLASS LANEn_ILAS3_R [31:0];

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
      for (int i=0; i<32; i++) begin
        this.LANEn_STATUS_R[i] = new($sformatf("LANE%0d_STATUS", i), 'h300 + i * 4, this);
      end
      for (int i=0; i<32; i++) begin
        this.LANEn_LATENCY_R[i] = new($sformatf("LANE%0d_LATENCY", i), 'h304 + i * 4, this);
      end
      for (int i=0; i<32; i++) begin
        this.LANEn_ERROR_STATISTICS_R[i] = new($sformatf("LANE%0d_ERROR_STATISTICS", i), 'h308 + i * 4, this);
      end
      for (int i=0; i<32; i++) begin
        this.LANEn_LANE_FRAME_ALIGN_ERR_CNT_R[i] = new($sformatf("LANE%0d_LANE_FRAME_ALIGN_ERR_CNT", i), 'h30c + i * 4, this);
      end
      for (int i=0; i<32; i++) begin
        this.LANEn_ILAS0_R[i] = new($sformatf("LANE%0d_ILAS0", i), 'h310 + i * 4, this);
      end
      for (int i=0; i<32; i++) begin
        this.LANEn_ILAS1_R[i] = new($sformatf("LANE%0d_ILAS1", i), 'h314 + i * 4, this);
      end
      for (int i=0; i<32; i++) begin
        this.LANEn_ILAS2_R[i] = new($sformatf("LANE%0d_ILAS2", i), 'h318 + i * 4, this);
      end
      for (int i=0; i<32; i++) begin
        this.LANEn_ILAS3_R[i] = new($sformatf("LANE%0d_ILAS3", i), 'h31c + i * 4, this);
      end

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_jesd_rx

endpackage: adi_regmap_jesd_rx_pkg
