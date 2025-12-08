// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
//
// Test harness for AD9740 DAC
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/1ps

`include "utils.svh"

module test_harness_ad9740 (
  input         ad974x_clk,
  output [13:0] ad974x_data
);

  // System clocks and resets
  wire sys_clk;
  wire sys_rst;
  wire dma_clk;
  wire ddr_clk;

  // AXI interfaces
  wire [`AXI_DATA_WIDTH-1:0]   mng_axi_awaddr;
  wire [2:0]                    mng_axi_awprot;
  wire                          mng_axi_awvalid;
  wire                          mng_axi_awready;
  wire [`AXI_DATA_WIDTH-1:0]   mng_axi_wdata;
  wire [(`AXI_DATA_WIDTH/8)-1:0] mng_axi_wstrb;
  wire                          mng_axi_wvalid;
  wire                          mng_axi_wready;
  wire [1:0]                    mng_axi_bresp;
  wire                          mng_axi_bvalid;
  wire                          mng_axi_bready;
  wire [`AXI_DATA_WIDTH-1:0]   mng_axi_araddr;
  wire [2:0]                    mng_axi_arprot;
  wire                          mng_axi_arvalid;
  wire                          mng_axi_arready;
  wire [`AXI_DATA_WIDTH-1:0]   mng_axi_rdata;
  wire [1:0]                    mng_axi_rresp;
  wire                          mng_axi_rvalid;
  wire                          mng_axi_rready;

  // Instantiate clock generators
  axi_clkgen sys_clkgen (
    .clk(sys_clk),
    .rstn(~sys_rst)
  );

  // Instantiate VIPs
  `AXI_VIP mng_axi_vip (
    .aclk(sys_clk),
    .aresetn(~sys_rst),
    .m_axi_awaddr(mng_axi_awaddr),
    .m_axi_awprot(mng_axi_awprot),
    .m_axi_awvalid(mng_axi_awvalid),
    .m_axi_awready(mng_axi_awready),
    .m_axi_wdata(mng_axi_wdata),
    .m_axi_wstrb(mng_axi_wstrb),
    .m_axi_wvalid(mng_axi_wvalid),
    .m_axi_wready(mng_axi_wready),
    .m_axi_bresp(mng_axi_bresp),
    .m_axi_bvalid(mng_axi_bvalid),
    .m_axi_bready(mng_axi_bready),
    .m_axi_araddr(mng_axi_araddr),
    .m_axi_arprot(mng_axi_arprot),
    .m_axi_arvalid(mng_axi_arvalid),
    .m_axi_arready(mng_axi_arready),
    .m_axi_rdata(mng_axi_rdata),
    .m_axi_rresp(mng_axi_rresp),
    .m_axi_rvalid(mng_axi_rvalid),
    .m_axi_rready(mng_axi_rready)
  );

  // DDR memory model
  ddr_model ddr_mem (
    .clk(ddr_clk),
    .rstn(~sys_rst)
  );

  // Instantiate the system block design
  system_bd system_bd_i (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .ddr_clk(ddr_clk),
    .ad974x_clk(ad974x_clk),
    .ad974x_data(ad974x_data),
    .mng_axi_awaddr(mng_axi_awaddr),
    .mng_axi_awprot(mng_axi_awprot),
    .mng_axi_awvalid(mng_axi_awvalid),
    .mng_axi_awready(mng_axi_awready),
    .mng_axi_wdata(mng_axi_wdata),
    .mng_axi_wstrb(mng_axi_wstrb),
    .mng_axi_wvalid(mng_axi_wvalid),
    .mng_axi_wready(mng_axi_wready),
    .mng_axi_bresp(mng_axi_bresp),
    .mng_axi_bvalid(mng_axi_bvalid),
    .mng_axi_bready(mng_axi_bready),
    .mng_axi_araddr(mng_axi_araddr),
    .mng_axi_arprot(mng_axi_arprot),
    .mng_axi_arvalid(mng_axi_arvalid),
    .mng_axi_arready(mng_axi_arready),
    .mng_axi_rdata(mng_axi_rdata),
    .mng_axi_rresp(mng_axi_rresp),
    .mng_axi_rvalid(mng_axi_rvalid),
    .mng_axi_rready(mng_axi_rready)
  );

endmodule