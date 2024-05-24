// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018 (c) Analog Devices, Inc. All rights reserved.
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

package spi_environment_pkg;

  import axi_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axi_sequencer_pkg::*;
  import s_axi_sequencer_pkg::*;
  import s_spi_sequencer_pkg::*;
  import adi_spi_vip_pkg::*;
  import test_harness_env_pkg::*;
  import `PKGIFY(test_harness, mng_axi_vip)::*;
  import `PKGIFY(test_harness, ddr_axi_vip)::*;
  import `PKGIFY(test_harness, spi_s_vip)::*;

  class spi_environment extends test_harness_env;

    // Agents
    adi_spi_agent #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_agent;

    // Sequencers
    s_spi_sequencer #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_seq;

    //============================================================================
    // Constructor
    //============================================================================
    function new(
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if,

      virtual interface rst_vip_if #(.C_ASYNCHRONOUS(1), .C_RST_POLARITY(1)) sys_rst_vip_if,

      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, mng_axi_vip)) mng_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, ddr_axi_vip)) ddr_vip_if,
      virtual interface spi_vip_if #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_s_vip_if
    );

      super.new(sys_clk_vip_if,
                dma_clk_vip_if,
                ddr_clk_vip_if,
                sys_rst_vip_if,
                mng_vip_if,
                ddr_vip_if);

      // Creating the agents
      spi_agent = new(spi_s_vip_if);
      
      // Creating the sequencers
      spi_seq = new(spi_agent);

    endfunction

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      super.start();
      spi_agent.start();      
    endtask

    //============================================================================
    // Start the test
    //   - start the scoreboard
    //   - start the sequencers
    //============================================================================
    task test();
      super.test();
      fork

      join_none
    endtask

    //============================================================================
    // Post test subroutine
    //============================================================================
    task post_test();
      super.post_test();
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run;
      test();
      post_test();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;
      spi_agent.stop();
      super.stop();      
    endtask

  endclass

endpackage
