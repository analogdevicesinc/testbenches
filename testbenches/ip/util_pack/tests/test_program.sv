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
import environment_pkg::*;
import dmac_api_pkg::*;
import watchdog_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, tx_src_axis)::*;
import `PKGIFY(test_harness, tx_dst_axis)::*;
import `PKGIFY(test_harness, rx_src_axis)::*;
import `PKGIFY(test_harness, rx_dst_axis)::*;

program test_program;

  // declare the class instances
  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;
  
  util_pack_environment #(`AXIS_VIP_PARAMS(test_harness, tx_src_axis), `AXIS_VIP_PARAMS(test_harness, tx_dst_axis), `AXIS_VIP_PARAMS(test_harness, rx_src_axis), `AXIS_VIP_PARAMS(test_harness, rx_dst_axis)) pack_env;

  watchdog packer_scoreboard_wd;

  dmac_api dmac_tx;
  dmac_api dmac_rx;
  
  int data_length = $urandom_range(5, 10) * `WIDTH * `CHANNELS * `SAMPLES / 8 * 2**int($clog2(`CHANNELS));

  initial begin

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

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

    pack_env = new("Util Pack Environment",
                    `TH.`TX_SRC_AXIS.inst.IF,
                    `TH.`TX_DST_AXIS.inst.IF,
                    `TH.`RX_SRC_AXIS.inst.IF,
                    `TH.`RX_DST_AXIS.inst.IF);

    dmac_tx = new("DMAC TX 0", base_env.mng.master_sequencer, `TX_DMA_BA);
    dmac_rx = new("DMAC RX 0", base_env.mng.master_sequencer, `RX_DMA_BA);

    base_env.start();
    pack_env.start();

    base_env.sys_reset();

    // configure environment sequencers
    pack_env.configure(data_length);

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
    pack_env.tx_src_axis_agent.sequencer.start();
    pack_env.rx_src_axis_agent.sequencer.start();

    // prepare watchdog with 20 us of wait time
    packer_scoreboard_wd = new("Packer watchdog", 20000, "Packers Scoreboard");
    packer_scoreboard_wd.start();

    #1us;

    // wait for scoreboards to finish
    fork
      pack_env.scoreboard_rx.wait_until_complete();
      pack_env.scoreboard_tx.wait_until_complete();
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

    dmac_rx.set_flags('b110);
    dmac_rx.set_lengths(xfer_length - 1, 0);
    dmac_rx.transfer_start();
  endtask

  task tx_dma_transfer(
    input int xfer_length);

    dmac_tx.set_flags('b010);
    dmac_tx.set_lengths(xfer_length - 1, 0);
    dmac_tx.transfer_start();
  endtask

endprogram
