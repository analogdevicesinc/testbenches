`include "utils.svh"

package scoreboard_pkg;

  import xil_common_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import axi_vip_pkg::*;
  import logger_pkg::*;
  import x_monitor_pkg::*;
  import mailbox_pkg::*;

  class scoreboard extends xil_component;

    typedef enum bit { CYCLIC=0, ONESHOT } sink_type_t;
    protected sink_type_t sink_type ;

    // List of analysis ports from the monitors
    protected x_monitor source_monitor;
    protected x_monitor sink_monitor;

    protected logic [7:0] source_byte_stream [$];
    protected logic [7:0] sink_byte_stream [$];

    // protected int transfer_size;
    // protected int all_transfer_size;
    protected int source_byte_stream_size;
    protected int sink_byte_stream_size;

    // counters and synchronizers
    protected bit enabled;
    protected bit byte_streams_empty_sig;

    // protected event end_of_first_cycle;
    protected event byte_streams_empty;
    protected event stop_scoreboard;
    protected event source_transaction_event;
    protected event sink_transaction_event;

    // constructor
    function new(input string name);

      super.new(name);

      this.enabled = 0;
      this.sink_type = CYCLIC;
      // this.transfer_size = 0;
      // this.all_transfer_size = 0;
      this.source_byte_stream_size = 0;
      this.sink_byte_stream_size = 0;
      this.byte_streams_empty_sig = 1;

    endfunction: new

    // connect the analysis ports of the monitor to the scoreboard
    function void set_source_stream(
      x_monitor source_monitor);

      this.source_monitor = source_monitor;

    endfunction: set_source_stream

    function void set_sink_stream(
      x_monitor sink_monitor);

      this.sink_monitor = sink_monitor;

    endfunction: set_sink_stream 

    // run task
    task run();

      fork
        this.enabled = 1;
        get_source_transaction();
        get_sink_transaction();
        compare_transaction();
        // verify_tx_cyclic();
      join_none

    endtask: run

    // stop scoreboard
    task stop();
      this.enabled = 0;
      ->>stop_scoreboard;
      #1step;
    endtask: stop

    // set sink type
    function void set_sink_type(input bit sink_type);

      if (!this.enabled) begin
        this.sink_type = sink_type_t'(sink_type);
      end else begin
        `ERROR(("ERROR Scoreboard: Can not configure sink_type while scoreboard is running."));
      end

    endfunction: set_sink_type

    // clear source and sink byte streams
    function void clear_streams();
      source_byte_stream.delete();
      sink_byte_stream.delete();
    endfunction: clear_streams

    // get sink type
    function bit get_sink_type();
      return this.sink_type;
    endfunction

    // wait until source and sink byte streams are empty, full check
    task wait_until_complete();
      if (this.byte_streams_empty_sig)
        return;
      @byte_streams_empty;
    endtask

    // get transaction data from source monitor
    task get_source_transaction();
    
      logic [7:0] source_byte;

      forever begin
        fork begin
          fork
            this.source_monitor.wait_for_transaction_event();
            @stop_scoreboard;
          join_any
          disable fork;
        end join
        if (this.enabled == 0)
          break;
        
        this.source_monitor.get_key();
        for (int i=0; i<this.source_monitor.mailbox.num(); ++i) begin
          this.source_monitor.mailbox.get(source_byte);
          this.source_monitor.mailbox.put(source_byte);
          this.source_byte_stream.push_front(source_byte);
        end
        this.source_byte_stream_size += this.source_monitor.mailbox.num();
        `INFOV(("Source transaction received, size: %d - %d", this.source_monitor.mailbox.num(), this.source_byte_stream_size), 200);
        ->>source_transaction_event;
        this.source_monitor.put_key();
      end

    endtask: get_source_transaction

    // get transaction data from sink monitor
    task get_sink_transaction();
    
      logic [7:0] sink_byte;

      forever begin
        fork begin
          fork
            this.sink_monitor.wait_for_transaction_event();
            @stop_scoreboard;
          join_any
          disable fork;
        end join

        if (this.enabled == 0)
          break;

        this.sink_monitor.get_key();
        for (int i=0; i<this.sink_monitor.mailbox.num(); ++i) begin
          this.sink_monitor.mailbox.get(sink_byte);
          this.sink_monitor.mailbox.put(sink_byte);
          this.sink_byte_stream.push_front(sink_byte);
        end
        this.sink_byte_stream_size += this.sink_monitor.mailbox.num();
        `INFOV(("Sink transaction received, size: %d - %d", this.sink_monitor.mailbox.num(), this.sink_byte_stream_size), 200);
        ->>sink_transaction_event;
        this.sink_monitor.put_key();
      end

    endtask: get_sink_transaction

    // compare the collected data
    task compare_transaction();

      logic [7:0] source_byte;
      logic [7:0] sink_byte;

      `INFOV(("Scoreboard started"), 100);

      forever begin : tx_path
        if (this.enabled == 0)
          break;
        if ((this.source_byte_stream_size > 0) &&
              (this.sink_byte_stream_size > 0)) begin
          byte_streams_empty_sig = 0;
          source_byte = this.source_byte_stream.pop_back();
          this.source_byte_stream_size--;
          sink_byte = this.sink_byte_stream.pop_back();
          this.sink_byte_stream_size--;
          `INFOV(("Scoreboard source-sink data: exp %h - rcv %h", source_byte, sink_byte), 100);
          if (source_byte != sink_byte) begin
            `ERROR(("Scoreboard failed at: exp %h - rcv %h", source_byte, sink_byte));
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
            join_any
            byte_streams_empty_sig = 0;
            disable fork;
          end join
        end
      end

    endtask /* compare_transaction */

    // function void post_tx_test();

    //   if (this.enabled == 0) begin
    //     `INFO(("Scoreboard was inactive."));
    //   end else begin
    //       if (comparison_cnt == 0) begin
    //         `ERROR(("TX scoreboard is empty! Check your interfaces or increase the runtime. Collected transactions are %d for source side and %d for sink side.", this.source_byte_stream_size, this.sink_byte_stream_size));
    //       end else if (error_cnt > 0) begin
    //         `ERROR(("ERROR: TX scoreboard has %d errors!", error_cnt));
    //         `INFO(("TX scoreboard has passed. %d bytes were checked.", this.comparison_cnt));
    //         `INFO(("TX transfer size are %d bytes.", this.all_transfer_size));
    //       end else begin
    //         `INFO(("TX scoreboard has passed. %d bytes were checked.", this.comparison_cnt));
    //         `INFO(("TX transfer size are %d bytes.", this.all_transfer_size));
    //       end
    //   end

    // endfunction /* post_tx_test */

    // function void post_rx_test();

    //   if (this.enabled == 0) begin
    //     `INFO(("Scoreboard was inactive."));
    //   end else begin
    //     if (comparison_cnt == 0) begin
    //       `ERROR(("RX scoreboard is empty! Check your interfaces or increase the runtime. Collected transactions are %d for source side and %d for sink side.", this.source_byte_stream_size, this.sink_byte_stream_size));
    //     end else if (error_cnt > 0) begin
    //       `ERROR(("ERROR: RX scoreboard has %d errors!", error_cnt));
    //     end else begin
    //       `INFO(("RX scoreboard has passed. %d bytes were checked.", this.comparison_cnt));
    //     end
    //   end

    // endfunction /* post_rx_test */

  endclass

endpackage
