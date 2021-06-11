// ***************************************************************************
// ***************************************************************************
// Copyright 2021 (c) Analog Devices, Inc. All rights reserved.
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

package environment_pkg;

  import m_axi_sequencer_pkg::*;

  import logger_pkg::*;

  import axi_vip_pkg::*;
  import `PKGIFY(test_harness, mng_axi)::*;

  class environment;

    // agents and sequencers
    `AGENT(test_harness, mng_axi, mst_t) mng_agent;

    m_axi_sequencer  #(`AGENT(test_harness, mng_axi, mst_t)) mng;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, mng_axi)) mng_vip_if);

      // creating the agents
      mng_agent = new("AXI Manager Agent", mng_vip_if);

      // create sequencers
      mng = new(mng_agent);

    endfunction

    //============================================================================
    // Start environment
    //============================================================================
    task start();

      // start agents, one by one
      mng_agent.start_master();

    endtask

    //============================================================================
    // Start the test
    //============================================================================
    task test();
      fork

      join_none
    endtask

    //============================================================================
    // Post test subroutine
    //============================================================================
    task post_test();
      fork

      join
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run;
      test();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;
      mng_agent.stop_master();
      post_test();
    endtask

  endclass

endpackage
