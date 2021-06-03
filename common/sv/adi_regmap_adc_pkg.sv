// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2021 (c) Analog Devices, Inc. All rights reserved.
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
//      <https://www.gnu.org/licenses/old_licenses/gpl-2.0.html>
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
/* Fri May 28 12:27:32 2021 */

package adi_regmap_adc_pkg;
  import adi_regmap_pkg::*;


/* ADC Common (axi_ad*) */

  const reg_t ADC_COMMON_REG_RSTN = '{ 'h0040, "REG_RSTN" , '{
    "CE_N": '{ 2, 2, RW, 'h0 },
    "MMCM_RSTN": '{ 1, 1, RW, 'h0 },
    "RSTN": '{ 0, 0, RW, 'h0 }}};
  `define SET_ADC_COMMON_REG_RSTN_CE_N(x) SetField(ADC_COMMON_REG_RSTN,"CE_N",x)
  `define GET_ADC_COMMON_REG_RSTN_CE_N(x) GetField(ADC_COMMON_REG_RSTN,"CE_N",x)
  `define SET_ADC_COMMON_REG_RSTN_MMCM_RSTN(x) SetField(ADC_COMMON_REG_RSTN,"MMCM_RSTN",x)
  `define GET_ADC_COMMON_REG_RSTN_MMCM_RSTN(x) GetField(ADC_COMMON_REG_RSTN,"MMCM_RSTN",x)
  `define SET_ADC_COMMON_REG_RSTN_RSTN(x) SetField(ADC_COMMON_REG_RSTN,"RSTN",x)
  `define GET_ADC_COMMON_REG_RSTN_RSTN(x) GetField(ADC_COMMON_REG_RSTN,"RSTN",x)

  const reg_t ADC_COMMON_REG_CNTRL = '{ 'h0044, "REG_CNTRL" , '{
    "SYNC": '{ 3, 3, RW, 'h0 },
    "R1_MODE": '{ 2, 2, RW, 'h0 },
    "DDR_EDGESEL": '{ 1, 1, RW, 'h0 },
    "PIN_MODE": '{ 0, 0, RW, 'h0 }}};
  `define SET_ADC_COMMON_REG_CNTRL_SYNC(x) SetField(ADC_COMMON_REG_CNTRL,"SYNC",x)
  `define GET_ADC_COMMON_REG_CNTRL_SYNC(x) GetField(ADC_COMMON_REG_CNTRL,"SYNC",x)
  `define SET_ADC_COMMON_REG_CNTRL_R1_MODE(x) SetField(ADC_COMMON_REG_CNTRL,"R1_MODE",x)
  `define GET_ADC_COMMON_REG_CNTRL_R1_MODE(x) GetField(ADC_COMMON_REG_CNTRL,"R1_MODE",x)
  `define SET_ADC_COMMON_REG_CNTRL_DDR_EDGESEL(x) SetField(ADC_COMMON_REG_CNTRL,"DDR_EDGESEL",x)
  `define GET_ADC_COMMON_REG_CNTRL_DDR_EDGESEL(x) GetField(ADC_COMMON_REG_CNTRL,"DDR_EDGESEL",x)
  `define SET_ADC_COMMON_REG_CNTRL_PIN_MODE(x) SetField(ADC_COMMON_REG_CNTRL,"PIN_MODE",x)
  `define GET_ADC_COMMON_REG_CNTRL_PIN_MODE(x) GetField(ADC_COMMON_REG_CNTRL,"PIN_MODE",x)

  const reg_t ADC_COMMON_REG_CLK_FREQ = '{ 'h0054, "REG_CLK_FREQ" , '{
    "CLK_FREQ": '{ 31, 0, RO, 'h0000 }}};
  `define SET_ADC_COMMON_REG_CLK_FREQ_CLK_FREQ(x) SetField(ADC_COMMON_REG_CLK_FREQ,"CLK_FREQ",x)
  `define GET_ADC_COMMON_REG_CLK_FREQ_CLK_FREQ(x) GetField(ADC_COMMON_REG_CLK_FREQ,"CLK_FREQ",x)

  const reg_t ADC_COMMON_REG_CLK_RATIO = '{ 'h0058, "REG_CLK_RATIO" , '{
    "CLK_RATIO": '{ 31, 0, RO, 'h0000 }}};
  `define SET_ADC_COMMON_REG_CLK_RATIO_CLK_RATIO(x) SetField(ADC_COMMON_REG_CLK_RATIO,"CLK_RATIO",x)
  `define GET_ADC_COMMON_REG_CLK_RATIO_CLK_RATIO(x) GetField(ADC_COMMON_REG_CLK_RATIO,"CLK_RATIO",x)

  const reg_t ADC_COMMON_REG_STATUS = '{ 'h005c, "REG_STATUS" , '{
    "PN_ERR": '{ 3, 3, RO, 'h0 },
    "PN_OOS": '{ 2, 2, RO, 'h0 },
    "OVER_RANGE": '{ 1, 1, RO, 'h0 },
    "STATUS": '{ 0, 0, RO, 'h0 }}};
  `define SET_ADC_COMMON_REG_STATUS_PN_ERR(x) SetField(ADC_COMMON_REG_STATUS,"PN_ERR",x)
  `define GET_ADC_COMMON_REG_STATUS_PN_ERR(x) GetField(ADC_COMMON_REG_STATUS,"PN_ERR",x)
  `define SET_ADC_COMMON_REG_STATUS_PN_OOS(x) SetField(ADC_COMMON_REG_STATUS,"PN_OOS",x)
  `define GET_ADC_COMMON_REG_STATUS_PN_OOS(x) GetField(ADC_COMMON_REG_STATUS,"PN_OOS",x)
  `define SET_ADC_COMMON_REG_STATUS_OVER_RANGE(x) SetField(ADC_COMMON_REG_STATUS,"OVER_RANGE",x)
  `define GET_ADC_COMMON_REG_STATUS_OVER_RANGE(x) GetField(ADC_COMMON_REG_STATUS,"OVER_RANGE",x)
  `define SET_ADC_COMMON_REG_STATUS_STATUS(x) SetField(ADC_COMMON_REG_STATUS,"STATUS",x)
  `define GET_ADC_COMMON_REG_STATUS_STATUS(x) GetField(ADC_COMMON_REG_STATUS,"STATUS",x)

  const reg_t ADC_COMMON_REG_DELAY_CNTRL_ = '{ 'h0060, "REG_DELAY_CNTRL_" , '{
    "DELAY_SEL": '{ 17, 17, RW, 'h0 },
    "DELAY_RWN": '{ 16, 16, RW, 'h0 },
    "DELAY_ADDRESS": '{ 15, 8, RW, 'h00 },
    "DELAY_WDATA": '{ 4, 0, RW, 'h0 }}};
  `define SET_ADC_COMMON_REG_DELAY_CNTRL__DELAY_SEL(x) SetField(ADC_COMMON_REG_DELAY_CNTRL_,"DELAY_SEL",x)
  `define GET_ADC_COMMON_REG_DELAY_CNTRL__DELAY_SEL(x) GetField(ADC_COMMON_REG_DELAY_CNTRL_,"DELAY_SEL",x)
  `define SET_ADC_COMMON_REG_DELAY_CNTRL__DELAY_RWN(x) SetField(ADC_COMMON_REG_DELAY_CNTRL_,"DELAY_RWN",x)
  `define GET_ADC_COMMON_REG_DELAY_CNTRL__DELAY_RWN(x) GetField(ADC_COMMON_REG_DELAY_CNTRL_,"DELAY_RWN",x)
  `define SET_ADC_COMMON_REG_DELAY_CNTRL__DELAY_ADDRESS(x) SetField(ADC_COMMON_REG_DELAY_CNTRL_,"DELAY_ADDRESS",x)
  `define GET_ADC_COMMON_REG_DELAY_CNTRL__DELAY_ADDRESS(x) GetField(ADC_COMMON_REG_DELAY_CNTRL_,"DELAY_ADDRESS",x)
  `define SET_ADC_COMMON_REG_DELAY_CNTRL__DELAY_WDATA(x) SetField(ADC_COMMON_REG_DELAY_CNTRL_,"DELAY_WDATA",x)
  `define GET_ADC_COMMON_REG_DELAY_CNTRL__DELAY_WDATA(x) GetField(ADC_COMMON_REG_DELAY_CNTRL_,"DELAY_WDATA",x)

  const reg_t ADC_COMMON_REG_DELAY_STATUS_ = '{ 'h0064, "REG_DELAY_STATUS_" , '{
    "DELAY_LOCKED": '{ 9, 9, RO, 'h0 },
    "DELAY_STATUS": '{ 8, 8, RO, 'h0 },
    "DELAY_RDATA": '{ 4, 0, RO, 'h0 }}};
  `define SET_ADC_COMMON_REG_DELAY_STATUS__DELAY_LOCKED(x) SetField(ADC_COMMON_REG_DELAY_STATUS_,"DELAY_LOCKED",x)
  `define GET_ADC_COMMON_REG_DELAY_STATUS__DELAY_LOCKED(x) GetField(ADC_COMMON_REG_DELAY_STATUS_,"DELAY_LOCKED",x)
  `define SET_ADC_COMMON_REG_DELAY_STATUS__DELAY_STATUS(x) SetField(ADC_COMMON_REG_DELAY_STATUS_,"DELAY_STATUS",x)
  `define GET_ADC_COMMON_REG_DELAY_STATUS__DELAY_STATUS(x) GetField(ADC_COMMON_REG_DELAY_STATUS_,"DELAY_STATUS",x)
  `define SET_ADC_COMMON_REG_DELAY_STATUS__DELAY_RDATA(x) SetField(ADC_COMMON_REG_DELAY_STATUS_,"DELAY_RDATA",x)
  `define GET_ADC_COMMON_REG_DELAY_STATUS__DELAY_RDATA(x) GetField(ADC_COMMON_REG_DELAY_STATUS_,"DELAY_RDATA",x)

  const reg_t ADC_COMMON_REG_SYNC_STATUS = '{ 'h0068, "REG_SYNC_STATUS" , '{
    "ADC_SYNC": '{ 0, 0, RO, 'h0 }}};
  `define SET_ADC_COMMON_REG_SYNC_STATUS_ADC_SYNC(x) SetField(ADC_COMMON_REG_SYNC_STATUS,"ADC_SYNC",x)
  `define GET_ADC_COMMON_REG_SYNC_STATUS_ADC_SYNC(x) GetField(ADC_COMMON_REG_SYNC_STATUS,"ADC_SYNC",x)

  const reg_t ADC_COMMON_REG_DRP_CNTRL = '{ 'h0070, "REG_DRP_CNTRL" , '{
    "DRP_RWN": '{ 28, 28, RW, 'h0 },
    "DRP_ADDRESS": '{ 27, 16, RW, 'h00 },
    "RESERVED": '{ 15, 0, RO, 'h0000 }}};
  `define SET_ADC_COMMON_REG_DRP_CNTRL_DRP_RWN(x) SetField(ADC_COMMON_REG_DRP_CNTRL,"DRP_RWN",x)
  `define GET_ADC_COMMON_REG_DRP_CNTRL_DRP_RWN(x) GetField(ADC_COMMON_REG_DRP_CNTRL,"DRP_RWN",x)
  `define SET_ADC_COMMON_REG_DRP_CNTRL_DRP_ADDRESS(x) SetField(ADC_COMMON_REG_DRP_CNTRL,"DRP_ADDRESS",x)
  `define GET_ADC_COMMON_REG_DRP_CNTRL_DRP_ADDRESS(x) GetField(ADC_COMMON_REG_DRP_CNTRL,"DRP_ADDRESS",x)
  `define SET_ADC_COMMON_REG_DRP_CNTRL_RESERVED(x) SetField(ADC_COMMON_REG_DRP_CNTRL,"RESERVED",x)
  `define GET_ADC_COMMON_REG_DRP_CNTRL_RESERVED(x) GetField(ADC_COMMON_REG_DRP_CNTRL,"RESERVED",x)

  const reg_t ADC_COMMON_REG_DRP_STATUS = '{ 'h0074, "REG_DRP_STATUS" , '{
    "DRP_LOCKED": '{ 17, 17, RO, 'h0 },
    "DRP_STATUS": '{ 16, 16, RO, 'h0 },
    "RESERVED": '{ 15, 0, RO, 'h00 }}};
  `define SET_ADC_COMMON_REG_DRP_STATUS_DRP_LOCKED(x) SetField(ADC_COMMON_REG_DRP_STATUS,"DRP_LOCKED",x)
  `define GET_ADC_COMMON_REG_DRP_STATUS_DRP_LOCKED(x) GetField(ADC_COMMON_REG_DRP_STATUS,"DRP_LOCKED",x)
  `define SET_ADC_COMMON_REG_DRP_STATUS_DRP_STATUS(x) SetField(ADC_COMMON_REG_DRP_STATUS,"DRP_STATUS",x)
  `define GET_ADC_COMMON_REG_DRP_STATUS_DRP_STATUS(x) GetField(ADC_COMMON_REG_DRP_STATUS,"DRP_STATUS",x)
  `define SET_ADC_COMMON_REG_DRP_STATUS_RESERVED(x) SetField(ADC_COMMON_REG_DRP_STATUS,"RESERVED",x)
  `define GET_ADC_COMMON_REG_DRP_STATUS_RESERVED(x) GetField(ADC_COMMON_REG_DRP_STATUS,"RESERVED",x)

  const reg_t ADC_COMMON_REG_DRP_WDATA = '{ 'h0078, "REG_DRP_WDATA" , '{
    "DRP_WDATA": '{ 15, 0, RW, 'h00 }}};
  `define SET_ADC_COMMON_REG_DRP_WDATA_DRP_WDATA(x) SetField(ADC_COMMON_REG_DRP_WDATA,"DRP_WDATA",x)
  `define GET_ADC_COMMON_REG_DRP_WDATA_DRP_WDATA(x) GetField(ADC_COMMON_REG_DRP_WDATA,"DRP_WDATA",x)

  const reg_t ADC_COMMON_REG_DRP_RDATA = '{ 'h007c, "REG_DRP_RDATA" , '{
    "DRP_RDATA": '{ 15, 0, RO, 'h00 }}};
  `define SET_ADC_COMMON_REG_DRP_RDATA_DRP_RDATA(x) SetField(ADC_COMMON_REG_DRP_RDATA,"DRP_RDATA",x)
  `define GET_ADC_COMMON_REG_DRP_RDATA_DRP_RDATA(x) GetField(ADC_COMMON_REG_DRP_RDATA,"DRP_RDATA",x)

  const reg_t ADC_COMMON_REG_UI_STATUS = '{ 'h0088, "REG_UI_STATUS" , '{
    "UI_OVF": '{ 2, 2, RW1C, 'h0 },
    "UI_UNF": '{ 1, 1, RW1C, 'h0 },
    "UI_RESERVED": '{ 0, 0, RW1C, 'h0 }}};
  `define SET_ADC_COMMON_REG_UI_STATUS_UI_OVF(x) SetField(ADC_COMMON_REG_UI_STATUS,"UI_OVF",x)
  `define GET_ADC_COMMON_REG_UI_STATUS_UI_OVF(x) GetField(ADC_COMMON_REG_UI_STATUS,"UI_OVF",x)
  `define SET_ADC_COMMON_REG_UI_STATUS_UI_UNF(x) SetField(ADC_COMMON_REG_UI_STATUS,"UI_UNF",x)
  `define GET_ADC_COMMON_REG_UI_STATUS_UI_UNF(x) GetField(ADC_COMMON_REG_UI_STATUS,"UI_UNF",x)
  `define SET_ADC_COMMON_REG_UI_STATUS_UI_RESERVED(x) SetField(ADC_COMMON_REG_UI_STATUS,"UI_RESERVED",x)
  `define GET_ADC_COMMON_REG_UI_STATUS_UI_RESERVED(x) GetField(ADC_COMMON_REG_UI_STATUS,"UI_RESERVED",x)

  const reg_t ADC_COMMON_REG_USR_CNTRL_1 = '{ 'h00a0, "REG_USR_CNTRL_1" , '{
    "USR_CHANMAX": '{ 7, 0, RW, 'h00 }}};
  `define SET_ADC_COMMON_REG_USR_CNTRL_1_USR_CHANMAX(x) SetField(ADC_COMMON_REG_USR_CNTRL_1,"USR_CHANMAX",x)
  `define GET_ADC_COMMON_REG_USR_CNTRL_1_USR_CHANMAX(x) GetField(ADC_COMMON_REG_USR_CNTRL_1,"USR_CHANMAX",x)

  const reg_t ADC_COMMON_REG_ADC_START_CODE = '{ 'h00a4, "REG_ADC_START_CODE" , '{
    "ADC_START_CODE": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_ADC_COMMON_REG_ADC_START_CODE_ADC_START_CODE(x) SetField(ADC_COMMON_REG_ADC_START_CODE,"ADC_START_CODE",x)
  `define GET_ADC_COMMON_REG_ADC_START_CODE_ADC_START_CODE(x) GetField(ADC_COMMON_REG_ADC_START_CODE,"ADC_START_CODE",x)

  const reg_t ADC_COMMON_REG_ADC_GPIO_IN = '{ 'h00b8, "REG_ADC_GPIO_IN" , '{
    "ADC_GPIO_IN": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_ADC_COMMON_REG_ADC_GPIO_IN_ADC_GPIO_IN(x) SetField(ADC_COMMON_REG_ADC_GPIO_IN,"ADC_GPIO_IN",x)
  `define GET_ADC_COMMON_REG_ADC_GPIO_IN_ADC_GPIO_IN(x) GetField(ADC_COMMON_REG_ADC_GPIO_IN,"ADC_GPIO_IN",x)

  const reg_t ADC_COMMON_REG_ADC_GPIO_OUT = '{ 'h00bc, "REG_ADC_GPIO_OUT" , '{
    "ADC_GPIO_OUT": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_ADC_COMMON_REG_ADC_GPIO_OUT_ADC_GPIO_OUT(x) SetField(ADC_COMMON_REG_ADC_GPIO_OUT,"ADC_GPIO_OUT",x)
  `define GET_ADC_COMMON_REG_ADC_GPIO_OUT_ADC_GPIO_OUT(x) GetField(ADC_COMMON_REG_ADC_GPIO_OUT,"ADC_GPIO_OUT",x)

  const reg_t ADC_COMMON_REG_PPS_COUNTER = '{ 'h00c0, "REG_PPS_COUNTER" , '{
    "PPS_COUNTER": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_ADC_COMMON_REG_PPS_COUNTER_PPS_COUNTER(x) SetField(ADC_COMMON_REG_PPS_COUNTER,"PPS_COUNTER",x)
  `define GET_ADC_COMMON_REG_PPS_COUNTER_PPS_COUNTER(x) GetField(ADC_COMMON_REG_PPS_COUNTER,"PPS_COUNTER",x)

  const reg_t ADC_COMMON_REG_PPS_STATUS = '{ 'h00c4, "REG_PPS_STATUS" , '{
    "PPS_STATUS": '{ 0, 0, RO, 'h0 }}};
  `define SET_ADC_COMMON_REG_PPS_STATUS_PPS_STATUS(x) SetField(ADC_COMMON_REG_PPS_STATUS,"PPS_STATUS",x)
  `define GET_ADC_COMMON_REG_PPS_STATUS_PPS_STATUS(x) GetField(ADC_COMMON_REG_PPS_STATUS,"PPS_STATUS",x)


