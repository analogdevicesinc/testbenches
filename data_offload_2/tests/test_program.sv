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

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import m_axis_sequencer_pkg::*;
import logger_pkg::*;

import environment_pkg::*;
import data_offload_pkg::*;

`ifdef HBM_AXI
import `PKGIFY(test_harness, HBM_VIP)::*;
`endif

//=============================================================================
// Register Maps
//=============================================================================

module test_program(
  output  reg       init_req = 1'b0,
  output  reg       sync_ext = 1'b0,
  output  reg       mem_rst_n = 1'b0
);

  //declaring environment instance
  environment                       env;
  xil_axi4stream_ready_gen_policy_t dac_mode;

  data_offload                      dut;

  `ifdef HBM_AXI
  `AGENT(test_harness, HBM_VIP, slv_mem_t) hbm_axi_agent;
  `endif

  initial begin
    //creating environment
    env = new(`TH.`MNG_AXI.inst.IF,
              `TH.`SRC_AXIS.inst.IF,
              `TH.`DST_AXIS.inst.IF
             );

    dut = new(env.mng, `DOFF_BA);

    //=========================================================================
    // Setup generator/monitor stubs
    //=========================================================================

    env.src_axis_seq.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
    for (int i = 0; i < `SRC_TRANSFERS_INITIAL_COUNT; i++)
      env.src_axis_seq.add_xfer_descriptor(`SRC_TRANSFERS_LENGTH, `PATH_TYPE, 0); // Only gen TLAST in TX path

    env.src_axis_seq.start();

    env.dst_axis_seq.set_mode(`DST_READY_MODE);
    env.dst_axis_seq.set_high_time(`DST_READY_HIGH);
    env.dst_axis_seq.set_low_time(`DST_READY_LOW);

    //=========================================================================

    setLoggerVerbosity(250);

    env.scoreboard.set_oneshot(`OFFLOAD_ONESHOT);
    env.scoreboard.set_path_type(`OFFLOAD_PATH_TYPE);

    start_clocks;
    sys_reset;

    #1
    env.start();

    `ifdef HBM_AXI
    if (`MEM_TYPE == 2) begin
      hbm_axi_agent = new("AXI HBM stub agent", `TH.`HBM_AXI.inst.IF);
      hbm_axi_agent.start_slave();
    end
    `endif

    #100
    `INFO(("Bring up IP from reset."));
    systemBringUp;

    // Start the ADC/DAC stubs
    `INFO(("Call the run() ..."));
    env.run();

    init_req <= 1'b1;

    if (!`OFFLOAD_ONESHOT) begin
      @env.src_axis_seq.queue_empty;
      init_req <= 1'b0;
    end

    #`SRC_TRANSFERS_DELAY

    init_req <= 1'b1;

    #100

    for (int i = 0; i < `SRC_TRANSFERS_DELAYED_COUNT; i++)
      env.src_axis_seq.add_xfer_descriptor(`SRC_TRANSFERS_LENGTH, `PATH_TYPE, 0);

    if (!`OFFLOAD_ONESHOT) begin
      @env.src_axis_seq.queue_empty;
      init_req <= 1'b0;
    end

    #`TIME_TO_WAIT

    env.stop();

    stop_clocks;

    `INFO(("Test bench done!"));
    $finish();

  end

  task start_clocks;

    #1
    `TH.`SRC_CLK.inst.IF.start_clock;
    #1
    `TH.`DST_CLK.inst.IF.start_clock;
    #1
    `TH.`SYS_CLK.inst.IF.start_clock;
    #1
    `TH.`MEM_CLK.inst.IF.start_clock;

  endtask

  task stop_clocks;

    `TH.`SRC_CLK.inst.IF.stop_clock;
    `TH.`DST_CLK.inst.IF.stop_clock;
    `TH.`SYS_CLK.inst.IF.stop_clock;
    `TH.`MEM_CLK.inst.IF.stop_clock;

  endtask

  task sys_reset;

    `TH.`SRC_RST.inst.IF.assert_reset;
    `TH.`DST_RST.inst.IF.assert_reset;
    `TH.`SYS_RST.inst.IF.assert_reset;

    #500
    `TH.`SRC_RST.inst.IF.deassert_reset;
    `TH.`DST_RST.inst.IF.deassert_reset;
    `TH.`SYS_RST.inst.IF.deassert_reset;
    mem_rst_n = 1'b1;

  endtask

  task systemBringUp;

    // bring up the Data Offload instances from reset
    `INFO(("Bring up TX Data Offload"));

    dut.set_oneshot(`OFFLOAD_ONESHOT);

`ifdef OFFLOAD_TRANSFER_LENGTH
    dut.set_transfer_length(`OFFLOAD_TRANSFER_LENGTH);
`endif

    dut.set_resetn(1'b1);

  endtask

endmodule
