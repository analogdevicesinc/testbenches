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

package adi_regmap_dac_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_dac extends adi_regmap;

    /* DAC Common (axi_ad) */
    class RSTN_CLASS extends register_base;
      field_base CE_N_F;
      field_base MMCM_RSTN_F;
      field_base RSTN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CE_N_F = new("CE_N", 2, 2, RW, 'h0, this);
        this.MMCM_RSTN_F = new("MMCM_RSTN", 1, 1, RW, 'h0, this);
        this.RSTN_F = new("RSTN", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: RSTN_CLASS

    class CNTRL_1_CLASS extends register_base;
      field_base SYNC_F;
      field_base EXT_SYNC_ARM_F;
      field_base EXT_SYNC_DISARM_F;
      field_base MANUAL_SYNC_REQUEST_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SYNC_F = new("SYNC", 0, 0, RW, 'h0, this);
        this.EXT_SYNC_ARM_F = new("EXT_SYNC_ARM", 1, 1, RW, 'h0, this);
        this.EXT_SYNC_DISARM_F = new("EXT_SYNC_DISARM", 2, 2, RW, 'h0, this);
        this.MANUAL_SYNC_REQUEST_F = new("MANUAL_SYNC_REQUEST", 8, 8, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CNTRL_1_CLASS

    class CNTRL_2_CLASS extends register_base;
      field_base SDR_DDR_N_F;
      field_base SYMB_OP_F;
      field_base SYMB_8_16B_F;
      field_base NUM_LANES_F;
      field_base PAR_TYPE_F;
      field_base PAR_ENB_F;
      field_base R1_MODE_F;
      field_base DATA_FORMAT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDR_DDR_N_F = new("SDR_DDR_N", 16, 16, RW, 'h0, this);
        this.SYMB_OP_F = new("SYMB_OP", 15, 15, RW, 'h0, this);
        this.SYMB_8_16B_F = new("SYMB_8_16B", 14, 14, RW, 'h0, this);
        this.NUM_LANES_F = new("NUM_LANES", 12, 8, RW, 'h0, this);
        this.PAR_TYPE_F = new("PAR_TYPE", 7, 7, RW, 'h0, this);
        this.PAR_ENB_F = new("PAR_ENB", 6, 6, RW, 'h0, this);
        this.R1_MODE_F = new("R1_MODE", 5, 5, RW, 'h0, this);
        this.DATA_FORMAT_F = new("DATA_FORMAT", 4, 4, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CNTRL_2_CLASS

    class RATECNTRL_CLASS extends register_base;
      field_base RATE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.RATE_F = new("RATE", 7, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: RATECNTRL_CLASS

    class FRAME_CLASS extends register_base;
      field_base FRAME_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FRAME_F = new("FRAME", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FRAME_CLASS

    class STATUS1_CLASS extends register_base;
      field_base CLK_FREQ_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CLK_FREQ_F = new("CLK_FREQ", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: STATUS1_CLASS

    class STATUS2_CLASS extends register_base;
      field_base CLK_RATIO_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CLK_RATIO_F = new("CLK_RATIO", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: STATUS2_CLASS

    class STATUS3_CLASS extends register_base;
      field_base STATUS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.STATUS_F = new("STATUS", 0, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: STATUS3_CLASS

    class DAC_CLKSEL_CLASS extends register_base;
      field_base DAC_CLKSEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAC_CLKSEL_F = new("DAC_CLKSEL", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DAC_CLKSEL_CLASS

    class SYNC_STATUS_CLASS extends register_base;
      field_base DAC_SYNC_STATUS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAC_SYNC_STATUS_F = new("DAC_SYNC_STATUS", 0, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SYNC_STATUS_CLASS

    class DRP_CNTRL_CLASS extends register_base;
      field_base DRP_RWN_F;
      field_base DRP_ADDRESS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DRP_RWN_F = new("DRP_RWN", 28, 28, RW, 'h0, this);
        this.DRP_ADDRESS_F = new("DRP_ADDRESS", 27, 16, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DRP_CNTRL_CLASS

    class DRP_STATUS_CLASS extends register_base;
      field_base DRP_LOCKED_F;
      field_base DRP_STATUS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DRP_LOCKED_F = new("DRP_LOCKED", 17, 17, RO, 'h0, this);
        this.DRP_STATUS_F = new("DRP_STATUS", 16, 16, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DRP_STATUS_CLASS

    class DRP_WDATA_CLASS extends register_base;
      field_base DRP_WDATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DRP_WDATA_F = new("DRP_WDATA", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DRP_WDATA_CLASS

    class DRP_RDATA_CLASS extends register_base;
      field_base DRP_RDATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DRP_RDATA_F = new("DRP_RDATA", 15, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DRP_RDATA_CLASS

    class DAC_CUSTOM_RD_CLASS extends register_base;
      field_base DAC_CUSTOM_RD_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAC_CUSTOM_RD_F = new("DAC_CUSTOM_RD", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DAC_CUSTOM_RD_CLASS

    class DAC_CUSTOM_WR_CLASS extends register_base;
      field_base DAC_CUSTOM_WR_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAC_CUSTOM_WR_F = new("DAC_CUSTOM_WR", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DAC_CUSTOM_WR_CLASS

    class UI_STATUS_CLASS extends register_base;
      field_base IF_BUSY_F;
      field_base UI_OVF_F;
      field_base UI_UNF_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IF_BUSY_F = new("IF_BUSY", 4, 4, RO, 'h0, this);
        this.UI_OVF_F = new("UI_OVF", 1, 1, RW1C, 'h0, this);
        this.UI_UNF_F = new("UI_UNF", 0, 0, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: UI_STATUS_CLASS

    class DAC_CUSTOM_CTRL_CLASS extends register_base;
      field_base DAC_CUSTOM_CTRL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAC_CUSTOM_CTRL_F = new("DAC_CUSTOM_CTRL", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DAC_CUSTOM_CTRL_CLASS

    class USR_CNTRL_1_CLASS extends register_base;
      field_base USR_CHANMAX_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.USR_CHANMAX_F = new("USR_CHANMAX", 7, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: USR_CNTRL_1_CLASS

    class DAC_GPIO_IN_CLASS extends register_base;
      field_base DAC_GPIO_IN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAC_GPIO_IN_F = new("DAC_GPIO_IN", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DAC_GPIO_IN_CLASS

    class DAC_GPIO_OUT_CLASS extends register_base;
      field_base DAC_GPIO_OUT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAC_GPIO_OUT_F = new("DAC_GPIO_OUT", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DAC_GPIO_OUT_CLASS

    /* DAC Channel (axi_ad*) */
    class CHAN_CNTRLn_1_CLASS extends register_base;
      field_base DDS_PHASE_DW_F;
      field_base DDS_SCALE_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DDS_PHASE_DW_F = new("DDS_PHASE_DW", 21, 16, RO, 'h0, this);
        this.DDS_SCALE_1_F = new("DDS_SCALE_1", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_1_CLASS

    class CHAN_CNTRLn_2_CLASS extends register_base;
      field_base DDS_INIT_1_F;
      field_base DDS_INCR_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DDS_INIT_1_F = new("DDS_INIT_1", 31, 16, RW, 'h0, this);
        this.DDS_INCR_1_F = new("DDS_INCR_1", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_2_CLASS

    class CHAN_CNTRLn_3_CLASS extends register_base;
      field_base DDS_SCALE_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DDS_SCALE_2_F = new("DDS_SCALE_2", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_3_CLASS

    class CHAN_CNTRLn_4_CLASS extends register_base;
      field_base DDS_INIT_2_F;
      field_base DDS_INCR_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DDS_INIT_2_F = new("DDS_INIT_2", 31, 16, RW, 'h0, this);
        this.DDS_INCR_2_F = new("DDS_INCR_2", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_4_CLASS

    class CHAN_CNTRLn_5_CLASS extends register_base;
      field_base DDS_PATT_2_F;
      field_base DDS_PATT_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DDS_PATT_2_F = new("DDS_PATT_2", 31, 16, RW, 'h0, this);
        this.DDS_PATT_1_F = new("DDS_PATT_1", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_5_CLASS

    class CHAN_CNTRLn_6_CLASS extends register_base;
      field_base IQCOR_ENB_F;
      field_base DAC_LB_OWR_F;
      field_base DAC_PN_OWR_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IQCOR_ENB_F = new("IQCOR_ENB", 2, 2, RW, 'h0, this);
        this.DAC_LB_OWR_F = new("DAC_LB_OWR", 1, 1, RW, 'h0, this);
        this.DAC_PN_OWR_F = new("DAC_PN_OWR", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_6_CLASS

    class CHAN_CNTRLn_7_CLASS extends register_base;
      field_base DAC_DDS_SEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAC_DDS_SEL_F = new("DAC_DDS_SEL", 3, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_7_CLASS

    class CHAN_CNTRLn_8_CLASS extends register_base;
      field_base IQCOR_COEFF_1_F;
      field_base IQCOR_COEFF_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IQCOR_COEFF_1_F = new("IQCOR_COEFF_1", 31, 16, RW, 'h0, this);
        this.IQCOR_COEFF_2_F = new("IQCOR_COEFF_2", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_8_CLASS

    class USR_CNTRLn_3_CLASS extends register_base;
      field_base USR_DATATYPE_BE_F;
      field_base USR_DATATYPE_SIGNED_F;
      field_base USR_DATATYPE_SHIFT_F;
      field_base USR_DATATYPE_TOTAL_BITS_F;
      field_base USR_DATATYPE_BITS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.USR_DATATYPE_BE_F = new("USR_DATATYPE_BE", 25, 25, RW, 'h0, this);
        this.USR_DATATYPE_SIGNED_F = new("USR_DATATYPE_SIGNED", 24, 24, RW, 'h0, this);
        this.USR_DATATYPE_SHIFT_F = new("USR_DATATYPE_SHIFT", 23, 16, RW, 'h0, this);
        this.USR_DATATYPE_TOTAL_BITS_F = new("USR_DATATYPE_TOTAL_BITS", 15, 8, RW, 'h0, this);
        this.USR_DATATYPE_BITS_F = new("USR_DATATYPE_BITS", 7, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: USR_CNTRLn_3_CLASS

    class USR_CNTRLn_4_CLASS extends register_base;
      field_base USR_INTERPOLATION_M_F;
      field_base USR_INTERPOLATION_N_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.USR_INTERPOLATION_M_F = new("USR_INTERPOLATION_M", 31, 16, RW, 'h0, this);
        this.USR_INTERPOLATION_N_F = new("USR_INTERPOLATION_N", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: USR_CNTRLn_4_CLASS

    class USR_CNTRLn_5_CLASS extends register_base;
      field_base DAC_IQ_MODE_F;
      field_base DAC_IQ_SWAP_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAC_IQ_MODE_F = new("DAC_IQ_MODE", 0, 0, RW, 'h0, this);
        this.DAC_IQ_SWAP_F = new("DAC_IQ_SWAP", 1, 1, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: USR_CNTRLn_5_CLASS

    class CHAN_CNTRLn_9_CLASS extends register_base;
      field_base DDS_INIT_1_EXTENDED_F;
      field_base DDS_INCR_1_EXTENDED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DDS_INIT_1_EXTENDED_F = new("DDS_INIT_1_EXTENDED", 31, 16, RW, 'h0, this);
        this.DDS_INCR_1_EXTENDED_F = new("DDS_INCR_1_EXTENDED", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_9_CLASS

    class CHAN_CNTRLn_10_CLASS extends register_base;
      field_base DDS_INIT_2_EXTENDED_F;
      field_base DDS_INCR_2_EXTENDED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DDS_INIT_2_EXTENDED_F = new("DDS_INIT_2_EXTENDED", 31, 16, RW, 'h0, this);
        this.DDS_INCR_2_EXTENDED_F = new("DDS_INCR_2_EXTENDED", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_10_CLASS

    RSTN_CLASS RSTN_R;
    CNTRL_1_CLASS CNTRL_1_R;
    CNTRL_2_CLASS CNTRL_2_R;
    RATECNTRL_CLASS RATECNTRL_R;
    FRAME_CLASS FRAME_R;
    STATUS1_CLASS STATUS1_R;
    STATUS2_CLASS STATUS2_R;
    STATUS3_CLASS STATUS3_R;
    DAC_CLKSEL_CLASS DAC_CLKSEL_R;
    SYNC_STATUS_CLASS SYNC_STATUS_R;
    DRP_CNTRL_CLASS DRP_CNTRL_R;
    DRP_STATUS_CLASS DRP_STATUS_R;
    DRP_WDATA_CLASS DRP_WDATA_R;
    DRP_RDATA_CLASS DRP_RDATA_R;
    DAC_CUSTOM_RD_CLASS DAC_CUSTOM_RD_R;
    DAC_CUSTOM_WR_CLASS DAC_CUSTOM_WR_R;
    UI_STATUS_CLASS UI_STATUS_R;
    DAC_CUSTOM_CTRL_CLASS DAC_CUSTOM_CTRL_R;
    USR_CNTRL_1_CLASS USR_CNTRL_1_R;
    DAC_GPIO_IN_CLASS DAC_GPIO_IN_R;
    DAC_GPIO_OUT_CLASS DAC_GPIO_OUT_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRLn_1_R [15:0];
    CHAN_CNTRLn_2_CLASS CHAN_CNTRLn_2_R [15:0];
    CHAN_CNTRLn_3_CLASS CHAN_CNTRLn_3_R [15:0];
    CHAN_CNTRLn_4_CLASS CHAN_CNTRLn_4_R [15:0];
    CHAN_CNTRLn_5_CLASS CHAN_CNTRLn_5_R [15:0];
    CHAN_CNTRLn_6_CLASS CHAN_CNTRLn_6_R [15:0];
    CHAN_CNTRLn_7_CLASS CHAN_CNTRLn_7_R [15:0];
    CHAN_CNTRLn_8_CLASS CHAN_CNTRLn_8_R [15:0];
    USR_CNTRLn_3_CLASS USR_CNTRLn_3_R [15:0];
    USR_CNTRLn_4_CLASS USR_CNTRLn_4_R [15:0];
    USR_CNTRLn_5_CLASS USR_CNTRLn_5_R [15:0];
    CHAN_CNTRLn_9_CLASS CHAN_CNTRLn_9_R [15:0];
    CHAN_CNTRLn_10_CLASS CHAN_CNTRLn_10_R [15:0];

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.RSTN_R = new("RSTN", 'h40, this);
      this.CNTRL_1_R = new("CNTRL_1", 'h44, this);
      this.CNTRL_2_R = new("CNTRL_2", 'h48, this);
      this.RATECNTRL_R = new("RATECNTRL", 'h4c, this);
      this.FRAME_R = new("FRAME", 'h50, this);
      this.STATUS1_R = new("STATUS1", 'h54, this);
      this.STATUS2_R = new("STATUS2", 'h58, this);
      this.STATUS3_R = new("STATUS3", 'h5c, this);
      this.DAC_CLKSEL_R = new("DAC_CLKSEL", 'h60, this);
      this.SYNC_STATUS_R = new("SYNC_STATUS", 'h68, this);
      this.DRP_CNTRL_R = new("DRP_CNTRL", 'h70, this);
      this.DRP_STATUS_R = new("DRP_STATUS", 'h74, this);
      this.DRP_WDATA_R = new("DRP_WDATA", 'h78, this);
      this.DRP_RDATA_R = new("DRP_RDATA", 'h7c, this);
      this.DAC_CUSTOM_RD_R = new("DAC_CUSTOM_RD", 'h80, this);
      this.DAC_CUSTOM_WR_R = new("DAC_CUSTOM_WR", 'h84, this);
      this.UI_STATUS_R = new("UI_STATUS", 'h88, this);
      this.DAC_CUSTOM_CTRL_R = new("DAC_CUSTOM_CTRL", 'h8c, this);
      this.USR_CNTRL_1_R = new("USR_CNTRL_1", 'ha0, this);
      this.DAC_GPIO_IN_R = new("DAC_GPIO_IN", 'hb8, this);
      this.DAC_GPIO_OUT_R = new("DAC_GPIO_OUT", 'hbc, this);
      for (int i=0; i<16; i++) begin
        this.CHAN_CNTRLn_1_R[i] = new($sformatf("CHAN_CNTRL%0d_1", i), 'h400 + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.CHAN_CNTRLn_2_R[i] = new($sformatf("CHAN_CNTRL%0d_2", i), 'h404 + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.CHAN_CNTRLn_3_R[i] = new($sformatf("CHAN_CNTRL%0d_3", i), 'h408 + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.CHAN_CNTRLn_4_R[i] = new($sformatf("CHAN_CNTRL%0d_4", i), 'h40c + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.CHAN_CNTRLn_5_R[i] = new($sformatf("CHAN_CNTRL%0d_5", i), 'h410 + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.CHAN_CNTRLn_6_R[i] = new($sformatf("CHAN_CNTRL%0d_6", i), 'h414 + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.CHAN_CNTRLn_7_R[i] = new($sformatf("CHAN_CNTRL%0d_7", i), 'h418 + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.CHAN_CNTRLn_8_R[i] = new($sformatf("CHAN_CNTRL%0d_8", i), 'h41c + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.USR_CNTRLn_3_R[i] = new($sformatf("USR_CNTRL%0d_3", i), 'h420 + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.USR_CNTRLn_4_R[i] = new($sformatf("USR_CNTRL%0d_4", i), 'h424 + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.USR_CNTRLn_5_R[i] = new($sformatf("USR_CNTRL%0d_5", i), 'h428 + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.CHAN_CNTRLn_9_R[i] = new($sformatf("CHAN_CNTRL%0d_9", i), 'h42c + 'h22 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.CHAN_CNTRLn_10_R[i] = new($sformatf("CHAN_CNTRL%0d_10", i), 'h430 + 'h22 * i * 4, this);
      end

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_dac

endpackage: adi_regmap_dac_pkg
