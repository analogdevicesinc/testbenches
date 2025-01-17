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
      
      // forever begin : tx_path
      //   if (this.enabled == 0)
      //     break;
      //   if ((this.source_byte_stream_size > 0) &&
      //         (this.sink_byte_stream_size >= this.channels*this.samples*this.width/8)) begin
      //     byte_streams_empty_sig = 0;
      //     for (int i=0; i<this.channels*this.samples*this.width/8; i++) begin
      //       sink_byte_stream_block[i] = this.sink_byte_stream.pop_back();
      //       this.sink_byte_stream_size--;
      //     end
      //     for (int i=0; i<outer_loop; i++) begin
      //       for (int j=0; j<inner_loop; j++) begin
      //         for (int k=0; k<this.width/8; k++) begin
      //           source_byte = this.source_byte_stream.pop_back();
      //           if (this.sink_type == CYCLIC)
      //             this.source_byte_stream.push_front(source_byte);
      //           else
      //             this.source_byte_stream_size--;
      //           sink_byte = sink_byte_stream_block[(outer_loop*j+i)*this.width/8+k];
      //           this.info($sformatf("Scoreboard source-sink data: exp %h - rcv %h", source_byte, sink_byte), 100);
      //           if (source_byte != sink_byte) begin
      //             this.error($sformatf("Scoreboard failed at: exp %h - rcv %h", source_byte, sink_byte));
      //           end
      //         end
      //       end
      //     end
      //   end else begin
      //     if ((this.source_byte_stream_size == 0) &&
      //         (this.sink_byte_stream_size == 0)) begin
      //       byte_streams_empty_sig = 1;
      //       ->>byte_streams_empty;
      //     end
      //     fork begin
      //       fork
      //         @source_transaction_event;
      //         @sink_transaction_event;
      //         @stop_scoreboard;
      //       join_any
      //       byte_streams_empty_sig = 0;
      //       disable fork;
      //     end join
      //   end
      // end

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
