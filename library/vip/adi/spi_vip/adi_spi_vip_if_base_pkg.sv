// ***************************************************************************
// Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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

package adi_spi_vip_if_base_pkg;

  typedef enum {SPI_MODE_SLAVE, SPI_MODE_MASTER, SPI_MODE_MONITOR} spi_mode_t;
  typedef logic mosi_array_t [];

  virtual class adi_spi_vip_if_base;

    function new();
    endfunction

    pure virtual function int get_param_MODE();

    pure virtual function int get_param_CPOL();

    pure virtual function int get_param_CPHA();

    pure virtual function int get_param_INV_CS();

    pure virtual function int get_param_DATA_DLENGTH();

    pure virtual function int get_param_NUM_OF_SDI();

    pure virtual function int get_param_NUM_OF_SDO();

    pure virtual function int get_param_SDI_LANE_MASK();

    pure virtual function int get_param_SDO_LANE_MASK();

    pure virtual function int get_param_SLAVE_TIN();

    pure virtual function int get_param_SLAVE_TOUT();

    pure virtual function int get_param_MASTER_TIN();

    pure virtual function int get_param_MASTER_TOUT();

    pure virtual function int get_param_CS_TO_MISO();

    pure virtual function int get_param_DEFAULT_MISO_DATA();

    pure virtual function spi_mode_t get_mode();

    pure virtual function logic get_cs_active();

    pure virtual task wait_cs_active();

    pure virtual task wait_cs_inactive();

    pure virtual task wait_for_sample_edge();

    pure virtual function mosi_array_t get_mosi_delayed();

    pure virtual task set_miso_drive(bit val[]);

    pure virtual task set_miso_drive_instantaneous(bit val[]);

    pure virtual task wait_for_drive_edge();

    pure virtual task wait_cs();

    pure virtual task set_miso_oen(bit val);

  endclass

endpackage
