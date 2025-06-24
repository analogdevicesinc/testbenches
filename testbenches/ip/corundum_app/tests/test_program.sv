// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024 - 2025 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsabilities that he or she has by using this source/core.
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
`include "axi_definitions.svh"
`include "axis_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import adi_axis_agent_pkg::*;
import m_axis_sequencer_pkg::*;
import axi4stream_vip_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, jesd_tx_axis)::*;
import `PKGIFY(test_harness, jesd_rx_axis)::*;
import `PKGIFY(test_harness, os_tx_axis)::*;
import `PKGIFY(test_harness, os_rx_axis)::*;

program test_program();

  // declare the class instances
  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  adi_axis_master_agent #(`AXIS_VIP_PARAMS(test_harness, jesd_tx_axis)) jesd_tx_axis_agent;
  adi_axis_slave_agent #(`AXIS_VIP_PARAMS(test_harness, jesd_rx_axis)) jesd_rx_axis_agent;

  adi_axis_master_agent #(`AXIS_VIP_PARAMS(test_harness, os_tx_axis)) os_tx_axis_agent;
  adi_axis_slave_agent #(`AXIS_VIP_PARAMS(test_harness, os_rx_axis)) os_rx_axis_agent;

  logic [63:0] total_bits = 'd0;
  logic [63:0] error_bits_total = 'd0;
  logic [31:0] out_of_sync_total = 'd0;

  initial begin

    // create environment
    base_env = new("Base Environment",
      `TH.`SYS_CLK.inst.IF,
      `TH.`DMA_CLK.inst.IF,
      `TH.`DDR_CLK.inst.IF,
      `TH.`SYS_RST.inst.IF);

    mng = new("", `TH.`MNG_AXI.inst.IF);
    ddr = new("", `TH.`DDR_AXI.inst.IF);

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    jesd_tx_axis_agent = new("", `TH.`JESD_TX_AXIS.inst.IF);
    jesd_rx_axis_agent = new("", `TH.`JESD_RX_AXIS.inst.IF);
    os_tx_axis_agent = new("", `TH.`OS_TX_AXIS.inst.IF);
    os_rx_axis_agent = new("", `TH.`OS_RX_AXIS.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    `TH.`CORUNDUM_CLK_VIP.inst.IF.start_clock();
    `TH.`INPUT_CLK_VIP.inst.IF.start_clock();

    base_env.start();
    jesd_tx_axis_agent.agent.start_master();
    jesd_rx_axis_agent.agent.start_slave();
    os_tx_axis_agent.agent.start_master();
    os_rx_axis_agent.agent.start_slave();
    base_env.sys_reset();

    jesd_tx_axis_agent.master_sequencer.set_descriptor_gen_mode(1);
    jesd_tx_axis_agent.master_sequencer.set_stop_policy(STOP_POLICY_PACKET);
    jesd_tx_axis_agent.master_sequencer.add_xfer_descriptor_sample_count(32'd12288/jesd_tx_axis_agent.agent.C_XIL_AXI4STREAM_DATA_WIDTH, 0, 0);

    os_tx_axis_agent.master_sequencer.set_descriptor_gen_mode(1);
    os_tx_axis_agent.master_sequencer.set_stop_policy(STOP_POLICY_PACKET);
    os_tx_axis_agent.master_sequencer.add_xfer_descriptor_sample_count(32'd24, 1, 0);
    os_tx_axis_agent.master_sequencer.set_descriptor_delay(32'd48);

    jesd_rx_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
    os_rx_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

    // Start the ADC/DAC stubs
    `INFO(("Start the sequencer"), ADI_VERBOSITY_LOW);
    jesd_tx_axis_agent.master_sequencer.start();
    os_tx_axis_agent.master_sequencer.start();
    jesd_rx_axis_agent.slave_sequencer.start();
    os_rx_axis_agent.slave_sequencer.start();

    // base_env.mng.master_sequencer.RegWrite32('h50000000+'h6*4, 32'd1024);
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h24*4, 32'd64);

    // Start-stop
    for (int i=0; i<8; i++) begin
      `TH.`EN_IO.inst.IF.set_io(8'hFF >> i);

      base_env.mng.master_sequencer.RegWrite32('h50000000+'h24*4, 32'd64 * int'(8/(8-i)));
      if (8'hFF >> i == 8'h03)
        base_env.mng.master_sequencer.RegWrite32('h50000000+'h24*4, 32'd16);

      base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h1);
      #2us;
      base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h0);
      #2us;
    end

    for (int i=0; i<8; i++) begin
      `TH.`EN_IO.inst.IF.set_io(8'h80 >> i);

      base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h1);
      #2us;
      base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h0);
      #2us;
    end

    os_tx_axis_agent.master_sequencer.stop();
    #2us;

    // `TH.`EN_IO.inst.IF.set_io(8'hFF);
    // base_env.mng.master_sequencer.RegWrite32('h50000000+'h24*4, 32'd128);
    `TH.`EN_IO.inst.IF.set_io(8'h11);
    // base_env.mng.master_sequencer.RegWrite32('h50000000+'h24*4, 32'd2048);
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h24*4, 32'd1792);

    // --- 1s packet counter testing ---
    // start transmission
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h1);
    #2us;

    // start counter
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h2*4, 32'h1);
    #10us;

    // stop transmission
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h0);
    #2us;

    // restart transmission to check if counter is reset
    // start counter
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h2*4, 32'h1);

    base_env.mng.master_sequencer.RegWrite32('h50000000+'h16*4, {8'd127, 8'd0, 8'd0, 8'd1});
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h17*4, {8'd127, 8'd0, 8'd0, 8'd1});

    // --- BER testing ---
    // reset and start BER
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h1D*4, 32'h1);
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h1C*4, 32'h1);
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h1);
    #10us;
    // 3 bit error insertion
    repeat (3) begin
      base_env.mng.master_sequencer.RegWrite32('h50000000+'h23*4, 32'h1);
    end
    #10us;
    @(posedge `TH.application_core.direct_tx_clk);
    repeat (5) begin
      force `TH.application_core.s_axis_direct_rx_tready = 'h0;
      force `TH.application_core.s_axis_direct_rx_tvalid = 'h0;
      repeat (3) begin
        @(posedge `TH.application_core.direct_tx_clk);
      end
      release `TH.application_core.s_axis_direct_rx_tready;
      release `TH.application_core.s_axis_direct_rx_tvalid;
      repeat (3) begin
        @(posedge `TH.application_core.direct_tx_clk);
      end
    end
    #10us;
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h0);

    // read BER registers
    base_env.mng.master_sequencer.RegRead32('h50000000+'h1E*4, total_bits[63:32]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h1F*4, total_bits[31:0]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h20*4, error_bits_total[63:32]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h21*4, error_bits_total[31:0]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h22*4, out_of_sync_total);

    // start-stop BER
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h1);
    #10us;
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h0);

    // read BER registers
    base_env.mng.master_sequencer.RegRead32('h50000000+'h1E*4, total_bits[63:32]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h1F*4, total_bits[31:0]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h20*4, error_bits_total[63:32]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h21*4, error_bits_total[31:0]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h22*4, out_of_sync_total);

    // forced errors BER
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h1);
    #10us;
    force `TH.application_core.s_axis_direct_rx_tdata = 'h0;
    #10us;
    release `TH.application_core.s_axis_direct_rx_tdata;
    #10us;
    base_env.mng.master_sequencer.RegWrite32('h50000000+'h5*4, 32'h0);

    // read BER registers
    base_env.mng.master_sequencer.RegRead32('h50000000+'h1E*4, total_bits[63:32]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h1F*4, total_bits[31:0]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h20*4, error_bits_total[63:32]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h21*4, error_bits_total[31:0]);
    base_env.mng.master_sequencer.RegRead32('h50000000+'h22*4, out_of_sync_total);

    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
