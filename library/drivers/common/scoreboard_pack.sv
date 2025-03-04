// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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

package scoreboard_pack_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import scoreboard_pkg::*;

  typedef enum {
    CPACK,
    UPACK
  } pack_type;

  class scoreboard_pack #(type data_type = int) extends scoreboard#(.data_type(data_type));

    protected int channels;
    protected int samples;
    protected int width;

    protected pack_type mode;

    // constructor
    function new(
      input string name,
      input int channels,
      input int samples,
      input int width,
      input pack_type mode,
      input adi_component parent = null);

      super.new(name, parent);

      this.channels = channels;
      this.samples = samples;
      this.width = width;
      this.mode = mode;

    endfunction: new

    // compare the collected data
    virtual function void compare_transaction();

      logic [7:0] source_byte;
      logic [7:0] sink_byte;
      data_type sink_byte_stream_block [int];

      int outer_loop = (this.mode == CPACK) ? this.channels : this.samples;
      int inner_loop = (this.mode == CPACK) ? this.samples : this.channels;

      if (this.enabled == 0)
        return;

      while ((this.subscriber_source.get_size() > 0) &&
            (this.subscriber_sink.get_size() >= this.channels*this.samples*this.width/8)) begin
        byte_streams_empty_sig = 0;
        for (int i=0; i<this.channels*this.samples*this.width/8; i++) begin
          sink_byte_stream_block[i] = this.subscriber_sink.get_data();
        end
        for (int i=0; i<outer_loop; i++) begin
          for (int j=0; j<inner_loop; j++) begin
            for (int k=0; k<this.width/8; k++) begin
              source_byte = this.subscriber_source.get_data();
              if (this.sink_type == CYCLIC)
                this.subscriber_source.put_data(source_byte);
              sink_byte = sink_byte_stream_block[(outer_loop*j+i)*this.width/8+k];
              this.info($sformatf("Scoreboard source-sink data: exp %h - rcv %h", source_byte, sink_byte), ADI_VERBOSITY_MEDIUM);
              if (source_byte != sink_byte) begin
                this.error($sformatf("Scoreboard failed at: exp %h - rcv %h", source_byte, sink_byte));
              end
            end
          end
        end
      end 

      if ((this.subscriber_source.get_size() == 0) &&
          (this.subscriber_sink.get_size() == 0)) begin
        this.byte_streams_empty_sig = 1;
        ->this.byte_streams_empty;
      end
    endfunction: compare_transaction

  endclass

endpackage
