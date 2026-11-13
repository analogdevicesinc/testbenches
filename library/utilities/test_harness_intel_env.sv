// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

package test_harness_intel_env_pkg;

  import logger_pkg::*;
  import adi_environment_pkg::*;
  import adi_avmm_agent_pkg::*;
  import adi_clk_rst_bfm_if_base_pkg::*;
  import watchdog_pkg::*;
  import vip_agent_typedef_pkg::*;
  import verbosity_pkg::*;

  class test_harness_intel_env extends adi_environment;

    adi_avmm_agent_base mng;
    adi_avmm_agent_base ddr;

    adi_clock_source_bfm_if_base sys_clk_vip_if;
    adi_clock_source_bfm_if_base dma_clk_vip_if;

    adi_reset_source_bfm_if_base sys_rst_vip_if;

    watchdog simulation_watchdog;

    function new(
      input string name,
      input adi_clock_source_bfm_if_base sys_clk_vip_if,
      input adi_clock_source_bfm_if_base dma_clk_vip_if,
      input adi_reset_source_bfm_if_base sys_rst_vip_if,
      input adi_environment parent = null);

      super.new(name, parent);

      this.simulation_watchdog = new("Simulation watchdog", 10**6, "Simulation might be hanging!");

      this.sys_clk_vip_if = sys_clk_vip_if;
      this.dma_clk_vip_if = dma_clk_vip_if;
      this.sys_rst_vip_if = sys_rst_vip_if;

      this.mng = new("AVMM Manager agent", MASTER, this);
      this.ddr = new("AVMM DDR stub agent", SLAVE, this);

      // The Intel BFMs report every clock start/stop and transaction at INFO
      set_verbosity(VERBOSITY_WARNING);
    endfunction

    task start();
      this.simulation_watchdog.start();

      this.sys_clk_vip_if.start_clock();
      this.dma_clk_vip_if.start_clock();

      this.mng.start_master();
      this.ddr.start_slave();
    endtask

    task stop();
      this.mng.stop_master();
      this.ddr.stop_slave();

      this.sys_clk_vip_if.stop_clock();
      this.dma_clk_vip_if.stop_clock();

      this.simulation_watchdog.stop();
    endtask

    task sys_reset();
      this.sys_rst_vip_if.assert_reset();
      #200ns;
      this.sys_rst_vip_if.deassert_reset();
      #800ns;
    endtask

  endclass

endpackage
