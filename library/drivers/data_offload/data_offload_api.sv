// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024 - 2025 Analog Devices, Inc. All rights reserved.
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

`include "utils.svh"

package data_offload_api_pkg;

  import logger_pkg::*;
  import adi_regmap_pkg::*;
  import reg_accessor_pkg::*;
  import adi_peripheral_pkg::*;
  import adi_regmap_data_offload_pkg::*;


  class data_offload_api #(int AUTO_BRINGUP, int HAS_BYPASS, int ID, int MEM_SIZE_LOG2, int MEM_TYPE, int TX_OR_RXN_PATH) extends adi_peripheral;

    adi_regmap_data_offload #(AUTO_BRINGUP, HAS_BYPASS, ID, MEM_SIZE_LOG2, MEM_TYPE, TX_OR_RXN_PATH) regmap;

    // -----------------
    function new(
      input string name,
      input m_axi_sequencer_base bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, bus, base_address, parent);

      this.regmap = new("Regmap", this);
    endfunction

    // -----------------
    task sanity_test();
      this.axi_verify(this.regmap.VERSION_R.get_address(), this.regmap.VERSION_R.get_reset_value());
      `INFO(("Version register current value: %h", this.regmap.VERSION_R.get()));
      this.axi_read_reg(this.regmap.VERSION_R);
      `INFO(("Version register updated value: %h", this.regmap.VERSION_R.get()));
    endtask

    // -----------------
    task set_transfer_length(input int length);
      this.regmap.TRANSFER_LENGTH_R.PARTIAL_LENGTH_F.set(length-1);
      this.axi_write_reg(this.regmap.TRANSFER_LENGTH_R);
    endtask

    // -----------------
    task enable_oneshot_mode();
      this.regmap.CONTROL_R.ONESHOT_EN_F.set(1);
      this.axi_write_reg(this.regmap.CONTROL_R);
    endtask

    // -----------------
    task disable_oneshot_mode();
      this.regmap.CONTROL_R.ONESHOT_EN_F.set(0);
      this.axi_write_reg(this.regmap.CONTROL_R);
    endtask

    // -----------------
    task enable_bypass_mode();
      this.regmap.CONTROL_R.OFFLOAD_BYPASS_F.set(1);
      this.axi_write_reg(this.regmap.CONTROL_R);
    endtask

    // -----------------
    task disable_bypass_mode();
      this.regmap.CONTROL_R.OFFLOAD_BYPASS_F.set(0);
      this.axi_write_reg(this.regmap.CONTROL_R);
    endtask

    // -----------------
    task assert_reset();
      this.regmap.RESETN_OFFLOAD_R.RESETN_F.set(0);
      this.axi_write_reg(this.regmap.RESETN_OFFLOAD_R);
    endtask

    // -----------------
    task deassert_reset();
      this.regmap.RESETN_OFFLOAD_R.RESETN_F.set(1);
      this.axi_write_reg(this.regmap.RESETN_OFFLOAD_R);
    endtask

  endclass

endpackage
