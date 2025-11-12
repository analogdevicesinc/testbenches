// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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
import environment_pkg::*;
import watchdog_pkg::*;
import adi_axis_packet_pkg::*;
import m_axis_sequencer_pkg::*;
import adi_axis_config_pkg::*;
import adi_axis_rand_config_pkg::*;
import adi_axis_rand_obj_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, input_axis)::*;
import `PKGIFY(test_harness, output_axis)::*;

program test_program ();

  timeunit 1ns;
  timeprecision 1ps;

  // declare the class instances
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  util_axis_fifo_environment #(`AXIS_VIP_PARAMS(test_harness, input_axis), `AXIS_VIP_PARAMS(test_harness, output_axis), `INPUT_CLK, `OUTPUT_CLK) uaf_env;

  watchdog send_data_wd;

  adi_axis_config axis_cfg;
  adi_axis_rand_config axis_rand_cfg;
  adi_axis_rand_obj axis_rand_obj;

  adi_axis_packet axis_packet;

  initial begin

    // create environment
    base_env = new("Base Environment",
                    `TH.`SYS_CLK.inst.IF,
                    `TH.`DMA_CLK.inst.IF,
                    `TH.`DDR_CLK.inst.IF,
                    `TH.`SYS_RST.inst.IF,
                    `TH.`MNG_AXI.inst.IF,
                    `TH.`DDR_AXI.inst.IF);

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

    uaf_env.run();

    send_data_wd = new("Util AXIS FIFO Asym Watchdog", 10**6 * 2, "Send data");

    // stop the integrated watchdog, as this testbench has another watchdog that is better suited for this test
    base_env.simulation_watchdog.stop();
    send_data_wd.start();

    axis_cfg = new(`AXIS_TRANSACTION_PARAM(test_harness, input_axis));
    axis_rand_cfg = new();
    axis_rand_obj = new();

    axis_rand_cfg.randomize_configuration();

    if (test_harness_input_axis_0_VIP_HAS_TLAST && test_harness_input_axis_0_VIP_HAS_TKEEP && test_harness_input_axis_0_VIP_DATA_WIDTH >= test_harness_output_axis_0_VIP_DATA_WIDTH) begin
      axis_packet = new(
        .transactions_per_packet($urandom_range(1, 20)),
        .cfg(axis_cfg),
        .rand_cfg(adi_axis_rand_config'(axis_rand_cfg.clone())),
        .rand_obj(adi_axis_rand_obj'(axis_rand_obj.clone())));
    end else begin
      axis_packet = new(
        .transactions_per_packet(`MAX(test_harness_input_axis_0_VIP_DATA_WIDTH, test_harness_output_axis_0_VIP_DATA_WIDTH) / `MIN(test_harness_input_axis_0_VIP_DATA_WIDTH, test_harness_output_axis_0_VIP_DATA_WIDTH) * $urandom_range(1, 5)),
        .cfg(axis_cfg),
        .rand_cfg(adi_axis_rand_config'(axis_rand_cfg.clone())),
        .rand_obj(adi_axis_rand_obj'(axis_rand_obj.clone())));
    end

    // stimulus
    repeat($urandom_range(5, 10)) begin
      send_data_wd.reset();

      repeat($urandom_range(1, 2)) begin
        axis_packet.randomize_packet();

        uaf_env.input_axis_agent.master_sequencer.add_packet(axis_packet);
      end

      #($urandom_range(1, 10)*1us);

      uaf_env.input_axis_agent.master_sequencer.clear_sequences();
      uaf_env.input_axis_agent.master_sequencer.wait_empty_sequences();
      uaf_env.input_axis_agent.master_sequencer.sequence_sent();

      uaf_env.scoreboard_inst.wait_until_complete();

      `INFO(("Packet finished."), ADI_VERBOSITY_LOW);
    end

    send_data_wd.stop();

    uaf_env.stop();
    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
