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
//      <https://www.gnu.org/licenses/old_licenses/gpl_2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on_line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
`include "utils.svh"

package adi_xcvr_pkg;

  import logger_pkg::*;
  import adi_peripheral_pkg::*;
  import reg_accessor_pkg::*;
  import adi_regmap_pkg::*;
  import adi_regmap_xcvr_pkg::*;
  import adi_jesd204_pkg::*;

  //============================================================================
  // Xilinx XCVR class
  //============================================================================
  class xcvr extends adi_peripheral;

    // lane rate
    // ref clock
    // out sel

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
          GTME4_NOT_SUPPORTED = 10} xcvr_type_t;

    // Capabilities
    bit qpll_enable;
    xcvr_type_t xcvr_type = Unknown;
    bit [1:0] link_mode;
    bit tx_or_rx_n;
    bit [5:0] num_lanes;

    // -----------------
    //
    // -----------------
    function new (reg_accessor bus, bit [31:0] base_address);
      super.new(bus, base_address);
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
      `INFO(("Found %0s %0s XCVR = %0s on %0d lanes, QPLL access : %0d" ,
        tx_or_rx_n ? "TX" : "RX",
        link_mode == 1 ? "8B10B" : link_mode == 2 ? "64B66B" : "Unknown",
        xcvr_type.name(),
        num_lanes,
        qpll_enable
        ));
    endtask : probe

    // -----------------
    // cm_sel - 0,1,.. - common number
    //          255 - broadcast
    // -----------------
    task drp_cm_write(input bit [7:0] sel,
                      input bit [11:0] addr,
                      input bit [15:0] wdata);

      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CM_SEL),
                          `SET_XCVR_CM_SEL_CM_SEL(sel));
      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CM_CONTROL),
                          `SET_XCVR_CM_CONTROL_CM_WR(1) |
                          `SET_XCVR_CM_CONTROL_CM_ADDR(addr) |
                          `SET_XCVR_CM_CONTROL_CM_WDATA(wdata));
    endtask : drp_cm_write

    // -----------------
    //
    // ch_sel - 0,1,.. - channel number
    //          255 - broadcast
    // -----------------
    task drp_ch_write(input bit [7:0] sel,
                      input bit [11:0] addr,
                      input bit [15:0] wdata);

      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CH_SEL),
                          `SET_XCVR_CH_SEL_CH_SEL(sel));
      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CH_CONTROL),
                          `SET_XCVR_CH_CONTROL_CH_WR(1) |
                          `SET_XCVR_CH_CONTROL_CH_ADDR(addr) |
                          `SET_XCVR_CH_CONTROL_CH_WDATA(wdata));
    endtask : drp_ch_write

    // -----------------
    //
    // -----------------
    task drp_cm_read(input bit [7:0] sel,
                     input bit [11:0] addr,
                     output bit [15:0] rdata);

      bit [15:0] val;

      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CM_SEL),
                          `SET_XCVR_CM_SEL_CM_SEL(sel));
      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CM_CONTROL),
                          `SET_XCVR_CM_CONTROL_CM_WR(0) |
                          `SET_XCVR_CM_CONTROL_CM_ADDR(addr) |
                          `SET_XCVR_CM_CONTROL_CM_WDATA(0));
      this.bus.RegRead32(this.base_address + GetAddrs(XCVR_CM_STATUS),val);
      rdata = `GET_XCVR_CM_STATUS_CM_RDATA(val);

    endtask : drp_cm_read

    // -----------------
    //
    // -----------------
    task drp_ch_read(input bit [7:0] sel,
                     input bit [11:0] addr,
                     output bit [15:0] rdata);

      bit [15:0] val;

      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CH_SEL),
                          `SET_XCVR_CH_SEL_CH_SEL(sel));
      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_CH_CONTROL),
                          `SET_XCVR_CH_CONTROL_CH_WR(0) |
                          `SET_XCVR_CH_CONTROL_CH_ADDR(addr) |
                          `SET_XCVR_CH_CONTROL_CH_WDATA(0));
      this.bus.RegRead32(this.base_address + GetAddrs(XCVR_CH_STATUS),val);
      rdata = `GET_XCVR_CH_STATUS_CH_RDATA(val);

    endtask : drp_ch_read

    // -----------------
    //
    // -----------------
    task up();

      bit [31:0] val;
      bit reset_done;
      bit pll_lockedn;
      int timeout = 20;

      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_RESETN),
                          `SET_XCVR_RESETN_RESETN(1));
      // wait until transceivers assert RESETDONE
      while (~reset_done && timeout > 0) begin
        #1us;
        this.bus.RegRead32(this.base_address + GetAddrs(XCVR_STATUS),val);
        reset_done = `GET_XCVR_STATUS_STATUS(val);
        timeout--;
      end
      if (timeout == 0) begin
        `ERROR(("XCVR status: 0, PLL lock: %0d", ~pll_lockedn));
      end else begin
        `INFO(("XCVR status: 1, PLL lock: %0d", ~pll_lockedn));
      end

    endtask : up

    // -----------------
    //
    // -----------------
    task down();
      this.bus.RegWrite32(this.base_address + GetAddrs(XCVR_RESETN),
                          `SET_XCVR_RESETN_RESETN(0));
    endtask : down


  endclass : xcvr

endpackage
