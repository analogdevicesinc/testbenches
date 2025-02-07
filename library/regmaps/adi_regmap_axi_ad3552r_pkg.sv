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
/* Feb 07 14:25:05 2025 v0.4.1 */

package adi_regmap_axi_ad3552r_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_axi_ad3552r extends adi_regmap;

    /* AXI AD3552R DAC Common (axi_ad3552r_dac_common) */
    class CNTRL_1_CLASS extends register_base;
      field_base EXT_SYNC_ARM_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.EXT_SYNC_ARM_F = new("EXT_SYNC_ARM", 1, 1, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CNTRL_1_CLASS

    class CNTRL_2_CLASS extends register_base;
      field_base SDR_DDR_N_F;
      field_base SYMB_8_16B_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDR_DDR_N_F = new("SDR_DDR_N", 16, 16, RW, 'h0, this);
        this.SYMB_8_16B_F = new("SYMB_8_16B", 14, 14, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CNTRL_2_CLASS

    class DAC_CUSTOM_WR_CLASS extends register_base;
      field_base DATA_WRITE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DATA_WRITE_F = new("DATA_WRITE", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DAC_CUSTOM_WR_CLASS

    class UI_STATUS_CLASS extends register_base;
      field_base IF_BUSY_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IF_BUSY_F = new("IF_BUSY", 4, 4, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: UI_STATUS_CLASS

    class DAC_CUSTOM_CTRL_CLASS extends register_base;
      field_base ADDRESS_F;
      field_base STREAM_F;
      field_base TRANSFER_DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADDRESS_F = new("ADDRESS", 31, 24, RW, 'h0, this);
        this.STREAM_F = new("STREAM", 1, 1, RW, 'h0, this);
        this.TRANSFER_DATA_F = new("TRANSFER_DATA", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DAC_CUSTOM_CTRL_CLASS

    /* AXI AD3552R DAC Channel (axi_ad3552r_dac_channel) */
    class CHAN_CNTRL0_7_CLASS extends register_base;
      field_base DAC_DDS_SEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAC_DDS_SEL_F = new("DAC_DDS_SEL", 3, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRL0_7_CLASS

    class CHAN_CNTRL1_7_CLASS extends register_base;
      field_base DAC_DDS_SEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAC_DDS_SEL_F = new("DAC_DDS_SEL", 3, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRL1_7_CLASS

    CNTRL_1_CLASS CNTRL_1_R;
    CNTRL_2_CLASS CNTRL_2_R;
    DAC_CUSTOM_WR_CLASS DAC_CUSTOM_WR_R;
    UI_STATUS_CLASS UI_STATUS_R;
    DAC_CUSTOM_CTRL_CLASS DAC_CUSTOM_CTRL_R;
    CHAN_CNTRL0_7_CLASS CHAN_CNTRL0_7_R;
    CHAN_CNTRL1_7_CLASS CHAN_CNTRL1_7_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.CNTRL_1_R = new("CNTRL_1", 'h44, this);
      this.CNTRL_2_R = new("CNTRL_2", 'h48, this);
      this.DAC_CUSTOM_WR_R = new("DAC_CUSTOM_WR", 'h84, this);
      this.UI_STATUS_R = new("UI_STATUS", 'h88, this);
      this.DAC_CUSTOM_CTRL_R = new("DAC_CUSTOM_CTRL", 'h8c, this);
      this.CHAN_CNTRL0_7_R = new("CHAN_CNTRL0_7", 'h400, this);
      this.CHAN_CNTRL1_7_R = new("CHAN_CNTRL1_7", 'h458, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_axi_ad3552r

endpackage: adi_regmap_axi_ad3552r_pkg
