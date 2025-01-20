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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

package ad57xx_environment_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;

  import s_spi_sequencer_pkg::*;
  import adi_spi_vip_pkg::*;
  
  import `PKGIFY(test_harness, spi_s_vip)::*;

  class ad57xx_environment extends adi_environment;

    // Agents
    adi_spi_agent #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_agent;

    // Sequencers
    s_spi_sequencer #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_seq;

    //============================================================================
    // Constructor
    //============================================================================
    function new(
      input string name,

      virtual interface spi_vip_if #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_s_vip_if
    );

      // Creating the agents
      this.spi_agent = new("SPI VIP Agent", spi_s_vip_if, this);

      // Creating the sequencers
      this.spi_seq = new("SPI VIP Sequencer", this.spi_agent, this);

    endfunction

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.spi_agent.start();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;
      this.spi_agent.stop();
    endtask

  endclass

endpackage
