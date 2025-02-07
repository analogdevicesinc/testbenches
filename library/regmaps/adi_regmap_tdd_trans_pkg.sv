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

package adi_regmap_tdd_trans_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_tdd_trans extends adi_regmap;

    /* Transceiver TDD Control (axi_ad*) */
    class TDD_CONTROL_0_CLASS extends register_base;
      field_base TDD_GATED_TX_DMAPATH_F;
      field_base TDD_GATED_RX_DMAPATH_F;
      field_base TDD_TXONLY_F;
      field_base TDD_RXONLY_F;
      field_base TDD_SECONDARY_F;
      field_base TDD_ENABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_GATED_TX_DMAPATH_F = new("TDD_GATED_TX_DMAPATH", 5, 5, RW, 'h0, this);
        this.TDD_GATED_RX_DMAPATH_F = new("TDD_GATED_RX_DMAPATH", 4, 4, RW, 'h0, this);
        this.TDD_TXONLY_F = new("TDD_TXONLY", 3, 3, RW, 'h0, this);
        this.TDD_RXONLY_F = new("TDD_RXONLY", 2, 2, RW, 'h0, this);
        this.TDD_SECONDARY_F = new("TDD_SECONDARY", 1, 1, RW, 'h0, this);
        this.TDD_ENABLE_F = new("TDD_ENABLE", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_CONTROL_0_CLASS

    class TDD_CONTROL_1_CLASS extends register_base;
      field_base TDD_BURST_COUNT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_BURST_COUNT_F = new("TDD_BURST_COUNT", 7, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_CONTROL_1_CLASS

    class TDD_CONTROL_2_CLASS extends register_base;
      field_base TDD_COUNTER_INIT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_COUNTER_INIT_F = new("TDD_COUNTER_INIT", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_CONTROL_2_CLASS

    class TDD_FRAME_LENGTH_CLASS extends register_base;
      field_base TDD_FRAME_LENGTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_FRAME_LENGTH_F = new("TDD_FRAME_LENGTH", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_FRAME_LENGTH_CLASS

    class TDD_SYNC_TERMINAL_TYPE_CLASS extends register_base;
      field_base TDD_SYNC_TERMINAL_TYPE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_SYNC_TERMINAL_TYPE_F = new("TDD_SYNC_TERMINAL_TYPE", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_SYNC_TERMINAL_TYPE_CLASS

    class TDD_STATUS_CLASS extends register_base;
      field_base TDD_RXTX_VCO_OVERLAP_F;
      field_base TDD_RXTX_RF_OVERLAP_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_RXTX_VCO_OVERLAP_F = new("TDD_RXTX_VCO_OVERLAP", 0, 0, RO, 'h0, this);
        this.TDD_RXTX_RF_OVERLAP_F = new("TDD_RXTX_RF_OVERLAP", 1, 1, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_STATUS_CLASS

    class TDD_VCO_RX_ON_1_CLASS extends register_base;
      field_base TDD_VCO_RX_ON_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_VCO_RX_ON_1_F = new("TDD_VCO_RX_ON_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_VCO_RX_ON_1_CLASS

    class TDD_VCO_RX_OFF_1_CLASS extends register_base;
      field_base TDD_VCO_RX_OFF_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_VCO_RX_OFF_1_F = new("TDD_VCO_RX_OFF_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_VCO_RX_OFF_1_CLASS

    class TDD_VCO_TX_ON_1_CLASS extends register_base;
      field_base TDD_VCO_TX_ON_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_VCO_TX_ON_1_F = new("TDD_VCO_TX_ON_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_VCO_TX_ON_1_CLASS

    class TDD_VCO_TX_OFF_1_CLASS extends register_base;
      field_base TDD_VCO_TX_OFF_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_VCO_TX_OFF_1_F = new("TDD_VCO_TX_OFF_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_VCO_TX_OFF_1_CLASS

    class TDD_RX_ON_1_CLASS extends register_base;
      field_base TDD_RX_ON_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_RX_ON_1_F = new("TDD_RX_ON_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_RX_ON_1_CLASS

    class TDD_RX_OFF_1_CLASS extends register_base;
      field_base TDD_RX_OFF_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_RX_OFF_1_F = new("TDD_RX_OFF_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_RX_OFF_1_CLASS

    class TDD_TX_ON_1_CLASS extends register_base;
      field_base TDD_TX_ON_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_TX_ON_1_F = new("TDD_TX_ON_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_TX_ON_1_CLASS

    class TDD_TX_OFF_1_CLASS extends register_base;
      field_base TDD_TX_OFF_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_TX_OFF_1_F = new("TDD_TX_OFF_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_TX_OFF_1_CLASS

    class TDD_RX_DP_ON_1_CLASS extends register_base;
      field_base TDD_RX_DP_ON_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_RX_DP_ON_1_F = new("TDD_RX_DP_ON_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_RX_DP_ON_1_CLASS

    class TDD_RX_DP_OFF_1_CLASS extends register_base;
      field_base TDD_RX_DP_OFF_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_RX_DP_OFF_1_F = new("TDD_RX_DP_OFF_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_RX_DP_OFF_1_CLASS

    class TDD_TX_DP_ON_1_CLASS extends register_base;
      field_base TDD_TX_DP_ON_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_TX_DP_ON_1_F = new("TDD_TX_DP_ON_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_TX_DP_ON_1_CLASS

    class TDD_TX_DP_OFF_1_CLASS extends register_base;
      field_base TDD_TX_DP_OFF_1_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_TX_DP_OFF_1_F = new("TDD_TX_DP_OFF_1", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_TX_DP_OFF_1_CLASS

    class TDD_VCO_RX_ON_2_CLASS extends register_base;
      field_base TDD_VCO_RX_ON_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_VCO_RX_ON_2_F = new("TDD_VCO_RX_ON_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_VCO_RX_ON_2_CLASS

    class TDD_VCO_RX_OFF_2_CLASS extends register_base;
      field_base TDD_VCO_RX_OFF_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_VCO_RX_OFF_2_F = new("TDD_VCO_RX_OFF_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_VCO_RX_OFF_2_CLASS

    class TDD_VCO_TX_ON_2_CLASS extends register_base;
      field_base TDD_VCO_TX_ON_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_VCO_TX_ON_2_F = new("TDD_VCO_TX_ON_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_VCO_TX_ON_2_CLASS

    class TDD_VCO_TX_OFF_2_CLASS extends register_base;
      field_base TDD_VCO_TX_OFF_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_VCO_TX_OFF_2_F = new("TDD_VCO_TX_OFF_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_VCO_TX_OFF_2_CLASS

    class TDD_RX_ON_2_CLASS extends register_base;
      field_base TDD_RX_ON_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_RX_ON_2_F = new("TDD_RX_ON_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_RX_ON_2_CLASS

    class TDD_RX_OFF_2_CLASS extends register_base;
      field_base TDD_RX_OFF_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_RX_OFF_2_F = new("TDD_RX_OFF_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_RX_OFF_2_CLASS

    class TDD_TX_ON_2_CLASS extends register_base;
      field_base TDD_TX_ON_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_TX_ON_2_F = new("TDD_TX_ON_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_TX_ON_2_CLASS

    class TDD_TX_OFF_2_CLASS extends register_base;
      field_base TDD_TX_OFF_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_TX_OFF_2_F = new("TDD_TX_OFF_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_TX_OFF_2_CLASS

    class TDD_RX_DP_ON_2_CLASS extends register_base;
      field_base TDD_RX_DP_ON_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_RX_DP_ON_2_F = new("TDD_RX_DP_ON_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_RX_DP_ON_2_CLASS

    class TDD_RX_DP_OFF_2_CLASS extends register_base;
      field_base TDD_RX_DP_OFF_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_RX_DP_OFF_2_F = new("TDD_RX_DP_OFF_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_RX_DP_OFF_2_CLASS

    class TDD_TX_DP_ON_2_CLASS extends register_base;
      field_base TDD_TX_DP_ON_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_TX_DP_ON_2_F = new("TDD_TX_DP_ON_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_TX_DP_ON_2_CLASS

    class TDD_TX_DP_OFF_2_CLASS extends register_base;
      field_base TDD_TX_DP_OFF_2_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TDD_TX_DP_OFF_2_F = new("TDD_TX_DP_OFF_2", 23, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TDD_TX_DP_OFF_2_CLASS

    TDD_CONTROL_0_CLASS TDD_CONTROL_0_R;
    TDD_CONTROL_1_CLASS TDD_CONTROL_1_R;
    TDD_CONTROL_2_CLASS TDD_CONTROL_2_R;
    TDD_FRAME_LENGTH_CLASS TDD_FRAME_LENGTH_R;
    TDD_SYNC_TERMINAL_TYPE_CLASS TDD_SYNC_TERMINAL_TYPE_R;
    TDD_STATUS_CLASS TDD_STATUS_R;
    TDD_VCO_RX_ON_1_CLASS TDD_VCO_RX_ON_1_R;
    TDD_VCO_RX_OFF_1_CLASS TDD_VCO_RX_OFF_1_R;
    TDD_VCO_TX_ON_1_CLASS TDD_VCO_TX_ON_1_R;
    TDD_VCO_TX_OFF_1_CLASS TDD_VCO_TX_OFF_1_R;
    TDD_RX_ON_1_CLASS TDD_RX_ON_1_R;
    TDD_RX_OFF_1_CLASS TDD_RX_OFF_1_R;
    TDD_TX_ON_1_CLASS TDD_TX_ON_1_R;
    TDD_TX_OFF_1_CLASS TDD_TX_OFF_1_R;
    TDD_RX_DP_ON_1_CLASS TDD_RX_DP_ON_1_R;
    TDD_RX_DP_OFF_1_CLASS TDD_RX_DP_OFF_1_R;
    TDD_TX_DP_ON_1_CLASS TDD_TX_DP_ON_1_R;
    TDD_TX_DP_OFF_1_CLASS TDD_TX_DP_OFF_1_R;
    TDD_VCO_RX_ON_2_CLASS TDD_VCO_RX_ON_2_R;
    TDD_VCO_RX_OFF_2_CLASS TDD_VCO_RX_OFF_2_R;
    TDD_VCO_TX_ON_2_CLASS TDD_VCO_TX_ON_2_R;
    TDD_VCO_TX_OFF_2_CLASS TDD_VCO_TX_OFF_2_R;
    TDD_RX_ON_2_CLASS TDD_RX_ON_2_R;
    TDD_RX_OFF_2_CLASS TDD_RX_OFF_2_R;
    TDD_TX_ON_2_CLASS TDD_TX_ON_2_R;
    TDD_TX_OFF_2_CLASS TDD_TX_OFF_2_R;
    TDD_RX_DP_ON_2_CLASS TDD_RX_DP_ON_2_R;
    TDD_RX_DP_OFF_2_CLASS TDD_RX_DP_OFF_2_R;
    TDD_TX_DP_ON_2_CLASS TDD_TX_DP_ON_2_R;
    TDD_TX_DP_OFF_2_CLASS TDD_TX_DP_OFF_2_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.TDD_CONTROL_0_R = new("TDD_CONTROL_0", 'h40, this);
      this.TDD_CONTROL_1_R = new("TDD_CONTROL_1", 'h44, this);
      this.TDD_CONTROL_2_R = new("TDD_CONTROL_2", 'h48, this);
      this.TDD_FRAME_LENGTH_R = new("TDD_FRAME_LENGTH", 'h4c, this);
      this.TDD_SYNC_TERMINAL_TYPE_R = new("TDD_SYNC_TERMINAL_TYPE", 'h50, this);
      this.TDD_STATUS_R = new("TDD_STATUS", 'h60, this);
      this.TDD_VCO_RX_ON_1_R = new("TDD_VCO_RX_ON_1", 'h80, this);
      this.TDD_VCO_RX_OFF_1_R = new("TDD_VCO_RX_OFF_1", 'h84, this);
      this.TDD_VCO_TX_ON_1_R = new("TDD_VCO_TX_ON_1", 'h88, this);
      this.TDD_VCO_TX_OFF_1_R = new("TDD_VCO_TX_OFF_1", 'h8c, this);
      this.TDD_RX_ON_1_R = new("TDD_RX_ON_1", 'h90, this);
      this.TDD_RX_OFF_1_R = new("TDD_RX_OFF_1", 'h94, this);
      this.TDD_TX_ON_1_R = new("TDD_TX_ON_1", 'h98, this);
      this.TDD_TX_OFF_1_R = new("TDD_TX_OFF_1", 'h9c, this);
      this.TDD_RX_DP_ON_1_R = new("TDD_RX_DP_ON_1", 'ha0, this);
      this.TDD_RX_DP_OFF_1_R = new("TDD_RX_DP_OFF_1", 'ha4, this);
      this.TDD_TX_DP_ON_1_R = new("TDD_TX_DP_ON_1", 'ha8, this);
      this.TDD_TX_DP_OFF_1_R = new("TDD_TX_DP_OFF_1", 'hac, this);
      this.TDD_VCO_RX_ON_2_R = new("TDD_VCO_RX_ON_2", 'hc0, this);
      this.TDD_VCO_RX_OFF_2_R = new("TDD_VCO_RX_OFF_2", 'hc4, this);
      this.TDD_VCO_TX_ON_2_R = new("TDD_VCO_TX_ON_2", 'hc8, this);
      this.TDD_VCO_TX_OFF_2_R = new("TDD_VCO_TX_OFF_2", 'hcc, this);
      this.TDD_RX_ON_2_R = new("TDD_RX_ON_2", 'hd0, this);
      this.TDD_RX_OFF_2_R = new("TDD_RX_OFF_2", 'hd4, this);
      this.TDD_TX_ON_2_R = new("TDD_TX_ON_2", 'hd8, this);
      this.TDD_TX_OFF_2_R = new("TDD_TX_OFF_2", 'hdc, this);
      this.TDD_RX_DP_ON_2_R = new("TDD_RX_DP_ON_2", 'he0, this);
      this.TDD_RX_DP_OFF_2_R = new("TDD_RX_DP_OFF_2", 'he4, this);
      this.TDD_TX_DP_ON_2_R = new("TDD_TX_DP_ON_2", 'he8, this);
      this.TDD_TX_DP_OFF_2_R = new("TDD_TX_DP_OFF_2", 'hec, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_tdd_trans

endpackage: adi_regmap_tdd_trans_pkg
