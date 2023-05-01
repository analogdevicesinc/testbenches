// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018 (c) Analog Devices, Inc. All rights reserved.
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

package dmac_api_pkg;

  import logger_pkg::*;
  import adi_peripheral_pkg::*;
  import adi_regmap_dmac_pkg::*;
  import adi_regmap_pkg::*;
  import reg_accessor_pkg::*;
  import dma_trans_pkg::*;
  import axi_dmac_pkg::*;

  class dmac_api extends adi_peripheral;

    // DMAC parameters
    axi_dmac_params_t p;

    // -----------------
    //
    // -----------------
    function new(string name, reg_accessor bus, bit [31:0] base_address);
      super.new(name, bus, base_address);
    endfunction

    // -----------------
    //
    // -----------------
    // Discover HW parameters                                                                 
    task discover_params();                                                                   
      bit [31:0] val;
      bit  [3:0] bpb_dest_log2, bpb_src_log2, bpb_width_log2;
      this.bus.RegRead32(this.base_address + GetAddrs(DMAC_PERIPHERAL_ID), val);              
      p.ID = `GET_DMAC_PERIPHERAL_ID_PERIPHERAL_ID(val);
      this.bus.RegRead32(this.base_address + GetAddrs(DMAC_INTERFACE_DESCRIPTION), val);      
      bpb_dest_log2 = `GET_DMAC_INTERFACE_DESCRIPTION_BYTES_PER_BEAT_DEST_LOG2(val);          
      p.DMA_DATA_WIDTH_DEST = (2**bpb_dest_log2)*8;
      p.DMA_TYPE_DEST = `GET_DMAC_INTERFACE_DESCRIPTION_DMA_TYPE_DEST(val);
      bpb_src_log2 = `GET_DMAC_INTERFACE_DESCRIPTION_BYTES_PER_BEAT_SRC_LOG2(val);            
      p.DMA_DATA_WIDTH_SRC = (2**bpb_src_log2)*8;
      p.DMA_TYPE_SRC = `GET_DMAC_INTERFACE_DESCRIPTION_DMA_TYPE_SRC(val);
      bpb_width_log2 = `GET_DMAC_INTERFACE_DESCRIPTION_BYTES_PER_BURST_WIDTH(val);            
      p.MAX_BYTES_PER_BURST = 2**bpb_width_log2;
      this.bus.RegWrite32(this.base_address + GetAddrs(DMAC_X_LENGTH),
                                SetField(DMAC_X_LENGTH, "X_LENGTH", 32'h0));
      this.bus.RegRead32(this.base_address + GetAddrs(DMAC_X_LENGTH), val);
      p.DMA_LENGTH_ALIGN = `GET_DMAC_X_LENGTH_X_LENGTH(val)+1;
      this.bus.RegWrite32(this.base_address + GetAddrs(DMAC_Y_LENGTH),
                                SetField(DMAC_Y_LENGTH, "Y_LENGTH", 32'hFFFFFFFF));
      this.bus.RegRead32(this.base_address + GetAddrs(DMAC_Y_LENGTH), val);
      if (val==0) begin
        p.DMA_2D_TRANSFER = 0;
      end else begin 
        p.DMA_2D_TRANSFER = 1;
        this.bus.RegWrite32(this.base_address + GetAddrs(DMAC_Y_LENGTH), 32'h0);
      end
    endtask : discover_params

    // -----------------
    //
    // -----------------
    task probe ();
      super.probe();
      discover_params();
      `INFO(("Found %0s destination interface of %0d bit data width\n\t\tFound %0s source interface of %0d bit data width" ,
        p.DMA_TYPE_DEST == 0 ? "AXI MemoryMap" : p.DMA_TYPE_DEST == 1 ? "AXI Stream" : p.DMA_TYPE_DEST == 2 ? "FIFO" : "Unknown",
        p.DMA_DATA_WIDTH_DEST,
        p.DMA_TYPE_SRC == 0 ? "AXI MemoryMap" : p.DMA_TYPE_SRC == 1 ? "AXI Stream" : p.DMA_TYPE_SRC == 2 ? "FIFO" : "Unknown",
        p.DMA_DATA_WIDTH_SRC));
      `INFO(("Found %0d max bytes per burst" , p.MAX_BYTES_PER_BURST));
      `INFO(("Transfer length alignment requirement: %0d bytes" , p.DMA_LENGTH_ALIGN));
      `INFO(("Enabled support for 2D transfers: %0d" , p.DMA_2D_TRANSFER));
    endtask : probe

    // -----------------
    //
    // -----------------
    function axi_dmac_params_t get_params();
      return this.p;
    endfunction : get_params

    // -----------------
    //
    // -----------------
    task enable_dma();
      this.bus.RegWrite32( this.base_address + GetAddrs(DMAC_CONTROL),
                                SetField(DMAC_CONTROL, "ENABLE", 1));
    endtask : enable_dma

    // -----------------
    //
    // -----------------
    task disable_dma();
      this.bus.RegWrite32( this.base_address + GetAddrs(DMAC_CONTROL),
                                SetField(DMAC_CONTROL, "ENABLE", 0));
    endtask : disable_dma

    // -----------------
    //
    // -----------------
    task set_flags(input bit[2:0] flags);
      this.bus.RegWrite32( this.base_address + GetAddrs(DMAC_FLAGS),
                                SetField(DMAC_FLAGS, "CYCLIC", flags[0])|
                                SetField(DMAC_FLAGS, "TLAST", flags[1])|
                                SetField(DMAC_FLAGS, "PARTIAL_REPORTING_EN", flags[2]));
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
            this.bus.RegRead32( this.base_address + GetAddrs(DMAC_TRANSFER_SUBMIT), regData);
          while (GetField(DMAC_TRANSFER_SUBMIT,
                          "TRANSFER_SUBMIT",
                          regData) != 0);
          `INFO(("Ready for submission "));
        end
        begin
          #2ms;
          timeout = 1;
        end
      join_any
      if (timeout) begin
         `ERROR(("Waiting transfer submission TIMEOUT !!!"));
      end
    endtask : wait_transfer_submission

    // -----------------
    //
    // -----------------
    task transfer_start;
      this.bus.RegWrite32( this.base_address + GetAddrs(DMAC_TRANSFER_SUBMIT),
                                SetField(DMAC_TRANSFER_SUBMIT, "TRANSFER_SUBMIT", 1));
      `INFO(("Transfer start"));
    endtask : transfer_start

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
            this.bus.RegRead32( this.base_address + GetAddrs(DMAC_TRANSFER_DONE), regData);
          end
          `INFO(("Transfer id %0d DONE",transfer_id));

          partial_info_available = GetField(DMAC_TRANSFER_DONE,
                                            "PARTIAL_TRANSFER_DONE",
                                            regData);

          if (partial_segment == 1) begin
            if (partial_info_available != 1) begin
              `ERROR(("Partial transfer info availability not set for ID %0d", transfer_id));
            end

            `INFO(("Found partial data info for ID  %0d",transfer_id));
            this.bus.RegRead32( this.base_address + GetAddrs(DMAC_PARTIAL_TRANSFER_LENGTH), regData);
            segment_length_found = GetField(DMAC_PARTIAL_TRANSFER_LENGTH,
                                            "PARTIAL_LENGTH",
                                             regData);
            if (segment_length_found != segment_length) begin
              `ERROR(("Partial transfer length does not match Expected %0d Found %0d",
                      segment_length, segment_length_found));
            end else begin
              `INFO(("Found partial data info length is %0d",segment_length));
            end
            this.bus.RegRead32( this.base_address + GetAddrs(DMAC_PARTIAL_TRANSFER_ID), regData);
            id_found = GetField(DMAC_PARTIAL_TRANSFER_ID,
                                "PARTIAL_TRANSFER_ID",
                                regData);

            if (id_found != transfer_id) begin
              `ERROR(("Partial transfer ID does not match Expected %0d Found %0d",
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
         `ERROR(("Waiting transfer done TIMEOUT !!!"));
      end
    endtask : wait_transfer_done

    // -----------------
    //
    // -----------------
    task transfer_id_get(output bit [3:0] transfer_id);
      this.bus.RegRead32( this.base_address + GetAddrs(DMAC_TRANSFER_ID), transfer_id);
      `INFO(("Found transfer ID = %0d", transfer_id));
    endtask : transfer_id_get

    // -----------------
    //
    // -----------------
    task submit_transfer(dma_segment t,
                         output int next_transfer_id);

      dma_2d_segment t_2d;

      wait_transfer_submission();
      `INFO((" Submitting up a segment of : "));
      t.print();
      `INFO((" --------------------------"));

      if (t.length % p.DMA_LENGTH_ALIGN > 0) begin
        `ERROR(("Transfer length (%0d) must be multiple of largest interface (%0d)", t.length, p.DMA_LENGTH_ALIGN));
      end
      if (p.DMA_TYPE_SRC == 0) begin
        this.bus.RegWrite32( this.base_address + GetAddrs(DMAC_SRC_ADDRESS),
                                  SetField(DMAC_SRC_ADDRESS, "SRC_ADDRESS", t.src_addr));
      end
      if (p.DMA_TYPE_DEST == 0) begin
        this.bus.RegWrite32( this.base_address + GetAddrs(DMAC_DEST_ADDRESS),
                                  SetField(DMAC_DEST_ADDRESS, "DEST_ADDRESS", t.dst_addr));
      end
      this.bus.RegWrite32( this.base_address + GetAddrs(DMAC_X_LENGTH),
                                SetField(DMAC_X_LENGTH, "X_LENGTH", t.length-1));

      if (p.DMA_2D_TRANSFER == 1) begin
        if (!$cast(t_2d,t)) begin
          // Write the default values for 2D regs for non-2D transactions
          t_2d = new(p);
          t_2d.ylength = 1;
          t_2d.src_stride = 0;
          t_2d.dst_stride = 0;
        end
        this.bus.RegWrite32( this.base_address + GetAddrs(DMAC_Y_LENGTH),
                                  SetField(DMAC_Y_LENGTH, "Y_LENGTH", t_2d.ylength-1));
        if (p.DMA_TYPE_SRC == 0) begin
          this.bus.RegWrite32( this.base_address + GetAddrs(DMAC_SRC_STRIDE),
                                    SetField(DMAC_SRC_STRIDE, "SRC_STRIDE", t_2d.src_stride));
        end
        if (p.DMA_TYPE_DEST == 0) begin
          this.bus.RegWrite32( this.base_address + GetAddrs(DMAC_DEST_STRIDE),
                                    SetField(DMAC_DEST_STRIDE, "DEST_STRIDE", t_2d.dst_stride));
        end
      end

      transfer_id_get(next_transfer_id);
      transfer_start();

    endtask : submit_transfer;
  endclass

endpackage
