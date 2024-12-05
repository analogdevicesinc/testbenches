// ***************************************************************************
// ***************************************************************************
// Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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

import environment_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_dmac_pkg::*;
import dmac_api_pkg::*;
import dma_trans_pkg::*;

program test_program;

  environment env;
  // Register accessors
  dmac_api m_dmac_api;
  dmac_api s_dmac_api;

  int frame_count;
  int has_sfsync;
  int has_dfsync;
  int sync_gen_en;

  initial begin
    //creating environment
    env = new("DMA Flock environment",
              `TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF,
              `TH.`SRC_AXIS.inst.IF,
              `TH.`DST_AXIS.inst.IF
    );

    #2ps;

    has_sfsync = `M_DMA_CFG_USE_EXT_SYNC;
    has_dfsync = `S_DMA_CFG_USE_EXT_SYNC;

    setLoggerVerbosity(ADI_VERBOSITY_NONE);
    env.start();
    start_clocks();
    env.sys_reset();
    env.run();

    m_dmac_api = new("TX_DMA_BA", env.mng, `TX_DMA_BA);
    m_dmac_api.probe();

    s_dmac_api = new("RX_DMA_BA", env.mng, `RX_DMA_BA);
    s_dmac_api.probe();

    sanity_test;

    // Test synchronous (reader and writer at the same speed)
    singleTest(
      .frame_num(10),
      .flock_framenum(3),
      .flock_distance(0),
      .src_clk(250000000),
      .dst_clk(250000000)
    );

    // Test repeating (reader faster than writer)
    singleTest(
      .frame_num(5),
      .flock_framenum(3),
      .flock_distance(0),
      .src_clk( 50000000),
      .dst_clk(250000000)
    );

    // Test skipping (writer faster than reader)
    singleTest(
      .frame_num(10),
      .flock_framenum(3),
      .flock_distance(0),
      .src_clk(250000000),
      .dst_clk( 50000000)
    );

    stop_clocks();
    env.stop();

    `INFO(("Testbench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task singleTest(
    input int frame_num = 10,
    input int flock_framenum = 3,
    input int flock_distance = 1,
    input int src_clk = 250000000,
    input int dst_clk = 250000000
  );
    dma_flocked_2d_segment m_seg, s_seg;
    int m_tid, s_tid;
    automatic int rand_succ = 0;

    axi4stream_ready_gen tready_gen;
    axi_ready_gen  wready_gen;

    // Set no backpressure from AXIS destination
    env.dst_axis_seq.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
    env.dst_axis_seq.user_gen_tready();

    // Set no backpressure from DDR
    wready_gen = env.ddr_axi_agent.wr_driver.create_ready("wready");
    wready_gen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    env.ddr_axi_agent.wr_driver.send_wready(wready_gen);

    m_seg = new(m_dmac_api.p);
    rand_succ = m_seg.randomize() with { dst_addr == 0;
                                         length == 1024;
                                         ylength == 8;
                                         dst_stride == length; };
    if (rand_succ == 0) `FATAL(("randomization failed"));

    m_seg.flock_framenum = flock_framenum;
    m_seg.flock_distance = flock_distance;
    m_seg.flock_mode = 0;
    m_seg.flock_wait_writer = 1;

    s_seg = m_seg.toSlaveSeg();

    env.src_axis_seq.set_stop_policy(m_axis_sequencer_pkg::STOP_POLICY_DESCRIPTOR_QUEUE);
    env.src_axis_seq.set_data_gen_mode(m_axis_sequencer_pkg::DATA_GEN_MODE_TEST_DATA);
    env.src_axis_seq.start();

    m_dmac_api.set_control('b1001);
    m_dmac_api.set_flags('b111);

    s_dmac_api.set_control('b1001);
    s_dmac_api.set_flags('b111);

    // Submit transfers to DMACs
    m_dmac_api.submit_transfer(m_seg, m_tid);
    s_dmac_api.submit_transfer(s_seg, s_tid);

    // Set clock generators
    set_src_clock(src_clk);
    set_dst_clock(dst_clk);

    sync_gen_en = 1;
    fork
      // Generate external sync and data for SRC
      begin
        for (int i = 0; i < frame_num; i++) begin
          if (sync_gen_en) begin
            fork
              gen_src_fsync(.clk_period(src_clk),
                            .bytes_to_transfer(m_seg.get_bytes_in_transfer));
              // Generate data
              begin
                for (int l = 0; l < m_seg.ylength; l++) begin
                  // update the AXIS generator command
                  env.src_axis_seq.add_xfer_descriptor(.bytes_to_generate(m_seg.length),
                                                       .gen_last(1),
                                                       .gen_sync(l==0));
                end

                // update the AXIS generator data
                for (int j = 0; j < m_seg.get_bytes_in_transfer; j++) begin
                  // ADI DMA frames start from offset 0x00
                  env.src_axis_seq.push_byte_for_stream(frame_count);
                end
              end
            join
            frame_count++;
          end
        end
      end

      // Generate external syncs for DEST
      begin
        while (sync_gen_en) begin
            gen_dst_fsync(.clk_period(dst_clk),
                          .bytes_to_transfer(m_seg.get_bytes_in_transfer));
        end
        #10ns;
      end
    join_any
    sync_gen_en = 0;

    // Stop triggers wait stop policy
    env.src_axis_seq.stop();

    // Shutdown DMACs
    m_dmac_api.disable_dma();
    s_dmac_api.disable_dma();

  endtask

  // This is a simple reg test to check the register access API
  task sanity_test();
    xil_axi_ulong mtestWADDR; // Write ADDR

    bit [63:0]    mtestWData; // Write Data
    bit [31:0]    rdData;

    env.mng.RegReadVerify32(`TX_DMA_BA + GetAddrs(DMAC_IDENTIFICATION), 'h44_4D_41_43);

    mtestWData = 0;
    repeat (10) begin
      env.mng.RegWrite32(`TX_DMA_BA + GetAddrs(DMAC_SCRATCH), mtestWData);
      env.mng.RegReadVerify32(`TX_DMA_BA + GetAddrs(DMAC_SCRATCH), mtestWData);
      mtestWData += 4;
    end

    env.mng.RegReadVerify32(`RX_DMA_BA + GetAddrs(DMAC_IDENTIFICATION), 'h44_4D_41_43);

  endtask

  // Set the writer AXIS side clock frequency
  task set_src_clock(input int freq);
    `TH.`SRC_CLK.inst.IF.set_clk_frq(.user_frequency(freq));
  endtask

  // Set the reader AXIS side clock frequency
  task set_dst_clock(input int freq);
    `TH.`DST_CLK.inst.IF.set_clk_frq(.user_frequency(freq));
  endtask

  // Set the MM AXI side DDR clock frequency
  task set_ddr_clock(input int freq);
    `TH.`DDR_CLK.inst.IF.set_clk_frq(.user_frequency(freq));
  endtask

  // Start all clocks
  task start_clocks();
     set_src_clock(100000000);
     set_dst_clock(100000000);
     set_ddr_clock(600000000);

    `TH.`SRC_CLK.inst.IF.start_clock;
    `TH.`DST_CLK.inst.IF.start_clock;
    #100ns;
  endtask

  // Stop all clocks
  task stop_clocks();
    `TH.`SRC_CLK.inst.IF.stop_clock;
    `TH.`DST_CLK.inst.IF.stop_clock;
  endtask

  // Assert external sync for one clock cycle
  task assert_writer_ext_sync();
  `ifdef SRC_SYNC_IO
    `TH.`SRC_SYNC_IO.inst.IF.setw_io(1);
    `TH.`SRC_SYNC_IO.inst.IF.setw_io(0);
  `endif
  endtask

  // Assert external sync for one clock cycle
  task assert_reader_ext_sync();
  `ifdef DST_SYNC_IO
    `TH.`DST_SYNC_IO.inst.IF.setw_io(1);
    `TH.`DST_SYNC_IO.inst.IF.setw_io(0);
  `endif
  endtask

  // Generate external sync pulse for input frames
  task gen_src_fsync(input int clk_period, input int bytes_to_transfer);
    real incycles,fperiod;
    if (has_sfsync) begin
      assert_writer_ext_sync();
    end
    // Calculate and wait one input frame duration plus a margin
    incycles = bytes_to_transfer / `SRC_AXIS_VIP_CFG_TDATA_NUM_BYTES * 1.5;
    fperiod = (incycles*1000000000)/ clk_period;
    #(fperiod*1ns);
  endtask

  // Generate external sync pulse for output frames
  task gen_dst_fsync(input int clk_period, input int bytes_to_transfer);
    real incycles,fperiod;
    if (has_dfsync) begin
      assert_reader_ext_sync();
    end
    // Calculate and wait one output frame duration plus a margin
    incycles = bytes_to_transfer / `DST_AXIS_VIP_CFG_TDATA_NUM_BYTES * 1.5;
    fperiod = (incycles*1000000000)/ clk_period;
    #(fperiod*1ns);
  endtask

endprogram
