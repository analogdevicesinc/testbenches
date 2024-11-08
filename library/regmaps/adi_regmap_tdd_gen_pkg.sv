// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2024 (c) Analog Devices, Inc. All rights reserved.
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
/* Nov 08 14:35:39 2024 v0.3.49 */

package adi_regmap_tdd_gen_pkg;
  import regmap_pkg::*;

  class adi_regmap_tdd_gen #(int BURST_COUNT_WIDTH, int CHANNEL_COUNT, int DEFAULT_POLARITY, int ID, int REGISTER_WIDTH, int SYNC_COUNT_WIDTH, int SYNC_EXTERNAL, int SYNC_EXTERNAL_CDC, int SYNC_INTERNAL);

    /* Generic TDD Control (axi_tdd) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_MAJOR_F;
      field_base VERSION_MINOR_F;
      field_base VERSION_PATCH_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.VERSION_MAJOR_F = new("VERSION_MAJOR", 31, 16, RO, 'h2, this);
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h0, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h62, this);
      endfunction: new
    endclass

    class PERIPHERAL_ID_CLASS #(int ID) extends register_base;
      field_base PERIPHERAL_ID_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.PERIPHERAL_ID_F = new("PERIPHERAL_ID", 31, 0, RO, ID, this);
      endfunction: new
    endclass

    class SCRATCH_CLASS extends register_base;
      field_base SCRATCH_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class IDENTIFICATION_CLASS extends register_base;
      field_base IDENTIFICATION_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.IDENTIFICATION_F = new("IDENTIFICATION", 31, 0, RO, 'h5444444e, this);
      endfunction: new
    endclass

    class INTERFACE_DESCRIPTION_CLASS #(int BURST_COUNT_WIDTH, int CHANNEL_COUNT, int REGISTER_WIDTH, int SYNC_COUNT_WIDTH, int SYNC_EXTERNAL, int SYNC_EXTERNAL_CDC, int SYNC_INTERNAL) extends register_base;
      field_base SYNC_COUNT_WIDTH_F;
      field_base BURST_COUNT_WIDTH_F;
      field_base REGISTER_WIDTH_F;
      field_base SYNC_EXTERNAL_CDC_F;
      field_base SYNC_EXTERNAL_F;
      field_base SYNC_INTERNAL_F;
      field_base CHANNEL_COUNT_EXTRA_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.SYNC_COUNT_WIDTH_F = new("SYNC_COUNT_WIDTH", 30, 24, RO, SYNC_COUNT_WIDTH, this);
        this.BURST_COUNT_WIDTH_F = new("BURST_COUNT_WIDTH", 21, 16, RO, BURST_COUNT_WIDTH, this);
        this.REGISTER_WIDTH_F = new("REGISTER_WIDTH", 13, 8, RO, REGISTER_WIDTH, this);
        this.SYNC_EXTERNAL_CDC_F = new("SYNC_EXTERNAL_CDC", 7, 7, RO, SYNC_EXTERNAL_CDC, this);
        this.SYNC_EXTERNAL_F = new("SYNC_EXTERNAL", 6, 6, RO, SYNC_EXTERNAL, this);
        this.SYNC_INTERNAL_F = new("SYNC_INTERNAL", 5, 5, RO, SYNC_INTERNAL, this);
        this.CHANNEL_COUNT_EXTRA_F = new("CHANNEL_COUNT_EXTRA", 4, 0, RO, CHANNEL_COUNT-1, this);
      endfunction: new
    endclass

    class DEFAULT_POLARITY_CLASS #(int DEFAULT_POLARITY) extends register_base;
      field_base DEFAULT_POLARITY_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.DEFAULT_POLARITY_F = new("DEFAULT_POLARITY", 31, 0, RO, DEFAULT_POLARITY, this);
      endfunction: new
    endclass

    class CONTROL_CLASS extends register_base;
      field_base SYNC_SOFT_F;
      field_base SYNC_EXT_F;
      field_base SYNC_INT_F;
      field_base SYNC_RST_F;
      field_base ENABLE_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.SYNC_SOFT_F = new("SYNC_SOFT", 4, 4, RW1C, 'h0, this);
        this.SYNC_EXT_F = new("SYNC_EXT", 3, 3, RW, 'h0, this);
        this.SYNC_INT_F = new("SYNC_INT", 2, 2, RW, 'h0, this);
        this.SYNC_RST_F = new("SYNC_RST", 1, 1, RW, 'h0, this);
        this.ENABLE_F = new("ENABLE", 0, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class CHANNEL_ENABLE_CLASS extends register_base;
      field_base CHANNEL_ENABLE_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.CHANNEL_ENABLE_F = new("CHANNEL_ENABLE", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class CHANNEL_POLARITY_CLASS extends register_base;
      field_base CHANNEL_POLARITY_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.CHANNEL_POLARITY_F = new("CHANNEL_POLARITY", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class BURST_COUNT_CLASS extends register_base;
      field_base BURST_COUNT_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.BURST_COUNT_F = new("BURST_COUNT", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class STARTUP_DELAY_CLASS extends register_base;
      field_base STARTUP_DELAY_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.STARTUP_DELAY_F = new("STARTUP_DELAY", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class FRAME_LENGTH_CLASS extends register_base;
      field_base FRAME_LENGTH_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.FRAME_LENGTH_F = new("FRAME_LENGTH", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class SYNC_PERIOD_LOW_CLASS extends register_base;
      field_base SYNC_PERIOD_LOW_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.SYNC_PERIOD_LOW_F = new("SYNC_PERIOD_LOW", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class SYNC_PERIOD_HIGH_CLASS extends register_base;
      field_base SYNC_PERIOD_HIGH_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.SYNC_PERIOD_HIGH_F = new("SYNC_PERIOD_HIGH", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class STATUS_CLASS extends register_base;
      field_base STATE_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.STATE_F = new("STATE", 1, 0, RO, 'h0, this);
      endfunction: new
    endclass

    class CHn_ON_CLASS extends register_base;
      field_base CHn_ON_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.CHn_ON_F = new("CHn_ON", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class CHn_OFF_CLASS extends register_base;
      field_base CHn_OFF_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.CHn_OFF_F = new("CHn_OFF", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    VERSION_CLASS VERSION_R;
    PERIPHERAL_ID_CLASS #(ID) PERIPHERAL_ID_R;
    SCRATCH_CLASS SCRATCH_R;
    IDENTIFICATION_CLASS IDENTIFICATION_R;
    INTERFACE_DESCRIPTION_CLASS #(BURST_COUNT_WIDTH, CHANNEL_COUNT, REGISTER_WIDTH, SYNC_COUNT_WIDTH, SYNC_EXTERNAL, SYNC_EXTERNAL_CDC, SYNC_INTERNAL) INTERFACE_DESCRIPTION_R;
    DEFAULT_POLARITY_CLASS #(DEFAULT_POLARITY) DEFAULT_POLARITY_R;
    CONTROL_CLASS CONTROL_R;
    CHANNEL_ENABLE_CLASS CHANNEL_ENABLE_R;
    CHANNEL_POLARITY_CLASS CHANNEL_POLARITY_R;
    BURST_COUNT_CLASS BURST_COUNT_R;
    STARTUP_DELAY_CLASS STARTUP_DELAY_R;
    FRAME_LENGTH_CLASS FRAME_LENGTH_R;
    SYNC_PERIOD_LOW_CLASS SYNC_PERIOD_LOW_R;
    SYNC_PERIOD_HIGH_CLASS SYNC_PERIOD_HIGH_R;
    STATUS_CLASS STATUS_R;
    CHn_ON_CLASS CH0_ON_R;
    CHn_ON_CLASS CH1_ON_R;
    CHn_ON_CLASS CH2_ON_R;
    CHn_ON_CLASS CH3_ON_R;
    CHn_ON_CLASS CH4_ON_R;
    CHn_ON_CLASS CH5_ON_R;
    CHn_ON_CLASS CH6_ON_R;
    CHn_ON_CLASS CH7_ON_R;
    CHn_ON_CLASS CH8_ON_R;
    CHn_ON_CLASS CH9_ON_R;
    CHn_ON_CLASS CH10_ON_R;
    CHn_ON_CLASS CH11_ON_R;
    CHn_ON_CLASS CH12_ON_R;
    CHn_ON_CLASS CH13_ON_R;
    CHn_ON_CLASS CH14_ON_R;
    CHn_ON_CLASS CH15_ON_R;
    CHn_ON_CLASS CH16_ON_R;
    CHn_ON_CLASS CH17_ON_R;
    CHn_ON_CLASS CH18_ON_R;
    CHn_ON_CLASS CH19_ON_R;
    CHn_ON_CLASS CH20_ON_R;
    CHn_ON_CLASS CH21_ON_R;
    CHn_ON_CLASS CH22_ON_R;
    CHn_ON_CLASS CH23_ON_R;
    CHn_ON_CLASS CH24_ON_R;
    CHn_ON_CLASS CH25_ON_R;
    CHn_ON_CLASS CH26_ON_R;
    CHn_ON_CLASS CH27_ON_R;
    CHn_ON_CLASS CH28_ON_R;
    CHn_ON_CLASS CH29_ON_R;
    CHn_ON_CLASS CH30_ON_R;
    CHn_ON_CLASS CH31_ON_R;
    CHn_OFF_CLASS CH0_OFF_R;
    CHn_OFF_CLASS CH1_OFF_R;
    CHn_OFF_CLASS CH2_OFF_R;
    CHn_OFF_CLASS CH3_OFF_R;
    CHn_OFF_CLASS CH4_OFF_R;
    CHn_OFF_CLASS CH5_OFF_R;
    CHn_OFF_CLASS CH6_OFF_R;
    CHn_OFF_CLASS CH7_OFF_R;
    CHn_OFF_CLASS CH8_OFF_R;
    CHn_OFF_CLASS CH9_OFF_R;
    CHn_OFF_CLASS CH10_OFF_R;
    CHn_OFF_CLASS CH11_OFF_R;
    CHn_OFF_CLASS CH12_OFF_R;
    CHn_OFF_CLASS CH13_OFF_R;
    CHn_OFF_CLASS CH14_OFF_R;
    CHn_OFF_CLASS CH15_OFF_R;
    CHn_OFF_CLASS CH16_OFF_R;
    CHn_OFF_CLASS CH17_OFF_R;
    CHn_OFF_CLASS CH18_OFF_R;
    CHn_OFF_CLASS CH19_OFF_R;
    CHn_OFF_CLASS CH20_OFF_R;
    CHn_OFF_CLASS CH21_OFF_R;
    CHn_OFF_CLASS CH22_OFF_R;
    CHn_OFF_CLASS CH23_OFF_R;
    CHn_OFF_CLASS CH24_OFF_R;
    CHn_OFF_CLASS CH25_OFF_R;
    CHn_OFF_CLASS CH26_OFF_R;
    CHn_OFF_CLASS CH27_OFF_R;
    CHn_OFF_CLASS CH28_OFF_R;
    CHn_OFF_CLASS CH29_OFF_R;
    CHn_OFF_CLASS CH30_OFF_R;
    CHn_OFF_CLASS CH31_OFF_R;

    function new();
      this.VERSION_R = new("VERSION", 'h0);
      this.PERIPHERAL_ID_R = new("PERIPHERAL_ID", 'h4);
      this.SCRATCH_R = new("SCRATCH", 'h8);
      this.IDENTIFICATION_R = new("IDENTIFICATION", 'hc);
      this.INTERFACE_DESCRIPTION_R = new("INTERFACE_DESCRIPTION", 'h10);
      this.DEFAULT_POLARITY_R = new("DEFAULT_POLARITY", 'h14);
      this.CONTROL_R = new("CONTROL", 'h40);
      this.CHANNEL_ENABLE_R = new("CHANNEL_ENABLE", 'h44);
      this.CHANNEL_POLARITY_R = new("CHANNEL_POLARITY", 'h48);
      this.BURST_COUNT_R = new("BURST_COUNT", 'h4c);
      this.STARTUP_DELAY_R = new("STARTUP_DELAY", 'h50);
      this.FRAME_LENGTH_R = new("FRAME_LENGTH", 'h54);
      this.SYNC_PERIOD_LOW_R = new("SYNC_PERIOD_LOW", 'h58);
      this.SYNC_PERIOD_HIGH_R = new("SYNC_PERIOD_HIGH", 'h5c);
      this.STATUS_R = new("STATUS", 'h60);
      this.CH0_ON_R = new("CH0_ON", 'h80);
      this.CH1_ON_R = new("CH1_ON", 'h88);
      this.CH2_ON_R = new("CH2_ON", 'h90);
      this.CH3_ON_R = new("CH3_ON", 'h98);
      this.CH4_ON_R = new("CH4_ON", 'ha0);
      this.CH5_ON_R = new("CH5_ON", 'ha8);
      this.CH6_ON_R = new("CH6_ON", 'hb0);
      this.CH7_ON_R = new("CH7_ON", 'hb8);
      this.CH8_ON_R = new("CH8_ON", 'hc0);
      this.CH9_ON_R = new("CH9_ON", 'hc8);
      this.CH10_ON_R = new("CH10_ON", 'hd0);
      this.CH11_ON_R = new("CH11_ON", 'hd8);
      this.CH12_ON_R = new("CH12_ON", 'he0);
      this.CH13_ON_R = new("CH13_ON", 'he8);
      this.CH14_ON_R = new("CH14_ON", 'hf0);
      this.CH15_ON_R = new("CH15_ON", 'hf8);
      this.CH16_ON_R = new("CH16_ON", 'h100);
      this.CH17_ON_R = new("CH17_ON", 'h108);
      this.CH18_ON_R = new("CH18_ON", 'h110);
      this.CH19_ON_R = new("CH19_ON", 'h118);
      this.CH20_ON_R = new("CH20_ON", 'h120);
      this.CH21_ON_R = new("CH21_ON", 'h128);
      this.CH22_ON_R = new("CH22_ON", 'h130);
      this.CH23_ON_R = new("CH23_ON", 'h138);
      this.CH24_ON_R = new("CH24_ON", 'h140);
      this.CH25_ON_R = new("CH25_ON", 'h148);
      this.CH26_ON_R = new("CH26_ON", 'h150);
      this.CH27_ON_R = new("CH27_ON", 'h158);
      this.CH28_ON_R = new("CH28_ON", 'h160);
      this.CH29_ON_R = new("CH29_ON", 'h168);
      this.CH30_ON_R = new("CH30_ON", 'h170);
      this.CH31_ON_R = new("CH31_ON", 'h178);
      this.CH0_OFF_R = new("CH0_OFF", 'h84);
      this.CH1_OFF_R = new("CH1_OFF", 'h8c);
      this.CH2_OFF_R = new("CH2_OFF", 'h94);
      this.CH3_OFF_R = new("CH3_OFF", 'h9c);
      this.CH4_OFF_R = new("CH4_OFF", 'ha4);
      this.CH5_OFF_R = new("CH5_OFF", 'hac);
      this.CH6_OFF_R = new("CH6_OFF", 'hb4);
      this.CH7_OFF_R = new("CH7_OFF", 'hbc);
      this.CH8_OFF_R = new("CH8_OFF", 'hc4);
      this.CH9_OFF_R = new("CH9_OFF", 'hcc);
      this.CH10_OFF_R = new("CH10_OFF", 'hd4);
      this.CH11_OFF_R = new("CH11_OFF", 'hdc);
      this.CH12_OFF_R = new("CH12_OFF", 'he4);
      this.CH13_OFF_R = new("CH13_OFF", 'hec);
      this.CH14_OFF_R = new("CH14_OFF", 'hf4);
      this.CH15_OFF_R = new("CH15_OFF", 'hfc);
      this.CH16_OFF_R = new("CH16_OFF", 'h104);
      this.CH17_OFF_R = new("CH17_OFF", 'h10c);
      this.CH18_OFF_R = new("CH18_OFF", 'h114);
      this.CH19_OFF_R = new("CH19_OFF", 'h11c);
      this.CH20_OFF_R = new("CH20_OFF", 'h124);
      this.CH21_OFF_R = new("CH21_OFF", 'h12c);
      this.CH22_OFF_R = new("CH22_OFF", 'h134);
      this.CH23_OFF_R = new("CH23_OFF", 'h13c);
      this.CH24_OFF_R = new("CH24_OFF", 'h144);
      this.CH25_OFF_R = new("CH25_OFF", 'h14c);
      this.CH26_OFF_R = new("CH26_OFF", 'h154);
      this.CH27_OFF_R = new("CH27_OFF", 'h15c);
      this.CH28_OFF_R = new("CH28_OFF", 'h164);
      this.CH29_OFF_R = new("CH29_OFF", 'h16c);
      this.CH30_OFF_R = new("CH30_OFF", 'h174);
      this.CH31_OFF_R = new("CH31_OFF", 'h17c);
    endfunction: new;

  endclass;
endpackage
