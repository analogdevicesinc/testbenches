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
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

package s_spi_sequencer_pkg;

  import logger_pkg::*;
  import adi_spi_vip_pkg::*;

  class s_spi_sequencer;

    adi_spi_agent agent;

    function new(adi_spi_agent agent);
      this.agent = agent;    
    endfunction: new

    virtual task automatic send_data(input int unsigned data);
      this.agent.send_data(data);
    endtask : send_data

    virtual task automatic receive_data(output int unsigned data);
      this.agent.receive_data(data);
    endtask : receive_data

    virtual task automatic receive_data_verify(input int unsigned expected);
      int unsigned received;
      this.agent.receive_data(received);
      if (received !== expected) begin
        `ERROR(("Data mismatch. Received : %h; expected %h", received, expected));
      end
    endtask : receive_data_verify

    virtual task flush_send();
      this.agent.flush_send();
    endtask : flush_send
  endclass
endpackage