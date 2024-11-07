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

`include "utils.svh"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_dmac_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;

localparam DATA_WIDTH                 = 16;
localparam DATA_DLENGTH               = 16;
localparam NUM_OF_WORDS               = 1;
localparam NUM_OF_TRANSFERS           = 10;

program test_program (
  output       ad7405_adc_clk,
  input        ad7405_adc_data,
  input [15:0] ad7405_filter_dec_ratio);


test_harness_env env;

// --------------------------
// Wrapper function for AXI read verif
// --------------------------
task axi_read_v(
    input   [31:0]  raddr,
    input   [31:0]  vdata);

  env.mng.RegReadVerify32(raddr,vdata);
endtask

task axi_read(
    input   [31:0]  raddr,
    output  [31:0]  data);

  env.mng.RegRead32(raddr,data);
endtask

// --------------------------
// Wrapper function for AXI write
// --------------------------
task axi_write(
  input [31:0]  waddr,
  input [31:0]  wdata);

  env.mng.RegWrite32(waddr,wdata);
endtask

// --------------------------
// Main procedure
// --------------------------
initial begin

  //creating environment
  env = new(`TH.`SYS_CLK.inst.IF,
            `TH.`DMA_CLK.inst.IF,
            `TH.`DDR_CLK.inst.IF,
            `TH.`SYS_RST.inst.IF,
            `TH.`MNG_AXI.inst.IF,
            `TH.`DDR_AXI.inst.IF);

  setLoggerVerbosity(6);
  env.start();

  //asserts all the resets for 100 ns
  `TH.`SYS_RST.inst.IF.assert_reset;
  #100
  `TH.`SYS_RST.inst.IF.deassert_reset;
  #100

  sanity_test();

  //#100

  //data_acquisition_test();

  `INFO(("Test Done"));

  $finish;

end

//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test();
  axi_write (`AXI_AD7405_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
  axi_read_v (`AXI_AD7405_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
  `INFO(("Sanity Test Done"));
endtask

endprogram
