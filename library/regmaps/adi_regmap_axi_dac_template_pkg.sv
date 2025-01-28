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

package adi_regmap_axi_dac_template_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_axi_dac_template extends adi_regmap;

    /* AXI TEMPLATE DAC Common (axi_template) */
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

    /* AXI TEMPLATE DAC Channel (axi_template_dac_channel) */
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
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL0_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL1_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL2_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL3_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL4_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL5_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL6_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL7_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL8_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL9_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL10_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL11_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL12_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL13_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL14_1_R;
    CHAN_CNTRLn_1_CLASS CHAN_CNTRL15_1_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL0_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL1_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL2_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL3_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL4_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL5_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL6_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL7_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL8_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL9_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL10_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL11_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL12_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL13_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL14_2_R;
    CHAN_CNTRLn_2_CLASS CHAN_CNTRL15_2_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL0_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL1_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL2_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL3_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL4_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL5_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL6_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL7_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL8_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL9_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL10_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL11_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL12_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL13_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL14_3_R;
    CHAN_CNTRLn_3_CLASS CHAN_CNTRL15_3_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL0_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL1_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL2_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL3_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL4_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL5_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL6_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL7_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL8_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL9_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL10_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL11_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL12_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL13_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL14_4_R;
    CHAN_CNTRLn_4_CLASS CHAN_CNTRL15_4_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL0_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL1_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL2_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL3_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL4_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL5_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL6_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL7_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL8_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL9_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL10_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL11_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL12_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL13_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL14_5_R;
    CHAN_CNTRLn_5_CLASS CHAN_CNTRL15_5_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL0_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL1_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL2_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL3_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL4_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL5_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL6_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL7_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL8_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL9_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL10_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL11_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL12_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL13_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL14_6_R;
    CHAN_CNTRLn_6_CLASS CHAN_CNTRL15_6_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL0_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL1_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL2_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL3_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL4_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL5_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL6_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL7_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL8_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL9_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL10_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL11_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL12_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL13_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL14_7_R;
    CHAN_CNTRLn_7_CLASS CHAN_CNTRL15_7_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL0_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL1_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL2_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL3_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL4_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL5_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL6_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL7_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL8_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL9_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL10_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL11_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL12_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL13_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL14_8_R;
    CHAN_CNTRLn_8_CLASS CHAN_CNTRL15_8_R;
    USR_CNTRLn_3_CLASS USR_CNTRL0_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL1_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL2_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL3_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL4_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL5_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL6_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL7_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL8_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL9_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL10_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL11_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL12_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL13_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL14_3_R;
    USR_CNTRLn_3_CLASS USR_CNTRL15_3_R;
    USR_CNTRLn_4_CLASS USR_CNTRL0_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL1_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL2_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL3_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL4_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL5_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL6_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL7_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL8_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL9_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL10_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL11_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL12_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL13_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL14_4_R;
    USR_CNTRLn_4_CLASS USR_CNTRL15_4_R;
    USR_CNTRLn_5_CLASS USR_CNTRL0_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL1_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL2_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL3_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL4_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL5_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL6_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL7_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL8_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL9_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL10_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL11_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL12_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL13_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL14_5_R;
    USR_CNTRLn_5_CLASS USR_CNTRL15_5_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL0_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL1_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL2_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL3_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL4_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL5_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL6_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL7_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL8_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL9_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL10_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL11_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL12_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL13_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL14_9_R;
    CHAN_CNTRLn_9_CLASS CHAN_CNTRL15_9_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL0_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL1_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL2_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL3_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL4_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL5_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL6_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL7_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL8_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL9_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL10_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL11_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL12_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL13_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL14_10_R;
    CHAN_CNTRLn_10_CLASS CHAN_CNTRL15_10_R;

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
      this.CHAN_CNTRL0_1_R = new("CHAN_CNTRL0_1", 'h400, this);
      this.CHAN_CNTRL1_1_R = new("CHAN_CNTRL1_1", 'h458, this);
      this.CHAN_CNTRL2_1_R = new("CHAN_CNTRL2_1", 'h4b0, this);
      this.CHAN_CNTRL3_1_R = new("CHAN_CNTRL3_1", 'h508, this);
      this.CHAN_CNTRL4_1_R = new("CHAN_CNTRL4_1", 'h560, this);
      this.CHAN_CNTRL5_1_R = new("CHAN_CNTRL5_1", 'h5b8, this);
      this.CHAN_CNTRL6_1_R = new("CHAN_CNTRL6_1", 'h610, this);
      this.CHAN_CNTRL7_1_R = new("CHAN_CNTRL7_1", 'h668, this);
      this.CHAN_CNTRL8_1_R = new("CHAN_CNTRL8_1", 'h6c0, this);
      this.CHAN_CNTRL9_1_R = new("CHAN_CNTRL9_1", 'h718, this);
      this.CHAN_CNTRL10_1_R = new("CHAN_CNTRL10_1", 'h770, this);
      this.CHAN_CNTRL11_1_R = new("CHAN_CNTRL11_1", 'h7c8, this);
      this.CHAN_CNTRL12_1_R = new("CHAN_CNTRL12_1", 'h820, this);
      this.CHAN_CNTRL13_1_R = new("CHAN_CNTRL13_1", 'h878, this);
      this.CHAN_CNTRL14_1_R = new("CHAN_CNTRL14_1", 'h8d0, this);
      this.CHAN_CNTRL15_1_R = new("CHAN_CNTRL15_1", 'h928, this);
      this.CHAN_CNTRL0_2_R = new("CHAN_CNTRL0_2", 'h404, this);
      this.CHAN_CNTRL1_2_R = new("CHAN_CNTRL1_2", 'h45c, this);
      this.CHAN_CNTRL2_2_R = new("CHAN_CNTRL2_2", 'h4b4, this);
      this.CHAN_CNTRL3_2_R = new("CHAN_CNTRL3_2", 'h50c, this);
      this.CHAN_CNTRL4_2_R = new("CHAN_CNTRL4_2", 'h564, this);
      this.CHAN_CNTRL5_2_R = new("CHAN_CNTRL5_2", 'h5bc, this);
      this.CHAN_CNTRL6_2_R = new("CHAN_CNTRL6_2", 'h614, this);
      this.CHAN_CNTRL7_2_R = new("CHAN_CNTRL7_2", 'h66c, this);
      this.CHAN_CNTRL8_2_R = new("CHAN_CNTRL8_2", 'h6c4, this);
      this.CHAN_CNTRL9_2_R = new("CHAN_CNTRL9_2", 'h71c, this);
      this.CHAN_CNTRL10_2_R = new("CHAN_CNTRL10_2", 'h774, this);
      this.CHAN_CNTRL11_2_R = new("CHAN_CNTRL11_2", 'h7cc, this);
      this.CHAN_CNTRL12_2_R = new("CHAN_CNTRL12_2", 'h824, this);
      this.CHAN_CNTRL13_2_R = new("CHAN_CNTRL13_2", 'h87c, this);
      this.CHAN_CNTRL14_2_R = new("CHAN_CNTRL14_2", 'h8d4, this);
      this.CHAN_CNTRL15_2_R = new("CHAN_CNTRL15_2", 'h92c, this);
      this.CHAN_CNTRL0_3_R = new("CHAN_CNTRL0_3", 'h408, this);
      this.CHAN_CNTRL1_3_R = new("CHAN_CNTRL1_3", 'h460, this);
      this.CHAN_CNTRL2_3_R = new("CHAN_CNTRL2_3", 'h4b8, this);
      this.CHAN_CNTRL3_3_R = new("CHAN_CNTRL3_3", 'h510, this);
      this.CHAN_CNTRL4_3_R = new("CHAN_CNTRL4_3", 'h568, this);
      this.CHAN_CNTRL5_3_R = new("CHAN_CNTRL5_3", 'h5c0, this);
      this.CHAN_CNTRL6_3_R = new("CHAN_CNTRL6_3", 'h618, this);
      this.CHAN_CNTRL7_3_R = new("CHAN_CNTRL7_3", 'h670, this);
      this.CHAN_CNTRL8_3_R = new("CHAN_CNTRL8_3", 'h6c8, this);
      this.CHAN_CNTRL9_3_R = new("CHAN_CNTRL9_3", 'h720, this);
      this.CHAN_CNTRL10_3_R = new("CHAN_CNTRL10_3", 'h778, this);
      this.CHAN_CNTRL11_3_R = new("CHAN_CNTRL11_3", 'h7d0, this);
      this.CHAN_CNTRL12_3_R = new("CHAN_CNTRL12_3", 'h828, this);
      this.CHAN_CNTRL13_3_R = new("CHAN_CNTRL13_3", 'h880, this);
      this.CHAN_CNTRL14_3_R = new("CHAN_CNTRL14_3", 'h8d8, this);
      this.CHAN_CNTRL15_3_R = new("CHAN_CNTRL15_3", 'h930, this);
      this.CHAN_CNTRL0_4_R = new("CHAN_CNTRL0_4", 'h40c, this);
      this.CHAN_CNTRL1_4_R = new("CHAN_CNTRL1_4", 'h464, this);
      this.CHAN_CNTRL2_4_R = new("CHAN_CNTRL2_4", 'h4bc, this);
      this.CHAN_CNTRL3_4_R = new("CHAN_CNTRL3_4", 'h514, this);
      this.CHAN_CNTRL4_4_R = new("CHAN_CNTRL4_4", 'h56c, this);
      this.CHAN_CNTRL5_4_R = new("CHAN_CNTRL5_4", 'h5c4, this);
      this.CHAN_CNTRL6_4_R = new("CHAN_CNTRL6_4", 'h61c, this);
      this.CHAN_CNTRL7_4_R = new("CHAN_CNTRL7_4", 'h674, this);
      this.CHAN_CNTRL8_4_R = new("CHAN_CNTRL8_4", 'h6cc, this);
      this.CHAN_CNTRL9_4_R = new("CHAN_CNTRL9_4", 'h724, this);
      this.CHAN_CNTRL10_4_R = new("CHAN_CNTRL10_4", 'h77c, this);
      this.CHAN_CNTRL11_4_R = new("CHAN_CNTRL11_4", 'h7d4, this);
      this.CHAN_CNTRL12_4_R = new("CHAN_CNTRL12_4", 'h82c, this);
      this.CHAN_CNTRL13_4_R = new("CHAN_CNTRL13_4", 'h884, this);
      this.CHAN_CNTRL14_4_R = new("CHAN_CNTRL14_4", 'h8dc, this);
      this.CHAN_CNTRL15_4_R = new("CHAN_CNTRL15_4", 'h934, this);
      this.CHAN_CNTRL0_5_R = new("CHAN_CNTRL0_5", 'h410, this);
      this.CHAN_CNTRL1_5_R = new("CHAN_CNTRL1_5", 'h468, this);
      this.CHAN_CNTRL2_5_R = new("CHAN_CNTRL2_5", 'h4c0, this);
      this.CHAN_CNTRL3_5_R = new("CHAN_CNTRL3_5", 'h518, this);
      this.CHAN_CNTRL4_5_R = new("CHAN_CNTRL4_5", 'h570, this);
      this.CHAN_CNTRL5_5_R = new("CHAN_CNTRL5_5", 'h5c8, this);
      this.CHAN_CNTRL6_5_R = new("CHAN_CNTRL6_5", 'h620, this);
      this.CHAN_CNTRL7_5_R = new("CHAN_CNTRL7_5", 'h678, this);
      this.CHAN_CNTRL8_5_R = new("CHAN_CNTRL8_5", 'h6d0, this);
      this.CHAN_CNTRL9_5_R = new("CHAN_CNTRL9_5", 'h728, this);
      this.CHAN_CNTRL10_5_R = new("CHAN_CNTRL10_5", 'h780, this);
      this.CHAN_CNTRL11_5_R = new("CHAN_CNTRL11_5", 'h7d8, this);
      this.CHAN_CNTRL12_5_R = new("CHAN_CNTRL12_5", 'h830, this);
      this.CHAN_CNTRL13_5_R = new("CHAN_CNTRL13_5", 'h888, this);
      this.CHAN_CNTRL14_5_R = new("CHAN_CNTRL14_5", 'h8e0, this);
      this.CHAN_CNTRL15_5_R = new("CHAN_CNTRL15_5", 'h938, this);
      this.CHAN_CNTRL0_6_R = new("CHAN_CNTRL0_6", 'h414, this);
      this.CHAN_CNTRL1_6_R = new("CHAN_CNTRL1_6", 'h46c, this);
      this.CHAN_CNTRL2_6_R = new("CHAN_CNTRL2_6", 'h4c4, this);
      this.CHAN_CNTRL3_6_R = new("CHAN_CNTRL3_6", 'h51c, this);
      this.CHAN_CNTRL4_6_R = new("CHAN_CNTRL4_6", 'h574, this);
      this.CHAN_CNTRL5_6_R = new("CHAN_CNTRL5_6", 'h5cc, this);
      this.CHAN_CNTRL6_6_R = new("CHAN_CNTRL6_6", 'h624, this);
      this.CHAN_CNTRL7_6_R = new("CHAN_CNTRL7_6", 'h67c, this);
      this.CHAN_CNTRL8_6_R = new("CHAN_CNTRL8_6", 'h6d4, this);
      this.CHAN_CNTRL9_6_R = new("CHAN_CNTRL9_6", 'h72c, this);
      this.CHAN_CNTRL10_6_R = new("CHAN_CNTRL10_6", 'h784, this);
      this.CHAN_CNTRL11_6_R = new("CHAN_CNTRL11_6", 'h7dc, this);
      this.CHAN_CNTRL12_6_R = new("CHAN_CNTRL12_6", 'h834, this);
      this.CHAN_CNTRL13_6_R = new("CHAN_CNTRL13_6", 'h88c, this);
      this.CHAN_CNTRL14_6_R = new("CHAN_CNTRL14_6", 'h8e4, this);
      this.CHAN_CNTRL15_6_R = new("CHAN_CNTRL15_6", 'h93c, this);
      this.CHAN_CNTRL0_7_R = new("CHAN_CNTRL0_7", 'h418, this);
      this.CHAN_CNTRL1_7_R = new("CHAN_CNTRL1_7", 'h470, this);
      this.CHAN_CNTRL2_7_R = new("CHAN_CNTRL2_7", 'h4c8, this);
      this.CHAN_CNTRL3_7_R = new("CHAN_CNTRL3_7", 'h520, this);
      this.CHAN_CNTRL4_7_R = new("CHAN_CNTRL4_7", 'h578, this);
      this.CHAN_CNTRL5_7_R = new("CHAN_CNTRL5_7", 'h5d0, this);
      this.CHAN_CNTRL6_7_R = new("CHAN_CNTRL6_7", 'h628, this);
      this.CHAN_CNTRL7_7_R = new("CHAN_CNTRL7_7", 'h680, this);
      this.CHAN_CNTRL8_7_R = new("CHAN_CNTRL8_7", 'h6d8, this);
      this.CHAN_CNTRL9_7_R = new("CHAN_CNTRL9_7", 'h730, this);
      this.CHAN_CNTRL10_7_R = new("CHAN_CNTRL10_7", 'h788, this);
      this.CHAN_CNTRL11_7_R = new("CHAN_CNTRL11_7", 'h7e0, this);
      this.CHAN_CNTRL12_7_R = new("CHAN_CNTRL12_7", 'h838, this);
      this.CHAN_CNTRL13_7_R = new("CHAN_CNTRL13_7", 'h890, this);
      this.CHAN_CNTRL14_7_R = new("CHAN_CNTRL14_7", 'h8e8, this);
      this.CHAN_CNTRL15_7_R = new("CHAN_CNTRL15_7", 'h940, this);
      this.CHAN_CNTRL0_8_R = new("CHAN_CNTRL0_8", 'h41c, this);
      this.CHAN_CNTRL1_8_R = new("CHAN_CNTRL1_8", 'h474, this);
      this.CHAN_CNTRL2_8_R = new("CHAN_CNTRL2_8", 'h4cc, this);
      this.CHAN_CNTRL3_8_R = new("CHAN_CNTRL3_8", 'h524, this);
      this.CHAN_CNTRL4_8_R = new("CHAN_CNTRL4_8", 'h57c, this);
      this.CHAN_CNTRL5_8_R = new("CHAN_CNTRL5_8", 'h5d4, this);
      this.CHAN_CNTRL6_8_R = new("CHAN_CNTRL6_8", 'h62c, this);
      this.CHAN_CNTRL7_8_R = new("CHAN_CNTRL7_8", 'h684, this);
      this.CHAN_CNTRL8_8_R = new("CHAN_CNTRL8_8", 'h6dc, this);
      this.CHAN_CNTRL9_8_R = new("CHAN_CNTRL9_8", 'h734, this);
      this.CHAN_CNTRL10_8_R = new("CHAN_CNTRL10_8", 'h78c, this);
      this.CHAN_CNTRL11_8_R = new("CHAN_CNTRL11_8", 'h7e4, this);
      this.CHAN_CNTRL12_8_R = new("CHAN_CNTRL12_8", 'h83c, this);
      this.CHAN_CNTRL13_8_R = new("CHAN_CNTRL13_8", 'h894, this);
      this.CHAN_CNTRL14_8_R = new("CHAN_CNTRL14_8", 'h8ec, this);
      this.CHAN_CNTRL15_8_R = new("CHAN_CNTRL15_8", 'h944, this);
      this.USR_CNTRL0_3_R = new("USR_CNTRL0_3", 'h420, this);
      this.USR_CNTRL1_3_R = new("USR_CNTRL1_3", 'h478, this);
      this.USR_CNTRL2_3_R = new("USR_CNTRL2_3", 'h4d0, this);
      this.USR_CNTRL3_3_R = new("USR_CNTRL3_3", 'h528, this);
      this.USR_CNTRL4_3_R = new("USR_CNTRL4_3", 'h580, this);
      this.USR_CNTRL5_3_R = new("USR_CNTRL5_3", 'h5d8, this);
      this.USR_CNTRL6_3_R = new("USR_CNTRL6_3", 'h630, this);
      this.USR_CNTRL7_3_R = new("USR_CNTRL7_3", 'h688, this);
      this.USR_CNTRL8_3_R = new("USR_CNTRL8_3", 'h6e0, this);
      this.USR_CNTRL9_3_R = new("USR_CNTRL9_3", 'h738, this);
      this.USR_CNTRL10_3_R = new("USR_CNTRL10_3", 'h790, this);
      this.USR_CNTRL11_3_R = new("USR_CNTRL11_3", 'h7e8, this);
      this.USR_CNTRL12_3_R = new("USR_CNTRL12_3", 'h840, this);
      this.USR_CNTRL13_3_R = new("USR_CNTRL13_3", 'h898, this);
      this.USR_CNTRL14_3_R = new("USR_CNTRL14_3", 'h8f0, this);
      this.USR_CNTRL15_3_R = new("USR_CNTRL15_3", 'h948, this);
      this.USR_CNTRL0_4_R = new("USR_CNTRL0_4", 'h424, this);
      this.USR_CNTRL1_4_R = new("USR_CNTRL1_4", 'h47c, this);
      this.USR_CNTRL2_4_R = new("USR_CNTRL2_4", 'h4d4, this);
      this.USR_CNTRL3_4_R = new("USR_CNTRL3_4", 'h52c, this);
      this.USR_CNTRL4_4_R = new("USR_CNTRL4_4", 'h584, this);
      this.USR_CNTRL5_4_R = new("USR_CNTRL5_4", 'h5dc, this);
      this.USR_CNTRL6_4_R = new("USR_CNTRL6_4", 'h634, this);
      this.USR_CNTRL7_4_R = new("USR_CNTRL7_4", 'h68c, this);
      this.USR_CNTRL8_4_R = new("USR_CNTRL8_4", 'h6e4, this);
      this.USR_CNTRL9_4_R = new("USR_CNTRL9_4", 'h73c, this);
      this.USR_CNTRL10_4_R = new("USR_CNTRL10_4", 'h794, this);
      this.USR_CNTRL11_4_R = new("USR_CNTRL11_4", 'h7ec, this);
      this.USR_CNTRL12_4_R = new("USR_CNTRL12_4", 'h844, this);
      this.USR_CNTRL13_4_R = new("USR_CNTRL13_4", 'h89c, this);
      this.USR_CNTRL14_4_R = new("USR_CNTRL14_4", 'h8f4, this);
      this.USR_CNTRL15_4_R = new("USR_CNTRL15_4", 'h94c, this);
      this.USR_CNTRL0_5_R = new("USR_CNTRL0_5", 'h428, this);
      this.USR_CNTRL1_5_R = new("USR_CNTRL1_5", 'h480, this);
      this.USR_CNTRL2_5_R = new("USR_CNTRL2_5", 'h4d8, this);
      this.USR_CNTRL3_5_R = new("USR_CNTRL3_5", 'h530, this);
      this.USR_CNTRL4_5_R = new("USR_CNTRL4_5", 'h588, this);
      this.USR_CNTRL5_5_R = new("USR_CNTRL5_5", 'h5e0, this);
      this.USR_CNTRL6_5_R = new("USR_CNTRL6_5", 'h638, this);
      this.USR_CNTRL7_5_R = new("USR_CNTRL7_5", 'h690, this);
      this.USR_CNTRL8_5_R = new("USR_CNTRL8_5", 'h6e8, this);
      this.USR_CNTRL9_5_R = new("USR_CNTRL9_5", 'h740, this);
      this.USR_CNTRL10_5_R = new("USR_CNTRL10_5", 'h798, this);
      this.USR_CNTRL11_5_R = new("USR_CNTRL11_5", 'h7f0, this);
      this.USR_CNTRL12_5_R = new("USR_CNTRL12_5", 'h848, this);
      this.USR_CNTRL13_5_R = new("USR_CNTRL13_5", 'h8a0, this);
      this.USR_CNTRL14_5_R = new("USR_CNTRL14_5", 'h8f8, this);
      this.USR_CNTRL15_5_R = new("USR_CNTRL15_5", 'h950, this);
      this.CHAN_CNTRL0_9_R = new("CHAN_CNTRL0_9", 'h42c, this);
      this.CHAN_CNTRL1_9_R = new("CHAN_CNTRL1_9", 'h484, this);
      this.CHAN_CNTRL2_9_R = new("CHAN_CNTRL2_9", 'h4dc, this);
      this.CHAN_CNTRL3_9_R = new("CHAN_CNTRL3_9", 'h534, this);
      this.CHAN_CNTRL4_9_R = new("CHAN_CNTRL4_9", 'h58c, this);
      this.CHAN_CNTRL5_9_R = new("CHAN_CNTRL5_9", 'h5e4, this);
      this.CHAN_CNTRL6_9_R = new("CHAN_CNTRL6_9", 'h63c, this);
      this.CHAN_CNTRL7_9_R = new("CHAN_CNTRL7_9", 'h694, this);
      this.CHAN_CNTRL8_9_R = new("CHAN_CNTRL8_9", 'h6ec, this);
      this.CHAN_CNTRL9_9_R = new("CHAN_CNTRL9_9", 'h744, this);
      this.CHAN_CNTRL10_9_R = new("CHAN_CNTRL10_9", 'h79c, this);
      this.CHAN_CNTRL11_9_R = new("CHAN_CNTRL11_9", 'h7f4, this);
      this.CHAN_CNTRL12_9_R = new("CHAN_CNTRL12_9", 'h84c, this);
      this.CHAN_CNTRL13_9_R = new("CHAN_CNTRL13_9", 'h8a4, this);
      this.CHAN_CNTRL14_9_R = new("CHAN_CNTRL14_9", 'h8fc, this);
      this.CHAN_CNTRL15_9_R = new("CHAN_CNTRL15_9", 'h954, this);
      this.CHAN_CNTRL0_10_R = new("CHAN_CNTRL0_10", 'h430, this);
      this.CHAN_CNTRL1_10_R = new("CHAN_CNTRL1_10", 'h488, this);
      this.CHAN_CNTRL2_10_R = new("CHAN_CNTRL2_10", 'h4e0, this);
      this.CHAN_CNTRL3_10_R = new("CHAN_CNTRL3_10", 'h538, this);
      this.CHAN_CNTRL4_10_R = new("CHAN_CNTRL4_10", 'h590, this);
      this.CHAN_CNTRL5_10_R = new("CHAN_CNTRL5_10", 'h5e8, this);
      this.CHAN_CNTRL6_10_R = new("CHAN_CNTRL6_10", 'h640, this);
      this.CHAN_CNTRL7_10_R = new("CHAN_CNTRL7_10", 'h698, this);
      this.CHAN_CNTRL8_10_R = new("CHAN_CNTRL8_10", 'h6f0, this);
      this.CHAN_CNTRL9_10_R = new("CHAN_CNTRL9_10", 'h748, this);
      this.CHAN_CNTRL10_10_R = new("CHAN_CNTRL10_10", 'h7a0, this);
      this.CHAN_CNTRL11_10_R = new("CHAN_CNTRL11_10", 'h7f8, this);
      this.CHAN_CNTRL12_10_R = new("CHAN_CNTRL12_10", 'h850, this);
      this.CHAN_CNTRL13_10_R = new("CHAN_CNTRL13_10", 'h8a8, this);
      this.CHAN_CNTRL14_10_R = new("CHAN_CNTRL14_10", 'h900, this);
      this.CHAN_CNTRL15_10_R = new("CHAN_CNTRL15_10", 'h958, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_axi_dac_template

endpackage: adi_regmap_axi_dac_template_pkg
