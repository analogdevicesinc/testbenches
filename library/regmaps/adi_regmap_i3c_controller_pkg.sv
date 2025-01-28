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

package adi_regmap_i3c_controller_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_i3c_controller extends adi_regmap;

    /* I3C Controller (i3c_controller_host_interface) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_MAJOR_F;
      field_base VERSION_MINOR_F;
      field_base VERSION_PATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_MAJOR_F = new("VERSION_MAJOR", 31, 16, RO, 'h0, this);
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h1, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VERSION_CLASS

    class DEVICE_ID_CLASS extends register_base;
      field_base DEVICE_ID_F;

      function new(
        input string name,
        input int address,
        input int ID,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DEVICE_ID_F = new("DEVICE_ID", 31, 0, RO, ID, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DEVICE_ID_CLASS

    class SCRATCH_CLASS extends register_base;
      field_base SCRATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SCRATCH_CLASS

    class ENABLE_CLASS extends register_base;
      field_base ENABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ENABLE_F = new("ENABLE", 0, 0, RW, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ENABLE_CLASS

    class IRQ_MASK_CLASS extends register_base;
      field_base DAA_PENDING_F;
      field_base IBI_PENDING_F;
      field_base CMDR_PENDING_F;
      field_base IBI_ALMOST_FULL_F;
      field_base SDI_ALMOST_FULL_F;
      field_base SDO_ALMOST_EMPTY_F;
      field_base CMDR_ALMOST_FULL_F;
      field_base CMD_ALMOST_EMPTY_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DAA_PENDING_F = new("DAA_PENDING", 7, 7, RW, 'h0, this);
        this.IBI_PENDING_F = new("IBI_PENDING", 6, 6, RW, 'h0, this);
        this.CMDR_PENDING_F = new("CMDR_PENDING", 5, 5, RW, 'h0, this);
        this.IBI_ALMOST_FULL_F = new("IBI_ALMOST_FULL", 4, 4, RW, 'h0, this);
        this.SDI_ALMOST_FULL_F = new("SDI_ALMOST_FULL", 3, 3, RW, 'h0, this);
        this.SDO_ALMOST_EMPTY_F = new("SDO_ALMOST_EMPTY", 2, 2, RW, 'h0, this);
        this.CMDR_ALMOST_FULL_F = new("CMDR_ALMOST_FULL", 1, 1, RW, 'h0, this);
        this.CMD_ALMOST_EMPTY_F = new("CMD_ALMOST_EMPTY", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_MASK_CLASS

    class IRQ_PENDING_CLASS extends register_base;
      field_base IRQ_PENDING_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IRQ_PENDING_F = new("IRQ_PENDING", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_PENDING_CLASS

    class IRQ_SOURCE_CLASS extends register_base;
      field_base IRQ_SOURCE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IRQ_SOURCE_F = new("IRQ_SOURCE", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_SOURCE_CLASS

    class CMD_FIFO_ROOM_CLASS extends register_base;
      field_base CMD_FIFO_ROOM_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CMD_FIFO_ROOM_F = new("CMD_FIFO_ROOM", 31, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CMD_FIFO_ROOM_CLASS

    class CMDR_FIFO_LEVEL_CLASS extends register_base;
      field_base CMDR_FIFO_LEVEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CMDR_FIFO_LEVEL_F = new("CMDR_FIFO_LEVEL", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CMDR_FIFO_LEVEL_CLASS

    class SDO_FIFO_ROOM_CLASS extends register_base;
      field_base SDO_FIFO_ROOM_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDO_FIFO_ROOM_F = new("SDO_FIFO_ROOM", 31, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SDO_FIFO_ROOM_CLASS

    class SDI_FIFO_LEVEL_CLASS extends register_base;
      field_base SDI_FIFO_LEVEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDI_FIFO_LEVEL_F = new("SDI_FIFO_LEVEL", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SDI_FIFO_LEVEL_CLASS

    class IBI_FIFO_LEVEL_CLASS extends register_base;
      field_base IBI_FIFO_LEVEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IBI_FIFO_LEVEL_F = new("IBI_FIFO_LEVEL", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IBI_FIFO_LEVEL_CLASS

    class CMD_FIFO_CLASS extends register_base;
      field_base CMD_IS_CCC_F;
      field_base CMD_BCAST_HEADER_F;
      field_base CMD_SR_F;
      field_base CMD_BUFFER_LENGHT_F;
      field_base CMD_DA_F;
      field_base CMD_RNW_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CMD_IS_CCC_F = new("CMD_IS_CCC", 22, 22, WO, 'hXXXXXXXX, this);
        this.CMD_BCAST_HEADER_F = new("CMD_BCAST_HEADER", 21, 21, WO, 'hXXXXXXXX, this);
        this.CMD_SR_F = new("CMD_SR", 20, 20, WO, 'hXXXXXXXX, this);
        this.CMD_BUFFER_LENGHT_F = new("CMD_BUFFER_LENGHT", 19, 8, WO, 'hXXXXXXXX, this);
        this.CMD_DA_F = new("CMD_DA", 7, 1, WO, 'hXXXXXXXX, this);
        this.CMD_RNW_F = new("CMD_RNW", 0, 0, WO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CMD_FIFO_CLASS

    class CMDR_FIFO_CLASS extends register_base;
      field_base CMDR_FIFO_ERROR_F;
      field_base CMDR_FIFO_BUFFER_LENGTH_F;
      field_base CMDR_FIFO_SYNC_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CMDR_FIFO_ERROR_F = new("CMDR_FIFO_ERROR", 23, 0, RO, 'hXXXXXXXX, this);
        this.CMDR_FIFO_BUFFER_LENGTH_F = new("CMDR_FIFO_BUFFER_LENGTH", 19, 8, RO, 'hXXXXXXXX, this);
        this.CMDR_FIFO_SYNC_F = new("CMDR_FIFO_SYNC", 7, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CMDR_FIFO_CLASS

    class SDO_FIFO_CLASS extends register_base;
      field_base SDO_FIFO_BYTE_3_F;
      field_base SDO_FIFO_BYTE_2_F;
      field_base SDO_FIFO_BYTE_1_F;
      field_base SDO_FIFO_BYTE_0_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDO_FIFO_BYTE_3_F = new("SDO_FIFO_BYTE_3", 31, 24, RO, 'hXXXXXXXX, this);
        this.SDO_FIFO_BYTE_2_F = new("SDO_FIFO_BYTE_2", 23, 16, RO, 'hXXXXXXXX, this);
        this.SDO_FIFO_BYTE_1_F = new("SDO_FIFO_BYTE_1", 15, 8, RO, 'hXXXXXXXX, this);
        this.SDO_FIFO_BYTE_0_F = new("SDO_FIFO_BYTE_0", 7, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SDO_FIFO_CLASS

    class SDI_FIFO_CLASS extends register_base;
      field_base SDI_FIFO_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDI_FIFO_F = new("SDI_FIFO", 31, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SDI_FIFO_CLASS

    class IBI_FIFO_CLASS extends register_base;
      field_base IBI_FIFO_DA_F;
      field_base IBI_FIFO_MDB_F;
      field_base IBI_FIFO_SYNC_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IBI_FIFO_DA_F = new("IBI_FIFO_DA", 23, 17, RO, 'hXXXXXXXX, this);
        this.IBI_FIFO_MDB_F = new("IBI_FIFO_MDB", 15, 8, RO, 'hXXXXXXXX, this);
        this.IBI_FIFO_SYNC_F = new("IBI_FIFO_SYNC", 7, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IBI_FIFO_CLASS

    class FIFO_STATUS_CLASS extends register_base;
      field_base SDI_EMPTY_F;
      field_base IBI_EMPTY_F;
      field_base CMDR_EMPTY_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDI_EMPTY_F = new("SDI_EMPTY", 2, 2, RO, 'h1, this);
        this.IBI_EMPTY_F = new("IBI_EMPTY", 1, 1, RO, 'h1, this);
        this.CMDR_EMPTY_F = new("CMDR_EMPTY", 0, 0, RO, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FIFO_STATUS_CLASS

    class OPS_CLASS extends register_base;
      field_base OPS_STATUS_NOP_F;
      field_base OPS_SPEED_GRADE_F;
      field_base OPS_OFFLOAD_LENGTH_F;
      field_base OPS_MODE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OPS_STATUS_NOP_F = new("OPS_STATUS_NOP", 7, 7, RO, 'h0, this);
        this.OPS_SPEED_GRADE_F = new("OPS_SPEED_GRADE", 6, 5, RW, 'h0, this);
        this.OPS_OFFLOAD_LENGTH_F = new("OPS_OFFLOAD_LENGTH", 4, 1, RW, 'h0, this);
        this.OPS_MODE_F = new("OPS_MODE", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OPS_CLASS

    class IBI_CONFIG_CLASS extends register_base;
      field_base IBI_CONFIG_LISTEN_F;
      field_base IBI_CONFIG_ENABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IBI_CONFIG_LISTEN_F = new("IBI_CONFIG_LISTEN", 1, 1, WO, 'h0, this);
        this.IBI_CONFIG_ENABLE_F = new("IBI_CONFIG_ENABLE", 0, 0, WO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IBI_CONFIG_CLASS

    class DEV_CHAR_CLASS extends register_base;
      field_base DEV_CHAR_ADDR_F;
      field_base DEV_CHAR_WEN_F;
      field_base DEV_CHAR_HAS_IBI_PAYLOAD_F;
      field_base DEV_CHAR_IS_IBI_CAPABLE_F;
      field_base DEV_CHAR_IS_ATTACHED_F;
      field_base DEV_CHAR_IS_I2C_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DEV_CHAR_ADDR_F = new("DEV_CHAR_ADDR", 15, 9, RW, 'h0, this);
        this.DEV_CHAR_WEN_F = new("DEV_CHAR_WEN", 8, 8, WO, 'hXXXXXXXX, this);
        this.DEV_CHAR_HAS_IBI_PAYLOAD_F = new("DEV_CHAR_HAS_IBI_PAYLOAD", 3, 3, RW, 'h0, this);
        this.DEV_CHAR_IS_IBI_CAPABLE_F = new("DEV_CHAR_IS_IBI_CAPABLE", 2, 2, RW, 'h0, this);
        this.DEV_CHAR_IS_ATTACHED_F = new("DEV_CHAR_IS_ATTACHED", 1, 1, RW, 'h0, this);
        this.DEV_CHAR_IS_I2C_F = new("DEV_CHAR_IS_I2C", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DEV_CHAR_CLASS

    class OFFLOAD_CMD_n_CLASS extends register_base;
      field_base OFFLOAD_CMD_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OFFLOAD_CMD_F = new("OFFLOAD_CMD", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OFFLOAD_CMD_n_CLASS

    class OFFLOAD_SDO_n_CLASS extends register_base;
      field_base OFFLOAD_SDO_BYTE_3_F;
      field_base OFFLOAD_SDO_BYTE_2_F;
      field_base OFFLOAD_SDO_BYTE_1_F;
      field_base OFFLOAD_SDO_BYTE_0_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OFFLOAD_SDO_BYTE_3_F = new("OFFLOAD_SDO_BYTE_3", 31, 24, RO, 'h0, this);
        this.OFFLOAD_SDO_BYTE_2_F = new("OFFLOAD_SDO_BYTE_2", 23, 16, RO, 'h0, this);
        this.OFFLOAD_SDO_BYTE_1_F = new("OFFLOAD_SDO_BYTE_1", 15, 8, RO, 'h0, this);
        this.OFFLOAD_SDO_BYTE_0_F = new("OFFLOAD_SDO_BYTE_0", 7, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OFFLOAD_SDO_n_CLASS

    VERSION_CLASS VERSION_R;
    DEVICE_ID_CLASS DEVICE_ID_R;
    SCRATCH_CLASS SCRATCH_R;
    ENABLE_CLASS ENABLE_R;
    IRQ_MASK_CLASS IRQ_MASK_R;
    IRQ_PENDING_CLASS IRQ_PENDING_R;
    IRQ_SOURCE_CLASS IRQ_SOURCE_R;
    CMD_FIFO_ROOM_CLASS CMD_FIFO_ROOM_R;
    CMDR_FIFO_LEVEL_CLASS CMDR_FIFO_LEVEL_R;
    SDO_FIFO_ROOM_CLASS SDO_FIFO_ROOM_R;
    SDI_FIFO_LEVEL_CLASS SDI_FIFO_LEVEL_R;
    IBI_FIFO_LEVEL_CLASS IBI_FIFO_LEVEL_R;
    CMD_FIFO_CLASS CMD_FIFO_R;
    CMDR_FIFO_CLASS CMDR_FIFO_R;
    SDO_FIFO_CLASS SDO_FIFO_R;
    SDI_FIFO_CLASS SDI_FIFO_R;
    IBI_FIFO_CLASS IBI_FIFO_R;
    FIFO_STATUS_CLASS FIFO_STATUS_R;
    OPS_CLASS OPS_R;
    IBI_CONFIG_CLASS IBI_CONFIG_R;
    DEV_CHAR_CLASS DEV_CHAR_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_0_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_1_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_2_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_3_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_4_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_5_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_6_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_7_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_8_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_9_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_10_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_11_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_12_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_13_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_14_R;
    OFFLOAD_CMD_n_CLASS OFFLOAD_CMD_15_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_0_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_1_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_2_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_3_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_4_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_5_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_6_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_7_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_8_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_9_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_10_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_11_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_12_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_13_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_14_R;
    OFFLOAD_SDO_n_CLASS OFFLOAD_SDO_15_R;

    function new(
      input string name,
      input int address,
      input int ID,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.DEVICE_ID_R = new("DEVICE_ID", 'h4, ID, this);
      this.SCRATCH_R = new("SCRATCH", 'h8, this);
      this.ENABLE_R = new("ENABLE", 'h40, this);
      this.IRQ_MASK_R = new("IRQ_MASK", 'h80, this);
      this.IRQ_PENDING_R = new("IRQ_PENDING", 'h84, this);
      this.IRQ_SOURCE_R = new("IRQ_SOURCE", 'h88, this);
      this.CMD_FIFO_ROOM_R = new("CMD_FIFO_ROOM", 'hc0, this);
      this.CMDR_FIFO_LEVEL_R = new("CMDR_FIFO_LEVEL", 'hc4, this);
      this.SDO_FIFO_ROOM_R = new("SDO_FIFO_ROOM", 'hc8, this);
      this.SDI_FIFO_LEVEL_R = new("SDI_FIFO_LEVEL", 'hcc, this);
      this.IBI_FIFO_LEVEL_R = new("IBI_FIFO_LEVEL", 'hd0, this);
      this.CMD_FIFO_R = new("CMD_FIFO", 'hd4, this);
      this.CMDR_FIFO_R = new("CMDR_FIFO", 'hd8, this);
      this.SDO_FIFO_R = new("SDO_FIFO", 'hdc, this);
      this.SDI_FIFO_R = new("SDI_FIFO", 'he0, this);
      this.IBI_FIFO_R = new("IBI_FIFO", 'he4, this);
      this.FIFO_STATUS_R = new("FIFO_STATUS", 'he8, this);
      this.OPS_R = new("OPS", 'h100, this);
      this.IBI_CONFIG_R = new("IBI_CONFIG", 'h140, this);
      this.DEV_CHAR_R = new("DEV_CHAR", 'h180, this);
      this.OFFLOAD_CMD_0_R = new("OFFLOAD_CMD_0", 'h2c0, this);
      this.OFFLOAD_CMD_1_R = new("OFFLOAD_CMD_1", 'h2c4, this);
      this.OFFLOAD_CMD_2_R = new("OFFLOAD_CMD_2", 'h2c8, this);
      this.OFFLOAD_CMD_3_R = new("OFFLOAD_CMD_3", 'h2cc, this);
      this.OFFLOAD_CMD_4_R = new("OFFLOAD_CMD_4", 'h2d0, this);
      this.OFFLOAD_CMD_5_R = new("OFFLOAD_CMD_5", 'h2d4, this);
      this.OFFLOAD_CMD_6_R = new("OFFLOAD_CMD_6", 'h2d8, this);
      this.OFFLOAD_CMD_7_R = new("OFFLOAD_CMD_7", 'h2dc, this);
      this.OFFLOAD_CMD_8_R = new("OFFLOAD_CMD_8", 'h2e0, this);
      this.OFFLOAD_CMD_9_R = new("OFFLOAD_CMD_9", 'h2e4, this);
      this.OFFLOAD_CMD_10_R = new("OFFLOAD_CMD_10", 'h2e8, this);
      this.OFFLOAD_CMD_11_R = new("OFFLOAD_CMD_11", 'h2ec, this);
      this.OFFLOAD_CMD_12_R = new("OFFLOAD_CMD_12", 'h2f0, this);
      this.OFFLOAD_CMD_13_R = new("OFFLOAD_CMD_13", 'h2f4, this);
      this.OFFLOAD_CMD_14_R = new("OFFLOAD_CMD_14", 'h2f8, this);
      this.OFFLOAD_CMD_15_R = new("OFFLOAD_CMD_15", 'h2fc, this);
      this.OFFLOAD_SDO_0_R = new("OFFLOAD_SDO_0", 'h300, this);
      this.OFFLOAD_SDO_1_R = new("OFFLOAD_SDO_1", 'h304, this);
      this.OFFLOAD_SDO_2_R = new("OFFLOAD_SDO_2", 'h308, this);
      this.OFFLOAD_SDO_3_R = new("OFFLOAD_SDO_3", 'h30c, this);
      this.OFFLOAD_SDO_4_R = new("OFFLOAD_SDO_4", 'h310, this);
      this.OFFLOAD_SDO_5_R = new("OFFLOAD_SDO_5", 'h314, this);
      this.OFFLOAD_SDO_6_R = new("OFFLOAD_SDO_6", 'h318, this);
      this.OFFLOAD_SDO_7_R = new("OFFLOAD_SDO_7", 'h31c, this);
      this.OFFLOAD_SDO_8_R = new("OFFLOAD_SDO_8", 'h320, this);
      this.OFFLOAD_SDO_9_R = new("OFFLOAD_SDO_9", 'h324, this);
      this.OFFLOAD_SDO_10_R = new("OFFLOAD_SDO_10", 'h328, this);
      this.OFFLOAD_SDO_11_R = new("OFFLOAD_SDO_11", 'h32c, this);
      this.OFFLOAD_SDO_12_R = new("OFFLOAD_SDO_12", 'h330, this);
      this.OFFLOAD_SDO_13_R = new("OFFLOAD_SDO_13", 'h334, this);
      this.OFFLOAD_SDO_14_R = new("OFFLOAD_SDO_14", 'h338, this);
      this.OFFLOAD_SDO_15_R = new("OFFLOAD_SDO_15", 'h33c, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_i3c_controller

endpackage: adi_regmap_i3c_controller_pkg
