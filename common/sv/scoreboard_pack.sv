`include "utils.svh"

package scoreboard_pack_pkg;

  import xil_common_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import axi_vip_pkg::*;
  import logger_pkg::*;
  import x_monitor_pkg::*;
  import mailbox_pkg::*;
  import scoreboard_pkg::*;

  typedef enum {
    CPACK,
    UPACK
  } pack_type;

  class scoreboard_pack extends scoreboard;

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
      input pack_type mode);

      super.new(name);

      this.channels = channels;
      this.samples = samples;
      this.width = width;
      this.mode = mode;

    endfunction: new

    // compare the collected data
    virtual task compare_transaction();

      logic [7:0] source_byte;
      logic [7:0] sink_byte;
      logic [7:0] sink_byte_stream_block [int];

      int outer_loop = (this.mode == CPACK) ? this.channels : this.samples;
      int inner_loop = (this.mode == CPACK) ? this.samples : this.channels;

      `INFOV(("Scoreboard started"), 100);

      forever begin : tx_path
        if (this.enabled == 0)
          break;
        if ((this.source_byte_stream_size > 0) &&
              (this.sink_byte_stream_size >= this.channels*this.samples*this.width/8)) begin
          byte_streams_empty_sig = 0;
          for (int i=0; i<this.channels*this.samples*this.width/8; i++) begin
            sink_byte_stream_block[i] = this.sink_byte_stream.pop_back();
            this.sink_byte_stream_size--;
          end
          for (int i=0; i<outer_loop; i++) begin
            for (int j=0; j<inner_loop; j++) begin
              for (int k=0; k<this.width/8; k++) begin
                source_byte = this.source_byte_stream.pop_back();
                if (this.sink_type == CYCLIC)
                  this.source_byte_stream.push_front(source_byte);
                else
                  this.source_byte_stream_size--;
                sink_byte = sink_byte_stream_block[(outer_loop*j+i)*this.width/8+k];
                `INFOV(("Scoreboard source-sink data: exp %h - rcv %h", source_byte, sink_byte), 100);
                if (source_byte != sink_byte) begin
                  `ERROR(("Scoreboard failed at: exp %h - rcv %h", source_byte, sink_byte));
                end
              end
            end
          end
        end else begin
          if ((this.source_byte_stream_size == 0) &&
              (this.sink_byte_stream_size == 0)) begin
            byte_streams_empty_sig = 1;
            ->>byte_streams_empty;
          end
          fork begin
            fork
              @source_transaction_event;
              @sink_transaction_event;
              @stop_scoreboard;
            join_any
            byte_streams_empty_sig = 0;
            disable fork;
          end join
        end
      end

    endtask /* compare_transaction */

  endclass

endpackage
