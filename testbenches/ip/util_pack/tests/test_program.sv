// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
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
import environment_pkg::*;
import dmac_api_pkg::*;
import watchdog_pkg::*;
import adi_axis_agent_pkg::*;
import adi_axis_packet_pkg::*;
import adi_axis_config_pkg::*;
import adi_axis_rand_config_pkg::*;
import adi_axis_rand_obj_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, tx_src_axis)::*;
import `PKGIFY(test_harness, tx_dst_axis)::*;
import `PKGIFY(test_harness, rx_src_axis)::*;
import `PKGIFY(test_harness, rx_dst_axis)::*;

program test_program;

  timeunit 1ns;
  timeprecision 1ps;

  // declare the class instances
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

  util_pack_environment pack_env;

  adi_axis_master_agent #(`AXIS_VIP_PARAMS(test_harness, tx_src_axis)) tx_src_axis_agent;
  adi_axis_slave_agent #(`AXIS_VIP_PARAMS(test_harness, tx_dst_axis)) tx_dst_axis_agent;
  adi_axis_master_agent #(`AXIS_VIP_PARAMS(test_harness, rx_src_axis)) rx_src_axis_agent;
  adi_axis_slave_agent #(`AXIS_VIP_PARAMS(test_harness, rx_dst_axis)) rx_dst_axis_agent;

  watchdog packer_scoreboard_wd;

  dmac_api dmac_tx;
  dmac_api dmac_rx;

  adi_axis_config axis_cfg_tx;
  adi_axis_rand_config axis_rand_cfg_tx;
  adi_axis_rand_obj axis_rand_obj_tx;
  adi_axis_packet axis_packet_tx;

  adi_axis_config axis_cfg_rx;
  adi_axis_rand_config axis_rand_cfg_rx;
  adi_axis_rand_obj axis_rand_obj_rx;
  adi_axis_packet axis_packet_rx;

  int data_length = $urandom_range(5, 10) * `WIDTH * `CHANNELS * `SAMPLES / 8 * 2**$clog2(`CHANNELS);

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

    pack_env = new("Util Pack Environment");

    tx_src_axis_agent = new("", `TH.`TX_SRC_AXIS.inst.IF);
    tx_dst_axis_agent = new("", `TH.`TX_DST_AXIS.inst.IF);
    rx_src_axis_agent = new("", `TH.`RX_SRC_AXIS.inst.IF);
    rx_dst_axis_agent = new("", `TH.`RX_DST_AXIS.inst.IF);

    `LINK(tx_src_axis_agent, pack_env, tx_src_axis_agent)
    `LINK(tx_dst_axis_agent, pack_env, tx_dst_axis_agent)
    `LINK(rx_src_axis_agent, pack_env, rx_src_axis_agent)
    `LINK(rx_dst_axis_agent, pack_env, rx_dst_axis_agent)

    dmac_tx = new("DMAC TX 0", base_env.mng.master_sequencer, `TX_DMA_BA);
    dmac_rx = new("DMAC RX 0", base_env.mng.master_sequencer, `RX_DMA_BA);

    // TX packet
    axis_cfg_tx = new(`AXIS_TRANSACTION_PARAM(test_harness, tx_src_axis));
    axis_rand_cfg_tx = new();
    axis_rand_obj_tx = new();

    // tdata - ramp
    axis_rand_cfg_tx.TDATA_MODE = 1;

    // tkeep - constant 1
    axis_rand_cfg_tx.TKEEP_MODE = 1;
    axis_rand_obj_tx.tkeep = 1'b1;

    axis_packet_tx = new(
      .bytes_per_packet(data_length),
      .cfg(axis_cfg_tx),
      .rand_cfg(axis_rand_cfg_tx),
      .rand_obj(axis_rand_obj_tx));

    axis_packet_tx.randomize_packet();

    // RX packet
    axis_cfg_rx = new(`AXIS_TRANSACTION_PARAM(test_harness, rx_src_axis));
    axis_rand_cfg_rx = new();
    axis_rand_obj_rx = new();

    // tdata - ramp
    axis_rand_cfg_rx.TDATA_MODE = 1;

    // tkeep - constant 1
    axis_rand_cfg_rx.TKEEP_MODE = 1;
    axis_rand_obj_rx.tkeep = 1'b1;

    axis_packet_rx = new(
      .bytes_per_packet(data_length),
      .cfg(axis_cfg_rx),
      .rand_cfg(axis_rand_cfg_rx),
      .rand_obj(axis_rand_obj_rx));

    axis_packet_rx.randomize_packet();

    pack_env.configure(
      .tx_packet(axis_packet_tx),
      .rx_packet(axis_packet_rx));

    base_env.start();
    pack_env.start();

    base_env.sys_reset();

    // configure environment sequencers

    `INFO(("Bring up IPs from reset."), ADI_VERBOSITY_LOW);
    systemBringUp();

    // Start the ADC/DAC stubs
    `INFO(("Call the run() ..."), ADI_VERBOSITY_LOW);
    pack_env.run();

    // Generate DMA transfers
    `INFO(("Start DMAs"), ADI_VERBOSITY_LOW);
    rx_dma_transfer(data_length);
    tx_dma_transfer(data_length);

    // start generating data
    pack_env.tx_src_axis_agent.master_sequencer.start();
    pack_env.rx_src_axis_agent.master_sequencer.start();
    pack_env.tx_dst_axis_agent.slave_sequencer.start();
    pack_env.rx_dst_axis_agent.slave_sequencer.start();

    // prepare watchdog with 20 us of wait time
    packer_scoreboard_wd = new("Packer watchdog", 20000, "Packers Scoreboard");
    packer_scoreboard_wd.start();

    #1us;

    // wait for scoreboards to finish
    fork
      pack_env.scoreboard_tx.wait_until_complete();
      pack_env.scoreboard_rx.wait_until_complete();
    join

    packer_scoreboard_wd.stop();

    pack_env.stop();
    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task systemBringUp();
    `INFO(("Bring up RX DMAC 0"), ADI_VERBOSITY_LOW);
    dmac_rx.enable_dma();
    `INFO(("Bring up TX DMAC 0"), ADI_VERBOSITY_LOW);
    dmac_tx.enable_dma();
  endtask

  // RX DMA transfer generator

  task rx_dma_transfer(
    input int xfer_length);

    dmac_rx.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    dmac_rx.set_lengths(xfer_length - 1, 0);
    dmac_rx.transfer_start();
  endtask

  task tx_dma_transfer(
    input int xfer_length);

    dmac_rx.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b0));
    dmac_tx.set_lengths(xfer_length - 1, 0);
    dmac_tx.transfer_start();
  endtask

endprogram
