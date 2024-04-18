// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2024 (c) Analog Devices, Inc. All rights reserved.
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

program test_program_frame_delay;

  environment env;
  // Register accessors
  dmac_api m_dmac_api;
  dmac_api s_dmac_api;

  int frame_count;
  int max_frames;
  int has_sfsync;
  int has_dfsync;
  int has_sautorun;
  int has_dautorun;
  int sync_gen_en;

  initial begin
    //creating environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF,
              `ifdef HAS_XIL_VDMA
              `TH.`REF_SRC_AXIS.inst.IF,
              `TH.`REF_DST_AXIS.inst.IF,
              `endif
              `TH.`SRC_AXIS.inst.IF,
              `TH.`DST_AXIS.inst.IF
    );

    #2ps;

    max_frames = `M_DMA_CFG_MAX_NUM_FRAMES;
    has_sfsync = `M_DMA_CFG_USE_EXT_SYNC;
    has_dfsync = `S_DMA_CFG_USE_EXT_SYNC;
    has_sautorun = `S_DMA_CFG_AUTORUN;
    has_dautorun = `M_DMA_CFG_AUTORUN;

    setLoggerVerbosity(6);
    env.start();
    env.run();

    m_dmac_api = new("TX_DMA_BA", env.mng, `TX_DMA_BA);
    m_dmac_api.probe();

    s_dmac_api = new("RX_DMA_BA", env.mng, `RX_DMA_BA);
    s_dmac_api.probe();


    if (has_sautorun + has_dautorun == 0) begin
      sanity_test;
    end

    start_clocks();
    sys_reset();

    // Test non-autorun mode
    if (has_sautorun + has_dautorun == 0) begin
      singleTest(
        .frame_num(10),
        .flock_framenum(3),
        .flock_distance(1),
        .src_clk(250000000),
        .dst_clk(250000000)
      );

      singleTest(
        .frame_num(10),
        .flock_framenum(5),
        .flock_distance(3),
        .src_clk(250000000),
        .dst_clk(250000000)
      );

      singleTest(
        .frame_num(10),
        .flock_framenum(8),
        .flock_distance(7),
        .src_clk(250000000),
        .dst_clk(250000000)
      );
    end

    // Test autorun mode
    if (has_sautorun + has_dautorun == 2) begin
      int autorun_flock_framenum;
      int autorun_flock_distance;

      // Get parameters
      autorun_flock_framenum =  `TH.`DUT_RX_DMA.inst.AUTORUN_FRAMELOCK_CONFIG & 'hFF;
      autorun_flock_distance = (((`TH.`DUT_RX_DMA.inst.AUTORUN_FRAMELOCK_CONFIG) >> 16) & 'hFF) + 1;
      singleTest(
        .frame_num(10),
        .flock_framenum(autorun_flock_framenum),
        .flock_distance(autorun_flock_distance),
        .src_clk(250000000),
        .dst_clk(250000000),
        .has_autorun(1)
      );
    end
    if (has_sautorun + has_dautorun == 1) begin
      `ERROR(("Both DMACs must be set in autorun mode."));
    end

    stop_clocks();

    $display("Testbench done!");
    $finish();

  end

  task singleTest(
    int frame_num = 10,
    int flock_framenum = 3,
    int flock_distance = 1,
    int src_clk = 250000000,
    int dst_clk = 250000000,
    int has_autorun = 0
  );
    dma_flocked_2d_segment m_seg, s_seg;
    int m_tid, s_tid;
    int rand_succ = 0;
    int x_length, y_length, baseaddress;

    axi4stream_ready_gen tready_gen;
    axi_ready_gen  wready_gen;

    // Set no backpressure from AXIS destination
    env.dst_axis_seq.user_gen_tready();
    `ifdef HAS_XIL_VDMA
    env.ref_dst_axis_seq.agent.driver.send_tready(tready_gen);
    `endif

    // Set no backpressure from DDR
    wready_gen = env.ddr_axi_agent.wr_driver.create_ready("wready");
    wready_gen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    env.ddr_axi_agent.wr_driver.send_wready(wready_gen);

    m_seg = new(m_dmac_api.p);

    baseaddress = 0;
    x_length = 1024;
    y_length = 8;
    if (has_autorun) begin
      // Get parameters
      baseaddress = `TH.`DUT_TX_DMA.inst.AUTORUN_DEST_ADDR;
      x_length = (`TH.`DUT_TX_DMA.inst.AUTORUN_X_LENGTH) + 1;
      y_length = (`TH.`DUT_TX_DMA.inst.AUTORUN_Y_LENGTH) + 1;
    end

    rand_succ = m_seg.randomize() with { dst_addr == baseaddress;
                                         length == x_length;
                                         ylength == y_length;
                                         dst_stride == length; };
    if (rand_succ == 0) `ERROR(("randomization failed"));

    m_seg.flock_framenum = flock_framenum;
    m_seg.flock_distance = flock_distance;
    m_seg.flock_mode = 1;
    m_seg.flock_wait_writer = 1;

    s_seg = m_seg.toSlaveSeg();

    env.src_axis_seq.set_stop_policy(m_axis_sequencer_pkg::STOP_POLICY_DESCRIPTOR_QUEUE);
    env.src_axis_seq.set_data_gen_mode(m_axis_sequencer_pkg::DATA_GEN_MODE_TEST_DATA);
    env.src_axis_seq.start();
    `ifdef HAS_XIL_VDMA
    env.ref_src_axis_seq.set_data_gen_mode(m_axis_sequencer_pkg::DATA_GEN_MODE_TEST_DATA);
    env.ref_src_axis_seq.start();
    `endif

    if (has_autorun == 0) begin
      m_dmac_api.enable_dma();
      m_dmac_api.set_flags('b1111);

      s_dmac_api.enable_dma();
      s_dmac_api.set_flags('b1111);
    end

    `ifdef HAS_XIL_VDMA
    // Config S2MM
    //This enables run/stop, Circular_Park, GenlockEn, and GenlockSrc.
    env.mng.RegWrite32(`VDMA_BA + 'h30, 'h8b);
    //Set S2MM_Start_Address1 .. S2MM_Start_Address8
    for (int i=0;i<8;i++) begin
      env.mng.RegWrite32(`VDMA_BA + 'hAC+i*4, 'h80000000+i*'h01000000);
    end
    //Set S2MM_FRMDLY_STRIDE
    env.mng.RegWrite32(`VDMA_BA + 'hA8, m_seg.length | (flock_distance << 24));
    //Set S2MM_HSIZE
    env.mng.RegWrite32(`VDMA_BA + 'hA4, m_seg.length);
    //Set S2MM_VSIZE
    env.mng.RegWrite32(`VDMA_BA + 'hA0, m_seg.ylength);

    // Config MM2S
    //This enables run/stop, Circular_Park, GenlockEn, and GenlockSrc
    env.mng.RegWrite32(`VDMA_BA + 'h00, 'h8b);
    //Set MM2S_Start_Address1 .. MM2S_Start_Address8
    for (int i=0;i<8;i++) begin
      env.mng.RegWrite32(`VDMA_BA + 'h5C+i*4, 'h80000000+i*'h01000000);
    end
    //Set MM2S_FRMDLY_STRIDE
    env.mng.RegWrite32(`VDMA_BA + 'h58, m_seg.length | (flock_distance << 24));
    //Set MM2S_HSIZE
    env.mng.RegWrite32(`VDMA_BA + 'h54, m_seg.length);
    //Set MM2S_VSIZE
    env.mng.RegWrite32(`VDMA_BA + 'h50, m_seg.ylength);
    `endif

    // Submit transfers to DMACs
    if (has_autorun == 0) begin
      m_dmac_api.submit_transfer(m_seg, m_tid);
      s_dmac_api.submit_transfer(s_seg, s_tid);
    end

    // Set clock generators
    set_src_clock(src_clk);
    set_dst_clock(dst_clk);

    sync_gen_en = 1;
    fork
      // Generate external sync and data for SRC
      begin
        #0.5us;
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
                  `ifdef HAS_XIL_VDMA
                  env.ref_src_axis_seq.add_xfer_descriptor(.bytes_to_generate(m_seg.length),
                                                           .gen_last(1),
                                                           .gen_sync(l==0));
                  `endif
                end

                // update the AXIS generator data
                for (int j = 0; j < m_seg.get_bytes_in_transfer; j++) begin
                  // ADI DMA frames start from offset 0x00
                  env.src_axis_seq.push_byte_for_stream(frame_count);
                  `ifdef HAS_XIL_VDMA
                  // VDMA frames start from offset 0x80
                  env.ref_src_axis_seq.push_byte_for_stream(frame_count+'h80);
                  `endif
                end
              end
            join
            frame_count++;
          end
        end
      end

      // Generate external syncs for DEST
      begin
        for (int i=0; i<frame_num; i++) begin
          if (sync_gen_en) begin
            gen_dst_fsync(.clk_period(dst_clk),
                          .bytes_to_transfer(m_seg.get_bytes_in_transfer));
          end
        end
        #10;
      end
    join
    sync_gen_en = 0;

    // Stop triggers wait stop policy
    env.src_axis_seq.stop();
    `ifdef HAS_XIL_VDMA
    env.ref_src_axis_seq.stop();
    `endif

    // Shutdown DMACs
    m_dmac_api.disable_dma();
    s_dmac_api.disable_dma();

  endtask

  // This is a simple reg test to check the register access API
  task sanity_test;
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
  task set_src_clock(int freq);
    `TH.`SRC_CLK.inst.IF.set_clk_frq(.user_frequency(freq));
  endtask

  // Set the reader AXIS side clock frequency
  task set_dst_clock(int freq);
    `TH.`DST_CLK.inst.IF.set_clk_frq(.user_frequency(freq));
  endtask

  // Set the MM AXI side DDR clock frequency
  task set_ddr_clock(int freq);
    `TH.`DDR_CLK.inst.IF.set_clk_frq(.user_frequency(freq));
  endtask

  // Start all clocks
  task start_clocks;
     set_src_clock(100000000);
     set_dst_clock(100000000);
     set_ddr_clock(500000000);

    `TH.`SRC_CLK.inst.IF.start_clock;
    `TH.`DST_CLK.inst.IF.start_clock;
    #100;
  endtask

  // Stop all clocks
  task stop_clocks;
    `TH.`SRC_CLK.inst.IF.stop_clock;
    `TH.`DST_CLK.inst.IF.stop_clock;
  endtask

  // Asserts all the resets for 100 ns
  task sys_reset;
    `TH.`SYS_RST.inst.IF.assert_reset;
    #100
    `TH.`SYS_RST.inst.IF.deassert_reset;
  endtask

  // Assert external sync for one clock cycle
  task assert_writer_ext_sync;
  `ifdef SRC_SYNC_IO
    `TH.`SRC_SYNC_IO.inst.IF.setw_io(1);
    `TH.`SRC_SYNC_IO.inst.IF.setw_io(0);
  `endif
  endtask

  // Assert external sync for one clock cycle
  task assert_reader_ext_sync;
  `ifdef DST_SYNC_IO
    `TH.`DST_SYNC_IO.inst.IF.setw_io(1);
    `TH.`DST_SYNC_IO.inst.IF.setw_io(0);
  `endif
  endtask

  // Generate external sync pulse for input frames
  task gen_src_fsync(int clk_period, int bytes_to_transfer);
    real incycles,fperiod;
    if (has_sfsync) begin
      assert_writer_ext_sync();
    end
    // Calculate and wait one input frame duration plus a margin
    incycles = bytes_to_transfer / `SRC_AXIS_VIP_CFG_TDATA_NUM_BYTES * 1.8;
    fperiod = (incycles*1000000000)/ clk_period;
    #fperiod;
  endtask

  // Generate external sync pulse for output frames
  task gen_dst_fsync(int clk_period, int bytes_to_transfer);
    real incycles,fperiod;
    if (has_dfsync) begin
      assert_reader_ext_sync();
    end
    // Calculate and wait one output frame duration plus a margin
    incycles = bytes_to_transfer / `DST_AXIS_VIP_CFG_TDATA_NUM_BYTES * 1.8;
    fperiod = (incycles*1000000000)/ clk_period;
    #fperiod;
  endtask

endprogram

