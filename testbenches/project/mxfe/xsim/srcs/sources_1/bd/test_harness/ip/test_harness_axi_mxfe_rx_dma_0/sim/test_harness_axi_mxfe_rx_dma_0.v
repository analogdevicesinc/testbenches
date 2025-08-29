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


// IP VLNV: analog.com:user:axi_dmac:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module test_harness_axi_mxfe_rx_dma_0 (
  s_axi_aclk,
  s_axi_aresetn,
  s_axi_awvalid,
  s_axi_awaddr,
  s_axi_awready,
  s_axi_awprot,
  s_axi_wvalid,
  s_axi_wdata,
  s_axi_wstrb,
  s_axi_wready,
  s_axi_bvalid,
  s_axi_bresp,
  s_axi_bready,
  s_axi_arvalid,
  s_axi_araddr,
  s_axi_arready,
  s_axi_arprot,
  s_axi_rvalid,
  s_axi_rready,
  s_axi_rresp,
  s_axi_rdata,
  irq,
  m_dest_axi_aclk,
  m_dest_axi_aresetn,
  m_dest_axi_awaddr,
  m_dest_axi_awlen,
  m_dest_axi_awsize,
  m_dest_axi_awburst,
  m_dest_axi_awprot,
  m_dest_axi_awcache,
  m_dest_axi_awvalid,
  m_dest_axi_awready,
  m_dest_axi_wdata,
  m_dest_axi_wstrb,
  m_dest_axi_wready,
  m_dest_axi_wvalid,
  m_dest_axi_wlast,
  m_dest_axi_bvalid,
  m_dest_axi_bresp,
  m_dest_axi_bready,
  s_axis_aclk,
  s_axis_ready,
  s_axis_valid,
  s_axis_data,
  s_axis_strb,
  s_axis_keep,
  s_axis_user,
  s_axis_id,
  s_axis_dest,
  s_axis_last,
  s_axis_xfer_req
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
input wire [10 : 0] s_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *)
output wire s_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWPROT" *)
input wire [2 : 0] s_axi_awprot;
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
input wire [10 : 0] s_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *)
output wire s_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARPROT" *)
input wire [2 : 0] s_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *)
output wire s_axi_rvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *)
input wire s_axi_rready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *)
output wire [1 : 0] s_axi_rresp;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 11, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN test_harness_sys_clk_vip_0_clk_out, NUM_READ_THREADS 1, NUM_\
WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *)
output wire [31 : 0] s_axi_rdata;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME irq, SENSITIVITY LEVEL_HIGH, PortWidth 1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 irq INTERRUPT" *)
output wire irq;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_dest_axi_aclk, ASSOCIATED_BUSIF m_dest_axi, ASSOCIATED_RESET m_dest_axi_aresetn, FREQ_HZ 200000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN test_harness_dma_clk_vip_0_clk_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 m_dest_axi_aclk CLK" *)
input wire m_dest_axi_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_dest_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 m_dest_axi_aresetn RST" *)
input wire m_dest_axi_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi AWADDR" *)
output wire [31 : 0] m_dest_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi AWLEN" *)
output wire [7 : 0] m_dest_axi_awlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi AWSIZE" *)
output wire [2 : 0] m_dest_axi_awsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi AWBURST" *)
output wire [1 : 0] m_dest_axi_awburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi AWPROT" *)
output wire [2 : 0] m_dest_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi AWCACHE" *)
output wire [3 : 0] m_dest_axi_awcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi AWVALID" *)
output wire m_dest_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi AWREADY" *)
input wire m_dest_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi WDATA" *)
output wire [511 : 0] m_dest_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi WSTRB" *)
output wire [63 : 0] m_dest_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi WREADY" *)
input wire m_dest_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi WVALID" *)
output wire m_dest_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi WLAST" *)
output wire m_dest_axi_wlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi BVALID" *)
input wire m_dest_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi BRESP" *)
input wire [1 : 0] m_dest_axi_bresp;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_dest_axi, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 512, PROTOCOL AXI4, FREQ_HZ 200000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE WRITE_ONLY, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 0, NUM_READ_OUTSTANDING 0, NUM_WRITE_OUTSTANDING 8, MAX_BURST_LENGTH 64, PHASE 0.0, CLK_DOMAIN test_harness_dma_clk_vip_0_clk_out, NUM_READ_THREADS 1, N\
UM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_dest_axi BREADY" *)
output wire m_dest_axi_bready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_aclk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, ASSOCIATED_BUSIF s_axis, INSERT_VIP 0, XIL_INTERFACENAME s_axis_signal_clock, ASSOCIATED_BUSIF s_axis, FREQ_HZ 200000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN test_harness_dma_clk_vip_0_clk_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axis_aclk CLK, xilinx.com:signal:clock:1.0 s_axis_signal_clock CLK" *)
input wire s_axis_aclk;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TREADY" *)
output wire s_axis_ready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TVALID" *)
input wire s_axis_valid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TDATA" *)
input wire [511 : 0] s_axis_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TSTRB" *)
input wire [63 : 0] s_axis_strb;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TKEEP" *)
input wire [63 : 0] s_axis_keep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TUSER" *)
input wire [0 : 0] s_axis_user;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TID" *)
input wire [7 : 0] s_axis_id;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TDEST" *)
input wire [3 : 0] s_axis_dest;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 64, TDEST_WIDTH 4, TID_WIDTH 8, TUSER_WIDTH 1, HAS_TREADY 1, HAS_TSTRB 1, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 200000000, PHASE 0.0, CLK_DOMAIN test_harness_dma_clk_vip_0_clk_out, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TLAST" *)
input wire s_axis_last;
output wire s_axis_xfer_req;

  axi_dmac #(
    .ID(0),
    .DMA_DATA_WIDTH_SRC(512),
    .DMA_DATA_WIDTH_DEST(512),
    .DMA_DATA_WIDTH_SG(64),
    .DMA_LENGTH_WIDTH(24),
    .DMA_2D_TRANSFER(1'B0),
    .DMA_SG_TRANSFER(1'B0),
    .ASYNC_CLK_REQ_SRC(1'B1),
    .ASYNC_CLK_SRC_DEST(1'B0),
    .ASYNC_CLK_DEST_REQ(1'B1),
    .ASYNC_CLK_REQ_SG(1'B1),
    .ASYNC_CLK_SRC_SG(1'B1),
    .ASYNC_CLK_DEST_SG(1'B1),
    .AXI_SLICE_DEST(1'B1),
    .AXI_SLICE_SRC(1'B1),
    .AXIS_TUSER_SYNC(1'B1),
    .SYNC_TRANSFER_START(1'B0),
    .CYCLIC(1'B0),
    .DMA_AXI_PROTOCOL_DEST(0),
    .DMA_AXI_PROTOCOL_SRC(0),
    .DMA_AXI_PROTOCOL_SG(0),
    .DMA_TYPE_DEST(0),
    .DMA_TYPE_SRC(1),
    .DMA_AXI_ADDR_WIDTH(32),
    .MAX_BYTES_PER_BURST(4096),
    .FIFO_SIZE(8),
    .AXI_ID_WIDTH_SRC(1),
    .AXI_ID_WIDTH_DEST(1),
    .AXI_ID_WIDTH_SG(1),
    .DMA_AXIS_ID_W(8),
    .DMA_AXIS_DEST_W(4),
    .DISABLE_DEBUG_REGISTERS(1'B0),
    .ENABLE_DIAGNOSTICS_IF(1'B0),
    .ALLOW_ASYM_MEM(1),
    .CACHE_COHERENT(1'B0),
    .AXI_AXCACHE(4'B0011),
    .AXI_AXPROT(3'B000),
    .DMA_2D_TLAST_MODE(0),
    .FRAMELOCK(1'B0),
    .MAX_NUM_FRAMES_WIDTH(3),
    .USE_EXT_SYNC(1'B0),
    .AUTORUN(1'B0),
    .AUTORUN_FLAGS(32'H00000000),
    .AUTORUN_SRC_ADDR(32'H00000000),
    .AUTORUN_DEST_ADDR(32'H00000000),
    .AUTORUN_X_LENGTH(32'H00000000),
    .AUTORUN_Y_LENGTH(32'H00000000),
    .AUTORUN_SRC_STRIDE(32'H00000000),
    .AUTORUN_DEST_STRIDE(32'H00000000),
    .AUTORUN_SG_ADDRESS(32'H00000000),
    .AUTORUN_FRAMELOCK_CONFIG(32'H00000000),
    .AUTORUN_FRAMELOCK_STRIDE(32'H00000000)
  ) inst (
    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awready(s_axi_awready),
    .s_axi_awprot(s_axi_awprot),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wready(s_axi_wready),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bready(s_axi_bready),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arready(s_axi_arready),
    .s_axi_arprot(s_axi_arprot),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rdata(s_axi_rdata),
    .irq(irq),
    .sync(1'B1),
    .m_dest_axi_aclk(m_dest_axi_aclk),
    .m_dest_axi_aresetn(m_dest_axi_aresetn),
    .m_dest_axi_awaddr(m_dest_axi_awaddr),
    .m_dest_axi_awlen(m_dest_axi_awlen),
    .m_dest_axi_awsize(m_dest_axi_awsize),
    .m_dest_axi_awburst(m_dest_axi_awburst),
    .m_dest_axi_awprot(m_dest_axi_awprot),
    .m_dest_axi_awcache(m_dest_axi_awcache),
    .m_dest_axi_awvalid(m_dest_axi_awvalid),
    .m_dest_axi_awready(m_dest_axi_awready),
    .m_dest_axi_awid(),
    .m_dest_axi_awlock(),
    .m_dest_axi_wdata(m_dest_axi_wdata),
    .m_dest_axi_wstrb(m_dest_axi_wstrb),
    .m_dest_axi_wready(m_dest_axi_wready),
    .m_dest_axi_wvalid(m_dest_axi_wvalid),
    .m_dest_axi_wlast(m_dest_axi_wlast),
    .m_dest_axi_wid(),
    .m_dest_axi_bvalid(m_dest_axi_bvalid),
    .m_dest_axi_bresp(m_dest_axi_bresp),
    .m_dest_axi_bready(m_dest_axi_bready),
    .m_dest_axi_bid(1'B0),
    .m_dest_axi_arvalid(),
    .m_dest_axi_araddr(),
    .m_dest_axi_arlen(),
    .m_dest_axi_arsize(),
    .m_dest_axi_arburst(),
    .m_dest_axi_arcache(),
    .m_dest_axi_arprot(),
    .m_dest_axi_arready(1'B0),
    .m_dest_axi_rvalid(1'B0),
    .m_dest_axi_rresp(2'B0),
    .m_dest_axi_rdata(512'B0),
    .m_dest_axi_rready(),
    .m_dest_axi_arid(),
    .m_dest_axi_arlock(),
    .m_dest_axi_rid(1'B0),
    .m_dest_axi_rlast(1'B0),
    .m_src_axi_aclk(1'B0),
    .m_src_axi_aresetn(1'B0),
    .m_src_axi_arready(1'B0),
    .m_src_axi_arvalid(),
    .m_src_axi_araddr(),
    .m_src_axi_arlen(),
    .m_src_axi_arsize(),
    .m_src_axi_arburst(),
    .m_src_axi_arprot(),
    .m_src_axi_arcache(),
    .m_src_axi_arid(),
    .m_src_axi_arlock(),
    .m_src_axi_rdata(512'B0),
    .m_src_axi_rready(),
    .m_src_axi_rvalid(1'B0),
    .m_src_axi_rresp(2'B0),
    .m_src_axi_rid(1'B0),
    .m_src_axi_rlast(1'B0),
    .m_src_axi_awvalid(),
    .m_src_axi_awaddr(),
    .m_src_axi_awlen(),
    .m_src_axi_awsize(),
    .m_src_axi_awburst(),
    .m_src_axi_awcache(),
    .m_src_axi_awprot(),
    .m_src_axi_awready(1'B0),
    .m_src_axi_wvalid(),
    .m_src_axi_wdata(),
    .m_src_axi_wstrb(),
    .m_src_axi_wlast(),
    .m_src_axi_wready(1'B0),
    .m_src_axi_bvalid(1'B0),
    .m_src_axi_bresp(2'B0),
    .m_src_axi_bready(),
    .m_src_axi_awid(),
    .m_src_axi_awlock(),
    .m_src_axi_wid(),
    .m_src_axi_bid(1'B0),
    .m_sg_axi_aclk(1'B0),
    .m_sg_axi_aresetn(1'B0),
    .m_sg_axi_arready(1'B0),
    .m_sg_axi_arvalid(),
    .m_sg_axi_araddr(),
    .m_sg_axi_arlen(),
    .m_sg_axi_arsize(),
    .m_sg_axi_arburst(),
    .m_sg_axi_arprot(),
    .m_sg_axi_arcache(),
    .m_sg_axi_arid(),
    .m_sg_axi_arlock(),
    .m_sg_axi_rdata(64'B0),
    .m_sg_axi_rready(),
    .m_sg_axi_rvalid(1'B0),
    .m_sg_axi_rresp(2'B0),
    .m_sg_axi_rid(1'B0),
    .m_sg_axi_rlast(1'B0),
    .m_sg_axi_awvalid(),
    .m_sg_axi_awaddr(),
    .m_sg_axi_awlen(),
    .m_sg_axi_awsize(),
    .m_sg_axi_awburst(),
    .m_sg_axi_awcache(),
    .m_sg_axi_awprot(),
    .m_sg_axi_awready(1'B0),
    .m_sg_axi_wvalid(),
    .m_sg_axi_wdata(),
    .m_sg_axi_wstrb(),
    .m_sg_axi_wlast(),
    .m_sg_axi_wready(1'B0),
    .m_sg_axi_bvalid(1'B0),
    .m_sg_axi_bresp(2'B0),
    .m_sg_axi_bready(),
    .m_sg_axi_awid(),
    .m_sg_axi_awlock(),
    .m_sg_axi_wid(),
    .m_sg_axi_bid(1'B0),
    .s_axis_aclk(s_axis_aclk),
    .s_axis_ready(s_axis_ready),
    .s_axis_valid(s_axis_valid),
    .s_axis_data(s_axis_data),
    .s_axis_strb(s_axis_strb),
    .s_axis_keep(s_axis_keep),
    .s_axis_user(s_axis_user),
    .s_axis_id(s_axis_id),
    .s_axis_dest(s_axis_dest),
    .s_axis_last(s_axis_last),
    .s_axis_xfer_req(s_axis_xfer_req),
    .m_axis_aclk(1'B0),
    .m_axis_ready(1'B0),
    .m_axis_valid(),
    .m_axis_data(),
    .m_axis_strb(),
    .m_axis_keep(),
    .m_axis_user(),
    .m_axis_id(),
    .m_axis_dest(),
    .m_axis_last(),
    .m_axis_xfer_req(),
    .fifo_wr_clk(1'B0),
    .fifo_wr_en(1'B0),
    .fifo_wr_din(512'B0),
    .fifo_wr_overflow(),
    .fifo_wr_xfer_req(),
    .fifo_rd_clk(1'B0),
    .fifo_rd_en(1'B0),
    .fifo_rd_valid(),
    .fifo_rd_dout(),
    .fifo_rd_underflow(),
    .fifo_rd_xfer_req(),
    .m_frame_in(3'B0),
    .m_frame_in_valid(1'B0),
    .m_frame_out(),
    .m_frame_out_valid(),
    .s_frame_in(3'B0),
    .s_frame_in_valid(1'B0),
    .s_frame_out(),
    .s_frame_out_valid(),
    .src_ext_sync(1'B0),
    .dest_ext_sync(1'B0),
    .dest_diag_level_bursts()
  );
endmodule
