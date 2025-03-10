// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024 - 2025 Analog Devices, Inc. All rights reserved.
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
`include "axi_definitions.svh"
`include "axis_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import adi_axis_agent_pkg::*;
import m_axis_sequencer_pkg::*;
import axi4stream_vip_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, src_axis)::*;
import `PKGIFY(test_harness, os_axis)::*;
import `PKGIFY(test_harness, dst_axis)::*;

program test_program();

  // declare the class instances
  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  adi_axis_master_agent #(`AXIS_VIP_PARAMS(test_harness, src_axis)) src_axis_agent;
  adi_axis_master_agent #(`AXIS_VIP_PARAMS(test_harness, os_axis)) os_axis_agent;
  adi_axis_slave_agent #(`AXIS_VIP_PARAMS(test_harness, dst_axis)) dst_axis_agent;

  initial begin

    // create environment
    base_env = new("Base Environment",
      `TH.`SYS_CLK.inst.IF,
      `TH.`DMA_CLK.inst.IF,
      `TH.`DDR_CLK.inst.IF,
      `TH.`SYS_RST.inst.IF);

    mng = new("", `TH.`MNG_AXI.inst.IF);
    ddr = new("", `TH.`DDR_AXI.inst.IF);

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    src_axis_agent = new("", `TH.`SRC_AXIS.inst.IF);
    os_axis_agent = new("", `TH.`OS_AXIS.inst.IF);
    dst_axis_agent = new("", `TH.`DST_AXIS.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    `TH.`CORUNDUM_CLK_VIP.inst.IF.start_clock();
    `TH.`INPUT_CLK_VIP.inst.IF.start_clock();

    base_env.start();
    src_axis_agent.agent.start_master();
    os_axis_agent.agent.start_master();
    dst_axis_agent.agent.start_slave();
    base_env.sys_reset();

    src_axis_agent.master_sequencer.set_descriptor_gen_mode(1);
    src_axis_agent.master_sequencer.set_stop_policy(STOP_POLICY_PACKET);
    src_axis_agent.master_sequencer.add_xfer_descriptor_sample_count(32'd8192/src_axis_agent.agent.C_XIL_AXI4STREAM_DATA_WIDTH, 0, 0);

    os_axis_agent.master_sequencer.set_descriptor_gen_mode(1);
    os_axis_agent.master_sequencer.set_stop_policy(STOP_POLICY_PACKET);
    os_axis_agent.master_sequencer.add_xfer_descriptor_sample_count(32'd24, 1, 0);
    os_axis_agent.master_sequencer.set_descriptor_delay(32'd48);

    dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

    // Start the ADC/DAC stubs
    `INFO(("Start the sequencer"), ADI_VERBOSITY_LOW);
    src_axis_agent.master_sequencer.start();
    os_axis_agent.master_sequencer.start();
    dst_axis_agent.slave_sequencer.start();

    base_env.mng.master_sequencer.RegWrite32('h50000000+'h6*4, 32'd1024);

    // Start-stop
    for (int i=0; i<8; i++) begin
      `TH.`EN_IO.inst.IF.set_io(8'hFF >> i);

      base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h1);
      #2us;
      base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h0);
      #2us;
    end

    for (int i=0; i<8; i++) begin
      `TH.`EN_IO.inst.IF.set_io(8'h80 >> i);

      base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h1);
      #2us;
      base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h0);
      #2us;
    end

    os_axis_agent.master_sequencer.stop();
    #2us;

    `TH.`EN_IO.inst.IF.set_io(8'hFF);

    // start transmission
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h1);
    #2us;

    // start counter
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h2*4, 32'h1);
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h2*4, 32'h0);
    #100us;

    // stop transmission
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h0);
    #2us;

    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
