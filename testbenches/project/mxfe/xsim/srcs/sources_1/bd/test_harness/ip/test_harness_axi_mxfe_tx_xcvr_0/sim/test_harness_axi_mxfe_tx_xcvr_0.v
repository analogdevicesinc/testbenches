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


// IP VLNV: analog.com:user:axi_adxcvr:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module test_harness_axi_mxfe_tx_xcvr_0 (
  up_cm_enb_0,
  up_cm_addr_0,
  up_cm_wr_0,
  up_cm_wdata_0,
  up_cm_rdata_0,
  up_cm_ready_0,
  up_ch_pll_locked_0,
  up_ch_rst_0,
  up_ch_user_ready_0,
  up_ch_rst_done_0,
  up_ch_prbsforceerr_0,
  up_ch_prbssel_0,
  up_ch_prbscntreset_0,
  up_ch_prbserr_0,
  up_ch_prbslocked_0,
  up_ch_bufstatus_0,
  up_ch_bufstatus_rst_0,
  up_ch_lpm_dfe_n_0,
  up_ch_rate_0,
  up_ch_sys_clk_sel_0,
  up_ch_out_clk_sel_0,
  up_ch_tx_diffctrl_0,
  up_ch_tx_postcursor_0,
  up_ch_tx_precursor_0,
  up_ch_enb_0,
  up_ch_addr_0,
  up_ch_wr_0,
  up_ch_wdata_0,
  up_ch_rdata_0,
  up_ch_ready_0,
  up_ch_pll_locked_1,
  up_ch_rst_1,
  up_ch_user_ready_1,
  up_ch_rst_done_1,
  up_ch_prbsforceerr_1,
  up_ch_prbssel_1,
  up_ch_prbscntreset_1,
  up_ch_prbserr_1,
  up_ch_prbslocked_1,
  up_ch_bufstatus_1,
  up_ch_bufstatus_rst_1,
  up_ch_lpm_dfe_n_1,
  up_ch_rate_1,
  up_ch_sys_clk_sel_1,
  up_ch_out_clk_sel_1,
  up_ch_tx_diffctrl_1,
  up_ch_tx_postcursor_1,
  up_ch_tx_precursor_1,
  up_ch_enb_1,
  up_ch_addr_1,
  up_ch_wr_1,
  up_ch_wdata_1,
  up_ch_rdata_1,
  up_ch_ready_1,
  up_ch_pll_locked_2,
  up_ch_rst_2,
  up_ch_user_ready_2,
  up_ch_rst_done_2,
  up_ch_prbsforceerr_2,
  up_ch_prbssel_2,
  up_ch_prbscntreset_2,
  up_ch_prbserr_2,
  up_ch_prbslocked_2,
  up_ch_bufstatus_2,
  up_ch_bufstatus_rst_2,
  up_ch_lpm_dfe_n_2,
  up_ch_rate_2,
  up_ch_sys_clk_sel_2,
  up_ch_out_clk_sel_2,
  up_ch_tx_diffctrl_2,
  up_ch_tx_postcursor_2,
  up_ch_tx_precursor_2,
  up_ch_enb_2,
  up_ch_addr_2,
  up_ch_wr_2,
  up_ch_wdata_2,
  up_ch_rdata_2,
  up_ch_ready_2,
  up_ch_pll_locked_3,
  up_ch_rst_3,
  up_ch_user_ready_3,
  up_ch_rst_done_3,
  up_ch_prbsforceerr_3,
  up_ch_prbssel_3,
  up_ch_prbscntreset_3,
  up_ch_prbserr_3,
  up_ch_prbslocked_3,
  up_ch_bufstatus_3,
  up_ch_bufstatus_rst_3,
  up_ch_lpm_dfe_n_3,
  up_ch_rate_3,
  up_ch_sys_clk_sel_3,
  up_ch_out_clk_sel_3,
  up_ch_tx_diffctrl_3,
  up_ch_tx_postcursor_3,
  up_ch_tx_precursor_3,
  up_ch_enb_3,
  up_ch_addr_3,
  up_ch_wr_3,
  up_ch_wdata_3,
  up_ch_rdata_3,
  up_ch_ready_3,
  s_axi_aclk,
  s_axi_aresetn,
  up_status,
  up_pll_rst,
  s_axi_awvalid,
  s_axi_awaddr,
  s_axi_awprot,
  s_axi_awready,
  s_axi_wvalid,
  s_axi_wdata,
  s_axi_wstrb,
  s_axi_wready,
  s_axi_bvalid,
  s_axi_bresp,
  s_axi_bready,
  s_axi_arvalid,
  s_axi_araddr,
  s_axi_arprot,
  s_axi_arready,
  s_axi_rvalid,
  s_axi_rresp,
  s_axi_rdata,
  s_axi_rready
);

