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

package spi_environment_pkg;

  import logger_pkg::*;
  import adi_environment_pkg::*;

  import axi4stream_vip_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_spi_sequencer_pkg::*;
  import adi_spi_vip_pkg::*;

  import `PKGIFY(test_harness, spi_s_vip)::*;
  
  `ifdef DEF_SDO_STREAMING
    import `PKGIFY(test_harness, sdo_src)::*;
  `endif

  class spi_environment extends adi_environment;

    // Agents
    adi_spi_agent #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_agent;
    `ifdef DEF_SDO_STREAMING
    `AGENT(test_harness, sdo_src, mst_t)    sdo_src_agent;
    `endif

    // Sequencers
    s_spi_sequencer #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_seq;
    `ifdef DEF_SDO_STREAMING
    m_axis_sequencer #(`AXIS_VIP_PARAMS(test_harness, sdo_src)) sdo_src_seq;
    `endif

    //============================================================================
    // Constructor
    //============================================================================
    function new(
      input string name,

      `ifdef DEF_SDO_STREAMING
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness_sdo_src_0)) sdo_src_axis_vip_if,
      `endif
      virtual interface spi_vip_if #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_s_vip_if);

      super.new(name);

      // Creating the agents
      this.spi_agent = new("SPI VIP Agent", spi_s_vip_if, this);
      `ifdef DEF_SDO_STREAMING
      this.sdo_src_agent = new("SDO Source AXI Stream Agent", sdo_src_axis_vip_if);
      `endif

      // Creating the sequencers
      this.spi_seq = new("SPI VIP Agent", this.spi_agent, this);
      `ifdef DEF_SDO_STREAMING
      this.sdo_src_seq = new("SDO Source AXI Stream Sequencer", this.sdo_src_agent.driver);
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
      this.sdo_src_seq.set_stop_policy(STOP_POLICY_PACKET);
      this.sdo_src_seq.set_data_gen_mode(DATA_GEN_MODE_TEST_DATA);
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
      this.sdo_src_agent.start_master();
      `endif
    endtask

    //============================================================================
    // Start the test
    //   - start the scoreboard
    //   - start the sequencers
    //============================================================================
    task test();
      fork
        `ifdef DEF_SDO_STREAMING
        this.sdo_src_seq.run();
        `endif
      join_none
    endtask

    //============================================================================
    // Post test subroutine
    //============================================================================
    task post_test();
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      test();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.spi_agent.stop();
      `ifdef DEF_SDO_STREAMING
      this.sdo_src_seq.stop();
      this.sdo_src_agent.stop_master();
      `endif
    endtask

  endclass

endpackage
