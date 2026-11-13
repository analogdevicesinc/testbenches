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

module system_tb();

  wire rx_sync_0;

  // On the a5e, software enables the transceiver reference clock with a GPIO
  reg refclk_ready = 1'b0;
  reg refclk_resetn = 1'b0;

  wire [`RX_JESD_L-1:0] serial_data;
  wire [`RX_JESD_L-1:0] serial_data_n;
  wire [`RX_JESD_L-1:0] src_rs_grant;
  wire [`RX_JESD_L-1:0] src_rs_req;
  wire                  pma_cu_clk;
  wire                  syspll_clk;
  wire                  syspll_lock;
  wire [9:0]            refclk_on;
  wire                  refclk_on_ack;
  wire [7:0]            refclk_fail_status;
  wire [9:0]            refclk_status_bus;
  wire [9:0]            refclk_cmd_bus;

  initial #100ns refclk_resetn = 1'b1;

  gts_refclk_reset #(
    .REFCLK_ON_WIDTH   (10),
    .FAIL_STATUS_WIDTH (8)
  ) i_gts_refclk_reset (
    .clk                (ref_clk),
    .resetn             (refclk_resetn),
    .refclk_ready       (refclk_ready),
    .refclk_on_ack      (refclk_on_ack),
    .refclk_fail_status (refclk_fail_status),
    .refclk_on          (refclk_on));

  `TEST_PROGRAM test();

  test_harness `TH (
    .device_clk_out_clk (device_clk),
    .sysref_clk_out_clk (sysref),

    .rx_device_clk_clk  (device_clk),
    .tx_device_clk_clk  (device_clk),
    .rx_sysref_export   (sysref),
    .tx_sysref_export   (sysref),
    .rx_sync_export     (rx_sync_0),
    .tx_sync_export     (rx_sync_0),
    .ref_clk_out_clk    (ref_clk),
    .refclk_xcvr_clk    (ref_clk),
    .rx_ref_clk_clk     (ref_clk),
    .tx_ref_clk_clk     (ref_clk),
    .i_refclk_rdy_data  (refclk_ready),
    .o_syspll_c0_clk    (syspll_clk),
    .o_pll_lock_o_pll_lock (syspll_lock),
    .system_pll_clk_clk (syspll_clk),
    .system_pll_lock_o_pll_lock (syspll_lock),

    .gts_reset_src_rs_priority_src_rs_priority                  ('h0),
    .gts_reset_i_src_rs_req_src_rs_req                          (src_rs_req),
    .gts_reset_o_src_rs_grant_src_rs_grant                      (src_rs_grant),
    .gts_reset_o_pma_cu_clk_clk                                 (pma_cu_clk),
    .gts_reset_i_refclk_on_refclk_on                            (refclk_on),
    .gts_reset_o_refclk_on_ack_refclk_on_ack                    (refclk_on_ack),
    .gts_reset_o_refclk_fail_status_refclk_fail_status          (refclk_fail_status),
    .gts_reset_i_src_rs_refclk_status_bus_refclk_status_bus_out (refclk_status_bus),
    .gts_reset_o_src_rs_refclk_cmd_bus_refclk_cmd_bus_in        (refclk_cmd_bus),

    .jesd204_phy_i_pma_cu_clk_clk                               (pma_cu_clk),
    .jesd204_phy_i_src_rs_grant_src_rs_grant                    (src_rs_grant),
    .jesd204_phy_o_src_rs_req_src_rs_req                        (src_rs_req),
    .jesd204_phy_o_refclk_status_bus_out_refclk_status_bus_out  (refclk_status_bus),
    .jesd204_phy_i_refclk_cmd_bus_in_refclk_cmd_bus_in          (refclk_cmd_bus),

    .tx_serial_data_o_tx_serial_data     (serial_data),
    .tx_serial_data_n_o_tx_serial_data_n (serial_data_n),
    .rx_serial_data_i_rx_serial_data     (serial_data),
    .rx_serial_data_n_i_rx_serial_data_n (serial_data_n),
    .mxfe_gpio_export   (15'd0)
  );

endmodule
