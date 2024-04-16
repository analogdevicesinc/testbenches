// ***************************************************************************
// ***************************************************************************
// Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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
//
//
//
`include "utils.svh"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import environment_pkg::*;
import dmac_api_pkg::*;

program test_program;

  // declare the class instances
  environment env;

  dmac_api dmac_tx;
  dmac_api dmac_rx;

  initial begin

    setLoggerVerbosity(250);

    // create environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF,

              `TH.`TX_SRC_AXIS.inst.IF,
              `TH.`TX_DST_AXIS.inst.IF,
              `TH.`RX_SRC_AXIS.inst.IF,
              `TH.`RX_DST_AXIS.inst.IF
             );

    dmac_tx = new("DMAC TX 0", env.mng, `TX_DMA_BA);
    dmac_rx = new("DMAC RX 0", env.mng, `RX_DMA_BA);

    env.start();
    env.sys_reset();

    // configure environment sequencers
    env.configure(128);

    `INFO(("Bring up IPs from reset."));
    systemBringUp();
    
    // Start the ADC/DAC stubs
    `INFO(("Call the run() ..."));
    env.run();

    // Generate DMA transfers
    `INFO(("Start DMAs"));
    rx_dma_transfer(128);
    tx_dma_transfer(128);

    // #5us;

    env.tx_src_axis_seq.start();
    env.rx_src_axis_seq.start();

    // env.scoreboard_rx.wait_until_complete();
    // env.scoreboard_tx.wait_until_complete();
    
    #1us;

    env.stop();
    
    `INFO(("Test bench done!"));
    $finish();

  end

  task systemBringUp();

    `INFO(("Bring up RX DMAC 0"));
    dmac_rx.enable_dma();
    `INFO(("Bring up TX DMAC 0"));
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
