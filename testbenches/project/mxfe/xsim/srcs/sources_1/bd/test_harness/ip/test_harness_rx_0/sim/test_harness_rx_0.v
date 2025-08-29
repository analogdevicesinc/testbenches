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


// IP VLNV: analog.com:user:jesd204_rx:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module test_harness_rx_0 (
  clk,
  reset,
  device_clk,
  device_reset,
  phy_data,
  phy_header,
  phy_charisk,
  phy_notintable,
  phy_disperr,
  phy_block_sync,
  sysref,
  lmfc_edge,
  lmfc_clk,
  device_event_sysref_alignment_error,
  device_event_sysref_edge,
  event_frame_alignment_error,
  event_unexpected_lane_state_error,
  rx_data,
  rx_valid,
  rx_eof,
  rx_sof,
  rx_eomf,
  rx_somf,
  cfg_lanes_disable,
  cfg_links_disable,
  cfg_octets_per_multiframe,
  cfg_octets_per_frame,
  cfg_disable_scrambler,
  cfg_disable_char_replacement,
  cfg_frame_align_err_threshold,
  device_cfg_octets_per_multiframe,
  device_cfg_octets_per_frame,
  device_cfg_beats_per_multiframe,
  device_cfg_lmfc_offset,
  device_cfg_sysref_oneshot,
  device_cfg_sysref_disable,
  device_cfg_buffer_early_release,
  device_cfg_buffer_delay,
  ctrl_err_statistics_reset,
  ctrl_err_statistics_mask,
  status_err_statistics_cnt,
  status_ctrl_state,
  status_lane_cgs_state,
  status_lane_ifs_ready,
  status_lane_latency,
  status_lane_emb_state,
  status_lane_frame_align_err_cnt,
  status_synth_params0,
  status_synth_params1,
  status_synth_params2
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rx_cfg_rx_ilas_config_rx_event_rx_status_signal_clock, ASSOCIATED_BUSIF rx_cfg:rx_ilas_config:rx_event:rx_status, ASSOCIATED_RESET reset, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN test_harness_util_mxfe_xcvr_0_rx_out_clk_0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 rx_cfg_rx_ilas_config_rx_event_rx_status_signal_clock CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rx_cfg_rx_ilas_config_rx_event_rx_status_signal_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rx_cfg_rx_ilas_config_rx_event_rx_status_signal_reset RST" *)
input wire reset;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rx_data_signal_clock, ASSOCIATED_BUSIF rx_data, ASSOCIATED_RESET device_reset, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 rx_data_signal_clock CLK" *)
input wire device_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rx_data_signal_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rx_data_signal_reset RST" *)
input wire device_reset;
(* X_INTERFACE_INFO = "xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy0 rxdata [63:0] [63:0], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy1 rxdata [63:0] [127:64], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy2 rxdata [63:0] [191:128], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy3 rxdata [63:0] [255:192]" *)
input wire [255 : 0] phy_data;
(* X_INTERFACE_INFO = "xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy0 rxheader [1:0] [1:0], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy1 rxheader [1:0] [3:2], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy2 rxheader [1:0] [5:4], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy3 rxheader [1:0] [7:6]" *)
input wire [7 : 0] phy_header;
(* X_INTERFACE_INFO = "xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy0 rxcharisk [7:0] [7:0], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy1 rxcharisk [7:0] [15:8], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy2 rxcharisk [7:0] [23:16], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy3 rxcharisk [7:0] [31:24]" *)
input wire [31 : 0] phy_charisk;
(* X_INTERFACE_INFO = "xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy0 rxnotintable [7:0] [7:0], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy1 rxnotintable [7:0] [15:8], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy2 rxnotintable [7:0] [23:16], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy3 rxnotintable [7:0] [31:24]" *)
input wire [31 : 0] phy_notintable;
(* X_INTERFACE_INFO = "xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy0 rxdisperr [7:0] [7:0], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy1 rxdisperr [7:0] [15:8], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy2 rxdisperr [7:0] [23:16], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy3 rxdisperr [7:0] [31:24]" *)
input wire [31 : 0] phy_disperr;
(* X_INTERFACE_INFO = "xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy0 rxblock_sync [0:0] [0:0], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy1 rxblock_sync [0:0] [1:1], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy2 rxblock_sync [0:0] [2:2], xilinx.com:display_jesd204:jesd204_rx_bus:1.0 rx_phy3 rxblock_sync [0:0] [3:3]" *)
input wire [3 : 0] phy_block_sync;
input wire sysref;
output wire lmfc_edge;
output wire lmfc_clk;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_event:1.0 rx_event sysref_alignment_error" *)
output wire device_event_sysref_alignment_error;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_event:1.0 rx_event sysref_edge" *)
output wire device_event_sysref_edge;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_event:1.0 rx_event frame_alignment_error" *)
output wire event_frame_alignment_error;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_event:1.0 rx_event unexpected_lane_state_error" *)
output wire event_unexpected_lane_state_error;
output wire [383 : 0] rx_data;
output wire rx_valid;
output wire [11 : 0] rx_eof;
output wire [11 : 0] rx_sof;
output wire [11 : 0] rx_eomf;
output wire [11 : 0] rx_somf;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg lanes_disable" *)
input wire [3 : 0] cfg_lanes_disable;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg links_disable" *)
input wire [0 : 0] cfg_links_disable;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg octets_per_multiframe" *)
input wire [9 : 0] cfg_octets_per_multiframe;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg octets_per_frame" *)
input wire [7 : 0] cfg_octets_per_frame;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg disable_scrambler" *)
input wire cfg_disable_scrambler;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg disable_char_replacement" *)
input wire cfg_disable_char_replacement;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg frame_align_err_threshold" *)
input wire [7 : 0] cfg_frame_align_err_threshold;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg device_octets_per_multiframe" *)
input wire [9 : 0] device_cfg_octets_per_multiframe;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg device_octets_per_frame" *)
input wire [7 : 0] device_cfg_octets_per_frame;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg device_beats_per_multiframe" *)
input wire [7 : 0] device_cfg_beats_per_multiframe;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg device_lmfc_offset" *)
input wire [7 : 0] device_cfg_lmfc_offset;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg device_sysref_oneshot" *)
input wire device_cfg_sysref_oneshot;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg device_sysref_disable" *)
input wire device_cfg_sysref_disable;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg device_buffer_early_release" *)
input wire device_cfg_buffer_early_release;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg device_buffer_delay" *)
input wire [7 : 0] device_cfg_buffer_delay;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg err_statistics_reset" *)
input wire ctrl_err_statistics_reset;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_cfg:1.0 rx_cfg err_statistics_mask" *)
input wire [6 : 0] ctrl_err_statistics_mask;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_status:1.0 rx_status err_statistics_cnt" *)
output wire [127 : 0] status_err_statistics_cnt;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_status:1.0 rx_status ctrl_state" *)
output wire [1 : 0] status_ctrl_state;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_status:1.0 rx_status lane_cgs_state" *)
output wire [7 : 0] status_lane_cgs_state;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_status:1.0 rx_status lane_ifs_ready" *)
output wire [3 : 0] status_lane_ifs_ready;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_status:1.0 rx_status lane_latency" *)
output wire [55 : 0] status_lane_latency;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_status:1.0 rx_status lane_emb_state" *)
output wire [11 : 0] status_lane_emb_state;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_status:1.0 rx_status lane_frame_align_err_cnt" *)
output wire [31 : 0] status_lane_frame_align_err_cnt;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_status:1.0 rx_status synth_params0" *)
output wire [31 : 0] status_synth_params0;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_status:1.0 rx_status synth_params1" *)
output wire [31 : 0] status_synth_params1;
(* X_INTERFACE_INFO = "analog.com:interface:jesd204_rx_status:1.0 rx_status synth_params2" *)
output wire [31 : 0] status_synth_params2;

  jesd204_rx #(
    .NUM_LANES(4),
    .NUM_LINKS(1),
    .NUM_INPUT_PIPELINE(1),
    .NUM_OUTPUT_PIPELINE(1),
    .LINK_MODE(2),
    .DATA_PATH_WIDTH(8),
    .ENABLE_FRAME_ALIGN_CHECK(1),
    .ENABLE_FRAME_ALIGN_ERR_RESET(0),
    .ENABLE_CHAR_REPLACE(0),
    .ASYNC_CLK(1),
    .TPL_DATA_PATH_WIDTH(12)
  ) inst (
    .clk(clk),
    .reset(reset),
    .device_clk(device_clk),
    .device_reset(device_reset),
    .phy_data(phy_data),
    .phy_header(phy_header),
    .phy_charisk(phy_charisk),
    .phy_notintable(phy_notintable),
    .phy_disperr(phy_disperr),
    .phy_block_sync(phy_block_sync),
    .sysref(sysref),
    .lmfc_edge(lmfc_edge),
    .lmfc_clk(lmfc_clk),
    .device_event_sysref_alignment_error(device_event_sysref_alignment_error),
    .device_event_sysref_edge(device_event_sysref_edge),
    .event_frame_alignment_error(event_frame_alignment_error),
    .event_unexpected_lane_state_error(event_unexpected_lane_state_error),
    .sync(),
    .phy_en_char_align(),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .rx_eof(rx_eof),
    .rx_sof(rx_sof),
    .rx_eomf(rx_eomf),
    .rx_somf(rx_somf),
    .cfg_lanes_disable(cfg_lanes_disable),
    .cfg_links_disable(cfg_links_disable),
    .cfg_octets_per_multiframe(cfg_octets_per_multiframe),
    .cfg_octets_per_frame(cfg_octets_per_frame),
    .cfg_disable_scrambler(cfg_disable_scrambler),
    .cfg_disable_char_replacement(cfg_disable_char_replacement),
    .cfg_frame_align_err_threshold(cfg_frame_align_err_threshold),
    .device_cfg_octets_per_multiframe(device_cfg_octets_per_multiframe),
    .device_cfg_octets_per_frame(device_cfg_octets_per_frame),
    .device_cfg_beats_per_multiframe(device_cfg_beats_per_multiframe),
    .device_cfg_lmfc_offset(device_cfg_lmfc_offset),
    .device_cfg_sysref_oneshot(device_cfg_sysref_oneshot),
    .device_cfg_sysref_disable(device_cfg_sysref_disable),
    .device_cfg_buffer_early_release(device_cfg_buffer_early_release),
    .device_cfg_buffer_delay(device_cfg_buffer_delay),
    .ctrl_err_statistics_reset(ctrl_err_statistics_reset),
    .ctrl_err_statistics_mask(ctrl_err_statistics_mask),
    .status_err_statistics_cnt(status_err_statistics_cnt),
    .ilas_config_valid(),
    .ilas_config_addr(),
    .ilas_config_data(),
    .status_ctrl_state(status_ctrl_state),
    .status_lane_cgs_state(status_lane_cgs_state),
    .status_lane_ifs_ready(status_lane_ifs_ready),
    .status_lane_latency(status_lane_latency),
    .status_lane_emb_state(status_lane_emb_state),
    .status_lane_frame_align_err_cnt(status_lane_frame_align_err_cnt),
    .status_synth_params0(status_synth_params0),
    .status_synth_params1(status_synth_params1),
    .status_synth_params2(status_synth_params2)
  );
endmodule
