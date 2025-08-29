// (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// (c) Copyright 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: analog.com:user:util_cpack2:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module test_harness_util_mxfe_cpack_0 (
  clk,
  reset,
  enable_0,
  enable_1,
  enable_2,
  enable_3,
  fifo_wr_en,
  fifo_wr_overflow,
  fifo_wr_data_0,
  fifo_wr_data_1,
  fifo_wr_data_2,
  fifo_wr_data_3,
  packed_fifo_wr_en,
  packed_fifo_wr_overflow,
  packed_fifo_wr_data,
  packed_sync
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME packed_fifo_wr_signal_clock, ASSOCIATED_BUSIF packed_fifo_wr, ASSOCIATED_RESET reset, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 packed_fifo_wr_signal_clock CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME packed_fifo_wr_signal_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 packed_fifo_wr_signal_reset RST" *)
input wire reset;
input wire enable_0;
input wire enable_1;
input wire enable_2;
input wire enable_3;
input wire fifo_wr_en;
output wire fifo_wr_overflow;
input wire [127 : 0] fifo_wr_data_0;
input wire [127 : 0] fifo_wr_data_1;
input wire [127 : 0] fifo_wr_data_2;
input wire [127 : 0] fifo_wr_data_3;
(* X_INTERFACE_INFO = "analog.com:interface:fifo_wr:1.0 packed_fifo_wr EN" *)
output wire packed_fifo_wr_en;
(* X_INTERFACE_INFO = "analog.com:interface:fifo_wr:1.0 packed_fifo_wr OVERFLOW" *)
input wire packed_fifo_wr_overflow;
(* X_INTERFACE_INFO = "analog.com:interface:fifo_wr:1.0 packed_fifo_wr DATA" *)
output wire [511 : 0] packed_fifo_wr_data;
output wire packed_sync;

  util_cpack2 #(
    .NUM_OF_CHANNELS(4),
    .SAMPLES_PER_CHANNEL(8),
    .SAMPLE_DATA_WIDTH(16)
  ) inst (
    .clk(clk),
    .reset(reset),
    .enable_0(enable_0),
    .enable_1(enable_1),
    .enable_2(enable_2),
    .enable_3(enable_3),
    .enable_4(1'B0),
    .enable_5(1'B0),
    .enable_6(1'B0),
    .enable_7(1'B0),
    .enable_8(1'B0),
    .enable_9(1'B0),
    .enable_10(1'B0),
    .enable_11(1'B0),
    .enable_12(1'B0),
    .enable_13(1'B0),
    .enable_14(1'B0),
    .enable_15(1'B0),
    .enable_16(1'B0),
    .enable_17(1'B0),
    .enable_18(1'B0),
    .enable_19(1'B0),
    .enable_20(1'B0),
    .enable_21(1'B0),
    .enable_22(1'B0),
    .enable_23(1'B0),
    .enable_24(1'B0),
    .enable_25(1'B0),
    .enable_26(1'B0),
    .enable_27(1'B0),
    .enable_28(1'B0),
    .enable_29(1'B0),
    .enable_30(1'B0),
    .enable_31(1'B0),
    .enable_32(1'B0),
    .enable_33(1'B0),
    .enable_34(1'B0),
    .enable_35(1'B0),
    .enable_36(1'B0),
    .enable_37(1'B0),
    .enable_38(1'B0),
    .enable_39(1'B0),
    .enable_40(1'B0),
    .enable_41(1'B0),
    .enable_42(1'B0),
    .enable_43(1'B0),
    .enable_44(1'B0),
    .enable_45(1'B0),
    .enable_46(1'B0),
    .enable_47(1'B0),
    .enable_48(1'B0),
    .enable_49(1'B0),
    .enable_50(1'B0),
    .enable_51(1'B0),
    .enable_52(1'B0),
    .enable_53(1'B0),
    .enable_54(1'B0),
    .enable_55(1'B0),
    .enable_56(1'B0),
    .enable_57(1'B0),
    .enable_58(1'B0),
    .enable_59(1'B0),
    .enable_60(1'B0),
    .enable_61(1'B0),
    .enable_62(1'B0),
    .enable_63(1'B0),
    .fifo_wr_en(fifo_wr_en),
    .fifo_wr_overflow(fifo_wr_overflow),
    .fifo_wr_data_0(fifo_wr_data_0),
    .fifo_wr_data_1(fifo_wr_data_1),
    .fifo_wr_data_2(fifo_wr_data_2),
    .fifo_wr_data_3(fifo_wr_data_3),
    .fifo_wr_data_4(128'B0),
    .fifo_wr_data_5(128'B0),
    .fifo_wr_data_6(128'B0),
    .fifo_wr_data_7(128'B0),
    .fifo_wr_data_8(128'B0),
    .fifo_wr_data_9(128'B0),
    .fifo_wr_data_10(128'B0),
    .fifo_wr_data_11(128'B0),
    .fifo_wr_data_12(128'B0),
    .fifo_wr_data_13(128'B0),
    .fifo_wr_data_14(128'B0),
    .fifo_wr_data_15(128'B0),
    .fifo_wr_data_16(128'B0),
    .fifo_wr_data_17(128'B0),
    .fifo_wr_data_18(128'B0),
    .fifo_wr_data_19(128'B0),
    .fifo_wr_data_20(128'B0),
    .fifo_wr_data_21(128'B0),
    .fifo_wr_data_22(128'B0),
    .fifo_wr_data_23(128'B0),
    .fifo_wr_data_24(128'B0),
    .fifo_wr_data_25(128'B0),
    .fifo_wr_data_26(128'B0),
    .fifo_wr_data_27(128'B0),
    .fifo_wr_data_28(128'B0),
    .fifo_wr_data_29(128'B0),
    .fifo_wr_data_30(128'B0),
    .fifo_wr_data_31(128'B0),
    .fifo_wr_data_32(128'B0),
    .fifo_wr_data_33(128'B0),
    .fifo_wr_data_34(128'B0),
    .fifo_wr_data_35(128'B0),
    .fifo_wr_data_36(128'B0),
    .fifo_wr_data_37(128'B0),
    .fifo_wr_data_38(128'B0),
    .fifo_wr_data_39(128'B0),
    .fifo_wr_data_40(128'B0),
    .fifo_wr_data_41(128'B0),
    .fifo_wr_data_42(128'B0),
    .fifo_wr_data_43(128'B0),
    .fifo_wr_data_44(128'B0),
    .fifo_wr_data_45(128'B0),
    .fifo_wr_data_46(128'B0),
    .fifo_wr_data_47(128'B0),
    .fifo_wr_data_48(128'B0),
    .fifo_wr_data_49(128'B0),
    .fifo_wr_data_50(128'B0),
    .fifo_wr_data_51(128'B0),
    .fifo_wr_data_52(128'B0),
    .fifo_wr_data_53(128'B0),
    .fifo_wr_data_54(128'B0),
    .fifo_wr_data_55(128'B0),
    .fifo_wr_data_56(128'B0),
    .fifo_wr_data_57(128'B0),
    .fifo_wr_data_58(128'B0),
    .fifo_wr_data_59(128'B0),
    .fifo_wr_data_60(128'B0),
    .fifo_wr_data_61(128'B0),
    .fifo_wr_data_62(128'B0),
    .fifo_wr_data_63(128'B0),
    .packed_fifo_wr_en(packed_fifo_wr_en),
    .packed_fifo_wr_overflow(packed_fifo_wr_overflow),
    .packed_fifo_wr_data(packed_fifo_wr_data),
    .packed_sync(packed_sync)
  );
endmodule
