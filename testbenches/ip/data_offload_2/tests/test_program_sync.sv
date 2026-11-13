// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2021-2026 Analog Devices, Inc. All rights reserved.
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

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import environment_pkg::*;
import data_offload_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;
import `PKGIFY(test_harness, src_axis)::*;
import `PKGIFY(test_harness, dst_axis)::*;

`ifdef HBM_AXI
import `PKGIFY(test_harness, HBM_VIP)::*;
`endif

program test_program_sync;

  timeunit 1ns;
  timeprecision 1ps;

  // Declare the class instances
  test_harness_env base_env;
  environment #(`AXIS_VIP_PARAMS(test_harness, src_axis), `AXIS_VIP_PARAMS(test_harness, dst_axis)) test_env;
  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  `ifdef HBM_AXI
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, HBM_VIP)) hbm_axi_agent;
  `endif

  data_offload_api dut;

  // Number of hardware sync pulses issued below (must match the pulse sequence)
  localparam int NUM_SYNC_PULSES = 5;

  // Number of HBM segment masters
  localparam int NUM_M = (`PATH_TYPE == 1 ? `OFFLOAD_DST_DWIDTH : `OFFLOAD_SRC_DWIDTH)
                         / `PLDDR_OFFLOAD_DATA_WIDTH;

  // Effective offload transfer length (falls back to the full buffer when unset)
  `ifdef OFFLOAD_TRANSFER_LENGTH
  localparam int EFF_OFFLOAD_LEN = `OFFLOAD_TRANSFER_LENGTH;
  `else
  localparam int EFF_OFFLOAD_LEN = `OFFLOAD_SIZE;
  `endif

  int                                src_transfers_length;
  int                                src_transfers_delay;
  int                                sync_delay_ns;
  int                                dst_ready_high = 1;
  int                                dst_ready_low  = 3;
  int                                time_to_wait;
  xil_axi4stream_ready_gen_policy_t  dst_ready_mode;

  int                                len_choices[]   = '{512, 1024};
  int                                delay_choices[] = '{10000, 20000};
  xil_axi4stream_ready_gen_policy_t  mode_choices[]  = '{XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE,
                                                         XIL_AXI4STREAM_READY_GEN_OSC};

  initial begin

    // Create environment
    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(`IRQ_C_BA),
      .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

    mng = new(.name(""), .master_vip_if(`TH.`MNG_AXI.inst.IF));
    ddr = new(.name(""), .slave_vip_if(`TH.`DDR_AXI.inst.IF));

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    `ifdef HBM_AXI
    hbm_axi_agent = new(
      .name("AXI HBM stub agent"),
      .slave_vip_if(`TH.`HBM_AXI.inst.IF));
    `endif

    test_env = new(
      .name("Test Environment"),
      .src_axis_vip_if(`TH.`SRC_AXIS.inst.IF),
      .dst_axis_vip_if(`TH.`DST_AXIS.inst.IF),
      .init_req_vip_if(`TH.`INIT_REQ.inst.inst.IF.vif),
      .sync_ext_vip_if(`TH.`SYNC_EXT.inst.inst.IF.vif));

    dut = new(
      .name("Data Offload"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`DOFF_BA));

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    test_env.start();

    `ifdef HBM_AXI
    hbm_axi_agent.start_slave();
    `endif

    start_clocks();
    base_env.sys_reset();

    // Randomize the simulation stimulus
    src_transfers_length = len_choices[$urandom_range(len_choices.size()-1)];
    // One transfer is released per sync pulse, so each transfer must fit the
    // per-pulse offload window. Compute to the largest power-of-two length that fits.
    if (src_transfers_length > EFF_OFFLOAD_LEN) begin
      src_transfers_length = 2 ** $clog2(EFF_OFFLOAD_LEN);
      if (src_transfers_length > EFF_OFFLOAD_LEN) begin
        src_transfers_length /= 2;
      end
    end

    src_transfers_delay = delay_choices[$urandom_range(delay_choices.size()-1)];
    sync_delay_ns       = (`MEM_TYPE == 2) ? (NUM_M * src_transfers_length) : 1000;
    time_to_wait        = (`MEM_TYPE == 2) ? 10000 : 2500;
    dst_ready_mode      = mode_choices [$urandom_range(mode_choices.size() -1)];

    `INFO(("Randomized stimulus: length=%0d delay=%0d sync_delay=%0d time_to_wait=%0d dst_ready_mode=%s",
      src_transfers_length, src_transfers_delay, sync_delay_ns, time_to_wait, dst_ready_mode.name()), ADI_VERBOSITY_LOW);

    // Configure environment sequencers
    test_env.configure(
      .transfer_length(src_transfers_length),
      .transfer_count(NUM_SYNC_PULSES),
      .path_type(`PATH_TYPE),
      .dst_ready_mode(dst_ready_mode),
      .dst_ready_high(dst_ready_high),
      .dst_ready_low(dst_ready_low),
      .oneshot(1));

    test_env.init_req_vip_if.set_io(1'b0);
    test_env.sync_ext_vip_if.set_io(1'b0);

    `INFO(("Bring up IP from reset."), ADI_VERBOSITY_LOW);
    systemBringUp();

    // Start the ADC/DAC stubs
    `INFO(("Call the run() ..."), ADI_VERBOSITY_LOW);
    test_env.run();

    test_env.src_axis_agent.master_sequencer.start();

    test_env.init_req_vip_if.set_io(1'b1);

    repeat (10) test_env.init_req_vip_if.wait_posedge_clk();

    trigger_ext_sync();
    #(sync_delay_ns * 1ns);

    trigger_ext_sync();
    #(sync_delay_ns * 1ns);

    trigger_ext_sync();
    #(sync_delay_ns * 1ns);

    trigger_ext_sync();
    #(sync_delay_ns * 1ns);

    #((src_transfers_delay)*1ns);

    trigger_ext_sync();

    #((time_to_wait)*1ns);

    `ifdef HBM_AXI
    hbm_axi_agent.stop_slave();
    `endif

    test_env.stop();
    base_env.stop();

    stop_clocks();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task start_clocks();
    `TH.`SRC_CLK.inst.IF.start_clock();
    `TH.`DST_CLK.inst.IF.start_clock();
    `ifdef HBM_AXI
    `TH.`MEM_CLK.inst.IF.start_clock();
    `endif
  endtask

  task stop_clocks();
    `TH.`SRC_CLK.inst.IF.stop_clock();
    `TH.`DST_CLK.inst.IF.stop_clock();
    `ifdef HBM_AXI
    `TH.`MEM_CLK.inst.IF.stop_clock();
    `endif
  endtask

  task systemBringUp();
    // Bring up the Data Offload instances from reset
    `INFO(("Bring up Data Offload"), ADI_VERBOSITY_LOW);

    dut.disable_oneshot_mode();
    dut.set_sync_config(2'h1); // Hardware Sync

    `ifdef OFFLOAD_TRANSFER_LENGTH
    dut.set_transfer_length(`OFFLOAD_TRANSFER_LENGTH/64);
    `else
    dut.set_transfer_length(`OFFLOAD_SIZE/64);
    `endif

    dut.deassert_reset();
  endtask

  task trigger_ext_sync();
    test_env.sync_ext_vip_if.set_io(1'b1);
    test_env.sync_ext_vip_if.wait_posedge_clk();
    test_env.sync_ext_vip_if.wait_posedge_clk();
    test_env.sync_ext_vip_if.set_io(1'b0);
  endtask

endprogram
