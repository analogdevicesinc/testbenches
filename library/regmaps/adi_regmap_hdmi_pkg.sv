// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2024 Analog Devices, Inc. All rights reserved.
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
/* Thu Mar 28 13:22:23 2024 */

package adi_regmap_hdmi_pkg;
  import adi_regmap_pkg::*;


/* HDMI Transmit (axi_hdmi_tx) */

  const reg_t HDMI_TX_REG_RSTN = '{ 'h0040, "REG_RSTN" , '{
    "RSTN": '{ 0, 0, RW, 'h0 }}};
  `define SET_HDMI_TX_REG_RSTN_RSTN(x) SetField(HDMI_TX_REG_RSTN,"RSTN",x)
  `define GET_HDMI_TX_REG_RSTN_RSTN(x) GetField(HDMI_TX_REG_RSTN,"RSTN",x)
  `define DEFAULT_HDMI_TX_REG_RSTN_RSTN GetResetValue(HDMI_TX_REG_RSTN,"RSTN")
  `define UPDATE_HDMI_TX_REG_RSTN_RSTN(x,y) UpdateField(HDMI_TX_REG_RSTN,"RSTN",x,y)

  const reg_t HDMI_TX_REG_CNTRL1 = '{ 'h0044, "REG_CNTRL1" , '{
    "SS_BYPASS": '{ 2, 2, RW, 'h0 },
    "CSC_BYPASS": '{ 0, 0, RW, 'h0 }}};
  `define SET_HDMI_TX_REG_CNTRL1_SS_BYPASS(x) SetField(HDMI_TX_REG_CNTRL1,"SS_BYPASS",x)
  `define GET_HDMI_TX_REG_CNTRL1_SS_BYPASS(x) GetField(HDMI_TX_REG_CNTRL1,"SS_BYPASS",x)
  `define DEFAULT_HDMI_TX_REG_CNTRL1_SS_BYPASS GetResetValue(HDMI_TX_REG_CNTRL1,"SS_BYPASS")
  `define UPDATE_HDMI_TX_REG_CNTRL1_SS_BYPASS(x,y) UpdateField(HDMI_TX_REG_CNTRL1,"SS_BYPASS",x,y)
  `define SET_HDMI_TX_REG_CNTRL1_CSC_BYPASS(x) SetField(HDMI_TX_REG_CNTRL1,"CSC_BYPASS",x)
  `define GET_HDMI_TX_REG_CNTRL1_CSC_BYPASS(x) GetField(HDMI_TX_REG_CNTRL1,"CSC_BYPASS",x)
  `define DEFAULT_HDMI_TX_REG_CNTRL1_CSC_BYPASS GetResetValue(HDMI_TX_REG_CNTRL1,"CSC_BYPASS")
  `define UPDATE_HDMI_TX_REG_CNTRL1_CSC_BYPASS(x,y) UpdateField(HDMI_TX_REG_CNTRL1,"CSC_BYPASS",x,y)

  const reg_t HDMI_TX_REG_CNTRL2 = '{ 'h0048, "REG_CNTRL2" , '{
    "SOURCE_SEL": '{ 1, 0, RW, 'h0 }}};
  `define SET_HDMI_TX_REG_CNTRL2_SOURCE_SEL(x) SetField(HDMI_TX_REG_CNTRL2,"SOURCE_SEL",x)
  `define GET_HDMI_TX_REG_CNTRL2_SOURCE_SEL(x) GetField(HDMI_TX_REG_CNTRL2,"SOURCE_SEL",x)
  `define DEFAULT_HDMI_TX_REG_CNTRL2_SOURCE_SEL GetResetValue(HDMI_TX_REG_CNTRL2,"SOURCE_SEL")
  `define UPDATE_HDMI_TX_REG_CNTRL2_SOURCE_SEL(x,y) UpdateField(HDMI_TX_REG_CNTRL2,"SOURCE_SEL",x,y)

  const reg_t HDMI_TX_REG_CNTRL3 = '{ 'h004c, "REG_CNTRL3" , '{
    "CONST_RGB": '{ 23, 0, RW, 'h000000 }}};
  `define SET_HDMI_TX_REG_CNTRL3_CONST_RGB(x) SetField(HDMI_TX_REG_CNTRL3,"CONST_RGB",x)
  `define GET_HDMI_TX_REG_CNTRL3_CONST_RGB(x) GetField(HDMI_TX_REG_CNTRL3,"CONST_RGB",x)
  `define DEFAULT_HDMI_TX_REG_CNTRL3_CONST_RGB GetResetValue(HDMI_TX_REG_CNTRL3,"CONST_RGB")
  `define UPDATE_HDMI_TX_REG_CNTRL3_CONST_RGB(x,y) UpdateField(HDMI_TX_REG_CNTRL3,"CONST_RGB",x,y)

  const reg_t HDMI_TX_REG_CLK_FREQ = '{ 'h0054, "REG_CLK_FREQ" , '{
    "CLK_FREQ": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_HDMI_TX_REG_CLK_FREQ_CLK_FREQ(x) SetField(HDMI_TX_REG_CLK_FREQ,"CLK_FREQ",x)
  `define GET_HDMI_TX_REG_CLK_FREQ_CLK_FREQ(x) GetField(HDMI_TX_REG_CLK_FREQ,"CLK_FREQ",x)
  `define DEFAULT_HDMI_TX_REG_CLK_FREQ_CLK_FREQ GetResetValue(HDMI_TX_REG_CLK_FREQ,"CLK_FREQ")
  `define UPDATE_HDMI_TX_REG_CLK_FREQ_CLK_FREQ(x,y) UpdateField(HDMI_TX_REG_CLK_FREQ,"CLK_FREQ",x,y)

  const reg_t HDMI_TX_REG_CLK_RATIO = '{ 'h0058, "REG_CLK_RATIO" , '{
    "CLK_RATIO": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_HDMI_TX_REG_CLK_RATIO_CLK_RATIO(x) SetField(HDMI_TX_REG_CLK_RATIO,"CLK_RATIO",x)
  `define GET_HDMI_TX_REG_CLK_RATIO_CLK_RATIO(x) GetField(HDMI_TX_REG_CLK_RATIO,"CLK_RATIO",x)
  `define DEFAULT_HDMI_TX_REG_CLK_RATIO_CLK_RATIO GetResetValue(HDMI_TX_REG_CLK_RATIO,"CLK_RATIO")
  `define UPDATE_HDMI_TX_REG_CLK_RATIO_CLK_RATIO(x,y) UpdateField(HDMI_TX_REG_CLK_RATIO,"CLK_RATIO",x,y)

  const reg_t HDMI_TX_REG_STATUS = '{ 'h005c, "REG_STATUS" , '{
    "STATUS": '{ 0, 0, RO, 'h0 }}};
  `define SET_HDMI_TX_REG_STATUS_STATUS(x) SetField(HDMI_TX_REG_STATUS,"STATUS",x)
  `define GET_HDMI_TX_REG_STATUS_STATUS(x) GetField(HDMI_TX_REG_STATUS,"STATUS",x)
  `define DEFAULT_HDMI_TX_REG_STATUS_STATUS GetResetValue(HDMI_TX_REG_STATUS,"STATUS")
  `define UPDATE_HDMI_TX_REG_STATUS_STATUS(x,y) UpdateField(HDMI_TX_REG_STATUS,"STATUS",x,y)

  const reg_t HDMI_TX_REG_VDMA_STATUS = '{ 'h0060, "REG_VDMA_STATUS" , '{
    "VDMA_OVF": '{ 1, 1, RW1C, 'h0 },
    "VDMA_UNF": '{ 0, 0, RW1C, 'h0 }}};
  `define SET_HDMI_TX_REG_VDMA_STATUS_VDMA_OVF(x) SetField(HDMI_TX_REG_VDMA_STATUS,"VDMA_OVF",x)
  `define GET_HDMI_TX_REG_VDMA_STATUS_VDMA_OVF(x) GetField(HDMI_TX_REG_VDMA_STATUS,"VDMA_OVF",x)
  `define DEFAULT_HDMI_TX_REG_VDMA_STATUS_VDMA_OVF GetResetValue(HDMI_TX_REG_VDMA_STATUS,"VDMA_OVF")
  `define UPDATE_HDMI_TX_REG_VDMA_STATUS_VDMA_OVF(x,y) UpdateField(HDMI_TX_REG_VDMA_STATUS,"VDMA_OVF",x,y)
  `define SET_HDMI_TX_REG_VDMA_STATUS_VDMA_UNF(x) SetField(HDMI_TX_REG_VDMA_STATUS,"VDMA_UNF",x)
  `define GET_HDMI_TX_REG_VDMA_STATUS_VDMA_UNF(x) GetField(HDMI_TX_REG_VDMA_STATUS,"VDMA_UNF",x)
  `define DEFAULT_HDMI_TX_REG_VDMA_STATUS_VDMA_UNF GetResetValue(HDMI_TX_REG_VDMA_STATUS,"VDMA_UNF")
  `define UPDATE_HDMI_TX_REG_VDMA_STATUS_VDMA_UNF(x,y) UpdateField(HDMI_TX_REG_VDMA_STATUS,"VDMA_UNF",x,y)

  const reg_t HDMI_TX_REG_TPM_STATUS = '{ 'h0064, "REG_TPM_STATUS" , '{
    "HDMI_TPM_OOS": '{ 1, 1, RW1C, 'h0 },
    "VDMA_TPM_OOS": '{ 0, 0, RW1C, 'h0 }}};
  `define SET_HDMI_TX_REG_TPM_STATUS_HDMI_TPM_OOS(x) SetField(HDMI_TX_REG_TPM_STATUS,"HDMI_TPM_OOS",x)
  `define GET_HDMI_TX_REG_TPM_STATUS_HDMI_TPM_OOS(x) GetField(HDMI_TX_REG_TPM_STATUS,"HDMI_TPM_OOS",x)
  `define DEFAULT_HDMI_TX_REG_TPM_STATUS_HDMI_TPM_OOS GetResetValue(HDMI_TX_REG_TPM_STATUS,"HDMI_TPM_OOS")
  `define UPDATE_HDMI_TX_REG_TPM_STATUS_HDMI_TPM_OOS(x,y) UpdateField(HDMI_TX_REG_TPM_STATUS,"HDMI_TPM_OOS",x,y)
  `define SET_HDMI_TX_REG_TPM_STATUS_VDMA_TPM_OOS(x) SetField(HDMI_TX_REG_TPM_STATUS,"VDMA_TPM_OOS",x)
  `define GET_HDMI_TX_REG_TPM_STATUS_VDMA_TPM_OOS(x) GetField(HDMI_TX_REG_TPM_STATUS,"VDMA_TPM_OOS",x)
  `define DEFAULT_HDMI_TX_REG_TPM_STATUS_VDMA_TPM_OOS GetResetValue(HDMI_TX_REG_TPM_STATUS,"VDMA_TPM_OOS")
  `define UPDATE_HDMI_TX_REG_TPM_STATUS_VDMA_TPM_OOS(x,y) UpdateField(HDMI_TX_REG_TPM_STATUS,"VDMA_TPM_OOS",x,y)

  const reg_t HDMI_TX_REG_CLIPP_MAX = '{ 'h0068, "REG_CLIPP_MAX" , '{
    "R_MAX/Cr_MAX": '{ 23, 16, RW, 'hF0 },
    "G_MAX/Y_MAX": '{ 16, 8, RW, 'hEB },
    "B_MAX/Cb_MAX": '{ 7, 0, RW, 'hF0 }}};
  `define SET_HDMI_TX_REG_CLIPP_MAX_R_MAX/Cr_MAX(x) SetField(HDMI_TX_REG_CLIPP_MAX,"R_MAX/Cr_MAX",x)
  `define GET_HDMI_TX_REG_CLIPP_MAX_R_MAX/Cr_MAX(x) GetField(HDMI_TX_REG_CLIPP_MAX,"R_MAX/Cr_MAX",x)
  `define DEFAULT_HDMI_TX_REG_CLIPP_MAX_R_MAX/Cr_MAX GetResetValue(HDMI_TX_REG_CLIPP_MAX,"R_MAX/Cr_MAX")
  `define UPDATE_HDMI_TX_REG_CLIPP_MAX_R_MAX/Cr_MAX(x,y) UpdateField(HDMI_TX_REG_CLIPP_MAX,"R_MAX/Cr_MAX",x,y)
  `define SET_HDMI_TX_REG_CLIPP_MAX_G_MAX/Y_MAX(x) SetField(HDMI_TX_REG_CLIPP_MAX,"G_MAX/Y_MAX",x)
  `define GET_HDMI_TX_REG_CLIPP_MAX_G_MAX/Y_MAX(x) GetField(HDMI_TX_REG_CLIPP_MAX,"G_MAX/Y_MAX",x)
  `define DEFAULT_HDMI_TX_REG_CLIPP_MAX_G_MAX/Y_MAX GetResetValue(HDMI_TX_REG_CLIPP_MAX,"G_MAX/Y_MAX")
  `define UPDATE_HDMI_TX_REG_CLIPP_MAX_G_MAX/Y_MAX(x,y) UpdateField(HDMI_TX_REG_CLIPP_MAX,"G_MAX/Y_MAX",x,y)
  `define SET_HDMI_TX_REG_CLIPP_MAX_B_MAX/Cb_MAX(x) SetField(HDMI_TX_REG_CLIPP_MAX,"B_MAX/Cb_MAX",x)
  `define GET_HDMI_TX_REG_CLIPP_MAX_B_MAX/Cb_MAX(x) GetField(HDMI_TX_REG_CLIPP_MAX,"B_MAX/Cb_MAX",x)
  `define DEFAULT_HDMI_TX_REG_CLIPP_MAX_B_MAX/Cb_MAX GetResetValue(HDMI_TX_REG_CLIPP_MAX,"B_MAX/Cb_MAX")
  `define UPDATE_HDMI_TX_REG_CLIPP_MAX_B_MAX/Cb_MAX(x,y) UpdateField(HDMI_TX_REG_CLIPP_MAX,"B_MAX/Cb_MAX",x,y)

  const reg_t HDMI_TX_REG_CLIPP_MIN = '{ 'h006c, "REG_CLIPP_MIN" , '{
    "R_MIN/Cr_MIN": '{ 23, 16, RW, 'h10 },
    "G_MIN/Y_MIN": '{ 16, 8, RW, 'h10 },
    "B_MIN/Cb_MIN": '{ 7, 0, RW, 'h10 }}};
  `define SET_HDMI_TX_REG_CLIPP_MIN_R_MIN/Cr_MIN(x) SetField(HDMI_TX_REG_CLIPP_MIN,"R_MIN/Cr_MIN",x)
  `define GET_HDMI_TX_REG_CLIPP_MIN_R_MIN/Cr_MIN(x) GetField(HDMI_TX_REG_CLIPP_MIN,"R_MIN/Cr_MIN",x)
  `define DEFAULT_HDMI_TX_REG_CLIPP_MIN_R_MIN/Cr_MIN GetResetValue(HDMI_TX_REG_CLIPP_MIN,"R_MIN/Cr_MIN")
  `define UPDATE_HDMI_TX_REG_CLIPP_MIN_R_MIN/Cr_MIN(x,y) UpdateField(HDMI_TX_REG_CLIPP_MIN,"R_MIN/Cr_MIN",x,y)
  `define SET_HDMI_TX_REG_CLIPP_MIN_G_MIN/Y_MIN(x) SetField(HDMI_TX_REG_CLIPP_MIN,"G_MIN/Y_MIN",x)
  `define GET_HDMI_TX_REG_CLIPP_MIN_G_MIN/Y_MIN(x) GetField(HDMI_TX_REG_CLIPP_MIN,"G_MIN/Y_MIN",x)
  `define DEFAULT_HDMI_TX_REG_CLIPP_MIN_G_MIN/Y_MIN GetResetValue(HDMI_TX_REG_CLIPP_MIN,"G_MIN/Y_MIN")
  `define UPDATE_HDMI_TX_REG_CLIPP_MIN_G_MIN/Y_MIN(x,y) UpdateField(HDMI_TX_REG_CLIPP_MIN,"G_MIN/Y_MIN",x,y)
  `define SET_HDMI_TX_REG_CLIPP_MIN_B_MIN/Cb_MIN(x) SetField(HDMI_TX_REG_CLIPP_MIN,"B_MIN/Cb_MIN",x)
  `define GET_HDMI_TX_REG_CLIPP_MIN_B_MIN/Cb_MIN(x) GetField(HDMI_TX_REG_CLIPP_MIN,"B_MIN/Cb_MIN",x)
  `define DEFAULT_HDMI_TX_REG_CLIPP_MIN_B_MIN/Cb_MIN GetResetValue(HDMI_TX_REG_CLIPP_MIN,"B_MIN/Cb_MIN")
  `define UPDATE_HDMI_TX_REG_CLIPP_MIN_B_MIN/Cb_MIN(x,y) UpdateField(HDMI_TX_REG_CLIPP_MIN,"B_MIN/Cb_MIN",x,y)

  const reg_t HDMI_TX_REG_HSYNC_1 = '{ 'h0400, "REG_HSYNC_1" , '{
    "H_LINE_ACTIVE": '{ 31, 16, RW, 'h0000 },
    "H_LINE_WIDTH": '{ 15, 0, RW, 'h0000 }}};
  `define SET_HDMI_TX_REG_HSYNC_1_H_LINE_ACTIVE(x) SetField(HDMI_TX_REG_HSYNC_1,"H_LINE_ACTIVE",x)
  `define GET_HDMI_TX_REG_HSYNC_1_H_LINE_ACTIVE(x) GetField(HDMI_TX_REG_HSYNC_1,"H_LINE_ACTIVE",x)
  `define DEFAULT_HDMI_TX_REG_HSYNC_1_H_LINE_ACTIVE GetResetValue(HDMI_TX_REG_HSYNC_1,"H_LINE_ACTIVE")
  `define UPDATE_HDMI_TX_REG_HSYNC_1_H_LINE_ACTIVE(x,y) UpdateField(HDMI_TX_REG_HSYNC_1,"H_LINE_ACTIVE",x,y)
  `define SET_HDMI_TX_REG_HSYNC_1_H_LINE_WIDTH(x) SetField(HDMI_TX_REG_HSYNC_1,"H_LINE_WIDTH",x)
  `define GET_HDMI_TX_REG_HSYNC_1_H_LINE_WIDTH(x) GetField(HDMI_TX_REG_HSYNC_1,"H_LINE_WIDTH",x)
  `define DEFAULT_HDMI_TX_REG_HSYNC_1_H_LINE_WIDTH GetResetValue(HDMI_TX_REG_HSYNC_1,"H_LINE_WIDTH")
  `define UPDATE_HDMI_TX_REG_HSYNC_1_H_LINE_WIDTH(x,y) UpdateField(HDMI_TX_REG_HSYNC_1,"H_LINE_WIDTH",x,y)

  const reg_t HDMI_TX_REG_HSYNC_2 = '{ 'h0404, "REG_HSYNC_2" , '{
    "H_SYNC_WIDTH": '{ 15, 0, RW, 'h0000 }}};
  `define SET_HDMI_TX_REG_HSYNC_2_H_SYNC_WIDTH(x) SetField(HDMI_TX_REG_HSYNC_2,"H_SYNC_WIDTH",x)
  `define GET_HDMI_TX_REG_HSYNC_2_H_SYNC_WIDTH(x) GetField(HDMI_TX_REG_HSYNC_2,"H_SYNC_WIDTH",x)
  `define DEFAULT_HDMI_TX_REG_HSYNC_2_H_SYNC_WIDTH GetResetValue(HDMI_TX_REG_HSYNC_2,"H_SYNC_WIDTH")
  `define UPDATE_HDMI_TX_REG_HSYNC_2_H_SYNC_WIDTH(x,y) UpdateField(HDMI_TX_REG_HSYNC_2,"H_SYNC_WIDTH",x,y)

  const reg_t HDMI_TX_REG_HSYNC_3 = '{ 'h0408, "REG_HSYNC_3" , '{
    "H_ENABLE_MAX": '{ 31, 16, RW, 'h0000 },
    "H_ENABLE_MIN": '{ 15, 0, RW, 'h0000 }}};
  `define SET_HDMI_TX_REG_HSYNC_3_H_ENABLE_MAX(x) SetField(HDMI_TX_REG_HSYNC_3,"H_ENABLE_MAX",x)
  `define GET_HDMI_TX_REG_HSYNC_3_H_ENABLE_MAX(x) GetField(HDMI_TX_REG_HSYNC_3,"H_ENABLE_MAX",x)
  `define DEFAULT_HDMI_TX_REG_HSYNC_3_H_ENABLE_MAX GetResetValue(HDMI_TX_REG_HSYNC_3,"H_ENABLE_MAX")
  `define UPDATE_HDMI_TX_REG_HSYNC_3_H_ENABLE_MAX(x,y) UpdateField(HDMI_TX_REG_HSYNC_3,"H_ENABLE_MAX",x,y)
  `define SET_HDMI_TX_REG_HSYNC_3_H_ENABLE_MIN(x) SetField(HDMI_TX_REG_HSYNC_3,"H_ENABLE_MIN",x)
  `define GET_HDMI_TX_REG_HSYNC_3_H_ENABLE_MIN(x) GetField(HDMI_TX_REG_HSYNC_3,"H_ENABLE_MIN",x)
  `define DEFAULT_HDMI_TX_REG_HSYNC_3_H_ENABLE_MIN GetResetValue(HDMI_TX_REG_HSYNC_3,"H_ENABLE_MIN")
  `define UPDATE_HDMI_TX_REG_HSYNC_3_H_ENABLE_MIN(x,y) UpdateField(HDMI_TX_REG_HSYNC_3,"H_ENABLE_MIN",x,y)

  const reg_t HDMI_TX_REG_VSYNC_1 = '{ 'h0440, "REG_VSYNC_1" , '{
    "V_FRAME_ACTIVE": '{ 31, 16, RW, 'h0000 },
    "V_FRAME_WIDTH": '{ 15, 0, RW, 'h0000 }}};
  `define SET_HDMI_TX_REG_VSYNC_1_V_FRAME_ACTIVE(x) SetField(HDMI_TX_REG_VSYNC_1,"V_FRAME_ACTIVE",x)
  `define GET_HDMI_TX_REG_VSYNC_1_V_FRAME_ACTIVE(x) GetField(HDMI_TX_REG_VSYNC_1,"V_FRAME_ACTIVE",x)
  `define DEFAULT_HDMI_TX_REG_VSYNC_1_V_FRAME_ACTIVE GetResetValue(HDMI_TX_REG_VSYNC_1,"V_FRAME_ACTIVE")
  `define UPDATE_HDMI_TX_REG_VSYNC_1_V_FRAME_ACTIVE(x,y) UpdateField(HDMI_TX_REG_VSYNC_1,"V_FRAME_ACTIVE",x,y)
  `define SET_HDMI_TX_REG_VSYNC_1_V_FRAME_WIDTH(x) SetField(HDMI_TX_REG_VSYNC_1,"V_FRAME_WIDTH",x)
  `define GET_HDMI_TX_REG_VSYNC_1_V_FRAME_WIDTH(x) GetField(HDMI_TX_REG_VSYNC_1,"V_FRAME_WIDTH",x)
  `define DEFAULT_HDMI_TX_REG_VSYNC_1_V_FRAME_WIDTH GetResetValue(HDMI_TX_REG_VSYNC_1,"V_FRAME_WIDTH")
  `define UPDATE_HDMI_TX_REG_VSYNC_1_V_FRAME_WIDTH(x,y) UpdateField(HDMI_TX_REG_VSYNC_1,"V_FRAME_WIDTH",x,y)

  const reg_t HDMI_TX_REG_VSYNC_2 = '{ 'h0444, "REG_VSYNC_2" , '{
    "V_SYNC_WIDTH": '{ 15, 0, RW, 'h0000 }}};
  `define SET_HDMI_TX_REG_VSYNC_2_V_SYNC_WIDTH(x) SetField(HDMI_TX_REG_VSYNC_2,"V_SYNC_WIDTH",x)
  `define GET_HDMI_TX_REG_VSYNC_2_V_SYNC_WIDTH(x) GetField(HDMI_TX_REG_VSYNC_2,"V_SYNC_WIDTH",x)
  `define DEFAULT_HDMI_TX_REG_VSYNC_2_V_SYNC_WIDTH GetResetValue(HDMI_TX_REG_VSYNC_2,"V_SYNC_WIDTH")
  `define UPDATE_HDMI_TX_REG_VSYNC_2_V_SYNC_WIDTH(x,y) UpdateField(HDMI_TX_REG_VSYNC_2,"V_SYNC_WIDTH",x,y)

  const reg_t HDMI_TX_REG_VSYNC_3 = '{ 'h0448, "REG_VSYNC_3" , '{
    "V_ENABLE_MAX": '{ 31, 16, RW, 'h0000 },
    "V_ENABLE_MIN": '{ 15, 0, RW, 'h0000 }}};
  `define SET_HDMI_TX_REG_VSYNC_3_V_ENABLE_MAX(x) SetField(HDMI_TX_REG_VSYNC_3,"V_ENABLE_MAX",x)
  `define GET_HDMI_TX_REG_VSYNC_3_V_ENABLE_MAX(x) GetField(HDMI_TX_REG_VSYNC_3,"V_ENABLE_MAX",x)
  `define DEFAULT_HDMI_TX_REG_VSYNC_3_V_ENABLE_MAX GetResetValue(HDMI_TX_REG_VSYNC_3,"V_ENABLE_MAX")
  `define UPDATE_HDMI_TX_REG_VSYNC_3_V_ENABLE_MAX(x,y) UpdateField(HDMI_TX_REG_VSYNC_3,"V_ENABLE_MAX",x,y)
  `define SET_HDMI_TX_REG_VSYNC_3_V_ENABLE_MIN(x) SetField(HDMI_TX_REG_VSYNC_3,"V_ENABLE_MIN",x)
  `define GET_HDMI_TX_REG_VSYNC_3_V_ENABLE_MIN(x) GetField(HDMI_TX_REG_VSYNC_3,"V_ENABLE_MIN",x)
  `define DEFAULT_HDMI_TX_REG_VSYNC_3_V_ENABLE_MIN GetResetValue(HDMI_TX_REG_VSYNC_3,"V_ENABLE_MIN")
  `define UPDATE_HDMI_TX_REG_VSYNC_3_V_ENABLE_MIN(x,y) UpdateField(HDMI_TX_REG_VSYNC_3,"V_ENABLE_MIN",x,y)