/* ADC Channel (axi_ad*) */

  const reg_t ADC_CHANNEL_REG_CHAN_CNTRL = '{ 'h0400, "REG_CHAN_CNTRL" , '{
    "ADC_LB_OWR": '{ 11, 11, RW, 'h0 },
    "ADC_PN_SEL_OWR": '{ 10, 10, RW, 'h0 },
    "IQCOR_ENB": '{ 9, 9, RW, 'h0 },
    "DCFILT_ENB": '{ 8, 8, RW, 'h0 },
    "FORMAT_SIGNEXT": '{ 6, 6, RW, 'h0 },
    "FORMAT_TYPE": '{ 5, 5, RW, 'h0 },
    "FORMAT_ENABLE": '{ 4, 4, RW, 'h0 },
    "RESERVED": '{ 3, 3, RO, 'h0 },
    "RESERVED": '{ 2, 2, RO, 'h0 },
    "ADC_PN_TYPE_OWR": '{ 1, 1, RW, 'h0 },
    "ENABLE": '{ 0, 0, RW, 'h0 }}};
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_ADC_LB_OWR(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL,"ADC_LB_OWR",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_ADC_LB_OWR(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL,"ADC_LB_OWR",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_ADC_PN_SEL_OWR(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL,"ADC_PN_SEL_OWR",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_ADC_PN_SEL_OWR(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL,"ADC_PN_SEL_OWR",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_IQCOR_ENB(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL,"IQCOR_ENB",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_IQCOR_ENB(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL,"IQCOR_ENB",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_DCFILT_ENB(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL,"DCFILT_ENB",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_DCFILT_ENB(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL,"DCFILT_ENB",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL,"FORMAT_SIGNEXT",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL,"FORMAT_SIGNEXT",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_TYPE(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL,"FORMAT_TYPE",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_TYPE(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL,"FORMAT_TYPE",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL,"FORMAT_ENABLE",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL,"FORMAT_ENABLE",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_RESERVED(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL,"RESERVED",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_RESERVED(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL,"RESERVED",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_RESERVED(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL,"RESERVED",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_RESERVED(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL,"RESERVED",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_ADC_PN_TYPE_OWR(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL,"ADC_PN_TYPE_OWR",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_ADC_PN_TYPE_OWR(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL,"ADC_PN_TYPE_OWR",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL,"ENABLE",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL,"ENABLE",x)

  const reg_t ADC_CHANNEL_REG_CHAN_STATUS = '{ 'h0404, "REG_CHAN_STATUS" , '{
    "PN_ERR": '{ 2, 2, RW1C, 'h0 },
    "PN_OOS": '{ 1, 1, RW1C, 'h0 },
    "OVER_RANGE": '{ 0, 0, RW1C, 'h0 }}};
  `define SET_ADC_CHANNEL_REG_CHAN_STATUS_PN_ERR(x) SetField(ADC_CHANNEL_REG_CHAN_STATUS,"PN_ERR",x)
  `define GET_ADC_CHANNEL_REG_CHAN_STATUS_PN_ERR(x) GetField(ADC_CHANNEL_REG_CHAN_STATUS,"PN_ERR",x)
  `define SET_ADC_CHANNEL_REG_CHAN_STATUS_PN_OOS(x) SetField(ADC_CHANNEL_REG_CHAN_STATUS,"PN_OOS",x)
  `define GET_ADC_CHANNEL_REG_CHAN_STATUS_PN_OOS(x) GetField(ADC_CHANNEL_REG_CHAN_STATUS,"PN_OOS",x)
  `define SET_ADC_CHANNEL_REG_CHAN_STATUS_OVER_RANGE(x) SetField(ADC_CHANNEL_REG_CHAN_STATUS,"OVER_RANGE",x)
  `define GET_ADC_CHANNEL_REG_CHAN_STATUS_OVER_RANGE(x) GetField(ADC_CHANNEL_REG_CHAN_STATUS,"OVER_RANGE",x)

  const reg_t ADC_CHANNEL_REG_CHAN_CNTRL_1 = '{ 'h0410, "REG_CHAN_CNTRL_1" , '{
    "DCFILT_OFFSET": '{ 31, 16, RW, 'h0000 },
    "DCFILT_COEFF": '{ 15, 0, RW, 'h0000 }}};
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_1_DCFILT_OFFSET(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL_1,"DCFILT_OFFSET",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_1_DCFILT_OFFSET(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL_1,"DCFILT_OFFSET",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_1_DCFILT_COEFF(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL_1,"DCFILT_COEFF",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_1_DCFILT_COEFF(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL_1,"DCFILT_COEFF",x)

  const reg_t ADC_CHANNEL_REG_CHAN_CNTRL_2 = '{ 'h0414, "REG_CHAN_CNTRL_2" , '{
    "IQCOR_COEFF_1": '{ 31, 16, RW, 'h0000 },
    "IQCOR_COEFF_2": '{ 15, 0, RW, 'h0000 }}};
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_2_IQCOR_COEFF_1(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL_2,"IQCOR_COEFF_1",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_2_IQCOR_COEFF_1(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL_2,"IQCOR_COEFF_1",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_2_IQCOR_COEFF_2(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL_2,"IQCOR_COEFF_2",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_2_IQCOR_COEFF_2(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL_2,"IQCOR_COEFF_2",x)

  const reg_t ADC_CHANNEL_REG_CHAN_CNTRL_3 = '{ 'h0418, "REG_CHAN_CNTRL_3" , '{
    "ADC_PN_SEL": '{ 19, 16, RW, 'h0 },
    "ADC_DATA_SEL": '{ 3, 0, RW, 'h0 }}};
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL_3,"ADC_PN_SEL",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL_3,"ADC_PN_SEL",x)
  `define SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_DATA_SEL(x) SetField(ADC_CHANNEL_REG_CHAN_CNTRL_3,"ADC_DATA_SEL",x)
  `define GET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_DATA_SEL(x) GetField(ADC_CHANNEL_REG_CHAN_CNTRL_3,"ADC_DATA_SEL",x)

  const reg_t ADC_CHANNEL_REG_CHAN_USR_CNTRL_1 = '{ 'h0420, "REG_CHAN_USR_CNTRL_1" , '{
    "USR_DATATYPE_BE": '{ 25, 25, RO, 'h0 },
    "USR_DATATYPE_SIGNED": '{ 24, 24, RO, 'h0 },
    "USR_DATATYPE_SHIFT": '{ 23, 16, RO, 'h00 },
    "USR_DATATYPE_TOTAL_BITS": '{ 15, 8, RO, 'h00 },
    "USR_DATATYPE_BITS": '{ 7, 0, RO, 'h00 }}};
  `define SET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_1_USR_DATATYPE_BE(x) SetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_1,"USR_DATATYPE_BE",x)
  `define GET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_1_USR_DATATYPE_BE(x) GetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_1,"USR_DATATYPE_BE",x)
  `define SET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_1_USR_DATATYPE_SIGNED(x) SetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_1,"USR_DATATYPE_SIGNED",x)
  `define GET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_1_USR_DATATYPE_SIGNED(x) GetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_1,"USR_DATATYPE_SIGNED",x)
  `define SET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_1_USR_DATATYPE_SHIFT(x) SetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_1,"USR_DATATYPE_SHIFT",x)
  `define GET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_1_USR_DATATYPE_SHIFT(x) GetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_1,"USR_DATATYPE_SHIFT",x)
  `define SET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_1_USR_DATATYPE_TOTAL_BITS(x) SetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_1,"USR_DATATYPE_TOTAL_BITS",x)
  `define GET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_1_USR_DATATYPE_TOTAL_BITS(x) GetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_1,"USR_DATATYPE_TOTAL_BITS",x)
  `define SET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_1_USR_DATATYPE_BITS(x) SetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_1,"USR_DATATYPE_BITS",x)
  `define GET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_1_USR_DATATYPE_BITS(x) GetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_1,"USR_DATATYPE_BITS",x)

  const reg_t ADC_CHANNEL_REG_CHAN_USR_CNTRL_2 = '{ 'h0424, "REG_CHAN_USR_CNTRL_2" , '{
    "USR_DECIMATION_M": '{ 31, 16, RW, 'h0000 },
    "USR_DECIMATION_N": '{ 15, 0, RW, 'h0000 }}};
  `define SET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_2_USR_DECIMATION_M(x) SetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_2,"USR_DECIMATION_M",x)
  `define GET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_2_USR_DECIMATION_M(x) GetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_2,"USR_DECIMATION_M",x)
  `define SET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_2_USR_DECIMATION_N(x) SetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_2,"USR_DECIMATION_N",x)
  `define GET_ADC_CHANNEL_REG_CHAN_USR_CNTRL_2_USR_DECIMATION_N(x) GetField(ADC_CHANNEL_REG_CHAN_USR_CNTRL_2,"USR_DECIMATION_N",x)


endpackage
