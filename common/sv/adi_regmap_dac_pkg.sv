// ***************************************************************************
// ***************************************************************************
// Copyright 2014 _ 2018 (c) Analog Devices, Inc. All rights reserved.
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

package adi_regmap_dac_pkg;
  import adi_regmap_pkg::*;


/* DAC Common (axi_ad) */

  const reg_t DAC_COMMON_REG_RSTN = '{ 'h0040, "REG_RSTN" , '{
    "CE_N": '{ 2, 2, RW, 'h0 },
    "MMCM_RSTN": '{ 1, 1, RW, 'h0 },
    "RSTN": '{ 0, 0, RW, 'h0 }}};
  `define SET_DAC_COMMON_REG_RSTN_CE_N(x) SetField(DAC_COMMON_REG_RSTN,"CE_N",x)
  `define GET_DAC_COMMON_REG_RSTN_CE_N(x) GetField(DAC_COMMON_REG_RSTN,"CE_N",x)
  `define SET_DAC_COMMON_REG_RSTN_MMCM_RSTN(x) SetField(DAC_COMMON_REG_RSTN,"MMCM_RSTN",x)
  `define GET_DAC_COMMON_REG_RSTN_MMCM_RSTN(x) GetField(DAC_COMMON_REG_RSTN,"MMCM_RSTN",x)
  `define SET_DAC_COMMON_REG_RSTN_RSTN(x) SetField(DAC_COMMON_REG_RSTN,"RSTN",x)
  `define GET_DAC_COMMON_REG_RSTN_RSTN(x) GetField(DAC_COMMON_REG_RSTN,"RSTN",x)

  const reg_t DAC_COMMON_REG_CNTRL_1 = '{ 'h0044, "REG_CNTRL_1" , '{
    "SYNC": '{ 0, 0, RW, 'h0 }}};
  `define SET_DAC_COMMON_REG_CNTRL_1_SYNC(x) SetField(DAC_COMMON_REG_CNTRL_1,"SYNC",x)
  `define GET_DAC_COMMON_REG_CNTRL_1_SYNC(x) GetField(DAC_COMMON_REG_CNTRL_1,"SYNC",x)

  const reg_t DAC_COMMON_REG_CNTRL_2 = '{ 'h0048, "REG_CNTRL_2" , '{
    "PAR_TYPE": '{ 7, 7, RW, 'h0 },
    "PAR_ENB": '{ 6, 6, RW, 'h0 },
    "R1_MODE": '{ 5, 5, RW, 'h0 },
    "DATA_FORMAT": '{ 4, 4, RW, 'h0 },
    "RESERVED": '{ 3, 0, NA, 'h00 }}};
  `define SET_DAC_COMMON_REG_CNTRL_2_PAR_TYPE(x) SetField(DAC_COMMON_REG_CNTRL_2,"PAR_TYPE",x)
  `define GET_DAC_COMMON_REG_CNTRL_2_PAR_TYPE(x) GetField(DAC_COMMON_REG_CNTRL_2,"PAR_TYPE",x)
  `define SET_DAC_COMMON_REG_CNTRL_2_PAR_ENB(x) SetField(DAC_COMMON_REG_CNTRL_2,"PAR_ENB",x)
  `define GET_DAC_COMMON_REG_CNTRL_2_PAR_ENB(x) GetField(DAC_COMMON_REG_CNTRL_2,"PAR_ENB",x)
  `define SET_DAC_COMMON_REG_CNTRL_2_R1_MODE(x) SetField(DAC_COMMON_REG_CNTRL_2,"R1_MODE",x)
  `define GET_DAC_COMMON_REG_CNTRL_2_R1_MODE(x) GetField(DAC_COMMON_REG_CNTRL_2,"R1_MODE",x)
  `define SET_DAC_COMMON_REG_CNTRL_2_DATA_FORMAT(x) SetField(DAC_COMMON_REG_CNTRL_2,"DATA_FORMAT",x)
  `define GET_DAC_COMMON_REG_CNTRL_2_DATA_FORMAT(x) GetField(DAC_COMMON_REG_CNTRL_2,"DATA_FORMAT",x)
  `define SET_DAC_COMMON_REG_CNTRL_2_RESERVED(x) SetField(DAC_COMMON_REG_CNTRL_2,"RESERVED",x)
  `define GET_DAC_COMMON_REG_CNTRL_2_RESERVED(x) GetField(DAC_COMMON_REG_CNTRL_2,"RESERVED",x)

  const reg_t DAC_COMMON_REG_RATECNTRL = '{ 'h004c, "REG_RATECNTRL" , '{
    "RATE": '{ 7, 0, RW, 'h00 }}};
  `define SET_DAC_COMMON_REG_RATECNTRL_RATE(x) SetField(DAC_COMMON_REG_RATECNTRL,"RATE",x)
  `define GET_DAC_COMMON_REG_RATECNTRL_RATE(x) GetField(DAC_COMMON_REG_RATECNTRL,"RATE",x)

  const reg_t DAC_COMMON_REG_FRAME = '{ 'h0050, "REG_FRAME" , '{
    "FRAME": '{ 0, 0, RW, 'h0 }}};
  `define SET_DAC_COMMON_REG_FRAME_FRAME(x) SetField(DAC_COMMON_REG_FRAME,"FRAME",x)
  `define GET_DAC_COMMON_REG_FRAME_FRAME(x) GetField(DAC_COMMON_REG_FRAME,"FRAME",x)

  const reg_t DAC_COMMON_REG_STATUS1 = '{ 'h0054, "REG_STATUS1" , '{
    "CLK_FREQ": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_DAC_COMMON_REG_STATUS1_CLK_FREQ(x) SetField(DAC_COMMON_REG_STATUS1,"CLK_FREQ",x)
  `define GET_DAC_COMMON_REG_STATUS1_CLK_FREQ(x) GetField(DAC_COMMON_REG_STATUS1,"CLK_FREQ",x)

  const reg_t DAC_COMMON_REG_STATUS2 = '{ 'h0058, "REG_STATUS2" , '{
    "CLK_RATIO": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_DAC_COMMON_REG_STATUS2_CLK_RATIO(x) SetField(DAC_COMMON_REG_STATUS2,"CLK_RATIO",x)
  `define GET_DAC_COMMON_REG_STATUS2_CLK_RATIO(x) GetField(DAC_COMMON_REG_STATUS2,"CLK_RATIO",x)

  const reg_t DAC_COMMON_REG_STATUS3 = '{ 'h005c, "REG_STATUS3" , '{
    "STATUS": '{ 0, 0, RO, 'h0 }}};
  `define SET_DAC_COMMON_REG_STATUS3_STATUS(x) SetField(DAC_COMMON_REG_STATUS3,"STATUS",x)
  `define GET_DAC_COMMON_REG_STATUS3_STATUS(x) GetField(DAC_COMMON_REG_STATUS3,"STATUS",x)

  const reg_t DAC_COMMON_REG_DAC_CLKSEL = '{ 'h0060, "REG_DAC_CLKSEL" , '{
    "DAC_CLKSEL": '{ 0, 0, RW, 'h0 }}};
  `define SET_DAC_COMMON_REG_DAC_CLKSEL_DAC_CLKSEL(x) SetField(DAC_COMMON_REG_DAC_CLKSEL,"DAC_CLKSEL",x)
  `define GET_DAC_COMMON_REG_DAC_CLKSEL_DAC_CLKSEL(x) GetField(DAC_COMMON_REG_DAC_CLKSEL,"DAC_CLKSEL",x)

  const reg_t DAC_COMMON_REG_SYNC_STATUS = '{ 'h0068, "REG_SYNC_STATUS" , '{
    "DAC_SYNC_STATUS": '{ 0, 0, RO, 'h0 }}};
  `define SET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(x) SetField(DAC_COMMON_REG_SYNC_STATUS,"DAC_SYNC_STATUS",x)
  `define GET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(x) GetField(DAC_COMMON_REG_SYNC_STATUS,"DAC_SYNC_STATUS",x)

  const reg_t DAC_COMMON_REG_DRP_CNTRL = '{ 'h0070, "REG_DRP_CNTRL" , '{
    "DRP_RWN": '{ 28, 28, RW, 'h0 },
    "DRP_ADDRESS": '{ 27, 16, RW, 'h00 },
    "RESERVED": '{ 15, 0, RO, 'h0000 }}};
  `define SET_DAC_COMMON_REG_DRP_CNTRL_DRP_RWN(x) SetField(DAC_COMMON_REG_DRP_CNTRL,"DRP_RWN",x)
  `define GET_DAC_COMMON_REG_DRP_CNTRL_DRP_RWN(x) GetField(DAC_COMMON_REG_DRP_CNTRL,"DRP_RWN",x)
  `define SET_DAC_COMMON_REG_DRP_CNTRL_DRP_ADDRESS(x) SetField(DAC_COMMON_REG_DRP_CNTRL,"DRP_ADDRESS",x)
  `define GET_DAC_COMMON_REG_DRP_CNTRL_DRP_ADDRESS(x) GetField(DAC_COMMON_REG_DRP_CNTRL,"DRP_ADDRESS",x)
  `define SET_DAC_COMMON_REG_DRP_CNTRL_RESERVED(x) SetField(DAC_COMMON_REG_DRP_CNTRL,"RESERVED",x)
  `define GET_DAC_COMMON_REG_DRP_CNTRL_RESERVED(x) GetField(DAC_COMMON_REG_DRP_CNTRL,"RESERVED",x)

  const reg_t DAC_COMMON_REG_DRP_STATUS = '{ 'h0074, "REG_DRP_STATUS" , '{
    "DRP_LOCKED": '{ 17, 17, RO, 'h0 },
    "DRP_STATUS": '{ 16, 16, RO, 'h0 },
    "RESERVED": '{ 15, 0, RO, 'h0000 }}};
  `define SET_DAC_COMMON_REG_DRP_STATUS_DRP_LOCKED(x) SetField(DAC_COMMON_REG_DRP_STATUS,"DRP_LOCKED",x)
  `define GET_DAC_COMMON_REG_DRP_STATUS_DRP_LOCKED(x) GetField(DAC_COMMON_REG_DRP_STATUS,"DRP_LOCKED",x)
  `define SET_DAC_COMMON_REG_DRP_STATUS_DRP_STATUS(x) SetField(DAC_COMMON_REG_DRP_STATUS,"DRP_STATUS",x)
  `define GET_DAC_COMMON_REG_DRP_STATUS_DRP_STATUS(x) GetField(DAC_COMMON_REG_DRP_STATUS,"DRP_STATUS",x)
  `define SET_DAC_COMMON_REG_DRP_STATUS_RESERVED(x) SetField(DAC_COMMON_REG_DRP_STATUS,"RESERVED",x)
  `define GET_DAC_COMMON_REG_DRP_STATUS_RESERVED(x) GetField(DAC_COMMON_REG_DRP_STATUS,"RESERVED",x)

  const reg_t DAC_COMMON_REG_DRP_WDATA = '{ 'h0078, "REG_DRP_WDATA" , '{
    "DRP_WDATA": '{ 15, 0, RW, 'h0000 }}};
  `define SET_DAC_COMMON_REG_DRP_WDATA_DRP_WDATA(x) SetField(DAC_COMMON_REG_DRP_WDATA,"DRP_WDATA",x)
  `define GET_DAC_COMMON_REG_DRP_WDATA_DRP_WDATA(x) GetField(DAC_COMMON_REG_DRP_WDATA,"DRP_WDATA",x)

  const reg_t DAC_COMMON_REG_DRP_RDATA = '{ 'h007c, "REG_DRP_RDATA" , '{
    "DRP_RDATA": '{ 15, 0, RO, 'h0000 }}};
  `define SET_DAC_COMMON_REG_DRP_RDATA_DRP_RDATA(x) SetField(DAC_COMMON_REG_DRP_RDATA,"DRP_RDATA",x)
  `define GET_DAC_COMMON_REG_DRP_RDATA_DRP_RDATA(x) GetField(DAC_COMMON_REG_DRP_RDATA,"DRP_RDATA",x)

  const reg_t DAC_COMMON_REG_UI_STATUS = '{ 'h0088, "REG_UI_STATUS" , '{
    "UI_OVF": '{ 1, 1, RW1C, 'h0 },
    "UI_UNF": '{ 0, 0, RW1C, 'h0 }}};
  `define SET_DAC_COMMON_REG_UI_STATUS_UI_OVF(x) SetField(DAC_COMMON_REG_UI_STATUS,"UI_OVF",x)
  `define GET_DAC_COMMON_REG_UI_STATUS_UI_OVF(x) GetField(DAC_COMMON_REG_UI_STATUS,"UI_OVF",x)
  `define SET_DAC_COMMON_REG_UI_STATUS_UI_UNF(x) SetField(DAC_COMMON_REG_UI_STATUS,"UI_UNF",x)
  `define GET_DAC_COMMON_REG_UI_STATUS_UI_UNF(x) GetField(DAC_COMMON_REG_UI_STATUS,"UI_UNF",x)

  const reg_t DAC_COMMON_REG_USR_CNTRL_1 = '{ 'h00a0, "REG_USR_CNTRL_1" , '{
    "USR_CHANMAX": '{ 7, 0, RW, 'h00 }}};
  `define SET_DAC_COMMON_REG_USR_CNTRL_1_USR_CHANMAX(x) SetField(DAC_COMMON_REG_USR_CNTRL_1,"USR_CHANMAX",x)
  `define GET_DAC_COMMON_REG_USR_CNTRL_1_USR_CHANMAX(x) GetField(DAC_COMMON_REG_USR_CNTRL_1,"USR_CHANMAX",x)

  const reg_t DAC_COMMON_REG_DAC_GPIO_IN = '{ 'h00b8, "REG_DAC_GPIO_IN" , '{
    "DAC_GPIO_IN": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_DAC_COMMON_REG_DAC_GPIO_IN_DAC_GPIO_IN(x) SetField(DAC_COMMON_REG_DAC_GPIO_IN,"DAC_GPIO_IN",x)
  `define GET_DAC_COMMON_REG_DAC_GPIO_IN_DAC_GPIO_IN(x) GetField(DAC_COMMON_REG_DAC_GPIO_IN,"DAC_GPIO_IN",x)

  const reg_t DAC_COMMON_REG_DAC_GPIO_OUT = '{ 'h00bc, "REG_DAC_GPIO_OUT" , '{
    "DAC_GPIO_OUT": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_DAC_COMMON_REG_DAC_GPIO_OUT_DAC_GPIO_OUT(x) SetField(DAC_COMMON_REG_DAC_GPIO_OUT,"DAC_GPIO_OUT",x)
  `define GET_DAC_COMMON_REG_DAC_GPIO_OUT_DAC_GPIO_OUT(x) GetField(DAC_COMMON_REG_DAC_GPIO_OUT,"DAC_GPIO_OUT",x)


