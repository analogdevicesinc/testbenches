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
/* Feb 07 14:25:05 2025 v0.4.1 */

package adi_regmap_tdd_gen_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_tdd_gen extends adi_regmap;

    /* Generic TDD Control (axi_tdd) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_MAJOR_F;
      field_base VERSION_MINOR_F;
      field_base VERSION_PATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_MAJOR_F = new("VERSION_MAJOR", 31, 16, RO, 'h2, this);
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h0, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h62, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VERSION_CLASS

    class PERIPHERAL_ID_CLASS extends register_base;
      field_base PERIPHERAL_ID_F;

      function new(
        input string name,
        input int address,
        input int ID,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PERIPHERAL_ID_F = new("PERIPHERAL_ID", 31, 0, RO, ID, this);

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

        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'h0, this);

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

        this.IDENTIFICATION_F = new("IDENTIFICATION", 31, 0, RO, 'h5444444e, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IDENTIFICATION_CLASS

    class INTERFACE_DESCRIPTION_CLASS extends register_base;
      field_base SYNC_COUNT_WIDTH_F;
      field_base BURST_COUNT_WIDTH_F;
      field_base REGISTER_WIDTH_F;
      field_base SYNC_EXTERNAL_CDC_F;
      field_base SYNC_EXTERNAL_F;
      field_base SYNC_INTERNAL_F;
      field_base CHANNEL_COUNT_EXTRA_F;

      function new(
        input string name,
        input int address,
        input int BURST_COUNT_WIDTH,
        input int CHANNEL_COUNT,
        input int REGISTER_WIDTH,
        input int SYNC_COUNT_WIDTH,
        input int SYNC_EXTERNAL,
        input int SYNC_EXTERNAL_CDC,
        input int SYNC_INTERNAL,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SYNC_COUNT_WIDTH_F = new("SYNC_COUNT_WIDTH", 30, 24, RO, SYNC_COUNT_WIDTH, this);
        this.BURST_COUNT_WIDTH_F = new("BURST_COUNT_WIDTH", 21, 16, RO, BURST_COUNT_WIDTH, this);
        this.REGISTER_WIDTH_F = new("REGISTER_WIDTH", 13, 8, RO, REGISTER_WIDTH, this);
        this.SYNC_EXTERNAL_CDC_F = new("SYNC_EXTERNAL_CDC", 7, 7, RO, SYNC_EXTERNAL_CDC, this);
        this.SYNC_EXTERNAL_F = new("SYNC_EXTERNAL", 6, 6, RO, SYNC_EXTERNAL, this);
        this.SYNC_INTERNAL_F = new("SYNC_INTERNAL", 5, 5, RO, SYNC_INTERNAL, this);
        this.CHANNEL_COUNT_EXTRA_F = new("CHANNEL_COUNT_EXTRA", 4, 0, RO, CHANNEL_COUNT-1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: INTERFACE_DESCRIPTION_CLASS

    class DEFAULT_POLARITY_CLASS extends register_base;
      field_base DEFAULT_POLARITY_F;

      function new(
        input string name,
        input int address,
        input int DEFAULT_POLARITY,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DEFAULT_POLARITY_F = new("DEFAULT_POLARITY", 31, 0, RO, DEFAULT_POLARITY, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DEFAULT_POLARITY_CLASS

    class CONTROL_CLASS extends register_base;
      field_base SYNC_SOFT_F;
      field_base SYNC_EXT_F;
      field_base SYNC_INT_F;
      field_base SYNC_RST_F;
      field_base ENABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SYNC_SOFT_F = new("SYNC_SOFT", 4, 4, RW1C, 'h0, this);
        this.SYNC_EXT_F = new("SYNC_EXT", 3, 3, RW, 'h0, this);
        this.SYNC_INT_F = new("SYNC_INT", 2, 2, RW, 'h0, this);
        this.SYNC_RST_F = new("SYNC_RST", 1, 1, RW, 'h0, this);
        this.ENABLE_F = new("ENABLE", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CONTROL_CLASS

    class CHANNEL_ENABLE_CLASS extends register_base;
      field_base CHANNEL_ENABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CHANNEL_ENABLE_F = new("CHANNEL_ENABLE", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHANNEL_ENABLE_CLASS

    class CHANNEL_POLARITY_CLASS extends register_base;
      field_base CHANNEL_POLARITY_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CHANNEL_POLARITY_F = new("CHANNEL_POLARITY", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHANNEL_POLARITY_CLASS

    class BURST_COUNT_CLASS extends register_base;
      field_base BURST_COUNT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.BURST_COUNT_F = new("BURST_COUNT", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: BURST_COUNT_CLASS

    class STARTUP_DELAY_CLASS extends register_base;
      field_base STARTUP_DELAY_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.STARTUP_DELAY_F = new("STARTUP_DELAY", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: STARTUP_DELAY_CLASS

    class FRAME_LENGTH_CLASS extends register_base;
      field_base FRAME_LENGTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FRAME_LENGTH_F = new("FRAME_LENGTH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FRAME_LENGTH_CLASS

    class SYNC_PERIOD_LOW_CLASS extends register_base;
      field_base SYNC_PERIOD_LOW_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SYNC_PERIOD_LOW_F = new("SYNC_PERIOD_LOW", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SYNC_PERIOD_LOW_CLASS

    class SYNC_PERIOD_HIGH_CLASS extends register_base;
      field_base SYNC_PERIOD_HIGH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SYNC_PERIOD_HIGH_F = new("SYNC_PERIOD_HIGH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SYNC_PERIOD_HIGH_CLASS

    class STATUS_CLASS extends register_base;
      field_base STATE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.STATE_F = new("STATE", 1, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: STATUS_CLASS

    class CHn_ON_CLASS extends register_base;
      field_base CHn_ON_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CHn_ON_F = new("CHn_ON", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHn_ON_CLASS

    class CHn_OFF_CLASS extends register_base;
      field_base CHn_OFF_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CHn_OFF_F = new("CHn_OFF", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHn_OFF_CLASS

    VERSION_CLASS VERSION_R;
    PERIPHERAL_ID_CLASS PERIPHERAL_ID_R;
    SCRATCH_CLASS SCRATCH_R;
    IDENTIFICATION_CLASS IDENTIFICATION_R;
    INTERFACE_DESCRIPTION_CLASS INTERFACE_DESCRIPTION_R;
    DEFAULT_POLARITY_CLASS DEFAULT_POLARITY_R;
    CONTROL_CLASS CONTROL_R;
    CHANNEL_ENABLE_CLASS CHANNEL_ENABLE_R;
    CHANNEL_POLARITY_CLASS CHANNEL_POLARITY_R;
    BURST_COUNT_CLASS BURST_COUNT_R;
    STARTUP_DELAY_CLASS STARTUP_DELAY_R;
    FRAME_LENGTH_CLASS FRAME_LENGTH_R;
    SYNC_PERIOD_LOW_CLASS SYNC_PERIOD_LOW_R;
    SYNC_PERIOD_HIGH_CLASS SYNC_PERIOD_HIGH_R;
    STATUS_CLASS STATUS_R;
    CHn_ON_CLASS CHn_ON_R [31:0];
    CHn_OFF_CLASS CHn_OFF_R [31:0];

    function new(
      input string name,
      input int address,
      input int BURST_COUNT_WIDTH,
      input int CHANNEL_COUNT,
      input int DEFAULT_POLARITY,
      input int ID,
      input int REGISTER_WIDTH,
      input int SYNC_COUNT_WIDTH,
      input int SYNC_EXTERNAL,
      input int SYNC_EXTERNAL_CDC,
      input int SYNC_INTERNAL,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.PERIPHERAL_ID_R = new("PERIPHERAL_ID", 'h4, ID, this);
      this.SCRATCH_R = new("SCRATCH", 'h8, this);
      this.IDENTIFICATION_R = new("IDENTIFICATION", 'hc, this);
      this.INTERFACE_DESCRIPTION_R = new("INTERFACE_DESCRIPTION", 'h10, BURST_COUNT_WIDTH, CHANNEL_COUNT, REGISTER_WIDTH, SYNC_COUNT_WIDTH, SYNC_EXTERNAL, SYNC_EXTERNAL_CDC, SYNC_INTERNAL, this);
      this.DEFAULT_POLARITY_R = new("DEFAULT_POLARITY", 'h14, DEFAULT_POLARITY, this);
      this.CONTROL_R = new("CONTROL", 'h40, this);
      this.CHANNEL_ENABLE_R = new("CHANNEL_ENABLE", 'h44, this);
      this.CHANNEL_POLARITY_R = new("CHANNEL_POLARITY", 'h48, this);
      this.BURST_COUNT_R = new("BURST_COUNT", 'h4c, this);
      this.STARTUP_DELAY_R = new("STARTUP_DELAY", 'h50, this);
      this.FRAME_LENGTH_R = new("FRAME_LENGTH", 'h54, this);
      this.SYNC_PERIOD_LOW_R = new("SYNC_PERIOD_LOW", 'h58, this);
      this.SYNC_PERIOD_HIGH_R = new("SYNC_PERIOD_HIGH", 'h5c, this);
      this.STATUS_R = new("STATUS", 'h60, this);
      for (int i=0; i<32; i++) begin
        this.CHn_ON_R[i] = new($sformatf("CH%0d_ON", i), 'h80 + 'h2 * i * 4, this);
      end
      for (int i=0; i<32; i++) begin
        this.CHn_OFF_R[i] = new($sformatf("CH%0d_OFF", i), 'h84 + 'h2 * i * 4, this);
      end

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_tdd_gen

endpackage: adi_regmap_tdd_gen_pkg
