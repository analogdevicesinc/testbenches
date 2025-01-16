// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2023-2025 Analog Devices, Inc. All rights reserved.
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
  import adi_common_pkg::*;
  import axi_vip_pkg::*;
  import m_axis_sequencer_pkg::*;
  import adi_axi_agent_pkg::*;
  import adi_axis_agent_pkg::*;
  import adi_spi_vip_pkg::*;
  import adi_spi_vip_if_base_pkg::*;

  `ifdef DEF_SDO_STREAMING
  class spi_environment #(int `AXI_VIP_PARAM_ORDER(mng), int `AXI_VIP_PARAM_ORDER(ddr), int `AXIS_VIP_PARAM_ORDER(sdo_src)) extends adi_environment;
  `else
  class spi_environment #(int `AXI_VIP_PARAM_ORDER(mng), int `AXI_VIP_PARAM_ORDER(ddr)) extends adi_environment;
  `endif

    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if;
    virtual interface rst_vip_if #(.C_ASYNCHRONOUS(1), .C_RST_POLARITY(1)) sys_rst_vip_if;

    // Agents
    adi_axi_master_agent #(`AXI_VIP_PARAM_ORDER(mng)) mng;
    adi_axi_slave_mem_agent #(`AXI_VIP_PARAM_ORDER(ddr)) ddr;
    adi_spi_agent spi_agent;

    `ifdef DEF_SDO_STREAMING
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(sdo_src)) sdo_src_agent;
    virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(sdo_src)) sdo_src_axis_vip_if;
    `endif


    //============================================================================
    // Constructor
    //============================================================================
    function new(
      input string name,

      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if,

      virtual interface rst_vip_if #(.C_ASYNCHRONOUS(1), .C_RST_POLARITY(1)) sys_rst_vip_if,

      `ifdef DEF_SDO_STREAMING
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(sdo_src)) sdo_src_axis_vip_if,
      `endif
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(mng)) mng_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(ddr)) ddr_vip_if,
      adi_spi_vip_if_base spi_s_vip_if_base
    );

      super.new(name);

      // virtual interfaces
      this.sys_clk_vip_if = sys_clk_vip_if;
      this.dma_clk_vip_if = dma_clk_vip_if;
      this.ddr_clk_vip_if = ddr_clk_vip_if;
      this.sys_rst_vip_if = sys_rst_vip_if;
      `ifdef DEF_SDO_STREAMING
        this.sdo_src_axis_vip_if = sdo_src_axis_vip_if;
      `endif

      // Creating the agents
      this.mng = new("AXI Manager Agent", mng_vip_if, this);
      this.ddr = new("AXI DDR stub Agent", ddr_vip_if, this);
      this.spi_agent = new("SPI VIP Agent", spi_s_vip_if_base, this);
      `ifdef DEF_SDO_STREAMING
      this.sdo_src_agent = new("SDO Source AXI Stream Agent", sdo_src_axis_vip_if, this);
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
      this.mng.agent.start_master();
      this.ddr.agent.start_slave();
      spi_agent.start();
      `ifdef DEF_SDO_STREAMING
      sdo_src_agent.agent.start_master();
      `endif
      this.sys_clk_vip_if.start_clock;
      this.dma_clk_vip_if.start_clock;
      this.ddr_clk_vip_if.start_clock;
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run;
      fork
        `ifdef DEF_SDO_STREAMING
        sdo_src_agent.sequencer.run();

        `endif
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;
      spi_agent.stop();
      `ifdef DEF_SDO_STREAMING
      sdo_src_agent.sequencer.stop();
      sdo_src_agent.agent.stop_master();
      `endif
      this.mng.agent.stop_master();
      this.ddr.agent.stop_slave();
      this.sys_clk_vip_if.stop_clock;
      this.dma_clk_vip_if.stop_clock;
      this.ddr_clk_vip_if.stop_clock;
    endtask

    //============================================================================
    // System reset routine
    //============================================================================
    task sys_reset();
      //asserts all the resets for 100 ns
      this.sys_rst_vip_if.assert_reset;
      #200;
      this.sys_rst_vip_if.deassert_reset;
      #800;
    endtask

  endclass

endpackage
