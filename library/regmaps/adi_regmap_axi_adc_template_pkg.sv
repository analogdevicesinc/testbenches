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

package adi_regmap_axi_adc_template_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_axi_adc_template extends adi_regmap;

    /* AXI TEMPLATE ADC Common (axi_template) */
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

    class CNTRL_CLASS extends register_base;
      field_base SDR_DDR_N_F;
      field_base SYMB_OP_F;
      field_base SYMB_8_16B_F;
      field_base NUM_LANES_F;
      field_base SYNC_F;
      field_base R1_MODE_F;
      field_base DDR_EDGESEL_F;
      field_base PIN_MODE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDR_DDR_N_F = new("SDR_DDR_N", 16, 16, RW, 'h0, this);
        this.SYMB_OP_F = new("SYMB_OP", 15, 15, RW, 'h0, this);
        this.SYMB_8_16B_F = new("SYMB_8_16B", 14, 14, RW, 'h0, this);
        this.NUM_LANES_F = new("NUM_LANES", 12, 8, RW, 'h0, this);
        this.SYNC_F = new("SYNC", 3, 3, RW, 'h0, this);
        this.R1_MODE_F = new("R1_MODE", 2, 2, RW, 'h0, this);
        this.DDR_EDGESEL_F = new("DDR_EDGESEL", 1, 1, RW, 'h0, this);
        this.PIN_MODE_F = new("PIN_MODE", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CNTRL_CLASS

    class CNTRL_2_CLASS extends register_base;
      field_base EXT_SYNC_ARM_F;
      field_base EXT_SYNC_DISARM_F;
      field_base MANUAL_SYNC_REQUEST_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.EXT_SYNC_ARM_F = new("EXT_SYNC_ARM", 1, 1, RW, 'h0, this);
        this.EXT_SYNC_DISARM_F = new("EXT_SYNC_DISARM", 2, 2, RW, 'h0, this);
        this.MANUAL_SYNC_REQUEST_F = new("MANUAL_SYNC_REQUEST", 8, 8, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CNTRL_2_CLASS

    class CNTRL_3_CLASS extends register_base;
      field_base CRC_EN_F;
      field_base CUSTOM_CONTROL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CRC_EN_F = new("CRC_EN", 8, 8, RW, 'h0, this);
        this.CUSTOM_CONTROL_F = new("CUSTOM_CONTROL", 7, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CNTRL_3_CLASS

    class CLK_FREQ_CLASS extends register_base;
      field_base CLK_FREQ_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CLK_FREQ_F = new("CLK_FREQ", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CLK_FREQ_CLASS

    class CLK_RATIO_CLASS extends register_base;
      field_base CLK_RATIO_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CLK_RATIO_F = new("CLK_RATIO", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CLK_RATIO_CLASS

    class STATUS_CLASS extends register_base;
      field_base ADC_CTRL_STATUS_F;
      field_base PN_ERR_F;
      field_base PN_OOS_F;
      field_base OVER_RANGE_F;
      field_base STATUS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADC_CTRL_STATUS_F = new("ADC_CTRL_STATUS", 4, 4, RO, 'h0, this);
        this.PN_ERR_F = new("PN_ERR", 3, 3, RO, 'h0, this);
        this.PN_OOS_F = new("PN_OOS", 2, 2, RO, 'h0, this);
        this.OVER_RANGE_F = new("OVER_RANGE", 1, 1, RO, 'h0, this);
        this.STATUS_F = new("STATUS", 0, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: STATUS_CLASS

    class SYNC_STATUS_CLASS extends register_base;
      field_base ADC_SYNC_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADC_SYNC_F = new("ADC_SYNC", 0, 0, RO, 'h0, this);

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

    class ADC_CONFIG_WR_CLASS extends register_base;
      field_base ADC_CONFIG_WR_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADC_CONFIG_WR_F = new("ADC_CONFIG_WR", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ADC_CONFIG_WR_CLASS

    class ADC_CONFIG_RD_CLASS extends register_base;
      field_base ADC_CONFIG_RD_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADC_CONFIG_RD_F = new("ADC_CONFIG_RD", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ADC_CONFIG_RD_CLASS

    class UI_STATUS_CLASS extends register_base;
      field_base UI_OVF_F;
      field_base UI_UNF_F;
      field_base UI_RESERVED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.UI_OVF_F = new("UI_OVF", 2, 2, RW1C, 'h0, this);
        this.UI_UNF_F = new("UI_UNF", 1, 1, RW1C, 'h0, this);
        this.UI_RESERVED_F = new("UI_RESERVED", 0, 0, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: UI_STATUS_CLASS

    class ADC_CONFIG_CTRL_CLASS extends register_base;
      field_base ADC_CONFIG_CTRL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADC_CONFIG_CTRL_F = new("ADC_CONFIG_CTRL", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ADC_CONFIG_CTRL_CLASS

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

    class ADC_START_CODE_CLASS extends register_base;
      field_base ADC_START_CODE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADC_START_CODE_F = new("ADC_START_CODE", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ADC_START_CODE_CLASS

    class ADC_GPIO_IN_CLASS extends register_base;
      field_base ADC_GPIO_IN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADC_GPIO_IN_F = new("ADC_GPIO_IN", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ADC_GPIO_IN_CLASS

    class ADC_GPIO_OUT_CLASS extends register_base;
      field_base ADC_GPIO_OUT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADC_GPIO_OUT_F = new("ADC_GPIO_OUT", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ADC_GPIO_OUT_CLASS

    class PPS_COUNTER_CLASS extends register_base;
      field_base PPS_COUNTER_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PPS_COUNTER_F = new("PPS_COUNTER", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PPS_COUNTER_CLASS

    class PPS_STATUS_CLASS extends register_base;
      field_base PPS_STATUS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PPS_STATUS_F = new("PPS_STATUS", 0, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PPS_STATUS_CLASS

    /* AXI TEMPLATE ADC Channel (axi_template_adc_channel) */
    class CHAN_CNTRLn_CLASS extends register_base;
      field_base ADC_LB_OWR_F;
      field_base ADC_PN_SEL_OWR_F;
      field_base IQCOR_ENB_F;
      field_base DCFILT_ENB_F;
      field_base FORMAT_SIGNEXT_F;
      field_base FORMAT_TYPE_F;
      field_base FORMAT_ENABLE_F;
      field_base ADC_PN_TYPE_OWR_F;
      field_base ENABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADC_LB_OWR_F = new("ADC_LB_OWR", 11, 11, RW, 'h0, this);
        this.ADC_PN_SEL_OWR_F = new("ADC_PN_SEL_OWR", 10, 10, RW, 'h0, this);
        this.IQCOR_ENB_F = new("IQCOR_ENB", 9, 9, RW, 'h0, this);
        this.DCFILT_ENB_F = new("DCFILT_ENB", 8, 8, RW, 'h0, this);
        this.FORMAT_SIGNEXT_F = new("FORMAT_SIGNEXT", 6, 6, RW, 'h0, this);
        this.FORMAT_TYPE_F = new("FORMAT_TYPE", 5, 5, RW, 'h0, this);
        this.FORMAT_ENABLE_F = new("FORMAT_ENABLE", 4, 4, RW, 'h0, this);
        this.ADC_PN_TYPE_OWR_F = new("ADC_PN_TYPE_OWR", 1, 1, RW, 'h0, this);
        this.ENABLE_F = new("ENABLE", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_CLASS

    class CHAN_STATUSn_CLASS extends register_base;
      field_base CRC_ERR_F;
      field_base STATUS_HEADER_F;
      field_base PN_ERR_F;
      field_base PN_OOS_F;
      field_base OVER_RANGE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CRC_ERR_F = new("CRC_ERR", 12, 12, RW1C, 'h0, this);
        this.STATUS_HEADER_F = new("STATUS_HEADER", 11, 4, RO, 'h0, this);
        this.PN_ERR_F = new("PN_ERR", 2, 2, RW1C, 'h0, this);
        this.PN_OOS_F = new("PN_OOS", 1, 1, RW1C, 'h0, this);
        this.OVER_RANGE_F = new("OVER_RANGE", 0, 0, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_STATUSn_CLASS

    class CHAN_RAW_DATAn_CLASS extends register_base;
      field_base ADC_READ_DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADC_READ_DATA_F = new("ADC_READ_DATA", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_RAW_DATAn_CLASS

    class CHAN_CNTRLn_1_CLASS extends register_base;
      field_base DCFILT_OFFSET_F;
      field_base DCFILT_COEFF_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DCFILT_OFFSET_F = new("DCFILT_OFFSET", 31, 16, RW, 'h0, this);
        this.DCFILT_COEFF_F = new("DCFILT_COEFF", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_1_CLASS

    class CHAN_CNTRLn_2_CLASS extends register_base;
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
    endclass: CHAN_CNTRLn_2_CLASS

    class CHAN_CNTRLn_3_CLASS extends register_base;
      field_base ADC_PN_SEL_F;
      field_base ADC_DATA_SEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ADC_PN_SEL_F = new("ADC_PN_SEL", 19, 16, RW, 'h0, this);
        this.ADC_DATA_SEL_F = new("ADC_DATA_SEL", 3, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_3_CLASS

    class CHAN_USR_CNTRLn_1_CLASS extends register_base;
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

        this.USR_DATATYPE_BE_F = new("USR_DATATYPE_BE", 25, 25, RO, 'h0, this);
        this.USR_DATATYPE_SIGNED_F = new("USR_DATATYPE_SIGNED", 24, 24, RO, 'h0, this);
        this.USR_DATATYPE_SHIFT_F = new("USR_DATATYPE_SHIFT", 23, 16, RO, 'h0, this);
        this.USR_DATATYPE_TOTAL_BITS_F = new("USR_DATATYPE_TOTAL_BITS", 15, 8, RO, 'h0, this);
        this.USR_DATATYPE_BITS_F = new("USR_DATATYPE_BITS", 7, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_USR_CNTRLn_1_CLASS

    class CHAN_USR_CNTRLn_2_CLASS extends register_base;
      field_base USR_DECIMATION_M_F;
      field_base USR_DECIMATION_N_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.USR_DECIMATION_M_F = new("USR_DECIMATION_M", 31, 16, RW, 'h0, this);
        this.USR_DECIMATION_N_F = new("USR_DECIMATION_N", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_USR_CNTRLn_2_CLASS

    class CHAN_CNTRLn_4_CLASS extends register_base;
      field_base SOFTSPAN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SOFTSPAN_F = new("SOFTSPAN", 2, 0, RW, 'h7, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CHAN_CNTRLn_4_CLASS

    RSTN_CLASS RSTN_R;
    CNTRL_CLASS CNTRL_R;
    CNTRL_2_CLASS CNTRL_2_R;
    CNTRL_3_CLASS CNTRL_3_R;
    CLK_FREQ_CLASS CLK_FREQ_R;
    CLK_RATIO_CLASS CLK_RATIO_R;
    STATUS_CLASS STATUS_R;
    SYNC_STATUS_CLASS SYNC_STATUS_R;
    DRP_CNTRL_CLASS DRP_CNTRL_R;
    DRP_STATUS_CLASS DRP_STATUS_R;
    DRP_WDATA_CLASS DRP_WDATA_R;
    DRP_RDATA_CLASS DRP_RDATA_R;
    ADC_CONFIG_WR_CLASS ADC_CONFIG_WR_R;
    ADC_CONFIG_RD_CLASS ADC_CONFIG_RD_R;
    UI_STATUS_CLASS UI_STATUS_R;
    ADC_CONFIG_CTRL_CLASS ADC_CONFIG_CTRL_R;
    USR_CNTRL_1_CLASS USR_CNTRL_1_R;
    ADC_START_CODE_CLASS ADC_START_CODE_R;
    ADC_GPIO_IN_CLASS ADC_GPIO_IN_R;
    ADC_GPIO_OUT_CLASS ADC_GPIO_OUT_R;
    PPS_COUNTER_CLASS PPS_COUNTER_R;
    PPS_STATUS_CLASS PPS_STATUS_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL0_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL1_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL2_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL3_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL4_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL5_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL6_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL7_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL8_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL9_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL10_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL11_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL12_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL13_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL14_R;
    CHAN_CNTRLn_CLASS CHAN_CNTRL15_R;
    CHAN_STATUSn_CLASS CHAN_STATUS0_R;
    CHAN_STATUSn_CLASS CHAN_STATUS1_R;
    CHAN_STATUSn_CLASS CHAN_STATUS2_R;
    CHAN_STATUSn_CLASS CHAN_STATUS3_R;
    CHAN_STATUSn_CLASS CHAN_STATUS4_R;
    CHAN_STATUSn_CLASS CHAN_STATUS5_R;
    CHAN_STATUSn_CLASS CHAN_STATUS6_R;
    CHAN_STATUSn_CLASS CHAN_STATUS7_R;
    CHAN_STATUSn_CLASS CHAN_STATUS8_R;
    CHAN_STATUSn_CLASS CHAN_STATUS9_R;
    CHAN_STATUSn_CLASS CHAN_STATUS10_R;
    CHAN_STATUSn_CLASS CHAN_STATUS11_R;
    CHAN_STATUSn_CLASS CHAN_STATUS12_R;
    CHAN_STATUSn_CLASS CHAN_STATUS13_R;
    CHAN_STATUSn_CLASS CHAN_STATUS14_R;
    CHAN_STATUSn_CLASS CHAN_STATUS15_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA0_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA1_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA2_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA3_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA4_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA5_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA6_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA7_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA8_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA9_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA10_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA11_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA12_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA13_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA14_R;
    CHAN_RAW_DATAn_CLASS CHAN_RAW_DATA15_R;
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
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL0_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL1_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL2_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL3_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL4_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL5_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL6_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL7_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL8_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL9_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL10_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL11_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL12_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL13_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL14_1_R;
    CHAN_USR_CNTRLn_1_CLASS CHAN_USR_CNTRL15_1_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL0_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL1_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL2_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL3_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL4_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL5_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL6_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL7_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL8_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL9_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL10_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL11_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL12_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL13_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL14_2_R;
    CHAN_USR_CNTRLn_2_CLASS CHAN_USR_CNTRL15_2_R;
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

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.RSTN_R = new("RSTN", 'h40, this);
      this.CNTRL_R = new("CNTRL", 'h44, this);
      this.CNTRL_2_R = new("CNTRL_2", 'h48, this);
      this.CNTRL_3_R = new("CNTRL_3", 'h4c, this);
      this.CLK_FREQ_R = new("CLK_FREQ", 'h54, this);
      this.CLK_RATIO_R = new("CLK_RATIO", 'h58, this);
      this.STATUS_R = new("STATUS", 'h5c, this);
      this.SYNC_STATUS_R = new("SYNC_STATUS", 'h68, this);
      this.DRP_CNTRL_R = new("DRP_CNTRL", 'h70, this);
      this.DRP_STATUS_R = new("DRP_STATUS", 'h74, this);
      this.DRP_WDATA_R = new("DRP_WDATA", 'h78, this);
      this.DRP_RDATA_R = new("DRP_RDATA", 'h7c, this);
      this.ADC_CONFIG_WR_R = new("ADC_CONFIG_WR", 'h80, this);
      this.ADC_CONFIG_RD_R = new("ADC_CONFIG_RD", 'h84, this);
      this.UI_STATUS_R = new("UI_STATUS", 'h88, this);
      this.ADC_CONFIG_CTRL_R = new("ADC_CONFIG_CTRL", 'h8c, this);
      this.USR_CNTRL_1_R = new("USR_CNTRL_1", 'ha0, this);
      this.ADC_START_CODE_R = new("ADC_START_CODE", 'ha4, this);
      this.ADC_GPIO_IN_R = new("ADC_GPIO_IN", 'hb8, this);
      this.ADC_GPIO_OUT_R = new("ADC_GPIO_OUT", 'hbc, this);
      this.PPS_COUNTER_R = new("PPS_COUNTER", 'hc0, this);
      this.PPS_STATUS_R = new("PPS_STATUS", 'hc4, this);
      this.CHAN_CNTRL0_R = new("CHAN_CNTRL0", 'h400, this);
      this.CHAN_CNTRL1_R = new("CHAN_CNTRL1", 'h458, this);
      this.CHAN_CNTRL2_R = new("CHAN_CNTRL2", 'h4b0, this);
      this.CHAN_CNTRL3_R = new("CHAN_CNTRL3", 'h508, this);
      this.CHAN_CNTRL4_R = new("CHAN_CNTRL4", 'h560, this);
      this.CHAN_CNTRL5_R = new("CHAN_CNTRL5", 'h5b8, this);
      this.CHAN_CNTRL6_R = new("CHAN_CNTRL6", 'h610, this);
      this.CHAN_CNTRL7_R = new("CHAN_CNTRL7", 'h668, this);
      this.CHAN_CNTRL8_R = new("CHAN_CNTRL8", 'h6c0, this);
      this.CHAN_CNTRL9_R = new("CHAN_CNTRL9", 'h718, this);
      this.CHAN_CNTRL10_R = new("CHAN_CNTRL10", 'h770, this);
      this.CHAN_CNTRL11_R = new("CHAN_CNTRL11", 'h7c8, this);
      this.CHAN_CNTRL12_R = new("CHAN_CNTRL12", 'h820, this);
      this.CHAN_CNTRL13_R = new("CHAN_CNTRL13", 'h878, this);
      this.CHAN_CNTRL14_R = new("CHAN_CNTRL14", 'h8d0, this);
      this.CHAN_CNTRL15_R = new("CHAN_CNTRL15", 'h928, this);
      this.CHAN_STATUS0_R = new("CHAN_STATUS0", 'h404, this);
      this.CHAN_STATUS1_R = new("CHAN_STATUS1", 'h45c, this);
      this.CHAN_STATUS2_R = new("CHAN_STATUS2", 'h4b4, this);
      this.CHAN_STATUS3_R = new("CHAN_STATUS3", 'h50c, this);
      this.CHAN_STATUS4_R = new("CHAN_STATUS4", 'h564, this);
      this.CHAN_STATUS5_R = new("CHAN_STATUS5", 'h5bc, this);
      this.CHAN_STATUS6_R = new("CHAN_STATUS6", 'h614, this);
      this.CHAN_STATUS7_R = new("CHAN_STATUS7", 'h66c, this);
      this.CHAN_STATUS8_R = new("CHAN_STATUS8", 'h6c4, this);
      this.CHAN_STATUS9_R = new("CHAN_STATUS9", 'h71c, this);
      this.CHAN_STATUS10_R = new("CHAN_STATUS10", 'h774, this);
      this.CHAN_STATUS11_R = new("CHAN_STATUS11", 'h7cc, this);
      this.CHAN_STATUS12_R = new("CHAN_STATUS12", 'h824, this);
      this.CHAN_STATUS13_R = new("CHAN_STATUS13", 'h87c, this);
      this.CHAN_STATUS14_R = new("CHAN_STATUS14", 'h8d4, this);
      this.CHAN_STATUS15_R = new("CHAN_STATUS15", 'h92c, this);
      this.CHAN_RAW_DATA0_R = new("CHAN_RAW_DATA0", 'h408, this);
      this.CHAN_RAW_DATA1_R = new("CHAN_RAW_DATA1", 'h460, this);
      this.CHAN_RAW_DATA2_R = new("CHAN_RAW_DATA2", 'h4b8, this);
      this.CHAN_RAW_DATA3_R = new("CHAN_RAW_DATA3", 'h510, this);
      this.CHAN_RAW_DATA4_R = new("CHAN_RAW_DATA4", 'h568, this);
      this.CHAN_RAW_DATA5_R = new("CHAN_RAW_DATA5", 'h5c0, this);
      this.CHAN_RAW_DATA6_R = new("CHAN_RAW_DATA6", 'h618, this);
      this.CHAN_RAW_DATA7_R = new("CHAN_RAW_DATA7", 'h670, this);
      this.CHAN_RAW_DATA8_R = new("CHAN_RAW_DATA8", 'h6c8, this);
      this.CHAN_RAW_DATA9_R = new("CHAN_RAW_DATA9", 'h720, this);
      this.CHAN_RAW_DATA10_R = new("CHAN_RAW_DATA10", 'h778, this);
      this.CHAN_RAW_DATA11_R = new("CHAN_RAW_DATA11", 'h7d0, this);
      this.CHAN_RAW_DATA12_R = new("CHAN_RAW_DATA12", 'h828, this);
      this.CHAN_RAW_DATA13_R = new("CHAN_RAW_DATA13", 'h880, this);
      this.CHAN_RAW_DATA14_R = new("CHAN_RAW_DATA14", 'h8d8, this);
      this.CHAN_RAW_DATA15_R = new("CHAN_RAW_DATA15", 'h930, this);
      this.CHAN_CNTRL0_1_R = new("CHAN_CNTRL0_1", 'h410, this);
      this.CHAN_CNTRL1_1_R = new("CHAN_CNTRL1_1", 'h468, this);
      this.CHAN_CNTRL2_1_R = new("CHAN_CNTRL2_1", 'h4c0, this);
      this.CHAN_CNTRL3_1_R = new("CHAN_CNTRL3_1", 'h518, this);
      this.CHAN_CNTRL4_1_R = new("CHAN_CNTRL4_1", 'h570, this);
      this.CHAN_CNTRL5_1_R = new("CHAN_CNTRL5_1", 'h5c8, this);
      this.CHAN_CNTRL6_1_R = new("CHAN_CNTRL6_1", 'h620, this);
      this.CHAN_CNTRL7_1_R = new("CHAN_CNTRL7_1", 'h678, this);
      this.CHAN_CNTRL8_1_R = new("CHAN_CNTRL8_1", 'h6d0, this);
      this.CHAN_CNTRL9_1_R = new("CHAN_CNTRL9_1", 'h728, this);
      this.CHAN_CNTRL10_1_R = new("CHAN_CNTRL10_1", 'h780, this);
      this.CHAN_CNTRL11_1_R = new("CHAN_CNTRL11_1", 'h7d8, this);
      this.CHAN_CNTRL12_1_R = new("CHAN_CNTRL12_1", 'h830, this);
      this.CHAN_CNTRL13_1_R = new("CHAN_CNTRL13_1", 'h888, this);
      this.CHAN_CNTRL14_1_R = new("CHAN_CNTRL14_1", 'h8e0, this);
      this.CHAN_CNTRL15_1_R = new("CHAN_CNTRL15_1", 'h938, this);
      this.CHAN_CNTRL0_2_R = new("CHAN_CNTRL0_2", 'h414, this);
      this.CHAN_CNTRL1_2_R = new("CHAN_CNTRL1_2", 'h46c, this);
      this.CHAN_CNTRL2_2_R = new("CHAN_CNTRL2_2", 'h4c4, this);
      this.CHAN_CNTRL3_2_R = new("CHAN_CNTRL3_2", 'h51c, this);
      this.CHAN_CNTRL4_2_R = new("CHAN_CNTRL4_2", 'h574, this);
      this.CHAN_CNTRL5_2_R = new("CHAN_CNTRL5_2", 'h5cc, this);
      this.CHAN_CNTRL6_2_R = new("CHAN_CNTRL6_2", 'h624, this);
      this.CHAN_CNTRL7_2_R = new("CHAN_CNTRL7_2", 'h67c, this);
      this.CHAN_CNTRL8_2_R = new("CHAN_CNTRL8_2", 'h6d4, this);
      this.CHAN_CNTRL9_2_R = new("CHAN_CNTRL9_2", 'h72c, this);
      this.CHAN_CNTRL10_2_R = new("CHAN_CNTRL10_2", 'h784, this);
      this.CHAN_CNTRL11_2_R = new("CHAN_CNTRL11_2", 'h7dc, this);
      this.CHAN_CNTRL12_2_R = new("CHAN_CNTRL12_2", 'h834, this);
      this.CHAN_CNTRL13_2_R = new("CHAN_CNTRL13_2", 'h88c, this);
      this.CHAN_CNTRL14_2_R = new("CHAN_CNTRL14_2", 'h8e4, this);
      this.CHAN_CNTRL15_2_R = new("CHAN_CNTRL15_2", 'h93c, this);
      this.CHAN_CNTRL0_3_R = new("CHAN_CNTRL0_3", 'h418, this);
      this.CHAN_CNTRL1_3_R = new("CHAN_CNTRL1_3", 'h470, this);
      this.CHAN_CNTRL2_3_R = new("CHAN_CNTRL2_3", 'h4c8, this);
      this.CHAN_CNTRL3_3_R = new("CHAN_CNTRL3_3", 'h520, this);
      this.CHAN_CNTRL4_3_R = new("CHAN_CNTRL4_3", 'h578, this);
      this.CHAN_CNTRL5_3_R = new("CHAN_CNTRL5_3", 'h5d0, this);
      this.CHAN_CNTRL6_3_R = new("CHAN_CNTRL6_3", 'h628, this);
      this.CHAN_CNTRL7_3_R = new("CHAN_CNTRL7_3", 'h680, this);
      this.CHAN_CNTRL8_3_R = new("CHAN_CNTRL8_3", 'h6d8, this);
      this.CHAN_CNTRL9_3_R = new("CHAN_CNTRL9_3", 'h730, this);
      this.CHAN_CNTRL10_3_R = new("CHAN_CNTRL10_3", 'h788, this);
      this.CHAN_CNTRL11_3_R = new("CHAN_CNTRL11_3", 'h7e0, this);
      this.CHAN_CNTRL12_3_R = new("CHAN_CNTRL12_3", 'h838, this);
      this.CHAN_CNTRL13_3_R = new("CHAN_CNTRL13_3", 'h890, this);
      this.CHAN_CNTRL14_3_R = new("CHAN_CNTRL14_3", 'h8e8, this);
      this.CHAN_CNTRL15_3_R = new("CHAN_CNTRL15_3", 'h940, this);
      this.CHAN_USR_CNTRL0_1_R = new("CHAN_USR_CNTRL0_1", 'h420, this);
      this.CHAN_USR_CNTRL1_1_R = new("CHAN_USR_CNTRL1_1", 'h478, this);
      this.CHAN_USR_CNTRL2_1_R = new("CHAN_USR_CNTRL2_1", 'h4d0, this);
      this.CHAN_USR_CNTRL3_1_R = new("CHAN_USR_CNTRL3_1", 'h528, this);
      this.CHAN_USR_CNTRL4_1_R = new("CHAN_USR_CNTRL4_1", 'h580, this);
      this.CHAN_USR_CNTRL5_1_R = new("CHAN_USR_CNTRL5_1", 'h5d8, this);
      this.CHAN_USR_CNTRL6_1_R = new("CHAN_USR_CNTRL6_1", 'h630, this);
      this.CHAN_USR_CNTRL7_1_R = new("CHAN_USR_CNTRL7_1", 'h688, this);
      this.CHAN_USR_CNTRL8_1_R = new("CHAN_USR_CNTRL8_1", 'h6e0, this);
      this.CHAN_USR_CNTRL9_1_R = new("CHAN_USR_CNTRL9_1", 'h738, this);
      this.CHAN_USR_CNTRL10_1_R = new("CHAN_USR_CNTRL10_1", 'h790, this);
      this.CHAN_USR_CNTRL11_1_R = new("CHAN_USR_CNTRL11_1", 'h7e8, this);
      this.CHAN_USR_CNTRL12_1_R = new("CHAN_USR_CNTRL12_1", 'h840, this);
      this.CHAN_USR_CNTRL13_1_R = new("CHAN_USR_CNTRL13_1", 'h898, this);
      this.CHAN_USR_CNTRL14_1_R = new("CHAN_USR_CNTRL14_1", 'h8f0, this);
      this.CHAN_USR_CNTRL15_1_R = new("CHAN_USR_CNTRL15_1", 'h948, this);
      this.CHAN_USR_CNTRL0_2_R = new("CHAN_USR_CNTRL0_2", 'h424, this);
      this.CHAN_USR_CNTRL1_2_R = new("CHAN_USR_CNTRL1_2", 'h47c, this);
      this.CHAN_USR_CNTRL2_2_R = new("CHAN_USR_CNTRL2_2", 'h4d4, this);
      this.CHAN_USR_CNTRL3_2_R = new("CHAN_USR_CNTRL3_2", 'h52c, this);
      this.CHAN_USR_CNTRL4_2_R = new("CHAN_USR_CNTRL4_2", 'h584, this);
      this.CHAN_USR_CNTRL5_2_R = new("CHAN_USR_CNTRL5_2", 'h5dc, this);
      this.CHAN_USR_CNTRL6_2_R = new("CHAN_USR_CNTRL6_2", 'h634, this);
      this.CHAN_USR_CNTRL7_2_R = new("CHAN_USR_CNTRL7_2", 'h68c, this);
      this.CHAN_USR_CNTRL8_2_R = new("CHAN_USR_CNTRL8_2", 'h6e4, this);
      this.CHAN_USR_CNTRL9_2_R = new("CHAN_USR_CNTRL9_2", 'h73c, this);
      this.CHAN_USR_CNTRL10_2_R = new("CHAN_USR_CNTRL10_2", 'h794, this);
      this.CHAN_USR_CNTRL11_2_R = new("CHAN_USR_CNTRL11_2", 'h7ec, this);
      this.CHAN_USR_CNTRL12_2_R = new("CHAN_USR_CNTRL12_2", 'h844, this);
      this.CHAN_USR_CNTRL13_2_R = new("CHAN_USR_CNTRL13_2", 'h89c, this);
      this.CHAN_USR_CNTRL14_2_R = new("CHAN_USR_CNTRL14_2", 'h8f4, this);
      this.CHAN_USR_CNTRL15_2_R = new("CHAN_USR_CNTRL15_2", 'h94c, this);
      this.CHAN_CNTRL0_4_R = new("CHAN_CNTRL0_4", 'h428, this);
      this.CHAN_CNTRL1_4_R = new("CHAN_CNTRL1_4", 'h480, this);
      this.CHAN_CNTRL2_4_R = new("CHAN_CNTRL2_4", 'h4d8, this);
      this.CHAN_CNTRL3_4_R = new("CHAN_CNTRL3_4", 'h530, this);
      this.CHAN_CNTRL4_4_R = new("CHAN_CNTRL4_4", 'h588, this);
      this.CHAN_CNTRL5_4_R = new("CHAN_CNTRL5_4", 'h5e0, this);
      this.CHAN_CNTRL6_4_R = new("CHAN_CNTRL6_4", 'h638, this);
      this.CHAN_CNTRL7_4_R = new("CHAN_CNTRL7_4", 'h690, this);
      this.CHAN_CNTRL8_4_R = new("CHAN_CNTRL8_4", 'h6e8, this);
      this.CHAN_CNTRL9_4_R = new("CHAN_CNTRL9_4", 'h740, this);
      this.CHAN_CNTRL10_4_R = new("CHAN_CNTRL10_4", 'h798, this);
      this.CHAN_CNTRL11_4_R = new("CHAN_CNTRL11_4", 'h7f0, this);
      this.CHAN_CNTRL12_4_R = new("CHAN_CNTRL12_4", 'h848, this);
      this.CHAN_CNTRL13_4_R = new("CHAN_CNTRL13_4", 'h8a0, this);
      this.CHAN_CNTRL14_4_R = new("CHAN_CNTRL14_4", 'h8f8, this);
      this.CHAN_CNTRL15_4_R = new("CHAN_CNTRL15_4", 'h950, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_axi_adc_template

endpackage: adi_regmap_axi_adc_template_pkg
