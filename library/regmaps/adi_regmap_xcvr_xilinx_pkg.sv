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

package adi_regmap_xcvr_xilinx_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_xcvr_xilinx extends adi_regmap;

    /* Xilinx XCVR (axi_xcvr) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_F = new("VERSION", 31, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VERSION_CLASS

    class ID_CLASS extends register_base;
      field_base ID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ID_F = new("ID", 31, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ID_CLASS

    class SCRATCH_CLASS extends register_base;
      field_base SCRATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SCRATCH_CLASS

    class RESETN_CLASS extends register_base;
      field_base BUFSTATUS_RST_F;
      field_base RESETN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.BUFSTATUS_RST_F = new("BUFSTATUS_RST", 1, 1, RW, 'hXXXXXXXX, this);
        this.RESETN_F = new("RESETN", 0, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: RESETN_CLASS

    class STATUS_CLASS extends register_base;
      field_base BUFSTATUS_F;
      field_base PLL_LOCK_N_F;
      field_base STATUS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.BUFSTATUS_F = new("BUFSTATUS", 6, 5, RO, 'hXXXXXXXX, this);
        this.PLL_LOCK_N_F = new("PLL_LOCK_N", 4, 4, RO, 'hXXXXXXXX, this);
        this.STATUS_F = new("STATUS", 0, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: STATUS_CLASS

    class FPGA_INFO_CLASS extends register_base;
      field_base FPGA_TECHNOLOGY_F;
      field_base FPGA_FAMILY_F;
      field_base SPEED_GRADE_F;
      field_base DEV_PACKAGE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FPGA_TECHNOLOGY_F = new("FPGA_TECHNOLOGY", 31, 24, RO, 'hXXXXXXXX, this);
        this.FPGA_FAMILY_F = new("FPGA_FAMILY", 23, 16, RO, 'hXXXXXXXX, this);
        this.SPEED_GRADE_F = new("SPEED_GRADE", 15, 8, RO, 'hXXXXXXXX, this);
        this.DEV_PACKAGE_F = new("DEV_PACKAGE", 7, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FPGA_INFO_CLASS

    class CONTROL_CLASS extends register_base;
      field_base LPM_DFE_N_F;
      field_base RATE_F;
      field_base SYSCLK_SEL_F;
      field_base OUTCLK_SEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.LPM_DFE_N_F = new("LPM_DFE_N", 12, 12, RW, 'hXXXXXXXX, this);
        this.RATE_F = new("RATE", 10, 8, RW, 'hXXXXXXXX, this);
        this.SYSCLK_SEL_F = new("SYSCLK_SEL", 5, 4, RW, 'hXXXXXXXX, this);
        this.OUTCLK_SEL_F = new("OUTCLK_SEL", 2, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CONTROL_CLASS

    class GENERIC_INFO_CLASS extends register_base;
      field_base QPLL_ENABLE_F;
      field_base XCVR_TYPE_F;
      field_base LINK_MODE_F;
      field_base TX_OR_RX_N_F;
      field_base NUM_OF_LANES_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.QPLL_ENABLE_F = new("QPLL_ENABLE", 20, 20, RO, 'hXXXXXXXX, this);
        this.XCVR_TYPE_F = new("XCVR_TYPE", 19, 16, RO, 'hXXXXXXXX, this);
        this.LINK_MODE_F = new("LINK_MODE", 13, 12, RO, 'hXXXXXXXX, this);
        this.TX_OR_RX_N_F = new("TX_OR_RX_N", 8, 8, RO, 'hXXXXXXXX, this);
        this.NUM_OF_LANES_F = new("NUM_OF_LANES", 7, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: GENERIC_INFO_CLASS

    class CM_SEL_CLASS extends register_base;
      field_base CM_SEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CM_SEL_F = new("CM_SEL", 7, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CM_SEL_CLASS

    class CM_CONTROL_CLASS extends register_base;
      field_base CM_WR_F;
      field_base CM_ADDR_F;
      field_base CM_WDATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CM_WR_F = new("CM_WR", 28, 28, RW, 'hXXXXXXXX, this);
        this.CM_ADDR_F = new("CM_ADDR", 27, 16, RW, 'hXXXXXXXX, this);
        this.CM_WDATA_F = new("CM_WDATA", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CM_CONTROL_CLASS

    class CM_STATUS_CLASS extends register_base;
      field_base CM_BUSY_F;
      field_base CM_RDATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CM_BUSY_F = new("CM_BUSY", 16, 16, RO, 'hXXXXXXXX, this);
        this.CM_RDATA_F = new("CM_RDATA", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CM_STATUS_CLASS

    class CH_SEL_CLASS extends register_base;
      field_base CH_SEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CH_SEL_F = new("CH_SEL", 7, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CH_SEL_CLASS

    class CH_CONTROL_CLASS extends register_base;
      field_base CH_WR_F;
      field_base CH_ADDR_F;
      field_base CH_WDATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CH_WR_F = new("CH_WR", 28, 28, RW, 'hXXXXXXXX, this);
        this.CH_ADDR_F = new("CH_ADDR", 27, 16, RW, 'hXXXXXXXX, this);
        this.CH_WDATA_F = new("CH_WDATA", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CH_CONTROL_CLASS

    class CH_STATUS_CLASS extends register_base;
      field_base CH_BUSY_F;
      field_base CH_RDATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CH_BUSY_F = new("CH_BUSY", 16, 16, RO, 'hXXXXXXXX, this);
        this.CH_RDATA_F = new("CH_RDATA", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CH_STATUS_CLASS

    class ES_SEL_CLASS extends register_base;
      field_base ES_SEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ES_SEL_F = new("ES_SEL", 7, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ES_SEL_CLASS

    class ES_REQ_CLASS extends register_base;
      field_base ES_REQ_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ES_REQ_F = new("ES_REQ", 0, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ES_REQ_CLASS

    class ES_CONTROL_1_CLASS extends register_base;
      field_base ES_PRESCALE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ES_PRESCALE_F = new("ES_PRESCALE", 4, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ES_CONTROL_1_CLASS

    class ES_CONTROL_2_CLASS extends register_base;
      field_base ES_VOFFSET_RANGE_F;
      field_base ES_VOFFSET_STEP_F;
      field_base ES_VOFFSET_MAX_F;
      field_base ES_VOFFSET_MIN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ES_VOFFSET_RANGE_F = new("ES_VOFFSET_RANGE", 25, 24, RW, 'hXXXXXXXX, this);
        this.ES_VOFFSET_STEP_F = new("ES_VOFFSET_STEP", 23, 16, RW, 'hXXXXXXXX, this);
        this.ES_VOFFSET_MAX_F = new("ES_VOFFSET_MAX", 15, 8, RW, 'hXXXXXXXX, this);
        this.ES_VOFFSET_MIN_F = new("ES_VOFFSET_MIN", 7, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ES_CONTROL_2_CLASS

    class ES_CONTROL_3_CLASS extends register_base;
      field_base ES_HOFFSET_MAX_F;
      field_base ES_HOFFSET_MIN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ES_HOFFSET_MAX_F = new("ES_HOFFSET_MAX", 27, 16, RW, 'hXXXXXXXX, this);
        this.ES_HOFFSET_MIN_F = new("ES_HOFFSET_MIN", 11, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ES_CONTROL_3_CLASS

    class ES_CONTROL_4_CLASS extends register_base;
      field_base ES_HOFFSET_STEP_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ES_HOFFSET_STEP_F = new("ES_HOFFSET_STEP", 11, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ES_CONTROL_4_CLASS

    class ES_CONTROL_5_CLASS extends register_base;
      field_base ES_STARTADDR_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ES_STARTADDR_F = new("ES_STARTADDR", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ES_CONTROL_5_CLASS

    class ES_STATUS_CLASS extends register_base;
      field_base ES_STATUS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ES_STATUS_F = new("ES_STATUS", 0, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ES_STATUS_CLASS

    class ES_RESET_CLASS extends register_base;
      field_base ES_RESET0_F;
      field_base ES_RESET1_F;
      field_base ES_RESET2_F;
      field_base ES_RESET3_F;
      field_base ES_RESET4_F;
      field_base ES_RESET5_F;
      field_base ES_RESET6_F;
      field_base ES_RESET7_F;
      field_base ES_RESET8_F;
      field_base ES_RESET9_F;
      field_base ES_RESET10_F;
      field_base ES_RESET11_F;
      field_base ES_RESET12_F;
      field_base ES_RESET13_F;
      field_base ES_RESET14_F;
      field_base ES_RESET15_F;
      field_base ES_RESET16_F;
      field_base ES_RESET17_F;
      field_base ES_RESET18_F;
      field_base ES_RESET19_F;
      field_base ES_RESET20_F;
      field_base ES_RESET21_F;
      field_base ES_RESET22_F;
      field_base ES_RESET23_F;
      field_base ES_RESET24_F;
      field_base ES_RESET25_F;
      field_base ES_RESET26_F;
      field_base ES_RESET27_F;
      field_base ES_RESET28_F;
      field_base ES_RESET29_F;
      field_base ES_RESET30_F;
      field_base ES_RESET31_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ES_RESET0_F = new("ES_RESET0", 0, 0, RW, 'hXXXXXXXX, this);
        this.ES_RESET1_F = new("ES_RESET1", 1, 1, RW, 'hXXXXXXXX, this);
        this.ES_RESET2_F = new("ES_RESET2", 2, 2, RW, 'hXXXXXXXX, this);
        this.ES_RESET3_F = new("ES_RESET3", 3, 3, RW, 'hXXXXXXXX, this);
        this.ES_RESET4_F = new("ES_RESET4", 4, 4, RW, 'hXXXXXXXX, this);
        this.ES_RESET5_F = new("ES_RESET5", 5, 5, RW, 'hXXXXXXXX, this);
        this.ES_RESET6_F = new("ES_RESET6", 6, 6, RW, 'hXXXXXXXX, this);
        this.ES_RESET7_F = new("ES_RESET7", 7, 7, RW, 'hXXXXXXXX, this);
        this.ES_RESET8_F = new("ES_RESET8", 8, 8, RW, 'hXXXXXXXX, this);
        this.ES_RESET9_F = new("ES_RESET9", 9, 9, RW, 'hXXXXXXXX, this);
        this.ES_RESET10_F = new("ES_RESET10", 10, 10, RW, 'hXXXXXXXX, this);
        this.ES_RESET11_F = new("ES_RESET11", 11, 11, RW, 'hXXXXXXXX, this);
        this.ES_RESET12_F = new("ES_RESET12", 12, 12, RW, 'hXXXXXXXX, this);
        this.ES_RESET13_F = new("ES_RESET13", 13, 13, RW, 'hXXXXXXXX, this);
        this.ES_RESET14_F = new("ES_RESET14", 14, 14, RW, 'hXXXXXXXX, this);
        this.ES_RESET15_F = new("ES_RESET15", 15, 15, RW, 'hXXXXXXXX, this);
        this.ES_RESET16_F = new("ES_RESET16", 16, 16, RW, 'hXXXXXXXX, this);
        this.ES_RESET17_F = new("ES_RESET17", 17, 17, RW, 'hXXXXXXXX, this);
        this.ES_RESET18_F = new("ES_RESET18", 18, 18, RW, 'hXXXXXXXX, this);
        this.ES_RESET19_F = new("ES_RESET19", 19, 19, RW, 'hXXXXXXXX, this);
        this.ES_RESET20_F = new("ES_RESET20", 20, 20, RW, 'hXXXXXXXX, this);
        this.ES_RESET21_F = new("ES_RESET21", 21, 21, RW, 'hXXXXXXXX, this);
        this.ES_RESET22_F = new("ES_RESET22", 22, 22, RW, 'hXXXXXXXX, this);
        this.ES_RESET23_F = new("ES_RESET23", 23, 23, RW, 'hXXXXXXXX, this);
        this.ES_RESET24_F = new("ES_RESET24", 24, 24, RW, 'hXXXXXXXX, this);
        this.ES_RESET25_F = new("ES_RESET25", 25, 25, RW, 'hXXXXXXXX, this);
        this.ES_RESET26_F = new("ES_RESET26", 26, 26, RW, 'hXXXXXXXX, this);
        this.ES_RESET27_F = new("ES_RESET27", 27, 27, RW, 'hXXXXXXXX, this);
        this.ES_RESET28_F = new("ES_RESET28", 28, 28, RW, 'hXXXXXXXX, this);
        this.ES_RESET29_F = new("ES_RESET29", 29, 29, RW, 'hXXXXXXXX, this);
        this.ES_RESET30_F = new("ES_RESET30", 30, 30, RW, 'hXXXXXXXX, this);
        this.ES_RESET31_F = new("ES_RESET31", 31, 31, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ES_RESET_CLASS

    class TX_DIFFCTRL_CLASS extends register_base;
      field_base TX_DIFFCTRL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TX_DIFFCTRL_F = new("TX_DIFFCTRL", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TX_DIFFCTRL_CLASS

    class TX_POSTCURSOR_CLASS extends register_base;
      field_base TX_POSTCURSOR_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TX_POSTCURSOR_F = new("TX_POSTCURSOR", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TX_POSTCURSOR_CLASS

    class TX_PRECURSOR_CLASS extends register_base;
      field_base TX_PRECURSOR_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TX_PRECURSOR_F = new("TX_PRECURSOR", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TX_PRECURSOR_CLASS

    class FPGA_VOLTAGE_CLASS extends register_base;
      field_base FPGA_VOLTAGE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FPGA_VOLTAGE_F = new("FPGA_VOLTAGE", 15, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FPGA_VOLTAGE_CLASS

    class PRBS_CNTRL_CLASS extends register_base;
      field_base PRBSFORCEERR_F;
      field_base PRBSCNTRESET_F;
      field_base PRBSSEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PRBSFORCEERR_F = new("PRBSFORCEERR", 16, 16, RW, 'hXXXXXXXX, this);
        this.PRBSCNTRESET_F = new("PRBSCNTRESET", 8, 8, RW, 'hXXXXXXXX, this);
        this.PRBSSEL_F = new("PRBSSEL", 3, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PRBS_CNTRL_CLASS

    class PRBS_STATUS_CLASS extends register_base;
      field_base PRBSERR_F;
      field_base PRBSLOCKED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PRBSERR_F = new("PRBSERR", 8, 8, RO, 'hXXXXXXXX, this);
        this.PRBSLOCKED_F = new("PRBSLOCKED", 0, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PRBS_STATUS_CLASS

    VERSION_CLASS VERSION_R;
    ID_CLASS ID_R;
    SCRATCH_CLASS SCRATCH_R;
    RESETN_CLASS RESETN_R;
    STATUS_CLASS STATUS_R;
    FPGA_INFO_CLASS FPGA_INFO_R;
    CONTROL_CLASS CONTROL_R;
    GENERIC_INFO_CLASS GENERIC_INFO_R;
    CM_SEL_CLASS CM_SEL_R;
    CM_CONTROL_CLASS CM_CONTROL_R;
    CM_STATUS_CLASS CM_STATUS_R;
    CH_SEL_CLASS CH_SEL_R;
    CH_CONTROL_CLASS CH_CONTROL_R;
    CH_STATUS_CLASS CH_STATUS_R;
    ES_SEL_CLASS ES_SEL_R;
    ES_REQ_CLASS ES_REQ_R;
    ES_CONTROL_1_CLASS ES_CONTROL_1_R;
    ES_CONTROL_2_CLASS ES_CONTROL_2_R;
    ES_CONTROL_3_CLASS ES_CONTROL_3_R;
    ES_CONTROL_4_CLASS ES_CONTROL_4_R;
    ES_CONTROL_5_CLASS ES_CONTROL_5_R;
    ES_STATUS_CLASS ES_STATUS_R;
    ES_RESET_CLASS ES_RESET_R;
    TX_DIFFCTRL_CLASS TX_DIFFCTRL_R;
    TX_POSTCURSOR_CLASS TX_POSTCURSOR_R;
    TX_PRECURSOR_CLASS TX_PRECURSOR_R;
    FPGA_VOLTAGE_CLASS FPGA_VOLTAGE_R;
    PRBS_CNTRL_CLASS PRBS_CNTRL_R;
    PRBS_STATUS_CLASS PRBS_STATUS_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.ID_R = new("ID", 'h4, this);
      this.SCRATCH_R = new("SCRATCH", 'h8, this);
      this.RESETN_R = new("RESETN", 'h10, this);
      this.STATUS_R = new("STATUS", 'h14, this);
      this.FPGA_INFO_R = new("FPGA_INFO", 'h1c, this);
      this.CONTROL_R = new("CONTROL", 'h20, this);
      this.GENERIC_INFO_R = new("GENERIC_INFO", 'h24, this);
      this.CM_SEL_R = new("CM_SEL", 'h40, this);
      this.CM_CONTROL_R = new("CM_CONTROL", 'h44, this);
      this.CM_STATUS_R = new("CM_STATUS", 'h48, this);
      this.CH_SEL_R = new("CH_SEL", 'h60, this);
      this.CH_CONTROL_R = new("CH_CONTROL", 'h64, this);
      this.CH_STATUS_R = new("CH_STATUS", 'h68, this);
      this.ES_SEL_R = new("ES_SEL", 'h80, this);
      this.ES_REQ_R = new("ES_REQ", 'ha0, this);
      this.ES_CONTROL_1_R = new("ES_CONTROL_1", 'ha4, this);
      this.ES_CONTROL_2_R = new("ES_CONTROL_2", 'ha8, this);
      this.ES_CONTROL_3_R = new("ES_CONTROL_3", 'hac, this);
      this.ES_CONTROL_4_R = new("ES_CONTROL_4", 'hb0, this);
      this.ES_CONTROL_5_R = new("ES_CONTROL_5", 'hb4, this);
      this.ES_STATUS_R = new("ES_STATUS", 'hb8, this);
      this.ES_RESET_R = new("ES_RESET", 'hbc, this);
      this.TX_DIFFCTRL_R = new("TX_DIFFCTRL", 'hc0, this);
      this.TX_POSTCURSOR_R = new("TX_POSTCURSOR", 'hc4, this);
      this.TX_PRECURSOR_R = new("TX_PRECURSOR", 'hc8, this);
      this.FPGA_VOLTAGE_R = new("FPGA_VOLTAGE", 'h140, this);
      this.PRBS_CNTRL_R = new("PRBS_CNTRL", 'h180, this);
      this.PRBS_STATUS_R = new("PRBS_STATUS", 'h184, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_xcvr_xilinx

endpackage: adi_regmap_xcvr_xilinx_pkg
