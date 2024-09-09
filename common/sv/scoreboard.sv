`include "utils.svh"

package scoreboard_pkg;

  import xil_common_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import axi_vip_pkg::*;
  import logger_pkg::*;
  import x_monitor_pkg::*;
  import mailbox_pkg::*;
  import filter_pkg::*;

  class scoreboard extends xil_component;

    typedef enum bit {
      CYCLIC=0,   // the source data will remain in the buffer after a check
      ONESHOT     // the source data will be consumed with the sink data
    } transfer_type_t;
    protected transfer_type_t transfer_type;

    // List of analysis ports from the monitors
    protected x_monitor source_monitor;
    protected x_monitor sink_monitor;

    protected logic [7:0] source_byte_stream [$];
    protected logic [7:0] sink_byte_stream [$];

    protected int source_byte_stream_size;
    protected int sink_byte_stream_size;

    // counters and synchronizers
    protected bit enabled;
    protected bit filter_enabled;
    protected bit byte_streams_empty_sig;

    // protected event end_of_first_cycle;
    protected event byte_streams_empty;
    protected event stop_scoreboard;
    protected event source_transaction_event;
    protected event sink_transaction_event;

    // filter trees
    protected filter_tree_class filter_tree_source;
    protected filter_tree_class filter_tree_sink;

    // constructor
    function new(input string name);

      super.new(name);

      this.enabled = 0;
      this.transfer_type = ONESHOT;
      this.source_byte_stream_size = 0;
      this.sink_byte_stream_size = 0;
      this.byte_streams_empty_sig = 1;
      this.filter_enabled = 0;

    endfunction: new

    // connect the analysis ports of the monitor to the scoreboard
    function void set_source_stream(
      x_monitor source_monitor);

      if (!this.enabled)
        this.source_monitor = source_monitor;
      else
        `ERROR(("Cannot set source monitor while scoreboard is running"));

    endfunction: set_source_stream

    function void set_sink_stream(
      x_monitor sink_monitor);

      if (!this.enabled)
        this.sink_monitor = sink_monitor;
      else
        `ERROR(("Cannot set sink monitor while scoreboard is running"));

    endfunction: set_sink_stream

    // enable data filtering
    function void enable_filtering();
      if (!this.enabled)
        this.filter_enabled = 1;
      else
        `ERROR(("Cannot enable data filtering while scoreboard is running"));
    endfunction: enable_filtering

    // disable data filtering
    function void disable_filtering();
      if (!this.enabled)
        this.filter_enabled = 0;
      else
        `ERROR(("Cannot disable data filtering while scoreboard is running"));
    endfunction: disable_filtering

    // set filter tree
    function void set_filter_tree_source(
      filter_tree_class filter_tree);

      if (!this.enabled)
        this.filter_tree_source = filter_tree;
      else
        `ERROR(("Cannot change filter tree while scoreboard is running"));
    endfunction: set_filter_tree_source

    function void set_filter_tree_sink(
      filter_tree_class filter_tree);

      if (!this.enabled)
        this.filter_tree_sink = filter_tree;
      else
        `ERROR(("Cannot change filter tree while scoreboard is running"));
    endfunction: set_filter_tree_sink

    // run task
    task run();

      if (this.filter_tree_source == null && this.filter_tree_sink == null && this.filter_enabled)
        `ERROR(("No filter tree is set"));

      fork
        this.enabled = 1;
        this.get_source_transaction();
        this.get_sink_transaction();
        this.compare_transaction();
      join_none

    endtask: run

    // stop scoreboard
    task stop();
      this.enabled = 0;
      ->>stop_scoreboard;
      this.clear_streams();
      #1step;
    endtask: stop

    // set sink type
    function void set_transfer_type(input bit transfer_type);

      if (!this.enabled) begin
        this.transfer_type = transfer_type_t'(transfer_type);
      end else begin
        `ERROR(("ERROR Scoreboard: Can not configure transfer_type while scoreboard is running."));
      end

    endfunction: set_transfer_type

    // clear source and sink byte streams
    function void clear_streams();
      this.source_byte_stream.delete();
      this.sink_byte_stream.delete();
      
      this.source_byte_stream_size = 0;
      this.sink_byte_stream_size = 0;
    endfunction: clear_streams

    // get sink type
    function bit get_transfer_type();
      return this.transfer_type;
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
      logic [7:0] packet [];

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
        packet = new [this.source_monitor.mailbox.num()];
        `INFOV(("Source packet length: %d", packet.size()), 200);
        for (int i=0; i<packet.size(); ++i) begin
          this.source_monitor.mailbox.get(source_byte);
          this.source_monitor.mailbox.put(source_byte);
          packet[i] = source_byte;
        end
        this.source_monitor.put_key();

        if (this.filter_enabled)
          this.filter_tree_source.apply_filter(packet);

        if (!this.filter_enabled || this.filter_tree_source.result) begin
          for (int i=0; i<packet.size(); ++i) begin
            this.source_byte_stream.push_front(packet[i]);
          end
          this.source_byte_stream_size += packet.size();
          `INFOV(("Source transaction received, size: %d - %d", packet.size(), this.source_byte_stream_size), 200);
          ->>source_transaction_event;
        end
      end

    endtask: get_source_transaction

    // get transaction data from sink monitor
    task get_sink_transaction();
    
      logic [7:0] sink_byte;
      logic [7:0] packet [];

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
        packet = new [this.sink_monitor.mailbox.num()];
        `INFOV(("Sink packet length: %d", packet.size()), 200);
        for (int i=0; i<packet.size(); ++i) begin
          this.sink_monitor.mailbox.get(sink_byte);
          this.sink_monitor.mailbox.put(sink_byte);
          packet[i] = sink_byte;
        end
        this.sink_monitor.put_key();

        if (this.filter_enabled)
          this.filter_tree_sink.apply_filter(packet);

        if (!this.filter_enabled || this.filter_tree_sink.result) begin
          for (int i=0; i<packet.size(); ++i) begin
            this.sink_byte_stream.push_front(packet[i]);
          end
          this.sink_byte_stream_size += packet.size();
          `INFOV(("Sink transaction received, size: %d - %d", packet.size(), this.sink_byte_stream_size), 200);
          ->>sink_transaction_event;
        end
      end

    endtask: get_sink_transaction

    // compare the collected data
    virtual task compare_transaction();

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
          if (this.transfer_type == CYCLIC)
            this.source_byte_stream.push_front(source_byte);
          else
            this.source_byte_stream_size--;
          sink_byte = this.sink_byte_stream.pop_back();
          this.sink_byte_stream_size--;
          `INFOV(("Scoreboard source-sink data: exp %h - rcv %h", source_byte, sink_byte), 100);
          if (source_byte != sink_byte) begin
            `ERROR(("Scoreboard failed at: exp %h - rcv %h", source_byte, sink_byte));
          end
        end else begin
          if (this.sink_byte_stream_size == 0) begin
            if (this.transfer_type == CYCLIC) begin
              byte_streams_empty_sig = 1;
              ->>byte_streams_empty;
            end else begin
              if ((this.source_byte_stream_size == 0)) begin
                byte_streams_empty_sig = 1;
                ->>byte_streams_empty;
              end
            end
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
