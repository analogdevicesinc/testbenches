//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
//Date        : Fri Aug 29 11:50:15 2025
//Host        : romlx4 running 64-bit Ubuntu 22.04.1 LTS
//Command     : generate_target test_harness.bd
//Design      : test_harness
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module axi_mxfe_rx_jesd_imp_595QX2
   (device_clk,
    irq,
    link_clk,
    rx_data_tdata,
    rx_data_tvalid,
    rx_eof,
    rx_phy0_rxblock_sync,
    rx_phy0_rxcharisk,
    rx_phy0_rxdata,
    rx_phy0_rxdisperr,
    rx_phy0_rxheader,
    rx_phy0_rxnotintable,
    rx_phy1_rxblock_sync,
    rx_phy1_rxcharisk,
    rx_phy1_rxdata,
    rx_phy1_rxdisperr,
    rx_phy1_rxheader,
    rx_phy1_rxnotintable,
    rx_phy2_rxblock_sync,
    rx_phy2_rxcharisk,
    rx_phy2_rxdata,
    rx_phy2_rxdisperr,
    rx_phy2_rxheader,
    rx_phy2_rxnotintable,
    rx_phy3_rxblock_sync,
    rx_phy3_rxcharisk,
    rx_phy3_rxdata,
    rx_phy3_rxdisperr,
    rx_phy3_rxheader,
    rx_phy3_rxnotintable,
    rx_sof,
    s_axi_aclk,
    s_axi_araddr,
    s_axi_aresetn,
    s_axi_arprot,
    s_axi_arready,
    s_axi_arvalid,
    s_axi_awaddr,
    s_axi_awprot,
    s_axi_awready,
    s_axi_awvalid,
    s_axi_bready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_rdata,
    s_axi_rready,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_wdata,
    s_axi_wready,
    s_axi_wstrb,
    s_axi_wvalid,
    sysref);
  input device_clk;
  output irq;
  input link_clk;
  output [383:0]rx_data_tdata;
  output rx_data_tvalid;
  output [11:0]rx_eof;
  input [0:0]rx_phy0_rxblock_sync;
  input [7:0]rx_phy0_rxcharisk;
  input [63:0]rx_phy0_rxdata;
  input [7:0]rx_phy0_rxdisperr;
  input [1:0]rx_phy0_rxheader;
  input [7:0]rx_phy0_rxnotintable;
  input [0:0]rx_phy1_rxblock_sync;
  input [7:0]rx_phy1_rxcharisk;
  input [63:0]rx_phy1_rxdata;
  input [7:0]rx_phy1_rxdisperr;
  input [1:0]rx_phy1_rxheader;
  input [7:0]rx_phy1_rxnotintable;
  input [0:0]rx_phy2_rxblock_sync;
  input [7:0]rx_phy2_rxcharisk;
  input [63:0]rx_phy2_rxdata;
  input [7:0]rx_phy2_rxdisperr;
  input [1:0]rx_phy2_rxheader;
  input [7:0]rx_phy2_rxnotintable;
  input [0:0]rx_phy3_rxblock_sync;
  input [7:0]rx_phy3_rxcharisk;
  input [63:0]rx_phy3_rxdata;
  input [7:0]rx_phy3_rxdisperr;
  input [1:0]rx_phy3_rxheader;
  input [7:0]rx_phy3_rxnotintable;
  output [11:0]rx_sof;
  input s_axi_aclk;
  input [13:0]s_axi_araddr;
  input s_axi_aresetn;
  input [2:0]s_axi_arprot;
  output s_axi_arready;
  input s_axi_arvalid;
  input [13:0]s_axi_awaddr;
  input [2:0]s_axi_awprot;
  output s_axi_awready;
  input s_axi_awvalid;
  input s_axi_bready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  output [31:0]s_axi_rdata;
  input s_axi_rready;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input [31:0]s_axi_wdata;
  output s_axi_wready;
  input [3:0]s_axi_wstrb;
  input s_axi_wvalid;
  input sysref;

  wire device_clk_1;
  wire link_clk_1;
  wire rx_axi_core_reset;
  wire rx_axi_device_reset;
  wire rx_axi_irq;
  wire [7:0]rx_axi_rx_cfg_device_beats_per_multiframe;
  wire [7:0]rx_axi_rx_cfg_device_buffer_delay;
  wire rx_axi_rx_cfg_device_buffer_early_release;
  wire [7:0]rx_axi_rx_cfg_device_lmfc_offset;
  wire [7:0]rx_axi_rx_cfg_device_octets_per_frame;
  wire [9:0]rx_axi_rx_cfg_device_octets_per_multiframe;
  wire rx_axi_rx_cfg_device_sysref_disable;
  wire rx_axi_rx_cfg_device_sysref_oneshot;
  wire rx_axi_rx_cfg_disable_char_replacement;
  wire rx_axi_rx_cfg_disable_scrambler;
  wire [6:0]rx_axi_rx_cfg_err_statistics_mask;
  wire rx_axi_rx_cfg_err_statistics_reset;
  wire [7:0]rx_axi_rx_cfg_frame_align_err_threshold;
  wire [3:0]rx_axi_rx_cfg_lanes_disable;
  wire [0:0]rx_axi_rx_cfg_links_disable;
  wire [7:0]rx_axi_rx_cfg_octets_per_frame;
  wire [9:0]rx_axi_rx_cfg_octets_per_multiframe;
  wire [0:0]rx_phy0_1_rxblock_sync;
  wire [7:0]rx_phy0_1_rxcharisk;
  wire [63:0]rx_phy0_1_rxdata;
  wire [7:0]rx_phy0_1_rxdisperr;
  wire [1:0]rx_phy0_1_rxheader;
  wire [7:0]rx_phy0_1_rxnotintable;
  wire [0:0]rx_phy1_1_rxblock_sync;
  wire [7:0]rx_phy1_1_rxcharisk;
  wire [63:0]rx_phy1_1_rxdata;
  wire [7:0]rx_phy1_1_rxdisperr;
  wire [1:0]rx_phy1_1_rxheader;
  wire [7:0]rx_phy1_1_rxnotintable;
  wire [0:0]rx_phy2_1_rxblock_sync;
  wire [7:0]rx_phy2_1_rxcharisk;
  wire [63:0]rx_phy2_1_rxdata;
  wire [7:0]rx_phy2_1_rxdisperr;
  wire [1:0]rx_phy2_1_rxheader;
  wire [7:0]rx_phy2_1_rxnotintable;
  wire [0:0]rx_phy3_1_rxblock_sync;
  wire [7:0]rx_phy3_1_rxcharisk;
  wire [63:0]rx_phy3_1_rxdata;
  wire [7:0]rx_phy3_1_rxdisperr;
  wire [1:0]rx_phy3_1_rxheader;
  wire [7:0]rx_phy3_1_rxnotintable;
  wire [383:0]rx_rx_data;
  wire [11:0]rx_rx_eof;
  wire rx_rx_event_frame_alignment_error;
  wire rx_rx_event_sysref_alignment_error;
  wire rx_rx_event_sysref_edge;
  wire rx_rx_event_unexpected_lane_state_error;
  wire [11:0]rx_rx_sof;
  wire [1:0]rx_rx_status_ctrl_state;
  wire [127:0]rx_rx_status_err_statistics_cnt;
  wire [7:0]rx_rx_status_lane_cgs_state;
  wire [11:0]rx_rx_status_lane_emb_state;
  wire [31:0]rx_rx_status_lane_frame_align_err_cnt;
  wire [3:0]rx_rx_status_lane_ifs_ready;
  wire [55:0]rx_rx_status_lane_latency;
  wire [31:0]rx_rx_status_synth_params0;
  wire [31:0]rx_rx_status_synth_params1;
  wire [31:0]rx_rx_status_synth_params2;
  wire rx_rx_valid;
  wire [13:0]s_axi_1_ARADDR;
  wire [2:0]s_axi_1_ARPROT;
  wire s_axi_1_ARREADY;
  wire s_axi_1_ARVALID;
  wire [13:0]s_axi_1_AWADDR;
  wire [2:0]s_axi_1_AWPROT;
  wire s_axi_1_AWREADY;
  wire s_axi_1_AWVALID;
  wire s_axi_1_BREADY;
  wire [1:0]s_axi_1_BRESP;
  wire s_axi_1_BVALID;
  wire [31:0]s_axi_1_RDATA;
  wire s_axi_1_RREADY;
  wire [1:0]s_axi_1_RRESP;
  wire s_axi_1_RVALID;
  wire [31:0]s_axi_1_WDATA;
  wire s_axi_1_WREADY;
  wire [3:0]s_axi_1_WSTRB;
  wire s_axi_1_WVALID;
  wire s_axi_aclk_1;
  wire s_axi_aresetn_1;
  wire sysref_1;

  assign device_clk_1 = device_clk;
  assign irq = rx_axi_irq;
  assign link_clk_1 = link_clk;
  assign rx_data_tdata[383:0] = rx_rx_data;
  assign rx_data_tvalid = rx_rx_valid;
  assign rx_eof[11:0] = rx_rx_eof;
  assign rx_phy0_1_rxblock_sync = rx_phy0_rxblock_sync[0];
  assign rx_phy0_1_rxcharisk = rx_phy0_rxcharisk[7:0];
  assign rx_phy0_1_rxdata = rx_phy0_rxdata[63:0];
  assign rx_phy0_1_rxdisperr = rx_phy0_rxdisperr[7:0];
  assign rx_phy0_1_rxheader = rx_phy0_rxheader[1:0];
  assign rx_phy0_1_rxnotintable = rx_phy0_rxnotintable[7:0];
  assign rx_phy1_1_rxblock_sync = rx_phy1_rxblock_sync[0];
  assign rx_phy1_1_rxcharisk = rx_phy1_rxcharisk[7:0];
  assign rx_phy1_1_rxdata = rx_phy1_rxdata[63:0];
  assign rx_phy1_1_rxdisperr = rx_phy1_rxdisperr[7:0];
  assign rx_phy1_1_rxheader = rx_phy1_rxheader[1:0];
  assign rx_phy1_1_rxnotintable = rx_phy1_rxnotintable[7:0];
  assign rx_phy2_1_rxblock_sync = rx_phy2_rxblock_sync[0];
  assign rx_phy2_1_rxcharisk = rx_phy2_rxcharisk[7:0];
  assign rx_phy2_1_rxdata = rx_phy2_rxdata[63:0];
  assign rx_phy2_1_rxdisperr = rx_phy2_rxdisperr[7:0];
  assign rx_phy2_1_rxheader = rx_phy2_rxheader[1:0];
  assign rx_phy2_1_rxnotintable = rx_phy2_rxnotintable[7:0];
  assign rx_phy3_1_rxblock_sync = rx_phy3_rxblock_sync[0];
  assign rx_phy3_1_rxcharisk = rx_phy3_rxcharisk[7:0];
  assign rx_phy3_1_rxdata = rx_phy3_rxdata[63:0];
  assign rx_phy3_1_rxdisperr = rx_phy3_rxdisperr[7:0];
  assign rx_phy3_1_rxheader = rx_phy3_rxheader[1:0];
  assign rx_phy3_1_rxnotintable = rx_phy3_rxnotintable[7:0];
  assign rx_sof[11:0] = rx_rx_sof;
  assign s_axi_1_ARADDR = s_axi_araddr[13:0];
  assign s_axi_1_ARPROT = s_axi_arprot[2:0];
  assign s_axi_1_ARVALID = s_axi_arvalid;
  assign s_axi_1_AWADDR = s_axi_awaddr[13:0];
  assign s_axi_1_AWPROT = s_axi_awprot[2:0];
  assign s_axi_1_AWVALID = s_axi_awvalid;
  assign s_axi_1_BREADY = s_axi_bready;
  assign s_axi_1_RREADY = s_axi_rready;
  assign s_axi_1_WDATA = s_axi_wdata[31:0];
  assign s_axi_1_WSTRB = s_axi_wstrb[3:0];
  assign s_axi_1_WVALID = s_axi_wvalid;
  assign s_axi_aclk_1 = s_axi_aclk;
  assign s_axi_aresetn_1 = s_axi_aresetn;
  assign s_axi_arready = s_axi_1_ARREADY;
  assign s_axi_awready = s_axi_1_AWREADY;
  assign s_axi_bresp[1:0] = s_axi_1_BRESP;
  assign s_axi_bvalid = s_axi_1_BVALID;
  assign s_axi_rdata[31:0] = s_axi_1_RDATA;
  assign s_axi_rresp[1:0] = s_axi_1_RRESP;
  assign s_axi_rvalid = s_axi_1_RVALID;
  assign s_axi_wready = s_axi_1_WREADY;
  assign sysref_1 = sysref;
  test_harness_rx_0 rx
       (.cfg_disable_char_replacement(rx_axi_rx_cfg_disable_char_replacement),
        .cfg_disable_scrambler(rx_axi_rx_cfg_disable_scrambler),
        .cfg_frame_align_err_threshold(rx_axi_rx_cfg_frame_align_err_threshold),
        .cfg_lanes_disable(rx_axi_rx_cfg_lanes_disable),
        .cfg_links_disable(rx_axi_rx_cfg_links_disable),
        .cfg_octets_per_frame(rx_axi_rx_cfg_octets_per_frame),
        .cfg_octets_per_multiframe(rx_axi_rx_cfg_octets_per_multiframe),
        .clk(link_clk_1),
        .ctrl_err_statistics_mask(rx_axi_rx_cfg_err_statistics_mask),
        .ctrl_err_statistics_reset(rx_axi_rx_cfg_err_statistics_reset),
        .device_cfg_beats_per_multiframe(rx_axi_rx_cfg_device_beats_per_multiframe),
        .device_cfg_buffer_delay(rx_axi_rx_cfg_device_buffer_delay),
        .device_cfg_buffer_early_release(rx_axi_rx_cfg_device_buffer_early_release),
        .device_cfg_lmfc_offset(rx_axi_rx_cfg_device_lmfc_offset),
        .device_cfg_octets_per_frame(rx_axi_rx_cfg_device_octets_per_frame),
        .device_cfg_octets_per_multiframe(rx_axi_rx_cfg_device_octets_per_multiframe),
        .device_cfg_sysref_disable(rx_axi_rx_cfg_device_sysref_disable),
        .device_cfg_sysref_oneshot(rx_axi_rx_cfg_device_sysref_oneshot),
        .device_clk(device_clk_1),
        .device_event_sysref_alignment_error(rx_rx_event_sysref_alignment_error),
        .device_event_sysref_edge(rx_rx_event_sysref_edge),
        .device_reset(rx_axi_device_reset),
        .event_frame_alignment_error(rx_rx_event_frame_alignment_error),
        .event_unexpected_lane_state_error(rx_rx_event_unexpected_lane_state_error),
        .phy_block_sync({rx_phy3_1_rxblock_sync,rx_phy2_1_rxblock_sync,rx_phy1_1_rxblock_sync,rx_phy0_1_rxblock_sync}),
        .phy_charisk({rx_phy3_1_rxcharisk,rx_phy2_1_rxcharisk,rx_phy1_1_rxcharisk,rx_phy0_1_rxcharisk}),
        .phy_data({rx_phy3_1_rxdata,rx_phy2_1_rxdata,rx_phy1_1_rxdata,rx_phy0_1_rxdata}),
        .phy_disperr({rx_phy3_1_rxdisperr,rx_phy2_1_rxdisperr,rx_phy1_1_rxdisperr,rx_phy0_1_rxdisperr}),
        .phy_header({rx_phy3_1_rxheader,rx_phy2_1_rxheader,rx_phy1_1_rxheader,rx_phy0_1_rxheader}),
        .phy_notintable({rx_phy3_1_rxnotintable,rx_phy2_1_rxnotintable,rx_phy1_1_rxnotintable,rx_phy0_1_rxnotintable}),
        .reset(rx_axi_core_reset),
        .rx_data(rx_rx_data),
        .rx_eof(rx_rx_eof),
        .rx_sof(rx_rx_sof),
        .rx_valid(rx_rx_valid),
        .status_ctrl_state(rx_rx_status_ctrl_state),
        .status_err_statistics_cnt(rx_rx_status_err_statistics_cnt),
        .status_lane_cgs_state(rx_rx_status_lane_cgs_state),
        .status_lane_emb_state(rx_rx_status_lane_emb_state),
        .status_lane_frame_align_err_cnt(rx_rx_status_lane_frame_align_err_cnt),
        .status_lane_ifs_ready(rx_rx_status_lane_ifs_ready),
        .status_lane_latency(rx_rx_status_lane_latency),
        .status_synth_params0(rx_rx_status_synth_params0),
        .status_synth_params1(rx_rx_status_synth_params1),
        .status_synth_params2(rx_rx_status_synth_params2),
        .sysref(sysref_1));
  test_harness_rx_axi_0 rx_axi
       (.core_cfg_disable_char_replacement(rx_axi_rx_cfg_disable_char_replacement),
        .core_cfg_disable_scrambler(rx_axi_rx_cfg_disable_scrambler),
        .core_cfg_frame_align_err_threshold(rx_axi_rx_cfg_frame_align_err_threshold),
        .core_cfg_lanes_disable(rx_axi_rx_cfg_lanes_disable),
        .core_cfg_links_disable(rx_axi_rx_cfg_links_disable),
        .core_cfg_octets_per_frame(rx_axi_rx_cfg_octets_per_frame),
        .core_cfg_octets_per_multiframe(rx_axi_rx_cfg_octets_per_multiframe),
        .core_clk(link_clk_1),
        .core_ctrl_err_statistics_mask(rx_axi_rx_cfg_err_statistics_mask),
        .core_ctrl_err_statistics_reset(rx_axi_rx_cfg_err_statistics_reset),
        .core_event_frame_alignment_error(rx_rx_event_frame_alignment_error),
        .core_event_unexpected_lane_state_error(rx_rx_event_unexpected_lane_state_error),
        .core_reset(rx_axi_core_reset),
        .core_reset_ext(1'b0),
        .core_status_ctrl_state(rx_rx_status_ctrl_state),
        .core_status_err_statistics_cnt(rx_rx_status_err_statistics_cnt),
        .core_status_lane_cgs_state(rx_rx_status_lane_cgs_state),
        .core_status_lane_emb_state(rx_rx_status_lane_emb_state),
        .core_status_lane_frame_align_err_cnt(rx_rx_status_lane_frame_align_err_cnt),
        .core_status_lane_ifs_ready(rx_rx_status_lane_ifs_ready),
        .core_status_lane_latency(rx_rx_status_lane_latency),
        .device_cfg_beats_per_multiframe(rx_axi_rx_cfg_device_beats_per_multiframe),
        .device_cfg_buffer_delay(rx_axi_rx_cfg_device_buffer_delay),
        .device_cfg_buffer_early_release(rx_axi_rx_cfg_device_buffer_early_release),
        .device_cfg_lmfc_offset(rx_axi_rx_cfg_device_lmfc_offset),
        .device_cfg_octets_per_frame(rx_axi_rx_cfg_device_octets_per_frame),
        .device_cfg_octets_per_multiframe(rx_axi_rx_cfg_device_octets_per_multiframe),
        .device_cfg_sysref_disable(rx_axi_rx_cfg_device_sysref_disable),
        .device_cfg_sysref_oneshot(rx_axi_rx_cfg_device_sysref_oneshot),
        .device_clk(device_clk_1),
        .device_event_sysref_alignment_error(rx_rx_event_sysref_alignment_error),
        .device_event_sysref_edge(rx_rx_event_sysref_edge),
        .device_reset(rx_axi_device_reset),
        .irq(rx_axi_irq),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(s_axi_1_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_arprot(s_axi_1_ARPROT),
        .s_axi_arready(s_axi_1_ARREADY),
        .s_axi_arvalid(s_axi_1_ARVALID),
        .s_axi_awaddr(s_axi_1_AWADDR),
        .s_axi_awprot(s_axi_1_AWPROT),
        .s_axi_awready(s_axi_1_AWREADY),
        .s_axi_awvalid(s_axi_1_AWVALID),
        .s_axi_bready(s_axi_1_BREADY),
        .s_axi_bresp(s_axi_1_BRESP),
        .s_axi_bvalid(s_axi_1_BVALID),
        .s_axi_rdata(s_axi_1_RDATA),
        .s_axi_rready(s_axi_1_RREADY),
        .s_axi_rresp(s_axi_1_RRESP),
        .s_axi_rvalid(s_axi_1_RVALID),
        .s_axi_wdata(s_axi_1_WDATA),
        .s_axi_wready(s_axi_1_WREADY),
        .s_axi_wstrb(s_axi_1_WSTRB),
        .s_axi_wvalid(s_axi_1_WVALID),
        .status_synth_params0(rx_rx_status_synth_params0),
        .status_synth_params1(rx_rx_status_synth_params1),
        .status_synth_params2(rx_rx_status_synth_params2));
endmodule

module axi_mxfe_tx_jesd_imp_13QEZ6D
   (device_clk,
    irq,
    link_clk,
    s_axi_aclk,
    s_axi_araddr,
    s_axi_aresetn,
    s_axi_arprot,
    s_axi_arready,
    s_axi_arvalid,
    s_axi_awaddr,
    s_axi_awprot,
    s_axi_awready,
    s_axi_awvalid,
    s_axi_bready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_rdata,
    s_axi_rready,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_wdata,
    s_axi_wready,
    s_axi_wstrb,
    s_axi_wvalid,
    sysref,
    tx_data_tdata,
    tx_data_tready,
    tx_data_tvalid,
    tx_phy0_txcharisk,
    tx_phy0_txdata,
    tx_phy0_txheader,
    tx_phy1_txcharisk,
    tx_phy1_txdata,
    tx_phy1_txheader,
    tx_phy2_txcharisk,
    tx_phy2_txdata,
    tx_phy2_txheader,
    tx_phy3_txcharisk,
    tx_phy3_txdata,
    tx_phy3_txheader);
  input device_clk;
  output irq;
  input link_clk;
  input s_axi_aclk;
  input [13:0]s_axi_araddr;
  input s_axi_aresetn;
  input [2:0]s_axi_arprot;
  output s_axi_arready;
  input s_axi_arvalid;
  input [13:0]s_axi_awaddr;
  input [2:0]s_axi_awprot;
  output s_axi_awready;
  input s_axi_awvalid;
  input s_axi_bready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  output [31:0]s_axi_rdata;
  input s_axi_rready;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input [31:0]s_axi_wdata;
  output s_axi_wready;
  input [3:0]s_axi_wstrb;
  input s_axi_wvalid;
  input sysref;
  input [383:0]tx_data_tdata;
  output tx_data_tready;
  input tx_data_tvalid;
  output [7:0]tx_phy0_txcharisk;
  output [63:0]tx_phy0_txdata;
  output [1:0]tx_phy0_txheader;
  output [7:0]tx_phy1_txcharisk;
  output [63:0]tx_phy1_txdata;
  output [1:0]tx_phy1_txheader;
  output [7:0]tx_phy2_txcharisk;
  output [63:0]tx_phy2_txdata;
  output [1:0]tx_phy2_txheader;
  output [7:0]tx_phy3_txcharisk;
  output [63:0]tx_phy3_txdata;
  output [1:0]tx_phy3_txheader;

  wire device_clk_1;
  wire link_clk_1;
  wire [13:0]s_axi_1_ARADDR;
  wire [2:0]s_axi_1_ARPROT;
  wire s_axi_1_ARREADY;
  wire s_axi_1_ARVALID;
  wire [13:0]s_axi_1_AWADDR;
  wire [2:0]s_axi_1_AWPROT;
  wire s_axi_1_AWREADY;
  wire s_axi_1_AWVALID;
  wire s_axi_1_BREADY;
  wire [1:0]s_axi_1_BRESP;
  wire s_axi_1_BVALID;
  wire [31:0]s_axi_1_RDATA;
  wire s_axi_1_RREADY;
  wire [1:0]s_axi_1_RRESP;
  wire s_axi_1_RVALID;
  wire [31:0]s_axi_1_WDATA;
  wire s_axi_1_WREADY;
  wire [3:0]s_axi_1_WSTRB;
  wire s_axi_1_WVALID;
  wire s_axi_aclk_1;
  wire s_axi_aresetn_1;
  wire sysref_1;
  wire tx_axi_core_reset;
  wire tx_axi_device_reset;
  wire tx_axi_irq;
  wire tx_axi_tx_cfg_continuous_cgs;
  wire tx_axi_tx_cfg_continuous_ilas;
  wire [7:0]tx_axi_tx_cfg_device_beats_per_multiframe;
  wire [7:0]tx_axi_tx_cfg_device_lmfc_offset;
  wire [7:0]tx_axi_tx_cfg_device_octets_per_frame;
  wire [9:0]tx_axi_tx_cfg_device_octets_per_multiframe;
  wire tx_axi_tx_cfg_device_sysref_disable;
  wire tx_axi_tx_cfg_device_sysref_oneshot;
  wire tx_axi_tx_cfg_disable_char_replacement;
  wire tx_axi_tx_cfg_disable_scrambler;
  wire [3:0]tx_axi_tx_cfg_lanes_disable;
  wire [0:0]tx_axi_tx_cfg_links_disable;
  wire [7:0]tx_axi_tx_cfg_mframes_per_ilas;
  wire [7:0]tx_axi_tx_cfg_octets_per_frame;
  wire [9:0]tx_axi_tx_cfg_octets_per_multiframe;
  wire tx_axi_tx_cfg_skip_ilas;
  wire [383:0]tx_data_1_TDATA;
  wire tx_data_1_TREADY;
  wire tx_data_1_TVALID;
  wire tx_tx_event_sysref_alignment_error;
  wire tx_tx_event_sysref_edge;
  wire [7:0]tx_tx_phy0_txcharisk;
  wire [63:0]tx_tx_phy0_txdata;
  wire [1:0]tx_tx_phy0_txheader;
  wire [15:8]tx_tx_phy1_txcharisk;
  wire [127:64]tx_tx_phy1_txdata;
  wire [3:2]tx_tx_phy1_txheader;
  wire [23:16]tx_tx_phy2_txcharisk;
  wire [191:128]tx_tx_phy2_txdata;
  wire [5:4]tx_tx_phy2_txheader;
  wire [31:24]tx_tx_phy3_txcharisk;
  wire [255:192]tx_tx_phy3_txdata;
  wire [7:6]tx_tx_phy3_txheader;
  wire [1:0]tx_tx_status_state;
  wire [0:0]tx_tx_status_sync;
  wire [31:0]tx_tx_status_synth_params0;
  wire [31:0]tx_tx_status_synth_params1;
  wire [31:0]tx_tx_status_synth_params2;

  assign device_clk_1 = device_clk;
  assign irq = tx_axi_irq;
  assign link_clk_1 = link_clk;
  assign s_axi_1_ARADDR = s_axi_araddr[13:0];
  assign s_axi_1_ARPROT = s_axi_arprot[2:0];
  assign s_axi_1_ARVALID = s_axi_arvalid;
  assign s_axi_1_AWADDR = s_axi_awaddr[13:0];
  assign s_axi_1_AWPROT = s_axi_awprot[2:0];
  assign s_axi_1_AWVALID = s_axi_awvalid;
  assign s_axi_1_BREADY = s_axi_bready;
  assign s_axi_1_RREADY = s_axi_rready;
  assign s_axi_1_WDATA = s_axi_wdata[31:0];
  assign s_axi_1_WSTRB = s_axi_wstrb[3:0];
  assign s_axi_1_WVALID = s_axi_wvalid;
  assign s_axi_aclk_1 = s_axi_aclk;
  assign s_axi_aresetn_1 = s_axi_aresetn;
  assign s_axi_arready = s_axi_1_ARREADY;
  assign s_axi_awready = s_axi_1_AWREADY;
  assign s_axi_bresp[1:0] = s_axi_1_BRESP;
  assign s_axi_bvalid = s_axi_1_BVALID;
  assign s_axi_rdata[31:0] = s_axi_1_RDATA;
  assign s_axi_rresp[1:0] = s_axi_1_RRESP;
  assign s_axi_rvalid = s_axi_1_RVALID;
  assign s_axi_wready = s_axi_1_WREADY;
  assign sysref_1 = sysref;
  assign tx_data_1_TDATA = tx_data_tdata[383:0];
  assign tx_data_1_TVALID = tx_data_tvalid;
  assign tx_data_tready = tx_data_1_TREADY;
  assign tx_phy0_txcharisk[7:0] = tx_tx_phy0_txcharisk;
  assign tx_phy0_txdata[63:0] = tx_tx_phy0_txdata;
  assign tx_phy0_txheader[1:0] = tx_tx_phy0_txheader;
  assign tx_phy1_txcharisk[7:0] = tx_tx_phy1_txcharisk;
  assign tx_phy1_txdata[63:0] = tx_tx_phy1_txdata;
  assign tx_phy1_txheader[1:0] = tx_tx_phy1_txheader;
  assign tx_phy2_txcharisk[7:0] = tx_tx_phy2_txcharisk;
  assign tx_phy2_txdata[63:0] = tx_tx_phy2_txdata;
  assign tx_phy2_txheader[1:0] = tx_tx_phy2_txheader;
  assign tx_phy3_txcharisk[7:0] = tx_tx_phy3_txcharisk;
  assign tx_phy3_txdata[63:0] = tx_tx_phy3_txdata;
  assign tx_phy3_txheader[1:0] = tx_tx_phy3_txheader;
  test_harness_tx_0 tx
       (.cfg_continuous_cgs(tx_axi_tx_cfg_continuous_cgs),
        .cfg_continuous_ilas(tx_axi_tx_cfg_continuous_ilas),
        .cfg_disable_char_replacement(tx_axi_tx_cfg_disable_char_replacement),
        .cfg_disable_scrambler(tx_axi_tx_cfg_disable_scrambler),
        .cfg_lanes_disable(tx_axi_tx_cfg_lanes_disable),
        .cfg_links_disable(tx_axi_tx_cfg_links_disable),
        .cfg_mframes_per_ilas(tx_axi_tx_cfg_mframes_per_ilas),
        .cfg_octets_per_frame(tx_axi_tx_cfg_octets_per_frame),
        .cfg_octets_per_multiframe(tx_axi_tx_cfg_octets_per_multiframe),
        .cfg_skip_ilas(tx_axi_tx_cfg_skip_ilas),
        .clk(link_clk_1),
        .device_cfg_beats_per_multiframe(tx_axi_tx_cfg_device_beats_per_multiframe),
        .device_cfg_lmfc_offset(tx_axi_tx_cfg_device_lmfc_offset),
        .device_cfg_octets_per_frame(tx_axi_tx_cfg_device_octets_per_frame),
        .device_cfg_octets_per_multiframe(tx_axi_tx_cfg_device_octets_per_multiframe),
        .device_cfg_sysref_disable(tx_axi_tx_cfg_device_sysref_disable),
        .device_cfg_sysref_oneshot(tx_axi_tx_cfg_device_sysref_oneshot),
        .device_clk(device_clk_1),
        .device_event_sysref_alignment_error(tx_tx_event_sysref_alignment_error),
        .device_event_sysref_edge(tx_tx_event_sysref_edge),
        .device_reset(tx_axi_device_reset),
        .phy_charisk({tx_tx_phy3_txcharisk,tx_tx_phy2_txcharisk,tx_tx_phy1_txcharisk,tx_tx_phy0_txcharisk}),
        .phy_data({tx_tx_phy3_txdata,tx_tx_phy2_txdata,tx_tx_phy1_txdata,tx_tx_phy0_txdata}),
        .phy_header({tx_tx_phy3_txheader,tx_tx_phy2_txheader,tx_tx_phy1_txheader,tx_tx_phy0_txheader}),
        .reset(tx_axi_core_reset),
        .status_state(tx_tx_status_state),
        .status_sync(tx_tx_status_sync),
        .status_synth_params0(tx_tx_status_synth_params0),
        .status_synth_params1(tx_tx_status_synth_params1),
        .status_synth_params2(tx_tx_status_synth_params2),
        .sysref(sysref_1),
        .tx_data(tx_data_1_TDATA),
        .tx_ready(tx_data_1_TREADY),
        .tx_valid(tx_data_1_TVALID));
  test_harness_tx_axi_0 tx_axi
       (.core_cfg_continuous_cgs(tx_axi_tx_cfg_continuous_cgs),
        .core_cfg_continuous_ilas(tx_axi_tx_cfg_continuous_ilas),
        .core_cfg_disable_char_replacement(tx_axi_tx_cfg_disable_char_replacement),
        .core_cfg_disable_scrambler(tx_axi_tx_cfg_disable_scrambler),
        .core_cfg_lanes_disable(tx_axi_tx_cfg_lanes_disable),
        .core_cfg_links_disable(tx_axi_tx_cfg_links_disable),
        .core_cfg_mframes_per_ilas(tx_axi_tx_cfg_mframes_per_ilas),
        .core_cfg_octets_per_frame(tx_axi_tx_cfg_octets_per_frame),
        .core_cfg_octets_per_multiframe(tx_axi_tx_cfg_octets_per_multiframe),
        .core_cfg_skip_ilas(tx_axi_tx_cfg_skip_ilas),
        .core_clk(link_clk_1),
        .core_reset(tx_axi_core_reset),
        .core_reset_ext(1'b0),
        .core_status_state(tx_tx_status_state),
        .core_status_sync(tx_tx_status_sync),
        .device_cfg_beats_per_multiframe(tx_axi_tx_cfg_device_beats_per_multiframe),
        .device_cfg_lmfc_offset(tx_axi_tx_cfg_device_lmfc_offset),
        .device_cfg_octets_per_frame(tx_axi_tx_cfg_device_octets_per_frame),
        .device_cfg_octets_per_multiframe(tx_axi_tx_cfg_device_octets_per_multiframe),
        .device_cfg_sysref_disable(tx_axi_tx_cfg_device_sysref_disable),
        .device_cfg_sysref_oneshot(tx_axi_tx_cfg_device_sysref_oneshot),
        .device_clk(device_clk_1),
        .device_event_sysref_alignment_error(tx_tx_event_sysref_alignment_error),
        .device_event_sysref_edge(tx_tx_event_sysref_edge),
        .device_reset(tx_axi_device_reset),
        .irq(tx_axi_irq),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(s_axi_1_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_arprot(s_axi_1_ARPROT),
        .s_axi_arready(s_axi_1_ARREADY),
        .s_axi_arvalid(s_axi_1_ARVALID),
        .s_axi_awaddr(s_axi_1_AWADDR),
        .s_axi_awprot(s_axi_1_AWPROT),
        .s_axi_awready(s_axi_1_AWREADY),
        .s_axi_awvalid(s_axi_1_AWVALID),
        .s_axi_bready(s_axi_1_BREADY),
        .s_axi_bresp(s_axi_1_BRESP),
        .s_axi_bvalid(s_axi_1_BVALID),
        .s_axi_rdata(s_axi_1_RDATA),
        .s_axi_rready(s_axi_1_RREADY),
        .s_axi_rresp(s_axi_1_RRESP),
        .s_axi_rvalid(s_axi_1_RVALID),
        .s_axi_wdata(s_axi_1_WDATA),
        .s_axi_wready(s_axi_1_WREADY),
        .s_axi_wstrb(s_axi_1_WSTRB),
        .s_axi_wvalid(s_axi_1_WVALID),
        .status_synth_params0(tx_tx_status_synth_params0),
        .status_synth_params1(tx_tx_status_synth_params1),
        .status_synth_params2(tx_tx_status_synth_params2));
endmodule

module mxfe_rx_data_offload_imp_1S7ORJK
   (init_req,
    m_axis_aclk,
    m_axis_aresetn,
    m_axis_tdata,
    m_axis_tkeep,
    m_axis_tlast,
    m_axis_tready,
    m_axis_tvalid,
    s_axi_aclk,
    s_axi_araddr,
    s_axi_aresetn,
    s_axi_arprot,
    s_axi_arready,
    s_axi_arvalid,
    s_axi_awaddr,
    s_axi_awprot,
    s_axi_awready,
    s_axi_awvalid,
    s_axi_bready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_rdata,
    s_axi_rready,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_wdata,
    s_axi_wready,
    s_axi_wstrb,
    s_axi_wvalid,
    s_axis_aclk,
    s_axis_aresetn,
    s_axis_tdata,
    s_axis_tkeep,
    s_axis_tlast,
    s_axis_tready,
    s_axis_tvalid,
    sync_ext);
  input init_req;
  input m_axis_aclk;
  input m_axis_aresetn;
  output [511:0]m_axis_tdata;
  output [63:0]m_axis_tkeep;
  output m_axis_tlast;
  input m_axis_tready;
  output m_axis_tvalid;
  input s_axi_aclk;
  input [15:0]s_axi_araddr;
  input s_axi_aresetn;
  input [2:0]s_axi_arprot;
  output s_axi_arready;
  input s_axi_arvalid;
  input [15:0]s_axi_awaddr;
  input [2:0]s_axi_awprot;
  output s_axi_awready;
  input s_axi_awvalid;
  input s_axi_bready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  output [31:0]s_axi_rdata;
  input s_axi_rready;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input [31:0]s_axi_wdata;
  output s_axi_wready;
  input [3:0]s_axi_wstrb;
  input s_axi_wvalid;
  input s_axis_aclk;
  input s_axis_aresetn;
  input [511:0]s_axis_tdata;
  input s_axis_tkeep;
  input s_axis_tlast;
  output s_axis_tready;
  input s_axis_tvalid;
  input sync_ext;

  wire [511:0]i_data_offload_m_axis_TDATA;
  wire [63:0]i_data_offload_m_axis_TKEEP;
  wire i_data_offload_m_axis_TLAST;
  wire i_data_offload_m_axis_TREADY;
  wire i_data_offload_m_axis_TVALID;
  wire [511:0]i_data_offload_m_storage_axis_TDATA;
  wire [63:0]i_data_offload_m_storage_axis_TKEEP;
  wire i_data_offload_m_storage_axis_TLAST;
  wire i_data_offload_m_storage_axis_TREADY;
  wire i_data_offload_m_storage_axis_TVALID;
  wire i_data_offload_rd_ctrl_request_enable;
  wire [11:0]i_data_offload_rd_ctrl_request_length;
  wire i_data_offload_rd_ctrl_request_ready;
  wire i_data_offload_rd_ctrl_request_valid;
  wire i_data_offload_rd_ctrl_response_eot;
  wire i_data_offload_wr_ctrl_request_enable;
  wire [11:0]i_data_offload_wr_ctrl_request_length;
  wire i_data_offload_wr_ctrl_request_ready;
  wire i_data_offload_wr_ctrl_request_valid;
  wire i_data_offload_wr_ctrl_response_eot;
  wire [11:0]i_data_offload_wr_ctrl_response_measured_length;
  wire init_req_1;
  wire m_axis_aclk_1;
  wire m_axis_aresetn_1;
  wire [15:0]s_axi_1_ARADDR;
  wire [2:0]s_axi_1_ARPROT;
  wire s_axi_1_ARREADY;
  wire s_axi_1_ARVALID;
  wire [15:0]s_axi_1_AWADDR;
  wire [2:0]s_axi_1_AWPROT;
  wire s_axi_1_AWREADY;
  wire s_axi_1_AWVALID;
  wire s_axi_1_BREADY;
  wire [1:0]s_axi_1_BRESP;
  wire s_axi_1_BVALID;
  wire [31:0]s_axi_1_RDATA;
  wire s_axi_1_RREADY;
  wire [1:0]s_axi_1_RRESP;
  wire s_axi_1_RVALID;
  wire [31:0]s_axi_1_WDATA;
  wire s_axi_1_WREADY;
  wire [3:0]s_axi_1_WSTRB;
  wire s_axi_1_WVALID;
  wire s_axi_aclk_1;
  wire s_axi_aresetn_1;
  wire [511:0]s_axis_1_TDATA;
  wire s_axis_1_TKEEP;
  wire s_axis_1_TLAST;
  wire s_axis_1_TREADY;
  wire s_axis_1_TVALID;
  wire s_axis_aclk_1;
  wire s_axis_aresetn_1;
  wire [511:0]storage_unit_m_axis_TDATA;
  wire [63:0]storage_unit_m_axis_TKEEP;
  wire storage_unit_m_axis_TLAST;
  wire storage_unit_m_axis_TREADY;
  wire storage_unit_m_axis_TVALID;
  wire sync_ext_1;

  assign i_data_offload_m_axis_TREADY = m_axis_tready;
  assign init_req_1 = init_req;
  assign m_axis_aclk_1 = m_axis_aclk;
  assign m_axis_aresetn_1 = m_axis_aresetn;
  assign m_axis_tdata[511:0] = i_data_offload_m_axis_TDATA;
  assign m_axis_tkeep[63:0] = i_data_offload_m_axis_TKEEP;
  assign m_axis_tlast = i_data_offload_m_axis_TLAST;
  assign m_axis_tvalid = i_data_offload_m_axis_TVALID;
  assign s_axi_1_ARADDR = s_axi_araddr[15:0];
  assign s_axi_1_ARPROT = s_axi_arprot[2:0];
  assign s_axi_1_ARVALID = s_axi_arvalid;
  assign s_axi_1_AWADDR = s_axi_awaddr[15:0];
  assign s_axi_1_AWPROT = s_axi_awprot[2:0];
  assign s_axi_1_AWVALID = s_axi_awvalid;
  assign s_axi_1_BREADY = s_axi_bready;
  assign s_axi_1_RREADY = s_axi_rready;
  assign s_axi_1_WDATA = s_axi_wdata[31:0];
  assign s_axi_1_WSTRB = s_axi_wstrb[3:0];
  assign s_axi_1_WVALID = s_axi_wvalid;
  assign s_axi_aclk_1 = s_axi_aclk;
  assign s_axi_aresetn_1 = s_axi_aresetn;
  assign s_axi_arready = s_axi_1_ARREADY;
  assign s_axi_awready = s_axi_1_AWREADY;
  assign s_axi_bresp[1:0] = s_axi_1_BRESP;
  assign s_axi_bvalid = s_axi_1_BVALID;
  assign s_axi_rdata[31:0] = s_axi_1_RDATA;
  assign s_axi_rresp[1:0] = s_axi_1_RRESP;
  assign s_axi_rvalid = s_axi_1_RVALID;
  assign s_axi_wready = s_axi_1_WREADY;
  assign s_axis_1_TDATA = s_axis_tdata[511:0];
  assign s_axis_1_TKEEP = s_axis_tkeep;
  assign s_axis_1_TLAST = s_axis_tlast;
  assign s_axis_1_TVALID = s_axis_tvalid;
  assign s_axis_aclk_1 = s_axis_aclk;
  assign s_axis_aresetn_1 = s_axis_aresetn;
  assign s_axis_tready = s_axis_1_TREADY;
  assign sync_ext_1 = sync_ext;
  test_harness_i_data_offload_0 i_data_offload
       (.init_req(init_req_1),
        .m_axis_aclk(m_axis_aclk_1),
        .m_axis_aresetn(m_axis_aresetn_1),
        .m_axis_data(i_data_offload_m_axis_TDATA),
        .m_axis_last(i_data_offload_m_axis_TLAST),
        .m_axis_ready(i_data_offload_m_axis_TREADY),
        .m_axis_tkeep(i_data_offload_m_axis_TKEEP),
        .m_axis_valid(i_data_offload_m_axis_TVALID),
        .m_storage_axis_data(i_data_offload_m_storage_axis_TDATA),
        .m_storage_axis_last(i_data_offload_m_storage_axis_TLAST),
        .m_storage_axis_ready(i_data_offload_m_storage_axis_TREADY),
        .m_storage_axis_tkeep(i_data_offload_m_storage_axis_TKEEP),
        .m_storage_axis_valid(i_data_offload_m_storage_axis_TVALID),
        .rd_request_enable(i_data_offload_rd_ctrl_request_enable),
        .rd_request_length(i_data_offload_rd_ctrl_request_length),
        .rd_request_ready(i_data_offload_rd_ctrl_request_ready),
        .rd_request_valid(i_data_offload_rd_ctrl_request_valid),
        .rd_response_eot(i_data_offload_rd_ctrl_response_eot),
        .rd_underflow(1'b0),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(s_axi_1_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_arprot(s_axi_1_ARPROT),
        .s_axi_arready(s_axi_1_ARREADY),
        .s_axi_arvalid(s_axi_1_ARVALID),
        .s_axi_awaddr(s_axi_1_AWADDR),
        .s_axi_awprot(s_axi_1_AWPROT),
        .s_axi_awready(s_axi_1_AWREADY),
        .s_axi_awvalid(s_axi_1_AWVALID),
        .s_axi_bready(s_axi_1_BREADY),
        .s_axi_bresp(s_axi_1_BRESP),
        .s_axi_bvalid(s_axi_1_BVALID),
        .s_axi_rdata(s_axi_1_RDATA),
        .s_axi_rready(s_axi_1_RREADY),
        .s_axi_rresp(s_axi_1_RRESP),
        .s_axi_rvalid(s_axi_1_RVALID),
        .s_axi_wdata(s_axi_1_WDATA),
        .s_axi_wready(s_axi_1_WREADY),
        .s_axi_wstrb(s_axi_1_WSTRB),
        .s_axi_wvalid(s_axi_1_WVALID),
        .s_axis_aclk(s_axis_aclk_1),
        .s_axis_aresetn(s_axis_aresetn_1),
        .s_axis_data(s_axis_1_TDATA),
        .s_axis_last(s_axis_1_TLAST),
        .s_axis_ready(s_axis_1_TREADY),
        .s_axis_tkeep({s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP,s_axis_1_TKEEP}),
        .s_axis_valid(s_axis_1_TVALID),
        .s_storage_axis_data(storage_unit_m_axis_TDATA),
        .s_storage_axis_last(storage_unit_m_axis_TLAST),
        .s_storage_axis_ready(storage_unit_m_axis_TREADY),
        .s_storage_axis_tkeep(storage_unit_m_axis_TKEEP),
        .s_storage_axis_valid(storage_unit_m_axis_TVALID),
        .sync_ext(sync_ext_1),
        .wr_overflow(1'b0),
        .wr_request_enable(i_data_offload_wr_ctrl_request_enable),
        .wr_request_length(i_data_offload_wr_ctrl_request_length),
        .wr_request_ready(i_data_offload_wr_ctrl_request_ready),
        .wr_request_valid(i_data_offload_wr_ctrl_request_valid),
        .wr_response_eot(i_data_offload_wr_ctrl_response_eot),
        .wr_response_measured_length(i_data_offload_wr_ctrl_response_measured_length));
  test_harness_storage_unit_0 storage_unit
       (.m_axis_aclk(m_axis_aclk_1),
        .m_axis_aresetn(m_axis_aresetn_1),
        .m_axis_data(storage_unit_m_axis_TDATA),
        .m_axis_keep(storage_unit_m_axis_TKEEP),
        .m_axis_last(storage_unit_m_axis_TLAST),
        .m_axis_ready(storage_unit_m_axis_TREADY),
        .m_axis_valid(storage_unit_m_axis_TVALID),
        .rd_request_enable(i_data_offload_rd_ctrl_request_enable),
        .rd_request_length(i_data_offload_rd_ctrl_request_length),
        .rd_request_ready(i_data_offload_rd_ctrl_request_ready),
        .rd_request_valid(i_data_offload_rd_ctrl_request_valid),
        .rd_response_eot(i_data_offload_rd_ctrl_response_eot),
        .s_axis_aclk(s_axis_aclk_1),
        .s_axis_aresetn(s_axis_aresetn_1),
        .s_axis_data(i_data_offload_m_storage_axis_TDATA),
        .s_axis_keep(i_data_offload_m_storage_axis_TKEEP),
        .s_axis_last(i_data_offload_m_storage_axis_TLAST),
        .s_axis_ready(i_data_offload_m_storage_axis_TREADY),
        .s_axis_strb({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .s_axis_user(1'b0),
        .s_axis_valid(i_data_offload_m_storage_axis_TVALID),
        .wr_request_enable(i_data_offload_wr_ctrl_request_enable),
        .wr_request_length(i_data_offload_wr_ctrl_request_length),
        .wr_request_ready(i_data_offload_wr_ctrl_request_ready),
        .wr_request_valid(i_data_offload_wr_ctrl_request_valid),
        .wr_response_eot(i_data_offload_wr_ctrl_response_eot),
        .wr_response_measured_length(i_data_offload_wr_ctrl_response_measured_length));
endmodule

module mxfe_tx_data_offload_imp_PB4RZR
   (init_req,
    m_axis_aclk,
    m_axis_aresetn,
    m_axis_tdata,
    m_axis_tready,
    m_axis_tvalid,
    s_axi_aclk,
    s_axi_araddr,
    s_axi_aresetn,
    s_axi_arprot,
    s_axi_arready,
    s_axi_arvalid,
    s_axi_awaddr,
    s_axi_awprot,
    s_axi_awready,
    s_axi_awvalid,
    s_axi_bready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_rdata,
    s_axi_rready,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_wdata,
    s_axi_wready,
    s_axi_wstrb,
    s_axi_wvalid,
    s_axis_aclk,
    s_axis_aresetn,
    s_axis_tdata,
    s_axis_tkeep,
    s_axis_tlast,
    s_axis_tready,
    s_axis_tvalid,
    sync_ext);
  input init_req;
  input m_axis_aclk;
  input m_axis_aresetn;
  output [511:0]m_axis_tdata;
  input m_axis_tready;
  output m_axis_tvalid;
  input s_axi_aclk;
  input [15:0]s_axi_araddr;
  input s_axi_aresetn;
  input [2:0]s_axi_arprot;
  output s_axi_arready;
  input s_axi_arvalid;
  input [15:0]s_axi_awaddr;
  input [2:0]s_axi_awprot;
  output s_axi_awready;
  input s_axi_awvalid;
  input s_axi_bready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  output [31:0]s_axi_rdata;
  input s_axi_rready;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input [31:0]s_axi_wdata;
  output s_axi_wready;
  input [3:0]s_axi_wstrb;
  input s_axi_wvalid;
  input s_axis_aclk;
  input s_axis_aresetn;
  input [511:0]s_axis_tdata;
  input [63:0]s_axis_tkeep;
  input s_axis_tlast;
  output s_axis_tready;
  input s_axis_tvalid;
  input sync_ext;

  wire [511:0]i_data_offload_m_axis_TDATA;
  wire i_data_offload_m_axis_TREADY;
  wire i_data_offload_m_axis_TVALID;
  wire [511:0]i_data_offload_m_storage_axis_TDATA;
  wire [63:0]i_data_offload_m_storage_axis_TKEEP;
  wire i_data_offload_m_storage_axis_TLAST;
  wire i_data_offload_m_storage_axis_TREADY;
  wire i_data_offload_m_storage_axis_TVALID;
  wire i_data_offload_rd_ctrl_request_enable;
  wire [11:0]i_data_offload_rd_ctrl_request_length;
  wire i_data_offload_rd_ctrl_request_ready;
  wire i_data_offload_rd_ctrl_request_valid;
  wire i_data_offload_rd_ctrl_response_eot;
  wire i_data_offload_wr_ctrl_request_enable;
  wire [11:0]i_data_offload_wr_ctrl_request_length;
  wire i_data_offload_wr_ctrl_request_ready;
  wire i_data_offload_wr_ctrl_request_valid;
  wire i_data_offload_wr_ctrl_response_eot;
  wire [11:0]i_data_offload_wr_ctrl_response_measured_length;
  wire init_req_1;
  wire m_axis_aclk_1;
  wire m_axis_aresetn_1;
  wire [15:0]s_axi_1_ARADDR;
  wire [2:0]s_axi_1_ARPROT;
  wire s_axi_1_ARREADY;
  wire s_axi_1_ARVALID;
  wire [15:0]s_axi_1_AWADDR;
  wire [2:0]s_axi_1_AWPROT;
  wire s_axi_1_AWREADY;
  wire s_axi_1_AWVALID;
  wire s_axi_1_BREADY;
  wire [1:0]s_axi_1_BRESP;
  wire s_axi_1_BVALID;
  wire [31:0]s_axi_1_RDATA;
  wire s_axi_1_RREADY;
  wire [1:0]s_axi_1_RRESP;
  wire s_axi_1_RVALID;
  wire [31:0]s_axi_1_WDATA;
  wire s_axi_1_WREADY;
  wire [3:0]s_axi_1_WSTRB;
  wire s_axi_1_WVALID;
  wire s_axi_aclk_1;
  wire s_axi_aresetn_1;
  wire [511:0]s_axis_1_TDATA;
  wire [63:0]s_axis_1_TKEEP;
  wire s_axis_1_TLAST;
  wire s_axis_1_TREADY;
  wire s_axis_1_TVALID;
  wire s_axis_aclk_1;
  wire s_axis_aresetn_1;
  wire [511:0]storage_unit_m_axis_TDATA;
  wire [63:0]storage_unit_m_axis_TKEEP;
  wire storage_unit_m_axis_TLAST;
  wire storage_unit_m_axis_TREADY;
  wire storage_unit_m_axis_TVALID;
  wire sync_ext_1;

  assign i_data_offload_m_axis_TREADY = m_axis_tready;
  assign init_req_1 = init_req;
  assign m_axis_aclk_1 = m_axis_aclk;
  assign m_axis_aresetn_1 = m_axis_aresetn;
  assign m_axis_tdata[511:0] = i_data_offload_m_axis_TDATA;
  assign m_axis_tvalid = i_data_offload_m_axis_TVALID;
  assign s_axi_1_ARADDR = s_axi_araddr[15:0];
  assign s_axi_1_ARPROT = s_axi_arprot[2:0];
  assign s_axi_1_ARVALID = s_axi_arvalid;
  assign s_axi_1_AWADDR = s_axi_awaddr[15:0];
  assign s_axi_1_AWPROT = s_axi_awprot[2:0];
  assign s_axi_1_AWVALID = s_axi_awvalid;
  assign s_axi_1_BREADY = s_axi_bready;
  assign s_axi_1_RREADY = s_axi_rready;
  assign s_axi_1_WDATA = s_axi_wdata[31:0];
  assign s_axi_1_WSTRB = s_axi_wstrb[3:0];
  assign s_axi_1_WVALID = s_axi_wvalid;
  assign s_axi_aclk_1 = s_axi_aclk;
  assign s_axi_aresetn_1 = s_axi_aresetn;
  assign s_axi_arready = s_axi_1_ARREADY;
  assign s_axi_awready = s_axi_1_AWREADY;
  assign s_axi_bresp[1:0] = s_axi_1_BRESP;
  assign s_axi_bvalid = s_axi_1_BVALID;
  assign s_axi_rdata[31:0] = s_axi_1_RDATA;
  assign s_axi_rresp[1:0] = s_axi_1_RRESP;
  assign s_axi_rvalid = s_axi_1_RVALID;
  assign s_axi_wready = s_axi_1_WREADY;
  assign s_axis_1_TDATA = s_axis_tdata[511:0];
  assign s_axis_1_TKEEP = s_axis_tkeep[63:0];
  assign s_axis_1_TLAST = s_axis_tlast;
  assign s_axis_1_TVALID = s_axis_tvalid;
  assign s_axis_aclk_1 = s_axis_aclk;
  assign s_axis_aresetn_1 = s_axis_aresetn;
  assign s_axis_tready = s_axis_1_TREADY;
  assign sync_ext_1 = sync_ext;
  test_harness_i_data_offload_1 i_data_offload
       (.init_req(init_req_1),
        .m_axis_aclk(m_axis_aclk_1),
        .m_axis_aresetn(m_axis_aresetn_1),
        .m_axis_data(i_data_offload_m_axis_TDATA),
        .m_axis_ready(i_data_offload_m_axis_TREADY),
        .m_axis_valid(i_data_offload_m_axis_TVALID),
        .m_storage_axis_data(i_data_offload_m_storage_axis_TDATA),
        .m_storage_axis_last(i_data_offload_m_storage_axis_TLAST),
        .m_storage_axis_ready(i_data_offload_m_storage_axis_TREADY),
        .m_storage_axis_tkeep(i_data_offload_m_storage_axis_TKEEP),
        .m_storage_axis_valid(i_data_offload_m_storage_axis_TVALID),
        .rd_request_enable(i_data_offload_rd_ctrl_request_enable),
        .rd_request_length(i_data_offload_rd_ctrl_request_length),
        .rd_request_ready(i_data_offload_rd_ctrl_request_ready),
        .rd_request_valid(i_data_offload_rd_ctrl_request_valid),
        .rd_response_eot(i_data_offload_rd_ctrl_response_eot),
        .rd_underflow(1'b0),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(s_axi_1_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_arprot(s_axi_1_ARPROT),
        .s_axi_arready(s_axi_1_ARREADY),
        .s_axi_arvalid(s_axi_1_ARVALID),
        .s_axi_awaddr(s_axi_1_AWADDR),
        .s_axi_awprot(s_axi_1_AWPROT),
        .s_axi_awready(s_axi_1_AWREADY),
        .s_axi_awvalid(s_axi_1_AWVALID),
        .s_axi_bready(s_axi_1_BREADY),
        .s_axi_bresp(s_axi_1_BRESP),
        .s_axi_bvalid(s_axi_1_BVALID),
        .s_axi_rdata(s_axi_1_RDATA),
        .s_axi_rready(s_axi_1_RREADY),
        .s_axi_rresp(s_axi_1_RRESP),
        .s_axi_rvalid(s_axi_1_RVALID),
        .s_axi_wdata(s_axi_1_WDATA),
        .s_axi_wready(s_axi_1_WREADY),
        .s_axi_wstrb(s_axi_1_WSTRB),
        .s_axi_wvalid(s_axi_1_WVALID),
        .s_axis_aclk(s_axis_aclk_1),
        .s_axis_aresetn(s_axis_aresetn_1),
        .s_axis_data(s_axis_1_TDATA),
        .s_axis_last(s_axis_1_TLAST),
        .s_axis_ready(s_axis_1_TREADY),
        .s_axis_tkeep(s_axis_1_TKEEP),
        .s_axis_valid(s_axis_1_TVALID),
        .s_storage_axis_data(storage_unit_m_axis_TDATA),
        .s_storage_axis_last(storage_unit_m_axis_TLAST),
        .s_storage_axis_ready(storage_unit_m_axis_TREADY),
        .s_storage_axis_tkeep(storage_unit_m_axis_TKEEP),
        .s_storage_axis_valid(storage_unit_m_axis_TVALID),
        .sync_ext(sync_ext_1),
        .wr_overflow(1'b0),
        .wr_request_enable(i_data_offload_wr_ctrl_request_enable),
        .wr_request_length(i_data_offload_wr_ctrl_request_length),
        .wr_request_ready(i_data_offload_wr_ctrl_request_ready),
        .wr_request_valid(i_data_offload_wr_ctrl_request_valid),
        .wr_response_eot(i_data_offload_wr_ctrl_response_eot),
        .wr_response_measured_length(i_data_offload_wr_ctrl_response_measured_length));
  test_harness_storage_unit_1 storage_unit
       (.m_axis_aclk(m_axis_aclk_1),
        .m_axis_aresetn(m_axis_aresetn_1),
        .m_axis_data(storage_unit_m_axis_TDATA),
        .m_axis_keep(storage_unit_m_axis_TKEEP),
        .m_axis_last(storage_unit_m_axis_TLAST),
        .m_axis_ready(storage_unit_m_axis_TREADY),
        .m_axis_valid(storage_unit_m_axis_TVALID),
        .rd_request_enable(i_data_offload_rd_ctrl_request_enable),
        .rd_request_length(i_data_offload_rd_ctrl_request_length),
        .rd_request_ready(i_data_offload_rd_ctrl_request_ready),
        .rd_request_valid(i_data_offload_rd_ctrl_request_valid),
        .rd_response_eot(i_data_offload_rd_ctrl_response_eot),
        .s_axis_aclk(s_axis_aclk_1),
        .s_axis_aresetn(s_axis_aresetn_1),
        .s_axis_data(i_data_offload_m_storage_axis_TDATA),
        .s_axis_keep(i_data_offload_m_storage_axis_TKEEP),
        .s_axis_last(i_data_offload_m_storage_axis_TLAST),
        .s_axis_ready(i_data_offload_m_storage_axis_TREADY),
        .s_axis_strb({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .s_axis_user(1'b0),
        .s_axis_valid(i_data_offload_m_storage_axis_TVALID),
        .wr_request_enable(i_data_offload_wr_ctrl_request_enable),
        .wr_request_length(i_data_offload_wr_ctrl_request_length),
        .wr_request_ready(i_data_offload_wr_ctrl_request_ready),
        .wr_request_valid(i_data_offload_wr_ctrl_request_valid),
        .wr_response_eot(i_data_offload_wr_ctrl_response_eot),
        .wr_response_measured_length(i_data_offload_wr_ctrl_response_measured_length));
endmodule

module rx_mxfe_tpl_core_imp_1EE77FV
   (adc_data_0,
    adc_data_1,
    adc_data_2,
    adc_data_3,
    adc_dovf,
    adc_enable_0,
    adc_enable_1,
    adc_enable_2,
    adc_enable_3,
    adc_rst,
    adc_sync_manual_req_in,
    adc_sync_manual_req_out,
    adc_valid_0,
    adc_valid_1,
    adc_valid_2,
    adc_valid_3,
    ext_sync_in,
    link_clk,
    link_data,
    link_sof,
    link_valid,
    s_axi_aclk,
    s_axi_araddr,
    s_axi_aresetn,
    s_axi_arprot,
    s_axi_arready,
    s_axi_arvalid,
    s_axi_awaddr,
    s_axi_awprot,
    s_axi_awready,
    s_axi_awvalid,
    s_axi_bready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_rdata,
    s_axi_rready,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_wdata,
    s_axi_wready,
    s_axi_wstrb,
    s_axi_wvalid);
  output [127:0]adc_data_0;
  output [127:0]adc_data_1;
  output [127:0]adc_data_2;
  output [127:0]adc_data_3;
  input adc_dovf;
  output [0:0]adc_enable_0;
  output [0:0]adc_enable_1;
  output [0:0]adc_enable_2;
  output [0:0]adc_enable_3;
  output adc_rst;
  input adc_sync_manual_req_in;
  output adc_sync_manual_req_out;
  output [0:0]adc_valid_0;
  output [0:0]adc_valid_1;
  output [0:0]adc_valid_2;
  output [0:0]adc_valid_3;
  input ext_sync_in;
  input link_clk;
  input [383:0]link_data;
  input [11:0]link_sof;
  input link_valid;
  input s_axi_aclk;
  input [12:0]s_axi_araddr;
  input s_axi_aresetn;
  input [2:0]s_axi_arprot;
  output s_axi_arready;
  input s_axi_arvalid;
  input [12:0]s_axi_awaddr;
  input [2:0]s_axi_awprot;
  output s_axi_awready;
  input s_axi_awvalid;
  input s_axi_bready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  output [31:0]s_axi_rdata;
  input s_axi_rready;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input [31:0]s_axi_wdata;
  output s_axi_wready;
  input [3:0]s_axi_wstrb;
  input s_axi_wvalid;

  wire adc_dovf_1;
  wire adc_sync_manual_req_in_1;
  wire [511:0]adc_tpl_core_adc_data;
  wire adc_tpl_core_adc_rst;
  wire adc_tpl_core_adc_sync_manual_req_out;
  wire [3:0]adc_tpl_core_adc_valid;
  wire [3:0]adc_tpl_core_enable;
  wire [127:0]data_slice_0_Dout;
  wire [127:0]data_slice_1_Dout;
  wire [127:0]data_slice_2_Dout;
  wire [127:0]data_slice_3_Dout;
  wire [0:0]enable_slice_0_Dout;
  wire [0:0]enable_slice_1_Dout;
  wire [0:0]enable_slice_2_Dout;
  wire [0:0]enable_slice_3_Dout;
  wire ext_sync_in_1;
  wire link_clk_1;
  wire [383:0]link_data_1;
  wire [11:0]link_sof_1;
  wire link_valid_1;
  wire [12:0]s_axi_1_ARADDR;
  wire [2:0]s_axi_1_ARPROT;
  wire s_axi_1_ARREADY;
  wire s_axi_1_ARVALID;
  wire [12:0]s_axi_1_AWADDR;
  wire [2:0]s_axi_1_AWPROT;
  wire s_axi_1_AWREADY;
  wire s_axi_1_AWVALID;
  wire s_axi_1_BREADY;
  wire [1:0]s_axi_1_BRESP;
  wire s_axi_1_BVALID;
  wire [31:0]s_axi_1_RDATA;
  wire s_axi_1_RREADY;
  wire [1:0]s_axi_1_RRESP;
  wire s_axi_1_RVALID;
  wire [31:0]s_axi_1_WDATA;
  wire s_axi_1_WREADY;
  wire [3:0]s_axi_1_WSTRB;
  wire s_axi_1_WVALID;
  wire s_axi_aclk_1;
  wire s_axi_aresetn_1;
  wire [0:0]valid_slice_0_Dout;
  wire [0:0]valid_slice_1_Dout;
  wire [0:0]valid_slice_2_Dout;
  wire [0:0]valid_slice_3_Dout;

  assign adc_data_0[127:0] = data_slice_0_Dout;
  assign adc_data_1[127:0] = data_slice_1_Dout;
  assign adc_data_2[127:0] = data_slice_2_Dout;
  assign adc_data_3[127:0] = data_slice_3_Dout;
  assign adc_dovf_1 = adc_dovf;
  assign adc_enable_0[0] = enable_slice_0_Dout;
  assign adc_enable_1[0] = enable_slice_1_Dout;
  assign adc_enable_2[0] = enable_slice_2_Dout;
  assign adc_enable_3[0] = enable_slice_3_Dout;
  assign adc_rst = adc_tpl_core_adc_rst;
  assign adc_sync_manual_req_in_1 = adc_sync_manual_req_in;
  assign adc_sync_manual_req_out = adc_tpl_core_adc_sync_manual_req_out;
  assign adc_valid_0[0] = valid_slice_0_Dout;
  assign adc_valid_1[0] = valid_slice_1_Dout;
  assign adc_valid_2[0] = valid_slice_2_Dout;
  assign adc_valid_3[0] = valid_slice_3_Dout;
  assign ext_sync_in_1 = ext_sync_in;
  assign link_clk_1 = link_clk;
  assign link_data_1 = link_data[383:0];
  assign link_sof_1 = link_sof[11:0];
  assign link_valid_1 = link_valid;
  assign s_axi_1_ARADDR = s_axi_araddr[12:0];
  assign s_axi_1_ARPROT = s_axi_arprot[2:0];
  assign s_axi_1_ARVALID = s_axi_arvalid;
  assign s_axi_1_AWADDR = s_axi_awaddr[12:0];
  assign s_axi_1_AWPROT = s_axi_awprot[2:0];
  assign s_axi_1_AWVALID = s_axi_awvalid;
  assign s_axi_1_BREADY = s_axi_bready;
  assign s_axi_1_RREADY = s_axi_rready;
  assign s_axi_1_WDATA = s_axi_wdata[31:0];
  assign s_axi_1_WSTRB = s_axi_wstrb[3:0];
  assign s_axi_1_WVALID = s_axi_wvalid;
  assign s_axi_aclk_1 = s_axi_aclk;
  assign s_axi_aresetn_1 = s_axi_aresetn;
  assign s_axi_arready = s_axi_1_ARREADY;
  assign s_axi_awready = s_axi_1_AWREADY;
  assign s_axi_bresp[1:0] = s_axi_1_BRESP;
  assign s_axi_bvalid = s_axi_1_BVALID;
  assign s_axi_rdata[31:0] = s_axi_1_RDATA;
  assign s_axi_rresp[1:0] = s_axi_1_RRESP;
  assign s_axi_rvalid = s_axi_1_RVALID;
  assign s_axi_wready = s_axi_1_WREADY;
  test_harness_adc_tpl_core_0 adc_tpl_core
       (.adc_data(adc_tpl_core_adc_data),
        .adc_dovf(adc_dovf_1),
        .adc_rst(adc_tpl_core_adc_rst),
        .adc_sync_in(ext_sync_in_1),
        .adc_sync_manual_req_in(adc_sync_manual_req_in_1),
        .adc_sync_manual_req_out(adc_tpl_core_adc_sync_manual_req_out),
        .adc_valid(adc_tpl_core_adc_valid),
        .enable(adc_tpl_core_enable),
        .link_clk(link_clk_1),
        .link_data(link_data_1),
        .link_sof(link_sof_1),
        .link_valid(link_valid_1),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(s_axi_1_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_arprot(s_axi_1_ARPROT),
        .s_axi_arready(s_axi_1_ARREADY),
        .s_axi_arvalid(s_axi_1_ARVALID),
        .s_axi_awaddr(s_axi_1_AWADDR),
        .s_axi_awprot(s_axi_1_AWPROT),
        .s_axi_awready(s_axi_1_AWREADY),
        .s_axi_awvalid(s_axi_1_AWVALID),
        .s_axi_bready(s_axi_1_BREADY),
        .s_axi_bresp(s_axi_1_BRESP),
        .s_axi_bvalid(s_axi_1_BVALID),
        .s_axi_rdata(s_axi_1_RDATA),
        .s_axi_rready(s_axi_1_RREADY),
        .s_axi_rresp(s_axi_1_RRESP),
        .s_axi_rvalid(s_axi_1_RVALID),
        .s_axi_wdata(s_axi_1_WDATA),
        .s_axi_wready(s_axi_1_WREADY),
        .s_axi_wstrb(s_axi_1_WSTRB),
        .s_axi_wvalid(s_axi_1_WVALID));
  test_harness_data_slice_0_0 data_slice_0
       (.Din(adc_tpl_core_adc_data),
        .Dout(data_slice_0_Dout));
  test_harness_data_slice_1_0 data_slice_1
       (.Din(adc_tpl_core_adc_data),
        .Dout(data_slice_1_Dout));
  test_harness_data_slice_2_0 data_slice_2
       (.Din(adc_tpl_core_adc_data),
        .Dout(data_slice_2_Dout));
  test_harness_data_slice_3_0 data_slice_3
       (.Din(adc_tpl_core_adc_data),
        .Dout(data_slice_3_Dout));
  test_harness_enable_slice_0_0 enable_slice_0
       (.Din(adc_tpl_core_enable),
        .Dout(enable_slice_0_Dout));
  test_harness_enable_slice_1_0 enable_slice_1
       (.Din(adc_tpl_core_enable),
        .Dout(enable_slice_1_Dout));
  test_harness_enable_slice_2_0 enable_slice_2
       (.Din(adc_tpl_core_enable),
        .Dout(enable_slice_2_Dout));
  test_harness_enable_slice_3_0 enable_slice_3
       (.Din(adc_tpl_core_enable),
        .Dout(enable_slice_3_Dout));
  test_harness_valid_slice_0_0 valid_slice_0
       (.Din(adc_tpl_core_adc_valid),
        .Dout(valid_slice_0_Dout));
  test_harness_valid_slice_1_0 valid_slice_1
       (.Din(adc_tpl_core_adc_valid),
        .Dout(valid_slice_1_Dout));
  test_harness_valid_slice_2_0 valid_slice_2
       (.Din(adc_tpl_core_adc_valid),
        .Dout(valid_slice_2_Dout));
  test_harness_valid_slice_3_0 valid_slice_3
       (.Din(adc_tpl_core_adc_valid),
        .Dout(valid_slice_3_Dout));
endmodule

(* CORE_GENERATION_INFO = "test_harness,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=test_harness,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=71,numReposBlks=65,numNonXlnxBlks=17,numHierBlks=6,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "test_harness.hwdef" *) 
module test_harness
   (device_clk_out,
    ext_sync_in,
    irq,
    ref_clk_out,
    ref_clk_q0,
    ref_clk_q1,
    rx_data_0_n,
    rx_data_0_p,
    rx_data_1_n,
    rx_data_1_p,
    rx_data_2_n,
    rx_data_2_p,
    rx_data_3_n,
    rx_data_3_p,
    rx_data_4_n,
    rx_data_4_p,
    rx_data_5_n,
    rx_data_5_p,
    rx_data_6_n,
    rx_data_6_p,
    rx_data_7_n,
    rx_data_7_p,
    rx_device_clk,
    rx_sync_0,
    rx_sysref_0,
    sysref_clk_out,
    tx_data_0_n,
    tx_data_0_p,
    tx_data_1_n,
    tx_data_1_p,
    tx_data_2_n,
    tx_data_2_p,
    tx_data_3_n,
    tx_data_3_p,
    tx_data_4_n,
    tx_data_4_p,
    tx_data_5_n,
    tx_data_5_p,
    tx_data_6_n,
    tx_data_6_p,
    tx_data_7_n,
    tx_data_7_p,
    tx_device_clk,
    tx_sync_0,
    tx_sysref_0);
  output device_clk_out;
  input ext_sync_in;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.IRQ INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.IRQ, PortWidth 1, SENSITIVITY LEVEL_HIGH" *) output irq;
  output ref_clk_out;
  input ref_clk_q0;
  input ref_clk_q1;
  input rx_data_0_n;
  input rx_data_0_p;
  input rx_data_1_n;
  input rx_data_1_p;
  input rx_data_2_n;
  input rx_data_2_p;
  input rx_data_3_n;
  input rx_data_3_p;
  input rx_data_4_n;
  input rx_data_4_p;
  input rx_data_5_n;
  input rx_data_5_p;
  input rx_data_6_n;
  input rx_data_6_p;
  input rx_data_7_n;
  input rx_data_7_p;
  input rx_device_clk;
  output [0:0]rx_sync_0;
  input rx_sysref_0;
  output sysref_clk_out;
  output tx_data_0_n;
  output tx_data_0_p;
  output tx_data_1_n;
  output tx_data_1_p;
  output tx_data_2_n;
  output tx_data_2_p;
  output tx_data_3_n;
  output tx_data_3_p;
  output tx_data_4_n;
  output tx_data_4_p;
  output tx_data_5_n;
  output tx_data_5_p;
  output tx_data_6_n;
  output tx_data_6_p;
  output tx_data_7_n;
  output tx_data_7_p;
  input tx_device_clk;
  input [0:0]tx_sync_0;
  input tx_sysref_0;

  wire [0:0]GND_1_dout;
  wire [0:0]VCC_1_dout;
  wire [8:0]axi_axi_interconnect_M00_AXI_ARADDR;
  wire axi_axi_interconnect_M00_AXI_ARREADY;
  wire axi_axi_interconnect_M00_AXI_ARVALID;
  wire [8:0]axi_axi_interconnect_M00_AXI_AWADDR;
  wire axi_axi_interconnect_M00_AXI_AWREADY;
  wire axi_axi_interconnect_M00_AXI_AWVALID;
  wire axi_axi_interconnect_M00_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M00_AXI_BRESP;
  wire axi_axi_interconnect_M00_AXI_BVALID;
  wire [31:0]axi_axi_interconnect_M00_AXI_RDATA;
  wire axi_axi_interconnect_M00_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M00_AXI_RRESP;
  wire axi_axi_interconnect_M00_AXI_RVALID;
  wire [31:0]axi_axi_interconnect_M00_AXI_WDATA;
  wire axi_axi_interconnect_M00_AXI_WREADY;
  wire [3:0]axi_axi_interconnect_M00_AXI_WSTRB;
  wire axi_axi_interconnect_M00_AXI_WVALID;
  wire [31:0]axi_axi_interconnect_M01_AXI_ARADDR;
  wire [1:0]axi_axi_interconnect_M01_AXI_ARBURST;
  wire [3:0]axi_axi_interconnect_M01_AXI_ARCACHE;
  wire [2:0]axi_axi_interconnect_M01_AXI_ARID;
  wire [7:0]axi_axi_interconnect_M01_AXI_ARLEN;
  wire [0:0]axi_axi_interconnect_M01_AXI_ARLOCK;
  wire [2:0]axi_axi_interconnect_M01_AXI_ARPROT;
  wire [3:0]axi_axi_interconnect_M01_AXI_ARQOS;
  wire axi_axi_interconnect_M01_AXI_ARREADY;
  wire [2:0]axi_axi_interconnect_M01_AXI_ARSIZE;
  wire [113:0]axi_axi_interconnect_M01_AXI_ARUSER;
  wire axi_axi_interconnect_M01_AXI_ARVALID;
  wire [31:0]axi_axi_interconnect_M01_AXI_AWADDR;
  wire [1:0]axi_axi_interconnect_M01_AXI_AWBURST;
  wire [3:0]axi_axi_interconnect_M01_AXI_AWCACHE;
  wire [2:0]axi_axi_interconnect_M01_AXI_AWID;
  wire [7:0]axi_axi_interconnect_M01_AXI_AWLEN;
  wire [0:0]axi_axi_interconnect_M01_AXI_AWLOCK;
  wire [2:0]axi_axi_interconnect_M01_AXI_AWPROT;
  wire [3:0]axi_axi_interconnect_M01_AXI_AWQOS;
  wire axi_axi_interconnect_M01_AXI_AWREADY;
  wire [2:0]axi_axi_interconnect_M01_AXI_AWSIZE;
  wire [113:0]axi_axi_interconnect_M01_AXI_AWUSER;
  wire axi_axi_interconnect_M01_AXI_AWVALID;
  wire [2:0]axi_axi_interconnect_M01_AXI_BID;
  wire axi_axi_interconnect_M01_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M01_AXI_BRESP;
  wire [113:0]axi_axi_interconnect_M01_AXI_BUSER;
  wire axi_axi_interconnect_M01_AXI_BVALID;
  wire [511:0]axi_axi_interconnect_M01_AXI_RDATA;
  wire [2:0]axi_axi_interconnect_M01_AXI_RID;
  wire axi_axi_interconnect_M01_AXI_RLAST;
  wire axi_axi_interconnect_M01_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M01_AXI_RRESP;
  wire [13:0]axi_axi_interconnect_M01_AXI_RUSER;
  wire axi_axi_interconnect_M01_AXI_RVALID;
  wire [511:0]axi_axi_interconnect_M01_AXI_WDATA;
  wire axi_axi_interconnect_M01_AXI_WLAST;
  wire axi_axi_interconnect_M01_AXI_WREADY;
  wire [63:0]axi_axi_interconnect_M01_AXI_WSTRB;
  wire [13:0]axi_axi_interconnect_M01_AXI_WUSER;
  wire axi_axi_interconnect_M01_AXI_WVALID;
  wire [15:0]axi_axi_interconnect_M02_AXI_ARADDR;
  wire [2:0]axi_axi_interconnect_M02_AXI_ARPROT;
  wire axi_axi_interconnect_M02_AXI_ARREADY;
  wire axi_axi_interconnect_M02_AXI_ARVALID;
  wire [15:0]axi_axi_interconnect_M02_AXI_AWADDR;
  wire [2:0]axi_axi_interconnect_M02_AXI_AWPROT;
  wire axi_axi_interconnect_M02_AXI_AWREADY;
  wire axi_axi_interconnect_M02_AXI_AWVALID;
  wire axi_axi_interconnect_M02_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M02_AXI_BRESP;
  wire axi_axi_interconnect_M02_AXI_BVALID;
  wire [31:0]axi_axi_interconnect_M02_AXI_RDATA;
  wire axi_axi_interconnect_M02_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M02_AXI_RRESP;
  wire axi_axi_interconnect_M02_AXI_RVALID;
  wire [31:0]axi_axi_interconnect_M02_AXI_WDATA;
  wire axi_axi_interconnect_M02_AXI_WREADY;
  wire [3:0]axi_axi_interconnect_M02_AXI_WSTRB;
  wire axi_axi_interconnect_M02_AXI_WVALID;
  wire [12:0]axi_axi_interconnect_M03_AXI_ARADDR;
  wire [2:0]axi_axi_interconnect_M03_AXI_ARPROT;
  wire axi_axi_interconnect_M03_AXI_ARREADY;
  wire axi_axi_interconnect_M03_AXI_ARVALID;
  wire [12:0]axi_axi_interconnect_M03_AXI_AWADDR;
  wire [2:0]axi_axi_interconnect_M03_AXI_AWPROT;
  wire axi_axi_interconnect_M03_AXI_AWREADY;
  wire axi_axi_interconnect_M03_AXI_AWVALID;
  wire axi_axi_interconnect_M03_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M03_AXI_BRESP;
  wire axi_axi_interconnect_M03_AXI_BVALID;
  wire [31:0]axi_axi_interconnect_M03_AXI_RDATA;
  wire axi_axi_interconnect_M03_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M03_AXI_RRESP;
  wire axi_axi_interconnect_M03_AXI_RVALID;
  wire [31:0]axi_axi_interconnect_M03_AXI_WDATA;
  wire axi_axi_interconnect_M03_AXI_WREADY;
  wire [3:0]axi_axi_interconnect_M03_AXI_WSTRB;
  wire axi_axi_interconnect_M03_AXI_WVALID;
  wire [13:0]axi_axi_interconnect_M04_AXI_ARADDR;
  wire [2:0]axi_axi_interconnect_M04_AXI_ARPROT;
  wire axi_axi_interconnect_M04_AXI_ARREADY;
  wire axi_axi_interconnect_M04_AXI_ARVALID;
  wire [13:0]axi_axi_interconnect_M04_AXI_AWADDR;
  wire [2:0]axi_axi_interconnect_M04_AXI_AWPROT;
  wire axi_axi_interconnect_M04_AXI_AWREADY;
  wire axi_axi_interconnect_M04_AXI_AWVALID;
  wire axi_axi_interconnect_M04_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M04_AXI_BRESP;
  wire axi_axi_interconnect_M04_AXI_BVALID;
  wire [31:0]axi_axi_interconnect_M04_AXI_RDATA;
  wire axi_axi_interconnect_M04_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M04_AXI_RRESP;
  wire axi_axi_interconnect_M04_AXI_RVALID;
  wire [31:0]axi_axi_interconnect_M04_AXI_WDATA;
  wire axi_axi_interconnect_M04_AXI_WREADY;
  wire [3:0]axi_axi_interconnect_M04_AXI_WSTRB;
  wire axi_axi_interconnect_M04_AXI_WVALID;
  wire [10:0]axi_axi_interconnect_M05_AXI_ARADDR;
  wire [2:0]axi_axi_interconnect_M05_AXI_ARPROT;
  wire axi_axi_interconnect_M05_AXI_ARREADY;
  wire axi_axi_interconnect_M05_AXI_ARVALID;
  wire [10:0]axi_axi_interconnect_M05_AXI_AWADDR;
  wire [2:0]axi_axi_interconnect_M05_AXI_AWPROT;
  wire axi_axi_interconnect_M05_AXI_AWREADY;
  wire axi_axi_interconnect_M05_AXI_AWVALID;
  wire axi_axi_interconnect_M05_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M05_AXI_BRESP;
  wire axi_axi_interconnect_M05_AXI_BVALID;
  wire [31:0]axi_axi_interconnect_M05_AXI_RDATA;
  wire axi_axi_interconnect_M05_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M05_AXI_RRESP;
  wire axi_axi_interconnect_M05_AXI_RVALID;
  wire [31:0]axi_axi_interconnect_M05_AXI_WDATA;
  wire axi_axi_interconnect_M05_AXI_WREADY;
  wire [3:0]axi_axi_interconnect_M05_AXI_WSTRB;
  wire axi_axi_interconnect_M05_AXI_WVALID;
  wire [15:0]axi_axi_interconnect_M06_AXI_ARADDR;
  wire [2:0]axi_axi_interconnect_M06_AXI_ARPROT;
  wire axi_axi_interconnect_M06_AXI_ARREADY;
  wire axi_axi_interconnect_M06_AXI_ARVALID;
  wire [15:0]axi_axi_interconnect_M06_AXI_AWADDR;
  wire [2:0]axi_axi_interconnect_M06_AXI_AWPROT;
  wire axi_axi_interconnect_M06_AXI_AWREADY;
  wire axi_axi_interconnect_M06_AXI_AWVALID;
  wire axi_axi_interconnect_M06_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M06_AXI_BRESP;
  wire axi_axi_interconnect_M06_AXI_BVALID;
  wire [31:0]axi_axi_interconnect_M06_AXI_RDATA;
  wire axi_axi_interconnect_M06_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M06_AXI_RRESP;
  wire axi_axi_interconnect_M06_AXI_RVALID;
  wire [31:0]axi_axi_interconnect_M06_AXI_WDATA;
  wire axi_axi_interconnect_M06_AXI_WREADY;
  wire [3:0]axi_axi_interconnect_M06_AXI_WSTRB;
  wire axi_axi_interconnect_M06_AXI_WVALID;
  wire [15:0]axi_axi_interconnect_M07_AXI_ARADDR;
  wire [2:0]axi_axi_interconnect_M07_AXI_ARPROT;
  wire axi_axi_interconnect_M07_AXI_ARREADY;
  wire axi_axi_interconnect_M07_AXI_ARVALID;
  wire [15:0]axi_axi_interconnect_M07_AXI_AWADDR;
  wire [2:0]axi_axi_interconnect_M07_AXI_AWPROT;
  wire axi_axi_interconnect_M07_AXI_AWREADY;
  wire axi_axi_interconnect_M07_AXI_AWVALID;
  wire axi_axi_interconnect_M07_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M07_AXI_BRESP;
  wire axi_axi_interconnect_M07_AXI_BVALID;
  wire [31:0]axi_axi_interconnect_M07_AXI_RDATA;
  wire axi_axi_interconnect_M07_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M07_AXI_RRESP;
  wire axi_axi_interconnect_M07_AXI_RVALID;
  wire [31:0]axi_axi_interconnect_M07_AXI_WDATA;
  wire axi_axi_interconnect_M07_AXI_WREADY;
  wire [3:0]axi_axi_interconnect_M07_AXI_WSTRB;
  wire axi_axi_interconnect_M07_AXI_WVALID;
  wire [12:0]axi_axi_interconnect_M08_AXI_ARADDR;
  wire [2:0]axi_axi_interconnect_M08_AXI_ARPROT;
  wire axi_axi_interconnect_M08_AXI_ARREADY;
  wire axi_axi_interconnect_M08_AXI_ARVALID;
  wire [12:0]axi_axi_interconnect_M08_AXI_AWADDR;
  wire [2:0]axi_axi_interconnect_M08_AXI_AWPROT;
  wire axi_axi_interconnect_M08_AXI_AWREADY;
  wire axi_axi_interconnect_M08_AXI_AWVALID;
  wire axi_axi_interconnect_M08_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M08_AXI_BRESP;
  wire axi_axi_interconnect_M08_AXI_BVALID;
  wire [31:0]axi_axi_interconnect_M08_AXI_RDATA;
  wire axi_axi_interconnect_M08_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M08_AXI_RRESP;
  wire axi_axi_interconnect_M08_AXI_RVALID;
  wire [31:0]axi_axi_interconnect_M08_AXI_WDATA;
  wire axi_axi_interconnect_M08_AXI_WREADY;
  wire [3:0]axi_axi_interconnect_M08_AXI_WSTRB;
  wire axi_axi_interconnect_M08_AXI_WVALID;
  wire [13:0]axi_axi_interconnect_M09_AXI_ARADDR;
  wire [2:0]axi_axi_interconnect_M09_AXI_ARPROT;
  wire axi_axi_interconnect_M09_AXI_ARREADY;
  wire axi_axi_interconnect_M09_AXI_ARVALID;
  wire [13:0]axi_axi_interconnect_M09_AXI_AWADDR;
  wire [2:0]axi_axi_interconnect_M09_AXI_AWPROT;
  wire axi_axi_interconnect_M09_AXI_AWREADY;
  wire axi_axi_interconnect_M09_AXI_AWVALID;
  wire axi_axi_interconnect_M09_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M09_AXI_BRESP;
  wire axi_axi_interconnect_M09_AXI_BVALID;
  wire [31:0]axi_axi_interconnect_M09_AXI_RDATA;
  wire axi_axi_interconnect_M09_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M09_AXI_RRESP;
  wire axi_axi_interconnect_M09_AXI_RVALID;
  wire [31:0]axi_axi_interconnect_M09_AXI_WDATA;
  wire axi_axi_interconnect_M09_AXI_WREADY;
  wire [3:0]axi_axi_interconnect_M09_AXI_WSTRB;
  wire axi_axi_interconnect_M09_AXI_WVALID;
  wire [10:0]axi_axi_interconnect_M10_AXI_ARADDR;
  wire [2:0]axi_axi_interconnect_M10_AXI_ARPROT;
  wire axi_axi_interconnect_M10_AXI_ARREADY;
  wire axi_axi_interconnect_M10_AXI_ARVALID;
  wire [10:0]axi_axi_interconnect_M10_AXI_AWADDR;
  wire [2:0]axi_axi_interconnect_M10_AXI_AWPROT;
  wire axi_axi_interconnect_M10_AXI_AWREADY;
  wire axi_axi_interconnect_M10_AXI_AWVALID;
  wire axi_axi_interconnect_M10_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M10_AXI_BRESP;
  wire axi_axi_interconnect_M10_AXI_BVALID;
  wire [31:0]axi_axi_interconnect_M10_AXI_RDATA;
  wire axi_axi_interconnect_M10_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M10_AXI_RRESP;
  wire axi_axi_interconnect_M10_AXI_RVALID;
  wire [31:0]axi_axi_interconnect_M10_AXI_WDATA;
  wire axi_axi_interconnect_M10_AXI_WREADY;
  wire [3:0]axi_axi_interconnect_M10_AXI_WSTRB;
  wire axi_axi_interconnect_M10_AXI_WVALID;
  wire [15:0]axi_axi_interconnect_M11_AXI_ARADDR;
  wire [2:0]axi_axi_interconnect_M11_AXI_ARPROT;
  wire axi_axi_interconnect_M11_AXI_ARREADY;
  wire axi_axi_interconnect_M11_AXI_ARVALID;
  wire [15:0]axi_axi_interconnect_M11_AXI_AWADDR;
  wire [2:0]axi_axi_interconnect_M11_AXI_AWPROT;
  wire axi_axi_interconnect_M11_AXI_AWREADY;
  wire axi_axi_interconnect_M11_AXI_AWVALID;
  wire axi_axi_interconnect_M11_AXI_BREADY;
  wire [1:0]axi_axi_interconnect_M11_AXI_BRESP;
  wire axi_axi_interconnect_M11_AXI_BVALID;
  wire [31:0]axi_axi_interconnect_M11_AXI_RDATA;
  wire axi_axi_interconnect_M11_AXI_RREADY;
  wire [1:0]axi_axi_interconnect_M11_AXI_RRESP;
  wire axi_axi_interconnect_M11_AXI_RVALID;
  wire [31:0]axi_axi_interconnect_M11_AXI_WDATA;
  wire axi_axi_interconnect_M11_AXI_WREADY;
  wire [3:0]axi_axi_interconnect_M11_AXI_WSTRB;
  wire axi_axi_interconnect_M11_AXI_WVALID;
  wire axi_intc_irq;
  wire [31:0]axi_mem_interconnect_M00_AXI_ARADDR;
  wire [1:0]axi_mem_interconnect_M00_AXI_ARBURST;
  wire [3:0]axi_mem_interconnect_M00_AXI_ARCACHE;
  wire [7:0]axi_mem_interconnect_M00_AXI_ARLEN;
  wire [0:0]axi_mem_interconnect_M00_AXI_ARLOCK;
  wire [2:0]axi_mem_interconnect_M00_AXI_ARPROT;
  wire [3:0]axi_mem_interconnect_M00_AXI_ARQOS;
  wire axi_mem_interconnect_M00_AXI_ARREADY;
  wire axi_mem_interconnect_M00_AXI_ARVALID;
  wire [31:0]axi_mem_interconnect_M00_AXI_AWADDR;
  wire [1:0]axi_mem_interconnect_M00_AXI_AWBURST;
  wire [3:0]axi_mem_interconnect_M00_AXI_AWCACHE;
  wire [7:0]axi_mem_interconnect_M00_AXI_AWLEN;
  wire [0:0]axi_mem_interconnect_M00_AXI_AWLOCK;
  wire [2:0]axi_mem_interconnect_M00_AXI_AWPROT;
  wire [3:0]axi_mem_interconnect_M00_AXI_AWQOS;
  wire axi_mem_interconnect_M00_AXI_AWREADY;
  wire axi_mem_interconnect_M00_AXI_AWVALID;
  wire axi_mem_interconnect_M00_AXI_BREADY;
  wire [1:0]axi_mem_interconnect_M00_AXI_BRESP;
  wire axi_mem_interconnect_M00_AXI_BVALID;
  wire [511:0]axi_mem_interconnect_M00_AXI_RDATA;
  wire axi_mem_interconnect_M00_AXI_RLAST;
  wire axi_mem_interconnect_M00_AXI_RREADY;
  wire [1:0]axi_mem_interconnect_M00_AXI_RRESP;
  wire axi_mem_interconnect_M00_AXI_RVALID;
  wire [511:0]axi_mem_interconnect_M00_AXI_WDATA;
  wire axi_mem_interconnect_M00_AXI_WLAST;
  wire axi_mem_interconnect_M00_AXI_WREADY;
  wire [63:0]axi_mem_interconnect_M00_AXI_WSTRB;
  wire axi_mem_interconnect_M00_AXI_WVALID;
  wire axi_mxfe_rx_dma_irq;
  wire [31:0]axi_mxfe_rx_dma_m_dest_axi_AWADDR;
  wire [1:0]axi_mxfe_rx_dma_m_dest_axi_AWBURST;
  wire [3:0]axi_mxfe_rx_dma_m_dest_axi_AWCACHE;
  wire [7:0]axi_mxfe_rx_dma_m_dest_axi_AWLEN;
  wire [2:0]axi_mxfe_rx_dma_m_dest_axi_AWPROT;
  wire axi_mxfe_rx_dma_m_dest_axi_AWREADY;
  wire [2:0]axi_mxfe_rx_dma_m_dest_axi_AWSIZE;
  wire axi_mxfe_rx_dma_m_dest_axi_AWVALID;
  wire axi_mxfe_rx_dma_m_dest_axi_BREADY;
  wire [1:0]axi_mxfe_rx_dma_m_dest_axi_BRESP;
  wire axi_mxfe_rx_dma_m_dest_axi_BVALID;
  wire [511:0]axi_mxfe_rx_dma_m_dest_axi_WDATA;
  wire axi_mxfe_rx_dma_m_dest_axi_WLAST;
  wire axi_mxfe_rx_dma_m_dest_axi_WREADY;
  wire [63:0]axi_mxfe_rx_dma_m_dest_axi_WSTRB;
  wire axi_mxfe_rx_dma_m_dest_axi_WVALID;
  wire axi_mxfe_rx_jesd_irq;
  wire [383:0]axi_mxfe_rx_jesd_rx_data_tdata;
  wire axi_mxfe_rx_jesd_rx_data_tvalid;
  wire [11:0]axi_mxfe_rx_jesd_rx_sof;
  wire [31:0]axi_mxfe_rx_xcvr_m_axi_ARADDR;
  wire [2:0]axi_mxfe_rx_xcvr_m_axi_ARPROT;
  wire axi_mxfe_rx_xcvr_m_axi_ARREADY;
  wire axi_mxfe_rx_xcvr_m_axi_ARVALID;
  wire [31:0]axi_mxfe_rx_xcvr_m_axi_AWADDR;
  wire [2:0]axi_mxfe_rx_xcvr_m_axi_AWPROT;
  wire axi_mxfe_rx_xcvr_m_axi_AWREADY;
  wire axi_mxfe_rx_xcvr_m_axi_AWVALID;
  wire axi_mxfe_rx_xcvr_m_axi_BREADY;
  wire [1:0]axi_mxfe_rx_xcvr_m_axi_BRESP;
  wire axi_mxfe_rx_xcvr_m_axi_BVALID;
  wire [31:0]axi_mxfe_rx_xcvr_m_axi_RDATA;
  wire axi_mxfe_rx_xcvr_m_axi_RREADY;
  wire [1:0]axi_mxfe_rx_xcvr_m_axi_RRESP;
  wire axi_mxfe_rx_xcvr_m_axi_RVALID;
  wire [31:0]axi_mxfe_rx_xcvr_m_axi_WDATA;
  wire axi_mxfe_rx_xcvr_m_axi_WREADY;
  wire [3:0]axi_mxfe_rx_xcvr_m_axi_WSTRB;
  wire axi_mxfe_rx_xcvr_m_axi_WVALID;
  wire [11:0]axi_mxfe_rx_xcvr_up_ch_0_addr;
  wire [1:0]axi_mxfe_rx_xcvr_up_ch_0_bufstatus;
  wire axi_mxfe_rx_xcvr_up_ch_0_bufstatus_rst;
  wire axi_mxfe_rx_xcvr_up_ch_0_enb;
  wire axi_mxfe_rx_xcvr_up_ch_0_lpm_dfe_n;
  wire [2:0]axi_mxfe_rx_xcvr_up_ch_0_out_clk_sel;
  wire axi_mxfe_rx_xcvr_up_ch_0_pll_locked;
  wire axi_mxfe_rx_xcvr_up_ch_0_prbscntreset;
  wire axi_mxfe_rx_xcvr_up_ch_0_prbserr;
  wire axi_mxfe_rx_xcvr_up_ch_0_prbslocked;
  wire [3:0]axi_mxfe_rx_xcvr_up_ch_0_prbssel;
  wire [2:0]axi_mxfe_rx_xcvr_up_ch_0_rate;
  wire [15:0]axi_mxfe_rx_xcvr_up_ch_0_rdata;
  wire axi_mxfe_rx_xcvr_up_ch_0_ready;
  wire axi_mxfe_rx_xcvr_up_ch_0_rst;
  wire axi_mxfe_rx_xcvr_up_ch_0_rst_done;
  wire [1:0]axi_mxfe_rx_xcvr_up_ch_0_sys_clk_sel;
  wire axi_mxfe_rx_xcvr_up_ch_0_user_ready;
  wire [15:0]axi_mxfe_rx_xcvr_up_ch_0_wdata;
  wire axi_mxfe_rx_xcvr_up_ch_0_wr;
  wire [11:0]axi_mxfe_rx_xcvr_up_ch_1_addr;
  wire [1:0]axi_mxfe_rx_xcvr_up_ch_1_bufstatus;
  wire axi_mxfe_rx_xcvr_up_ch_1_bufstatus_rst;
  wire axi_mxfe_rx_xcvr_up_ch_1_enb;
  wire axi_mxfe_rx_xcvr_up_ch_1_lpm_dfe_n;
  wire [2:0]axi_mxfe_rx_xcvr_up_ch_1_out_clk_sel;
  wire axi_mxfe_rx_xcvr_up_ch_1_pll_locked;
  wire axi_mxfe_rx_xcvr_up_ch_1_prbscntreset;
  wire axi_mxfe_rx_xcvr_up_ch_1_prbserr;
  wire axi_mxfe_rx_xcvr_up_ch_1_prbslocked;
  wire [3:0]axi_mxfe_rx_xcvr_up_ch_1_prbssel;
  wire [2:0]axi_mxfe_rx_xcvr_up_ch_1_rate;
  wire [15:0]axi_mxfe_rx_xcvr_up_ch_1_rdata;
  wire axi_mxfe_rx_xcvr_up_ch_1_ready;
  wire axi_mxfe_rx_xcvr_up_ch_1_rst;
  wire axi_mxfe_rx_xcvr_up_ch_1_rst_done;
  wire [1:0]axi_mxfe_rx_xcvr_up_ch_1_sys_clk_sel;
  wire axi_mxfe_rx_xcvr_up_ch_1_user_ready;
  wire [15:0]axi_mxfe_rx_xcvr_up_ch_1_wdata;
  wire axi_mxfe_rx_xcvr_up_ch_1_wr;
  wire [11:0]axi_mxfe_rx_xcvr_up_ch_2_addr;
  wire [1:0]axi_mxfe_rx_xcvr_up_ch_2_bufstatus;
  wire axi_mxfe_rx_xcvr_up_ch_2_bufstatus_rst;
  wire axi_mxfe_rx_xcvr_up_ch_2_enb;
  wire axi_mxfe_rx_xcvr_up_ch_2_lpm_dfe_n;
  wire [2:0]axi_mxfe_rx_xcvr_up_ch_2_out_clk_sel;
  wire axi_mxfe_rx_xcvr_up_ch_2_pll_locked;
  wire axi_mxfe_rx_xcvr_up_ch_2_prbscntreset;
  wire axi_mxfe_rx_xcvr_up_ch_2_prbserr;
  wire axi_mxfe_rx_xcvr_up_ch_2_prbslocked;
  wire [3:0]axi_mxfe_rx_xcvr_up_ch_2_prbssel;
  wire [2:0]axi_mxfe_rx_xcvr_up_ch_2_rate;
  wire [15:0]axi_mxfe_rx_xcvr_up_ch_2_rdata;
  wire axi_mxfe_rx_xcvr_up_ch_2_ready;
  wire axi_mxfe_rx_xcvr_up_ch_2_rst;
  wire axi_mxfe_rx_xcvr_up_ch_2_rst_done;
  wire [1:0]axi_mxfe_rx_xcvr_up_ch_2_sys_clk_sel;
  wire axi_mxfe_rx_xcvr_up_ch_2_user_ready;
  wire [15:0]axi_mxfe_rx_xcvr_up_ch_2_wdata;
  wire axi_mxfe_rx_xcvr_up_ch_2_wr;
  wire [11:0]axi_mxfe_rx_xcvr_up_ch_3_addr;
  wire [1:0]axi_mxfe_rx_xcvr_up_ch_3_bufstatus;
  wire axi_mxfe_rx_xcvr_up_ch_3_bufstatus_rst;
  wire axi_mxfe_rx_xcvr_up_ch_3_enb;
  wire axi_mxfe_rx_xcvr_up_ch_3_lpm_dfe_n;
  wire [2:0]axi_mxfe_rx_xcvr_up_ch_3_out_clk_sel;
  wire axi_mxfe_rx_xcvr_up_ch_3_pll_locked;
  wire axi_mxfe_rx_xcvr_up_ch_3_prbscntreset;
  wire axi_mxfe_rx_xcvr_up_ch_3_prbserr;
  wire axi_mxfe_rx_xcvr_up_ch_3_prbslocked;
  wire [3:0]axi_mxfe_rx_xcvr_up_ch_3_prbssel;
  wire [2:0]axi_mxfe_rx_xcvr_up_ch_3_rate;
  wire [15:0]axi_mxfe_rx_xcvr_up_ch_3_rdata;
  wire axi_mxfe_rx_xcvr_up_ch_3_ready;
  wire axi_mxfe_rx_xcvr_up_ch_3_rst;
  wire axi_mxfe_rx_xcvr_up_ch_3_rst_done;
  wire [1:0]axi_mxfe_rx_xcvr_up_ch_3_sys_clk_sel;
  wire axi_mxfe_rx_xcvr_up_ch_3_user_ready;
  wire [15:0]axi_mxfe_rx_xcvr_up_ch_3_wdata;
  wire axi_mxfe_rx_xcvr_up_ch_3_wr;
  wire [11:0]axi_mxfe_rx_xcvr_up_es_0_addr;
  wire axi_mxfe_rx_xcvr_up_es_0_enb;
  wire [15:0]axi_mxfe_rx_xcvr_up_es_0_rdata;
  wire axi_mxfe_rx_xcvr_up_es_0_ready;
  wire axi_mxfe_rx_xcvr_up_es_0_reset;
  wire [15:0]axi_mxfe_rx_xcvr_up_es_0_wdata;
  wire axi_mxfe_rx_xcvr_up_es_0_wr;
  wire [11:0]axi_mxfe_rx_xcvr_up_es_1_addr;
  wire axi_mxfe_rx_xcvr_up_es_1_enb;
  wire [15:0]axi_mxfe_rx_xcvr_up_es_1_rdata;
  wire axi_mxfe_rx_xcvr_up_es_1_ready;
  wire axi_mxfe_rx_xcvr_up_es_1_reset;
  wire [15:0]axi_mxfe_rx_xcvr_up_es_1_wdata;
  wire axi_mxfe_rx_xcvr_up_es_1_wr;
  wire [11:0]axi_mxfe_rx_xcvr_up_es_2_addr;
  wire axi_mxfe_rx_xcvr_up_es_2_enb;
  wire [15:0]axi_mxfe_rx_xcvr_up_es_2_rdata;
  wire axi_mxfe_rx_xcvr_up_es_2_ready;
  wire axi_mxfe_rx_xcvr_up_es_2_reset;
  wire [15:0]axi_mxfe_rx_xcvr_up_es_2_wdata;
  wire axi_mxfe_rx_xcvr_up_es_2_wr;
  wire [11:0]axi_mxfe_rx_xcvr_up_es_3_addr;
  wire axi_mxfe_rx_xcvr_up_es_3_enb;
  wire [15:0]axi_mxfe_rx_xcvr_up_es_3_rdata;
  wire axi_mxfe_rx_xcvr_up_es_3_ready;
  wire axi_mxfe_rx_xcvr_up_es_3_reset;
  wire [15:0]axi_mxfe_rx_xcvr_up_es_3_wdata;
  wire axi_mxfe_rx_xcvr_up_es_3_wr;
  wire axi_mxfe_rx_xcvr_up_pll_rst;
  wire axi_mxfe_tx_dma_irq;
  wire [31:0]axi_mxfe_tx_dma_m_src_axi_ARADDR;
  wire [1:0]axi_mxfe_tx_dma_m_src_axi_ARBURST;
  wire [3:0]axi_mxfe_tx_dma_m_src_axi_ARCACHE;
  wire [7:0]axi_mxfe_tx_dma_m_src_axi_ARLEN;
  wire [2:0]axi_mxfe_tx_dma_m_src_axi_ARPROT;
  wire axi_mxfe_tx_dma_m_src_axi_ARREADY;
  wire [2:0]axi_mxfe_tx_dma_m_src_axi_ARSIZE;
  wire axi_mxfe_tx_dma_m_src_axi_ARVALID;
  wire [511:0]axi_mxfe_tx_dma_m_src_axi_RDATA;
  wire axi_mxfe_tx_dma_m_src_axi_RLAST;
  wire axi_mxfe_tx_dma_m_src_axi_RREADY;
  wire [1:0]axi_mxfe_tx_dma_m_src_axi_RRESP;
  wire axi_mxfe_tx_dma_m_src_axi_RVALID;
  wire axi_mxfe_tx_jesd_irq;
  wire [7:0]axi_mxfe_tx_jesd_tx_phy0_txcharisk;
  wire [63:0]axi_mxfe_tx_jesd_tx_phy0_txdata;
  wire [1:0]axi_mxfe_tx_jesd_tx_phy0_txheader;
  wire [7:0]axi_mxfe_tx_jesd_tx_phy1_txcharisk;
  wire [63:0]axi_mxfe_tx_jesd_tx_phy1_txdata;
  wire [1:0]axi_mxfe_tx_jesd_tx_phy1_txheader;
  wire [7:0]axi_mxfe_tx_jesd_tx_phy2_txcharisk;
  wire [63:0]axi_mxfe_tx_jesd_tx_phy2_txdata;
  wire [1:0]axi_mxfe_tx_jesd_tx_phy2_txheader;
  wire [7:0]axi_mxfe_tx_jesd_tx_phy3_txcharisk;
  wire [63:0]axi_mxfe_tx_jesd_tx_phy3_txdata;
  wire [1:0]axi_mxfe_tx_jesd_tx_phy3_txheader;
  wire [11:0]axi_mxfe_tx_xcvr_up_ch_0_addr;
  wire [1:0]axi_mxfe_tx_xcvr_up_ch_0_bufstatus;
  wire axi_mxfe_tx_xcvr_up_ch_0_enb;
  wire axi_mxfe_tx_xcvr_up_ch_0_lpm_dfe_n;
  wire [2:0]axi_mxfe_tx_xcvr_up_ch_0_out_clk_sel;
  wire axi_mxfe_tx_xcvr_up_ch_0_pll_locked;
  wire axi_mxfe_tx_xcvr_up_ch_0_prbsforceerr;
  wire [3:0]axi_mxfe_tx_xcvr_up_ch_0_prbssel;
  wire [2:0]axi_mxfe_tx_xcvr_up_ch_0_rate;
  wire [15:0]axi_mxfe_tx_xcvr_up_ch_0_rdata;
  wire axi_mxfe_tx_xcvr_up_ch_0_ready;
  wire axi_mxfe_tx_xcvr_up_ch_0_rst;
  wire axi_mxfe_tx_xcvr_up_ch_0_rst_done;
  wire [1:0]axi_mxfe_tx_xcvr_up_ch_0_sys_clk_sel;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_0_tx_diffctrl;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_0_tx_postcursor;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_0_tx_precursor;
  wire axi_mxfe_tx_xcvr_up_ch_0_user_ready;
  wire [15:0]axi_mxfe_tx_xcvr_up_ch_0_wdata;
  wire axi_mxfe_tx_xcvr_up_ch_0_wr;
  wire [11:0]axi_mxfe_tx_xcvr_up_ch_1_addr;
  wire [1:0]axi_mxfe_tx_xcvr_up_ch_1_bufstatus;
  wire axi_mxfe_tx_xcvr_up_ch_1_enb;
  wire axi_mxfe_tx_xcvr_up_ch_1_lpm_dfe_n;
  wire [2:0]axi_mxfe_tx_xcvr_up_ch_1_out_clk_sel;
  wire axi_mxfe_tx_xcvr_up_ch_1_pll_locked;
  wire axi_mxfe_tx_xcvr_up_ch_1_prbsforceerr;
  wire [3:0]axi_mxfe_tx_xcvr_up_ch_1_prbssel;
  wire [2:0]axi_mxfe_tx_xcvr_up_ch_1_rate;
  wire [15:0]axi_mxfe_tx_xcvr_up_ch_1_rdata;
  wire axi_mxfe_tx_xcvr_up_ch_1_ready;
  wire axi_mxfe_tx_xcvr_up_ch_1_rst;
  wire axi_mxfe_tx_xcvr_up_ch_1_rst_done;
  wire [1:0]axi_mxfe_tx_xcvr_up_ch_1_sys_clk_sel;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_1_tx_diffctrl;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_1_tx_postcursor;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_1_tx_precursor;
  wire axi_mxfe_tx_xcvr_up_ch_1_user_ready;
  wire [15:0]axi_mxfe_tx_xcvr_up_ch_1_wdata;
  wire axi_mxfe_tx_xcvr_up_ch_1_wr;
  wire [11:0]axi_mxfe_tx_xcvr_up_ch_2_addr;
  wire [1:0]axi_mxfe_tx_xcvr_up_ch_2_bufstatus;
  wire axi_mxfe_tx_xcvr_up_ch_2_enb;
  wire axi_mxfe_tx_xcvr_up_ch_2_lpm_dfe_n;
  wire [2:0]axi_mxfe_tx_xcvr_up_ch_2_out_clk_sel;
  wire axi_mxfe_tx_xcvr_up_ch_2_pll_locked;
  wire axi_mxfe_tx_xcvr_up_ch_2_prbsforceerr;
  wire [3:0]axi_mxfe_tx_xcvr_up_ch_2_prbssel;
  wire [2:0]axi_mxfe_tx_xcvr_up_ch_2_rate;
  wire [15:0]axi_mxfe_tx_xcvr_up_ch_2_rdata;
  wire axi_mxfe_tx_xcvr_up_ch_2_ready;
  wire axi_mxfe_tx_xcvr_up_ch_2_rst;
  wire axi_mxfe_tx_xcvr_up_ch_2_rst_done;
  wire [1:0]axi_mxfe_tx_xcvr_up_ch_2_sys_clk_sel;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_2_tx_diffctrl;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_2_tx_postcursor;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_2_tx_precursor;
  wire axi_mxfe_tx_xcvr_up_ch_2_user_ready;
  wire [15:0]axi_mxfe_tx_xcvr_up_ch_2_wdata;
  wire axi_mxfe_tx_xcvr_up_ch_2_wr;
  wire [11:0]axi_mxfe_tx_xcvr_up_ch_3_addr;
  wire [1:0]axi_mxfe_tx_xcvr_up_ch_3_bufstatus;
  wire axi_mxfe_tx_xcvr_up_ch_3_enb;
  wire axi_mxfe_tx_xcvr_up_ch_3_lpm_dfe_n;
  wire [2:0]axi_mxfe_tx_xcvr_up_ch_3_out_clk_sel;
  wire axi_mxfe_tx_xcvr_up_ch_3_pll_locked;
  wire axi_mxfe_tx_xcvr_up_ch_3_prbsforceerr;
  wire [3:0]axi_mxfe_tx_xcvr_up_ch_3_prbssel;
  wire [2:0]axi_mxfe_tx_xcvr_up_ch_3_rate;
  wire [15:0]axi_mxfe_tx_xcvr_up_ch_3_rdata;
  wire axi_mxfe_tx_xcvr_up_ch_3_ready;
  wire axi_mxfe_tx_xcvr_up_ch_3_rst;
  wire axi_mxfe_tx_xcvr_up_ch_3_rst_done;
  wire [1:0]axi_mxfe_tx_xcvr_up_ch_3_sys_clk_sel;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_3_tx_diffctrl;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_3_tx_postcursor;
  wire [4:0]axi_mxfe_tx_xcvr_up_ch_3_tx_precursor;
  wire axi_mxfe_tx_xcvr_up_ch_3_user_ready;
  wire [15:0]axi_mxfe_tx_xcvr_up_ch_3_wdata;
  wire axi_mxfe_tx_xcvr_up_ch_3_wr;
  wire [11:0]axi_mxfe_tx_xcvr_up_cm_0_addr;
  wire axi_mxfe_tx_xcvr_up_cm_0_enb;
  wire [15:0]axi_mxfe_tx_xcvr_up_cm_0_rdata;
  wire axi_mxfe_tx_xcvr_up_cm_0_ready;
  wire [15:0]axi_mxfe_tx_xcvr_up_cm_0_wdata;
  wire axi_mxfe_tx_xcvr_up_cm_0_wr;
  wire axi_mxfe_tx_xcvr_up_pll_rst;
  wire [2:0]cpack_reset_sources_dout;
  wire cpack_rst_logic_Res;
  wire device_clk_vip_clk_out;
  wire ext_sync_in_1;
  wire init_req_1;
  wire init_req_2;
  wire [0:0]manual_sync_or_Res;
  wire [31:0]mng_axi_vip_M_AXI_ARADDR;
  wire [2:0]mng_axi_vip_M_AXI_ARPROT;
  wire mng_axi_vip_M_AXI_ARREADY;
  wire mng_axi_vip_M_AXI_ARVALID;
  wire [31:0]mng_axi_vip_M_AXI_AWADDR;
  wire [2:0]mng_axi_vip_M_AXI_AWPROT;
  wire mng_axi_vip_M_AXI_AWREADY;
  wire mng_axi_vip_M_AXI_AWVALID;
  wire mng_axi_vip_M_AXI_BREADY;
  wire [1:0]mng_axi_vip_M_AXI_BRESP;
  wire mng_axi_vip_M_AXI_BVALID;
  wire [31:0]mng_axi_vip_M_AXI_RDATA;
  wire mng_axi_vip_M_AXI_RREADY;
  wire [1:0]mng_axi_vip_M_AXI_RRESP;
  wire mng_axi_vip_M_AXI_RVALID;
  wire [31:0]mng_axi_vip_M_AXI_WDATA;
  wire mng_axi_vip_M_AXI_WREADY;
  wire [3:0]mng_axi_vip_M_AXI_WSTRB;
  wire mng_axi_vip_M_AXI_WVALID;
  wire [511:0]mxfe_rx_data_offload_m_axis_TDATA;
  wire [63:0]mxfe_rx_data_offload_m_axis_TKEEP;
  wire mxfe_rx_data_offload_m_axis_TLAST;
  wire mxfe_rx_data_offload_m_axis_TREADY;
  wire mxfe_rx_data_offload_m_axis_TVALID;
  wire mxfe_rx_data_offload_s_axis_tready;
  wire [511:0]mxfe_tx_data_offload_m_axis_TDATA;
  wire mxfe_tx_data_offload_m_axis_TREADY;
  wire mxfe_tx_data_offload_m_axis_TVALID;
  wire ref_clk_q0_1;
  wire ref_clk_vip_clk_out;
  wire rx_data_0_n_1;
  wire rx_data_0_p_1;
  wire rx_data_1_n_1;
  wire rx_data_1_p_1;
  wire rx_data_2_n_1;
  wire rx_data_2_p_1;
  wire rx_data_3_n_1;
  wire rx_data_3_p_1;
  wire rx_device_clk_1;
  wire [0:0]rx_device_clk_rstgen_peripheral_aresetn;
  wire [0:0]rx_device_clk_rstgen_peripheral_reset;
  wire [0:0]rx_do_rstout_logic_Res;
  wire [127:0]rx_mxfe_tpl_core_adc_data_0;
  wire [127:0]rx_mxfe_tpl_core_adc_data_1;
  wire [127:0]rx_mxfe_tpl_core_adc_data_2;
  wire [127:0]rx_mxfe_tpl_core_adc_data_3;
  wire [0:0]rx_mxfe_tpl_core_adc_enable_0;
  wire [0:0]rx_mxfe_tpl_core_adc_enable_1;
  wire [0:0]rx_mxfe_tpl_core_adc_enable_2;
  wire [0:0]rx_mxfe_tpl_core_adc_enable_3;
  wire rx_mxfe_tpl_core_adc_rst;
  wire rx_mxfe_tpl_core_adc_sync_manual_req_out;
  wire [0:0]rx_mxfe_tpl_core_adc_valid_0;
  wire [511:0]s_axis_1_TDATA;
  wire [63:0]s_axis_1_TKEEP;
  wire s_axis_1_TLAST;
  wire s_axis_1_TREADY;
  wire s_axis_1_TVALID;
  wire [15:0]sys_concat_intc_dout;
  wire sys_cpu_clk;
  wire [0:0]sys_cpu_reset;
  wire [0:0]sys_cpu_resetn;
  wire sys_dma_clk;
  wire [0:0]sys_dma_reset;
  wire [0:0]sys_dma_resetn;
  wire sys_mem_clk;
  wire [0:0]sys_mem_reset;
  wire [0:0]sys_mem_resetn;
  wire sys_rst_vip_rst_out;
  wire sysref_1;
  wire sysref_2;
  wire sysref_clk_vip_clk_out;
  wire tx_device_clk_1;
  wire [0:0]tx_device_clk_rstgen_peripheral_aresetn;
  wire [0:0]tx_device_clk_rstgen_peripheral_reset;
  wire [0:0]tx_mxfe_tpl_core_dac_enable_0;
  wire [0:0]tx_mxfe_tpl_core_dac_enable_1;
  wire [0:0]tx_mxfe_tpl_core_dac_enable_2;
  wire [0:0]tx_mxfe_tpl_core_dac_enable_3;
  wire tx_mxfe_tpl_core_dac_rst;
  wire tx_mxfe_tpl_core_dac_sync_manual_req_out;
  wire [0:0]tx_mxfe_tpl_core_dac_valid_0;
  wire [383:0]tx_mxfe_tpl_core_link_TDATA;
  wire tx_mxfe_tpl_core_link_TREADY;
  wire tx_mxfe_tpl_core_link_TVALID;
  wire [1:0]upack_reset_sources_dout;
  wire upack_rst_logic_Res;
  wire util_mxfe_cpack_fifo_wr_overflow;
  wire [511:0]util_mxfe_cpack_packed_fifo_wr_data;
  wire util_mxfe_cpack_packed_fifo_wr_en;
  wire [127:0]util_mxfe_upack_fifo_rd_data_0;
  wire [127:0]util_mxfe_upack_fifo_rd_data_1;
  wire [127:0]util_mxfe_upack_fifo_rd_data_2;
  wire [127:0]util_mxfe_upack_fifo_rd_data_3;
  wire util_mxfe_xcvr_rx_0_rxblock_sync;
  wire [7:0]util_mxfe_xcvr_rx_0_rxcharisk;
  wire [63:0]util_mxfe_xcvr_rx_0_rxdata;
  wire [7:0]util_mxfe_xcvr_rx_0_rxdisperr;
  wire [1:0]util_mxfe_xcvr_rx_0_rxheader;
  wire [7:0]util_mxfe_xcvr_rx_0_rxnotintable;
  wire util_mxfe_xcvr_rx_1_rxblock_sync;
  wire [7:0]util_mxfe_xcvr_rx_1_rxcharisk;
  wire [63:0]util_mxfe_xcvr_rx_1_rxdata;
  wire [7:0]util_mxfe_xcvr_rx_1_rxdisperr;
  wire [1:0]util_mxfe_xcvr_rx_1_rxheader;
  wire [7:0]util_mxfe_xcvr_rx_1_rxnotintable;
  wire util_mxfe_xcvr_rx_2_rxblock_sync;
  wire [7:0]util_mxfe_xcvr_rx_2_rxcharisk;
  wire [63:0]util_mxfe_xcvr_rx_2_rxdata;
  wire [7:0]util_mxfe_xcvr_rx_2_rxdisperr;
  wire [1:0]util_mxfe_xcvr_rx_2_rxheader;
  wire [7:0]util_mxfe_xcvr_rx_2_rxnotintable;
  wire util_mxfe_xcvr_rx_3_rxblock_sync;
  wire [7:0]util_mxfe_xcvr_rx_3_rxcharisk;
  wire [63:0]util_mxfe_xcvr_rx_3_rxdata;
  wire [7:0]util_mxfe_xcvr_rx_3_rxdisperr;
  wire [1:0]util_mxfe_xcvr_rx_3_rxheader;
  wire [7:0]util_mxfe_xcvr_rx_3_rxnotintable;
  wire util_mxfe_xcvr_rx_out_clk_0;
  wire util_mxfe_xcvr_tx_0_n;
  wire util_mxfe_xcvr_tx_0_p;
  wire util_mxfe_xcvr_tx_1_n;
  wire util_mxfe_xcvr_tx_1_p;
  wire util_mxfe_xcvr_tx_2_n;
  wire util_mxfe_xcvr_tx_2_p;
  wire util_mxfe_xcvr_tx_3_n;
  wire util_mxfe_xcvr_tx_3_p;
  wire util_mxfe_xcvr_tx_out_clk_0;

  assign device_clk_out = device_clk_vip_clk_out;
  assign ext_sync_in_1 = ext_sync_in;
  assign irq = axi_intc_irq;
  assign ref_clk_out = ref_clk_vip_clk_out;
  assign ref_clk_q0_1 = ref_clk_q0;
  assign rx_data_0_n_1 = rx_data_0_n;
  assign rx_data_0_p_1 = rx_data_0_p;
  assign rx_data_1_n_1 = rx_data_1_n;
  assign rx_data_1_p_1 = rx_data_1_p;
  assign rx_data_2_n_1 = rx_data_2_n;
  assign rx_data_2_p_1 = rx_data_2_p;
  assign rx_data_3_n_1 = rx_data_3_n;
  assign rx_data_3_p_1 = rx_data_3_p;
  assign rx_device_clk_1 = rx_device_clk;
  assign sysref_1 = rx_sysref_0;
  assign sysref_2 = tx_sysref_0;
  assign sysref_clk_out = sysref_clk_vip_clk_out;
  assign tx_data_0_n = util_mxfe_xcvr_tx_0_n;
  assign tx_data_0_p = util_mxfe_xcvr_tx_0_p;
  assign tx_data_1_n = util_mxfe_xcvr_tx_1_n;
  assign tx_data_1_p = util_mxfe_xcvr_tx_1_p;
  assign tx_data_2_n = util_mxfe_xcvr_tx_2_n;
  assign tx_data_2_p = util_mxfe_xcvr_tx_2_p;
  assign tx_data_3_n = util_mxfe_xcvr_tx_3_n;
  assign tx_data_3_p = util_mxfe_xcvr_tx_3_p;
  assign tx_device_clk_1 = tx_device_clk;
  test_harness_GND_1_0 GND_1
       (.dout(GND_1_dout));
  test_harness_VCC_1_0 VCC_1
       (.dout(VCC_1_dout));
  test_harness_axi_axi_interconnect_0 axi_axi_interconnect
       (.M00_AXI_araddr(axi_axi_interconnect_M00_AXI_ARADDR),
        .M00_AXI_arready(axi_axi_interconnect_M00_AXI_ARREADY),
        .M00_AXI_arvalid(axi_axi_interconnect_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_axi_interconnect_M00_AXI_AWADDR),
        .M00_AXI_awready(axi_axi_interconnect_M00_AXI_AWREADY),
        .M00_AXI_awvalid(axi_axi_interconnect_M00_AXI_AWVALID),
        .M00_AXI_bready(axi_axi_interconnect_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_axi_interconnect_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_axi_interconnect_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_axi_interconnect_M00_AXI_RDATA),
        .M00_AXI_rready(axi_axi_interconnect_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_axi_interconnect_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_axi_interconnect_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_axi_interconnect_M00_AXI_WDATA),
        .M00_AXI_wready(axi_axi_interconnect_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_axi_interconnect_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_axi_interconnect_M00_AXI_WVALID),
        .M01_AXI_araddr(axi_axi_interconnect_M01_AXI_ARADDR),
        .M01_AXI_arburst(axi_axi_interconnect_M01_AXI_ARBURST),
        .M01_AXI_arcache(axi_axi_interconnect_M01_AXI_ARCACHE),
        .M01_AXI_arid(axi_axi_interconnect_M01_AXI_ARID),
        .M01_AXI_arlen(axi_axi_interconnect_M01_AXI_ARLEN),
        .M01_AXI_arlock(axi_axi_interconnect_M01_AXI_ARLOCK),
        .M01_AXI_arprot(axi_axi_interconnect_M01_AXI_ARPROT),
        .M01_AXI_arqos(axi_axi_interconnect_M01_AXI_ARQOS),
        .M01_AXI_arready(axi_axi_interconnect_M01_AXI_ARREADY),
        .M01_AXI_arsize(axi_axi_interconnect_M01_AXI_ARSIZE),
        .M01_AXI_aruser(axi_axi_interconnect_M01_AXI_ARUSER),
        .M01_AXI_arvalid(axi_axi_interconnect_M01_AXI_ARVALID),
        .M01_AXI_awaddr(axi_axi_interconnect_M01_AXI_AWADDR),
        .M01_AXI_awburst(axi_axi_interconnect_M01_AXI_AWBURST),
        .M01_AXI_awcache(axi_axi_interconnect_M01_AXI_AWCACHE),
        .M01_AXI_awid(axi_axi_interconnect_M01_AXI_AWID),
        .M01_AXI_awlen(axi_axi_interconnect_M01_AXI_AWLEN),
        .M01_AXI_awlock(axi_axi_interconnect_M01_AXI_AWLOCK),
        .M01_AXI_awprot(axi_axi_interconnect_M01_AXI_AWPROT),
        .M01_AXI_awqos(axi_axi_interconnect_M01_AXI_AWQOS),
        .M01_AXI_awready(axi_axi_interconnect_M01_AXI_AWREADY),
        .M01_AXI_awsize(axi_axi_interconnect_M01_AXI_AWSIZE),
        .M01_AXI_awuser(axi_axi_interconnect_M01_AXI_AWUSER),
        .M01_AXI_awvalid(axi_axi_interconnect_M01_AXI_AWVALID),
        .M01_AXI_bid(axi_axi_interconnect_M01_AXI_BID),
        .M01_AXI_bready(axi_axi_interconnect_M01_AXI_BREADY),
        .M01_AXI_bresp(axi_axi_interconnect_M01_AXI_BRESP),
        .M01_AXI_buser(axi_axi_interconnect_M01_AXI_BUSER),
        .M01_AXI_bvalid(axi_axi_interconnect_M01_AXI_BVALID),
        .M01_AXI_rdata(axi_axi_interconnect_M01_AXI_RDATA),
        .M01_AXI_rid(axi_axi_interconnect_M01_AXI_RID),
        .M01_AXI_rlast(axi_axi_interconnect_M01_AXI_RLAST),
        .M01_AXI_rready(axi_axi_interconnect_M01_AXI_RREADY),
        .M01_AXI_rresp(axi_axi_interconnect_M01_AXI_RRESP),
        .M01_AXI_ruser(axi_axi_interconnect_M01_AXI_RUSER),
        .M01_AXI_rvalid(axi_axi_interconnect_M01_AXI_RVALID),
        .M01_AXI_wdata(axi_axi_interconnect_M01_AXI_WDATA),
        .M01_AXI_wlast(axi_axi_interconnect_M01_AXI_WLAST),
        .M01_AXI_wready(axi_axi_interconnect_M01_AXI_WREADY),
        .M01_AXI_wstrb(axi_axi_interconnect_M01_AXI_WSTRB),
        .M01_AXI_wuser(axi_axi_interconnect_M01_AXI_WUSER),
        .M01_AXI_wvalid(axi_axi_interconnect_M01_AXI_WVALID),
        .M02_AXI_araddr(axi_axi_interconnect_M02_AXI_ARADDR),
        .M02_AXI_arprot(axi_axi_interconnect_M02_AXI_ARPROT),
        .M02_AXI_arready(axi_axi_interconnect_M02_AXI_ARREADY),
        .M02_AXI_arvalid(axi_axi_interconnect_M02_AXI_ARVALID),
        .M02_AXI_awaddr(axi_axi_interconnect_M02_AXI_AWADDR),
        .M02_AXI_awprot(axi_axi_interconnect_M02_AXI_AWPROT),
        .M02_AXI_awready(axi_axi_interconnect_M02_AXI_AWREADY),
        .M02_AXI_awvalid(axi_axi_interconnect_M02_AXI_AWVALID),
        .M02_AXI_bready(axi_axi_interconnect_M02_AXI_BREADY),
        .M02_AXI_bresp(axi_axi_interconnect_M02_AXI_BRESP),
        .M02_AXI_bvalid(axi_axi_interconnect_M02_AXI_BVALID),
        .M02_AXI_rdata(axi_axi_interconnect_M02_AXI_RDATA),
        .M02_AXI_rready(axi_axi_interconnect_M02_AXI_RREADY),
        .M02_AXI_rresp(axi_axi_interconnect_M02_AXI_RRESP),
        .M02_AXI_rvalid(axi_axi_interconnect_M02_AXI_RVALID),
        .M02_AXI_wdata(axi_axi_interconnect_M02_AXI_WDATA),
        .M02_AXI_wready(axi_axi_interconnect_M02_AXI_WREADY),
        .M02_AXI_wstrb(axi_axi_interconnect_M02_AXI_WSTRB),
        .M02_AXI_wvalid(axi_axi_interconnect_M02_AXI_WVALID),
        .M03_AXI_araddr(axi_axi_interconnect_M03_AXI_ARADDR),
        .M03_AXI_arprot(axi_axi_interconnect_M03_AXI_ARPROT),
        .M03_AXI_arready(axi_axi_interconnect_M03_AXI_ARREADY),
        .M03_AXI_arvalid(axi_axi_interconnect_M03_AXI_ARVALID),
        .M03_AXI_awaddr(axi_axi_interconnect_M03_AXI_AWADDR),
        .M03_AXI_awprot(axi_axi_interconnect_M03_AXI_AWPROT),
        .M03_AXI_awready(axi_axi_interconnect_M03_AXI_AWREADY),
        .M03_AXI_awvalid(axi_axi_interconnect_M03_AXI_AWVALID),
        .M03_AXI_bready(axi_axi_interconnect_M03_AXI_BREADY),
        .M03_AXI_bresp(axi_axi_interconnect_M03_AXI_BRESP),
        .M03_AXI_bvalid(axi_axi_interconnect_M03_AXI_BVALID),
        .M03_AXI_rdata(axi_axi_interconnect_M03_AXI_RDATA),
        .M03_AXI_rready(axi_axi_interconnect_M03_AXI_RREADY),
        .M03_AXI_rresp(axi_axi_interconnect_M03_AXI_RRESP),
        .M03_AXI_rvalid(axi_axi_interconnect_M03_AXI_RVALID),
        .M03_AXI_wdata(axi_axi_interconnect_M03_AXI_WDATA),
        .M03_AXI_wready(axi_axi_interconnect_M03_AXI_WREADY),
        .M03_AXI_wstrb(axi_axi_interconnect_M03_AXI_WSTRB),
        .M03_AXI_wvalid(axi_axi_interconnect_M03_AXI_WVALID),
        .M04_AXI_araddr(axi_axi_interconnect_M04_AXI_ARADDR),
        .M04_AXI_arprot(axi_axi_interconnect_M04_AXI_ARPROT),
        .M04_AXI_arready(axi_axi_interconnect_M04_AXI_ARREADY),
        .M04_AXI_arvalid(axi_axi_interconnect_M04_AXI_ARVALID),
        .M04_AXI_awaddr(axi_axi_interconnect_M04_AXI_AWADDR),
        .M04_AXI_awprot(axi_axi_interconnect_M04_AXI_AWPROT),
        .M04_AXI_awready(axi_axi_interconnect_M04_AXI_AWREADY),
        .M04_AXI_awvalid(axi_axi_interconnect_M04_AXI_AWVALID),
        .M04_AXI_bready(axi_axi_interconnect_M04_AXI_BREADY),
        .M04_AXI_bresp(axi_axi_interconnect_M04_AXI_BRESP),
        .M04_AXI_bvalid(axi_axi_interconnect_M04_AXI_BVALID),
        .M04_AXI_rdata(axi_axi_interconnect_M04_AXI_RDATA),
        .M04_AXI_rready(axi_axi_interconnect_M04_AXI_RREADY),
        .M04_AXI_rresp(axi_axi_interconnect_M04_AXI_RRESP),
        .M04_AXI_rvalid(axi_axi_interconnect_M04_AXI_RVALID),
        .M04_AXI_wdata(axi_axi_interconnect_M04_AXI_WDATA),
        .M04_AXI_wready(axi_axi_interconnect_M04_AXI_WREADY),
        .M04_AXI_wstrb(axi_axi_interconnect_M04_AXI_WSTRB),
        .M04_AXI_wvalid(axi_axi_interconnect_M04_AXI_WVALID),
        .M05_AXI_araddr(axi_axi_interconnect_M05_AXI_ARADDR),
        .M05_AXI_arprot(axi_axi_interconnect_M05_AXI_ARPROT),
        .M05_AXI_arready(axi_axi_interconnect_M05_AXI_ARREADY),
        .M05_AXI_arvalid(axi_axi_interconnect_M05_AXI_ARVALID),
        .M05_AXI_awaddr(axi_axi_interconnect_M05_AXI_AWADDR),
        .M05_AXI_awprot(axi_axi_interconnect_M05_AXI_AWPROT),
        .M05_AXI_awready(axi_axi_interconnect_M05_AXI_AWREADY),
        .M05_AXI_awvalid(axi_axi_interconnect_M05_AXI_AWVALID),
        .M05_AXI_bready(axi_axi_interconnect_M05_AXI_BREADY),
        .M05_AXI_bresp(axi_axi_interconnect_M05_AXI_BRESP),
        .M05_AXI_bvalid(axi_axi_interconnect_M05_AXI_BVALID),
        .M05_AXI_rdata(axi_axi_interconnect_M05_AXI_RDATA),
        .M05_AXI_rready(axi_axi_interconnect_M05_AXI_RREADY),
        .M05_AXI_rresp(axi_axi_interconnect_M05_AXI_RRESP),
        .M05_AXI_rvalid(axi_axi_interconnect_M05_AXI_RVALID),
        .M05_AXI_wdata(axi_axi_interconnect_M05_AXI_WDATA),
        .M05_AXI_wready(axi_axi_interconnect_M05_AXI_WREADY),
        .M05_AXI_wstrb(axi_axi_interconnect_M05_AXI_WSTRB),
        .M05_AXI_wvalid(axi_axi_interconnect_M05_AXI_WVALID),
        .M06_AXI_araddr(axi_axi_interconnect_M06_AXI_ARADDR),
        .M06_AXI_arprot(axi_axi_interconnect_M06_AXI_ARPROT),
        .M06_AXI_arready(axi_axi_interconnect_M06_AXI_ARREADY),
        .M06_AXI_arvalid(axi_axi_interconnect_M06_AXI_ARVALID),
        .M06_AXI_awaddr(axi_axi_interconnect_M06_AXI_AWADDR),
        .M06_AXI_awprot(axi_axi_interconnect_M06_AXI_AWPROT),
        .M06_AXI_awready(axi_axi_interconnect_M06_AXI_AWREADY),
        .M06_AXI_awvalid(axi_axi_interconnect_M06_AXI_AWVALID),
        .M06_AXI_bready(axi_axi_interconnect_M06_AXI_BREADY),
        .M06_AXI_bresp(axi_axi_interconnect_M06_AXI_BRESP),
        .M06_AXI_bvalid(axi_axi_interconnect_M06_AXI_BVALID),
        .M06_AXI_rdata(axi_axi_interconnect_M06_AXI_RDATA),
        .M06_AXI_rready(axi_axi_interconnect_M06_AXI_RREADY),
        .M06_AXI_rresp(axi_axi_interconnect_M06_AXI_RRESP),
        .M06_AXI_rvalid(axi_axi_interconnect_M06_AXI_RVALID),
        .M06_AXI_wdata(axi_axi_interconnect_M06_AXI_WDATA),
        .M06_AXI_wready(axi_axi_interconnect_M06_AXI_WREADY),
        .M06_AXI_wstrb(axi_axi_interconnect_M06_AXI_WSTRB),
        .M06_AXI_wvalid(axi_axi_interconnect_M06_AXI_WVALID),
        .M07_AXI_araddr(axi_axi_interconnect_M07_AXI_ARADDR),
        .M07_AXI_arprot(axi_axi_interconnect_M07_AXI_ARPROT),
        .M07_AXI_arready(axi_axi_interconnect_M07_AXI_ARREADY),
        .M07_AXI_arvalid(axi_axi_interconnect_M07_AXI_ARVALID),
        .M07_AXI_awaddr(axi_axi_interconnect_M07_AXI_AWADDR),
        .M07_AXI_awprot(axi_axi_interconnect_M07_AXI_AWPROT),
        .M07_AXI_awready(axi_axi_interconnect_M07_AXI_AWREADY),
        .M07_AXI_awvalid(axi_axi_interconnect_M07_AXI_AWVALID),
        .M07_AXI_bready(axi_axi_interconnect_M07_AXI_BREADY),
        .M07_AXI_bresp(axi_axi_interconnect_M07_AXI_BRESP),
        .M07_AXI_bvalid(axi_axi_interconnect_M07_AXI_BVALID),
        .M07_AXI_rdata(axi_axi_interconnect_M07_AXI_RDATA),
        .M07_AXI_rready(axi_axi_interconnect_M07_AXI_RREADY),
        .M07_AXI_rresp(axi_axi_interconnect_M07_AXI_RRESP),
        .M07_AXI_rvalid(axi_axi_interconnect_M07_AXI_RVALID),
        .M07_AXI_wdata(axi_axi_interconnect_M07_AXI_WDATA),
        .M07_AXI_wready(axi_axi_interconnect_M07_AXI_WREADY),
        .M07_AXI_wstrb(axi_axi_interconnect_M07_AXI_WSTRB),
        .M07_AXI_wvalid(axi_axi_interconnect_M07_AXI_WVALID),
        .M08_AXI_araddr(axi_axi_interconnect_M08_AXI_ARADDR),
        .M08_AXI_arprot(axi_axi_interconnect_M08_AXI_ARPROT),
        .M08_AXI_arready(axi_axi_interconnect_M08_AXI_ARREADY),
        .M08_AXI_arvalid(axi_axi_interconnect_M08_AXI_ARVALID),
        .M08_AXI_awaddr(axi_axi_interconnect_M08_AXI_AWADDR),
        .M08_AXI_awprot(axi_axi_interconnect_M08_AXI_AWPROT),
        .M08_AXI_awready(axi_axi_interconnect_M08_AXI_AWREADY),
        .M08_AXI_awvalid(axi_axi_interconnect_M08_AXI_AWVALID),
        .M08_AXI_bready(axi_axi_interconnect_M08_AXI_BREADY),
        .M08_AXI_bresp(axi_axi_interconnect_M08_AXI_BRESP),
        .M08_AXI_bvalid(axi_axi_interconnect_M08_AXI_BVALID),
        .M08_AXI_rdata(axi_axi_interconnect_M08_AXI_RDATA),
        .M08_AXI_rready(axi_axi_interconnect_M08_AXI_RREADY),
        .M08_AXI_rresp(axi_axi_interconnect_M08_AXI_RRESP),
        .M08_AXI_rvalid(axi_axi_interconnect_M08_AXI_RVALID),
        .M08_AXI_wdata(axi_axi_interconnect_M08_AXI_WDATA),
        .M08_AXI_wready(axi_axi_interconnect_M08_AXI_WREADY),
        .M08_AXI_wstrb(axi_axi_interconnect_M08_AXI_WSTRB),
        .M08_AXI_wvalid(axi_axi_interconnect_M08_AXI_WVALID),
        .M09_AXI_araddr(axi_axi_interconnect_M09_AXI_ARADDR),
        .M09_AXI_arprot(axi_axi_interconnect_M09_AXI_ARPROT),
        .M09_AXI_arready(axi_axi_interconnect_M09_AXI_ARREADY),
        .M09_AXI_arvalid(axi_axi_interconnect_M09_AXI_ARVALID),
        .M09_AXI_awaddr(axi_axi_interconnect_M09_AXI_AWADDR),
        .M09_AXI_awprot(axi_axi_interconnect_M09_AXI_AWPROT),
        .M09_AXI_awready(axi_axi_interconnect_M09_AXI_AWREADY),
        .M09_AXI_awvalid(axi_axi_interconnect_M09_AXI_AWVALID),
        .M09_AXI_bready(axi_axi_interconnect_M09_AXI_BREADY),
        .M09_AXI_bresp(axi_axi_interconnect_M09_AXI_BRESP),
        .M09_AXI_bvalid(axi_axi_interconnect_M09_AXI_BVALID),
        .M09_AXI_rdata(axi_axi_interconnect_M09_AXI_RDATA),
        .M09_AXI_rready(axi_axi_interconnect_M09_AXI_RREADY),
        .M09_AXI_rresp(axi_axi_interconnect_M09_AXI_RRESP),
        .M09_AXI_rvalid(axi_axi_interconnect_M09_AXI_RVALID),
        .M09_AXI_wdata(axi_axi_interconnect_M09_AXI_WDATA),
        .M09_AXI_wready(axi_axi_interconnect_M09_AXI_WREADY),
        .M09_AXI_wstrb(axi_axi_interconnect_M09_AXI_WSTRB),
        .M09_AXI_wvalid(axi_axi_interconnect_M09_AXI_WVALID),
        .M10_AXI_araddr(axi_axi_interconnect_M10_AXI_ARADDR),
        .M10_AXI_arprot(axi_axi_interconnect_M10_AXI_ARPROT),
        .M10_AXI_arready(axi_axi_interconnect_M10_AXI_ARREADY),
        .M10_AXI_arvalid(axi_axi_interconnect_M10_AXI_ARVALID),
        .M10_AXI_awaddr(axi_axi_interconnect_M10_AXI_AWADDR),
        .M10_AXI_awprot(axi_axi_interconnect_M10_AXI_AWPROT),
        .M10_AXI_awready(axi_axi_interconnect_M10_AXI_AWREADY),
        .M10_AXI_awvalid(axi_axi_interconnect_M10_AXI_AWVALID),
        .M10_AXI_bready(axi_axi_interconnect_M10_AXI_BREADY),
        .M10_AXI_bresp(axi_axi_interconnect_M10_AXI_BRESP),
        .M10_AXI_bvalid(axi_axi_interconnect_M10_AXI_BVALID),
        .M10_AXI_rdata(axi_axi_interconnect_M10_AXI_RDATA),
        .M10_AXI_rready(axi_axi_interconnect_M10_AXI_RREADY),
        .M10_AXI_rresp(axi_axi_interconnect_M10_AXI_RRESP),
        .M10_AXI_rvalid(axi_axi_interconnect_M10_AXI_RVALID),
        .M10_AXI_wdata(axi_axi_interconnect_M10_AXI_WDATA),
        .M10_AXI_wready(axi_axi_interconnect_M10_AXI_WREADY),
        .M10_AXI_wstrb(axi_axi_interconnect_M10_AXI_WSTRB),
        .M10_AXI_wvalid(axi_axi_interconnect_M10_AXI_WVALID),
        .M11_AXI_araddr(axi_axi_interconnect_M11_AXI_ARADDR),
        .M11_AXI_arprot(axi_axi_interconnect_M11_AXI_ARPROT),
        .M11_AXI_arready(axi_axi_interconnect_M11_AXI_ARREADY),
        .M11_AXI_arvalid(axi_axi_interconnect_M11_AXI_ARVALID),
        .M11_AXI_awaddr(axi_axi_interconnect_M11_AXI_AWADDR),
        .M11_AXI_awprot(axi_axi_interconnect_M11_AXI_AWPROT),
        .M11_AXI_awready(axi_axi_interconnect_M11_AXI_AWREADY),
        .M11_AXI_awvalid(axi_axi_interconnect_M11_AXI_AWVALID),
        .M11_AXI_bready(axi_axi_interconnect_M11_AXI_BREADY),
        .M11_AXI_bresp(axi_axi_interconnect_M11_AXI_BRESP),
        .M11_AXI_bvalid(axi_axi_interconnect_M11_AXI_BVALID),
        .M11_AXI_rdata(axi_axi_interconnect_M11_AXI_RDATA),
        .M11_AXI_rready(axi_axi_interconnect_M11_AXI_RREADY),
        .M11_AXI_rresp(axi_axi_interconnect_M11_AXI_RRESP),
        .M11_AXI_rvalid(axi_axi_interconnect_M11_AXI_RVALID),
        .M11_AXI_wdata(axi_axi_interconnect_M11_AXI_WDATA),
        .M11_AXI_wready(axi_axi_interconnect_M11_AXI_WREADY),
        .M11_AXI_wstrb(axi_axi_interconnect_M11_AXI_WSTRB),
        .M11_AXI_wvalid(axi_axi_interconnect_M11_AXI_WVALID),
        .S00_AXI_araddr(mng_axi_vip_M_AXI_ARADDR),
        .S00_AXI_arprot(mng_axi_vip_M_AXI_ARPROT),
        .S00_AXI_arready(mng_axi_vip_M_AXI_ARREADY),
        .S00_AXI_arvalid(mng_axi_vip_M_AXI_ARVALID),
        .S00_AXI_awaddr(mng_axi_vip_M_AXI_AWADDR),
        .S00_AXI_awprot(mng_axi_vip_M_AXI_AWPROT),
        .S00_AXI_awready(mng_axi_vip_M_AXI_AWREADY),
        .S00_AXI_awvalid(mng_axi_vip_M_AXI_AWVALID),
        .S00_AXI_bready(mng_axi_vip_M_AXI_BREADY),
        .S00_AXI_bresp(mng_axi_vip_M_AXI_BRESP),
        .S00_AXI_bvalid(mng_axi_vip_M_AXI_BVALID),
        .S00_AXI_rdata(mng_axi_vip_M_AXI_RDATA),
        .S00_AXI_rready(mng_axi_vip_M_AXI_RREADY),
        .S00_AXI_rresp(mng_axi_vip_M_AXI_RRESP),
        .S00_AXI_rvalid(mng_axi_vip_M_AXI_RVALID),
        .S00_AXI_wdata(mng_axi_vip_M_AXI_WDATA),
        .S00_AXI_wready(mng_axi_vip_M_AXI_WREADY),
        .S00_AXI_wstrb(mng_axi_vip_M_AXI_WSTRB),
        .S00_AXI_wvalid(mng_axi_vip_M_AXI_WVALID),
        .aclk(sys_cpu_clk),
        .aresetn(sys_cpu_resetn));
  test_harness_axi_intc_0 axi_intc
       (.intr(sys_concat_intc_dout),
        .irq(axi_intc_irq),
        .s_axi_aclk(sys_cpu_clk),
        .s_axi_araddr(axi_axi_interconnect_M00_AXI_ARADDR),
        .s_axi_aresetn(sys_cpu_resetn),
        .s_axi_arready(axi_axi_interconnect_M00_AXI_ARREADY),
        .s_axi_arvalid(axi_axi_interconnect_M00_AXI_ARVALID),
        .s_axi_awaddr(axi_axi_interconnect_M00_AXI_AWADDR),
        .s_axi_awready(axi_axi_interconnect_M00_AXI_AWREADY),
        .s_axi_awvalid(axi_axi_interconnect_M00_AXI_AWVALID),
        .s_axi_bready(axi_axi_interconnect_M00_AXI_BREADY),
        .s_axi_bresp(axi_axi_interconnect_M00_AXI_BRESP),
        .s_axi_bvalid(axi_axi_interconnect_M00_AXI_BVALID),
        .s_axi_rdata(axi_axi_interconnect_M00_AXI_RDATA),
        .s_axi_rready(axi_axi_interconnect_M00_AXI_RREADY),
        .s_axi_rresp(axi_axi_interconnect_M00_AXI_RRESP),
        .s_axi_rvalid(axi_axi_interconnect_M00_AXI_RVALID),
        .s_axi_wdata(axi_axi_interconnect_M00_AXI_WDATA),
        .s_axi_wready(axi_axi_interconnect_M00_AXI_WREADY),
        .s_axi_wstrb(axi_axi_interconnect_M00_AXI_WSTRB),
        .s_axi_wvalid(axi_axi_interconnect_M00_AXI_WVALID));
  test_harness_axi_mem_interconnect_0 axi_mem_interconnect
       (.M00_AXI_araddr(axi_mem_interconnect_M00_AXI_ARADDR),
        .M00_AXI_arburst(axi_mem_interconnect_M00_AXI_ARBURST),
        .M00_AXI_arcache(axi_mem_interconnect_M00_AXI_ARCACHE),
        .M00_AXI_arlen(axi_mem_interconnect_M00_AXI_ARLEN),
        .M00_AXI_arlock(axi_mem_interconnect_M00_AXI_ARLOCK),
        .M00_AXI_arprot(axi_mem_interconnect_M00_AXI_ARPROT),
        .M00_AXI_arqos(axi_mem_interconnect_M00_AXI_ARQOS),
        .M00_AXI_arready(axi_mem_interconnect_M00_AXI_ARREADY),
        .M00_AXI_arvalid(axi_mem_interconnect_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_mem_interconnect_M00_AXI_AWADDR),
        .M00_AXI_awburst(axi_mem_interconnect_M00_AXI_AWBURST),
        .M00_AXI_awcache(axi_mem_interconnect_M00_AXI_AWCACHE),
        .M00_AXI_awlen(axi_mem_interconnect_M00_AXI_AWLEN),
        .M00_AXI_awlock(axi_mem_interconnect_M00_AXI_AWLOCK),
        .M00_AXI_awprot(axi_mem_interconnect_M00_AXI_AWPROT),
        .M00_AXI_awqos(axi_mem_interconnect_M00_AXI_AWQOS),
        .M00_AXI_awready(axi_mem_interconnect_M00_AXI_AWREADY),
        .M00_AXI_awvalid(axi_mem_interconnect_M00_AXI_AWVALID),
        .M00_AXI_bready(axi_mem_interconnect_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_mem_interconnect_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_mem_interconnect_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_mem_interconnect_M00_AXI_RDATA),
        .M00_AXI_rlast(axi_mem_interconnect_M00_AXI_RLAST),
        .M00_AXI_rready(axi_mem_interconnect_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_mem_interconnect_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_mem_interconnect_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_mem_interconnect_M00_AXI_WDATA),
        .M00_AXI_wlast(axi_mem_interconnect_M00_AXI_WLAST),
        .M00_AXI_wready(axi_mem_interconnect_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_mem_interconnect_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_mem_interconnect_M00_AXI_WVALID),
        .S00_AXI_araddr(axi_axi_interconnect_M01_AXI_ARADDR),
        .S00_AXI_arburst(axi_axi_interconnect_M01_AXI_ARBURST),
        .S00_AXI_arcache(axi_axi_interconnect_M01_AXI_ARCACHE),
        .S00_AXI_arid(axi_axi_interconnect_M01_AXI_ARID),
        .S00_AXI_arlen(axi_axi_interconnect_M01_AXI_ARLEN),
        .S00_AXI_arlock(axi_axi_interconnect_M01_AXI_ARLOCK),
        .S00_AXI_arprot(axi_axi_interconnect_M01_AXI_ARPROT),
        .S00_AXI_arqos(axi_axi_interconnect_M01_AXI_ARQOS),
        .S00_AXI_arready(axi_axi_interconnect_M01_AXI_ARREADY),
        .S00_AXI_arsize(axi_axi_interconnect_M01_AXI_ARSIZE),
        .S00_AXI_aruser(axi_axi_interconnect_M01_AXI_ARUSER),
        .S00_AXI_arvalid(axi_axi_interconnect_M01_AXI_ARVALID),
        .S00_AXI_awaddr(axi_axi_interconnect_M01_AXI_AWADDR),
        .S00_AXI_awburst(axi_axi_interconnect_M01_AXI_AWBURST),
        .S00_AXI_awcache(axi_axi_interconnect_M01_AXI_AWCACHE),
        .S00_AXI_awid(axi_axi_interconnect_M01_AXI_AWID),
        .S00_AXI_awlen(axi_axi_interconnect_M01_AXI_AWLEN),
        .S00_AXI_awlock(axi_axi_interconnect_M01_AXI_AWLOCK),
        .S00_AXI_awprot(axi_axi_interconnect_M01_AXI_AWPROT),
        .S00_AXI_awqos(axi_axi_interconnect_M01_AXI_AWQOS),
        .S00_AXI_awready(axi_axi_interconnect_M01_AXI_AWREADY),
        .S00_AXI_awsize(axi_axi_interconnect_M01_AXI_AWSIZE),
        .S00_AXI_awuser(axi_axi_interconnect_M01_AXI_AWUSER),
        .S00_AXI_awvalid(axi_axi_interconnect_M01_AXI_AWVALID),
        .S00_AXI_bid(axi_axi_interconnect_M01_AXI_BID),
        .S00_AXI_bready(axi_axi_interconnect_M01_AXI_BREADY),
        .S00_AXI_bresp(axi_axi_interconnect_M01_AXI_BRESP),
        .S00_AXI_buser(axi_axi_interconnect_M01_AXI_BUSER),
        .S00_AXI_bvalid(axi_axi_interconnect_M01_AXI_BVALID),
        .S00_AXI_rdata(axi_axi_interconnect_M01_AXI_RDATA),
        .S00_AXI_rid(axi_axi_interconnect_M01_AXI_RID),
        .S00_AXI_rlast(axi_axi_interconnect_M01_AXI_RLAST),
        .S00_AXI_rready(axi_axi_interconnect_M01_AXI_RREADY),
        .S00_AXI_rresp(axi_axi_interconnect_M01_AXI_RRESP),
        .S00_AXI_ruser(axi_axi_interconnect_M01_AXI_RUSER),
        .S00_AXI_rvalid(axi_axi_interconnect_M01_AXI_RVALID),
        .S00_AXI_wdata(axi_axi_interconnect_M01_AXI_WDATA),
        .S00_AXI_wlast(axi_axi_interconnect_M01_AXI_WLAST),
        .S00_AXI_wready(axi_axi_interconnect_M01_AXI_WREADY),
        .S00_AXI_wstrb(axi_axi_interconnect_M01_AXI_WSTRB),
        .S00_AXI_wuser(axi_axi_interconnect_M01_AXI_WUSER),
        .S00_AXI_wvalid(axi_axi_interconnect_M01_AXI_WVALID),
        .S01_AXI_araddr(axi_mxfe_rx_xcvr_m_axi_ARADDR),
        .S01_AXI_arprot(axi_mxfe_rx_xcvr_m_axi_ARPROT),
        .S01_AXI_arready(axi_mxfe_rx_xcvr_m_axi_ARREADY),
        .S01_AXI_arvalid(axi_mxfe_rx_xcvr_m_axi_ARVALID),
        .S01_AXI_awaddr(axi_mxfe_rx_xcvr_m_axi_AWADDR),
        .S01_AXI_awprot(axi_mxfe_rx_xcvr_m_axi_AWPROT),
        .S01_AXI_awready(axi_mxfe_rx_xcvr_m_axi_AWREADY),
        .S01_AXI_awvalid(axi_mxfe_rx_xcvr_m_axi_AWVALID),
        .S01_AXI_bready(axi_mxfe_rx_xcvr_m_axi_BREADY),
        .S01_AXI_bresp(axi_mxfe_rx_xcvr_m_axi_BRESP),
        .S01_AXI_bvalid(axi_mxfe_rx_xcvr_m_axi_BVALID),
        .S01_AXI_rdata(axi_mxfe_rx_xcvr_m_axi_RDATA),
        .S01_AXI_rready(axi_mxfe_rx_xcvr_m_axi_RREADY),
        .S01_AXI_rresp(axi_mxfe_rx_xcvr_m_axi_RRESP),
        .S01_AXI_rvalid(axi_mxfe_rx_xcvr_m_axi_RVALID),
        .S01_AXI_wdata(axi_mxfe_rx_xcvr_m_axi_WDATA),
        .S01_AXI_wready(axi_mxfe_rx_xcvr_m_axi_WREADY),
        .S01_AXI_wstrb(axi_mxfe_rx_xcvr_m_axi_WSTRB),
        .S01_AXI_wvalid(axi_mxfe_rx_xcvr_m_axi_WVALID),
        .S02_AXI_awaddr(axi_mxfe_rx_dma_m_dest_axi_AWADDR),
        .S02_AXI_awburst(axi_mxfe_rx_dma_m_dest_axi_AWBURST),
        .S02_AXI_awcache(axi_mxfe_rx_dma_m_dest_axi_AWCACHE),
        .S02_AXI_awlen(axi_mxfe_rx_dma_m_dest_axi_AWLEN),
        .S02_AXI_awlock(1'b0),
        .S02_AXI_awprot(axi_mxfe_rx_dma_m_dest_axi_AWPROT),
        .S02_AXI_awqos({1'b0,1'b0,1'b0,1'b0}),
        .S02_AXI_awready(axi_mxfe_rx_dma_m_dest_axi_AWREADY),
        .S02_AXI_awsize(axi_mxfe_rx_dma_m_dest_axi_AWSIZE),
        .S02_AXI_awvalid(axi_mxfe_rx_dma_m_dest_axi_AWVALID),
        .S02_AXI_bready(axi_mxfe_rx_dma_m_dest_axi_BREADY),
        .S02_AXI_bresp(axi_mxfe_rx_dma_m_dest_axi_BRESP),
        .S02_AXI_bvalid(axi_mxfe_rx_dma_m_dest_axi_BVALID),
        .S02_AXI_wdata(axi_mxfe_rx_dma_m_dest_axi_WDATA),
        .S02_AXI_wlast(axi_mxfe_rx_dma_m_dest_axi_WLAST),
        .S02_AXI_wready(axi_mxfe_rx_dma_m_dest_axi_WREADY),
        .S02_AXI_wstrb(axi_mxfe_rx_dma_m_dest_axi_WSTRB),
        .S02_AXI_wvalid(axi_mxfe_rx_dma_m_dest_axi_WVALID),
        .S03_AXI_araddr(axi_mxfe_tx_dma_m_src_axi_ARADDR),
        .S03_AXI_arburst(axi_mxfe_tx_dma_m_src_axi_ARBURST),
        .S03_AXI_arcache(axi_mxfe_tx_dma_m_src_axi_ARCACHE),
        .S03_AXI_arlen(axi_mxfe_tx_dma_m_src_axi_ARLEN),
        .S03_AXI_arlock(1'b0),
        .S03_AXI_arprot(axi_mxfe_tx_dma_m_src_axi_ARPROT),
        .S03_AXI_arqos({1'b0,1'b0,1'b0,1'b0}),
        .S03_AXI_arready(axi_mxfe_tx_dma_m_src_axi_ARREADY),
        .S03_AXI_arsize(axi_mxfe_tx_dma_m_src_axi_ARSIZE),
        .S03_AXI_arvalid(axi_mxfe_tx_dma_m_src_axi_ARVALID),
        .S03_AXI_rdata(axi_mxfe_tx_dma_m_src_axi_RDATA),
        .S03_AXI_rlast(axi_mxfe_tx_dma_m_src_axi_RLAST),
        .S03_AXI_rready(axi_mxfe_tx_dma_m_src_axi_RREADY),
        .S03_AXI_rresp(axi_mxfe_tx_dma_m_src_axi_RRESP),
        .S03_AXI_rvalid(axi_mxfe_tx_dma_m_src_axi_RVALID),
        .aclk(sys_mem_clk),
        .aclk1(sys_cpu_clk),
        .aclk2(sys_dma_clk),
        .aresetn(sys_mem_resetn));
  test_harness_axi_mxfe_rx_dma_0 axi_mxfe_rx_dma
       (.irq(axi_mxfe_rx_dma_irq),
        .m_dest_axi_aclk(sys_dma_clk),
        .m_dest_axi_aresetn(sys_dma_resetn),
        .m_dest_axi_awaddr(axi_mxfe_rx_dma_m_dest_axi_AWADDR),
        .m_dest_axi_awburst(axi_mxfe_rx_dma_m_dest_axi_AWBURST),
        .m_dest_axi_awcache(axi_mxfe_rx_dma_m_dest_axi_AWCACHE),
        .m_dest_axi_awlen(axi_mxfe_rx_dma_m_dest_axi_AWLEN),
        .m_dest_axi_awprot(axi_mxfe_rx_dma_m_dest_axi_AWPROT),
        .m_dest_axi_awready(axi_mxfe_rx_dma_m_dest_axi_AWREADY),
        .m_dest_axi_awsize(axi_mxfe_rx_dma_m_dest_axi_AWSIZE),
        .m_dest_axi_awvalid(axi_mxfe_rx_dma_m_dest_axi_AWVALID),
        .m_dest_axi_bready(axi_mxfe_rx_dma_m_dest_axi_BREADY),
        .m_dest_axi_bresp(axi_mxfe_rx_dma_m_dest_axi_BRESP),
        .m_dest_axi_bvalid(axi_mxfe_rx_dma_m_dest_axi_BVALID),
        .m_dest_axi_wdata(axi_mxfe_rx_dma_m_dest_axi_WDATA),
        .m_dest_axi_wlast(axi_mxfe_rx_dma_m_dest_axi_WLAST),
        .m_dest_axi_wready(axi_mxfe_rx_dma_m_dest_axi_WREADY),
        .m_dest_axi_wstrb(axi_mxfe_rx_dma_m_dest_axi_WSTRB),
        .m_dest_axi_wvalid(axi_mxfe_rx_dma_m_dest_axi_WVALID),
        .s_axi_aclk(sys_cpu_clk),
        .s_axi_araddr(axi_axi_interconnect_M05_AXI_ARADDR),
        .s_axi_aresetn(sys_cpu_resetn),
        .s_axi_arprot(axi_axi_interconnect_M05_AXI_ARPROT),
        .s_axi_arready(axi_axi_interconnect_M05_AXI_ARREADY),
        .s_axi_arvalid(axi_axi_interconnect_M05_AXI_ARVALID),
        .s_axi_awaddr(axi_axi_interconnect_M05_AXI_AWADDR),
        .s_axi_awprot(axi_axi_interconnect_M05_AXI_AWPROT),
        .s_axi_awready(axi_axi_interconnect_M05_AXI_AWREADY),
        .s_axi_awvalid(axi_axi_interconnect_M05_AXI_AWVALID),
        .s_axi_bready(axi_axi_interconnect_M05_AXI_BREADY),
        .s_axi_bresp(axi_axi_interconnect_M05_AXI_BRESP),
        .s_axi_bvalid(axi_axi_interconnect_M05_AXI_BVALID),
        .s_axi_rdata(axi_axi_interconnect_M05_AXI_RDATA),
        .s_axi_rready(axi_axi_interconnect_M05_AXI_RREADY),
        .s_axi_rresp(axi_axi_interconnect_M05_AXI_RRESP),
        .s_axi_rvalid(axi_axi_interconnect_M05_AXI_RVALID),
        .s_axi_wdata(axi_axi_interconnect_M05_AXI_WDATA),
        .s_axi_wready(axi_axi_interconnect_M05_AXI_WREADY),
        .s_axi_wstrb(axi_axi_interconnect_M05_AXI_WSTRB),
        .s_axi_wvalid(axi_axi_interconnect_M05_AXI_WVALID),
        .s_axis_aclk(sys_dma_clk),
        .s_axis_data(mxfe_rx_data_offload_m_axis_TDATA),
        .s_axis_dest({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_id({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_keep(mxfe_rx_data_offload_m_axis_TKEEP),
        .s_axis_last(mxfe_rx_data_offload_m_axis_TLAST),
        .s_axis_ready(mxfe_rx_data_offload_m_axis_TREADY),
        .s_axis_strb({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .s_axis_user(1'b0),
        .s_axis_valid(mxfe_rx_data_offload_m_axis_TVALID),
        .s_axis_xfer_req(init_req_1));
  axi_mxfe_rx_jesd_imp_595QX2 axi_mxfe_rx_jesd
       (.device_clk(rx_device_clk_1),
        .irq(axi_mxfe_rx_jesd_irq),
        .link_clk(util_mxfe_xcvr_rx_out_clk_0),
        .rx_data_tdata(axi_mxfe_rx_jesd_rx_data_tdata),
        .rx_data_tvalid(axi_mxfe_rx_jesd_rx_data_tvalid),
        .rx_phy0_rxblock_sync(util_mxfe_xcvr_rx_0_rxblock_sync),
        .rx_phy0_rxcharisk(util_mxfe_xcvr_rx_0_rxcharisk),
        .rx_phy0_rxdata(util_mxfe_xcvr_rx_0_rxdata),
        .rx_phy0_rxdisperr(util_mxfe_xcvr_rx_0_rxdisperr),
        .rx_phy0_rxheader(util_mxfe_xcvr_rx_0_rxheader),
        .rx_phy0_rxnotintable(util_mxfe_xcvr_rx_0_rxnotintable),
        .rx_phy1_rxblock_sync(util_mxfe_xcvr_rx_1_rxblock_sync),
        .rx_phy1_rxcharisk(util_mxfe_xcvr_rx_1_rxcharisk),
        .rx_phy1_rxdata(util_mxfe_xcvr_rx_1_rxdata),
        .rx_phy1_rxdisperr(util_mxfe_xcvr_rx_1_rxdisperr),
        .rx_phy1_rxheader(util_mxfe_xcvr_rx_1_rxheader),
        .rx_phy1_rxnotintable(util_mxfe_xcvr_rx_1_rxnotintable),
        .rx_phy2_rxblock_sync(util_mxfe_xcvr_rx_2_rxblock_sync),
        .rx_phy2_rxcharisk(util_mxfe_xcvr_rx_2_rxcharisk),
        .rx_phy2_rxdata(util_mxfe_xcvr_rx_2_rxdata),
        .rx_phy2_rxdisperr(util_mxfe_xcvr_rx_2_rxdisperr),
        .rx_phy2_rxheader(util_mxfe_xcvr_rx_2_rxheader),
        .rx_phy2_rxnotintable(util_mxfe_xcvr_rx_2_rxnotintable),
        .rx_phy3_rxblock_sync(util_mxfe_xcvr_rx_3_rxblock_sync),
        .rx_phy3_rxcharisk(util_mxfe_xcvr_rx_3_rxcharisk),
        .rx_phy3_rxdata(util_mxfe_xcvr_rx_3_rxdata),
        .rx_phy3_rxdisperr(util_mxfe_xcvr_rx_3_rxdisperr),
        .rx_phy3_rxheader(util_mxfe_xcvr_rx_3_rxheader),
        .rx_phy3_rxnotintable(util_mxfe_xcvr_rx_3_rxnotintable),
        .rx_sof(axi_mxfe_rx_jesd_rx_sof),
        .s_axi_aclk(sys_cpu_clk),
        .s_axi_araddr(axi_axi_interconnect_M04_AXI_ARADDR),
        .s_axi_aresetn(sys_cpu_resetn),
        .s_axi_arprot(axi_axi_interconnect_M04_AXI_ARPROT),
        .s_axi_arready(axi_axi_interconnect_M04_AXI_ARREADY),
        .s_axi_arvalid(axi_axi_interconnect_M04_AXI_ARVALID),
        .s_axi_awaddr(axi_axi_interconnect_M04_AXI_AWADDR),
        .s_axi_awprot(axi_axi_interconnect_M04_AXI_AWPROT),
        .s_axi_awready(axi_axi_interconnect_M04_AXI_AWREADY),
        .s_axi_awvalid(axi_axi_interconnect_M04_AXI_AWVALID),
        .s_axi_bready(axi_axi_interconnect_M04_AXI_BREADY),
        .s_axi_bresp(axi_axi_interconnect_M04_AXI_BRESP),
        .s_axi_bvalid(axi_axi_interconnect_M04_AXI_BVALID),
        .s_axi_rdata(axi_axi_interconnect_M04_AXI_RDATA),
        .s_axi_rready(axi_axi_interconnect_M04_AXI_RREADY),
        .s_axi_rresp(axi_axi_interconnect_M04_AXI_RRESP),
        .s_axi_rvalid(axi_axi_interconnect_M04_AXI_RVALID),
        .s_axi_wdata(axi_axi_interconnect_M04_AXI_WDATA),
        .s_axi_wready(axi_axi_interconnect_M04_AXI_WREADY),
        .s_axi_wstrb(axi_axi_interconnect_M04_AXI_WSTRB),
        .s_axi_wvalid(axi_axi_interconnect_M04_AXI_WVALID),
        .sysref(sysref_1));
  test_harness_axi_mxfe_rx_xcvr_0 axi_mxfe_rx_xcvr
       (.m_axi_araddr(axi_mxfe_rx_xcvr_m_axi_ARADDR),
        .m_axi_arprot(axi_mxfe_rx_xcvr_m_axi_ARPROT),
        .m_axi_arready(axi_mxfe_rx_xcvr_m_axi_ARREADY),
        .m_axi_arvalid(axi_mxfe_rx_xcvr_m_axi_ARVALID),
        .m_axi_awaddr(axi_mxfe_rx_xcvr_m_axi_AWADDR),
        .m_axi_awprot(axi_mxfe_rx_xcvr_m_axi_AWPROT),
        .m_axi_awready(axi_mxfe_rx_xcvr_m_axi_AWREADY),
        .m_axi_awvalid(axi_mxfe_rx_xcvr_m_axi_AWVALID),
        .m_axi_bready(axi_mxfe_rx_xcvr_m_axi_BREADY),
        .m_axi_bresp(axi_mxfe_rx_xcvr_m_axi_BRESP),
        .m_axi_bvalid(axi_mxfe_rx_xcvr_m_axi_BVALID),
        .m_axi_rdata(axi_mxfe_rx_xcvr_m_axi_RDATA),
        .m_axi_rready(axi_mxfe_rx_xcvr_m_axi_RREADY),
        .m_axi_rresp(axi_mxfe_rx_xcvr_m_axi_RRESP),
        .m_axi_rvalid(axi_mxfe_rx_xcvr_m_axi_RVALID),
        .m_axi_wdata(axi_mxfe_rx_xcvr_m_axi_WDATA),
        .m_axi_wready(axi_mxfe_rx_xcvr_m_axi_WREADY),
        .m_axi_wstrb(axi_mxfe_rx_xcvr_m_axi_WSTRB),
        .m_axi_wvalid(axi_mxfe_rx_xcvr_m_axi_WVALID),
        .s_axi_aclk(sys_cpu_clk),
        .s_axi_araddr(axi_axi_interconnect_M02_AXI_ARADDR),
        .s_axi_aresetn(sys_cpu_resetn),
        .s_axi_arprot(axi_axi_interconnect_M02_AXI_ARPROT),
        .s_axi_arready(axi_axi_interconnect_M02_AXI_ARREADY),
        .s_axi_arvalid(axi_axi_interconnect_M02_AXI_ARVALID),
        .s_axi_awaddr(axi_axi_interconnect_M02_AXI_AWADDR),
        .s_axi_awprot(axi_axi_interconnect_M02_AXI_AWPROT),
        .s_axi_awready(axi_axi_interconnect_M02_AXI_AWREADY),
        .s_axi_awvalid(axi_axi_interconnect_M02_AXI_AWVALID),
        .s_axi_bready(axi_axi_interconnect_M02_AXI_BREADY),
        .s_axi_bresp(axi_axi_interconnect_M02_AXI_BRESP),
        .s_axi_bvalid(axi_axi_interconnect_M02_AXI_BVALID),
        .s_axi_rdata(axi_axi_interconnect_M02_AXI_RDATA),
        .s_axi_rready(axi_axi_interconnect_M02_AXI_RREADY),
        .s_axi_rresp(axi_axi_interconnect_M02_AXI_RRESP),
        .s_axi_rvalid(axi_axi_interconnect_M02_AXI_RVALID),
        .s_axi_wdata(axi_axi_interconnect_M02_AXI_WDATA),
        .s_axi_wready(axi_axi_interconnect_M02_AXI_WREADY),
        .s_axi_wstrb(axi_axi_interconnect_M02_AXI_WSTRB),
        .s_axi_wvalid(axi_axi_interconnect_M02_AXI_WVALID),
        .up_ch_addr_0(axi_mxfe_rx_xcvr_up_ch_0_addr),
        .up_ch_addr_1(axi_mxfe_rx_xcvr_up_ch_1_addr),
        .up_ch_addr_2(axi_mxfe_rx_xcvr_up_ch_2_addr),
        .up_ch_addr_3(axi_mxfe_rx_xcvr_up_ch_3_addr),
        .up_ch_bufstatus_0(axi_mxfe_rx_xcvr_up_ch_0_bufstatus),
        .up_ch_bufstatus_1(axi_mxfe_rx_xcvr_up_ch_1_bufstatus),
        .up_ch_bufstatus_2(axi_mxfe_rx_xcvr_up_ch_2_bufstatus),
        .up_ch_bufstatus_3(axi_mxfe_rx_xcvr_up_ch_3_bufstatus),
        .up_ch_bufstatus_rst_0(axi_mxfe_rx_xcvr_up_ch_0_bufstatus_rst),
        .up_ch_bufstatus_rst_1(axi_mxfe_rx_xcvr_up_ch_1_bufstatus_rst),
        .up_ch_bufstatus_rst_2(axi_mxfe_rx_xcvr_up_ch_2_bufstatus_rst),
        .up_ch_bufstatus_rst_3(axi_mxfe_rx_xcvr_up_ch_3_bufstatus_rst),
        .up_ch_enb_0(axi_mxfe_rx_xcvr_up_ch_0_enb),
        .up_ch_enb_1(axi_mxfe_rx_xcvr_up_ch_1_enb),
        .up_ch_enb_2(axi_mxfe_rx_xcvr_up_ch_2_enb),
        .up_ch_enb_3(axi_mxfe_rx_xcvr_up_ch_3_enb),
        .up_ch_lpm_dfe_n_0(axi_mxfe_rx_xcvr_up_ch_0_lpm_dfe_n),
        .up_ch_lpm_dfe_n_1(axi_mxfe_rx_xcvr_up_ch_1_lpm_dfe_n),
        .up_ch_lpm_dfe_n_2(axi_mxfe_rx_xcvr_up_ch_2_lpm_dfe_n),
        .up_ch_lpm_dfe_n_3(axi_mxfe_rx_xcvr_up_ch_3_lpm_dfe_n),
        .up_ch_out_clk_sel_0(axi_mxfe_rx_xcvr_up_ch_0_out_clk_sel),
        .up_ch_out_clk_sel_1(axi_mxfe_rx_xcvr_up_ch_1_out_clk_sel),
        .up_ch_out_clk_sel_2(axi_mxfe_rx_xcvr_up_ch_2_out_clk_sel),
        .up_ch_out_clk_sel_3(axi_mxfe_rx_xcvr_up_ch_3_out_clk_sel),
        .up_ch_pll_locked_0(axi_mxfe_rx_xcvr_up_ch_0_pll_locked),
        .up_ch_pll_locked_1(axi_mxfe_rx_xcvr_up_ch_1_pll_locked),
        .up_ch_pll_locked_2(axi_mxfe_rx_xcvr_up_ch_2_pll_locked),
        .up_ch_pll_locked_3(axi_mxfe_rx_xcvr_up_ch_3_pll_locked),
        .up_ch_prbscntreset_0(axi_mxfe_rx_xcvr_up_ch_0_prbscntreset),
        .up_ch_prbscntreset_1(axi_mxfe_rx_xcvr_up_ch_1_prbscntreset),
        .up_ch_prbscntreset_2(axi_mxfe_rx_xcvr_up_ch_2_prbscntreset),
        .up_ch_prbscntreset_3(axi_mxfe_rx_xcvr_up_ch_3_prbscntreset),
        .up_ch_prbserr_0(axi_mxfe_rx_xcvr_up_ch_0_prbserr),
        .up_ch_prbserr_1(axi_mxfe_rx_xcvr_up_ch_1_prbserr),
        .up_ch_prbserr_2(axi_mxfe_rx_xcvr_up_ch_2_prbserr),
        .up_ch_prbserr_3(axi_mxfe_rx_xcvr_up_ch_3_prbserr),
        .up_ch_prbslocked_0(axi_mxfe_rx_xcvr_up_ch_0_prbslocked),
        .up_ch_prbslocked_1(axi_mxfe_rx_xcvr_up_ch_1_prbslocked),
        .up_ch_prbslocked_2(axi_mxfe_rx_xcvr_up_ch_2_prbslocked),
        .up_ch_prbslocked_3(axi_mxfe_rx_xcvr_up_ch_3_prbslocked),
        .up_ch_prbssel_0(axi_mxfe_rx_xcvr_up_ch_0_prbssel),
        .up_ch_prbssel_1(axi_mxfe_rx_xcvr_up_ch_1_prbssel),
        .up_ch_prbssel_2(axi_mxfe_rx_xcvr_up_ch_2_prbssel),
        .up_ch_prbssel_3(axi_mxfe_rx_xcvr_up_ch_3_prbssel),
        .up_ch_rate_0(axi_mxfe_rx_xcvr_up_ch_0_rate),
        .up_ch_rate_1(axi_mxfe_rx_xcvr_up_ch_1_rate),
        .up_ch_rate_2(axi_mxfe_rx_xcvr_up_ch_2_rate),
        .up_ch_rate_3(axi_mxfe_rx_xcvr_up_ch_3_rate),
        .up_ch_rdata_0(axi_mxfe_rx_xcvr_up_ch_0_rdata),
        .up_ch_rdata_1(axi_mxfe_rx_xcvr_up_ch_1_rdata),
        .up_ch_rdata_2(axi_mxfe_rx_xcvr_up_ch_2_rdata),
        .up_ch_rdata_3(axi_mxfe_rx_xcvr_up_ch_3_rdata),
        .up_ch_ready_0(axi_mxfe_rx_xcvr_up_ch_0_ready),
        .up_ch_ready_1(axi_mxfe_rx_xcvr_up_ch_1_ready),
        .up_ch_ready_2(axi_mxfe_rx_xcvr_up_ch_2_ready),
        .up_ch_ready_3(axi_mxfe_rx_xcvr_up_ch_3_ready),
        .up_ch_rst_0(axi_mxfe_rx_xcvr_up_ch_0_rst),
        .up_ch_rst_1(axi_mxfe_rx_xcvr_up_ch_1_rst),
        .up_ch_rst_2(axi_mxfe_rx_xcvr_up_ch_2_rst),
        .up_ch_rst_3(axi_mxfe_rx_xcvr_up_ch_3_rst),
        .up_ch_rst_done_0(axi_mxfe_rx_xcvr_up_ch_0_rst_done),
        .up_ch_rst_done_1(axi_mxfe_rx_xcvr_up_ch_1_rst_done),
        .up_ch_rst_done_2(axi_mxfe_rx_xcvr_up_ch_2_rst_done),
        .up_ch_rst_done_3(axi_mxfe_rx_xcvr_up_ch_3_rst_done),
        .up_ch_sys_clk_sel_0(axi_mxfe_rx_xcvr_up_ch_0_sys_clk_sel),
        .up_ch_sys_clk_sel_1(axi_mxfe_rx_xcvr_up_ch_1_sys_clk_sel),
        .up_ch_sys_clk_sel_2(axi_mxfe_rx_xcvr_up_ch_2_sys_clk_sel),
        .up_ch_sys_clk_sel_3(axi_mxfe_rx_xcvr_up_ch_3_sys_clk_sel),
        .up_ch_user_ready_0(axi_mxfe_rx_xcvr_up_ch_0_user_ready),
        .up_ch_user_ready_1(axi_mxfe_rx_xcvr_up_ch_1_user_ready),
        .up_ch_user_ready_2(axi_mxfe_rx_xcvr_up_ch_2_user_ready),
        .up_ch_user_ready_3(axi_mxfe_rx_xcvr_up_ch_3_user_ready),
        .up_ch_wdata_0(axi_mxfe_rx_xcvr_up_ch_0_wdata),
        .up_ch_wdata_1(axi_mxfe_rx_xcvr_up_ch_1_wdata),
        .up_ch_wdata_2(axi_mxfe_rx_xcvr_up_ch_2_wdata),
        .up_ch_wdata_3(axi_mxfe_rx_xcvr_up_ch_3_wdata),
        .up_ch_wr_0(axi_mxfe_rx_xcvr_up_ch_0_wr),
        .up_ch_wr_1(axi_mxfe_rx_xcvr_up_ch_1_wr),
        .up_ch_wr_2(axi_mxfe_rx_xcvr_up_ch_2_wr),
        .up_ch_wr_3(axi_mxfe_rx_xcvr_up_ch_3_wr),
        .up_es_addr_0(axi_mxfe_rx_xcvr_up_es_0_addr),
        .up_es_addr_1(axi_mxfe_rx_xcvr_up_es_1_addr),
        .up_es_addr_2(axi_mxfe_rx_xcvr_up_es_2_addr),
        .up_es_addr_3(axi_mxfe_rx_xcvr_up_es_3_addr),
        .up_es_enb_0(axi_mxfe_rx_xcvr_up_es_0_enb),
        .up_es_enb_1(axi_mxfe_rx_xcvr_up_es_1_enb),
        .up_es_enb_2(axi_mxfe_rx_xcvr_up_es_2_enb),
        .up_es_enb_3(axi_mxfe_rx_xcvr_up_es_3_enb),
        .up_es_rdata_0(axi_mxfe_rx_xcvr_up_es_0_rdata),
        .up_es_rdata_1(axi_mxfe_rx_xcvr_up_es_1_rdata),
        .up_es_rdata_2(axi_mxfe_rx_xcvr_up_es_2_rdata),
        .up_es_rdata_3(axi_mxfe_rx_xcvr_up_es_3_rdata),
        .up_es_ready_0(axi_mxfe_rx_xcvr_up_es_0_ready),
        .up_es_ready_1(axi_mxfe_rx_xcvr_up_es_1_ready),
        .up_es_ready_2(axi_mxfe_rx_xcvr_up_es_2_ready),
        .up_es_ready_3(axi_mxfe_rx_xcvr_up_es_3_ready),
        .up_es_reset_0(axi_mxfe_rx_xcvr_up_es_0_reset),
        .up_es_reset_1(axi_mxfe_rx_xcvr_up_es_1_reset),
        .up_es_reset_2(axi_mxfe_rx_xcvr_up_es_2_reset),
        .up_es_reset_3(axi_mxfe_rx_xcvr_up_es_3_reset),
        .up_es_wdata_0(axi_mxfe_rx_xcvr_up_es_0_wdata),
        .up_es_wdata_1(axi_mxfe_rx_xcvr_up_es_1_wdata),
        .up_es_wdata_2(axi_mxfe_rx_xcvr_up_es_2_wdata),
        .up_es_wdata_3(axi_mxfe_rx_xcvr_up_es_3_wdata),
        .up_es_wr_0(axi_mxfe_rx_xcvr_up_es_0_wr),
        .up_es_wr_1(axi_mxfe_rx_xcvr_up_es_1_wr),
        .up_es_wr_2(axi_mxfe_rx_xcvr_up_es_2_wr),
        .up_es_wr_3(axi_mxfe_rx_xcvr_up_es_3_wr),
        .up_pll_rst(axi_mxfe_rx_xcvr_up_pll_rst));
  test_harness_axi_mxfe_tx_dma_0 axi_mxfe_tx_dma
       (.irq(axi_mxfe_tx_dma_irq),
        .m_axis_aclk(sys_dma_clk),
        .m_axis_data(s_axis_1_TDATA),
        .m_axis_keep(s_axis_1_TKEEP),
        .m_axis_last(s_axis_1_TLAST),
        .m_axis_ready(s_axis_1_TREADY),
        .m_axis_valid(s_axis_1_TVALID),
        .m_axis_xfer_req(init_req_2),
        .m_src_axi_aclk(sys_dma_clk),
        .m_src_axi_araddr(axi_mxfe_tx_dma_m_src_axi_ARADDR),
        .m_src_axi_arburst(axi_mxfe_tx_dma_m_src_axi_ARBURST),
        .m_src_axi_arcache(axi_mxfe_tx_dma_m_src_axi_ARCACHE),
        .m_src_axi_aresetn(sys_dma_resetn),
        .m_src_axi_arlen(axi_mxfe_tx_dma_m_src_axi_ARLEN),
        .m_src_axi_arprot(axi_mxfe_tx_dma_m_src_axi_ARPROT),
        .m_src_axi_arready(axi_mxfe_tx_dma_m_src_axi_ARREADY),
        .m_src_axi_arsize(axi_mxfe_tx_dma_m_src_axi_ARSIZE),
        .m_src_axi_arvalid(axi_mxfe_tx_dma_m_src_axi_ARVALID),
        .m_src_axi_rdata(axi_mxfe_tx_dma_m_src_axi_RDATA),
        .m_src_axi_rlast(axi_mxfe_tx_dma_m_src_axi_RLAST),
        .m_src_axi_rready(axi_mxfe_tx_dma_m_src_axi_RREADY),
        .m_src_axi_rresp(axi_mxfe_tx_dma_m_src_axi_RRESP),
        .m_src_axi_rvalid(axi_mxfe_tx_dma_m_src_axi_RVALID),
        .s_axi_aclk(sys_cpu_clk),
        .s_axi_araddr(axi_axi_interconnect_M10_AXI_ARADDR),
        .s_axi_aresetn(sys_cpu_resetn),
        .s_axi_arprot(axi_axi_interconnect_M10_AXI_ARPROT),
        .s_axi_arready(axi_axi_interconnect_M10_AXI_ARREADY),
        .s_axi_arvalid(axi_axi_interconnect_M10_AXI_ARVALID),
        .s_axi_awaddr(axi_axi_interconnect_M10_AXI_AWADDR),
        .s_axi_awprot(axi_axi_interconnect_M10_AXI_AWPROT),
        .s_axi_awready(axi_axi_interconnect_M10_AXI_AWREADY),
        .s_axi_awvalid(axi_axi_interconnect_M10_AXI_AWVALID),
        .s_axi_bready(axi_axi_interconnect_M10_AXI_BREADY),
        .s_axi_bresp(axi_axi_interconnect_M10_AXI_BRESP),
        .s_axi_bvalid(axi_axi_interconnect_M10_AXI_BVALID),
        .s_axi_rdata(axi_axi_interconnect_M10_AXI_RDATA),
        .s_axi_rready(axi_axi_interconnect_M10_AXI_RREADY),
        .s_axi_rresp(axi_axi_interconnect_M10_AXI_RRESP),
        .s_axi_rvalid(axi_axi_interconnect_M10_AXI_RVALID),
        .s_axi_wdata(axi_axi_interconnect_M10_AXI_WDATA),
        .s_axi_wready(axi_axi_interconnect_M10_AXI_WREADY),
        .s_axi_wstrb(axi_axi_interconnect_M10_AXI_WSTRB),
        .s_axi_wvalid(axi_axi_interconnect_M10_AXI_WVALID));
  axi_mxfe_tx_jesd_imp_13QEZ6D axi_mxfe_tx_jesd
       (.device_clk(tx_device_clk_1),
        .irq(axi_mxfe_tx_jesd_irq),
        .link_clk(util_mxfe_xcvr_tx_out_clk_0),
        .s_axi_aclk(sys_cpu_clk),
        .s_axi_araddr(axi_axi_interconnect_M09_AXI_ARADDR),
        .s_axi_aresetn(sys_cpu_resetn),
        .s_axi_arprot(axi_axi_interconnect_M09_AXI_ARPROT),
        .s_axi_arready(axi_axi_interconnect_M09_AXI_ARREADY),
        .s_axi_arvalid(axi_axi_interconnect_M09_AXI_ARVALID),
        .s_axi_awaddr(axi_axi_interconnect_M09_AXI_AWADDR),
        .s_axi_awprot(axi_axi_interconnect_M09_AXI_AWPROT),
        .s_axi_awready(axi_axi_interconnect_M09_AXI_AWREADY),
        .s_axi_awvalid(axi_axi_interconnect_M09_AXI_AWVALID),
        .s_axi_bready(axi_axi_interconnect_M09_AXI_BREADY),
        .s_axi_bresp(axi_axi_interconnect_M09_AXI_BRESP),
        .s_axi_bvalid(axi_axi_interconnect_M09_AXI_BVALID),
        .s_axi_rdata(axi_axi_interconnect_M09_AXI_RDATA),
        .s_axi_rready(axi_axi_interconnect_M09_AXI_RREADY),
        .s_axi_rresp(axi_axi_interconnect_M09_AXI_RRESP),
        .s_axi_rvalid(axi_axi_interconnect_M09_AXI_RVALID),
        .s_axi_wdata(axi_axi_interconnect_M09_AXI_WDATA),
        .s_axi_wready(axi_axi_interconnect_M09_AXI_WREADY),
        .s_axi_wstrb(axi_axi_interconnect_M09_AXI_WSTRB),
        .s_axi_wvalid(axi_axi_interconnect_M09_AXI_WVALID),
        .sysref(sysref_2),
        .tx_data_tdata(tx_mxfe_tpl_core_link_TDATA),
        .tx_data_tready(tx_mxfe_tpl_core_link_TREADY),
        .tx_data_tvalid(tx_mxfe_tpl_core_link_TVALID),
        .tx_phy0_txcharisk(axi_mxfe_tx_jesd_tx_phy0_txcharisk),
        .tx_phy0_txdata(axi_mxfe_tx_jesd_tx_phy0_txdata),
        .tx_phy0_txheader(axi_mxfe_tx_jesd_tx_phy0_txheader),
        .tx_phy1_txcharisk(axi_mxfe_tx_jesd_tx_phy1_txcharisk),
        .tx_phy1_txdata(axi_mxfe_tx_jesd_tx_phy1_txdata),
        .tx_phy1_txheader(axi_mxfe_tx_jesd_tx_phy1_txheader),
        .tx_phy2_txcharisk(axi_mxfe_tx_jesd_tx_phy2_txcharisk),
        .tx_phy2_txdata(axi_mxfe_tx_jesd_tx_phy2_txdata),
        .tx_phy2_txheader(axi_mxfe_tx_jesd_tx_phy2_txheader),
        .tx_phy3_txcharisk(axi_mxfe_tx_jesd_tx_phy3_txcharisk),
        .tx_phy3_txdata(axi_mxfe_tx_jesd_tx_phy3_txdata),
        .tx_phy3_txheader(axi_mxfe_tx_jesd_tx_phy3_txheader));
  test_harness_axi_mxfe_tx_xcvr_0 axi_mxfe_tx_xcvr
       (.s_axi_aclk(sys_cpu_clk),
        .s_axi_araddr(axi_axi_interconnect_M07_AXI_ARADDR),
        .s_axi_aresetn(sys_cpu_resetn),
        .s_axi_arprot(axi_axi_interconnect_M07_AXI_ARPROT),
        .s_axi_arready(axi_axi_interconnect_M07_AXI_ARREADY),
        .s_axi_arvalid(axi_axi_interconnect_M07_AXI_ARVALID),
        .s_axi_awaddr(axi_axi_interconnect_M07_AXI_AWADDR),
        .s_axi_awprot(axi_axi_interconnect_M07_AXI_AWPROT),
        .s_axi_awready(axi_axi_interconnect_M07_AXI_AWREADY),
        .s_axi_awvalid(axi_axi_interconnect_M07_AXI_AWVALID),
        .s_axi_bready(axi_axi_interconnect_M07_AXI_BREADY),
        .s_axi_bresp(axi_axi_interconnect_M07_AXI_BRESP),
        .s_axi_bvalid(axi_axi_interconnect_M07_AXI_BVALID),
        .s_axi_rdata(axi_axi_interconnect_M07_AXI_RDATA),
        .s_axi_rready(axi_axi_interconnect_M07_AXI_RREADY),
        .s_axi_rresp(axi_axi_interconnect_M07_AXI_RRESP),
        .s_axi_rvalid(axi_axi_interconnect_M07_AXI_RVALID),
        .s_axi_wdata(axi_axi_interconnect_M07_AXI_WDATA),
        .s_axi_wready(axi_axi_interconnect_M07_AXI_WREADY),
        .s_axi_wstrb(axi_axi_interconnect_M07_AXI_WSTRB),
        .s_axi_wvalid(axi_axi_interconnect_M07_AXI_WVALID),
        .up_ch_addr_0(axi_mxfe_tx_xcvr_up_ch_0_addr),
        .up_ch_addr_1(axi_mxfe_tx_xcvr_up_ch_1_addr),
        .up_ch_addr_2(axi_mxfe_tx_xcvr_up_ch_2_addr),
        .up_ch_addr_3(axi_mxfe_tx_xcvr_up_ch_3_addr),
        .up_ch_bufstatus_0(axi_mxfe_tx_xcvr_up_ch_0_bufstatus),
        .up_ch_bufstatus_1(axi_mxfe_tx_xcvr_up_ch_1_bufstatus),
        .up_ch_bufstatus_2(axi_mxfe_tx_xcvr_up_ch_2_bufstatus),
        .up_ch_bufstatus_3(axi_mxfe_tx_xcvr_up_ch_3_bufstatus),
        .up_ch_enb_0(axi_mxfe_tx_xcvr_up_ch_0_enb),
        .up_ch_enb_1(axi_mxfe_tx_xcvr_up_ch_1_enb),
        .up_ch_enb_2(axi_mxfe_tx_xcvr_up_ch_2_enb),
        .up_ch_enb_3(axi_mxfe_tx_xcvr_up_ch_3_enb),
        .up_ch_lpm_dfe_n_0(axi_mxfe_tx_xcvr_up_ch_0_lpm_dfe_n),
        .up_ch_lpm_dfe_n_1(axi_mxfe_tx_xcvr_up_ch_1_lpm_dfe_n),
        .up_ch_lpm_dfe_n_2(axi_mxfe_tx_xcvr_up_ch_2_lpm_dfe_n),
        .up_ch_lpm_dfe_n_3(axi_mxfe_tx_xcvr_up_ch_3_lpm_dfe_n),
        .up_ch_out_clk_sel_0(axi_mxfe_tx_xcvr_up_ch_0_out_clk_sel),
        .up_ch_out_clk_sel_1(axi_mxfe_tx_xcvr_up_ch_1_out_clk_sel),
        .up_ch_out_clk_sel_2(axi_mxfe_tx_xcvr_up_ch_2_out_clk_sel),
        .up_ch_out_clk_sel_3(axi_mxfe_tx_xcvr_up_ch_3_out_clk_sel),
        .up_ch_pll_locked_0(axi_mxfe_tx_xcvr_up_ch_0_pll_locked),
        .up_ch_pll_locked_1(axi_mxfe_tx_xcvr_up_ch_1_pll_locked),
        .up_ch_pll_locked_2(axi_mxfe_tx_xcvr_up_ch_2_pll_locked),
        .up_ch_pll_locked_3(axi_mxfe_tx_xcvr_up_ch_3_pll_locked),
        .up_ch_prbserr_0(1'b0),
        .up_ch_prbserr_1(1'b0),
        .up_ch_prbserr_2(1'b0),
        .up_ch_prbserr_3(1'b0),
        .up_ch_prbsforceerr_0(axi_mxfe_tx_xcvr_up_ch_0_prbsforceerr),
        .up_ch_prbsforceerr_1(axi_mxfe_tx_xcvr_up_ch_1_prbsforceerr),
        .up_ch_prbsforceerr_2(axi_mxfe_tx_xcvr_up_ch_2_prbsforceerr),
        .up_ch_prbsforceerr_3(axi_mxfe_tx_xcvr_up_ch_3_prbsforceerr),
        .up_ch_prbslocked_0(1'b0),
        .up_ch_prbslocked_1(1'b0),
        .up_ch_prbslocked_2(1'b0),
        .up_ch_prbslocked_3(1'b0),
        .up_ch_prbssel_0(axi_mxfe_tx_xcvr_up_ch_0_prbssel),
        .up_ch_prbssel_1(axi_mxfe_tx_xcvr_up_ch_1_prbssel),
        .up_ch_prbssel_2(axi_mxfe_tx_xcvr_up_ch_2_prbssel),
        .up_ch_prbssel_3(axi_mxfe_tx_xcvr_up_ch_3_prbssel),
        .up_ch_rate_0(axi_mxfe_tx_xcvr_up_ch_0_rate),
        .up_ch_rate_1(axi_mxfe_tx_xcvr_up_ch_1_rate),
        .up_ch_rate_2(axi_mxfe_tx_xcvr_up_ch_2_rate),
        .up_ch_rate_3(axi_mxfe_tx_xcvr_up_ch_3_rate),
        .up_ch_rdata_0(axi_mxfe_tx_xcvr_up_ch_0_rdata),
        .up_ch_rdata_1(axi_mxfe_tx_xcvr_up_ch_1_rdata),
        .up_ch_rdata_2(axi_mxfe_tx_xcvr_up_ch_2_rdata),
        .up_ch_rdata_3(axi_mxfe_tx_xcvr_up_ch_3_rdata),
        .up_ch_ready_0(axi_mxfe_tx_xcvr_up_ch_0_ready),
        .up_ch_ready_1(axi_mxfe_tx_xcvr_up_ch_1_ready),
        .up_ch_ready_2(axi_mxfe_tx_xcvr_up_ch_2_ready),
        .up_ch_ready_3(axi_mxfe_tx_xcvr_up_ch_3_ready),
        .up_ch_rst_0(axi_mxfe_tx_xcvr_up_ch_0_rst),
        .up_ch_rst_1(axi_mxfe_tx_xcvr_up_ch_1_rst),
        .up_ch_rst_2(axi_mxfe_tx_xcvr_up_ch_2_rst),
        .up_ch_rst_3(axi_mxfe_tx_xcvr_up_ch_3_rst),
        .up_ch_rst_done_0(axi_mxfe_tx_xcvr_up_ch_0_rst_done),
        .up_ch_rst_done_1(axi_mxfe_tx_xcvr_up_ch_1_rst_done),
        .up_ch_rst_done_2(axi_mxfe_tx_xcvr_up_ch_2_rst_done),
        .up_ch_rst_done_3(axi_mxfe_tx_xcvr_up_ch_3_rst_done),
        .up_ch_sys_clk_sel_0(axi_mxfe_tx_xcvr_up_ch_0_sys_clk_sel),
        .up_ch_sys_clk_sel_1(axi_mxfe_tx_xcvr_up_ch_1_sys_clk_sel),
        .up_ch_sys_clk_sel_2(axi_mxfe_tx_xcvr_up_ch_2_sys_clk_sel),
        .up_ch_sys_clk_sel_3(axi_mxfe_tx_xcvr_up_ch_3_sys_clk_sel),
        .up_ch_tx_diffctrl_0(axi_mxfe_tx_xcvr_up_ch_0_tx_diffctrl),
        .up_ch_tx_diffctrl_1(axi_mxfe_tx_xcvr_up_ch_1_tx_diffctrl),
        .up_ch_tx_diffctrl_2(axi_mxfe_tx_xcvr_up_ch_2_tx_diffctrl),
        .up_ch_tx_diffctrl_3(axi_mxfe_tx_xcvr_up_ch_3_tx_diffctrl),
        .up_ch_tx_postcursor_0(axi_mxfe_tx_xcvr_up_ch_0_tx_postcursor),
        .up_ch_tx_postcursor_1(axi_mxfe_tx_xcvr_up_ch_1_tx_postcursor),
        .up_ch_tx_postcursor_2(axi_mxfe_tx_xcvr_up_ch_2_tx_postcursor),
        .up_ch_tx_postcursor_3(axi_mxfe_tx_xcvr_up_ch_3_tx_postcursor),
        .up_ch_tx_precursor_0(axi_mxfe_tx_xcvr_up_ch_0_tx_precursor),
        .up_ch_tx_precursor_1(axi_mxfe_tx_xcvr_up_ch_1_tx_precursor),
        .up_ch_tx_precursor_2(axi_mxfe_tx_xcvr_up_ch_2_tx_precursor),
        .up_ch_tx_precursor_3(axi_mxfe_tx_xcvr_up_ch_3_tx_precursor),
        .up_ch_user_ready_0(axi_mxfe_tx_xcvr_up_ch_0_user_ready),
        .up_ch_user_ready_1(axi_mxfe_tx_xcvr_up_ch_1_user_ready),
        .up_ch_user_ready_2(axi_mxfe_tx_xcvr_up_ch_2_user_ready),
        .up_ch_user_ready_3(axi_mxfe_tx_xcvr_up_ch_3_user_ready),
        .up_ch_wdata_0(axi_mxfe_tx_xcvr_up_ch_0_wdata),
        .up_ch_wdata_1(axi_mxfe_tx_xcvr_up_ch_1_wdata),
        .up_ch_wdata_2(axi_mxfe_tx_xcvr_up_ch_2_wdata),
        .up_ch_wdata_3(axi_mxfe_tx_xcvr_up_ch_3_wdata),
        .up_ch_wr_0(axi_mxfe_tx_xcvr_up_ch_0_wr),
        .up_ch_wr_1(axi_mxfe_tx_xcvr_up_ch_1_wr),
        .up_ch_wr_2(axi_mxfe_tx_xcvr_up_ch_2_wr),
        .up_ch_wr_3(axi_mxfe_tx_xcvr_up_ch_3_wr),
        .up_cm_addr_0(axi_mxfe_tx_xcvr_up_cm_0_addr),
        .up_cm_enb_0(axi_mxfe_tx_xcvr_up_cm_0_enb),
        .up_cm_rdata_0(axi_mxfe_tx_xcvr_up_cm_0_rdata),
        .up_cm_ready_0(axi_mxfe_tx_xcvr_up_cm_0_ready),
        .up_cm_wdata_0(axi_mxfe_tx_xcvr_up_cm_0_wdata),
        .up_cm_wr_0(axi_mxfe_tx_xcvr_up_cm_0_wr),
        .up_pll_rst(axi_mxfe_tx_xcvr_up_pll_rst));
  test_harness_cpack_reset_sources_0 cpack_reset_sources
       (.In0(rx_device_clk_rstgen_peripheral_reset),
        .In1(rx_mxfe_tpl_core_adc_rst),
        .In2(rx_do_rstout_logic_Res),
        .dout(cpack_reset_sources_dout));
  test_harness_cpack_rst_logic_0 cpack_rst_logic
       (.Op1(cpack_reset_sources_dout),
        .Res(cpack_rst_logic_Res));
  test_harness_ddr_axi_vip_0 ddr_axi_vip
       (.aclk(sys_mem_clk),
        .aresetn(sys_mem_resetn),
        .s_axi_araddr(axi_mem_interconnect_M00_AXI_ARADDR),
        .s_axi_arburst(axi_mem_interconnect_M00_AXI_ARBURST),
        .s_axi_arcache(axi_mem_interconnect_M00_AXI_ARCACHE),
        .s_axi_arlen(axi_mem_interconnect_M00_AXI_ARLEN),
        .s_axi_arlock(axi_mem_interconnect_M00_AXI_ARLOCK),
        .s_axi_arprot(axi_mem_interconnect_M00_AXI_ARPROT),
        .s_axi_arqos(axi_mem_interconnect_M00_AXI_ARQOS),
        .s_axi_arready(axi_mem_interconnect_M00_AXI_ARREADY),
        .s_axi_arvalid(axi_mem_interconnect_M00_AXI_ARVALID),
        .s_axi_awaddr(axi_mem_interconnect_M00_AXI_AWADDR),
        .s_axi_awburst(axi_mem_interconnect_M00_AXI_AWBURST),
        .s_axi_awcache(axi_mem_interconnect_M00_AXI_AWCACHE),
        .s_axi_awlen(axi_mem_interconnect_M00_AXI_AWLEN),
        .s_axi_awlock(axi_mem_interconnect_M00_AXI_AWLOCK),
        .s_axi_awprot(axi_mem_interconnect_M00_AXI_AWPROT),
        .s_axi_awqos(axi_mem_interconnect_M00_AXI_AWQOS),
        .s_axi_awready(axi_mem_interconnect_M00_AXI_AWREADY),
        .s_axi_awvalid(axi_mem_interconnect_M00_AXI_AWVALID),
        .s_axi_bready(axi_mem_interconnect_M00_AXI_BREADY),
        .s_axi_bresp(axi_mem_interconnect_M00_AXI_BRESP),
        .s_axi_bvalid(axi_mem_interconnect_M00_AXI_BVALID),
        .s_axi_rdata(axi_mem_interconnect_M00_AXI_RDATA),
        .s_axi_rlast(axi_mem_interconnect_M00_AXI_RLAST),
        .s_axi_rready(axi_mem_interconnect_M00_AXI_RREADY),
        .s_axi_rresp(axi_mem_interconnect_M00_AXI_RRESP),
        .s_axi_rvalid(axi_mem_interconnect_M00_AXI_RVALID),
        .s_axi_wdata(axi_mem_interconnect_M00_AXI_WDATA),
        .s_axi_wlast(axi_mem_interconnect_M00_AXI_WLAST),
        .s_axi_wready(axi_mem_interconnect_M00_AXI_WREADY),
        .s_axi_wstrb(axi_mem_interconnect_M00_AXI_WSTRB),
        .s_axi_wvalid(axi_mem_interconnect_M00_AXI_WVALID));
  test_harness_ddr_clk_vip_0 ddr_clk_vip
       (.clk_out(sys_mem_clk));
  test_harness_device_clk_vip_0 device_clk_vip
       (.clk_out(device_clk_vip_clk_out));
  test_harness_dma_clk_vip_0 dma_clk_vip
       (.clk_out(sys_dma_clk));
  test_harness_drp_clk_vip_0 drp_clk_vip
       ();
  test_harness_manual_sync_or_0 manual_sync_or
       (.Op1(rx_mxfe_tpl_core_adc_sync_manual_req_out),
        .Op2(tx_mxfe_tpl_core_dac_sync_manual_req_out),
        .Res(manual_sync_or_Res));
  test_harness_mng_axi_vip_0 mng_axi_vip
       (.aclk(sys_cpu_clk),
        .aresetn(sys_cpu_resetn),
        .m_axi_araddr(mng_axi_vip_M_AXI_ARADDR),
        .m_axi_arprot(mng_axi_vip_M_AXI_ARPROT),
        .m_axi_arready(mng_axi_vip_M_AXI_ARREADY),
        .m_axi_arvalid(mng_axi_vip_M_AXI_ARVALID),
        .m_axi_awaddr(mng_axi_vip_M_AXI_AWADDR),
        .m_axi_awprot(mng_axi_vip_M_AXI_AWPROT),
        .m_axi_awready(mng_axi_vip_M_AXI_AWREADY),
        .m_axi_awvalid(mng_axi_vip_M_AXI_AWVALID),
        .m_axi_bready(mng_axi_vip_M_AXI_BREADY),
        .m_axi_bresp(mng_axi_vip_M_AXI_BRESP),
        .m_axi_bvalid(mng_axi_vip_M_AXI_BVALID),
        .m_axi_rdata(mng_axi_vip_M_AXI_RDATA),
        .m_axi_rready(mng_axi_vip_M_AXI_RREADY),
        .m_axi_rresp(mng_axi_vip_M_AXI_RRESP),
        .m_axi_rvalid(mng_axi_vip_M_AXI_RVALID),
        .m_axi_wdata(mng_axi_vip_M_AXI_WDATA),
        .m_axi_wready(mng_axi_vip_M_AXI_WREADY),
        .m_axi_wstrb(mng_axi_vip_M_AXI_WSTRB),
        .m_axi_wvalid(mng_axi_vip_M_AXI_WVALID));
  mxfe_rx_data_offload_imp_1S7ORJK mxfe_rx_data_offload
       (.init_req(init_req_1),
        .m_axis_aclk(sys_dma_clk),
        .m_axis_aresetn(sys_dma_resetn),
        .m_axis_tdata(mxfe_rx_data_offload_m_axis_TDATA),
        .m_axis_tkeep(mxfe_rx_data_offload_m_axis_TKEEP),
        .m_axis_tlast(mxfe_rx_data_offload_m_axis_TLAST),
        .m_axis_tready(mxfe_rx_data_offload_m_axis_TREADY),
        .m_axis_tvalid(mxfe_rx_data_offload_m_axis_TVALID),
        .s_axi_aclk(sys_cpu_clk),
        .s_axi_araddr(axi_axi_interconnect_M06_AXI_ARADDR),
        .s_axi_aresetn(sys_cpu_resetn),
        .s_axi_arprot(axi_axi_interconnect_M06_AXI_ARPROT),
        .s_axi_arready(axi_axi_interconnect_M06_AXI_ARREADY),
        .s_axi_arvalid(axi_axi_interconnect_M06_AXI_ARVALID),
        .s_axi_awaddr(axi_axi_interconnect_M06_AXI_AWADDR),
        .s_axi_awprot(axi_axi_interconnect_M06_AXI_AWPROT),
        .s_axi_awready(axi_axi_interconnect_M06_AXI_AWREADY),
        .s_axi_awvalid(axi_axi_interconnect_M06_AXI_AWVALID),
        .s_axi_bready(axi_axi_interconnect_M06_AXI_BREADY),
        .s_axi_bresp(axi_axi_interconnect_M06_AXI_BRESP),
        .s_axi_bvalid(axi_axi_interconnect_M06_AXI_BVALID),
        .s_axi_rdata(axi_axi_interconnect_M06_AXI_RDATA),
        .s_axi_rready(axi_axi_interconnect_M06_AXI_RREADY),
        .s_axi_rresp(axi_axi_interconnect_M06_AXI_RRESP),
        .s_axi_rvalid(axi_axi_interconnect_M06_AXI_RVALID),
        .s_axi_wdata(axi_axi_interconnect_M06_AXI_WDATA),
        .s_axi_wready(axi_axi_interconnect_M06_AXI_WREADY),
        .s_axi_wstrb(axi_axi_interconnect_M06_AXI_WSTRB),
        .s_axi_wvalid(axi_axi_interconnect_M06_AXI_WVALID),
        .s_axis_aclk(rx_device_clk_1),
        .s_axis_aresetn(rx_device_clk_rstgen_peripheral_aresetn),
        .s_axis_tdata(util_mxfe_cpack_packed_fifo_wr_data),
        .s_axis_tkeep(VCC_1_dout),
        .s_axis_tlast(GND_1_dout),
        .s_axis_tready(mxfe_rx_data_offload_s_axis_tready),
        .s_axis_tvalid(util_mxfe_cpack_packed_fifo_wr_en),
        .sync_ext(GND_1_dout));
  mxfe_tx_data_offload_imp_PB4RZR mxfe_tx_data_offload
       (.init_req(init_req_2),
        .m_axis_aclk(tx_device_clk_1),
        .m_axis_aresetn(tx_device_clk_rstgen_peripheral_aresetn),
        .m_axis_tdata(mxfe_tx_data_offload_m_axis_TDATA),
        .m_axis_tready(mxfe_tx_data_offload_m_axis_TREADY),
        .m_axis_tvalid(mxfe_tx_data_offload_m_axis_TVALID),
        .s_axi_aclk(sys_cpu_clk),
        .s_axi_araddr(axi_axi_interconnect_M11_AXI_ARADDR),
        .s_axi_aresetn(sys_cpu_resetn),
        .s_axi_arprot(axi_axi_interconnect_M11_AXI_ARPROT),
        .s_axi_arready(axi_axi_interconnect_M11_AXI_ARREADY),
        .s_axi_arvalid(axi_axi_interconnect_M11_AXI_ARVALID),
        .s_axi_awaddr(axi_axi_interconnect_M11_AXI_AWADDR),
        .s_axi_awprot(axi_axi_interconnect_M11_AXI_AWPROT),
        .s_axi_awready(axi_axi_interconnect_M11_AXI_AWREADY),
        .s_axi_awvalid(axi_axi_interconnect_M11_AXI_AWVALID),
        .s_axi_bready(axi_axi_interconnect_M11_AXI_BREADY),
        .s_axi_bresp(axi_axi_interconnect_M11_AXI_BRESP),
        .s_axi_bvalid(axi_axi_interconnect_M11_AXI_BVALID),
        .s_axi_rdata(axi_axi_interconnect_M11_AXI_RDATA),
        .s_axi_rready(axi_axi_interconnect_M11_AXI_RREADY),
        .s_axi_rresp(axi_axi_interconnect_M11_AXI_RRESP),
        .s_axi_rvalid(axi_axi_interconnect_M11_AXI_RVALID),
        .s_axi_wdata(axi_axi_interconnect_M11_AXI_WDATA),
        .s_axi_wready(axi_axi_interconnect_M11_AXI_WREADY),
        .s_axi_wstrb(axi_axi_interconnect_M11_AXI_WSTRB),
        .s_axi_wvalid(axi_axi_interconnect_M11_AXI_WVALID),
        .s_axis_aclk(sys_dma_clk),
        .s_axis_aresetn(sys_dma_resetn),
        .s_axis_tdata(s_axis_1_TDATA),
        .s_axis_tkeep(s_axis_1_TKEEP),
        .s_axis_tlast(s_axis_1_TLAST),
        .s_axis_tready(s_axis_1_TREADY),
        .s_axis_tvalid(s_axis_1_TVALID),
        .sync_ext(GND_1_dout));
  test_harness_ref_clk_vip_0 ref_clk_vip
       (.clk_out(ref_clk_vip_clk_out));
  test_harness_rx_device_clk_rstgen_0 rx_device_clk_rstgen
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(sys_cpu_resetn),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rx_device_clk_rstgen_peripheral_aresetn),
        .peripheral_reset(rx_device_clk_rstgen_peripheral_reset),
        .slowest_sync_clk(rx_device_clk_1));
  test_harness_rx_do_rstout_logic_0 rx_do_rstout_logic
       (.Op1(mxfe_rx_data_offload_s_axis_tready),
        .Res(rx_do_rstout_logic_Res));
  rx_mxfe_tpl_core_imp_1EE77FV rx_mxfe_tpl_core
       (.adc_data_0(rx_mxfe_tpl_core_adc_data_0),
        .adc_data_1(rx_mxfe_tpl_core_adc_data_1),
        .adc_data_2(rx_mxfe_tpl_core_adc_data_2),
        .adc_data_3(rx_mxfe_tpl_core_adc_data_3),
        .adc_dovf(util_mxfe_cpack_fifo_wr_overflow),
        .adc_enable_0(rx_mxfe_tpl_core_adc_enable_0),
        .adc_enable_1(rx_mxfe_tpl_core_adc_enable_1),
        .adc_enable_2(rx_mxfe_tpl_core_adc_enable_2),
        .adc_enable_3(rx_mxfe_tpl_core_adc_enable_3),
        .adc_rst(rx_mxfe_tpl_core_adc_rst),
        .adc_sync_manual_req_in(manual_sync_or_Res),
        .adc_sync_manual_req_out(rx_mxfe_tpl_core_adc_sync_manual_req_out),
        .adc_valid_0(rx_mxfe_tpl_core_adc_valid_0),
        .ext_sync_in(ext_sync_in_1),
        .link_clk(rx_device_clk_1),
        .link_data(axi_mxfe_rx_jesd_rx_data_tdata),
        .link_sof(axi_mxfe_rx_jesd_rx_sof),
        .link_valid(axi_mxfe_rx_jesd_rx_data_tvalid),
        .s_axi_aclk(sys_cpu_clk),
        .s_axi_araddr(axi_axi_interconnect_M03_AXI_ARADDR),
        .s_axi_aresetn(sys_cpu_resetn),
        .s_axi_arprot(axi_axi_interconnect_M03_AXI_ARPROT),
        .s_axi_arready(axi_axi_interconnect_M03_AXI_ARREADY),
        .s_axi_arvalid(axi_axi_interconnect_M03_AXI_ARVALID),
        .s_axi_awaddr(axi_axi_interconnect_M03_AXI_AWADDR),
        .s_axi_awprot(axi_axi_interconnect_M03_AXI_AWPROT),
        .s_axi_awready(axi_axi_interconnect_M03_AXI_AWREADY),
        .s_axi_awvalid(axi_axi_interconnect_M03_AXI_AWVALID),
        .s_axi_bready(axi_axi_interconnect_M03_AXI_BREADY),
        .s_axi_bresp(axi_axi_interconnect_M03_AXI_BRESP),
        .s_axi_bvalid(axi_axi_interconnect_M03_AXI_BVALID),
        .s_axi_rdata(axi_axi_interconnect_M03_AXI_RDATA),
        .s_axi_rready(axi_axi_interconnect_M03_AXI_RREADY),
        .s_axi_rresp(axi_axi_interconnect_M03_AXI_RRESP),
        .s_axi_rvalid(axi_axi_interconnect_M03_AXI_RVALID),
        .s_axi_wdata(axi_axi_interconnect_M03_AXI_WDATA),
        .s_axi_wready(axi_axi_interconnect_M03_AXI_WREADY),
        .s_axi_wstrb(axi_axi_interconnect_M03_AXI_WSTRB),
        .s_axi_wvalid(axi_axi_interconnect_M03_AXI_WVALID));
  test_harness_sys_clk_vip_0 sys_clk_vip
       (.clk_out(sys_cpu_clk));
  test_harness_sys_concat_intc_0 sys_concat_intc
       (.In0(GND_1_dout),
        .In1(GND_1_dout),
        .In10(GND_1_dout),
        .In11(GND_1_dout),
        .In12(axi_mxfe_rx_dma_irq),
        .In13(axi_mxfe_tx_dma_irq),
        .In14(axi_mxfe_rx_jesd_irq),
        .In15(axi_mxfe_tx_jesd_irq),
        .In2(GND_1_dout),
        .In3(GND_1_dout),
        .In4(GND_1_dout),
        .In5(GND_1_dout),
        .In6(GND_1_dout),
        .In7(GND_1_dout),
        .In8(GND_1_dout),
        .In9(GND_1_dout),
        .dout(sys_concat_intc_dout));
  test_harness_sys_dma_rstgen_0 sys_dma_rstgen
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(sys_rst_vip_rst_out),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(sys_dma_resetn),
        .peripheral_reset(sys_dma_reset),
        .slowest_sync_clk(sys_dma_clk));
  test_harness_sys_mem_rstgen_0 sys_mem_rstgen
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(sys_rst_vip_rst_out),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(sys_mem_resetn),
        .peripheral_reset(sys_mem_reset),
        .slowest_sync_clk(sys_mem_clk));
  test_harness_sys_rst_vip_0 sys_rst_vip
       (.rst_out(sys_rst_vip_rst_out));
  test_harness_sys_rstgen_0 sys_rstgen
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(sys_rst_vip_rst_out),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(sys_cpu_resetn),
        .peripheral_reset(sys_cpu_reset),
        .slowest_sync_clk(sys_cpu_clk));
  test_harness_sysref_clk_vip_0 sysref_clk_vip
       (.clk_out(sysref_clk_vip_clk_out));
  test_harness_tx_device_clk_rstgen_0 tx_device_clk_rstgen
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(sys_cpu_resetn),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(tx_device_clk_rstgen_peripheral_aresetn),
        .peripheral_reset(tx_device_clk_rstgen_peripheral_reset),
        .slowest_sync_clk(tx_device_clk_1));
  tx_mxfe_tpl_core_imp_1CVF2G5 tx_mxfe_tpl_core
       (.dac_data_0(util_mxfe_upack_fifo_rd_data_0),
        .dac_data_1(util_mxfe_upack_fifo_rd_data_1),
        .dac_data_2(util_mxfe_upack_fifo_rd_data_2),
        .dac_data_3(util_mxfe_upack_fifo_rd_data_3),
        .dac_dunf(GND_1_dout),
        .dac_enable_0(tx_mxfe_tpl_core_dac_enable_0),
        .dac_enable_1(tx_mxfe_tpl_core_dac_enable_1),
        .dac_enable_2(tx_mxfe_tpl_core_dac_enable_2),
        .dac_enable_3(tx_mxfe_tpl_core_dac_enable_3),
        .dac_rst(tx_mxfe_tpl_core_dac_rst),
        .dac_sync_manual_req_in(manual_sync_or_Res),
        .dac_sync_manual_req_out(tx_mxfe_tpl_core_dac_sync_manual_req_out),
        .dac_valid_0(tx_mxfe_tpl_core_dac_valid_0),
        .ext_sync_in(ext_sync_in_1),
        .link_clk(tx_device_clk_1),
        .link_tdata(tx_mxfe_tpl_core_link_TDATA),
        .link_tready(tx_mxfe_tpl_core_link_TREADY),
        .link_tvalid(tx_mxfe_tpl_core_link_TVALID),
        .s_axi_aclk(sys_cpu_clk),
        .s_axi_araddr(axi_axi_interconnect_M08_AXI_ARADDR),
        .s_axi_aresetn(sys_cpu_resetn),
        .s_axi_arprot(axi_axi_interconnect_M08_AXI_ARPROT),
        .s_axi_arready(axi_axi_interconnect_M08_AXI_ARREADY),
        .s_axi_arvalid(axi_axi_interconnect_M08_AXI_ARVALID),
        .s_axi_awaddr(axi_axi_interconnect_M08_AXI_AWADDR),
        .s_axi_awprot(axi_axi_interconnect_M08_AXI_AWPROT),
        .s_axi_awready(axi_axi_interconnect_M08_AXI_AWREADY),
        .s_axi_awvalid(axi_axi_interconnect_M08_AXI_AWVALID),
        .s_axi_bready(axi_axi_interconnect_M08_AXI_BREADY),
        .s_axi_bresp(axi_axi_interconnect_M08_AXI_BRESP),
        .s_axi_bvalid(axi_axi_interconnect_M08_AXI_BVALID),
        .s_axi_rdata(axi_axi_interconnect_M08_AXI_RDATA),
        .s_axi_rready(axi_axi_interconnect_M08_AXI_RREADY),
        .s_axi_rresp(axi_axi_interconnect_M08_AXI_RRESP),
        .s_axi_rvalid(axi_axi_interconnect_M08_AXI_RVALID),
        .s_axi_wdata(axi_axi_interconnect_M08_AXI_WDATA),
        .s_axi_wready(axi_axi_interconnect_M08_AXI_WREADY),
        .s_axi_wstrb(axi_axi_interconnect_M08_AXI_WSTRB),
        .s_axi_wvalid(axi_axi_interconnect_M08_AXI_WVALID));
  test_harness_upack_reset_sources_0 upack_reset_sources
       (.In0(tx_device_clk_rstgen_peripheral_reset),
        .In1(tx_mxfe_tpl_core_dac_rst),
        .dout(upack_reset_sources_dout));
  test_harness_upack_rst_logic_0 upack_rst_logic
       (.Op1(upack_reset_sources_dout),
        .Res(upack_rst_logic_Res));
  test_harness_util_mxfe_cpack_0 util_mxfe_cpack
       (.clk(rx_device_clk_1),
        .enable_0(rx_mxfe_tpl_core_adc_enable_0),
        .enable_1(rx_mxfe_tpl_core_adc_enable_1),
        .enable_2(rx_mxfe_tpl_core_adc_enable_2),
        .enable_3(rx_mxfe_tpl_core_adc_enable_3),
        .fifo_wr_data_0(rx_mxfe_tpl_core_adc_data_0),
        .fifo_wr_data_1(rx_mxfe_tpl_core_adc_data_1),
        .fifo_wr_data_2(rx_mxfe_tpl_core_adc_data_2),
        .fifo_wr_data_3(rx_mxfe_tpl_core_adc_data_3),
        .fifo_wr_en(rx_mxfe_tpl_core_adc_valid_0),
        .fifo_wr_overflow(util_mxfe_cpack_fifo_wr_overflow),
        .packed_fifo_wr_data(util_mxfe_cpack_packed_fifo_wr_data),
        .packed_fifo_wr_en(util_mxfe_cpack_packed_fifo_wr_en),
        .packed_fifo_wr_overflow(1'b0),
        .reset(cpack_rst_logic_Res));
  test_harness_util_mxfe_upack_0 util_mxfe_upack
       (.clk(tx_device_clk_1),
        .enable_0(tx_mxfe_tpl_core_dac_enable_0),
        .enable_1(tx_mxfe_tpl_core_dac_enable_1),
        .enable_2(tx_mxfe_tpl_core_dac_enable_2),
        .enable_3(tx_mxfe_tpl_core_dac_enable_3),
        .fifo_rd_data_0(util_mxfe_upack_fifo_rd_data_0),
        .fifo_rd_data_1(util_mxfe_upack_fifo_rd_data_1),
        .fifo_rd_data_2(util_mxfe_upack_fifo_rd_data_2),
        .fifo_rd_data_3(util_mxfe_upack_fifo_rd_data_3),
        .fifo_rd_en(tx_mxfe_tpl_core_dac_valid_0),
        .reset(upack_rst_logic_Res),
        .s_axis_data(mxfe_tx_data_offload_m_axis_TDATA),
        .s_axis_ready(mxfe_tx_data_offload_m_axis_TREADY),
        .s_axis_valid(mxfe_tx_data_offload_m_axis_TVALID));
  test_harness_util_mxfe_xcvr_0 util_mxfe_xcvr
       (.cpll_ref_clk_0(ref_clk_q0_1),
        .cpll_ref_clk_1(ref_clk_q0_1),
        .cpll_ref_clk_2(ref_clk_q0_1),
        .cpll_ref_clk_3(ref_clk_q0_1),
        .qpll_ref_clk_0(ref_clk_q0_1),
        .rx_0_n(rx_data_0_n_1),
        .rx_0_p(rx_data_0_p_1),
        .rx_1_n(rx_data_1_n_1),
        .rx_1_p(rx_data_1_p_1),
        .rx_2_n(rx_data_2_n_1),
        .rx_2_p(rx_data_2_p_1),
        .rx_3_n(rx_data_3_n_1),
        .rx_3_p(rx_data_3_p_1),
        .rx_block_sync_0(util_mxfe_xcvr_rx_0_rxblock_sync),
        .rx_block_sync_1(util_mxfe_xcvr_rx_1_rxblock_sync),
        .rx_block_sync_2(util_mxfe_xcvr_rx_2_rxblock_sync),
        .rx_block_sync_3(util_mxfe_xcvr_rx_3_rxblock_sync),
        .rx_calign_0(1'b0),
        .rx_calign_1(1'b0),
        .rx_calign_2(1'b0),
        .rx_calign_3(1'b0),
        .rx_charisk_0(util_mxfe_xcvr_rx_0_rxcharisk),
        .rx_charisk_1(util_mxfe_xcvr_rx_1_rxcharisk),
        .rx_charisk_2(util_mxfe_xcvr_rx_2_rxcharisk),
        .rx_charisk_3(util_mxfe_xcvr_rx_3_rxcharisk),
        .rx_clk_0(util_mxfe_xcvr_rx_out_clk_0),
        .rx_clk_1(util_mxfe_xcvr_rx_out_clk_0),
        .rx_clk_2(util_mxfe_xcvr_rx_out_clk_0),
        .rx_clk_3(util_mxfe_xcvr_rx_out_clk_0),
        .rx_data_0(util_mxfe_xcvr_rx_0_rxdata),
        .rx_data_1(util_mxfe_xcvr_rx_1_rxdata),
        .rx_data_2(util_mxfe_xcvr_rx_2_rxdata),
        .rx_data_3(util_mxfe_xcvr_rx_3_rxdata),
        .rx_disperr_0(util_mxfe_xcvr_rx_0_rxdisperr),
        .rx_disperr_1(util_mxfe_xcvr_rx_1_rxdisperr),
        .rx_disperr_2(util_mxfe_xcvr_rx_2_rxdisperr),
        .rx_disperr_3(util_mxfe_xcvr_rx_3_rxdisperr),
        .rx_header_0(util_mxfe_xcvr_rx_0_rxheader),
        .rx_header_1(util_mxfe_xcvr_rx_1_rxheader),
        .rx_header_2(util_mxfe_xcvr_rx_2_rxheader),
        .rx_header_3(util_mxfe_xcvr_rx_3_rxheader),
        .rx_notintable_0(util_mxfe_xcvr_rx_0_rxnotintable),
        .rx_notintable_1(util_mxfe_xcvr_rx_1_rxnotintable),
        .rx_notintable_2(util_mxfe_xcvr_rx_2_rxnotintable),
        .rx_notintable_3(util_mxfe_xcvr_rx_3_rxnotintable),
        .rx_out_clk_0(util_mxfe_xcvr_rx_out_clk_0),
        .tx_0_n(util_mxfe_xcvr_tx_0_n),
        .tx_0_p(util_mxfe_xcvr_tx_0_p),
        .tx_1_n(util_mxfe_xcvr_tx_1_n),
        .tx_1_p(util_mxfe_xcvr_tx_1_p),
        .tx_2_n(util_mxfe_xcvr_tx_2_n),
        .tx_2_p(util_mxfe_xcvr_tx_2_p),
        .tx_3_n(util_mxfe_xcvr_tx_3_n),
        .tx_3_p(util_mxfe_xcvr_tx_3_p),
        .tx_charisk_0(axi_mxfe_tx_jesd_tx_phy0_txcharisk),
        .tx_charisk_1(axi_mxfe_tx_jesd_tx_phy1_txcharisk),
        .tx_charisk_2(axi_mxfe_tx_jesd_tx_phy2_txcharisk),
        .tx_charisk_3(axi_mxfe_tx_jesd_tx_phy3_txcharisk),
        .tx_clk_0(util_mxfe_xcvr_tx_out_clk_0),
        .tx_clk_1(util_mxfe_xcvr_tx_out_clk_0),
        .tx_clk_2(util_mxfe_xcvr_tx_out_clk_0),
        .tx_clk_3(util_mxfe_xcvr_tx_out_clk_0),
        .tx_data_0(axi_mxfe_tx_jesd_tx_phy0_txdata),
        .tx_data_1(axi_mxfe_tx_jesd_tx_phy1_txdata),
        .tx_data_2(axi_mxfe_tx_jesd_tx_phy2_txdata),
        .tx_data_3(axi_mxfe_tx_jesd_tx_phy3_txdata),
        .tx_header_0(axi_mxfe_tx_jesd_tx_phy0_txheader),
        .tx_header_1(axi_mxfe_tx_jesd_tx_phy1_txheader),
        .tx_header_2(axi_mxfe_tx_jesd_tx_phy2_txheader),
        .tx_header_3(axi_mxfe_tx_jesd_tx_phy3_txheader),
        .tx_out_clk_0(util_mxfe_xcvr_tx_out_clk_0),
        .up_clk(sys_cpu_clk),
        .up_cm_addr_0(axi_mxfe_tx_xcvr_up_cm_0_addr),
        .up_cm_enb_0(axi_mxfe_tx_xcvr_up_cm_0_enb),
        .up_cm_rdata_0(axi_mxfe_tx_xcvr_up_cm_0_rdata),
        .up_cm_ready_0(axi_mxfe_tx_xcvr_up_cm_0_ready),
        .up_cm_wdata_0(axi_mxfe_tx_xcvr_up_cm_0_wdata),
        .up_cm_wr_0(axi_mxfe_tx_xcvr_up_cm_0_wr),
        .up_cpll_rst_0(axi_mxfe_rx_xcvr_up_pll_rst),
        .up_cpll_rst_1(axi_mxfe_rx_xcvr_up_pll_rst),
        .up_cpll_rst_2(axi_mxfe_rx_xcvr_up_pll_rst),
        .up_cpll_rst_3(axi_mxfe_rx_xcvr_up_pll_rst),
        .up_es_addr_0(axi_mxfe_rx_xcvr_up_es_0_addr),
        .up_es_addr_1(axi_mxfe_rx_xcvr_up_es_1_addr),
        .up_es_addr_2(axi_mxfe_rx_xcvr_up_es_2_addr),
        .up_es_addr_3(axi_mxfe_rx_xcvr_up_es_3_addr),
        .up_es_enb_0(axi_mxfe_rx_xcvr_up_es_0_enb),
        .up_es_enb_1(axi_mxfe_rx_xcvr_up_es_1_enb),
        .up_es_enb_2(axi_mxfe_rx_xcvr_up_es_2_enb),
        .up_es_enb_3(axi_mxfe_rx_xcvr_up_es_3_enb),
        .up_es_rdata_0(axi_mxfe_rx_xcvr_up_es_0_rdata),
        .up_es_rdata_1(axi_mxfe_rx_xcvr_up_es_1_rdata),
        .up_es_rdata_2(axi_mxfe_rx_xcvr_up_es_2_rdata),
        .up_es_rdata_3(axi_mxfe_rx_xcvr_up_es_3_rdata),
        .up_es_ready_0(axi_mxfe_rx_xcvr_up_es_0_ready),
        .up_es_ready_1(axi_mxfe_rx_xcvr_up_es_1_ready),
        .up_es_ready_2(axi_mxfe_rx_xcvr_up_es_2_ready),
        .up_es_ready_3(axi_mxfe_rx_xcvr_up_es_3_ready),
        .up_es_reset_0(axi_mxfe_rx_xcvr_up_es_0_reset),
        .up_es_reset_1(axi_mxfe_rx_xcvr_up_es_1_reset),
        .up_es_reset_2(axi_mxfe_rx_xcvr_up_es_2_reset),
        .up_es_reset_3(axi_mxfe_rx_xcvr_up_es_3_reset),
        .up_es_wdata_0(axi_mxfe_rx_xcvr_up_es_0_wdata),
        .up_es_wdata_1(axi_mxfe_rx_xcvr_up_es_1_wdata),
        .up_es_wdata_2(axi_mxfe_rx_xcvr_up_es_2_wdata),
        .up_es_wdata_3(axi_mxfe_rx_xcvr_up_es_3_wdata),
        .up_es_wr_0(axi_mxfe_rx_xcvr_up_es_0_wr),
        .up_es_wr_1(axi_mxfe_rx_xcvr_up_es_1_wr),
        .up_es_wr_2(axi_mxfe_rx_xcvr_up_es_2_wr),
        .up_es_wr_3(axi_mxfe_rx_xcvr_up_es_3_wr),
        .up_qpll_rst_0(axi_mxfe_tx_xcvr_up_pll_rst),
        .up_rstn(sys_cpu_resetn),
        .up_rx_addr_0(axi_mxfe_rx_xcvr_up_ch_0_addr),
        .up_rx_addr_1(axi_mxfe_rx_xcvr_up_ch_1_addr),
        .up_rx_addr_2(axi_mxfe_rx_xcvr_up_ch_2_addr),
        .up_rx_addr_3(axi_mxfe_rx_xcvr_up_ch_3_addr),
        .up_rx_bufstatus_0(axi_mxfe_rx_xcvr_up_ch_0_bufstatus),
        .up_rx_bufstatus_1(axi_mxfe_rx_xcvr_up_ch_1_bufstatus),
        .up_rx_bufstatus_2(axi_mxfe_rx_xcvr_up_ch_2_bufstatus),
        .up_rx_bufstatus_3(axi_mxfe_rx_xcvr_up_ch_3_bufstatus),
        .up_rx_bufstatus_rst_0(axi_mxfe_rx_xcvr_up_ch_0_bufstatus_rst),
        .up_rx_bufstatus_rst_1(axi_mxfe_rx_xcvr_up_ch_1_bufstatus_rst),
        .up_rx_bufstatus_rst_2(axi_mxfe_rx_xcvr_up_ch_2_bufstatus_rst),
        .up_rx_bufstatus_rst_3(axi_mxfe_rx_xcvr_up_ch_3_bufstatus_rst),
        .up_rx_enb_0(axi_mxfe_rx_xcvr_up_ch_0_enb),
        .up_rx_enb_1(axi_mxfe_rx_xcvr_up_ch_1_enb),
        .up_rx_enb_2(axi_mxfe_rx_xcvr_up_ch_2_enb),
        .up_rx_enb_3(axi_mxfe_rx_xcvr_up_ch_3_enb),
        .up_rx_lpm_dfe_n_0(axi_mxfe_rx_xcvr_up_ch_0_lpm_dfe_n),
        .up_rx_lpm_dfe_n_1(axi_mxfe_rx_xcvr_up_ch_1_lpm_dfe_n),
        .up_rx_lpm_dfe_n_2(axi_mxfe_rx_xcvr_up_ch_2_lpm_dfe_n),
        .up_rx_lpm_dfe_n_3(axi_mxfe_rx_xcvr_up_ch_3_lpm_dfe_n),
        .up_rx_out_clk_sel_0(axi_mxfe_rx_xcvr_up_ch_0_out_clk_sel),
        .up_rx_out_clk_sel_1(axi_mxfe_rx_xcvr_up_ch_1_out_clk_sel),
        .up_rx_out_clk_sel_2(axi_mxfe_rx_xcvr_up_ch_2_out_clk_sel),
        .up_rx_out_clk_sel_3(axi_mxfe_rx_xcvr_up_ch_3_out_clk_sel),
        .up_rx_pll_locked_0(axi_mxfe_rx_xcvr_up_ch_0_pll_locked),
        .up_rx_pll_locked_1(axi_mxfe_rx_xcvr_up_ch_1_pll_locked),
        .up_rx_pll_locked_2(axi_mxfe_rx_xcvr_up_ch_2_pll_locked),
        .up_rx_pll_locked_3(axi_mxfe_rx_xcvr_up_ch_3_pll_locked),
        .up_rx_prbscntreset_0(axi_mxfe_rx_xcvr_up_ch_0_prbscntreset),
        .up_rx_prbscntreset_1(axi_mxfe_rx_xcvr_up_ch_1_prbscntreset),
        .up_rx_prbscntreset_2(axi_mxfe_rx_xcvr_up_ch_2_prbscntreset),
        .up_rx_prbscntreset_3(axi_mxfe_rx_xcvr_up_ch_3_prbscntreset),
        .up_rx_prbserr_0(axi_mxfe_rx_xcvr_up_ch_0_prbserr),
        .up_rx_prbserr_1(axi_mxfe_rx_xcvr_up_ch_1_prbserr),
        .up_rx_prbserr_2(axi_mxfe_rx_xcvr_up_ch_2_prbserr),
        .up_rx_prbserr_3(axi_mxfe_rx_xcvr_up_ch_3_prbserr),
        .up_rx_prbslocked_0(axi_mxfe_rx_xcvr_up_ch_0_prbslocked),
        .up_rx_prbslocked_1(axi_mxfe_rx_xcvr_up_ch_1_prbslocked),
        .up_rx_prbslocked_2(axi_mxfe_rx_xcvr_up_ch_2_prbslocked),
        .up_rx_prbslocked_3(axi_mxfe_rx_xcvr_up_ch_3_prbslocked),
        .up_rx_prbssel_0(axi_mxfe_rx_xcvr_up_ch_0_prbssel),
        .up_rx_prbssel_1(axi_mxfe_rx_xcvr_up_ch_1_prbssel),
        .up_rx_prbssel_2(axi_mxfe_rx_xcvr_up_ch_2_prbssel),
        .up_rx_prbssel_3(axi_mxfe_rx_xcvr_up_ch_3_prbssel),
        .up_rx_rate_0(axi_mxfe_rx_xcvr_up_ch_0_rate),
        .up_rx_rate_1(axi_mxfe_rx_xcvr_up_ch_1_rate),
        .up_rx_rate_2(axi_mxfe_rx_xcvr_up_ch_2_rate),
        .up_rx_rate_3(axi_mxfe_rx_xcvr_up_ch_3_rate),
        .up_rx_rdata_0(axi_mxfe_rx_xcvr_up_ch_0_rdata),
        .up_rx_rdata_1(axi_mxfe_rx_xcvr_up_ch_1_rdata),
        .up_rx_rdata_2(axi_mxfe_rx_xcvr_up_ch_2_rdata),
        .up_rx_rdata_3(axi_mxfe_rx_xcvr_up_ch_3_rdata),
        .up_rx_ready_0(axi_mxfe_rx_xcvr_up_ch_0_ready),
        .up_rx_ready_1(axi_mxfe_rx_xcvr_up_ch_1_ready),
        .up_rx_ready_2(axi_mxfe_rx_xcvr_up_ch_2_ready),
        .up_rx_ready_3(axi_mxfe_rx_xcvr_up_ch_3_ready),
        .up_rx_rst_0(axi_mxfe_rx_xcvr_up_ch_0_rst),
        .up_rx_rst_1(axi_mxfe_rx_xcvr_up_ch_1_rst),
        .up_rx_rst_2(axi_mxfe_rx_xcvr_up_ch_2_rst),
        .up_rx_rst_3(axi_mxfe_rx_xcvr_up_ch_3_rst),
        .up_rx_rst_done_0(axi_mxfe_rx_xcvr_up_ch_0_rst_done),
        .up_rx_rst_done_1(axi_mxfe_rx_xcvr_up_ch_1_rst_done),
        .up_rx_rst_done_2(axi_mxfe_rx_xcvr_up_ch_2_rst_done),
        .up_rx_rst_done_3(axi_mxfe_rx_xcvr_up_ch_3_rst_done),
        .up_rx_sys_clk_sel_0(axi_mxfe_rx_xcvr_up_ch_0_sys_clk_sel),
        .up_rx_sys_clk_sel_1(axi_mxfe_rx_xcvr_up_ch_1_sys_clk_sel),
        .up_rx_sys_clk_sel_2(axi_mxfe_rx_xcvr_up_ch_2_sys_clk_sel),
        .up_rx_sys_clk_sel_3(axi_mxfe_rx_xcvr_up_ch_3_sys_clk_sel),
        .up_rx_user_ready_0(axi_mxfe_rx_xcvr_up_ch_0_user_ready),
        .up_rx_user_ready_1(axi_mxfe_rx_xcvr_up_ch_1_user_ready),
        .up_rx_user_ready_2(axi_mxfe_rx_xcvr_up_ch_2_user_ready),
        .up_rx_user_ready_3(axi_mxfe_rx_xcvr_up_ch_3_user_ready),
        .up_rx_wdata_0(axi_mxfe_rx_xcvr_up_ch_0_wdata),
        .up_rx_wdata_1(axi_mxfe_rx_xcvr_up_ch_1_wdata),
        .up_rx_wdata_2(axi_mxfe_rx_xcvr_up_ch_2_wdata),
        .up_rx_wdata_3(axi_mxfe_rx_xcvr_up_ch_3_wdata),
        .up_rx_wr_0(axi_mxfe_rx_xcvr_up_ch_0_wr),
        .up_rx_wr_1(axi_mxfe_rx_xcvr_up_ch_1_wr),
        .up_rx_wr_2(axi_mxfe_rx_xcvr_up_ch_2_wr),
        .up_rx_wr_3(axi_mxfe_rx_xcvr_up_ch_3_wr),
        .up_tx_addr_0(axi_mxfe_tx_xcvr_up_ch_0_addr),
        .up_tx_addr_1(axi_mxfe_tx_xcvr_up_ch_1_addr),
        .up_tx_addr_2(axi_mxfe_tx_xcvr_up_ch_2_addr),
        .up_tx_addr_3(axi_mxfe_tx_xcvr_up_ch_3_addr),
        .up_tx_bufstatus_0(axi_mxfe_tx_xcvr_up_ch_0_bufstatus),
        .up_tx_bufstatus_1(axi_mxfe_tx_xcvr_up_ch_1_bufstatus),
        .up_tx_bufstatus_2(axi_mxfe_tx_xcvr_up_ch_2_bufstatus),
        .up_tx_bufstatus_3(axi_mxfe_tx_xcvr_up_ch_3_bufstatus),
        .up_tx_diffctrl_0(axi_mxfe_tx_xcvr_up_ch_0_tx_diffctrl),
        .up_tx_diffctrl_1(axi_mxfe_tx_xcvr_up_ch_1_tx_diffctrl),
        .up_tx_diffctrl_2(axi_mxfe_tx_xcvr_up_ch_2_tx_diffctrl),
        .up_tx_diffctrl_3(axi_mxfe_tx_xcvr_up_ch_3_tx_diffctrl),
        .up_tx_enb_0(axi_mxfe_tx_xcvr_up_ch_0_enb),
        .up_tx_enb_1(axi_mxfe_tx_xcvr_up_ch_1_enb),
        .up_tx_enb_2(axi_mxfe_tx_xcvr_up_ch_2_enb),
        .up_tx_enb_3(axi_mxfe_tx_xcvr_up_ch_3_enb),
        .up_tx_lpm_dfe_n_0(axi_mxfe_tx_xcvr_up_ch_0_lpm_dfe_n),
        .up_tx_lpm_dfe_n_1(axi_mxfe_tx_xcvr_up_ch_1_lpm_dfe_n),
        .up_tx_lpm_dfe_n_2(axi_mxfe_tx_xcvr_up_ch_2_lpm_dfe_n),
        .up_tx_lpm_dfe_n_3(axi_mxfe_tx_xcvr_up_ch_3_lpm_dfe_n),
        .up_tx_out_clk_sel_0(axi_mxfe_tx_xcvr_up_ch_0_out_clk_sel),
        .up_tx_out_clk_sel_1(axi_mxfe_tx_xcvr_up_ch_1_out_clk_sel),
        .up_tx_out_clk_sel_2(axi_mxfe_tx_xcvr_up_ch_2_out_clk_sel),
        .up_tx_out_clk_sel_3(axi_mxfe_tx_xcvr_up_ch_3_out_clk_sel),
        .up_tx_pll_locked_0(axi_mxfe_tx_xcvr_up_ch_0_pll_locked),
        .up_tx_pll_locked_1(axi_mxfe_tx_xcvr_up_ch_1_pll_locked),
        .up_tx_pll_locked_2(axi_mxfe_tx_xcvr_up_ch_2_pll_locked),
        .up_tx_pll_locked_3(axi_mxfe_tx_xcvr_up_ch_3_pll_locked),
        .up_tx_postcursor_0(axi_mxfe_tx_xcvr_up_ch_0_tx_postcursor),
        .up_tx_postcursor_1(axi_mxfe_tx_xcvr_up_ch_1_tx_postcursor),
        .up_tx_postcursor_2(axi_mxfe_tx_xcvr_up_ch_2_tx_postcursor),
        .up_tx_postcursor_3(axi_mxfe_tx_xcvr_up_ch_3_tx_postcursor),
        .up_tx_prbsforceerr_0(axi_mxfe_tx_xcvr_up_ch_0_prbsforceerr),
        .up_tx_prbsforceerr_1(axi_mxfe_tx_xcvr_up_ch_1_prbsforceerr),
        .up_tx_prbsforceerr_2(axi_mxfe_tx_xcvr_up_ch_2_prbsforceerr),
        .up_tx_prbsforceerr_3(axi_mxfe_tx_xcvr_up_ch_3_prbsforceerr),
        .up_tx_prbssel_0(axi_mxfe_tx_xcvr_up_ch_0_prbssel),
        .up_tx_prbssel_1(axi_mxfe_tx_xcvr_up_ch_1_prbssel),
        .up_tx_prbssel_2(axi_mxfe_tx_xcvr_up_ch_2_prbssel),
        .up_tx_prbssel_3(axi_mxfe_tx_xcvr_up_ch_3_prbssel),
        .up_tx_precursor_0(axi_mxfe_tx_xcvr_up_ch_0_tx_precursor),
        .up_tx_precursor_1(axi_mxfe_tx_xcvr_up_ch_1_tx_precursor),
        .up_tx_precursor_2(axi_mxfe_tx_xcvr_up_ch_2_tx_precursor),
        .up_tx_precursor_3(axi_mxfe_tx_xcvr_up_ch_3_tx_precursor),
        .up_tx_rate_0(axi_mxfe_tx_xcvr_up_ch_0_rate),
        .up_tx_rate_1(axi_mxfe_tx_xcvr_up_ch_1_rate),
        .up_tx_rate_2(axi_mxfe_tx_xcvr_up_ch_2_rate),
        .up_tx_rate_3(axi_mxfe_tx_xcvr_up_ch_3_rate),
        .up_tx_rdata_0(axi_mxfe_tx_xcvr_up_ch_0_rdata),
        .up_tx_rdata_1(axi_mxfe_tx_xcvr_up_ch_1_rdata),
        .up_tx_rdata_2(axi_mxfe_tx_xcvr_up_ch_2_rdata),
        .up_tx_rdata_3(axi_mxfe_tx_xcvr_up_ch_3_rdata),
        .up_tx_ready_0(axi_mxfe_tx_xcvr_up_ch_0_ready),
        .up_tx_ready_1(axi_mxfe_tx_xcvr_up_ch_1_ready),
        .up_tx_ready_2(axi_mxfe_tx_xcvr_up_ch_2_ready),
        .up_tx_ready_3(axi_mxfe_tx_xcvr_up_ch_3_ready),
        .up_tx_rst_0(axi_mxfe_tx_xcvr_up_ch_0_rst),
        .up_tx_rst_1(axi_mxfe_tx_xcvr_up_ch_1_rst),
        .up_tx_rst_2(axi_mxfe_tx_xcvr_up_ch_2_rst),
        .up_tx_rst_3(axi_mxfe_tx_xcvr_up_ch_3_rst),
        .up_tx_rst_done_0(axi_mxfe_tx_xcvr_up_ch_0_rst_done),
        .up_tx_rst_done_1(axi_mxfe_tx_xcvr_up_ch_1_rst_done),
        .up_tx_rst_done_2(axi_mxfe_tx_xcvr_up_ch_2_rst_done),
        .up_tx_rst_done_3(axi_mxfe_tx_xcvr_up_ch_3_rst_done),
        .up_tx_sys_clk_sel_0(axi_mxfe_tx_xcvr_up_ch_0_sys_clk_sel),
        .up_tx_sys_clk_sel_1(axi_mxfe_tx_xcvr_up_ch_1_sys_clk_sel),
        .up_tx_sys_clk_sel_2(axi_mxfe_tx_xcvr_up_ch_2_sys_clk_sel),
        .up_tx_sys_clk_sel_3(axi_mxfe_tx_xcvr_up_ch_3_sys_clk_sel),
        .up_tx_user_ready_0(axi_mxfe_tx_xcvr_up_ch_0_user_ready),
        .up_tx_user_ready_1(axi_mxfe_tx_xcvr_up_ch_1_user_ready),
        .up_tx_user_ready_2(axi_mxfe_tx_xcvr_up_ch_2_user_ready),
        .up_tx_user_ready_3(axi_mxfe_tx_xcvr_up_ch_3_user_ready),
        .up_tx_wdata_0(axi_mxfe_tx_xcvr_up_ch_0_wdata),
        .up_tx_wdata_1(axi_mxfe_tx_xcvr_up_ch_1_wdata),
        .up_tx_wdata_2(axi_mxfe_tx_xcvr_up_ch_2_wdata),
        .up_tx_wdata_3(axi_mxfe_tx_xcvr_up_ch_3_wdata),
        .up_tx_wr_0(axi_mxfe_tx_xcvr_up_ch_0_wr),
        .up_tx_wr_1(axi_mxfe_tx_xcvr_up_ch_1_wr),
        .up_tx_wr_2(axi_mxfe_tx_xcvr_up_ch_2_wr),
        .up_tx_wr_3(axi_mxfe_tx_xcvr_up_ch_3_wr));
endmodule

module tx_mxfe_tpl_core_imp_1CVF2G5
   (dac_data_0,
    dac_data_1,
    dac_data_2,
    dac_data_3,
    dac_dunf,
    dac_enable_0,
    dac_enable_1,
    dac_enable_2,
    dac_enable_3,
    dac_rst,
    dac_sync_manual_req_in,
    dac_sync_manual_req_out,
    dac_valid_0,
    dac_valid_1,
    dac_valid_2,
    dac_valid_3,
    ext_sync_in,
    link_clk,
    link_tdata,
    link_tready,
    link_tvalid,
    s_axi_aclk,
    s_axi_araddr,
    s_axi_aresetn,
    s_axi_arprot,
    s_axi_arready,
    s_axi_arvalid,
    s_axi_awaddr,
    s_axi_awprot,
    s_axi_awready,
    s_axi_awvalid,
    s_axi_bready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_rdata,
    s_axi_rready,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_wdata,
    s_axi_wready,
    s_axi_wstrb,
    s_axi_wvalid);
  input [127:0]dac_data_0;
  input [127:0]dac_data_1;
  input [127:0]dac_data_2;
  input [127:0]dac_data_3;
  input dac_dunf;
  output [0:0]dac_enable_0;
  output [0:0]dac_enable_1;
  output [0:0]dac_enable_2;
  output [0:0]dac_enable_3;
  output dac_rst;
  input dac_sync_manual_req_in;
  output dac_sync_manual_req_out;
  output [0:0]dac_valid_0;
  output [0:0]dac_valid_1;
  output [0:0]dac_valid_2;
  output [0:0]dac_valid_3;
  input ext_sync_in;
  input link_clk;
  output [383:0]link_tdata;
  input link_tready;
  output link_tvalid;
  input s_axi_aclk;
  input [12:0]s_axi_araddr;
  input s_axi_aresetn;
  input [2:0]s_axi_arprot;
  output s_axi_arready;
  input s_axi_arvalid;
  input [12:0]s_axi_awaddr;
  input [2:0]s_axi_awprot;
  output s_axi_awready;
  input s_axi_awvalid;
  input s_axi_bready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  output [31:0]s_axi_rdata;
  input s_axi_rready;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input [31:0]s_axi_wdata;
  output s_axi_wready;
  input [3:0]s_axi_wstrb;
  input s_axi_wvalid;

  wire [127:0]dac_data_0_1;
  wire [127:0]dac_data_1_1;
  wire [127:0]dac_data_2_1;
  wire [127:0]dac_data_3_1;
  wire dac_dunf_1;
  wire dac_sync_manual_req_in_1;
  wire dac_tpl_core_dac_rst;
  wire dac_tpl_core_dac_sync_manual_req_out;
  wire [3:0]dac_tpl_core_dac_valid;
  wire [3:0]dac_tpl_core_enable;
  wire [383:0]dac_tpl_core_link_TDATA;
  wire dac_tpl_core_link_TREADY;
  wire dac_tpl_core_link_TVALID;
  wire [511:0]data_concat0_dout;
  wire [0:0]enable_slice_0_Dout;
  wire [0:0]enable_slice_1_Dout;
  wire [0:0]enable_slice_2_Dout;
  wire [0:0]enable_slice_3_Dout;
  wire ext_sync_in_1;
  wire link_clk_1;
  wire [12:0]s_axi_1_ARADDR;
  wire [2:0]s_axi_1_ARPROT;
  wire s_axi_1_ARREADY;
  wire s_axi_1_ARVALID;
  wire [12:0]s_axi_1_AWADDR;
  wire [2:0]s_axi_1_AWPROT;
  wire s_axi_1_AWREADY;
  wire s_axi_1_AWVALID;
  wire s_axi_1_BREADY;
  wire [1:0]s_axi_1_BRESP;
  wire s_axi_1_BVALID;
  wire [31:0]s_axi_1_RDATA;
  wire s_axi_1_RREADY;
  wire [1:0]s_axi_1_RRESP;
  wire s_axi_1_RVALID;
  wire [31:0]s_axi_1_WDATA;
  wire s_axi_1_WREADY;
  wire [3:0]s_axi_1_WSTRB;
  wire s_axi_1_WVALID;
  wire s_axi_aclk_1;
  wire s_axi_aresetn_1;
  wire [0:0]valid_slice_0_Dout;
  wire [0:0]valid_slice_1_Dout;
  wire [0:0]valid_slice_2_Dout;
  wire [0:0]valid_slice_3_Dout;

  assign dac_data_0_1 = dac_data_0[127:0];
  assign dac_data_1_1 = dac_data_1[127:0];
  assign dac_data_2_1 = dac_data_2[127:0];
  assign dac_data_3_1 = dac_data_3[127:0];
  assign dac_dunf_1 = dac_dunf;
  assign dac_enable_0[0] = enable_slice_0_Dout;
  assign dac_enable_1[0] = enable_slice_1_Dout;
  assign dac_enable_2[0] = enable_slice_2_Dout;
  assign dac_enable_3[0] = enable_slice_3_Dout;
  assign dac_rst = dac_tpl_core_dac_rst;
  assign dac_sync_manual_req_in_1 = dac_sync_manual_req_in;
  assign dac_sync_manual_req_out = dac_tpl_core_dac_sync_manual_req_out;
  assign dac_tpl_core_link_TREADY = link_tready;
  assign dac_valid_0[0] = valid_slice_0_Dout;
  assign dac_valid_1[0] = valid_slice_1_Dout;
  assign dac_valid_2[0] = valid_slice_2_Dout;
  assign dac_valid_3[0] = valid_slice_3_Dout;
  assign ext_sync_in_1 = ext_sync_in;
  assign link_clk_1 = link_clk;
  assign link_tdata[383:0] = dac_tpl_core_link_TDATA;
  assign link_tvalid = dac_tpl_core_link_TVALID;
  assign s_axi_1_ARADDR = s_axi_araddr[12:0];
  assign s_axi_1_ARPROT = s_axi_arprot[2:0];
  assign s_axi_1_ARVALID = s_axi_arvalid;
  assign s_axi_1_AWADDR = s_axi_awaddr[12:0];
  assign s_axi_1_AWPROT = s_axi_awprot[2:0];
  assign s_axi_1_AWVALID = s_axi_awvalid;
  assign s_axi_1_BREADY = s_axi_bready;
  assign s_axi_1_RREADY = s_axi_rready;
  assign s_axi_1_WDATA = s_axi_wdata[31:0];
  assign s_axi_1_WSTRB = s_axi_wstrb[3:0];
  assign s_axi_1_WVALID = s_axi_wvalid;
  assign s_axi_aclk_1 = s_axi_aclk;
  assign s_axi_aresetn_1 = s_axi_aresetn;
  assign s_axi_arready = s_axi_1_ARREADY;
  assign s_axi_awready = s_axi_1_AWREADY;
  assign s_axi_bresp[1:0] = s_axi_1_BRESP;
  assign s_axi_bvalid = s_axi_1_BVALID;
  assign s_axi_rdata[31:0] = s_axi_1_RDATA;
  assign s_axi_rresp[1:0] = s_axi_1_RRESP;
  assign s_axi_rvalid = s_axi_1_RVALID;
  assign s_axi_wready = s_axi_1_WREADY;
  test_harness_dac_tpl_core_0 dac_tpl_core
       (.dac_ddata(data_concat0_dout),
        .dac_dunf(dac_dunf_1),
        .dac_rst(dac_tpl_core_dac_rst),
        .dac_sync_in(ext_sync_in_1),
        .dac_sync_manual_req_in(dac_sync_manual_req_in_1),
        .dac_sync_manual_req_out(dac_tpl_core_dac_sync_manual_req_out),
        .dac_valid(dac_tpl_core_dac_valid),
        .enable(dac_tpl_core_enable),
        .link_clk(link_clk_1),
        .link_data(dac_tpl_core_link_TDATA),
        .link_ready(dac_tpl_core_link_TREADY),
        .link_valid(dac_tpl_core_link_TVALID),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(s_axi_1_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_arprot(s_axi_1_ARPROT),
        .s_axi_arready(s_axi_1_ARREADY),
        .s_axi_arvalid(s_axi_1_ARVALID),
        .s_axi_awaddr(s_axi_1_AWADDR),
        .s_axi_awprot(s_axi_1_AWPROT),
        .s_axi_awready(s_axi_1_AWREADY),
        .s_axi_awvalid(s_axi_1_AWVALID),
        .s_axi_bready(s_axi_1_BREADY),
        .s_axi_bresp(s_axi_1_BRESP),
        .s_axi_bvalid(s_axi_1_BVALID),
        .s_axi_rdata(s_axi_1_RDATA),
        .s_axi_rready(s_axi_1_RREADY),
        .s_axi_rresp(s_axi_1_RRESP),
        .s_axi_rvalid(s_axi_1_RVALID),
        .s_axi_wdata(s_axi_1_WDATA),
        .s_axi_wready(s_axi_1_WREADY),
        .s_axi_wstrb(s_axi_1_WSTRB),
        .s_axi_wvalid(s_axi_1_WVALID));
  test_harness_data_concat0_0 data_concat0
       (.In0(dac_data_0_1),
        .In1(dac_data_1_1),
        .In2(dac_data_2_1),
        .In3(dac_data_3_1),
        .dout(data_concat0_dout));
  test_harness_enable_slice_0_1 enable_slice_0
       (.Din(dac_tpl_core_enable),
        .Dout(enable_slice_0_Dout));
  test_harness_enable_slice_1_1 enable_slice_1
       (.Din(dac_tpl_core_enable),
        .Dout(enable_slice_1_Dout));
  test_harness_enable_slice_2_1 enable_slice_2
       (.Din(dac_tpl_core_enable),
        .Dout(enable_slice_2_Dout));
  test_harness_enable_slice_3_1 enable_slice_3
       (.Din(dac_tpl_core_enable),
        .Dout(enable_slice_3_Dout));
  test_harness_valid_slice_0_1 valid_slice_0
       (.Din(dac_tpl_core_dac_valid),
        .Dout(valid_slice_0_Dout));
  test_harness_valid_slice_1_1 valid_slice_1
       (.Din(dac_tpl_core_dac_valid),
        .Dout(valid_slice_1_Dout));
  test_harness_valid_slice_2_1 valid_slice_2
       (.Din(dac_tpl_core_dac_valid),
        .Dout(valid_slice_2_Dout));
  test_harness_valid_slice_3_1 valid_slice_3
       (.Din(dac_tpl_core_dac_valid),
        .Dout(valid_slice_3_Dout));
endmodule
