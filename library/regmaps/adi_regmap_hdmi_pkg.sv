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

package adi_regmap_hdmi_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_hdmi extends adi_regmap;

    /* HDMI Transmit (axi_hdmi_tx) */
    class RSTN_TX_CLASS extends register_base;
      field_base RSTN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.RSTN_F = new("RSTN", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: RSTN_TX_CLASS

    class CNTRL1_CLASS extends register_base;
      field_base SS_BYPASS_F;
      field_base CSC_BYPASS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SS_BYPASS_F = new("SS_BYPASS", 2, 2, RW, 'h0, this);
        this.CSC_BYPASS_F = new("CSC_BYPASS", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CNTRL1_CLASS

    class CNTRL2_CLASS extends register_base;
      field_base SOURCE_SEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SOURCE_SEL_F = new("SOURCE_SEL", 1, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CNTRL2_CLASS

    class CNTRL3_CLASS extends register_base;
      field_base CONST_RGB_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CONST_RGB_F = new("CONST_RGB", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CNTRL3_CLASS

    class CLK_FREQ_TX_CLASS extends register_base;
      field_base CLK_FREQ_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CLK_FREQ_F = new("CLK_FREQ", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CLK_FREQ_TX_CLASS

    class CLK_RATIO_TX_CLASS extends register_base;
      field_base CLK_RATIO_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CLK_RATIO_F = new("CLK_RATIO", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CLK_RATIO_TX_CLASS

    class STATUS_CLASS extends register_base;
      field_base STATUS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.STATUS_F = new("STATUS", 0, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: STATUS_CLASS

    class VDMA_STATUS_TX_CLASS extends register_base;
      field_base VDMA_OVF_F;
      field_base VDMA_UNF_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VDMA_OVF_F = new("VDMA_OVF", 1, 1, RW1C, 'h0, this);
        this.VDMA_UNF_F = new("VDMA_UNF", 0, 0, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VDMA_STATUS_TX_CLASS

    class TPM_STATUS_CLASS extends register_base;
      field_base HDMI_TPM_OOS_F;
      field_base VDMA_TPM_OOS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.HDMI_TPM_OOS_F = new("HDMI_TPM_OOS", 1, 1, RW1C, 'h0, this);
        this.VDMA_TPM_OOS_F = new("VDMA_TPM_OOS", 0, 0, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TPM_STATUS_CLASS

    class CLIPP_MAX_CLASS extends register_base;
      field_base R_MAXorCR_MAX_F;
      field_base G_MAXorY_MAX_F;
      field_base B_MAXorCB_MAX_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.R_MAXorCR_MAX_F = new("R_MAXorCR_MAX", 23, 16, RW, 'hf0, this);
        this.G_MAXorY_MAX_F = new("G_MAXorY_MAX", 16, 8, RW, 'heb, this);
        this.B_MAXorCB_MAX_F = new("B_MAXorCB_MAX", 7, 0, RW, 'hf0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CLIPP_MAX_CLASS

    class CLIPP_MIN_CLASS extends register_base;
      field_base R_MINorCR_MIN_F;
      field_base G_MINorY_MIN_F;
      field_base B_MINorCB_MIN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.R_MINorCR_MIN_F = new("R_MINorCR_MIN", 23, 16, RW, 'h10, this);
        this.G_MINorY_MIN_F = new("G_MINorY_MIN", 16, 8, RW, 'h10, this);
        this.B_MINorCB_MIN_F = new("B_MINorCB_MIN", 7, 0, RW, 'h10, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CLIPP_MIN_CLASS

    class HSYNC_1_CLASS extends register_base;
      field_base H_LINE_ACTIVE_F;
      field_base H_LINE_WIDTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.H_LINE_ACTIVE_F = new("H_LINE_ACTIVE", 31, 16, RW, 'h0, this);
        this.H_LINE_WIDTH_F = new("H_LINE_WIDTH", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: HSYNC_1_CLASS

    class HSYNC_2_CLASS extends register_base;
      field_base H_SYNC_WIDTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.H_SYNC_WIDTH_F = new("H_SYNC_WIDTH", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: HSYNC_2_CLASS

    class HSYNC_3_CLASS extends register_base;
      field_base H_ENABLE_MAX_F;
      field_base H_ENABLE_MIN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.H_ENABLE_MAX_F = new("H_ENABLE_MAX", 31, 16, RW, 'h0, this);
        this.H_ENABLE_MIN_F = new("H_ENABLE_MIN", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: HSYNC_3_CLASS

    class VSYNC_1_CLASS extends register_base;
      field_base V_FRAME_ACTIVE_F;
      field_base V_FRAME_WIDTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.V_FRAME_ACTIVE_F = new("V_FRAME_ACTIVE", 31, 16, RW, 'h0, this);
        this.V_FRAME_WIDTH_F = new("V_FRAME_WIDTH", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VSYNC_1_CLASS

    class VSYNC_2_CLASS extends register_base;
      field_base V_SYNC_WIDTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.V_SYNC_WIDTH_F = new("V_SYNC_WIDTH", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VSYNC_2_CLASS

    class VSYNC_3_CLASS extends register_base;
      field_base V_ENABLE_MAX_F;
      field_base V_ENABLE_MIN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.V_ENABLE_MAX_F = new("V_ENABLE_MAX", 31, 16, RW, 'h0, this);
        this.V_ENABLE_MIN_F = new("V_ENABLE_MIN", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VSYNC_3_CLASS

    /* HDMI Receive (axi_hdmi_rx) */
    class RSTN_RX_CLASS extends register_base;
      field_base RSTN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.RSTN_F = new("RSTN", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: RSTN_RX_CLASS

    class CNTRL_CLASS extends register_base;
      field_base EDGE_SEL_F;
      field_base BGR_F;
      field_base PACKED_F;
      field_base CSC_BYPASS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.EDGE_SEL_F = new("EDGE_SEL", 3, 3, RW, 'h0, this);
        this.BGR_F = new("BGR", 2, 2, RW, 'h0, this);
        this.PACKED_F = new("PACKED", 1, 1, RW, 'h0, this);
        this.CSC_BYPASS_F = new("CSC_BYPASS", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CNTRL_CLASS

    class CLK_FREQ_RX_CLASS extends register_base;
      field_base CLK_FREQ_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CLK_FREQ_F = new("CLK_FREQ", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CLK_FREQ_RX_CLASS

    class CLK_RATIO_RX_CLASS extends register_base;
      field_base CLK_RATIO_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CLK_RATIO_F = new("CLK_RATIO", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CLK_RATIO_RX_CLASS

    class VDMA_STATUS_RX_CLASS extends register_base;
      field_base VDMA_OVF_F;
      field_base VDMA_UNF_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VDMA_OVF_F = new("VDMA_OVF", 1, 1, RW1C, 'h0, this);
        this.VDMA_UNF_F = new("VDMA_UNF", 0, 0, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VDMA_STATUS_RX_CLASS

    class TPM_STATUS1_CLASS extends register_base;
      field_base HDMI_TPM_OOS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.HDMI_TPM_OOS_F = new("HDMI_TPM_OOS", 1, 1, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TPM_STATUS1_CLASS

    class TPM_STATUS2_CLASS extends register_base;
      field_base VS_OOS_F;
      field_base HS_OOS_F;
      field_base VS_MISMATCH_F;
      field_base HS_MISMATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VS_OOS_F = new("VS_OOS", 3, 3, RW1C, 'h0, this);
        this.HS_OOS_F = new("HS_OOS", 2, 2, RW1C, 'h0, this);
        this.VS_MISMATCH_F = new("VS_MISMATCH", 1, 1, RW1C, 'h0, this);
        this.HS_MISMATCH_F = new("HS_MISMATCH", 0, 0, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TPM_STATUS2_CLASS

    class HVCOUNTS1_CLASS extends register_base;
      field_base VS_COUNT_F;
      field_base HS_COUNT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VS_COUNT_F = new("VS_COUNT", 31, 16, RW, 'h0, this);
        this.HS_COUNT_F = new("HS_COUNT", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: HVCOUNTS1_CLASS

    class HVCOUNTS2_CLASS extends register_base;
      field_base VS_COUNT_F;
      field_base HS_COUNT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VS_COUNT_F = new("VS_COUNT", 31, 16, RO, 'h0, this);
        this.HS_COUNT_F = new("HS_COUNT", 15, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: HVCOUNTS2_CLASS

    RSTN_TX_CLASS RSTN_TX_R;
    CNTRL1_CLASS CNTRL1_R;
    CNTRL2_CLASS CNTRL2_R;
    CNTRL3_CLASS CNTRL3_R;
    CLK_FREQ_TX_CLASS CLK_FREQ_TX_R;
    CLK_RATIO_TX_CLASS CLK_RATIO_TX_R;
    STATUS_CLASS STATUS_R;
    VDMA_STATUS_TX_CLASS VDMA_STATUS_TX_R;
    TPM_STATUS_CLASS TPM_STATUS_R;
    CLIPP_MAX_CLASS CLIPP_MAX_R;
    CLIPP_MIN_CLASS CLIPP_MIN_R;
    HSYNC_1_CLASS HSYNC_1_R;
    HSYNC_2_CLASS HSYNC_2_R;
    HSYNC_3_CLASS HSYNC_3_R;
    VSYNC_1_CLASS VSYNC_1_R;
    VSYNC_2_CLASS VSYNC_2_R;
    VSYNC_3_CLASS VSYNC_3_R;
    RSTN_RX_CLASS RSTN_RX_R;
    CNTRL_CLASS CNTRL_R;
    CLK_FREQ_RX_CLASS CLK_FREQ_RX_R;
    CLK_RATIO_RX_CLASS CLK_RATIO_RX_R;
    VDMA_STATUS_RX_CLASS VDMA_STATUS_RX_R;
    TPM_STATUS1_CLASS TPM_STATUS1_R;
    TPM_STATUS2_CLASS TPM_STATUS2_R;
    HVCOUNTS1_CLASS HVCOUNTS1_R;
    HVCOUNTS2_CLASS HVCOUNTS2_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.RSTN_TX_R = new("RSTN_TX", 'h40, this);
      this.CNTRL1_R = new("CNTRL1", 'h44, this);
      this.CNTRL2_R = new("CNTRL2", 'h48, this);
      this.CNTRL3_R = new("CNTRL3", 'h4c, this);
      this.CLK_FREQ_TX_R = new("CLK_FREQ_TX", 'h54, this);
      this.CLK_RATIO_TX_R = new("CLK_RATIO_TX", 'h58, this);
      this.STATUS_R = new("STATUS", 'h5c, this);
      this.VDMA_STATUS_TX_R = new("VDMA_STATUS_TX", 'h60, this);
      this.TPM_STATUS_R = new("TPM_STATUS", 'h64, this);
      this.CLIPP_MAX_R = new("CLIPP_MAX", 'h68, this);
      this.CLIPP_MIN_R = new("CLIPP_MIN", 'h6c, this);
      this.HSYNC_1_R = new("HSYNC_1", 'h400, this);
      this.HSYNC_2_R = new("HSYNC_2", 'h404, this);
      this.HSYNC_3_R = new("HSYNC_3", 'h408, this);
      this.VSYNC_1_R = new("VSYNC_1", 'h440, this);
      this.VSYNC_2_R = new("VSYNC_2", 'h444, this);
      this.VSYNC_3_R = new("VSYNC_3", 'h448, this);
      this.RSTN_RX_R = new("RSTN_RX", 'h40, this);
      this.CNTRL_R = new("CNTRL", 'h44, this);
      this.CLK_FREQ_RX_R = new("CLK_FREQ_RX", 'h54, this);
      this.CLK_RATIO_RX_R = new("CLK_RATIO_RX", 'h58, this);
      this.VDMA_STATUS_RX_R = new("VDMA_STATUS_RX", 'h60, this);
      this.TPM_STATUS1_R = new("TPM_STATUS1", 'h64, this);
      this.TPM_STATUS2_R = new("TPM_STATUS2", 'h80, this);
      this.HVCOUNTS1_R = new("HVCOUNTS1", 'h400, this);
      this.HVCOUNTS2_R = new("HVCOUNTS2", 'h404, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_hdmi

endpackage: adi_regmap_hdmi_pkg