/* DAC Channel (axi_ad*) */

  const reg_t DAC_CHANNEL_REG_CHAN_CNTRL_1 = '{ 'h0400, "REG_CHAN_CNTRL_1" , '{
    "DDS_SCALE_1": '{ 15, 0, RW, 'h0000 }}};
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_1,"DDS_SCALE_1",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_1,"DDS_SCALE_1",x)

  const reg_t DAC_CHANNEL_REG_CHAN_CNTRL_2 = '{ 'h0404, "REG_CHAN_CNTRL_2" , '{
    "DDS_INIT_1": '{ 31, 16, RW, 'h0000 },
    "DDS_INCR_1": '{ 15, 0, RW, 'h0000 }}};
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INIT_1(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_2,"DDS_INIT_1",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INIT_1(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_2,"DDS_INIT_1",x)
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_2,"DDS_INCR_1",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_2,"DDS_INCR_1",x)

  const reg_t DAC_CHANNEL_REG_CHAN_CNTRL_3 = '{ 'h0408, "REG_CHAN_CNTRL_3" , '{
    "DDS_SCALE_2": '{ 15, 0, RW, 'h0000 }}};
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_3_DDS_SCALE_2(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_3,"DDS_SCALE_2",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_3_DDS_SCALE_2(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_3,"DDS_SCALE_2",x)

  const reg_t DAC_CHANNEL_REG_CHAN_CNTRL_4 = '{ 'h040c, "REG_CHAN_CNTRL_4" , '{
    "DDS_INIT_2": '{ 31, 16, RW, 'h0000 },
    "DDS_INCR_2": '{ 15, 0, RW, 'h0000 }}};
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_4_DDS_INIT_2(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_4,"DDS_INIT_2",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_4_DDS_INIT_2(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_4,"DDS_INIT_2",x)
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_4_DDS_INCR_2(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_4,"DDS_INCR_2",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_4_DDS_INCR_2(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_4,"DDS_INCR_2",x)

  const reg_t DAC_CHANNEL_REG_CHAN_CNTRL_5 = '{ 'h0410, "REG_CHAN_CNTRL_5" , '{
    "DDS_PATT_2": '{ 31, 16, RW, 'h0000 },
    "DDS_PATT_1": '{ 15, 0, RW, 'h0000 }}};
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_5_DDS_PATT_2(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_5,"DDS_PATT_2",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_5_DDS_PATT_2(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_5,"DDS_PATT_2",x)
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_5_DDS_PATT_1(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_5,"DDS_PATT_1",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_5_DDS_PATT_1(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_5,"DDS_PATT_1",x)

  const reg_t DAC_CHANNEL_REG_CHAN_CNTRL_6 = '{ 'h0414, "REG_CHAN_CNTRL_6" , '{
    "IQCOR_ENB": '{ 2, 2, RW, 'h0 },
    "DAC_LB_OWR": '{ 1, 1, RW, 'h0 },
    "DAC_PN_OWR": '{ 0, 0, RW, 'h0 }}};
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_6_IQCOR_ENB(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_6,"IQCOR_ENB",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_6_IQCOR_ENB(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_6,"IQCOR_ENB",x)
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_6_DAC_LB_OWR(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_6,"DAC_LB_OWR",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_6_DAC_LB_OWR(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_6,"DAC_LB_OWR",x)
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_6_DAC_PN_OWR(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_6,"DAC_PN_OWR",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_6_DAC_PN_OWR(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_6,"DAC_PN_OWR",x)

  const reg_t DAC_CHANNEL_REG_CHAN_CNTRL_7 = '{ 'h0418, "REG_CHAN_CNTRL_7" , '{
    "DAC_DDS_SEL": '{ 3, 0, RW, 'h00 }}};
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_7,"DAC_DDS_SEL",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_7,"DAC_DDS_SEL",x)

  const reg_t DAC_CHANNEL_REG_CHAN_CNTRL_8 = '{ 'h041c, "REG_CHAN_CNTRL_8" , '{
    "IQCOR_COEFF_1": '{ 31, 16, RW, 'h0000 },
    "IQCOR_COEFF_2": '{ 15, 0, RW, 'h0000 }}};
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_8_IQCOR_COEFF_1(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_8,"IQCOR_COEFF_1",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_8_IQCOR_COEFF_1(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_8,"IQCOR_COEFF_1",x)
  `define SET_DAC_CHANNEL_REG_CHAN_CNTRL_8_IQCOR_COEFF_2(x) SetField(DAC_CHANNEL_REG_CHAN_CNTRL_8,"IQCOR_COEFF_2",x)
  `define GET_DAC_CHANNEL_REG_CHAN_CNTRL_8_IQCOR_COEFF_2(x) GetField(DAC_CHANNEL_REG_CHAN_CNTRL_8,"IQCOR_COEFF_2",x)

  const reg_t DAC_CHANNEL_REG_USR_CNTRL_3 = '{ 'h0420, "REG_USR_CNTRL_3" , '{
    "USR_DATATYPE_BE": '{ 25, 25, RW, 'h0 },
    "USR_DATATYPE_SIGNED": '{ 24, 24, RW, 'h0 },
    "USR_DATATYPE_SHIFT": '{ 23, 16, RW, 'h00 },
    "USR_DATATYPE_TOTAL_BITS": '{ 15, 8, RW, 'h00 },
    "USR_DATATYPE_BITS": '{ 7, 0, RW, 'h00 }}};
  `define SET_DAC_CHANNEL_REG_USR_CNTRL_3_USR_DATATYPE_BE(x) SetField(DAC_CHANNEL_REG_USR_CNTRL_3,"USR_DATATYPE_BE",x)
  `define GET_DAC_CHANNEL_REG_USR_CNTRL_3_USR_DATATYPE_BE(x) GetField(DAC_CHANNEL_REG_USR_CNTRL_3,"USR_DATATYPE_BE",x)
  `define SET_DAC_CHANNEL_REG_USR_CNTRL_3_USR_DATATYPE_SIGNED(x) SetField(DAC_CHANNEL_REG_USR_CNTRL_3,"USR_DATATYPE_SIGNED",x)
  `define GET_DAC_CHANNEL_REG_USR_CNTRL_3_USR_DATATYPE_SIGNED(x) GetField(DAC_CHANNEL_REG_USR_CNTRL_3,"USR_DATATYPE_SIGNED",x)
  `define SET_DAC_CHANNEL_REG_USR_CNTRL_3_USR_DATATYPE_SHIFT(x) SetField(DAC_CHANNEL_REG_USR_CNTRL_3,"USR_DATATYPE_SHIFT",x)
  `define GET_DAC_CHANNEL_REG_USR_CNTRL_3_USR_DATATYPE_SHIFT(x) GetField(DAC_CHANNEL_REG_USR_CNTRL_3,"USR_DATATYPE_SHIFT",x)
  `define SET_DAC_CHANNEL_REG_USR_CNTRL_3_USR_DATATYPE_TOTAL_BITS(x) SetField(DAC_CHANNEL_REG_USR_CNTRL_3,"USR_DATATYPE_TOTAL_BITS",x)
  `define GET_DAC_CHANNEL_REG_USR_CNTRL_3_USR_DATATYPE_TOTAL_BITS(x) GetField(DAC_CHANNEL_REG_USR_CNTRL_3,"USR_DATATYPE_TOTAL_BITS",x)
  `define SET_DAC_CHANNEL_REG_USR_CNTRL_3_USR_DATATYPE_BITS(x) SetField(DAC_CHANNEL_REG_USR_CNTRL_3,"USR_DATATYPE_BITS",x)
  `define GET_DAC_CHANNEL_REG_USR_CNTRL_3_USR_DATATYPE_BITS(x) GetField(DAC_CHANNEL_REG_USR_CNTRL_3,"USR_DATATYPE_BITS",x)

  const reg_t DAC_CHANNEL_REG_USR_CNTRL_4 = '{ 'h0424, "REG_USR_CNTRL_4" , '{
    "USR_INTERPOLATION_M": '{ 31, 16, RW, 'h0000 },
    "USR_INTERPOLATION_N": '{ 15, 0, RW, 'h0000 }}};
  `define SET_DAC_CHANNEL_REG_USR_CNTRL_4_USR_INTERPOLATION_M(x) SetField(DAC_CHANNEL_REG_USR_CNTRL_4,"USR_INTERPOLATION_M",x)
  `define GET_DAC_CHANNEL_REG_USR_CNTRL_4_USR_INTERPOLATION_M(x) GetField(DAC_CHANNEL_REG_USR_CNTRL_4,"USR_INTERPOLATION_M",x)
  `define SET_DAC_CHANNEL_REG_USR_CNTRL_4_USR_INTERPOLATION_N(x) SetField(DAC_CHANNEL_REG_USR_CNTRL_4,"USR_INTERPOLATION_N",x)
  `define GET_DAC_CHANNEL_REG_USR_CNTRL_4_USR_INTERPOLATION_N(x) GetField(DAC_CHANNEL_REG_USR_CNTRL_4,"USR_INTERPOLATION_N",x)

  const reg_t DAC_CHANNEL_REG_USR_CNTRL_5 = '{ 'h0428, "REG_USR_CNTRL_5" , '{
    "DAC_IQ_MODE": '{ 0, 0, RW, 'h0 },
    "DAC_IQ_SWAP": '{ 1, 1, RW, 'h0 }}};
  `define SET_DAC_CHANNEL_REG_USR_CNTRL_5_DAC_IQ_MODE(x) SetField(DAC_CHANNEL_REG_USR_CNTRL_5,"DAC_IQ_MODE",x)
  `define GET_DAC_CHANNEL_REG_USR_CNTRL_5_DAC_IQ_MODE(x) GetField(DAC_CHANNEL_REG_USR_CNTRL_5,"DAC_IQ_MODE",x)
  `define SET_DAC_CHANNEL_REG_USR_CNTRL_5_DAC_IQ_SWAP(x) SetField(DAC_CHANNEL_REG_USR_CNTRL_5,"DAC_IQ_SWAP",x)
  `define GET_DAC_CHANNEL_REG_USR_CNTRL_5_DAC_IQ_SWAP(x) GetField(DAC_CHANNEL_REG_USR_CNTRL_5,"DAC_IQ_SWAP",x)


endpackage
