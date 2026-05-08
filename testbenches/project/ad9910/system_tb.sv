// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

`timescale 1ns/1ps

module system_tb();

  // Parallel data clock - directly generated in testbench
  reg pd_clk_tb = 1'b0;
  always #2 pd_clk_tb = ~pd_clk_tb;  // 250 MHz

  // SYNC_CLK - simulates clock output from AD9910 chip
  reg sync_clk_tb = 1'b0;
  always #2 sync_clk_tb = ~sync_clk_tb;  // 250 MHz

  // DDS control interface signals
  wire        ad9910_main_reset_tb;
  wire        ad9910_io_reset_tb;
  wire        pw_down_tb;
  reg         ext_sync_tb = 1'b0;
  wire        ad9910_irq_tb;
  wire        trig_out_tb;

  // Ramp control signals
  wire        osk_tb;
  wire        drctl_tb;
  wire        drhold_tb;
  reg         drover_tb = 1'b0;
  reg         sync_smp_err_tb = 1'b0;
  reg         ram_swp_ovr_tb = 1'b0;
  wire [2:0]  profile_tb;
  wire        io_update_tb;

  // Parallel data interface
  wire [17:0] db_o_tb;
  wire        tx_enable_tb;

  // AXI-Stream tready (exposed externally only in DRG mode;
  // in PAR_IF mode the DMA handles flow control internally)
`ifndef TX_DMA
  wire        s_axis_tready_tb;
`endif

  // Test program instantiation
  `TEST_PROGRAM test (
    .pd_clk_tp(pd_clk_tb),
    .sync_clk_tp(sync_clk_tb),
    .main_reset_tp(ad9910_main_reset_tb),
    .io_reset_tp(ad9910_io_reset_tb),
    .pw_down_tp(pw_down_tb),
    .ext_sync_tp(ext_sync_tb),
    .ad9910_irq_tp(ad9910_irq_tb),
    .trig_out_tp(trig_out_tb),
    .osk_tp(osk_tb),
    .drctl_tp(drctl_tb),
    .drhold_tp(drhold_tb),
    .drover_tp(drover_tb),
    .sync_smp_err_tp(sync_smp_err_tb),
    .ram_swp_ovr_tp(ram_swp_ovr_tb),
    .profile_tp(profile_tb),
    .io_update_tp(io_update_tb),
    .db_o_tp(db_o_tb),
    .tx_enable_tp(tx_enable_tb)
  );

  // Test harness instantiation
  test_harness `TH (
    .pd_clk_in(pd_clk_tb),
    .sync_clk_in(sync_clk_tb),
    .ad9910_main_reset(ad9910_main_reset_tb),
    .ad9910_io_reset(ad9910_io_reset_tb),
    .pw_down(pw_down_tb),
    .ext_sync(ext_sync_tb),
    .ad9910_irq(ad9910_irq_tb),
    .trig_out(trig_out_tb),
    .osk(osk_tb),
    .drctl(drctl_tb),
    .drhold(drhold_tb),
    .drover(drover_tb),
    .sync_smp_err(sync_smp_err_tb),
    .ram_swp_ovr(ram_swp_ovr_tb),
    .profile(profile_tb),
    .io_update(io_update_tb),
    .db_o(db_o_tb),
    .tx_enable(tx_enable_tb)
`ifndef TX_DMA
    ,.s_axis_tready(s_axis_tready_tb)
`endif
  );

endmodule
