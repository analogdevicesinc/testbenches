// ***************************************************************************
// ***************************************************************************
// Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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
//      <https://www.gnu.org/licenses/old-licenses/gpl_2.0.html>
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

package adi_spi_vip_pkg;

  virtual class adi_abstract_spi_driver;
    pure virtual task put_tx_data(int unsigned data);
    pure virtual task get_rx_data(output int unsigned data);
    pure virtual task flush_tx();
    pure virtual task start();
    pure virtual task stop();
    pure virtual function void set_default_miso_data(int unsigned data);
  endclass

  class adi_spi_agent;

    adi_abstract_spi_driver driver;


    function new(adi_abstract_spi_driver driver);
      this.driver = driver;
    endfunction

    virtual task send_data(input int unsigned data);
      this.driver.put_tx_data(data);
    endtask : send_data

    virtual task receive_data(output int unsigned data);
      this.driver.get_rx_data(data);
    endtask : receive_data

    virtual task flush_send();
      this.driver.flush_tx();
    endtask : flush_send

    virtual task start();
      fork
        this.driver.start();
      join_none
    endtask : start

    virtual task stop();
      this.driver.stop();
    endtask : stop

    virtual function void set_default_miso_data(input int unsigned data);
      this.driver.set_default_miso_data(data);
    endfunction : set_default_miso_data

  endclass

endpackage