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
`include "axi_definitions.svh"
`include "axis_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import adi_axis_agent_pkg::*;
import axi4stream_vip_pkg::*;
import m_axis_sequencer_pkg::*;
import scoreboard_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, adc_src_axis)::*;
import `PKGIFY(test_harness, dac_dst_axis)::*;

program test_program();

  timeunit 1ns;
  timeprecision 1ps;

  // declare the class instances
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

  adi_axis_master_agent #(`AXIS_VIP_PARAMS(test_harness, adc_src_axis)) adc_src_axis_agent;
  adi_axis_slave_agent #(`AXIS_VIP_PARAMS(test_harness, dac_dst_axis)) dac_dst_axis_agent;

  scoreboard #(logic [7:0]) scoreboard;

  initial begin

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    // create environment
    base_env = new("Base Environment",
                    `TH.`SYS_CLK.inst.IF,
                    `TH.`DMA_CLK.inst.IF,
                    `TH.`DDR_CLK.inst.IF,
                    `TH.`SYS_RST.inst.IF,
                    `TH.`MNG_AXI.inst.IF,
                    `TH.`DDR_AXI.inst.IF);

    adc_src_axis_agent = new("Source", `TH.`ADC_SRC_AXIS.inst.IF);
    dac_dst_axis_agent = new("Destination", `TH.`DAC_DST_AXIS.inst.IF);

    scoreboard = new("Scoreboard");

    // configure the sequencers
    adc_src_axis_agent.master_sequencer.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
    adc_src_axis_agent.master_sequencer.add_xfer_descriptor_byte_count(32'h100, 1, 0);

    dac_dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

    // start the environment
    base_env.start();
    adc_src_axis_agent.start_master();
    dac_dst_axis_agent.start_slave();
    base_env.sys_reset();

    // subscribe and start the scoreboard
    adc_src_axis_agent.monitor.publisher.subscribe(scoreboard.subscriber_source);
    dac_dst_axis_agent.monitor.publisher.subscribe(scoreboard.subscriber_sink);

    scoreboard.run();

    // generate data
    adc_src_axis_agent.master_sequencer.start();
    dac_dst_axis_agent.slave_sequencer.start();

    #1us;

    // wait for scoreboard to be empty on both sides
    scoreboard.wait_until_complete();

    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
