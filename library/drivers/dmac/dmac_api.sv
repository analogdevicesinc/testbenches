// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2018, 2025 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
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

package dmac_api_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import adi_api_pkg::*;
  import adi_regmap_pkg::*;
  import adi_regmap_dmac_pkg::*;
  import m_axi_sequencer_pkg::*;
  import dma_trans_pkg::*;

  class dmac_api extends adi_api;

    // DMAC parameters
    axi_dmac_params_t p;

    // -----------------
    //
    // -----------------
    function new(
      input string name,
      input m_axi_sequencer_base bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, bus, base_address, parent);
    endfunction


    task sanity_test();
      reg [31:0] data;
      // version
      this.axi_verify(GetAddrs(DMAC_VERSION),
        `SET_DMAC_VERSION_VERSION_MAJOR(`DEFAULT_DMAC_VERSION_VERSION_MAJOR) |
        `SET_DMAC_VERSION_VERSION_MINOR(`DEFAULT_DMAC_VERSION_VERSION_MINOR) |
        `SET_DMAC_VERSION_VERSION_PATCH(`DEFAULT_DMAC_VERSION_VERSION_PATCH));
      // scratch
      data = 32'hdeadbeef;
      this.axi_write(GetAddrs(DMAC_SCRATCH), `SET_DMAC_SCRATCH_SCRATCH(data));
      this.axi_verify(GetAddrs(DMAC_SCRATCH), `SET_DMAC_SCRATCH_SCRATCH(data));
      // magic
      this.axi_verify(GetAddrs(DMAC_IDENTIFICATION), `SET_DMAC_IDENTIFICATION_IDENTIFICATION(`DEFAULT_DMAC_IDENTIFICATION_IDENTIFICATION));
    endtask

    // -----------------
    //
    // -----------------
    // Discover HW parameters
    task discover_params();
      bit [31:0] val;
      bit  [3:0] bpb_dest_log2, bpb_src_log2, bpb_width_log2;
      this.axi_read(GetAddrs(DMAC_PERIPHERAL_ID), val);
      p.ID = `GET_DMAC_PERIPHERAL_ID_PERIPHERAL_ID(val);
      this.axi_read(GetAddrs(DMAC_INTERFACE_DESCRIPTION_1), val);
      bpb_dest_log2 = `GET_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BEAT_DEST_LOG2(val);
      p.DMA_DATA_WIDTH_DEST = (2**bpb_dest_log2)*8;
      p.DMA_TYPE_DEST = `GET_DMAC_INTERFACE_DESCRIPTION_1_DMA_TYPE_DEST(val);
      bpb_src_log2 = `GET_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BEAT_SRC_LOG2(val);
      p.DMA_DATA_WIDTH_SRC = (2**bpb_src_log2)*8;
      p.DMA_TYPE_SRC = `GET_DMAC_INTERFACE_DESCRIPTION_1_DMA_TYPE_SRC(val);
      bpb_width_log2 = `GET_DMAC_INTERFACE_DESCRIPTION_1_BYTES_PER_BURST_WIDTH(val);
      p.MAX_BYTES_PER_BURST = 2**bpb_width_log2;
      p.DMA_2D_TLAST_MODE = `GET_DMAC_INTERFACE_DESCRIPTION_1_DMA_2D_TLAST_MODE(val);
      p.MAX_NUM_FRAMES_WIDTH = $clog2(`GET_DMAC_INTERFACE_DESCRIPTION_1_MAX_NUM_FRAMES(val))+1;
      p.USE_EXT_SYNC = `GET_DMAC_INTERFACE_DESCRIPTION_1_USE_EXT_SYNC(val);
      p.HAS_AUTORUN = `GET_DMAC_INTERFACE_DESCRIPTION_1_HAS_AUTORUN(val);
      if (!p.HAS_AUTORUN) begin
        this.axi_write(GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(32'h0));
      end
      this.axi_read(GetAddrs(DMAC_X_LENGTH), val);
      p.DMA_LENGTH_ALIGN = `GET_DMAC_X_LENGTH_X_LENGTH(val)+1;
      if (!p.HAS_AUTORUN) begin
        this.axi_write(GetAddrs(DMAC_Y_LENGTH),
                       `SET_DMAC_Y_LENGTH_Y_LENGTH(32'hFFFFFFFF));
      end
      this.axi_read(GetAddrs(DMAC_Y_LENGTH), val);
      if (val==0) begin
        p.DMA_2D_TRANSFER = 0;
      end else begin
        p.DMA_2D_TRANSFER = 1;
        if (!p.HAS_AUTORUN) begin
          this.axi_write(GetAddrs(DMAC_Y_LENGTH), 32'h0);
        end
      end
      this.axi_read(GetAddrs(DMAC_FLAGS), val);
      p.FRAMELOCK = `GET_DMAC_CONTROL_FRAMELOCK(val);
    endtask : discover_params

    // -----------------
    //
    // -----------------
    task probe ();
      super.probe();
      discover_params();
      this.info($sformatf("Found %0s destination interface of %0d bit data width\n\t\tFound %0s source interface of %0d bit data width" ,
        p.DMA_TYPE_DEST == 0 ? "AXI MemoryMap" : p.DMA_TYPE_DEST == 1 ? "AXI Stream" : p.DMA_TYPE_DEST == 2 ? "FIFO" : "Unknown",
        p.DMA_DATA_WIDTH_DEST,
        p.DMA_TYPE_SRC == 0 ? "AXI MemoryMap" : p.DMA_TYPE_SRC == 1 ? "AXI Stream" : p.DMA_TYPE_SRC == 2 ? "FIFO" : "Unknown",
        p.DMA_DATA_WIDTH_SRC), ADI_VERBOSITY_MEDIUM);
      this.info($sformatf("Found %0d max bytes per burst" , p.MAX_BYTES_PER_BURST), ADI_VERBOSITY_MEDIUM);
      this.info($sformatf("Transfer length alignment requirement: %0d bytes" , p.DMA_LENGTH_ALIGN), ADI_VERBOSITY_MEDIUM);
      this.info($sformatf("Enabled support for 2D transfers: %0d" , p.DMA_2D_TRANSFER), ADI_VERBOSITY_MEDIUM);
    endtask : probe

    // -----------------
    //
    // -----------------
    function axi_dmac_params_t get_params();
      return this.p;
    endfunction : get_params

    task set_sg_address(input bit [31:0] address);
      this.axi_write(GetAddrs(DMAC_SG_ADDRESS), `SET_DMAC_SG_ADDRESS_SG_ADDRESS(address));
    endtask

    // -----------------
    //
    // -----------------
    task enable_dma();
      this.axi_write(GetAddrs(DMAC_CONTROL),
                     `SET_DMAC_CONTROL_ENABLE(1));
    endtask : enable_dma

    // -----------------
    //
    // -----------------
    task disable_dma();
      this.axi_write(GetAddrs(DMAC_CONTROL),
                     `SET_DMAC_CONTROL_PAUSE(0));
    endtask : disable_dma

    // -----------------
    //
    // -----------------
    task set_control(input bit[3:0] control);
      this.axi_write(GetAddrs(DMAC_CONTROL),
                     `SET_DMAC_CONTROL_ENABLE(control[0]) |
                     `SET_DMAC_CONTROL_PAUSE(control[1]) |
                     `SET_DMAC_CONTROL_HWDESC(control[2]) |
                     `SET_DMAC_CONTROL_FRAMELOCK(control[3]));
    endtask : set_control

    // -----------------
    //
    // -----------------
    task set_flags(input bit[3:0] flags);
      this.axi_write(GetAddrs(DMAC_FLAGS),
                     `SET_DMAC_FLAGS_CYCLIC(flags[0]) |
                     `SET_DMAC_FLAGS_TLAST(flags[1]) |
                     `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(flags[2]));
    endtask : set_flags

    // -----------------
    //
    // -----------------
    task wait_transfer_submission;
      bit [31:0] regData = 'h0;
      bit timeout;

      regData = 'h0;
      timeout = 0;
      fork
        begin
          do
            this.axi_read(GetAddrs(DMAC_TRANSFER_SUBMIT), regData);
          while (`GET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(regData) != 0);
          this.info($sformatf("Ready for submission "), ADI_VERBOSITY_MEDIUM);
        end
        begin
          #2ms;
          timeout = 1;
        end
      join_any
      if (timeout) begin
         this.error($sformatf("Waiting transfer submission TIMEOUT !!!"));
      end
    endtask : wait_transfer_submission

    // -----------------
    //
    // -----------------
    task transfer_start;
      this.axi_write(GetAddrs(DMAC_TRANSFER_SUBMIT),
                        `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      this.info($sformatf("Transfer start"), ADI_VERBOSITY_MEDIUM);
    endtask : transfer_start

    // -----------------
    //
    // -----------------
    task set_dest_addr(input int xfer_addr);
      this.axi_write(GetAddrs(DMAC_DEST_ADDRESS),
                     `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(xfer_addr));
    endtask : set_dest_addr

    // -----------------
    //
    // -----------------
    task set_src_addr(input int xfer_addr);
      this.axi_write(GetAddrs(DMAC_SRC_ADDRESS),
                     `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(xfer_addr));
    endtask : set_src_addr

    // -----------------
    //
    // -----------------
    task set_lengths(
      input int xfer_length_x,
      input int xfer_length_y);
      this.axi_write(GetAddrs(DMAC_X_LENGTH),
                     `SET_DMAC_X_LENGTH_X_LENGTH(xfer_length_x));
      this.axi_write(GetAddrs(DMAC_Y_LENGTH),
                     `SET_DMAC_Y_LENGTH_Y_LENGTH(xfer_length_y));
    endtask : set_lengths

    // -----------------
    //
    // -----------------
    task wait_transfer_done(input bit [3:0] transfer_id,
                            input bit partial_segment = 0,
                            input int segment_length = 0,
                            input int timeut_in_us = 2000);
      bit [31:0] regData = 'h0;
      bit timeout;
      int segment_length_found,id_found;
      bit partial_info_available;

      regData = 'h0;
      timeout = 0;
      fork
        begin
          while (~regData[transfer_id]) begin
            this.axi_read(GetAddrs(DMAC_TRANSFER_DONE), regData);
          end
          this.info($sformatf("Transfer id %0d DONE",transfer_id), ADI_VERBOSITY_MEDIUM);

          partial_info_available = `GET_DMAC_TRANSFER_DONE_PARTIAL_TRANSFER_DONE(regData);

          if (partial_segment == 1) begin
            if (partial_info_available != 1) begin
              this.error($sformatf("Partial transfer info availability not set for ID %0d", transfer_id));
            end

            this.info($sformatf("Found partial data info for ID  %0d",transfer_id), ADI_VERBOSITY_MEDIUM);
            this.axi_read(GetAddrs(DMAC_PARTIAL_TRANSFER_LENGTH), regData);
            segment_length_found = `GET_DMAC_PARTIAL_TRANSFER_LENGTH_PARTIAL_LENGTH(regData);
            if (segment_length_found != segment_length) begin
              this.error($sformatf("Partial transfer length does not match Expected %0d Found %0d",
                      segment_length, segment_length_found));
            end else begin
              this.info($sformatf("Found partial data info length is %0d",segment_length), ADI_VERBOSITY_MEDIUM);
            end
            this.axi_read(GetAddrs(DMAC_PARTIAL_TRANSFER_ID), regData);
            id_found = `GET_DMAC_PARTIAL_TRANSFER_ID_PARTIAL_TRANSFER_ID(regData);

            if (id_found != transfer_id) begin
              this.error($sformatf("Partial transfer ID does not match Expected %0d Found %0d",
                      transfer_id ,id_found));
            end
          end

        end
        begin
          repeat (timeut_in_us) begin
            #1us;
          end
          timeout = 1;
        end
      join_any
      if (timeout) begin
         this.error($sformatf("Waiting transfer done TIMEOUT !!!"));
      end
    endtask : wait_transfer_done

    // -----------------
    //
    // -----------------
    task transfer_id_get(output bit [3:0] transfer_id);
      this.axi_read(GetAddrs(DMAC_TRANSFER_ID), transfer_id);
      this.info($sformatf("Found transfer ID = %0d", transfer_id), ADI_VERBOSITY_MEDIUM);
    endtask : transfer_id_get

    // -----------------
    //
    // -----------------
    task submit_transfer(dma_segment t,
                         output int next_transfer_id);

      dma_2d_segment t_2d;
      dma_flocked_2d_segment t_fl_2d;

      wait_transfer_submission();
      this.info($sformatf(" Submitting up a segment of : "), ADI_VERBOSITY_MEDIUM);
      t.print();
      this.info($sformatf(" --------------------------"), ADI_VERBOSITY_MEDIUM);

      if (t.length % p.DMA_LENGTH_ALIGN > 0) begin
        this.error($sformatf("Transfer length (%0d) must be multiple of largest interface (%0d)", t.length, p.DMA_LENGTH_ALIGN));
      end
      if (p.DMA_TYPE_SRC == 0) begin
        this.axi_write(GetAddrs(DMAC_SRC_ADDRESS),
                       `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(t.src_addr));
      end
      if (p.DMA_TYPE_DEST == 0) begin
        this.axi_write(GetAddrs(DMAC_DEST_ADDRESS),
                       `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(t.dst_addr));
      end
      this.axi_write(GetAddrs(DMAC_X_LENGTH),
                     `SET_DMAC_X_LENGTH_X_LENGTH(t.length-1));

      if (p.DMA_2D_TRANSFER == 1) begin
        if (!$cast(t_2d,t)) begin
          // Write the default values for 2D regs for non-2D transactions
          t_2d = new(p);
          t_2d.ylength = 1;
          t_2d.src_stride = 0;
          t_2d.dst_stride = 0;
        end
        this.axi_write(GetAddrs(DMAC_Y_LENGTH),
                       `SET_DMAC_Y_LENGTH_Y_LENGTH(t_2d.ylength-1));
        if (p.DMA_TYPE_SRC == 0) begin
          this.axi_write(GetAddrs(DMAC_SRC_STRIDE),
                         `SET_DMAC_SRC_STRIDE_SRC_STRIDE(t_2d.src_stride));
        end
        if (p.DMA_TYPE_DEST == 0) begin
          this.axi_write(GetAddrs(DMAC_DEST_STRIDE),
                         `SET_DMAC_DEST_STRIDE_DEST_STRIDE(t_2d.dst_stride));
        end
      end

      if ($cast(t_fl_2d,t)) begin
        this.axi_write(GetAddrs(DMAC_FRAMELOCK_CONFIG),
                       `SET_DMAC_FRAMELOCK_CONFIG_MODE(t_fl_2d.flock_mode) |
                       `SET_DMAC_FRAMELOCK_CONFIG_WAIT_WRITER(t_fl_2d.flock_wait_writer ) |
                       `SET_DMAC_FRAMELOCK_CONFIG_FRAMENUM(t_fl_2d.flock_framenum) |
                       `SET_DMAC_FRAMELOCK_CONFIG_DISTANCE(t_fl_2d.flock_distance));
        this.axi_write(GetAddrs(DMAC_FRAMELOCK_STRIDE),
                       `SET_DMAC_FRAMELOCK_STRIDE_STRIDE(t_fl_2d.flock_stride));
      end

      transfer_id_get(next_transfer_id);
      transfer_start();

    endtask : submit_transfer;
  endclass

endpackage
