// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2025 Analog Devices, Inc. All rights reserved.
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
//      <https://www.gnu.org/licenses/old-licenses/gpl_2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on_line at:
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

package adi_xcvr_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import adi_api_pkg::*;
  import m_axi_sequencer_pkg::*;
  import adi_regmap_pkg::*;
  import adi_regmap_xcvr_pkg::*;

  typedef enum bit [2:0] {
    OUTCLKPCS = 1,
    OUTCLKPMA = 2,
    PLLREFCLK_DIV1 = 3,
    PLLREFCLK_DIV2 = 4,
    PROGDIVCLK = 5
  } out_clk_sel_t;

  typedef enum bit [1:0] {
    CPLL = 0,
    QPLL0 = 3,
    QPLL1 = 2
  } pll_type_t;

  typedef enum bit [3:0] {
        Unknown = 0,
        GTPE2_NOT_SUPPORTED = 1,
        GTXE2 = 2,
        GTHE2_NOT_SUPPORTED = 3,
        GTZE2_NOT_SUPPORTED = 4,
        GTHE3 = 5,
        GTYE3_NOT_SUPPORTED = 6,
        GTRE4_NOT_SUPPORTED = 7,
        GTHE4 = 8,
        GTYE4 = 9,
        GTME4_NOT_SUPPORTED = 10
  } xcvr_type_t;

  //============================================================================
  // Xilinx XCVR parameters base class
  //============================================================================
  class xcvr_params;

    // -----------------
    //
    // -----------------
    function int cpll_fbdiv_drp(int val);
      case (val)
        1: return 16;
        2: return 0;
        3: return 1;
        4: return 2;
        5: return 3;
        default: `FATAL(("CPLL FBDIV value not supported"));
      endcase
      return 0;
    endfunction : cpll_fbdiv_drp

    // -----------------
    //
    // -----------------
    function int cpll_fbdiv_45_drp(int val);
      case (val)
        4: return 0;
        5: return 1;
        default: `FATAL(("CPLL FBDIV_45 value not supported"));
      endcase
      return 0;
    endfunction : cpll_fbdiv_45_drp

    // -----------------
    //
    // -----------------
    function int cpll_refclk_div_drp(int val);
      case (val)
        1: return 16;
        2: return 0;
        default: `FATAL(("CPLL REFCLKDIV value not supported"));
      endcase
      return 0;
    endfunction : cpll_refclk_div_drp

    // -----------------
    //
    // -----------------
    function int out_div_drp(int val);
      case (val)
        1: return 0;
        2: return 1;
        4: return 2;
        8: return 3;
        16: return 4;
        default: `FATAL(("OUTDIV value not supported"));
      endcase
      return 0;
    endfunction : out_div_drp


    const bit [15:0] prog_div_drp[int];

    // -----------------
    //
    // -----------------
    function int qpll_refclk_div_drp(int val);
      case (val)
        1: return 16;
        2: return 0;
        3: return 1;
        4: return 2;
        default: `FATAL(("QPLL REFCLKDIV value not supported"));
      endcase
      return 0;
    endfunction : qpll_refclk_div_drp


    //const int qpll_fbdiv [];
    const int qpll_fbdiv_drp [int];

    const longint unsigned cpll_vco_min;
    const longint unsigned cpll_vco_max;

    // -----------------
    //
    // -----------------
    function int cpll_check_vco_range(longint unsigned cpll_vco);
      if (cpll_vco < cpll_vco_min || cpll_vco > cpll_vco_max)
        return 1;
      else
        return 0;
    endfunction

    // -----------------
    //
    // -----------------
    virtual function int qpll_check_vco_range(longint unsigned qpll_vco, int is_qpll1=0);
    endfunction

  endclass : xcvr_params

  //============================================================================
  // GTX2 parameters class
  //============================================================================
  class gtx2_xcvr_params extends xcvr_params;

    // -----------------
    //
    // -----------------
    function new();
      qpll_fbdiv_drp  = '{16: 32,
                          20: 48,
                          32: 96,
                          40: 128,
                          64: 224,
                          66: 320,
                          80: 288,
                          100: 368};

      cpll_vco_min = 64'd1600000000;
      cpll_vco_max = 64'd3300000000;

    endfunction

    // -----------------
    //
    // -----------------
    function int qpll_check_vco_range(longint unsigned qpll_vco, int is_qpll1=0);
      if (qpll_vco < 64'd5930000000 || qpll_vco > 64'd12500000000)
        return 1;
      else if (qpll_vco > 64'd8000000000 && qpll_vco < 64'd9800000000)
          return 1;
        else
          return 0;
    endfunction : qpll_check_vco_range

  endclass

  //============================================================================
  // GTH3 parameters class
  //============================================================================
  class gth3_xcvr_params extends xcvr_params;

    // -----------------
    //
    // -----------------
    function new();

      prog_div_drp = '{10: 57760,
                       17: 49672,
                       20: 57762,
                       33: 49800,
                       40: 57766,
                       66: 50056,
                       80: 57743
                       };

      // Only take the interesting  values. Actual range 16-160
      qpll_fbdiv_drp  = '{16: 14,
                          20: 18,
                          32: 30,
                          33: 31,
                          40: 38,
                          64: 62,
                          66: 64,
                          80: 78,
                          99: 97,
                          100: 98};

      cpll_vco_min = 64'd2000000000;
      cpll_vco_max = 64'd6250000000;

    endfunction

    // -----------------
    //
    // -----------------
    function int qpll_check_vco_range(longint unsigned qpll_vco, int is_qpll1 = 0);
      if ((qpll_vco < 64'd9800000000 || qpll_vco > 64'd16375000000) && is_qpll1 == 0)
        return 1;
      else if ((qpll_vco < 64'd8000000000 || qpll_vco > 64'd13000000000) && is_qpll1 == 1)
          return 1;
        else
          return 0;
    endfunction : qpll_check_vco_range

  endclass : gth3_xcvr_params

  //============================================================================
  // GTH4 parameters class
  //============================================================================
  class gth4_xcvr_params extends gth3_xcvr_params;

    // -----------------
    //
    // -----------------
    function new();
      super.new();
      prog_div_drp = '{10: 57440,
                       17: 57880,
                       20: 57442,
                       33: 57856,
                       40: 57415,
                       66: 57858,
                       80: 57423
                       };

    endfunction

  endclass : gth4_xcvr_params

  //============================================================================
  // Xilinx XCVR class
  //============================================================================
  class xcvr extends adi_api;

    // Capabilities
    bit qpll_enable;
    xcvr_type_t xcvr_type = Unknown;
    bit [1:0] link_mode;
    bit tx_or_rx_n;
    bit [5:0] num_lanes;

    xcvr_params p;

    // -----------------
    //
    // -----------------
    function new (string name, m_axi_sequencer_base bus, bit [31:0] base_address);
      super.new(name, bus, base_address);
    endfunction

    // -----------------
    //
    // -----------------
    // Discover Hw capabilities
    task discover_capabs();
      bit [31:0] val;
      this.bus.RegRead32(this.base_address + GetAddrs(XCVR_GENERIC_INFO), val);
      qpll_enable = `GET_XCVR_GENERIC_INFO_QPLL_ENABLE(val);
      xcvr_type = xcvr_type_t'(`GET_XCVR_GENERIC_INFO_XCVR_TYPE(val));
      link_mode = `GET_XCVR_GENERIC_INFO_LINK_MODE(val);
      num_lanes = `GET_XCVR_GENERIC_INFO_NUM_OF_LANES(val);
      tx_or_rx_n = `GET_XCVR_GENERIC_INFO_TX_OR_RX_N(val);
    endtask : discover_capabs

    // -----------------
    //
    // -----------------
    task probe ();
      super.probe();
      discover_capabs();
      this.info($sformatf("Found %0s %0s XCVR = %0s on %0d lanes, QPLL access : %0d" ,
        tx_or_rx_n ? "TX" : "RX",
        link_mode == 1 ? "8B10B" : link_mode == 2 ? "64B66B" : "Unknown",
        xcvr_type.name(),
        num_lanes,
        qpll_enable
        ), ADI_VERBOSITY_MEDIUM);
      case (xcvr_type)
        GTXE2:
          begin
            gtx2_xcvr_params GTXE2p;
            GTXE2p = new();
            p = GTXE2p;
          end
        GTHE3:
          begin
            gth3_xcvr_params GTHE3p;
            GTHE3p = new();
            p = GTHE3p;
          end
        GTHE4,
        GTYE3_NOT_SUPPORTED,
        GTYE4:
          begin
            gth4_xcvr_params GTHE4p;
            GTHE4p = new();
            p = GTHE4p;
          end
        default:
          this.error($sformatf("Case not supported"));
      endcase

    endtask : probe

    // -----------------
    // cm_sel - 0, 1, .. - common number
    //          255 - broadcast
    // -----------------
    task drp_cm_write(input bit [7:0] sel,
                      input bit [11:0] addr,
                      input bit [15:0] wdata);

      bit [16:0] val = {1'b1, 16'b0};

      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CM_SEL),
                          `SET_XCVR_CM_SEL_CM_SEL(sel));
      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CM_CONTROL),
                          `SET_XCVR_CM_CONTROL_CM_WR(1) |
                          `SET_XCVR_CM_CONTROL_CM_ADDR(addr) |
                          `SET_XCVR_CM_CONTROL_CM_WDATA(wdata));
      while (val[16]) begin
        this.bus.RegRead32(this.base_address + GetAddrs(XCVR_CM_STATUS), val);
      end
    endtask : drp_cm_write

    // -----------------
    //
    // -----------------
    task drp_cm_read(input bit [7:0] sel,
                     input bit [11:0] addr,
                     output logic [15:0] rdata);

      logic [16:0] val = {1'b1, 16'b0};

      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CM_SEL),
                          `SET_XCVR_CM_SEL_CM_SEL(sel));
      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CM_CONTROL),
                          `SET_XCVR_CM_CONTROL_CM_WR(0) |
                          `SET_XCVR_CM_CONTROL_CM_ADDR(addr) |
                          `SET_XCVR_CM_CONTROL_CM_WDATA(0));
      while (val[16]) begin
        this.bus.RegRead32(this.base_address + GetAddrs(XCVR_CM_STATUS), val);
      end
      rdata = `GET_XCVR_CM_STATUS_CM_RDATA(val);

    endtask : drp_cm_read

    // -----------------
    //
    // cm_sel - 0, 1, .. - common number
    //          255 - broadcast
    // wdata - value of field shifted
    // mask - active field mask;
    //        eg for 7:4 mask is 00011110000
    // -----------------
    task drp_cm_update(input bit [7:0] sel,
                       input bit [11:0] addr,
                       input bit [15:0] wdata,
                       input bit [15:0] mask);
      bit [15:0] val;
      drp_cm_read(sel, addr, val);
      val = (val & ~mask) | wdata;
      drp_cm_write(sel, addr, val);
    endtask : drp_cm_update

    // -----------------
    //
    // ch_sel - 0, 1, .. - channel number
    //          255 - broadcast
    // -----------------
    task drp_ch_write(input bit [7:0] sel,
                      input bit [11:0] addr,
                      input bit [15:0] wdata);

      bit [16:0] val = {1'b1, 16'b0};

      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CH_SEL),
                          `SET_XCVR_CH_SEL_CH_SEL(sel));
      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CH_CONTROL),
                          `SET_XCVR_CH_CONTROL_CH_WR(1) |
                          `SET_XCVR_CH_CONTROL_CH_ADDR(addr) |
                          `SET_XCVR_CH_CONTROL_CH_WDATA(wdata));
      while (val[16]) begin
        this.bus.RegRead32(this.base_address + GetAddrs(XCVR_CH_STATUS), val);
      end

    endtask : drp_ch_write

    // -----------------
    //
    // -----------------
    task drp_ch_read(input bit [7:0] sel,
                     input bit [11:0] addr,
                     output logic [15:0] rdata);

      logic [16:0] val = {1'b1, 16'b0};

      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CH_SEL),
                          `SET_XCVR_CH_SEL_CH_SEL(sel));
      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CH_CONTROL),
                          `SET_XCVR_CH_CONTROL_CH_WR(0) |
                          `SET_XCVR_CH_CONTROL_CH_ADDR(addr) |
                          `SET_XCVR_CH_CONTROL_CH_WDATA(0));
      while (val[16]) begin
        this.bus.RegRead32(this.base_address + GetAddrs(XCVR_CH_STATUS), val);
      end
      rdata = `GET_XCVR_CH_STATUS_CH_RDATA(val);

    endtask : drp_ch_read

    // -----------------
    //
    // ch_sel - 0, 1, .. - channel number
    //          255 - broadcast
    // wdata - value of field shifted
    // mask - active field mask;
    //        eg for 7:4 mask is 00011110000
    // -----------------
    task drp_ch_update(input bit [7:0] sel,
                       input bit [11:0] addr,
                       input bit [15:0] wdata,
                       input bit [15:0] mask);
      bit [15:0] val;
      drp_ch_read(sel, addr, val);
      val = (val & ~mask) | wdata;
      drp_ch_write(sel, addr, val);
    endtask : drp_ch_update

    // -----------------
    //
    // -----------------
    task up();

      bit [31:0] val;
      bit reset_done;
      bit pll_lock_n;
      int timeout = 50;

      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_RESETN),
                          `SET_XCVR_RESETN_RESETN(1));
      // wait until transceivers assert RESETDONE
      while (~reset_done && timeout > 0) begin
        #1us;
        this.bus.RegRead32(this.base_address + GetAddrs(XCVR_STATUS), val);
        reset_done = `GET_XCVR_STATUS_STATUS(val);
        pll_lock_n = `GET_XCVR_STATUS_PLL_LOCK_N(val);
        timeout--;
      end
      if (timeout == 0) begin
        this.error($sformatf("[%s] XCVR status: 0, PLL lock: %0d", name, ~pll_lock_n));
      end else begin
        this.info($sformatf("[%s] XCVR status: 1, PLL lock: %0d", name, ~pll_lock_n), ADI_VERBOSITY_MEDIUM);
      end

    endtask : up

    // -----------------
    //
    // -----------------
    task down();
      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_RESETN),
                          `SET_XCVR_RESETN_RESETN(0));
    endtask : down

    // -----------------
    // Automatically choose a PLL and
    // set its internal dividers based on :
    //    lane rate,
    //    ref clock
    // -----------------
    task setup_clocks(longint unsigned lane_rate,
                      int unsigned ref_clk,
                      pll_type_t plls_to_try[] = {});

      int pll_idx;
      pll_type_t pll_type;
      pll_type_t invalid_plls[$];
      out_clk_sel_t out_clk_sel;
      int out_div;
      int pll_success = 0;

      case (xcvr_type)
        GTXE2:
          begin
            if (plls_to_try.size() == 0)
              plls_to_try = '{QPLL0, CPLL};

            invalid_plls = plls_to_try.find(x) with (x == QPLL1);
            if (invalid_plls.size() != 0)
              this.error($sformatf("QPLL1 is not supported on GTXE2"));

            out_clk_sel = OUTCLKPMA;
          end
        GTHE3,
        GTHE4,
        GTYE3_NOT_SUPPORTED,
        GTYE4:
          begin
            if (plls_to_try.size() == 0)
              plls_to_try = '{QPLL0, QPLL1, CPLL};
            out_clk_sel = PROGDIVCLK;
          end
        default:
          this.error($sformatf("Case not supported"));
      endcase

      foreach (plls_to_try[pll_idx]) begin
        case (plls_to_try[pll_idx])
          CPLL:
            calc_cpll(lane_rate, ref_clk, pll_success, out_div);
          QPLL1:
              calc_qpll(lane_rate, ref_clk, 1, pll_success, out_div);
          QPLL0:
              calc_qpll(lane_rate, ref_clk, 0, pll_success, out_div);
          default:
            this.error($sformatf("Case not supported"));
        endcase
        if (pll_success) begin
          pll_type = plls_to_try[pll_idx];
          break;
        end
      end

      if (pll_success == 0) begin
        this.error($sformatf("No PLL could be set"));
      end

      for (int ch_idx = 0; ch_idx < num_lanes; ch_idx++) begin
        if (out_clk_sel == PROGDIVCLK) begin
          case (xcvr_type)
            GTXE2:
              this.error($sformatf("No PROGDIV support"));
            GTHE3,
            GTHE4,
            GTYE3_NOT_SUPPORTED,
            GTYE4:
              set_progdiv(ch_idx, out_div);
            default:
              this.error($sformatf("Case not supported"));
          endcase
        end

        set_out_div(ch_idx, out_div);

      end

      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CONTROL),
                          `SET_XCVR_CONTROL_LPM_DFE_N(1) |
                          `SET_XCVR_CONTROL_SYSCLK_SEL(pll_type) |
                          `SET_XCVR_CONTROL_OUTCLK_SEL(out_clk_sel));

    endtask : setup_clocks

    // -----------------
    //
    // -----------------
    task calc_cpll(longint unsigned lane_rate,
                   int unsigned ref_clk,
                   output int success,
                   output int f_out_div);

      // CPLL out = ref_clk * CPLL_FBDIV * CPLL_FBDIV_45 / CPLL_REFCLK_DIV
      // lane rate = CPLL out * 2 / OUT_DIV
      longint unsigned cpll_vco;

      int out_div;
      int f_fbdiv, f_fbdiv_45, f_refclk_div;
      int found = 0;

      this.info($sformatf("Searching valid config for lane rate %0d ref clock %0d", lane_rate, ref_clk), ADI_VERBOSITY_MEDIUM);
      for (int fbdiv = 1; fbdiv <= 5; fbdiv++) begin
        for (int fbdiv_45 = 4; fbdiv_45 <= 5; fbdiv_45++) begin
          for (int refclk_div = 1; refclk_div <= 2; refclk_div++) begin
            cpll_vco = ref_clk * fbdiv_45 * fbdiv / refclk_div;
            if (p.cpll_check_vco_range(cpll_vco)) begin
              this.info($sformatf("Skipping CPLL vco %0d . Out of range, [ %0d - %0d ]",
                      cpll_vco,
                      p.cpll_vco_min,
                      p.cpll_vco_max), ADI_VERBOSITY_MEDIUM);
              continue;
            end
            for (int out_div_idx = 0; out_div_idx <= 3; out_div_idx++) begin
              out_div = 2**out_div_idx;
              if (cpll_vco/out_div == lane_rate/2) begin
                f_fbdiv = fbdiv;
                f_fbdiv_45 = fbdiv_45;
                f_refclk_div = refclk_div;
                f_out_div = out_div;
                found = 1;
                break;
              end
            end
            if (found) break;
          end
          if (found) break;
        end
        if (found) break;
      end

      if (found) begin
        this.info($sformatf("Found cpll_vco : %0d", cpll_vco), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("Found cpll_fbdiv : %0d", f_fbdiv), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("Found cpll_fbdiv_45 : %0d", f_fbdiv_45), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("Found cpll_refclk_div : %0d", f_refclk_div), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("Found out_div : %0d", f_out_div), ADI_VERBOSITY_MEDIUM);
      end else begin
        this.info($sformatf("No valid config found for CPLL lane rate %0d ref clock %0d", lane_rate, ref_clk), ADI_VERBOSITY_MEDIUM);
        success = 0;
        return;
      end

      for (int ch_idx = 0; ch_idx < num_lanes; ch_idx++) begin

        set_cpll_divs(ch_idx, f_refclk_div, f_fbdiv, f_fbdiv_45);

      end
      success = 1;

    endtask : calc_cpll

    // -----------------
    //
    // -----------------
    task set_cpll_divs(int ch_idx, int f_refclk_div, int f_fbdiv, int f_fbdiv_45);
       case (xcvr_type)
          GTXE2:
            begin
              drp_ch_update(ch_idx, 'h5E,
                            p.cpll_refclk_div_drp(f_refclk_div) << 8 |
                            p.cpll_fbdiv_45_drp(f_fbdiv_45) << 7 |
                            p.cpll_fbdiv_drp(f_fbdiv),
                            {13{1'b1}} << 0
                            );
            end
          GTHE3,
          GTHE4,
          GTYE3_NOT_SUPPORTED,
          GTYE4:
            begin
              drp_ch_update(ch_idx, 'h2A,
                            p.cpll_refclk_div_drp(f_refclk_div) << 11,
                            {5{1'b1}} << 11
                            );
              drp_ch_update(ch_idx, 'h28,
                            p.cpll_fbdiv_drp(f_fbdiv) << 8 |
                            p.cpll_fbdiv_45_drp(f_fbdiv_45)<< 7,
                            {9{1'b1}} << 7
                            );
            end
          default:
            this.error($sformatf("Case not supported"));
        endcase

    endtask : set_cpll_divs

    // -----------------
    //
    // -----------------
    task calc_qpll(longint unsigned lane_rate,
                   int unsigned ref_clk,
                   input is_qpll1,
                   output int success,
                   output int f_out_div);
      // QPLL out = ref_clk * QPLL_FBDIV / (QPLL_REFCLK_DIV * QPLL_CLKOUTRATE)
      // lane rate = QPLL out * 2 / OUT_DIV
      longint unsigned qpll_vco;

      int fbdiv, out_div;
      int f_fbdiv, f_refclk_div;
      int found = 0;
      int qpll_clkoutrate;
      int qpll_clkoutrate_min = 2;

      case (xcvr_type)
        GTYE3_NOT_SUPPORTED,
        GTYE4:
          qpll_clkoutrate_min = 1;  // Full rate
        default:
          qpll_clkoutrate_min = 2;  // Half rate
      endcase

      this.info($sformatf("Searching valid config for lane rate %0d ref clock %0d", lane_rate, ref_clk), ADI_VERBOSITY_MEDIUM);
      foreach (p.qpll_fbdiv_drp[fbdiv]) begin : fbdiv_loop
        for (int refclk_div = 1; refclk_div <= 4; refclk_div++) begin
          qpll_vco = ref_clk * fbdiv / refclk_div;
          if (p.qpll_check_vco_range(qpll_vco, is_qpll1)) begin
            this.info($sformatf("Skipping QPLL vco %0d . Out of range. fbdiv = %0d refclk_div = %0d", qpll_vco, fbdiv, refclk_div), ADI_VERBOSITY_MEDIUM);
            continue;
          end
          for (qpll_clkoutrate = qpll_clkoutrate_min; qpll_clkoutrate <= 2; qpll_clkoutrate++) begin
            for (int out_div_idx = 0; out_div_idx <= 3; out_div_idx++) begin
              out_div = 2**out_div_idx;
              if (qpll_vco/qpll_clkoutrate/out_div == lane_rate/2) begin
                f_fbdiv = fbdiv;
                f_refclk_div = refclk_div;
                f_out_div = out_div;
                found = 1;
                break;
              end
            end
            if (found) break;
          end
          if (found) break;
        end
        if (found) break;
      end

      if (found) begin
        this.info($sformatf("Found qpll_vco : %0d", qpll_vco), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("Found qpll_fbdiv : %0d", f_fbdiv), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("Found qpll_refclk_div : %0d", f_refclk_div), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("Found qpll_clkoutrate : %0d", qpll_clkoutrate), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("Found out_div : %0d", f_out_div), ADI_VERBOSITY_MEDIUM);
      end else begin
        this.info($sformatf("No valid config found for QPLL%0d lane rate %0d ref clock %0d", is_qpll1, lane_rate, ref_clk), ADI_VERBOSITY_MEDIUM);
        success = 0;
        return;
      end

      for (int ch_idx = 0; ch_idx < num_lanes; ch_idx++) begin

        if (ch_idx % 4 == 0) begin
          if (qpll_enable)
            set_qpll_divs(ch_idx, is_qpll1, f_refclk_div, f_fbdiv, qpll_clkoutrate);
          else
            this.info($sformatf("WARNING: Skipping QPLL configuration. Current AXI_XCVR does not have access to the CM ports"), ADI_VERBOSITY_MEDIUM);
        end

      end

      success = 1;

    endtask : calc_qpll

    // -----------------
    //
    // -----------------
    task set_qpll_divs (int cm_idx, int is_qpll1, int f_refclk_div, int f_fbdiv, int qpll_clkoutrate);
        case (xcvr_type)
          GTXE2:
            begin
              drp_cm_update(cm_idx, 'h33,
                            p.qpll_refclk_div_drp(f_refclk_div) << 11,
                            {5{1'b1}} << 11
                          );
              drp_cm_update(cm_idx, 'h36,
                            p.qpll_fbdiv_drp[f_fbdiv] << 0,
                            {10{1'b1}} << 0
                          );
            end
          GTHE3,
          GTHE4,
          GTYE3_NOT_SUPPORTED,
          GTYE4:
            begin
              drp_cm_update(cm_idx, 'h18 + 'h80 * is_qpll1,
                            p.qpll_refclk_div_drp(f_refclk_div) << 7,
                            {5{1'b1}} << 7
                            );
              drp_cm_update(cm_idx, 'h14 + 'h80 * is_qpll1,
                            p.qpll_fbdiv_drp[f_fbdiv] << 0,
                            {8{1'b1}} << 0
                            );
              if (xcvr_type == GTYE4 ||
                  xcvr_type == GTYE3_NOT_SUPPORTED) begin
                drp_cm_write(cm_idx, 'h0E + 'h80 * is_qpll1,
                             qpll_clkoutrate == 1
                            );
              end
            end
          default:
            this.error($sformatf("Case not supported"));
        endcase
    endtask : set_qpll_divs

    // -----------------
    // Set RXOUT_DIV or TXOUT_DIV based on channel direction
    // -----------------
    task set_out_div(int ch_idx, int f_out_div);
      case (xcvr_type)
        GTXE2:
          begin
            if (tx_or_rx_n) begin
              drp_ch_update(ch_idx, 'h88,
                            p.out_div_drp(f_out_div) << 4,
                            {3{1'b1}} << 4
                            );
            end else begin
              drp_ch_update(ch_idx, 'h88,
                            p.out_div_drp(f_out_div) << 0,
                            {3{1'b1}} << 0
                            );
            end
          end
        GTHE3,
        GTHE4,
        GTYE3_NOT_SUPPORTED,
        GTYE4:
          begin
            if (tx_or_rx_n) begin
              drp_ch_update(ch_idx, 'h7c,
                            p.out_div_drp(f_out_div) << 8,
                            {3{1'b1}} << 8
                            );
            end else begin
              drp_ch_update(ch_idx, 'h63,
                            p.out_div_drp(f_out_div) << 0,
                            {3{1'b1}} << 0
                            );
            end
          end
        default:
          this.error($sformatf("Case not supported"));
      endcase
    endtask : set_out_div

    // -----------------
    // Set PROGDIV_CFG corresponding to an OUT_DIV
    //  OUT_CLK must be:
    //     - lane rate / 40 for 8b10b
    //     - lane rate / 66 for 64b66b on GTY
    //     - lane rate / 33 for 64b66b on GTH
    // -----------------
    task set_progdiv(int ch_idx, int f_out_div);
      int progdiv;
      int progdiv_rate = 1;
      int progdiv_rate_addr;
      int progdiv_addr;

      if (link_mode == 1) begin
         case (xcvr_type)
          GTHE3,
          GTHE4:
            case (f_out_div)
              1: progdiv = 20;
              2: progdiv = 40;
              4: progdiv = 80;
              default:
                this.error($sformatf("Case not supported"));
            endcase
          GTYE3_NOT_SUPPORTED,
          GTYE4:
            case (f_out_div)
              1: progdiv = 10;
              2: progdiv = 20;
              4: progdiv = 40;
              8: progdiv = 80;
              default:
                this.error($sformatf("Case not supported"));
            endcase
          default:
            this.error($sformatf("Case not supported"));
        endcase

      end else if (link_mode == 2) begin
        case (f_out_div)
          1: progdiv = 17; // 16.5
          2: progdiv = 33;
          4: progdiv = 66;
          default:
            this.error($sformatf("Case not supported"));
        endcase

      end else begin
        this.error($sformatf("Case not supported"));
      end

      case (xcvr_type)
        GTYE3_NOT_SUPPORTED,
        GTYE4:
          progdiv_rate = 0; // pre-divider = 2;
        default:
          progdiv_rate = 1; // pre-divider = 1;
      endcase

      if (tx_or_rx_n) begin
        case (xcvr_type)
          GTYE4:
            progdiv_addr = 'h0057;
          default:
            progdiv_addr = 'h003E;
        endcase
        progdiv_rate_addr = 'h105;
      end else begin
        progdiv_addr = 'h00C6;
        progdiv_rate_addr = 'h103;
      end

      drp_ch_write(ch_idx, progdiv_addr,
                   p.prog_div_drp[progdiv]);
      drp_ch_write(ch_idx, progdiv_rate_addr,
                   progdiv_rate);

    endtask : set_progdiv

  endclass : xcvr

endpackage
