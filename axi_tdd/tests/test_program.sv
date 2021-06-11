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
import logger_pkg::*;

import environment_pkg::*;
import axi_tdd_pkg::*;

//=============================================================================
// Register Maps
//=============================================================================

module test_program(
  output  reg       tdd_sync = 1'b0
);

  //declaring environment instance
  environment                       env;

  axi_tdd                           dut;

  initial begin
    //creating environment
    env = new(`TH.`MNG_AXI.inst.IF);

    dut = new(env.mng, `TDD_BA);

    setLoggerVerbosity(250);

    start_clocks;
    sys_reset;

    tdd_sync = 1'b0;

    #1
    env.start();

    #100
    `INFO(("Bring up IP from reset."));
    systemBringUp;

    `INFO(("Call the run() ..."));
    env.run();

    #1000

    tdd_sync = 1'b1;
    #10
    tdd_sync = 1'b0;

    #`SIM_WAIT

    env.stop();

    stop_clocks;

    `INFO(("Test bench done!"));
    $finish();

  end

  task start_clocks;
    #1
    `TH.`SYS_CLK.inst.IF.start_clock;
    #1
    `TH.`DEV_CLK.inst.IF.start_clock;
  endtask

  task stop_clocks;
    `TH.`SYS_CLK.inst.IF.stop_clock;
    `TH.`DEV_CLK.inst.IF.stop_clock;
  endtask

  task sys_reset;

    `TH.`SYS_RST.inst.IF.assert_reset;
    `TH.`DEV_RST.inst.IF.assert_reset;

    #500
    `TH.`SYS_RST.inst.IF.deassert_reset;
    `TH.`DEV_RST.inst.IF.deassert_reset;

  endtask

  task systemBringUp;
    automatic bit [31:0] data;

    `INFO(("Bring up TDD Engine"));


    dut.get_core_version(data);
    `INFO(("TDD Version: %x", data));

    dut.get_core_magic(data);
    `INFO(("TDD Core Magic: %x", data));

    dut.set_secondary(`TDD_SECONDARY);

    dut.set_rxonly(1'b0);
    dut.set_txonly(1'b0);

    dut.set_gated_rx_dmapath(`TDD_GATED_DATAPATH);
    dut.set_gated_tx_dmapath(`TDD_GATED_DATAPATH);

    dut.set_frame_length(`TDD_FRAME_LENGTH);
    dut.set_burst_count(`TDD_BURST_COUNT);
    dut.set_counter_init(`TDD_COUNTER_INIT);

    dut.set_terminal_type(`TDD_TERMINAL_TYPE);

    dut.set_primary_slot(
      `TDD_VCO_RX_ON_1,
      `TDD_VCO_RX_OFF_1,
      `TDD_VCO_TX_ON_1,
      `TDD_VCO_TX_OFF_1,
      `TDD_RX_ON_1,
      `TDD_RX_OFF_1,
      `TDD_TX_ON_1,
      `TDD_TX_OFF_1,
      `TDD_RX_DP_ON_1,
      `TDD_RX_DP_OFF_1,
      `TDD_TX_DP_ON_1,
      `TDD_TX_DP_OFF_1);

    dut.set_secondary_slot(
      `TDD_VCO_RX_ON_2,
      `TDD_VCO_RX_OFF_2,
      `TDD_VCO_TX_ON_2,
      `TDD_VCO_TX_OFF_2,
      `TDD_RX_ON_2,
      `TDD_RX_OFF_2,
      `TDD_TX_ON_2,
      `TDD_TX_OFF_2,
      `TDD_RX_DP_ON_2,
      `TDD_RX_DP_OFF_2,
      `TDD_TX_DP_ON_2,
      `TDD_TX_DP_OFF_2);

    dut.set_enabled(1'b1);

  endtask

endmodule
