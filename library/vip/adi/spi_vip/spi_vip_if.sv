// ***************************************************************************
// Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
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

interface spi_vip_if #(
  int MODE              = 0,
      CPOL              = 0,
      CPHA              = 0,
      INV_CS            = 0,
      DATA_DLENGTH      = 16,
      NUM_OF_SDI        = 1,
      NUM_OF_SDO        = 1,
      SDI_LANE_MASK     = 8'hFF,
      SDO_LANE_MASK     = 8'hFF,
      SLAVE_TIN         = 0,
      SLAVE_TOUT        = 0,
      MASTER_TIN        = 0,
      MASTER_TOUT       = 0,
      CS_TO_MISO        = 0,
      DEFAULT_MISO_DATA = 'hCAFE
) ();
  import adi_spi_vip_if_base_pkg::*;

  logic s_sclk;
  wire  [NUM_OF_SDI-1:0] s_miso; // need net types here in case tb wants to tristate this
  logic [NUM_OF_SDO-1:0] s_mosi;
  logic s_cs;

  logic m_sclk;
  wire  [NUM_OF_SDI-1:0] m_miso; // need net types here in case tb wants to tristate this
  logic [NUM_OF_SDO-1:0] m_mosi;
  logic m_cs;

  // internal
  spi_mode_t spi_mode;
  logic miso_oen;
  logic [NUM_OF_SDI-1:0] miso_drive;
  logic [NUM_OF_SDI-1:0] miso_drive_delayed;
  logic [NUM_OF_SDO-1:0] mosi_drive = 1'b0;
  logic cs_drive = 1'b0;
  logic sclk_drive = 1'b0;
  logic cs_active;
  logic [NUM_OF_SDO-1:0] s_mosi_delayed;
  mosi_array_t s_mosi_unpacked;
  wire sclk;
  wire cs;

  localparam CS_ACTIVE_LEVEL = (INV_CS) ? 1'b1 : 1'b0;
  // localparam DEFAULT_MASK_SDI_SPI_LANE = (2 ** NUM_OF_SDI) - 1; //by default all lanes are enabled
  // localparam DEFAULT_MASK_SDO_SPI_LANE = (2 ** NUM_OF_SDO) - 1; //by default all lanes are enabled

  // cs, sclk sources
  assign cs = (spi_mode != SPI_MODE_SLAVE)  ? m_cs : s_cs;
  assign sclk = (spi_mode != SPI_MODE_SLAVE)  ? m_sclk : s_sclk;

  // hack for parameterized edge. TODO: improve this
  logic sample_edge, drive_edge;
  assign sample_edge  = (CPOL^CPHA) ? !sclk : sclk;
  assign drive_edge   = (CPOL^CPHA) ? sclk : !sclk;
  assign cs_active = (cs == CS_ACTIVE_LEVEL);

  // miso drive handling
  assign s_miso = (spi_mode != SPI_MODE_SLAVE)  ? m_miso
                : (miso_oen)          ? miso_drive_delayed
                /*default*/         : 'z;

  // mosi drive handling
  assign m_mosi = (spi_mode != SPI_MODE_MASTER)  ? s_mosi : mosi_drive;

  // cs drive handling
  assign m_cs   = (spi_mode != SPI_MODE_MASTER)  ? s_cs : cs_drive;

  // sclk drive handling
  assign m_sclk = (spi_mode != SPI_MODE_MASTER)  ? s_sclk : sclk_drive;

  // mosi delay
  assign #(SLAVE_TIN*1ns) s_mosi_delayed =  s_mosi;

  class adi_spi_vip_if #(int dummy = 10) extends adi_spi_vip_if_base;

    function new();
      s_mosi_unpacked = new [NUM_OF_SDO];
    endfunction

    virtual function int get_param_MODE();
      return MODE;
    endfunction

    virtual function int get_param_CPOL();
      return CPOL;
    endfunction

    virtual function int get_param_CPHA();
      return CPHA;
    endfunction

    virtual function int get_param_INV_CS();
      return INV_CS;
    endfunction

    virtual function int get_param_DATA_DLENGTH();
      return DATA_DLENGTH;
    endfunction

    virtual function int get_param_NUM_OF_SDI();
      return NUM_OF_SDI;
    endfunction

    virtual function int get_param_NUM_OF_SDO();
      return NUM_OF_SDO;
    endfunction

    virtual function int get_param_SDI_LANE_MASK();
      return SDI_LANE_MASK;
    endfunction

    virtual function int get_param_SDO_LANE_MASK();
      return SDO_LANE_MASK;
    endfunction

    virtual function int get_param_SLAVE_TIN();
      return SLAVE_TIN;
    endfunction

    virtual function int get_param_SLAVE_TOUT();
      return SLAVE_TOUT;
    endfunction

    virtual function int get_param_MASTER_TIN();
      return MASTER_TIN;
    endfunction

    virtual function int get_param_MASTER_TOUT();
      return MASTER_TOUT;
    endfunction

    virtual function int get_param_CS_TO_MISO();
      return CS_TO_MISO;
    endfunction

    virtual function int get_param_DEFAULT_MISO_DATA();
      return DEFAULT_MISO_DATA;
    endfunction

    virtual function spi_mode_t get_mode();
      return spi_mode;
    endfunction

    virtual function mosi_array_t get_mosi_delayed();
      {<<{s_mosi_unpacked}} = s_mosi_delayed;
      return s_mosi_unpacked;
    endfunction

    virtual function logic get_cs_active();
      return cs_active;
    endfunction

    virtual task set_miso_drive(bit val[]);
      foreach (val[i]) begin
        miso_drive[i] = val[i];
      end
      miso_drive_delayed <= #(SLAVE_TOUT * 1ns) miso_drive;
    endtask

    virtual task set_miso_drive_instantaneous(bit val[]);
      foreach (val[i]) begin
        miso_drive[i] = val[i];
      end
      miso_drive_delayed <= miso_drive;
    endtask

    virtual task wait_cs_active();
      wait(cs_active);
    endtask

    virtual task wait_cs_inactive();
      wait(!cs_active);
    endtask

    virtual task wait_for_sample_edge();
      @(posedge sample_edge);
    endtask

    virtual task wait_for_drive_edge();
      @(posedge drive_edge);
    endtask

    virtual task wait_cs();
      @(cs);
    endtask

    virtual task set_miso_oen(bit val);
      miso_oen <= #(CS_TO_MISO*1ns) val;
    endtask

  endclass: adi_spi_vip_if

  adi_spi_vip_if vif = new();

  function void set_slave_mode();
    spi_mode = SPI_MODE_SLAVE;
  endfunction : set_slave_mode

  function void set_master_mode();
    spi_mode = SPI_MODE_MASTER;
    $error("Unsupported mode master"); //TODO
  endfunction : set_master_mode

  function void set_monitor_mode();
    spi_mode = SPI_MODE_MONITOR;
    $error("Unsupported mode monitor"); //TODO
  endfunction : set_monitor_mode

endinterface
