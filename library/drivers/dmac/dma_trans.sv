// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018, 2024 (c) Analog Devices, Inc. All rights reserved.
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
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

package dma_trans_pkg;

  import logger_pkg::*;

  typedef struct {
    int ID;
    int DMA_DATA_WIDTH_SRC;
    int DMA_DATA_WIDTH_DEST;
    int DMA_2D_TRANSFER;
    int DMA_2D_TLAST_MODE;
    int DMA_TYPE_SRC;
    int DMA_TYPE_DEST;
    int DMA_LENGTH_ALIGN;
    int MAX_BYTES_PER_BURST;
    int FRAMELOCK;
    int MAX_NUM_FRAMES_WIDTH;
    int USE_EXT_SYNC;
    int HAS_AUTORUN;
  } axi_dmac_params_t;

  //==========================================================================
  /*
    dma_segment
  */
  //==========================================================================
  class dma_segment;
    // DMAC parameters
    axi_dmac_params_t p;

    rand int unsigned src_addr;
    rand int unsigned dst_addr;
    rand int unsigned length;
    bit first = 1;
    bit last = 1;
    bit skip = 0;
    bit cyclic = 0;

    // do not test large addresses
    constraint saddr_range {src_addr <= 2**16;}
    constraint daddr_range {dst_addr <= 2**16;}

    // length resolution
    int src_res;
    int dst_res;
    int res;

    // -----------------
    //
    // -----------------
    function new(axi_dmac_params_t p);
      this.p = p;

      this.src_res = p.DMA_DATA_WIDTH_SRC/8;
      this.dst_res = p.DMA_DATA_WIDTH_DEST/8;
      this.res = `MAX(src_res, dst_res);
    endfunction

    // -----------------
    //
    // -----------------
    function copy(dma_segment ds);
      ds.p = p;
      ds.src_addr = src_addr;
      ds.dst_addr = dst_addr;
      ds.length = length;
      ds.first = first;
      ds.last = last;
      ds.skip = skip;
      ds.cyclic = cyclic;
    endfunction

    constraint transfer_length {length > res; length <= 4096;}

    // -----------------
    //
    // -----------------
    virtual function void print();
      `INFO(("--------------------------"), ADI_VERBOSITY_MEDIUM);
      `INFO(("src_addr is 0x%h",src_addr), ADI_VERBOSITY_MEDIUM);
      `INFO(("dst_addr is 0x%h",dst_addr), ADI_VERBOSITY_MEDIUM);
      `INFO(("length   is %0d",length), ADI_VERBOSITY_MEDIUM);
      `INFO(("first    is %0d",first), ADI_VERBOSITY_MEDIUM);
      `INFO(("last     is %0d",last), ADI_VERBOSITY_MEDIUM);
      `INFO(("skip     is %0d",skip), ADI_VERBOSITY_MEDIUM);
    endfunction

    // -----------------
    //
    // -----------------
    virtual function int get_bytes_in_transfer();
      return length;
    endfunction

    // -----------------
    //
    // -----------------
    virtual function int get_actual_bytes_in_segment();
      return get_bytes_in_transfer();
    endfunction

    // -----------------
    //
    // -----------------
    function void post_randomize();
      // Address needs to be aligned to the width of the MM interface
      src_addr =  src_addr & ~(src_res - 1);
      dst_addr =  dst_addr & ~(dst_res - 1);
      // Address needs to be aligned so the 4kB boundary won't be crossed
      src_addr =  src_addr & ~(p.MAX_BYTES_PER_BURST - 1);
      dst_addr =  dst_addr & ~(p.MAX_BYTES_PER_BURST - 1);
      // transfer length must be multiple of largest interface width
      length = length & ~(res - 1);
    endfunction

  endclass : dma_segment

  //==========================================================================
  /*
    dma_partial_segment
  */
  //==========================================================================
  class dma_partial_segment extends dma_segment;
    rand int reduced_length;

    // -----------------
    //
    // -----------------
    function new(axi_dmac_params_t p);
      super.new(p);
    endfunction

    // -----------------
    //
    // -----------------
    function copy(dma_partial_segment ds);
      super.copy(ds);
      ds.reduced_length = reduced_length;
    endfunction

    // -----------------
    //
    // -----------------
    virtual function void print();
      super.print();
      `INFO(("partial length is %0d", reduced_length), ADI_VERBOSITY_MEDIUM);
    endfunction

    // length resolution
    constraint partial_length {reduced_length > src_res; reduced_length < length;};

    // -----------------
    //
    // -----------------
    function void post_randomize();
      super.post_randomize();
      reduced_length = reduced_length & ~(src_res - 1);
      if (reduced_length >= length) begin
        reduced_length = length - src_res;
      end
    endfunction

    // -----------------
    //
    // -----------------
    virtual function int get_actual_bytes_in_segment();
      return reduced_length;
    endfunction

  endclass : dma_partial_segment

  //==========================================================================
  /*
    dma_2d_segment
  */
  //==========================================================================
  class dma_2d_segment extends dma_segment;

    typedef dma_segment dma_segment_array_t[];

    rand int unsigned src_stride;
    rand int unsigned dst_stride;
    rand int unsigned ylength;

    // -----------------
    //
    // -----------------
    function new(axi_dmac_params_t p);
      super.new(p);
    endfunction

    // -----------------
    //
    // -----------------
    function copy(dma_2d_segment ds);
      super.copy(ds);
      ds.src_stride = src_stride;
      ds.dst_stride = dst_stride;
      ds.ylength = ylength;
    endfunction

    constraint sstride_size {src_stride >= length; src_stride < 2*length;};
    constraint dstride_size {dst_stride >= length; dst_stride < 2*length;};

    // Known Issue:
    // DMAC does not likes short lines in 2D transfers, it not optimal and
    // transfer done interrupt may not be generated.
    constraint xlength_size {
      length > 100;
    }

    constraint ylength_size {
      ylength > 1 && ylength < 10;
    }

    // -----------------
    //
    // -----------------
    virtual function int get_bytes_in_transfer();
      return length*ylength;
    endfunction

    // -----------------
    //
    // -----------------
    function void post_randomize();
      super.post_randomize();
      // stride needs to be aligned so the 4kB boundary won't be crossed
      src_stride =  src_stride & ~(p.MAX_BYTES_PER_BURST - 1);
      dst_stride =  dst_stride & ~(p.MAX_BYTES_PER_BURST - 1);
    endfunction

    // -----------------
    //
    // -----------------
    virtual function void print();
      super.print();
      `INFO(("ylength    is %0d", ylength), ADI_VERBOSITY_MEDIUM);
      `INFO(("src_stride is 0x%0h", src_stride), ADI_VERBOSITY_MEDIUM);
      `INFO(("dst_stride is 0x%0h", dst_stride), ADI_VERBOSITY_MEDIUM);
    endfunction

    // -----------------
    //
    // -----------------
    virtual function dma_segment_array_t build_segments();
      dma_segment_array_t sa;
      dma_segment s;
      sa = new[ylength];
      for (int i=0; i<ylength; i++) begin
        s = new(p);
        s.src_addr = src_addr + i*src_stride;
        s.dst_addr = dst_addr + i*dst_stride;
        s.length = length;
        if (i != ylength-1)
          s.last = (p.DMA_2D_TLAST_MODE == 1) & this.last;
        if (i > 0)
          s.first = 0;
        sa[i] = s;
      end
     return sa;
    endfunction

  endclass : dma_2d_segment

  //==========================================================================
  /*
    dma_partial_2d_segment
  */
  //==========================================================================
  class dma_partial_2d_segment extends dma_2d_segment;

    rand int partial_segment_no;
    rand int reduced_length;

    // -----------------
    //
    // -----------------
    function new(axi_dmac_params_t p);
      super.new(p);
    endfunction

    // -----------------
    //
    // -----------------
    function copy(dma_partial_2d_segment ds);
      super.copy(ds);
      ds.partial_segment_no = partial_segment_no;
      ds.reduced_length = reduced_length;
    endfunction

    constraint partial_segment_c {
      partial_segment_no >= 0 && partial_segment_no < ylength;
    }
    constraint partial_length_c {
      reduced_length >= src_res && reduced_length < length;
    }

    // -----------------
    //
    // -----------------
    virtual function int get_bytes_in_transfer();
      return length*partial_segment_no + reduced_length;
    endfunction

    // -----------------
    //
    // -----------------
    function void post_randomize();
      super.post_randomize();
      // align partial length to source width
      reduced_length =  reduced_length & ~(src_res - 1);
    endfunction

    // -----------------
    //
    // -----------------
    virtual function void print();
      super.print();
      `INFO(("partial_segment_no is %0d", partial_segment_no), ADI_VERBOSITY_MEDIUM);
      `INFO(("reduced_length is %0d", reduced_length), ADI_VERBOSITY_MEDIUM);
    endfunction

    // -----------------
    //
    // -----------------
    virtual function dma_segment_array_t build_segments();
      dma_segment_array_t sa;
      dma_segment s;
      dma_partial_segment ps;
      int skip_segment = 0;

      sa = new[ylength];
      for (int i=0; i<ylength; i++) begin
        if (i != partial_segment_no) begin
          s = new(p);
          s.src_addr = src_addr + i*src_stride;
          s.dst_addr = dst_addr + i*dst_stride;
          s.length = length;
          s.skip = skip_segment;
          if (i != ylength-1)
            s.last = 0;
          sa[i] = s;
          `INFO((" generating segment "), ADI_VERBOSITY_MEDIUM);
          s.print();
        end else begin
          ps = new(p);
          ps.src_addr = src_addr + i*src_stride;
          ps.dst_addr = dst_addr + i*dst_stride;
          ps.length = length;
          ps.reduced_length = reduced_length;
          ps.skip = 0;
          ps.last = 1;
          sa[i] = ps;
          skip_segment = 1;
          `INFO((" generating partial segment "), ADI_VERBOSITY_MEDIUM);
          ps.print();
        end
      end
     return sa;
    endfunction

  endclass : dma_partial_2d_segment

  //==========================================================================
  /*
    dma_flocked_2d_segment
  */
  //==========================================================================
  class dma_flocked_2d_segment extends dma_2d_segment;

    rand int unsigned flock_distance;
    int flock_wait_writer = 1;
    int flock_mode = 0;  // 0 - dynamic. 1 - simple
    rand int unsigned flock_framenum;
    int unsigned flock_stride;

    // -----------------
    //
    // -----------------
    function new(axi_dmac_params_t p);
      super.new(p);
    endfunction

    // -----------------
    //
    // -----------------
    function copy(dma_flocked_2d_segment ds);
      super.copy(ds);
      ds.flock_framenum = flock_framenum;
      ds.flock_distance = flock_distance;
      ds.flock_stride = flock_stride;
      ds.flock_mode = flock_mode;
      ds.flock_wait_writer = flock_wait_writer;
    endfunction

    constraint c_buf_num  {flock_framenum < (p.MAX_NUM_FRAMES_WIDTH-1)**2;};
    constraint c_frm_dist {flock_distance < flock_framenum;};

    virtual function void print();
      super.print();
      `INFO(("flock_framenum is %0d", flock_framenum), ADI_VERBOSITY_MEDIUM);
      `INFO(("flock_distance is %0d", flock_distance), ADI_VERBOSITY_MEDIUM);
      `INFO(("flock_stride is 0x%0h", flock_stride), ADI_VERBOSITY_MEDIUM);
    endfunction


    // -----------------
    //
    // -----------------
    function void post_randomize();
      super.post_randomize();
      flock_stride =  length *  ylength;
      cyclic = 1;
    endfunction


    // -----------------
    //
    // -----------------
    function dma_flocked_2d_segment toSlaveSeg;
      dma_flocked_2d_segment seg;
      seg = new(this.p);
      this.copy(seg);
      seg.src_addr = seg.dst_addr;
      seg.src_stride = seg.dst_stride;

      return seg;
    endfunction

  endclass : dma_flocked_2d_segment

  //==========================================================================
  /*
    dma_transfer
  */
  //==========================================================================
  class dma_transfer;
    axi_dmac_params_t p;

    // -----------------
    //
    // -----------------
    function new(axi_dmac_params_t p);
      this.p = p;
    endfunction

    dma_segment group[];
    rand int size;

    int skip_next_segment = 0;

    constraint default_size {
      size > 0 && size < 5;
      group.size() == size;
    }

    // -----------------
    //
    // -----------------
    virtual function void print();
      `INFO(("transfer S"), ADI_VERBOSITY_MEDIUM);
      for (int i=0; i<group.size(); i++) begin
        group[i].print();
      end
      `INFO(("transfer E"), ADI_VERBOSITY_MEDIUM);
    endfunction

    // -----------------
    //
    // -----------------
    function void post_randomize();
      dma_segment s;
      group = new[size];
      `INFO(("groups size %0d",group.size()), ADI_VERBOSITY_MEDIUM);
      for (int i=0;i<size;i++) begin
        s = new(p);
        if (i != size-1)
          s.last = 0;
        if (i > 0)
          s.first = 0;
        if (s.randomize())
          group[i] = s;
        else
          `FATAL(("randomization failed"));
      end
    endfunction

    // -----------------
    //
    // -----------------
    // Add element to the group
    function void add(dma_segment s);

      dma_partial_segment ps;

      group = new[group.size()+1] (group);
      group[size-1].last = 0;
      group[size] = s;
      group[size].skip = skip_next_segment;
      group[size].first = 0;
      if ($cast(ps,s)) begin
        skip_next_segment = 1;
      end
      size++;
    endfunction

  endclass : dma_transfer

  //==========================================================================
  /*
    dma_transfer_group
  */
  //==========================================================================
  class dma_transfer_group;

    dma_transfer group[];
    rand int size;

    constraint default_size {
      size > 0 && size < 5;
      group.size() == size;
    }

    // -----------------
    //
    // -----------------
    // Add element to the group
    function void add(dma_transfer t);
      group = new[group.size()+1] (group);
      group[size] = t;
      size++;
    endfunction

  endclass : dma_transfer_group

endpackage
