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


// IP VLNV: analog.com:user:data_offload:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module test_harness_i_data_offload_0 (
  s_axi_aclk,
  s_axi_aresetn,
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
  s_axi_rready,
  s_axi_rresp,
  s_axi_rdata,
  s_axis_aclk,
  s_axis_aresetn,
  s_axis_ready,
  s_axis_valid,
  s_axis_data,
  s_axis_last,
  s_axis_tkeep,
  m_axis_aclk,
  m_axis_aresetn,
  m_axis_ready,
  m_axis_valid,
  m_axis_data,
  m_axis_last,
  m_axis_tkeep,
  init_req,
  sync_ext,
  m_storage_axis_ready,
  m_storage_axis_valid,
  m_storage_axis_data,
  m_storage_axis_last,
  m_storage_axis_tkeep,
  s_storage_axis_ready,
  s_storage_axis_valid,
  s_storage_axis_data,
  s_storage_axis_last,
  s_storage_axis_tkeep,
  wr_request_enable,
  wr_request_valid,
  wr_request_ready,
  wr_request_length,
  wr_response_measured_length,
  wr_response_eot,
  wr_overflow,
  rd_request_enable,
  rd_request_valid,
  rd_request_ready,
  rd_request_length,
  rd_response_eot,
  rd_underflow
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_aclk, ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN test_harness_sys_clk_vip_0_clk_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *)
input wire s_axi_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
input wire s_axi_aresetn;
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
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *)
input wire s_axi_rready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *)
output wire [1 : 0] s_axi_rresp;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 16, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN test_harness_sys_clk_vip_0_clk_out, NUM_READ_THREADS 1, NUM_\
WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *)
output wire [31 : 0] s_axi_rdata;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_storage_axis_s_axis_signal_clock, ASSOCIATED_BUSIF m_storage_axis:s_axis, ASSOCIATED_RESET s_axis_aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 m_storage_axis_s_axis_signal_clock CLK" *)
input wire s_axis_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_storage_axis_s_axis_signal_reset, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 m_storage_axis_s_axis_signal_reset RST" *)
input wire s_axis_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TREADY" *)
output wire s_axis_ready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TVALID" *)
input wire s_axis_valid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TDATA" *)
input wire [511 : 0] s_axis_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TLAST" *)
input wire s_axis_last;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TKEEP" *)
input wire [63 : 0] s_axis_tkeep;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_storage_axis_m_axis_signal_clock, ASSOCIATED_BUSIF s_storage_axis:m_axis, ASSOCIATED_RESET m_axis_aresetn, FREQ_HZ 200000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN test_harness_dma_clk_vip_0_clk_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_storage_axis_m_axis_signal_clock CLK" *)
input wire m_axis_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_storage_axis_m_axis_signal_reset, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_storage_axis_m_axis_signal_reset RST" *)
input wire m_axis_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TREADY" *)
input wire m_axis_ready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *)
output wire m_axis_valid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *)
output wire [511 : 0] m_axis_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TLAST" *)
output wire m_axis_last;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 200000000, PHASE 0.0, CLK_DOMAIN test_harness_dma_clk_vip_0_clk_out, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TKEEP" *)
output wire [63 : 0] m_axis_tkeep;
input wire init_req;
input wire sync_ext;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_storage_axis TREADY" *)
input wire m_storage_axis_ready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_storage_axis TVALID" *)
output wire m_storage_axis_valid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_storage_axis TDATA" *)
output wire [511 : 0] m_storage_axis_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_storage_axis TLAST" *)
output wire m_storage_axis_last;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_storage_axis, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_storage_axis TKEEP" *)
output wire [63 : 0] m_storage_axis_tkeep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_storage_axis TREADY" *)
output wire s_storage_axis_ready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_storage_axis TVALID" *)
input wire s_storage_axis_valid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_storage_axis TDATA" *)
input wire [511 : 0] s_storage_axis_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_storage_axis TLAST" *)
input wire s_storage_axis_last;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_storage_axis, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 200000000, PHASE 0.0, CLK_DOMAIN test_harness_dma_clk_vip_0_clk_out, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_storage_axis TKEEP" *)
input wire [63 : 0] s_storage_axis_tkeep;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 wr_ctrl request_enable" *)
output wire wr_request_enable;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 wr_ctrl request_valid" *)
output wire wr_request_valid;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 wr_ctrl request_ready" *)
input wire wr_request_ready;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 wr_ctrl request_length" *)
output wire [11 : 0] wr_request_length;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 wr_ctrl response_measured_length" *)
input wire [11 : 0] wr_response_measured_length;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 wr_ctrl response_eot" *)
input wire wr_response_eot;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 wr_ctrl status_overflow" *)
input wire wr_overflow;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 rd_ctrl request_enable" *)
output wire rd_request_enable;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 rd_ctrl request_valid" *)
output wire rd_request_valid;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 rd_ctrl request_ready" *)
input wire rd_request_ready;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 rd_ctrl request_length" *)
output wire [11 : 0] rd_request_length;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 rd_ctrl response_eot" *)
input wire rd_response_eot;
(* X_INTERFACE_INFO = "analog.com:interface:if_do_ctrl:1.0 rd_ctrl status_underflow" *)
input wire rd_underflow;

  data_offload #(
    .ID(0),
    .MEM_TYPE(0),
    .MEM_SIZE_LOG2(12),
    .TX_OR_RXN_PATH(0),
    .SRC_DATA_WIDTH(512),
    .DST_DATA_WIDTH(512),
    .DST_CYCLIC_EN(1'B1),
    .AUTO_BRINGUP(1),
    .SYNC_EXT_ADD_INTERNAL_CDC(1'B1),
    .HAS_BYPASS(1'B1)
  ) inst (
    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
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
    .s_axi_rready(s_axi_rready),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rdata(s_axi_rdata),
    .s_axis_aclk(s_axis_aclk),
    .s_axis_aresetn(s_axis_aresetn),
    .s_axis_ready(s_axis_ready),
    .s_axis_valid(s_axis_valid),
    .s_axis_data(s_axis_data),
    .s_axis_last(s_axis_last),
    .s_axis_tkeep(s_axis_tkeep),
    .m_axis_aclk(m_axis_aclk),
    .m_axis_aresetn(m_axis_aresetn),
    .m_axis_ready(m_axis_ready),
    .m_axis_valid(m_axis_valid),
    .m_axis_data(m_axis_data),
    .m_axis_last(m_axis_last),
    .m_axis_tkeep(m_axis_tkeep),
    .init_req(init_req),
    .sync_ext(sync_ext),
    .m_storage_axis_ready(m_storage_axis_ready),
    .m_storage_axis_valid(m_storage_axis_valid),
    .m_storage_axis_data(m_storage_axis_data),
    .m_storage_axis_last(m_storage_axis_last),
    .m_storage_axis_tkeep(m_storage_axis_tkeep),
    .s_storage_axis_ready(s_storage_axis_ready),
    .s_storage_axis_valid(s_storage_axis_valid),
    .s_storage_axis_data(s_storage_axis_data),
    .s_storage_axis_last(s_storage_axis_last),
    .s_storage_axis_tkeep(s_storage_axis_tkeep),
    .wr_request_enable(wr_request_enable),
    .wr_request_valid(wr_request_valid),
    .wr_request_ready(wr_request_ready),
    .wr_request_length(wr_request_length),
    .wr_response_measured_length(wr_response_measured_length),
    .wr_response_eot(wr_response_eot),
    .wr_overflow(wr_overflow),
    .rd_request_enable(rd_request_enable),
    .rd_request_valid(rd_request_valid),
    .rd_request_ready(rd_request_ready),
    .rd_request_length(rd_request_length),
    .rd_response_eot(rd_response_eot),
    .rd_underflow(rd_underflow),
    .ddr_calib_done(1'B0)
  );
endmodule
