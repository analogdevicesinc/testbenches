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

package adi_regmap_spi_engine_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_spi_engine extends adi_regmap;

    /* SPI Engine (axi_spi_engine) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_MAJOR_F;
      field_base VERSION_MINOR_F;
      field_base VERSION_PATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_MAJOR_F = new("VERSION_MAJOR", 31, 16, RO, 'h1, this);
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h4, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VERSION_CLASS

    class PERIPHERAL_ID_CLASS extends register_base;
      field_base PERIPHERAL_ID_F;

      function new(
        input string name,
        input int address,
        input int ID,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PERIPHERAL_ID_F = new("PERIPHERAL_ID", 31, 0, RO, ID, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PERIPHERAL_ID_CLASS

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

    class DATA_WIDTH_CLASS extends register_base;
      field_base NUM_OF_SDI_F;
      field_base DATA_WIDTH_F;

      function new(
        input string name,
        input int address,
        input int DATA_WIDTH,
        input int NUM_OF_SDI,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.NUM_OF_SDI_F = new("NUM_OF_SDI", 7, 4, RO, NUM_OF_SDI, this);
        this.DATA_WIDTH_F = new("DATA_WIDTH", 3, 0, RO, DATA_WIDTH, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DATA_WIDTH_CLASS

    class OFFLOAD_MEM_ADDR_WIDTH_CLASS extends register_base;
      field_base SDO_MEM_ADDRESS_WIDTH_F;
      field_base CMD_MEM_ADDRESS_WIDTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDO_MEM_ADDRESS_WIDTH_F = new("SDO_MEM_ADDRESS_WIDTH", 15, 8, RO, 'h4, this);
        this.CMD_MEM_ADDRESS_WIDTH_F = new("CMD_MEM_ADDRESS_WIDTH", 7, 0, RO, 'h4, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OFFLOAD_MEM_ADDR_WIDTH_CLASS

    class FIFO_ADDR_WIDTH_CLASS extends register_base;
      field_base SDI_FIFO_ADDRESS_WIDTH_F;
      field_base SDO_FIFO_ADDRESS_WIDTH_F;
      field_base SYNC_FIFO_ADDRESS_WIDTH_F;
      field_base CMD_FIFO_ADDRESS_WIDTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDI_FIFO_ADDRESS_WIDTH_F = new("SDI_FIFO_ADDRESS_WIDTH", 31, 24, RO, 'h5, this);
        this.SDO_FIFO_ADDRESS_WIDTH_F = new("SDO_FIFO_ADDRESS_WIDTH", 23, 16, RO, 'h5, this);
        this.SYNC_FIFO_ADDRESS_WIDTH_F = new("SYNC_FIFO_ADDRESS_WIDTH", 15, 8, RO, 'h4, this);
        this.CMD_FIFO_ADDRESS_WIDTH_F = new("CMD_FIFO_ADDRESS_WIDTH", 7, 0, RO, 'h4, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FIFO_ADDR_WIDTH_CLASS

    class ENABLE_CLASS extends register_base;
      field_base ENABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ENABLE_F = new("ENABLE", 31, 0, RW, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ENABLE_CLASS

    class IRQ_MASK_CLASS extends register_base;
      field_base CMD_ALMOST_EMPTY_F;
      field_base SDO_ALMOST_EMPTY_F;
      field_base SDI_ALMOST_FULL_F;
      field_base SYNC_EVENT_F;
      field_base OFFLOAD_SYNC_ID_PENDING_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CMD_ALMOST_EMPTY_F = new("CMD_ALMOST_EMPTY", 0, 0, RW, 'h0, this);
        this.SDO_ALMOST_EMPTY_F = new("SDO_ALMOST_EMPTY", 1, 1, RW, 'h0, this);
        this.SDI_ALMOST_FULL_F = new("SDI_ALMOST_FULL", 2, 2, RW, 'h0, this);
        this.SYNC_EVENT_F = new("SYNC_EVENT", 3, 3, RW, 'h0, this);
        this.OFFLOAD_SYNC_ID_PENDING_F = new("OFFLOAD_SYNC_ID_PENDING", 4, 4, RW, 'h0, this);

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

        this.IRQ_PENDING_F = new("IRQ_PENDING", 31, 0, RW1C, 'h0, this);

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

    class SYNC_ID_CLASS extends register_base;
      field_base SYNC_ID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SYNC_ID_F = new("SYNC_ID", 31, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SYNC_ID_CLASS

    class OFFLOAD_SYNC_ID_CLASS extends register_base;
      field_base OFFLOAD_SYNC_ID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OFFLOAD_SYNC_ID_F = new("OFFLOAD_SYNC_ID", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OFFLOAD_SYNC_ID_CLASS

    class CMD_FIFO_ROOM_CLASS extends register_base;
      field_base CMD_FIFO_ROOM_F;

      function new(
        input string name,
        input int address,
        input int CMD_FIFO_ADDRESS_WIDTH,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CMD_FIFO_ROOM_F = new("CMD_FIFO_ROOM", 31, 0, RO, $clog2((2**CMD_FIFO_ADDRESS_WIDTH)-1), this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CMD_FIFO_ROOM_CLASS

    class SDO_FIFO_ROOM_CLASS extends register_base;
      field_base SDO_FIFO_ROOM_F;

      function new(
        input string name,
        input int address,
        input int SDO_FIFO_ADDRESS_WIDTH,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDO_FIFO_ROOM_F = new("SDO_FIFO_ROOM", 31, 0, RO, $clog2((2**SDO_FIFO_ADDRESS_WIDTH)-1), this);

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

    class CMD_FIFO_CLASS extends register_base;
      field_base CMD_FIFO_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CMD_FIFO_F = new("CMD_FIFO", 31, 0, WO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CMD_FIFO_CLASS

    class SDO_FIFO_CLASS extends register_base;
      field_base SDO_FIFO_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDO_FIFO_F = new("SDO_FIFO", 31, 0, WO, 'hXXXXXXXX, this);

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

    class SDI_FIFO_MSB_CLASS extends register_base;
      field_base SDI_FIFO_MSB_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDI_FIFO_MSB_F = new("SDI_FIFO_MSB", 31, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SDI_FIFO_MSB_CLASS

    class SDI_FIFO_PEEK_CLASS extends register_base;
      field_base SDI_FIFO_PEEK_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SDI_FIFO_PEEK_F = new("SDI_FIFO_PEEK", 31, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SDI_FIFO_PEEK_CLASS

    class OFFLOAD0_EN_CLASS extends register_base;
      field_base OFFLOAD0_EN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OFFLOAD0_EN_F = new("OFFLOAD0_EN", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OFFLOAD0_EN_CLASS

    class OFFLOAD0_STATUS_CLASS extends register_base;
      field_base OFFLOAD0_STATUS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OFFLOAD0_STATUS_F = new("OFFLOAD0_STATUS", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OFFLOAD0_STATUS_CLASS

    class OFFLOAD0_MEM_RESET_CLASS extends register_base;
      field_base OFFLOAD0_MEM_RESET_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OFFLOAD0_MEM_RESET_F = new("OFFLOAD0_MEM_RESET", 31, 0, WO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OFFLOAD0_MEM_RESET_CLASS

    class OFFLOAD0_CDM_FIFO_CLASS extends register_base;
      field_base OFFLOAD0_CDM_FIFO_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OFFLOAD0_CDM_FIFO_F = new("OFFLOAD0_CDM_FIFO", 31, 0, WO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OFFLOAD0_CDM_FIFO_CLASS

    class OFFLOAD0_SDO_FIFO_CLASS extends register_base;
      field_base OFFLOAD0_SDO_FIFO_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OFFLOAD0_SDO_FIFO_F = new("OFFLOAD0_SDO_FIFO", 31, 0, WO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OFFLOAD0_SDO_FIFO_CLASS

    class CFG_INFO_0_CLASS extends register_base;
      field_base CFG_INFO_0_F;

      function new(
        input string name,
        input int address,
        input int CFG_INFO_0,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CFG_INFO_0_F = new("CFG_INFO_0", 31, 0, RO, CFG_INFO_0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CFG_INFO_0_CLASS

    class CFG_INFO_1_CLASS extends register_base;
      field_base CFG_INFO_1_F;

      function new(
        input string name,
        input int address,
        input int CFG_INFO_1,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CFG_INFO_1_F = new("CFG_INFO_1", 31, 0, RO, CFG_INFO_1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CFG_INFO_1_CLASS

    class CFG_INFO_2_CLASS extends register_base;
      field_base CFG_INFO_2_F;

      function new(
        input string name,
        input int address,
        input int CFG_INFO_2,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CFG_INFO_2_F = new("CFG_INFO_2", 31, 0, RO, CFG_INFO_2, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CFG_INFO_2_CLASS

    class CFG_INFO_3_CLASS extends register_base;
      field_base CFG_INFO_4_F;

      function new(
        input string name,
        input int address,
        input int CFG_INFO_3,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CFG_INFO_4_F = new("CFG_INFO_4", 31, 0, RO, CFG_INFO_3, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CFG_INFO_3_CLASS

    VERSION_CLASS VERSION_R;
    PERIPHERAL_ID_CLASS PERIPHERAL_ID_R;
    SCRATCH_CLASS SCRATCH_R;
    DATA_WIDTH_CLASS DATA_WIDTH_R;
    OFFLOAD_MEM_ADDR_WIDTH_CLASS OFFLOAD_MEM_ADDR_WIDTH_R;
    FIFO_ADDR_WIDTH_CLASS FIFO_ADDR_WIDTH_R;
    ENABLE_CLASS ENABLE_R;
    IRQ_MASK_CLASS IRQ_MASK_R;
    IRQ_PENDING_CLASS IRQ_PENDING_R;
    IRQ_SOURCE_CLASS IRQ_SOURCE_R;
    SYNC_ID_CLASS SYNC_ID_R;
    OFFLOAD_SYNC_ID_CLASS OFFLOAD_SYNC_ID_R;
    CMD_FIFO_ROOM_CLASS CMD_FIFO_ROOM_R;
    SDO_FIFO_ROOM_CLASS SDO_FIFO_ROOM_R;
    SDI_FIFO_LEVEL_CLASS SDI_FIFO_LEVEL_R;
    CMD_FIFO_CLASS CMD_FIFO_R;
    SDO_FIFO_CLASS SDO_FIFO_R;
    SDI_FIFO_CLASS SDI_FIFO_R;
    SDI_FIFO_MSB_CLASS SDI_FIFO_MSB_R;
    SDI_FIFO_PEEK_CLASS SDI_FIFO_PEEK_R;
    OFFLOAD0_EN_CLASS OFFLOAD0_EN_R;
    OFFLOAD0_STATUS_CLASS OFFLOAD0_STATUS_R;
    OFFLOAD0_MEM_RESET_CLASS OFFLOAD0_MEM_RESET_R;
    OFFLOAD0_CDM_FIFO_CLASS OFFLOAD0_CDM_FIFO_R;
    OFFLOAD0_SDO_FIFO_CLASS OFFLOAD0_SDO_FIFO_R;
    CFG_INFO_0_CLASS CFG_INFO_0_R;
    CFG_INFO_1_CLASS CFG_INFO_1_R;
    CFG_INFO_2_CLASS CFG_INFO_2_R;
    CFG_INFO_3_CLASS CFG_INFO_3_R;

    function new(
      input string name,
      input int address,
      input int CFG_INFO_0,
      input int CFG_INFO_1,
      input int CFG_INFO_2,
      input int CFG_INFO_3,
      input int CMD_FIFO_ADDRESS_WIDTH,
      input int DATA_WIDTH,
      input int ID,
      input int NUM_OF_SDI,
      input int SDO_FIFO_ADDRESS_WIDTH,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.PERIPHERAL_ID_R = new("PERIPHERAL_ID", 'h4, ID, this);
      this.SCRATCH_R = new("SCRATCH", 'h8, this);
      this.DATA_WIDTH_R = new("DATA_WIDTH", 'hc, DATA_WIDTH, NUM_OF_SDI, this);
      this.OFFLOAD_MEM_ADDR_WIDTH_R = new("OFFLOAD_MEM_ADDR_WIDTH", 'h10, this);
      this.FIFO_ADDR_WIDTH_R = new("FIFO_ADDR_WIDTH", 'h14, this);
      this.ENABLE_R = new("ENABLE", 'h40, this);
      this.IRQ_MASK_R = new("IRQ_MASK", 'h80, this);
      this.IRQ_PENDING_R = new("IRQ_PENDING", 'h84, this);
      this.IRQ_SOURCE_R = new("IRQ_SOURCE", 'h88, this);
      this.SYNC_ID_R = new("SYNC_ID", 'hc0, this);
      this.OFFLOAD_SYNC_ID_R = new("OFFLOAD_SYNC_ID", 'hc4, this);
      this.CMD_FIFO_ROOM_R = new("CMD_FIFO_ROOM", 'hd0, CMD_FIFO_ADDRESS_WIDTH, this);
      this.SDO_FIFO_ROOM_R = new("SDO_FIFO_ROOM", 'hd4, SDO_FIFO_ADDRESS_WIDTH, this);
      this.SDI_FIFO_LEVEL_R = new("SDI_FIFO_LEVEL", 'hd8, this);
      this.CMD_FIFO_R = new("CMD_FIFO", 'he0, this);
      this.SDO_FIFO_R = new("SDO_FIFO", 'he4, this);
      this.SDI_FIFO_R = new("SDI_FIFO", 'he8, this);
      this.SDI_FIFO_MSB_R = new("SDI_FIFO_MSB", 'hec, this);
      this.SDI_FIFO_PEEK_R = new("SDI_FIFO_PEEK", 'hf0, this);
      this.OFFLOAD0_EN_R = new("OFFLOAD0_EN", 'h100, this);
      this.OFFLOAD0_STATUS_R = new("OFFLOAD0_STATUS", 'h104, this);
      this.OFFLOAD0_MEM_RESET_R = new("OFFLOAD0_MEM_RESET", 'h108, this);
      this.OFFLOAD0_CDM_FIFO_R = new("OFFLOAD0_CDM_FIFO", 'h110, this);
      this.OFFLOAD0_SDO_FIFO_R = new("OFFLOAD0_SDO_FIFO", 'h114, this);
      this.CFG_INFO_0_R = new("CFG_INFO_0", 'h200, CFG_INFO_0, this);
      this.CFG_INFO_1_R = new("CFG_INFO_1", 'h204, CFG_INFO_1, this);
      this.CFG_INFO_2_R = new("CFG_INFO_2", 'h208, CFG_INFO_2, this);
      this.CFG_INFO_3_R = new("CFG_INFO_3", 'h20c, CFG_INFO_3, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_spi_engine

endpackage: adi_regmap_spi_engine_pkg
