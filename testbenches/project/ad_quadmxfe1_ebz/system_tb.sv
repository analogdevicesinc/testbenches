// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2025 Analog Devices, Inc. All rights reserved.
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

  wire ref_clk;
  wire device_clk;
  wire sysref;

  wire [3:0] rx_sync;

  wire [15:0] m2c_n;
  wire [15:0] m2c_p;

  wire [15:0] c2m_n;
  wire [15:0] c2m_p;

  reg ext_sync = 1'b0;

  `TEST_PROGRAM test();

  test_harness `TH (
    // clocks are generated in block design with clk_vip
    .ref_clk_out    (ref_clk),
    .device_clk_out (device_clk),
    .sysref_clk_out (sysref),

    .rx_device_clk     (device_clk),      //-dir I
    .tx_device_clk     (device_clk),      //-dir I
        // FMCp
    .rx_data_0_n (m2c_n[10]), // {10 15 8 4 11 9 14 13 12 3 1 2 6 0 7 5}
    .rx_data_0_p (m2c_p[10]),
    .rx_data_1_n (m2c_n[15]),
    .rx_data_1_p (m2c_p[15]),
    .rx_data_2_n (m2c_n[8]),
    .rx_data_2_p (m2c_p[8]),
    .rx_data_3_n (m2c_n[4]),
    .rx_data_3_p (m2c_p[4]),
    .rx_data_4_n (m2c_n[11]),
    .rx_data_4_p (m2c_p[11]),
    .rx_data_5_n (m2c_n[9]),
    .rx_data_5_p (m2c_p[9]),
    .rx_data_6_n (m2c_n[14]),
    .rx_data_6_p (m2c_p[14]),
    .rx_data_7_n (m2c_n[13]),
    .rx_data_7_p (m2c_p[13]),
    .rx_data_8_n (m2c_n[12]),
    .rx_data_8_p (m2c_p[12]),
    .rx_data_9_n (m2c_n[3]),
    .rx_data_9_p (m2c_p[3]),
    .rx_data_10_n (m2c_n[1]),
    .rx_data_10_p (m2c_p[1]),
    .rx_data_11_n (m2c_n[2]),
    .rx_data_11_p (m2c_p[2]),
    .rx_data_12_n (m2c_n[6]),
    .rx_data_12_p (m2c_p[6]),
    .rx_data_13_n (m2c_n[0]),
    .rx_data_13_p (m2c_p[0]),
    .rx_data_14_n (m2c_n[7]),
    .rx_data_14_p (m2c_p[7]),
    .rx_data_15_n (m2c_n[5]),
    .rx_data_15_p (m2c_p[5]),
    .tx_data_0_n (c2m_n[12]), // {12 14 10 4 11 9 8 3 1 2 13 15 6 0 7 5}
    .tx_data_0_p (c2m_p[12]),
    .tx_data_1_n (c2m_n[14]),
    .tx_data_1_p (c2m_p[14]),
    .tx_data_2_n (c2m_n[10]),
    .tx_data_2_p (c2m_p[10]),
    .tx_data_3_n (c2m_n[4]),
    .tx_data_3_p (c2m_p[4]),
    .tx_data_4_n (c2m_n[11]),
    .tx_data_4_p (c2m_p[11]),
    .tx_data_5_n (c2m_n[9]),
    .tx_data_5_p (c2m_p[9]),
    .tx_data_6_n (c2m_n[8]),
    .tx_data_6_p (c2m_p[8]),
    .tx_data_7_n (c2m_n[3]),
    .tx_data_7_p (c2m_p[3]),
    .tx_data_8_n (c2m_n[1]),
    .tx_data_8_p (c2m_p[1]),
    .tx_data_9_n (c2m_n[2]),
    .tx_data_9_p (c2m_p[2]),
    .tx_data_10_n (c2m_n[13]),
    .tx_data_10_p (c2m_p[13]),
    .tx_data_11_n (c2m_n[15]),
    .tx_data_11_p (c2m_p[15]),
    .tx_data_12_n (c2m_n[6]),
    .tx_data_12_p (c2m_p[6]),
    .tx_data_13_n (c2m_n[0]),
    .tx_data_13_p (c2m_p[0]),
    .tx_data_14_n (c2m_n[7]),
    .tx_data_14_p (c2m_p[7]),
    .tx_data_15_n (c2m_n[5]),
    .tx_data_15_p (c2m_p[5]),

    .rx_sysref_0    (sysref),          //-dir I
    .tx_sysref_0    (sysref),          //-dir I
    .rx_sync_0      (rx_sync),         //-dir O
    .tx_sync_0      (rx_sync),         //-dir I
    .ref_clk_q0     (ref_clk),         //-dir I
    .ref_clk_q1     (ref_clk),         //-dir I
    .ref_clk_q2     (ref_clk),         //-dir I
    .ref_clk_q3     (ref_clk),         //-dir I

    .ext_sync (ext_sync) //-dir I

  );

  assign m2c_n = c2m_n;
  assign m2c_p = c2m_p;

  initial begin
    #22us;
    ext_sync =1'b1;
    #10ns;
    ext_sync =1'b0;
    #50us;
    ext_sync =1'b1;
    #10ns;
    ext_sync =1'b0;
  end


endmodule