/* HDMI Receive (axi_hdmi_rx) */

  const reg_t hdmi_rx_REG_RSTN = '{ 'h0040, "REG_RSTN" , '{
    "RSTN": '{ 0, 0, RW, 'h0 }}};
  `define SET_hdmi_rx_REG_RSTN_RSTN(x) SetField(hdmi_rx_REG_RSTN,"RSTN",x)
  `define GET_hdmi_rx_REG_RSTN_RSTN(x) GetField(hdmi_rx_REG_RSTN,"RSTN",x)
  `define DEFAULT_hdmi_rx_REG_RSTN_RSTN GetResetValue(hdmi_rx_REG_RSTN,"RSTN")
  `define UPDATE_hdmi_rx_REG_RSTN_RSTN(x,y) UpdateField(hdmi_rx_REG_RSTN,"RSTN",x,y)

  const reg_t hdmi_rx_REG_CNTRL = '{ 'h0044, "REG_CNTRL" , '{
    "EDGE_SEL": '{ 3, 3, RW, 'h0 },
    "BGR": '{ 2, 2, RW, 'h0 },
    "PACKED": '{ 1, 1, RW, 'h0 },
    "CSC_BYPASS": '{ 0, 0, RW, 'h0 }}};
  `define SET_hdmi_rx_REG_CNTRL_EDGE_SEL(x) SetField(hdmi_rx_REG_CNTRL,"EDGE_SEL",x)
  `define GET_hdmi_rx_REG_CNTRL_EDGE_SEL(x) GetField(hdmi_rx_REG_CNTRL,"EDGE_SEL",x)
  `define DEFAULT_hdmi_rx_REG_CNTRL_EDGE_SEL GetResetValue(hdmi_rx_REG_CNTRL,"EDGE_SEL")
  `define UPDATE_hdmi_rx_REG_CNTRL_EDGE_SEL(x,y) UpdateField(hdmi_rx_REG_CNTRL,"EDGE_SEL",x,y)
  `define SET_hdmi_rx_REG_CNTRL_BGR(x) SetField(hdmi_rx_REG_CNTRL,"BGR",x)
  `define GET_hdmi_rx_REG_CNTRL_BGR(x) GetField(hdmi_rx_REG_CNTRL,"BGR",x)
  `define DEFAULT_hdmi_rx_REG_CNTRL_BGR GetResetValue(hdmi_rx_REG_CNTRL,"BGR")
  `define UPDATE_hdmi_rx_REG_CNTRL_BGR(x,y) UpdateField(hdmi_rx_REG_CNTRL,"BGR",x,y)
  `define SET_hdmi_rx_REG_CNTRL_PACKED(x) SetField(hdmi_rx_REG_CNTRL,"PACKED",x)
  `define GET_hdmi_rx_REG_CNTRL_PACKED(x) GetField(hdmi_rx_REG_CNTRL,"PACKED",x)
  `define DEFAULT_hdmi_rx_REG_CNTRL_PACKED GetResetValue(hdmi_rx_REG_CNTRL,"PACKED")
  `define UPDATE_hdmi_rx_REG_CNTRL_PACKED(x,y) UpdateField(hdmi_rx_REG_CNTRL,"PACKED",x,y)
  `define SET_hdmi_rx_REG_CNTRL_CSC_BYPASS(x) SetField(hdmi_rx_REG_CNTRL,"CSC_BYPASS",x)
  `define GET_hdmi_rx_REG_CNTRL_CSC_BYPASS(x) GetField(hdmi_rx_REG_CNTRL,"CSC_BYPASS",x)
  `define DEFAULT_hdmi_rx_REG_CNTRL_CSC_BYPASS GetResetValue(hdmi_rx_REG_CNTRL,"CSC_BYPASS")
  `define UPDATE_hdmi_rx_REG_CNTRL_CSC_BYPASS(x,y) UpdateField(hdmi_rx_REG_CNTRL,"CSC_BYPASS",x,y)

  const reg_t hdmi_rx_REG_CLK_FREQ = '{ 'h0054, "REG_CLK_FREQ" , '{
    "CLK_FREQ": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_hdmi_rx_REG_CLK_FREQ_CLK_FREQ(x) SetField(hdmi_rx_REG_CLK_FREQ,"CLK_FREQ",x)
  `define GET_hdmi_rx_REG_CLK_FREQ_CLK_FREQ(x) GetField(hdmi_rx_REG_CLK_FREQ,"CLK_FREQ",x)
  `define DEFAULT_hdmi_rx_REG_CLK_FREQ_CLK_FREQ GetResetValue(hdmi_rx_REG_CLK_FREQ,"CLK_FREQ")
  `define UPDATE_hdmi_rx_REG_CLK_FREQ_CLK_FREQ(x,y) UpdateField(hdmi_rx_REG_CLK_FREQ,"CLK_FREQ",x,y)

  const reg_t hdmi_rx_REG_CLK_RATIO = '{ 'h0058, "REG_CLK_RATIO" , '{
    "CLK_RATIO": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_hdmi_rx_REG_CLK_RATIO_CLK_RATIO(x) SetField(hdmi_rx_REG_CLK_RATIO,"CLK_RATIO",x)
  `define GET_hdmi_rx_REG_CLK_RATIO_CLK_RATIO(x) GetField(hdmi_rx_REG_CLK_RATIO,"CLK_RATIO",x)
  `define DEFAULT_hdmi_rx_REG_CLK_RATIO_CLK_RATIO GetResetValue(hdmi_rx_REG_CLK_RATIO,"CLK_RATIO")
  `define UPDATE_hdmi_rx_REG_CLK_RATIO_CLK_RATIO(x,y) UpdateField(hdmi_rx_REG_CLK_RATIO,"CLK_RATIO",x,y)

  const reg_t hdmi_rx_REG_VDMA_STATUS = '{ 'h0060, "REG_VDMA_STATUS" , '{
    "VDMA_OVF": '{ 1, 1, RW1C, 'h0 },
    "VDMA_UNF": '{ 0, 0, RW1C, 'h0 }}};
  `define SET_hdmi_rx_REG_VDMA_STATUS_VDMA_OVF(x) SetField(hdmi_rx_REG_VDMA_STATUS,"VDMA_OVF",x)
  `define GET_hdmi_rx_REG_VDMA_STATUS_VDMA_OVF(x) GetField(hdmi_rx_REG_VDMA_STATUS,"VDMA_OVF",x)
  `define DEFAULT_hdmi_rx_REG_VDMA_STATUS_VDMA_OVF GetResetValue(hdmi_rx_REG_VDMA_STATUS,"VDMA_OVF")
  `define UPDATE_hdmi_rx_REG_VDMA_STATUS_VDMA_OVF(x,y) UpdateField(hdmi_rx_REG_VDMA_STATUS,"VDMA_OVF",x,y)
  `define SET_hdmi_rx_REG_VDMA_STATUS_VDMA_UNF(x) SetField(hdmi_rx_REG_VDMA_STATUS,"VDMA_UNF",x)
  `define GET_hdmi_rx_REG_VDMA_STATUS_VDMA_UNF(x) GetField(hdmi_rx_REG_VDMA_STATUS,"VDMA_UNF",x)
  `define DEFAULT_hdmi_rx_REG_VDMA_STATUS_VDMA_UNF GetResetValue(hdmi_rx_REG_VDMA_STATUS,"VDMA_UNF")
  `define UPDATE_hdmi_rx_REG_VDMA_STATUS_VDMA_UNF(x,y) UpdateField(hdmi_rx_REG_VDMA_STATUS,"VDMA_UNF",x,y)

  const reg_t hdmi_rx_REG_TPM_STATUS1 = '{ 'h0064, "REG_TPM_STATUS1" , '{
    "HDMI_TPM_OOS": '{ 1, 1, RW1C, 'h0 }}};
  `define SET_hdmi_rx_REG_TPM_STATUS1_HDMI_TPM_OOS(x) SetField(hdmi_rx_REG_TPM_STATUS1,"HDMI_TPM_OOS",x)
  `define GET_hdmi_rx_REG_TPM_STATUS1_HDMI_TPM_OOS(x) GetField(hdmi_rx_REG_TPM_STATUS1,"HDMI_TPM_OOS",x)
  `define DEFAULT_hdmi_rx_REG_TPM_STATUS1_HDMI_TPM_OOS GetResetValue(hdmi_rx_REG_TPM_STATUS1,"HDMI_TPM_OOS")
  `define UPDATE_hdmi_rx_REG_TPM_STATUS1_HDMI_TPM_OOS(x,y) UpdateField(hdmi_rx_REG_TPM_STATUS1,"HDMI_TPM_OOS",x,y)

  const reg_t hdmi_rx_REG_TPM_STATUS2 = '{ 'h0080, "REG_TPM_STATUS2" , '{
    "VS_OOS": '{ 3, 3, RW1C, 'h0 },
    "HS_OOS": '{ 2, 2, RW1C, 'h0 },
    "VS_MISMATCH": '{ 1, 1, RW1C, 'h0 },
    "HS_MISMATCH": '{ 0, 0, RW1C, 'h0 }}};
  `define SET_hdmi_rx_REG_TPM_STATUS2_VS_OOS(x) SetField(hdmi_rx_REG_TPM_STATUS2,"VS_OOS",x)
  `define GET_hdmi_rx_REG_TPM_STATUS2_VS_OOS(x) GetField(hdmi_rx_REG_TPM_STATUS2,"VS_OOS",x)
  `define DEFAULT_hdmi_rx_REG_TPM_STATUS2_VS_OOS GetResetValue(hdmi_rx_REG_TPM_STATUS2,"VS_OOS")
  `define UPDATE_hdmi_rx_REG_TPM_STATUS2_VS_OOS(x,y) UpdateField(hdmi_rx_REG_TPM_STATUS2,"VS_OOS",x,y)
  `define SET_hdmi_rx_REG_TPM_STATUS2_HS_OOS(x) SetField(hdmi_rx_REG_TPM_STATUS2,"HS_OOS",x)
  `define GET_hdmi_rx_REG_TPM_STATUS2_HS_OOS(x) GetField(hdmi_rx_REG_TPM_STATUS2,"HS_OOS",x)
  `define DEFAULT_hdmi_rx_REG_TPM_STATUS2_HS_OOS GetResetValue(hdmi_rx_REG_TPM_STATUS2,"HS_OOS")
  `define UPDATE_hdmi_rx_REG_TPM_STATUS2_HS_OOS(x,y) UpdateField(hdmi_rx_REG_TPM_STATUS2,"HS_OOS",x,y)
  `define SET_hdmi_rx_REG_TPM_STATUS2_VS_MISMATCH(x) SetField(hdmi_rx_REG_TPM_STATUS2,"VS_MISMATCH",x)
  `define GET_hdmi_rx_REG_TPM_STATUS2_VS_MISMATCH(x) GetField(hdmi_rx_REG_TPM_STATUS2,"VS_MISMATCH",x)
  `define DEFAULT_hdmi_rx_REG_TPM_STATUS2_VS_MISMATCH GetResetValue(hdmi_rx_REG_TPM_STATUS2,"VS_MISMATCH")
  `define UPDATE_hdmi_rx_REG_TPM_STATUS2_VS_MISMATCH(x,y) UpdateField(hdmi_rx_REG_TPM_STATUS2,"VS_MISMATCH",x,y)
  `define SET_hdmi_rx_REG_TPM_STATUS2_HS_MISMATCH(x) SetField(hdmi_rx_REG_TPM_STATUS2,"HS_MISMATCH",x)
  `define GET_hdmi_rx_REG_TPM_STATUS2_HS_MISMATCH(x) GetField(hdmi_rx_REG_TPM_STATUS2,"HS_MISMATCH",x)
  `define DEFAULT_hdmi_rx_REG_TPM_STATUS2_HS_MISMATCH GetResetValue(hdmi_rx_REG_TPM_STATUS2,"HS_MISMATCH")
  `define UPDATE_hdmi_rx_REG_TPM_STATUS2_HS_MISMATCH(x,y) UpdateField(hdmi_rx_REG_TPM_STATUS2,"HS_MISMATCH",x,y)

  const reg_t hdmi_rx_REG_HVCOUNTS1 = '{ 'h0400, "REG_HVCOUNTS1" , '{
    "VS_COUNT": '{ 31, 16, RW, 'h0000 },
    "HS_COUNT": '{ 15, 0, RW, 'h0000 }}};
  `define SET_hdmi_rx_REG_HVCOUNTS1_VS_COUNT(x) SetField(hdmi_rx_REG_HVCOUNTS1,"VS_COUNT",x)
  `define GET_hdmi_rx_REG_HVCOUNTS1_VS_COUNT(x) GetField(hdmi_rx_REG_HVCOUNTS1,"VS_COUNT",x)
  `define DEFAULT_hdmi_rx_REG_HVCOUNTS1_VS_COUNT GetResetValue(hdmi_rx_REG_HVCOUNTS1,"VS_COUNT")
  `define UPDATE_hdmi_rx_REG_HVCOUNTS1_VS_COUNT(x,y) UpdateField(hdmi_rx_REG_HVCOUNTS1,"VS_COUNT",x,y)
  `define SET_hdmi_rx_REG_HVCOUNTS1_HS_COUNT(x) SetField(hdmi_rx_REG_HVCOUNTS1,"HS_COUNT",x)
  `define GET_hdmi_rx_REG_HVCOUNTS1_HS_COUNT(x) GetField(hdmi_rx_REG_HVCOUNTS1,"HS_COUNT",x)
  `define DEFAULT_hdmi_rx_REG_HVCOUNTS1_HS_COUNT GetResetValue(hdmi_rx_REG_HVCOUNTS1,"HS_COUNT")
  `define UPDATE_hdmi_rx_REG_HVCOUNTS1_HS_COUNT(x,y) UpdateField(hdmi_rx_REG_HVCOUNTS1,"HS_COUNT",x,y)

  const reg_t hdmi_rx_REG_HVCOUNTS2 = '{ 'h0404, "REG_HVCOUNTS2" , '{
    "VS_COUNT": '{ 31, 16, RO, 'h0000 },
    "HS_COUNT": '{ 15, 0, RO, 'h0000 }}};
  `define SET_hdmi_rx_REG_HVCOUNTS2_VS_COUNT(x) SetField(hdmi_rx_REG_HVCOUNTS2,"VS_COUNT",x)
  `define GET_hdmi_rx_REG_HVCOUNTS2_VS_COUNT(x) GetField(hdmi_rx_REG_HVCOUNTS2,"VS_COUNT",x)
  `define DEFAULT_hdmi_rx_REG_HVCOUNTS2_VS_COUNT GetResetValue(hdmi_rx_REG_HVCOUNTS2,"VS_COUNT")
  `define UPDATE_hdmi_rx_REG_HVCOUNTS2_VS_COUNT(x,y) UpdateField(hdmi_rx_REG_HVCOUNTS2,"VS_COUNT",x,y)
  `define SET_hdmi_rx_REG_HVCOUNTS2_HS_COUNT(x) SetField(hdmi_rx_REG_HVCOUNTS2,"HS_COUNT",x)
  `define GET_hdmi_rx_REG_HVCOUNTS2_HS_COUNT(x) GetField(hdmi_rx_REG_HVCOUNTS2,"HS_COUNT",x)
  `define DEFAULT_hdmi_rx_REG_HVCOUNTS2_HS_COUNT GetResetValue(hdmi_rx_REG_HVCOUNTS2,"HS_COUNT")
  `define UPDATE_hdmi_rx_REG_HVCOUNTS2_HS_COUNT(x,y) UpdateField(hdmi_rx_REG_HVCOUNTS2,"HS_COUNT",x,y)


endpackage
