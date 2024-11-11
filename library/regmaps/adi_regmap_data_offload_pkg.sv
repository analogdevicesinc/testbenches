// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2024 (c) Analog Devices, Inc. All rights reserved.
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
/* Nov 08 16:38:17 2024 v0.3.49 */

package adi_regmap_data_offload_pkg;

  import logger_pkg::*;
  import adi_regmap_pkg::*;

  class adi_regmap_data_offload #(int AUTO_BRINGUP, int HAS_BYPASS, int ID, int MEM_SIZE_LOG2, int MEM_TYPE, int TX_OR_RXN_PATH) extends adi_component;

    /* Data Offload Engine (data_offload) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_MAJOR_F;
      field_base VERSION_MINOR_F;
      field_base VERSION_PATCH_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.VERSION_MAJOR_F = new("VERSION_MAJOR", 31, 16, RO, 'h1, this);
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h0, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h61, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class PERIPHERAL_ID_CLASS #(int ID) extends register_base;
      field_base PERIPHERAL_ID_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.PERIPHERAL_ID_F = new("PERIPHERAL_ID", 31, 0, RO, ID, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class SCRATCH_CLASS extends register_base;
      field_base SCRATCH_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class IDENTIFICATION_CLASS extends register_base;
      field_base IDENTIFICATION_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.IDENTIFICATION_F = new("IDENTIFICATION", 31, 0, RO, 'h44414f46, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class SYNTHESIS_CONFIG_1_CLASS #(int HAS_BYPASS, int MEM_TYPE, int TX_OR_RXN_PATH) extends register_base;
      field_base HAS_BYPASS_F;
      field_base TX_OR_RXN_PATH_F;
      field_base MEMORY_TYPE_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.HAS_BYPASS_F = new("HAS_BYPASS", 2, 2, RO, HAS_BYPASS, this);
        this.TX_OR_RXN_PATH_F = new("TX_OR_RXN_PATH", 1, 1, RO, TX_OR_RXN_PATH, this);
        this.MEMORY_TYPE_F = new("MEMORY_TYPE", 0, 0, RO, MEM_TYPE, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class SYNTHESIS_CONFIG_2_CLASS #(int MEM_SIZE_LOG2) extends register_base;
      field_base MEM_SIZE_LSB_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.MEM_SIZE_LSB_F = new("MEM_SIZE_LSB", 31, 0, RO, 1<<MEM_SIZE_LOG2, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class SYNTHESIS_CONFIG_3_CLASS #(int MEM_SIZE_LOG2) extends register_base;
      field_base MEM_SIZE_MSB_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.MEM_SIZE_MSB_F = new("MEM_SIZE_MSB", 1, 0, RO, (1<<MEM_SIZE_LOG2)>>32, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class TRANSFER_LENGTH_CLASS #(int MEM_SIZE_LOG2) extends register_base;
      field_base TRANSFER_LENGTH_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.TRANSFER_LENGTH_F = new("TRANSFER_LENGTH", 31, 0, RW, (2**MEM_SIZE_LOG2-1)>>6, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class MEM_PHY_STATE_CLASS extends register_base;
      field_base UNDERFLOW_F;
      field_base OVERFLOW_F;
      field_base CALIB_COMPLETE_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.UNDERFLOW_F = new("UNDERFLOW", 5, 5, RW1C, 'h0, this);
        this.OVERFLOW_F = new("OVERFLOW", 4, 4, RW1C, 'h0, this);
        this.CALIB_COMPLETE_F = new("CALIB_COMPLETE", 0, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class RESET_OFFLOAD_CLASS #(int AUTO_BRINGUP) extends register_base;
      field_base RESETN_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.RESETN_F = new("RESETN", 0, 0, RW, AUTO_BRINGUP, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class CONTROL_CLASS #(int TX_OR_RXN_PATH) extends register_base;
      field_base ONESHOT_EN_F;
      field_base OFFLOAD_BYPASS_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.ONESHOT_EN_F = new("ONESHOT_EN", 1, 1, RW, ~TX_OR_RXN_PATH, this);
        this.OFFLOAD_BYPASS_F = new("OFFLOAD_BYPASS", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class SYNC_TRIGGER_CLASS extends register_base;
      field_base SYNC_TRIGGER_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.SYNC_TRIGGER_F = new("SYNC_TRIGGER", 0, 0, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class SYNC_CONFIG_CLASS extends register_base;
      field_base SYNC_CONFIG_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.SYNC_CONFIG_F = new("SYNC_CONFIG", 1, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    class FSM_BDG_CLASS extends register_base;
      field_base FSM_STATE_READ_F;
      field_base FSM_STATE_WRITE_F;

      function new(
        input string name,
        input int address,
        input adi_component parent = null);

        super.new(name, address, parent);

        this.FSM_STATE_READ_F = new("FSM_STATE_READ", 11, 8, RO, 'hXXXXXXXX, this);
        this.FSM_STATE_WRITE_F = new("FSM_STATE_WRITE", 4, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass

    VERSION_CLASS VERSION_R;
    PERIPHERAL_ID_CLASS #(ID) PERIPHERAL_ID_R;
    SCRATCH_CLASS SCRATCH_R;
    IDENTIFICATION_CLASS IDENTIFICATION_R;
    SYNTHESIS_CONFIG_1_CLASS #(HAS_BYPASS, MEM_TYPE, TX_OR_RXN_PATH) SYNTHESIS_CONFIG_1_R;
    SYNTHESIS_CONFIG_2_CLASS #(MEM_SIZE_LOG2) SYNTHESIS_CONFIG_2_R;
    SYNTHESIS_CONFIG_3_CLASS #(MEM_SIZE_LOG2) SYNTHESIS_CONFIG_3_R;
    TRANSFER_LENGTH_CLASS #(MEM_SIZE_LOG2) TRANSFER_LENGTH_R;
    MEM_PHY_STATE_CLASS MEM_PHY_STATE_R;
    RESET_OFFLOAD_CLASS #(AUTO_BRINGUP) RESET_OFFLOAD_R;
    CONTROL_CLASS #(TX_OR_RXN_PATH) CONTROL_R;
    SYNC_TRIGGER_CLASS SYNC_TRIGGER_R;
    SYNC_CONFIG_CLASS SYNC_CONFIG_R;
    FSM_BDG_CLASS FSM_BDG_R;

    function new(
      input string name,
      input adi_component parent = null);

      super.new(name, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.PERIPHERAL_ID_R = new("PERIPHERAL_ID", 'h4, this);
      this.SCRATCH_R = new("SCRATCH", 'h8, this);
      this.IDENTIFICATION_R = new("IDENTIFICATION", 'hc, this);
      this.SYNTHESIS_CONFIG_1_R = new("SYNTHESIS_CONFIG_1", 'h10, this);
      this.SYNTHESIS_CONFIG_2_R = new("SYNTHESIS_CONFIG_2", 'h14, this);
      this.SYNTHESIS_CONFIG_3_R = new("SYNTHESIS_CONFIG_3", 'h18, this);
      this.TRANSFER_LENGTH_R = new("TRANSFER_LENGTH", 'h1c, this);
      this.MEM_PHY_STATE_R = new("MEM_PHY_STATE", 'h80, this);
      this.RESET_OFFLOAD_R = new("RESET_OFFLOAD", 'h84, this);
      this.CONTROL_R = new("CONTROL", 'h88, this);
      this.SYNC_TRIGGER_R = new("SYNC_TRIGGER", 'h100, this);
      this.SYNC_CONFIG_R = new("SYNC_CONFIG", 'h104, this);
      this.FSM_BDG_R = new("FSM_BDG", 'h200, this);
    endfunction: new;

  endclass;

endpackage