(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_cm:1.0 up_cm_0 enb" *)
output wire up_cm_enb_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_cm:1.0 up_cm_0 addr" *)
output wire [11 : 0] up_cm_addr_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_cm:1.0 up_cm_0 wr" *)
output wire up_cm_wr_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_cm:1.0 up_cm_0 wdata" *)
output wire [15 : 0] up_cm_wdata_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_cm:1.0 up_cm_0 rdata" *)
input wire [15 : 0] up_cm_rdata_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_cm:1.0 up_cm_0 ready" *)
input wire up_cm_ready_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 pll_locked" *)
input wire up_ch_pll_locked_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 rst" *)
output wire up_ch_rst_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 user_ready" *)
output wire up_ch_user_ready_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 rst_done" *)
input wire up_ch_rst_done_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 prbsforceerr" *)
output wire up_ch_prbsforceerr_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 prbssel" *)
output wire [3 : 0] up_ch_prbssel_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 prbscntreset" *)
output wire up_ch_prbscntreset_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 prbserr" *)
input wire up_ch_prbserr_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 prbslocked" *)
input wire up_ch_prbslocked_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 bufstatus" *)
input wire [1 : 0] up_ch_bufstatus_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 bufstatus_rst" *)
output wire up_ch_bufstatus_rst_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 lpm_dfe_n" *)
output wire up_ch_lpm_dfe_n_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 rate" *)
output wire [2 : 0] up_ch_rate_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 sys_clk_sel" *)
output wire [1 : 0] up_ch_sys_clk_sel_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 out_clk_sel" *)
output wire [2 : 0] up_ch_out_clk_sel_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 tx_diffctrl" *)
output wire [4 : 0] up_ch_tx_diffctrl_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 tx_postcursor" *)
output wire [4 : 0] up_ch_tx_postcursor_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 tx_precursor" *)
output wire [4 : 0] up_ch_tx_precursor_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 enb" *)
output wire up_ch_enb_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 addr" *)
output wire [11 : 0] up_ch_addr_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 wr" *)
output wire up_ch_wr_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 wdata" *)
output wire [15 : 0] up_ch_wdata_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 rdata" *)
input wire [15 : 0] up_ch_rdata_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_0 ready" *)
input wire up_ch_ready_0;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 pll_locked" *)
input wire up_ch_pll_locked_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 rst" *)
output wire up_ch_rst_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 user_ready" *)
output wire up_ch_user_ready_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 rst_done" *)
input wire up_ch_rst_done_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 prbsforceerr" *)
output wire up_ch_prbsforceerr_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 prbssel" *)
output wire [3 : 0] up_ch_prbssel_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 prbscntreset" *)
output wire up_ch_prbscntreset_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 prbserr" *)
input wire up_ch_prbserr_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 prbslocked" *)
input wire up_ch_prbslocked_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 bufstatus" *)
input wire [1 : 0] up_ch_bufstatus_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 bufstatus_rst" *)
output wire up_ch_bufstatus_rst_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 lpm_dfe_n" *)
output wire up_ch_lpm_dfe_n_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 rate" *)
output wire [2 : 0] up_ch_rate_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 sys_clk_sel" *)
output wire [1 : 0] up_ch_sys_clk_sel_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 out_clk_sel" *)
output wire [2 : 0] up_ch_out_clk_sel_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 tx_diffctrl" *)
output wire [4 : 0] up_ch_tx_diffctrl_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 tx_postcursor" *)
output wire [4 : 0] up_ch_tx_postcursor_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 tx_precursor" *)
output wire [4 : 0] up_ch_tx_precursor_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 enb" *)
output wire up_ch_enb_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 addr" *)
output wire [11 : 0] up_ch_addr_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 wr" *)
output wire up_ch_wr_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 wdata" *)
output wire [15 : 0] up_ch_wdata_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 rdata" *)
input wire [15 : 0] up_ch_rdata_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_1 ready" *)
input wire up_ch_ready_1;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 pll_locked" *)
input wire up_ch_pll_locked_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 rst" *)
output wire up_ch_rst_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 user_ready" *)
output wire up_ch_user_ready_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 rst_done" *)
input wire up_ch_rst_done_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 prbsforceerr" *)
output wire up_ch_prbsforceerr_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 prbssel" *)
output wire [3 : 0] up_ch_prbssel_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 prbscntreset" *)
output wire up_ch_prbscntreset_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 prbserr" *)
input wire up_ch_prbserr_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 prbslocked" *)
input wire up_ch_prbslocked_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 bufstatus" *)
input wire [1 : 0] up_ch_bufstatus_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 bufstatus_rst" *)
output wire up_ch_bufstatus_rst_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 lpm_dfe_n" *)
output wire up_ch_lpm_dfe_n_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 rate" *)
output wire [2 : 0] up_ch_rate_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 sys_clk_sel" *)
output wire [1 : 0] up_ch_sys_clk_sel_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 out_clk_sel" *)
output wire [2 : 0] up_ch_out_clk_sel_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 tx_diffctrl" *)
output wire [4 : 0] up_ch_tx_diffctrl_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 tx_postcursor" *)
output wire [4 : 0] up_ch_tx_postcursor_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 tx_precursor" *)
output wire [4 : 0] up_ch_tx_precursor_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 enb" *)
output wire up_ch_enb_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 addr" *)
output wire [11 : 0] up_ch_addr_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 wr" *)
output wire up_ch_wr_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 wdata" *)
output wire [15 : 0] up_ch_wdata_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 rdata" *)
input wire [15 : 0] up_ch_rdata_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_2 ready" *)
input wire up_ch_ready_2;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 pll_locked" *)
input wire up_ch_pll_locked_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 rst" *)
output wire up_ch_rst_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 user_ready" *)
output wire up_ch_user_ready_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 rst_done" *)
input wire up_ch_rst_done_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 prbsforceerr" *)
output wire up_ch_prbsforceerr_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 prbssel" *)
output wire [3 : 0] up_ch_prbssel_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 prbscntreset" *)
output wire up_ch_prbscntreset_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 prbserr" *)
input wire up_ch_prbserr_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 prbslocked" *)
input wire up_ch_prbslocked_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 bufstatus" *)
input wire [1 : 0] up_ch_bufstatus_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 bufstatus_rst" *)
output wire up_ch_bufstatus_rst_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 lpm_dfe_n" *)
output wire up_ch_lpm_dfe_n_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 rate" *)
output wire [2 : 0] up_ch_rate_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 sys_clk_sel" *)
output wire [1 : 0] up_ch_sys_clk_sel_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 out_clk_sel" *)
output wire [2 : 0] up_ch_out_clk_sel_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 tx_diffctrl" *)
output wire [4 : 0] up_ch_tx_diffctrl_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 tx_postcursor" *)
output wire [4 : 0] up_ch_tx_postcursor_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 tx_precursor" *)
output wire [4 : 0] up_ch_tx_precursor_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 enb" *)
output wire up_ch_enb_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 addr" *)
output wire [11 : 0] up_ch_addr_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 wr" *)
output wire up_ch_wr_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 wdata" *)
output wire [15 : 0] up_ch_wdata_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 rdata" *)
input wire [15 : 0] up_ch_rdata_3;
(* X_INTERFACE_INFO = "analog.com:interface:if_xcvr_ch:1.0 up_ch_3 ready" *)
input wire up_ch_ready_3;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_aclk, ASSOCIATED_BUSIF s_axi:m_axi, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN test_harness_sys_clk_vip_0_clk_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *)
input wire s_axi_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
input wire s_axi_aresetn;
output wire up_status;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME up_pll_rst, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 up_pll_rst RST" *)
output wire up_pll_rst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *)
input wire s_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *)
input wire [15 : 0] s_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWPROT" *)
input wire [2 : 0] s_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *)
output wire s_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WVALID" *)
input wire s_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WDATA" *)
input wire [31 : 0] s_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WSTRB" *)
input wire [3 : 0] s_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WREADY" *)
output wire s_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BVALID" *)
output wire s_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BRESP" *)
output wire [1 : 0] s_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BREADY" *)
input wire s_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *)
input wire s_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *)
input wire [15 : 0] s_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARPROT" *)
input wire [2 : 0] s_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *)
output wire s_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *)
output wire s_axi_rvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *)
output wire [1 : 0] s_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *)
output wire [31 : 0] s_axi_rdata;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 16, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN test_harness_sys_clk_vip_0_clk_out, NUM_READ_THREADS 1, NUM_\
WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *)
input wire s_axi_rready;

  axi_adxcvr #(
    .ID(0),
    .NUM_OF_LANES(4),
    .XCVR_TYPE(9),
    .LINK_MODE(2),
    .FPGA_TECHNOLOGY(3),
    .FPGA_FAMILY(3),
    .SPEED_GRADE(21),
    .DEV_PACKAGE(2),
    .FPGA_VOLTAGE(850),
    .TX_OR_RX_N(1),
    .QPLL_ENABLE(1),
    .LPM_OR_DFE_N(1),
    .RATE(3'B000),
    .TX_DIFFCTRL(5'B01000),
    .TX_POSTCURSOR(5'B00000),
    .TX_PRECURSOR(5'B00000),
    .SYS_CLK_SEL(2'H3),
    .OUT_CLK_SEL(3'B100)
  ) inst (
    .up_cm_enb_0(up_cm_enb_0),
    .up_cm_addr_0(up_cm_addr_0),
    .up_cm_wr_0(up_cm_wr_0),
    .up_cm_wdata_0(up_cm_wdata_0),
    .up_cm_rdata_0(up_cm_rdata_0),
    .up_cm_ready_0(up_cm_ready_0),
    .up_es_enb_0(),
    .up_es_addr_0(),
    .up_es_wr_0(),
    .up_es_reset_0(),
    .up_es_wdata_0(),
    .up_es_rdata_0(16'B0),
    .up_es_ready_0(1'B0),
    .up_ch_pll_locked_0(up_ch_pll_locked_0),
    .up_ch_rst_0(up_ch_rst_0),
    .up_ch_user_ready_0(up_ch_user_ready_0),
    .up_ch_rst_done_0(up_ch_rst_done_0),
    .up_ch_prbsforceerr_0(up_ch_prbsforceerr_0),
    .up_ch_prbssel_0(up_ch_prbssel_0),
    .up_ch_prbscntreset_0(up_ch_prbscntreset_0),
    .up_ch_prbserr_0(up_ch_prbserr_0),
    .up_ch_prbslocked_0(up_ch_prbslocked_0),
    .up_ch_bufstatus_0(up_ch_bufstatus_0),
    .up_ch_bufstatus_rst_0(up_ch_bufstatus_rst_0),
    .up_ch_lpm_dfe_n_0(up_ch_lpm_dfe_n_0),
    .up_ch_rate_0(up_ch_rate_0),
    .up_ch_sys_clk_sel_0(up_ch_sys_clk_sel_0),
    .up_ch_out_clk_sel_0(up_ch_out_clk_sel_0),
    .up_ch_tx_diffctrl_0(up_ch_tx_diffctrl_0),
    .up_ch_tx_postcursor_0(up_ch_tx_postcursor_0),
    .up_ch_tx_precursor_0(up_ch_tx_precursor_0),
    .up_ch_enb_0(up_ch_enb_0),
    .up_ch_addr_0(up_ch_addr_0),
    .up_ch_wr_0(up_ch_wr_0),
    .up_ch_wdata_0(up_ch_wdata_0),
    .up_ch_rdata_0(up_ch_rdata_0),
    .up_ch_ready_0(up_ch_ready_0),
    .up_es_enb_1(),
    .up_es_addr_1(),
    .up_es_wr_1(),
    .up_es_reset_1(),
    .up_es_wdata_1(),
    .up_es_rdata_1(16'B0),
    .up_es_ready_1(1'B0),
    .up_ch_pll_locked_1(up_ch_pll_locked_1),
    .up_ch_rst_1(up_ch_rst_1),
    .up_ch_user_ready_1(up_ch_user_ready_1),
    .up_ch_rst_done_1(up_ch_rst_done_1),
    .up_ch_prbsforceerr_1(up_ch_prbsforceerr_1),
    .up_ch_prbssel_1(up_ch_prbssel_1),
    .up_ch_prbscntreset_1(up_ch_prbscntreset_1),
    .up_ch_prbserr_1(up_ch_prbserr_1),
    .up_ch_prbslocked_1(up_ch_prbslocked_1),
    .up_ch_bufstatus_1(up_ch_bufstatus_1),
    .up_ch_bufstatus_rst_1(up_ch_bufstatus_rst_1),
    .up_ch_lpm_dfe_n_1(up_ch_lpm_dfe_n_1),
    .up_ch_rate_1(up_ch_rate_1),
    .up_ch_sys_clk_sel_1(up_ch_sys_clk_sel_1),
    .up_ch_out_clk_sel_1(up_ch_out_clk_sel_1),
    .up_ch_tx_diffctrl_1(up_ch_tx_diffctrl_1),
    .up_ch_tx_postcursor_1(up_ch_tx_postcursor_1),
    .up_ch_tx_precursor_1(up_ch_tx_precursor_1),
    .up_ch_enb_1(up_ch_enb_1),
    .up_ch_addr_1(up_ch_addr_1),
    .up_ch_wr_1(up_ch_wr_1),
    .up_ch_wdata_1(up_ch_wdata_1),
    .up_ch_rdata_1(up_ch_rdata_1),
    .up_ch_ready_1(up_ch_ready_1),
    .up_es_enb_2(),
    .up_es_addr_2(),
    .up_es_wr_2(),
    .up_es_reset_2(),
    .up_es_wdata_2(),
    .up_es_rdata_2(16'B0),
    .up_es_ready_2(1'B0),
    .up_ch_pll_locked_2(up_ch_pll_locked_2),
    .up_ch_rst_2(up_ch_rst_2),
    .up_ch_user_ready_2(up_ch_user_ready_2),
    .up_ch_rst_done_2(up_ch_rst_done_2),
    .up_ch_prbsforceerr_2(up_ch_prbsforceerr_2),
    .up_ch_prbssel_2(up_ch_prbssel_2),
    .up_ch_prbscntreset_2(up_ch_prbscntreset_2),
    .up_ch_prbserr_2(up_ch_prbserr_2),
    .up_ch_prbslocked_2(up_ch_prbslocked_2),
    .up_ch_bufstatus_2(up_ch_bufstatus_2),
    .up_ch_bufstatus_rst_2(up_ch_bufstatus_rst_2),
    .up_ch_lpm_dfe_n_2(up_ch_lpm_dfe_n_2),
    .up_ch_rate_2(up_ch_rate_2),
    .up_ch_sys_clk_sel_2(up_ch_sys_clk_sel_2),
    .up_ch_out_clk_sel_2(up_ch_out_clk_sel_2),
    .up_ch_tx_diffctrl_2(up_ch_tx_diffctrl_2),
    .up_ch_tx_postcursor_2(up_ch_tx_postcursor_2),
    .up_ch_tx_precursor_2(up_ch_tx_precursor_2),
    .up_ch_enb_2(up_ch_enb_2),
    .up_ch_addr_2(up_ch_addr_2),
    .up_ch_wr_2(up_ch_wr_2),
    .up_ch_wdata_2(up_ch_wdata_2),
    .up_ch_rdata_2(up_ch_rdata_2),
    .up_ch_ready_2(up_ch_ready_2),
    .up_es_enb_3(),
    .up_es_addr_3(),
    .up_es_wr_3(),
    .up_es_reset_3(),
    .up_es_wdata_3(),
    .up_es_rdata_3(16'B0),
    .up_es_ready_3(1'B0),
    .up_ch_pll_locked_3(up_ch_pll_locked_3),
    .up_ch_rst_3(up_ch_rst_3),
    .up_ch_user_ready_3(up_ch_user_ready_3),
    .up_ch_rst_done_3(up_ch_rst_done_3),
    .up_ch_prbsforceerr_3(up_ch_prbsforceerr_3),
    .up_ch_prbssel_3(up_ch_prbssel_3),
    .up_ch_prbscntreset_3(up_ch_prbscntreset_3),
    .up_ch_prbserr_3(up_ch_prbserr_3),
    .up_ch_prbslocked_3(up_ch_prbslocked_3),
    .up_ch_bufstatus_3(up_ch_bufstatus_3),
    .up_ch_bufstatus_rst_3(up_ch_bufstatus_rst_3),
    .up_ch_lpm_dfe_n_3(up_ch_lpm_dfe_n_3),
    .up_ch_rate_3(up_ch_rate_3),
    .up_ch_sys_clk_sel_3(up_ch_sys_clk_sel_3),
    .up_ch_out_clk_sel_3(up_ch_out_clk_sel_3),
    .up_ch_tx_diffctrl_3(up_ch_tx_diffctrl_3),
    .up_ch_tx_postcursor_3(up_ch_tx_postcursor_3),
    .up_ch_tx_precursor_3(up_ch_tx_precursor_3),
    .up_ch_enb_3(up_ch_enb_3),
    .up_ch_addr_3(up_ch_addr_3),
    .up_ch_wr_3(up_ch_wr_3),
    .up_ch_wdata_3(up_ch_wdata_3),
    .up_ch_rdata_3(up_ch_rdata_3),
    .up_ch_ready_3(up_ch_ready_3),
    .up_cm_enb_4(),
    .up_cm_addr_4(),
    .up_cm_wr_4(),
    .up_cm_wdata_4(),
    .up_cm_rdata_4(16'B0),
    .up_cm_ready_4(1'B0),
    .up_es_enb_4(),
    .up_es_addr_4(),
    .up_es_wr_4(),
    .up_es_reset_4(),
    .up_es_wdata_4(),
    .up_es_rdata_4(16'B0),
    .up_es_ready_4(1'B0),
    .up_ch_pll_locked_4(1'B0),
    .up_ch_rst_4(),
    .up_ch_user_ready_4(),
    .up_ch_rst_done_4(1'B0),
    .up_ch_prbsforceerr_4(),
    .up_ch_prbssel_4(),
    .up_ch_prbscntreset_4(),
    .up_ch_prbserr_4(1'B0),
    .up_ch_prbslocked_4(1'B0),
    .up_ch_bufstatus_4(2'B0),
    .up_ch_bufstatus_rst_4(),
    .up_ch_lpm_dfe_n_4(),
    .up_ch_rate_4(),
    .up_ch_sys_clk_sel_4(),
    .up_ch_out_clk_sel_4(),
    .up_ch_tx_diffctrl_4(),
    .up_ch_tx_postcursor_4(),
    .up_ch_tx_precursor_4(),
    .up_ch_enb_4(),
    .up_ch_addr_4(),
    .up_ch_wr_4(),
    .up_ch_wdata_4(),
    .up_ch_rdata_4(16'B0),
    .up_ch_ready_4(1'B0),
    .up_es_enb_5(),
    .up_es_addr_5(),
    .up_es_wr_5(),
    .up_es_reset_5(),
    .up_es_wdata_5(),
    .up_es_rdata_5(16'B0),
    .up_es_ready_5(1'B0),
    .up_ch_pll_locked_5(1'B0),
    .up_ch_rst_5(),
    .up_ch_user_ready_5(),
    .up_ch_rst_done_5(1'B0),
    .up_ch_prbsforceerr_5(),
    .up_ch_prbssel_5(),
    .up_ch_prbscntreset_5(),
    .up_ch_prbserr_5(1'B0),
    .up_ch_prbslocked_5(1'B0),
    .up_ch_bufstatus_5(2'B0),
    .up_ch_bufstatus_rst_5(),
    .up_ch_lpm_dfe_n_5(),
    .up_ch_rate_5(),
    .up_ch_sys_clk_sel_5(),
    .up_ch_out_clk_sel_5(),
    .up_ch_tx_diffctrl_5(),
    .up_ch_tx_postcursor_5(),
    .up_ch_tx_precursor_5(),
    .up_ch_enb_5(),
    .up_ch_addr_5(),
    .up_ch_wr_5(),
    .up_ch_wdata_5(),
    .up_ch_rdata_5(16'B0),
    .up_ch_ready_5(1'B0),
    .up_es_enb_6(),
    .up_es_addr_6(),
    .up_es_wr_6(),
    .up_es_reset_6(),
    .up_es_wdata_6(),
    .up_es_rdata_6(16'B0),
    .up_es_ready_6(1'B0),
    .up_ch_pll_locked_6(1'B0),
    .up_ch_rst_6(),
    .up_ch_user_ready_6(),
    .up_ch_rst_done_6(1'B0),
    .up_ch_prbsforceerr_6(),
    .up_ch_prbssel_6(),
    .up_ch_prbscntreset_6(),
    .up_ch_prbserr_6(1'B0),
    .up_ch_prbslocked_6(1'B0),
    .up_ch_bufstatus_6(2'B0),
    .up_ch_bufstatus_rst_6(),
    .up_ch_lpm_dfe_n_6(),
    .up_ch_rate_6(),
    .up_ch_sys_clk_sel_6(),
    .up_ch_out_clk_sel_6(),
    .up_ch_tx_diffctrl_6(),
    .up_ch_tx_postcursor_6(),
    .up_ch_tx_precursor_6(),
    .up_ch_enb_6(),
    .up_ch_addr_6(),
    .up_ch_wr_6(),
    .up_ch_wdata_6(),
    .up_ch_rdata_6(16'B0),
    .up_ch_ready_6(1'B0),
    .up_es_enb_7(),
    .up_es_addr_7(),
    .up_es_wr_7(),
    .up_es_reset_7(),
    .up_es_wdata_7(),
    .up_es_rdata_7(16'B0),
    .up_es_ready_7(1'B0),
    .up_ch_pll_locked_7(1'B0),
    .up_ch_rst_7(),
    .up_ch_user_ready_7(),
    .up_ch_rst_done_7(1'B0),
    .up_ch_prbsforceerr_7(),
    .up_ch_prbssel_7(),
    .up_ch_prbscntreset_7(),
    .up_ch_prbserr_7(1'B0),
    .up_ch_prbslocked_7(1'B0),
    .up_ch_bufstatus_7(2'B0),
    .up_ch_bufstatus_rst_7(),
    .up_ch_lpm_dfe_n_7(),
    .up_ch_rate_7(),
    .up_ch_sys_clk_sel_7(),
    .up_ch_out_clk_sel_7(),
    .up_ch_tx_diffctrl_7(),
    .up_ch_tx_postcursor_7(),
    .up_ch_tx_precursor_7(),
    .up_ch_enb_7(),
    .up_ch_addr_7(),
    .up_ch_wr_7(),
    .up_ch_wdata_7(),
    .up_ch_rdata_7(16'B0),
    .up_ch_ready_7(1'B0),
    .up_cm_enb_8(),
    .up_cm_addr_8(),
    .up_cm_wr_8(),
    .up_cm_wdata_8(),
    .up_cm_rdata_8(16'B0),
    .up_cm_ready_8(1'B0),
    .up_es_enb_8(),
    .up_es_addr_8(),
    .up_es_wr_8(),
    .up_es_reset_8(),
    .up_es_wdata_8(),
    .up_es_rdata_8(16'B0),
    .up_es_ready_8(1'B0),
    .up_ch_pll_locked_8(1'B0),
    .up_ch_rst_8(),
    .up_ch_user_ready_8(),
    .up_ch_rst_done_8(1'B0),
    .up_ch_prbsforceerr_8(),
    .up_ch_prbssel_8(),
    .up_ch_prbscntreset_8(),
    .up_ch_prbserr_8(1'B0),
    .up_ch_prbslocked_8(1'B0),
    .up_ch_bufstatus_8(2'B0),
    .up_ch_bufstatus_rst_8(),
    .up_ch_lpm_dfe_n_8(),
    .up_ch_rate_8(),
    .up_ch_sys_clk_sel_8(),
    .up_ch_out_clk_sel_8(),
    .up_ch_tx_diffctrl_8(),
    .up_ch_tx_postcursor_8(),
    .up_ch_tx_precursor_8(),
    .up_ch_enb_8(),
    .up_ch_addr_8(),
    .up_ch_wr_8(),
    .up_ch_wdata_8(),
    .up_ch_rdata_8(16'B0),
    .up_ch_ready_8(1'B0),
    .up_es_enb_9(),
    .up_es_addr_9(),
    .up_es_wr_9(),
    .up_es_reset_9(),
    .up_es_wdata_9(),
    .up_es_rdata_9(16'B0),
    .up_es_ready_9(1'B0),
    .up_ch_pll_locked_9(1'B0),
    .up_ch_rst_9(),
    .up_ch_user_ready_9(),
    .up_ch_rst_done_9(1'B0),
    .up_ch_prbsforceerr_9(),
    .up_ch_prbssel_9(),
    .up_ch_prbscntreset_9(),
    .up_ch_prbserr_9(1'B0),
    .up_ch_prbslocked_9(1'B0),
    .up_ch_bufstatus_9(2'B0),
    .up_ch_bufstatus_rst_9(),
    .up_ch_lpm_dfe_n_9(),
    .up_ch_rate_9(),
    .up_ch_sys_clk_sel_9(),
    .up_ch_out_clk_sel_9(),
    .up_ch_tx_diffctrl_9(),
    .up_ch_tx_postcursor_9(),
    .up_ch_tx_precursor_9(),
    .up_ch_enb_9(),
    .up_ch_addr_9(),
    .up_ch_wr_9(),
    .up_ch_wdata_9(),
    .up_ch_rdata_9(16'B0),
    .up_ch_ready_9(1'B0),
    .up_es_enb_10(),
    .up_es_addr_10(),
    .up_es_wr_10(),
    .up_es_reset_10(),
    .up_es_wdata_10(),
    .up_es_rdata_10(16'B0),
    .up_es_ready_10(1'B0),
    .up_ch_pll_locked_10(1'B0),
    .up_ch_rst_10(),
    .up_ch_user_ready_10(),
    .up_ch_rst_done_10(1'B0),
    .up_ch_prbsforceerr_10(),
    .up_ch_prbssel_10(),
    .up_ch_prbscntreset_10(),
    .up_ch_prbserr_10(1'B0),
    .up_ch_prbslocked_10(1'B0),
    .up_ch_bufstatus_10(2'B0),
    .up_ch_bufstatus_rst_10(),
    .up_ch_lpm_dfe_n_10(),
    .up_ch_rate_10(),
    .up_ch_sys_clk_sel_10(),
    .up_ch_out_clk_sel_10(),
    .up_ch_tx_diffctrl_10(),
    .up_ch_tx_postcursor_10(),
    .up_ch_tx_precursor_10(),
    .up_ch_enb_10(),
    .up_ch_addr_10(),
    .up_ch_wr_10(),
    .up_ch_wdata_10(),
    .up_ch_rdata_10(16'B0),
    .up_ch_ready_10(1'B0),
    .up_es_enb_11(),
    .up_es_addr_11(),
    .up_es_wr_11(),
    .up_es_reset_11(),
    .up_es_wdata_11(),
    .up_es_rdata_11(16'B0),
    .up_es_ready_11(1'B0),
    .up_ch_pll_locked_11(1'B0),
    .up_ch_rst_11(),
    .up_ch_user_ready_11(),
    .up_ch_rst_done_11(1'B0),
    .up_ch_prbsforceerr_11(),
    .up_ch_prbssel_11(),
    .up_ch_prbscntreset_11(),
    .up_ch_prbserr_11(1'B0),
    .up_ch_prbslocked_11(1'B0),
    .up_ch_bufstatus_11(2'B0),
    .up_ch_bufstatus_rst_11(),
    .up_ch_lpm_dfe_n_11(),
    .up_ch_rate_11(),
    .up_ch_sys_clk_sel_11(),
    .up_ch_out_clk_sel_11(),
    .up_ch_tx_diffctrl_11(),
    .up_ch_tx_postcursor_11(),
    .up_ch_tx_precursor_11(),
    .up_ch_enb_11(),
    .up_ch_addr_11(),
    .up_ch_wr_11(),
    .up_ch_wdata_11(),
    .up_ch_rdata_11(16'B0),
    .up_ch_ready_11(1'B0),
    .up_cm_enb_12(),
    .up_cm_addr_12(),
    .up_cm_wr_12(),
    .up_cm_wdata_12(),
    .up_cm_rdata_12(16'B0),
    .up_cm_ready_12(1'B0),
    .up_es_enb_12(),
    .up_es_addr_12(),
    .up_es_wr_12(),
    .up_es_reset_12(),
    .up_es_wdata_12(),
    .up_es_rdata_12(16'B0),
    .up_es_ready_12(1'B0),
    .up_ch_pll_locked_12(1'B0),
    .up_ch_rst_12(),
    .up_ch_user_ready_12(),
    .up_ch_rst_done_12(1'B0),
    .up_ch_prbsforceerr_12(),
    .up_ch_prbssel_12(),
    .up_ch_prbscntreset_12(),
    .up_ch_prbserr_12(1'B0),
    .up_ch_prbslocked_12(1'B0),
    .up_ch_bufstatus_12(2'B0),
    .up_ch_bufstatus_rst_12(),
    .up_ch_lpm_dfe_n_12(),
    .up_ch_rate_12(),
    .up_ch_sys_clk_sel_12(),
    .up_ch_out_clk_sel_12(),
    .up_ch_tx_diffctrl_12(),
    .up_ch_tx_postcursor_12(),
    .up_ch_tx_precursor_12(),
    .up_ch_enb_12(),
    .up_ch_addr_12(),
    .up_ch_wr_12(),
    .up_ch_wdata_12(),
    .up_ch_rdata_12(16'B0),
    .up_ch_ready_12(1'B0),
    .up_es_enb_13(),
    .up_es_addr_13(),
    .up_es_wr_13(),
    .up_es_reset_13(),
    .up_es_wdata_13(),
    .up_es_rdata_13(16'B0),
    .up_es_ready_13(1'B0),
    .up_ch_pll_locked_13(1'B0),
    .up_ch_rst_13(),
    .up_ch_user_ready_13(),
    .up_ch_rst_done_13(1'B0),
    .up_ch_prbsforceerr_13(),
    .up_ch_prbssel_13(),
    .up_ch_prbscntreset_13(),
    .up_ch_prbserr_13(1'B0),
    .up_ch_prbslocked_13(1'B0),
    .up_ch_bufstatus_13(2'B0),
    .up_ch_bufstatus_rst_13(),
    .up_ch_lpm_dfe_n_13(),
    .up_ch_rate_13(),
    .up_ch_sys_clk_sel_13(),
    .up_ch_out_clk_sel_13(),
    .up_ch_tx_diffctrl_13(),
    .up_ch_tx_postcursor_13(),
    .up_ch_tx_precursor_13(),
    .up_ch_enb_13(),
    .up_ch_addr_13(),
    .up_ch_wr_13(),
    .up_ch_wdata_13(),
    .up_ch_rdata_13(16'B0),
    .up_ch_ready_13(1'B0),
    .up_es_enb_14(),
    .up_es_addr_14(),
    .up_es_wr_14(),
    .up_es_reset_14(),
    .up_es_wdata_14(),
    .up_es_rdata_14(16'B0),
    .up_es_ready_14(1'B0),
    .up_ch_pll_locked_14(1'B0),
    .up_ch_rst_14(),
    .up_ch_user_ready_14(),
    .up_ch_rst_done_14(1'B0),
    .up_ch_prbsforceerr_14(),
    .up_ch_prbssel_14(),
    .up_ch_prbscntreset_14(),
    .up_ch_prbserr_14(1'B0),
    .up_ch_prbslocked_14(1'B0),
    .up_ch_bufstatus_14(2'B0),
    .up_ch_bufstatus_rst_14(),
    .up_ch_lpm_dfe_n_14(),
    .up_ch_rate_14(),
    .up_ch_sys_clk_sel_14(),
    .up_ch_out_clk_sel_14(),
    .up_ch_tx_diffctrl_14(),
    .up_ch_tx_postcursor_14(),
    .up_ch_tx_precursor_14(),
    .up_ch_enb_14(),
    .up_ch_addr_14(),
    .up_ch_wr_14(),
    .up_ch_wdata_14(),
    .up_ch_rdata_14(16'B0),
    .up_ch_ready_14(1'B0),
    .up_es_enb_15(),
    .up_es_addr_15(),
    .up_es_wr_15(),
    .up_es_reset_15(),
    .up_es_wdata_15(),
    .up_es_rdata_15(16'B0),
    .up_es_ready_15(1'B0),
    .up_ch_pll_locked_15(1'B0),
    .up_ch_rst_15(),
    .up_ch_user_ready_15(),
    .up_ch_rst_done_15(1'B0),
    .up_ch_prbsforceerr_15(),
    .up_ch_prbssel_15(),
    .up_ch_prbscntreset_15(),
    .up_ch_prbserr_15(1'B0),
    .up_ch_prbslocked_15(1'B0),
    .up_ch_bufstatus_15(2'B0),
    .up_ch_bufstatus_rst_15(),
    .up_ch_lpm_dfe_n_15(),
    .up_ch_rate_15(),
    .up_ch_sys_clk_sel_15(),
    .up_ch_out_clk_sel_15(),
    .up_ch_tx_diffctrl_15(),
    .up_ch_tx_postcursor_15(),
    .up_ch_tx_precursor_15(),
    .up_ch_enb_15(),
    .up_ch_addr_15(),
    .up_ch_wr_15(),
    .up_ch_wdata_15(),
    .up_ch_rdata_15(16'B0),
    .up_ch_ready_15(1'B0),
    .up_cm_enb_16(),
    .up_cm_addr_16(),
    .up_cm_wr_16(),
    .up_cm_wdata_16(),
    .up_cm_rdata_16(16'B0),
    .up_cm_ready_16(1'B0),
    .up_es_enb_16(),
    .up_es_addr_16(),
    .up_es_wr_16(),
    .up_es_reset_16(),
    .up_es_wdata_16(),
    .up_es_rdata_16(16'B0),
    .up_es_ready_16(1'B0),
    .up_ch_pll_locked_16(1'B0),
    .up_ch_rst_16(),
    .up_ch_user_ready_16(),
    .up_ch_rst_done_16(1'B0),
    .up_ch_prbsforceerr_16(),
    .up_ch_prbssel_16(),
    .up_ch_prbscntreset_16(),
    .up_ch_prbserr_16(1'B0),
    .up_ch_prbslocked_16(1'B0),
    .up_ch_bufstatus_16(2'B0),
    .up_ch_bufstatus_rst_16(),
    .up_ch_lpm_dfe_n_16(),
    .up_ch_rate_16(),
    .up_ch_sys_clk_sel_16(),
    .up_ch_out_clk_sel_16(),
    .up_ch_tx_diffctrl_16(),
    .up_ch_tx_postcursor_16(),
    .up_ch_tx_precursor_16(),
    .up_ch_enb_16(),
    .up_ch_addr_16(),
    .up_ch_wr_16(),
    .up_ch_wdata_16(),
    .up_ch_rdata_16(16'B0),
    .up_ch_ready_16(1'B0),
    .up_es_enb_17(),
    .up_es_addr_17(),
    .up_es_wr_17(),
    .up_es_reset_17(),
    .up_es_wdata_17(),
    .up_es_rdata_17(16'B0),
    .up_es_ready_17(1'B0),
    .up_ch_pll_locked_17(1'B0),
    .up_ch_rst_17(),
    .up_ch_user_ready_17(),
    .up_ch_rst_done_17(1'B0),
    .up_ch_prbsforceerr_17(),
    .up_ch_prbssel_17(),
    .up_ch_prbscntreset_17(),
    .up_ch_prbserr_17(1'B0),
    .up_ch_prbslocked_17(1'B0),
    .up_ch_bufstatus_17(2'B0),
    .up_ch_bufstatus_rst_17(),
    .up_ch_lpm_dfe_n_17(),
    .up_ch_rate_17(),
    .up_ch_sys_clk_sel_17(),
    .up_ch_out_clk_sel_17(),
    .up_ch_tx_diffctrl_17(),
    .up_ch_tx_postcursor_17(),
    .up_ch_tx_precursor_17(),
    .up_ch_enb_17(),
    .up_ch_addr_17(),
    .up_ch_wr_17(),
    .up_ch_wdata_17(),
    .up_ch_rdata_17(16'B0),
    .up_ch_ready_17(1'B0),
    .up_es_enb_18(),
    .up_es_addr_18(),
    .up_es_wr_18(),
    .up_es_reset_18(),
    .up_es_wdata_18(),
    .up_es_rdata_18(16'B0),
    .up_es_ready_18(1'B0),
    .up_ch_pll_locked_18(1'B0),
    .up_ch_rst_18(),
    .up_ch_user_ready_18(),
    .up_ch_rst_done_18(1'B0),
    .up_ch_prbsforceerr_18(),
    .up_ch_prbssel_18(),
    .up_ch_prbscntreset_18(),
    .up_ch_prbserr_18(1'B0),
    .up_ch_prbslocked_18(1'B0),
    .up_ch_bufstatus_18(2'B0),
    .up_ch_bufstatus_rst_18(),
    .up_ch_lpm_dfe_n_18(),
    .up_ch_rate_18(),
    .up_ch_sys_clk_sel_18(),
    .up_ch_out_clk_sel_18(),
    .up_ch_tx_diffctrl_18(),
    .up_ch_tx_postcursor_18(),
    .up_ch_tx_precursor_18(),
    .up_ch_enb_18(),
    .up_ch_addr_18(),
    .up_ch_wr_18(),
    .up_ch_wdata_18(),
    .up_ch_rdata_18(16'B0),
    .up_ch_ready_18(1'B0),
    .up_es_enb_19(),
    .up_es_addr_19(),
    .up_es_wr_19(),
    .up_es_reset_19(),
    .up_es_wdata_19(),
    .up_es_rdata_19(16'B0),
    .up_es_ready_19(1'B0),
    .up_ch_pll_locked_19(1'B0),
    .up_ch_rst_19(),
    .up_ch_user_ready_19(),
    .up_ch_rst_done_19(1'B0),
    .up_ch_prbsforceerr_19(),
    .up_ch_prbssel_19(),
    .up_ch_prbscntreset_19(),
    .up_ch_prbserr_19(1'B0),
    .up_ch_prbslocked_19(1'B0),
    .up_ch_bufstatus_19(2'B0),
    .up_ch_bufstatus_rst_19(),
    .up_ch_lpm_dfe_n_19(),
    .up_ch_rate_19(),
    .up_ch_sys_clk_sel_19(),
    .up_ch_out_clk_sel_19(),
    .up_ch_tx_diffctrl_19(),
    .up_ch_tx_postcursor_19(),
    .up_ch_tx_precursor_19(),
    .up_ch_enb_19(),
    .up_ch_addr_19(),
    .up_ch_wr_19(),
    .up_ch_wdata_19(),
    .up_ch_rdata_19(16'B0),
    .up_ch_ready_19(1'B0),
    .up_cm_enb_20(),
    .up_cm_addr_20(),
    .up_cm_wr_20(),
    .up_cm_wdata_20(),
    .up_cm_rdata_20(16'B0),
    .up_cm_ready_20(1'B0),
    .up_es_enb_20(),
    .up_es_addr_20(),
    .up_es_wr_20(),
    .up_es_reset_20(),
    .up_es_wdata_20(),
    .up_es_rdata_20(16'B0),
    .up_es_ready_20(1'B0),
    .up_ch_pll_locked_20(1'B0),
    .up_ch_rst_20(),
    .up_ch_user_ready_20(),
    .up_ch_rst_done_20(1'B0),
    .up_ch_prbsforceerr_20(),
    .up_ch_prbssel_20(),
    .up_ch_prbscntreset_20(),
    .up_ch_prbserr_20(1'B0),
    .up_ch_prbslocked_20(1'B0),
    .up_ch_bufstatus_20(2'B0),
    .up_ch_bufstatus_rst_20(),
    .up_ch_lpm_dfe_n_20(),
    .up_ch_rate_20(),
    .up_ch_sys_clk_sel_20(),
    .up_ch_out_clk_sel_20(),
    .up_ch_tx_diffctrl_20(),
    .up_ch_tx_postcursor_20(),
    .up_ch_tx_precursor_20(),
    .up_ch_enb_20(),
    .up_ch_addr_20(),
    .up_ch_wr_20(),
    .up_ch_wdata_20(),
    .up_ch_rdata_20(16'B0),
    .up_ch_ready_20(1'B0),
    .up_es_enb_21(),
    .up_es_addr_21(),
    .up_es_wr_21(),
    .up_es_reset_21(),
    .up_es_wdata_21(),
    .up_es_rdata_21(16'B0),
    .up_es_ready_21(1'B0),
    .up_ch_pll_locked_21(1'B0),
    .up_ch_rst_21(),
    .up_ch_user_ready_21(),
    .up_ch_rst_done_21(1'B0),
    .up_ch_prbsforceerr_21(),
    .up_ch_prbssel_21(),
    .up_ch_prbscntreset_21(),
    .up_ch_prbserr_21(1'B0),
    .up_ch_prbslocked_21(1'B0),
    .up_ch_bufstatus_21(2'B0),
    .up_ch_bufstatus_rst_21(),
    .up_ch_lpm_dfe_n_21(),
    .up_ch_rate_21(),
    .up_ch_sys_clk_sel_21(),
    .up_ch_out_clk_sel_21(),
    .up_ch_tx_diffctrl_21(),
    .up_ch_tx_postcursor_21(),
    .up_ch_tx_precursor_21(),
    .up_ch_enb_21(),
    .up_ch_addr_21(),
    .up_ch_wr_21(),
    .up_ch_wdata_21(),
    .up_ch_rdata_21(16'B0),
    .up_ch_ready_21(1'B0),
    .up_es_enb_22(),
    .up_es_addr_22(),
    .up_es_wr_22(),
    .up_es_reset_22(),
    .up_es_wdata_22(),
    .up_es_rdata_22(16'B0),
    .up_es_ready_22(1'B0),
    .up_ch_pll_locked_22(1'B0),
    .up_ch_rst_22(),
    .up_ch_user_ready_22(),
    .up_ch_rst_done_22(1'B0),
    .up_ch_prbsforceerr_22(),
    .up_ch_prbssel_22(),
    .up_ch_prbscntreset_22(),
    .up_ch_prbserr_22(1'B0),
    .up_ch_prbslocked_22(1'B0),
    .up_ch_bufstatus_22(2'B0),
    .up_ch_bufstatus_rst_22(),
    .up_ch_lpm_dfe_n_22(),
    .up_ch_rate_22(),
    .up_ch_sys_clk_sel_22(),
    .up_ch_out_clk_sel_22(),
    .up_ch_tx_diffctrl_22(),
    .up_ch_tx_postcursor_22(),
    .up_ch_tx_precursor_22(),
    .up_ch_enb_22(),
    .up_ch_addr_22(),
    .up_ch_wr_22(),
    .up_ch_wdata_22(),
    .up_ch_rdata_22(16'B0),
    .up_ch_ready_22(1'B0),
    .up_es_enb_23(),
    .up_es_addr_23(),
    .up_es_wr_23(),
    .up_es_reset_23(),
    .up_es_wdata_23(),
    .up_es_rdata_23(16'B0),
    .up_es_ready_23(1'B0),
    .up_ch_pll_locked_23(1'B0),
    .up_ch_rst_23(),
    .up_ch_user_ready_23(),
    .up_ch_rst_done_23(1'B0),
    .up_ch_prbsforceerr_23(),
    .up_ch_prbssel_23(),
    .up_ch_prbscntreset_23(),
    .up_ch_prbserr_23(1'B0),
    .up_ch_prbslocked_23(1'B0),
    .up_ch_bufstatus_23(2'B0),
    .up_ch_bufstatus_rst_23(),
    .up_ch_lpm_dfe_n_23(),
    .up_ch_rate_23(),
    .up_ch_sys_clk_sel_23(),
    .up_ch_out_clk_sel_23(),
    .up_ch_tx_diffctrl_23(),
    .up_ch_tx_postcursor_23(),
    .up_ch_tx_precursor_23(),
    .up_ch_enb_23(),
    .up_ch_addr_23(),
    .up_ch_wr_23(),
    .up_ch_wdata_23(),
    .up_ch_rdata_23(16'B0),
    .up_ch_ready_23(1'B0),
    .up_cm_enb_24(),
    .up_cm_addr_24(),
    .up_cm_wr_24(),
    .up_cm_wdata_24(),
    .up_cm_rdata_24(16'B0),
    .up_cm_ready_24(1'B0),
    .up_es_enb_24(),
    .up_es_addr_24(),
    .up_es_wr_24(),
    .up_es_reset_24(),
    .up_es_wdata_24(),
    .up_es_rdata_24(16'B0),
    .up_es_ready_24(1'B0),
    .up_ch_pll_locked_24(1'B0),
    .up_ch_rst_24(),
    .up_ch_user_ready_24(),
    .up_ch_rst_done_24(1'B0),
    .up_ch_prbsforceerr_24(),
    .up_ch_prbssel_24(),
    .up_ch_prbscntreset_24(),
    .up_ch_prbserr_24(1'B0),
    .up_ch_prbslocked_24(1'B0),
    .up_ch_bufstatus_24(2'B0),
    .up_ch_bufstatus_rst_24(),
    .up_ch_lpm_dfe_n_24(),
    .up_ch_rate_24(),
    .up_ch_sys_clk_sel_24(),
    .up_ch_out_clk_sel_24(),
    .up_ch_tx_diffctrl_24(),
    .up_ch_tx_postcursor_24(),
    .up_ch_tx_precursor_24(),
    .up_ch_enb_24(),
    .up_ch_addr_24(),
    .up_ch_wr_24(),
    .up_ch_wdata_24(),
    .up_ch_rdata_24(16'B0),
    .up_ch_ready_24(1'B0),
    .up_es_enb_25(),
    .up_es_addr_25(),
    .up_es_wr_25(),
    .up_es_reset_25(),
    .up_es_wdata_25(),
    .up_es_rdata_25(16'B0),
    .up_es_ready_25(1'B0),
    .up_ch_pll_locked_25(1'B0),
    .up_ch_rst_25(),
    .up_ch_user_ready_25(),
    .up_ch_rst_done_25(1'B0),
    .up_ch_prbsforceerr_25(),
    .up_ch_prbssel_25(),
    .up_ch_prbscntreset_25(),
    .up_ch_prbserr_25(1'B0),
    .up_ch_prbslocked_25(1'B0),
    .up_ch_bufstatus_25(2'B0),
    .up_ch_bufstatus_rst_25(),
    .up_ch_lpm_dfe_n_25(),
    .up_ch_rate_25(),
    .up_ch_sys_clk_sel_25(),
    .up_ch_out_clk_sel_25(),
    .up_ch_tx_diffctrl_25(),
    .up_ch_tx_postcursor_25(),
    .up_ch_tx_precursor_25(),
    .up_ch_enb_25(),
    .up_ch_addr_25(),
    .up_ch_wr_25(),
    .up_ch_wdata_25(),
    .up_ch_rdata_25(16'B0),
    .up_ch_ready_25(1'B0),
    .up_es_enb_26(),
    .up_es_addr_26(),
    .up_es_wr_26(),
    .up_es_reset_26(),
    .up_es_wdata_26(),
    .up_es_rdata_26(16'B0),
    .up_es_ready_26(1'B0),
    .up_ch_pll_locked_26(1'B0),
    .up_ch_rst_26(),
    .up_ch_user_ready_26(),
    .up_ch_rst_done_26(1'B0),
    .up_ch_prbsforceerr_26(),
    .up_ch_prbssel_26(),
    .up_ch_prbscntreset_26(),
    .up_ch_prbserr_26(1'B0),
    .up_ch_prbslocked_26(1'B0),
    .up_ch_bufstatus_26(2'B0),
    .up_ch_bufstatus_rst_26(),
    .up_ch_lpm_dfe_n_26(),
    .up_ch_rate_26(),
    .up_ch_sys_clk_sel_26(),
    .up_ch_out_clk_sel_26(),
    .up_ch_tx_diffctrl_26(),
    .up_ch_tx_postcursor_26(),
    .up_ch_tx_precursor_26(),
    .up_ch_enb_26(),
    .up_ch_addr_26(),
    .up_ch_wr_26(),
    .up_ch_wdata_26(),
    .up_ch_rdata_26(16'B0),
    .up_ch_ready_26(1'B0),
    .up_es_enb_27(),
    .up_es_addr_27(),
    .up_es_wr_27(),
    .up_es_reset_27(),
    .up_es_wdata_27(),
    .up_es_rdata_27(16'B0),
    .up_es_ready_27(1'B0),
    .up_ch_pll_locked_27(1'B0),
    .up_ch_rst_27(),
    .up_ch_user_ready_27(),
    .up_ch_rst_done_27(1'B0),
    .up_ch_prbsforceerr_27(),
    .up_ch_prbssel_27(),
    .up_ch_prbscntreset_27(),
    .up_ch_prbserr_27(1'B0),
    .up_ch_prbslocked_27(1'B0),
    .up_ch_bufstatus_27(2'B0),
    .up_ch_bufstatus_rst_27(),
    .up_ch_lpm_dfe_n_27(),
    .up_ch_rate_27(),
    .up_ch_sys_clk_sel_27(),
    .up_ch_out_clk_sel_27(),
    .up_ch_tx_diffctrl_27(),
    .up_ch_tx_postcursor_27(),
    .up_ch_tx_precursor_27(),
    .up_ch_enb_27(),
    .up_ch_addr_27(),
    .up_ch_wr_27(),
    .up_ch_wdata_27(),
    .up_ch_rdata_27(16'B0),
    .up_ch_ready_27(1'B0),
    .up_cm_enb_28(),
    .up_cm_addr_28(),
    .up_cm_wr_28(),
    .up_cm_wdata_28(),
    .up_cm_rdata_28(16'B0),
    .up_cm_ready_28(1'B0),
    .up_es_enb_28(),
    .up_es_addr_28(),
    .up_es_wr_28(),
    .up_es_reset_28(),
    .up_es_wdata_28(),
    .up_es_rdata_28(16'B0),
    .up_es_ready_28(1'B0),
    .up_ch_pll_locked_28(1'B0),
    .up_ch_rst_28(),
    .up_ch_user_ready_28(),
    .up_ch_rst_done_28(1'B0),
    .up_ch_prbsforceerr_28(),
    .up_ch_prbssel_28(),
    .up_ch_prbscntreset_28(),
    .up_ch_prbserr_28(1'B0),
    .up_ch_prbslocked_28(1'B0),
    .up_ch_bufstatus_28(2'B0),
    .up_ch_bufstatus_rst_28(),
    .up_ch_lpm_dfe_n_28(),
    .up_ch_rate_28(),
    .up_ch_sys_clk_sel_28(),
    .up_ch_out_clk_sel_28(),
    .up_ch_tx_diffctrl_28(),
    .up_ch_tx_postcursor_28(),
    .up_ch_tx_precursor_28(),
    .up_ch_enb_28(),
    .up_ch_addr_28(),
    .up_ch_wr_28(),
    .up_ch_wdata_28(),
    .up_ch_rdata_28(16'B0),
    .up_ch_ready_28(1'B0),
    .up_es_enb_29(),
    .up_es_addr_29(),
    .up_es_wr_29(),
    .up_es_reset_29(),
    .up_es_wdata_29(),
    .up_es_rdata_29(16'B0),
    .up_es_ready_29(1'B0),
    .up_ch_pll_locked_29(1'B0),
    .up_ch_rst_29(),
    .up_ch_user_ready_29(),
    .up_ch_rst_done_29(1'B0),
    .up_ch_prbsforceerr_29(),
    .up_ch_prbssel_29(),
    .up_ch_prbscntreset_29(),
    .up_ch_prbserr_29(1'B0),
    .up_ch_prbslocked_29(1'B0),
    .up_ch_bufstatus_29(2'B0),
    .up_ch_bufstatus_rst_29(),
    .up_ch_lpm_dfe_n_29(),
    .up_ch_rate_29(),
    .up_ch_sys_clk_sel_29(),
    .up_ch_out_clk_sel_29(),
    .up_ch_tx_diffctrl_29(),
    .up_ch_tx_postcursor_29(),
    .up_ch_tx_precursor_29(),
    .up_ch_enb_29(),
    .up_ch_addr_29(),
    .up_ch_wr_29(),
    .up_ch_wdata_29(),
    .up_ch_rdata_29(16'B0),
    .up_ch_ready_29(1'B0),
    .up_es_enb_30(),
    .up_es_addr_30(),
    .up_es_wr_30(),
    .up_es_reset_30(),
    .up_es_wdata_30(),
    .up_es_rdata_30(16'B0),
    .up_es_ready_30(1'B0),
    .up_ch_pll_locked_30(1'B0),
    .up_ch_rst_30(),
    .up_ch_user_ready_30(),
    .up_ch_rst_done_30(1'B0),
    .up_ch_prbsforceerr_30(),
    .up_ch_prbssel_30(),
    .up_ch_prbscntreset_30(),
    .up_ch_prbserr_30(1'B0),
    .up_ch_prbslocked_30(1'B0),
    .up_ch_bufstatus_30(2'B0),
    .up_ch_bufstatus_rst_30(),
    .up_ch_lpm_dfe_n_30(),
    .up_ch_rate_30(),
    .up_ch_sys_clk_sel_30(),
    .up_ch_out_clk_sel_30(),
    .up_ch_tx_diffctrl_30(),
    .up_ch_tx_postcursor_30(),
    .up_ch_tx_precursor_30(),
    .up_ch_enb_30(),
    .up_ch_addr_30(),
    .up_ch_wr_30(),
    .up_ch_wdata_30(),
    .up_ch_rdata_30(16'B0),
    .up_ch_ready_30(1'B0),
    .up_es_enb_31(),
    .up_es_addr_31(),
    .up_es_wr_31(),
    .up_es_reset_31(),
    .up_es_wdata_31(),
    .up_es_rdata_31(16'B0),
    .up_es_ready_31(1'B0),
    .up_ch_pll_locked_31(1'B0),
    .up_ch_rst_31(),
    .up_ch_user_ready_31(),
    .up_ch_rst_done_31(1'B0),
    .up_ch_prbsforceerr_31(),
    .up_ch_prbssel_31(),
    .up_ch_prbscntreset_31(),
    .up_ch_prbserr_31(1'B0),
    .up_ch_prbslocked_31(1'B0),
    .up_ch_bufstatus_31(2'B0),
    .up_ch_bufstatus_rst_31(),
    .up_ch_lpm_dfe_n_31(),
    .up_ch_rate_31(),
    .up_ch_sys_clk_sel_31(),
    .up_ch_out_clk_sel_31(),
    .up_ch_tx_diffctrl_31(),
    .up_ch_tx_postcursor_31(),
    .up_ch_tx_precursor_31(),
    .up_ch_enb_31(),
    .up_ch_addr_31(),
    .up_ch_wr_31(),
    .up_ch_wdata_31(),
    .up_ch_rdata_31(16'B0),
    .up_ch_ready_31(1'B0),
    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
    .up_status(up_status),
    .up_pll_rst(up_pll_rst),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awprot(s_axi_awprot),
    .s_axi_awready(s_axi_awready),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wready(s_axi_wready),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bready(s_axi_bready),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arprot(s_axi_arprot),
    .s_axi_arready(s_axi_arready),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rready(s_axi_rready),
    .m_axi_awvalid(),
    .m_axi_awaddr(),
    .m_axi_awprot(),
    .m_axi_awready(1'B0),
    .m_axi_wvalid(),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wready(1'B0),
    .m_axi_bvalid(1'B0),
    .m_axi_bresp(2'B0),
    .m_axi_bready(),
    .m_axi_arvalid(),
    .m_axi_araddr(),
    .m_axi_arprot(),
    .m_axi_arready(1'B0),
    .m_axi_rvalid(1'B0),
    .m_axi_rdata(32'B0),
    .m_axi_rresp(2'B0),
    .m_axi_rready()
  );
endmodule
