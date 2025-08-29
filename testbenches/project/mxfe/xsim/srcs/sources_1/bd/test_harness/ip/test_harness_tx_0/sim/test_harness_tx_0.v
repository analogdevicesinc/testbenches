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


// IP VLNV: analog.com:user:jesd204_tx:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module test_harness_tx_0 (
  clk,
  reset,
  device_clk,
  device_reset,
  phy_data,
  phy_charisk,
  phy_header,
  sysref,
  lmfc_edge,
  lmfc_clk,
  tx_data,
  tx_ready,
  tx_eof,
  tx_sof,
  tx_somf,
  tx_eomf,
  tx_valid,
  cfg_lanes_disable,
  cfg_links_disable,
  cfg_octets_per_multiframe,
  cfg_octets_per_frame,
  cfg_continuous_cgs,
  cfg_continuous_ilas,
  cfg_skip_ilas,
  cfg_mframes_per_ilas,
  cfg_disable_char_replacement,
  cfg_disable_scrambler,
  device_cfg_octets_per_multiframe,
  device_cfg_octets_per_frame,
  device_cfg_beats_per_multiframe,
  device_cfg_lmfc_offset,
  device_cfg_sysref_oneshot,
  device_cfg_sysref_disable,
  device_event_sysref_edge,
  device_event_sysref_alignment_error,
  status_sync,
  status_state,
  status_synth_params0,
  status_synth_params1,
  status_synth_params2
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME tx_cfg_tx_ilas_config_tx_event_tx_status_tx_ctrl_signal_clock, ASSOCIATED_BUSIF tx_cfg:tx_ilas_config:tx_event:tx_status:tx_ctrl, ASSOCIATED_RESET reset, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN test_harness_util_mxfe_xcvr_0_tx_out_clk_0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 tx_cfg_tx_ilas_config_tx_event_tx_status_tx_ctrl_signal_clock CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME tx_cfg_tx_ilas_config_tx_event_tx_status_tx_ctrl_signal_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 tx_cfg_tx_ilas_config_tx_event_tx_status_tx_ctrl_signal_reset RST" *)
input wire reset;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME tx_data_signal_clock, ASSOCIATED_BUSIF tx_data, ASSOCIATED_RESET device_reset, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 tx_data_signal_clock CLK" *)
input wire device_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME tx_data_signal_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 tx_data_signal_reset RST" *)
input wire device_reset;
(* X_INTERFACE_INFO = "xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy0 txdata [63:0] [63:0], xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy1 txdata [63:0] [127:64], xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy2 txdata [63:0] [191:128], xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy3 txdata [63:0] [255:192]" *)
output wire [255 : 0] phy_data;
(* X_INTERFACE_INFO = "xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy0 txcharisk [7:0] [7:0], xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy1 txcharisk [7:0] [15:8], xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy2 txcharisk [7:0] [23:16], xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy3 txcharisk [7:0] [31:24]" *)
output wire [31 : 0] phy_charisk;
(* X_INTERFACE_INFO = "xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy0 txheader [1:0] [1:0], xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy1 txheader [1:0] [3:2], xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy2 txheader [1:0] [5:4], xilinx.com:display_jesd204:jesd204_tx_bus:1.0 tx_phy3 txheader [1:0] [7:6]" *)
output wire [7 : 0] phy_header;
input wire sysref;
output wire lmfc_edge;
output wire lmfc_clk;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 tx_data TDATA" *)
input wire [383 : 0] tx_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 tx_data TREADY" *)
output wire tx_ready;
output wire [11 : 0] tx_eof;
output wire [11 : 0] tx_sof;
output wire [11 : 0] tx_somf;
output wire [11 : 0] tx_eomf;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME tx_data, TDATA_NUM_BYTES 48, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 tx_data TVALID" *)
input wire tx_valid;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg lanes_disable" *)
input wire [3 : 0] cfg_lanes_disable;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg links_disable" *)
input wire [0 : 0] cfg_links_disable;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg octets_per_multiframe" *)
input wire [9 : 0] cfg_octets_per_multiframe;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg octets_per_frame" *)
input wire [7 : 0] cfg_octets_per_frame;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg continuous_cgs" *)
input wire cfg_continuous_cgs;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg continuous_ilas" *)
input wire cfg_continuous_ilas;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg skip_ilas" *)
input wire cfg_skip_ilas;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg mframes_per_ilas" *)
input wire [7 : 0] cfg_mframes_per_ilas;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg disable_char_replacement" *)
input wire cfg_disable_char_replacement;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg disable_scrambler" *)
input wire cfg_disable_scrambler;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg device_octets_per_multiframe" *)
input wire [9 : 0] device_cfg_octets_per_multiframe;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg device_octets_per_frame" *)
input wire [7 : 0] device_cfg_octets_per_frame;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg device_beats_per_multiframe" *)
input wire [7 : 0] device_cfg_beats_per_multiframe;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg device_lmfc_offset" *)
input wire [7 : 0] device_cfg_lmfc_offset;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg device_sysref_oneshot" *)
input wire device_cfg_sysref_oneshot;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_cfg:1.0 tx_cfg device_sysref_disable" *)
input wire device_cfg_sysref_disable;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_event:1.0 tx_event sysref_edge" *)
output wire device_event_sysref_edge;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_event:1.0 tx_event sysref_alignment_error" *)
output wire device_event_sysref_alignment_error;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_status:1.0 tx_status sync" *)
output wire [0 : 0] status_sync;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_status:1.0 tx_status state" *)
output wire [1 : 0] status_state;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_status:1.0 tx_status synth_params0" *)
output wire [31 : 0] status_synth_params0;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_status:1.0 tx_status synth_params1" *)
output wire [31 : 0] status_synth_params1;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_tx_status:1.0 tx_status synth_params2" *)
output wire [31 : 0] status_synth_params2;

  jesd204_tx #(
    .NUM_LANES(4),
    .NUM_LINKS(1),
    .NUM_OUTPUT_PIPELINE(0),
    .LINK_MODE(2),
    .DATA_PATH_WIDTH(8),
    .TPL_DATA_PATH_WIDTH(12),
    .ENABLE_CHAR_REPLACE(1'B0),
    .ASYNC_CLK(1)
  ) inst (
    .clk(clk),
    .reset(reset),
    .device_clk(device_clk),
    .device_reset(device_reset),
    .phy_data(phy_data),
    .phy_charisk(phy_charisk),
    .phy_header(phy_header),
    .sysref(sysref),
    .lmfc_edge(lmfc_edge),
    .lmfc_clk(lmfc_clk),
    .sync(1'B0),
    .tx_data(tx_data),
    .tx_ready(tx_ready),
    .tx_eof(tx_eof),
    .tx_sof(tx_sof),
    .tx_somf(tx_somf),
    .tx_eomf(tx_eomf),
    .tx_valid(tx_valid),
    .cfg_lanes_disable(cfg_lanes_disable),
    .cfg_links_disable(cfg_links_disable),
    .cfg_octets_per_multiframe(cfg_octets_per_multiframe),
    .cfg_octets_per_frame(cfg_octets_per_frame),
    .cfg_continuous_cgs(cfg_continuous_cgs),
    .cfg_continuous_ilas(cfg_continuous_ilas),
    .cfg_skip_ilas(cfg_skip_ilas),
    .cfg_mframes_per_ilas(cfg_mframes_per_ilas),
    .cfg_disable_char_replacement(cfg_disable_char_replacement),
    .cfg_disable_scrambler(cfg_disable_scrambler),
    .device_cfg_octets_per_multiframe(device_cfg_octets_per_multiframe),
    .device_cfg_octets_per_frame(device_cfg_octets_per_frame),
    .device_cfg_beats_per_multiframe(device_cfg_beats_per_multiframe),
    .device_cfg_lmfc_offset(device_cfg_lmfc_offset),
    .device_cfg_sysref_oneshot(device_cfg_sysref_oneshot),
    .device_cfg_sysref_disable(device_cfg_sysref_disable),
    .ilas_config_rd(),
    .ilas_config_addr(),
    .ilas_config_data(256'B0),
    .ctrl_manual_sync_request(1'B0),
    .device_event_sysref_edge(device_event_sysref_edge),
    .device_event_sysref_alignment_error(device_event_sysref_alignment_error),
    .status_sync(status_sync),
    .status_state(status_state),
    .status_synth_params0(status_synth_params0),
    .status_synth_params1(status_synth_params1),
    .status_synth_params2(status_synth_params2)
  );
endmodule
