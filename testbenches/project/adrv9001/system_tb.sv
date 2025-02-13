// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2018 Analog Devices, Inc. All rights reserved.
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

`timescale 1ns/1ps

`include "utils.svh"

module system_tb();

  reg mssi_sync = 1'b0;

  `TEST_PROGRAM #(
    .CMOS_LVDS_N (`CMOS_LVDS_N),
    .SDR_DDR_N (`SDR_DDR_N),
    .SINGLE_LANE (`SINGLE_LANE),
    .USE_RX_CLK_FOR_TX (`USE_RX_CLK_FOR_TX),
    .SYMB_OP (`SYMB_OP),
    .SYMB_8_16B (`SYMB_8_16B),
    .DDS_DISABLE (`DDS_DISABLE)
  ) test();

  test_harness `TH (
    .ssi_clk_out (ssi_clk),

    .ref_clk (1'b0),
    .mssi_sync (mssi_sync),

    .tx_output_enable (1'b1),

    .rx1_dclk_in_n (tx1_dclk_out_n),
    .rx1_dclk_in_p (tx1_dclk_out_p),
    .rx1_idata_in_n (tx1_idata_out_n),
    .rx1_idata_in_p (tx1_idata_out_p),
    .rx1_qdata_in_n (tx1_qdata_out_n),
    .rx1_qdata_in_p (tx1_qdata_out_p),
    .rx1_strobe_in_n (tx1_strobe_out_n),
    .rx1_strobe_in_p (tx1_strobe_out_p),

    .rx2_dclk_in_n (tx2_dclk_out_n),
    .rx2_dclk_in_p (tx2_dclk_out_p),
    .rx2_idata_in_n (tx2_idata_out_n),
    .rx2_idata_in_p (tx2_idata_out_p),
    .rx2_qdata_in_n (tx2_qdata_out_n),
    .rx2_qdata_in_p (tx2_qdata_out_p),
    .rx2_strobe_in_n (tx2_strobe_out_n),
    .rx2_strobe_in_p (tx2_strobe_out_p),

    .tx1_dclk_out_n (tx1_dclk_out_n),
    .tx1_dclk_out_p (tx1_dclk_out_p),
    .tx1_dclk_in_n (tx1_dclk_in_n),
    .tx1_dclk_in_p (tx1_dclk_in_p),
    .tx1_idata_out_n (tx1_idata_out_n),
    .tx1_idata_out_p (tx1_idata_out_p),
    .tx1_qdata_out_n (tx1_qdata_out_n),
    .tx1_qdata_out_p (tx1_qdata_out_p),
    .tx1_strobe_out_n (tx1_strobe_out_n),
    .tx1_strobe_out_p (tx1_strobe_out_p),

    .tx2_dclk_out_n (tx2_dclk_out_n),
    .tx2_dclk_out_p (tx2_dclk_out_p),
    .tx2_dclk_in_n (tx2_dclk_in_n),
    .tx2_dclk_in_p (tx2_dclk_in_p),
    .tx2_idata_out_n (tx2_idata_out_n),
    .tx2_idata_out_p (tx2_idata_out_p),
    .tx2_qdata_out_n (tx2_qdata_out_n),
    .tx2_qdata_out_p (tx2_qdata_out_p),
    .tx2_strobe_out_n (tx2_strobe_out_n),
    .tx2_strobe_out_p (tx2_strobe_out_p),

    .gpio_rx1_enable_in (1'b1),
    .gpio_rx2_enable_in (1'b1),
    .gpio_tx1_enable_in (1'b1),
    .gpio_tx2_enable_in (1'b1),

    .tdd_sync (1'b0)
  );

  assign tx1_dclk_in_n = ~ssi_clk;
  assign tx1_dclk_in_p = ssi_clk;
  assign tx2_dclk_in_n = ~ssi_clk;
  assign tx2_dclk_in_p = ssi_clk;

  task gen_mssi_sync;
    mssi_sync = 1'b1;
    # 100;
    mssi_sync = 1'b0;
  endtask


endmodule
