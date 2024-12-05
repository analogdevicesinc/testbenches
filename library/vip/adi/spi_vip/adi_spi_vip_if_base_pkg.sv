// ***************************************************************************
// Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
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

package adi_spi_vip_if_base_pkg;

  class adi_spi_vip_if_base;

    function new();
    endfunction

    virtual function int get_param_MODE();
    endfunction

    virtual function int get_param_CPOL();
    endfunction

    virtual function int get_param_CPHA();
    endfunction

    virtual function int get_param_INV_CS();
    endfunction

    virtual function int get_param_DATA_DLENGTH();
    endfunction

    virtual function int get_param_SLAVE_TIN();
    endfunction

    virtual function int get_param_SLAVE_TOUT();
    endfunction

    virtual function int get_param_MASTER_TIN();
    endfunction

    virtual function int get_param_MASTER_TOUT();
    endfunction

    virtual function int get_param_CS_TO_MISO();
    endfunction

    virtual function int get_param_DEFAULT_MISO_DATA();
    endfunction

    virtual function int get_master_mode();
      $fatal(1, $sformatf("Function not implemented!"));
    endfunction
    
    virtual function int get_slave_mode();
      $fatal(1, $sformatf("Function not implemented!"));
    endfunction
    
    virtual function int get_cs_active();
      $fatal(1, $sformatf("Function not implemented!"));
    endfunction
    
    virtual task wait_cs_active();
      $fatal(1, $sformatf("Task not implemented!"));
    endtask
    
    virtual task wait_posedge_sample_edge();
      $fatal(1, $sformatf("Task not implemented!"));
    endtask
    
    virtual function int get_mosi_delayed();
      $fatal(1, $sformatf("Function not implemented!"));
    endfunction
    
    virtual function void set_miso_drive();
      $fatal(1, $sformatf("Function not implemented!"));
    endfunction
    
    virtual task wait_posedge_drive_edge();
      $fatal(1, $sformatf("Task not implemented!"));
    endtask
    
    virtual task wait_cs();
      $fatal(1, $sformatf("Task not implemented!"));
    endtask
    
    virtual function void set_miso_oen();
      $fatal(1, $sformatf("Function not implemented!"));
    endfunction
    
  endclass

endpackage
