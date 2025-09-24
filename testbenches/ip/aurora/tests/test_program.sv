// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2024 Analog Devices, Inc. All rights reserved.
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

import test_harness_env_pkg::*;
import adi_regmap_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program;

  timeunit 1ns;
  timeprecision 1ps;

  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  bit [31:0] val;

  initial begin

    //creating environment
    base_env = new("Base Environment",
                    `TH.`SYS_CLK.inst.IF,
                    `TH.`DMA_CLK.inst.IF,
                    `TH.`DDR_CLK.inst.IF,
                    `TH.`SYS_RST.inst.IF,
                    `TH.`MNG_AXI.inst.IF,
                    `TH.`DDR_AXI.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    base_env.sys_reset();

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));
    `TH.`CONTROLLER_CLK.inst.IF.set_clk_frq(.user_frequency(`CONTROLLER_CLK_RATE*1000000));
    `TH.`NODE_CLK.inst.IF.set_clk_frq(.user_frequency(`NODE_CLK_RATE*1000000));
    `TH.`BRIDGE_CLK.inst.IF.set_clk_frq(.user_frequency(`BRIDGE_CLK_RATE*1000000));

    `TH.`REF_CLK.inst.IF.start_clock();
    `TH.`CONTROLLER_CLK.inst.IF.start_clock();
    `TH.`NODE_CLK.inst.IF.start_clock();
    `TH.`BRIDGE_CLK.inst.IF.start_clock();

    #20us
    `INFO(("Write transaction on AXI_GPIO"), ADI_VERBOSITY_NONE);
    // base_env.mng.sequencer.RegWrite32(`AXI_GPIO_BA + 'h04, 'h0);
    // #5us;
    base_env.mng.sequencer.RegWrite32(`AXI_GPIO_BA, 'h0f0f0f0f);

    `INFO(("End AXI_GPIO transaction"), ADI_VERBOSITY_NONE);

    base_env.stop();

    `TH.`REF_CLK.inst.IF.stop_clock();
    `TH.`CONTROLLER_CLK.inst.IF.stop_clock();
    `TH.`NODE_CLK.inst.IF.stop_clock();
    `TH.`BRIDGE_CLK.inst.IF.stop_clock();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
