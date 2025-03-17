// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2023-2024 Analog Devices, Inc. All rights reserved.
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

`include "utils.svh"
`include "axis_definitions.svh"

package spi_environment_pkg;

  import logger_pkg::*;
  import adi_environment_pkg::*;

  import m_axis_sequencer_pkg::*;
  import adi_axis_agent_pkg::*;
  import adi_spi_vip_pkg::*;
  import adi_spi_vip_if_base_pkg::*;

  `ifdef DEF_SDO_STREAMING
    import `PKGIFY(test_harness, sdo_src)::*;
  `endif

  class spi_environment extends adi_environment;

    // Agents
    adi_spi_agent spi_agent;
    `ifdef DEF_SDO_STREAMING
      adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(test_harness_sdo_src_0)) sdo_src_agent;
    `endif

    //============================================================================
    // Constructor
    //============================================================================
    function new(
      input string name,

      `ifdef DEF_SDO_STREAMING
        virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness_sdo_src_0)) sdo_src_axis_vip_if,
      `endif
      adi_spi_vip_if_base spi_s_vip_if);

      super.new(name);

      // Creating the agents
      this.spi_agent = new("SPI VIP Agent", spi_s_vip_if, this);
      `ifdef DEF_SDO_STREAMING
        this.sdo_src_agent = new("SDO Source AXI Stream Agent", sdo_src_axis_vip_if);
      `endif

      // downgrade reset check: we are currently using a clock generator for the SPI clock,
      // so it will come a bit after the reset and trigger the default error.
      // This is harmless for this test (we don't want to test any reset scheme)
      `ifdef DEF_SDO_STREAMING
        sdo_src_axis_vip_if.set_xilinx_reset_check_to_warn();
      `endif
    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencers with an initial configuration before starting
    //============================================================================
    task configure();
      `ifdef DEF_SDO_STREAMING
        this.sdo_src_agent.sequencer.set_stop_policy(STOP_POLICY_PACKET);
        this.sdo_src_agent.sequencer.set_data_gen_mode(DATA_GEN_MODE_TEST_DATA);
      `endif
    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.spi_agent.start();
      `ifdef DEF_SDO_STREAMING
        this.sdo_src_agent.start();
      `endif
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      fork
        `ifdef DEF_SDO_STREAMING
          this.sdo_src_agent.run();
        `endif
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.spi_agent.stop();
      `ifdef DEF_SDO_STREAMING
        this.sdo_src_agent.stop();
      `endif
    endtask

  endclass

endpackage
