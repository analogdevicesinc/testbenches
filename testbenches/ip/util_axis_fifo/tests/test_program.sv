// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import environment_pkg::*;
import watchdog_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, input_axis)::*;
import `PKGIFY(test_harness, output_axis)::*;

program test_program ();

  timeunit 1ns;
  timeprecision 1ps;

  // declare the class instances
  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  util_axis_fifo_environment #(`AXIS_VIP_PARAMS(test_harness, input_axis), `AXIS_VIP_PARAMS(test_harness, output_axis), `INPUT_CLK, `OUTPUT_CLK) uaf_env;

  watchdog send_data_wd;

  initial begin

    // create environment
    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(`IRQ_C_BA),
      .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

    mng = new("", `TH.`MNG_AXI.inst.IF);
    ddr = new("", `TH.`DDR_AXI.inst.IF);

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    uaf_env = new("Util AXIS FIFO Environment",
                  `TH.`INPUT_CLK_VIP.inst.IF,
                  `TH.`OUTPUT_CLK_VIP.inst.IF,
                  `TH.`INPUT_AXIS.inst.IF,
                  `TH.`OUTPUT_AXIS.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    uaf_env.start();

    base_env.sys_reset();

    uaf_env.configure();

    if (!`TKEEP_EN) begin
      uaf_env.input_axis_agent.master_sequencer.set_keep_some();
    end else begin
      uaf_env.input_axis_agent.master_sequencer.set_keep_all();
    end

    uaf_env.run();

    send_data_wd = new("Util AXIS FIFO Watchdog", 500000, "Send data");

    send_data_wd.start();

    uaf_env.input_axis_agent.master_sequencer.start();

    // stimulus
    repeat($urandom_range(5,10)) begin
      send_data_wd.reset();

      if (!`TKEEP_EN) begin
        repeat($urandom_range(1,5)) begin
          uaf_env.input_axis_agent.master_sequencer.add_xfer_descriptor_sample_count($urandom_range(1,128), `TLAST_EN, 0);
        end
      end else begin
        repeat($urandom_range(1,5)) begin
          uaf_env.input_axis_agent.master_sequencer.add_xfer_descriptor_byte_count($urandom_range(1,1024), `TLAST_EN, 0);
        end
      end

      #($urandom_range(1,10)*1us);

      uaf_env.input_axis_agent.master_sequencer.clear_descriptor_queue();
      uaf_env.input_axis_agent.master_sequencer.wait_empty_descriptor_queue();

      uaf_env.scoreboard_inst.wait_until_complete();

      `INFO(("Packet finished."), ADI_VERBOSITY_LOW);
    end

    send_data_wd.stop();

    #100ns;

    uaf_env.stop();
    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
