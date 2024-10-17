`include "utils.svh"

package do_scoreboard_pkg;

  import xil_common_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import axi_vip_pkg::*;
  import logger_pkg::*;

  class do_scoreboard extends xil_component;

    typedef enum bit { CYCLIC=0, ONESHOT } sink_type_t;
    sink_type_t tx_sink_type ;

    // List of analysis ports from the monitors
    xil_analysis_port #(axi_monitor_transaction) ddr_axi_ap;
    xil_analysis_port #(axi4stream_monitor_transaction) tx_sink_axis_ap;
    xil_analysis_port #(axi4stream_monitor_transaction) rx_source_axis_ap;

    // transaction queues (because the source and sink interface can have
    // different widths, byte streams are used)
    logic [7:0] tx_source_byte_stream [$];
    logic [7:0] rx_sink_byte_stream [$];
    logic [7:0] tx_cyclic_sink_byte_stream [$];
    logic [7:0] tx_sink_byte_stream [$];
    logic [7:0] rx_source_byte_stream [$];

    int tx_transfer_size;
    int tx_all_transfer_size;
    int tx_source_byte_stream_size;
    int tx_sink_byte_stream_size;
    int rx_source_byte_stream_size;
    int rx_sink_byte_stream_size;

    // counters and synchronizers
    bit enabled;
    xil_uint rx_error_cnt;
    xil_uint tx_error_cnt;
    xil_uint rx_comparison_cnt;
    xil_uint tx_comparison_cnt;
    event end_of_first_cycle;

    // constructor
    function new(input string name);
      super.new(name);
      this.enabled = 0;
      this.rx_error_cnt = 0;
      this.tx_error_cnt = 0;
      this.rx_comparison_cnt = 0;
      this.tx_comparison_cnt = 0;
      this.tx_sink_type = CYCLIC;
      this.tx_transfer_size = 0;
      this.tx_all_transfer_size = 0;
      this.tx_source_byte_stream_size = 0;
      this.tx_sink_byte_stream_size = 0;
      this.rx_source_byte_stream_size = 0;
      this.rx_sink_byte_stream_size = 0;
    endfunction /* new */

    // connect the analysis ports of the monitor to the scoreboard
    function void set_ports(
      xil_analysis_port #(axi_monitor_transaction)         ddr_axi_ap,
      xil_analysis_port #(axi4stream_monitor_transaction)  tx_sink_axis_ap,
      xil_analysis_port #(axi4stream_monitor_transaction)  rx_source_axis_ap);
      this.ddr_axi_ap = ddr_axi_ap;
      this.tx_sink_axis_ap = tx_sink_axis_ap;
      this.rx_source_axis_ap = rx_source_axis_ap;
    endfunction /* set_ports */

    // run task
    task run();
      fork
        this.enabled = 1;
        get_ddr_transaction();
        get_tx_sink_transaction();
        get_rx_source_transaction();
        compare_tx_transaction();
        compare_rx_transaction();
        verify_tx_cyclic();
      join_none
    endtask /* run */

    // set sink type
    function void set_sink_type(input bit sink_type);
      if (!this.enabled) begin
        this.tx_sink_type = sink_type_t'(sink_type);
      end else begin
        `ERROR(("ERROR Scoreboard: Can not configure sink_type while scoreboard is running."));
      end
    endfunction

    // get sink type
    function bit get_sink_type();
      return this.tx_sink_type;
    endfunction

    // collect data from the DDR interface, all WRITE transaction are coming
    // from the ADC and all READ transactions are going to the DAC
    task get_ddr_transaction();

      axi_monitor_transaction transaction;
      xil_axi_data_beat data_beat;
      int num_bytes;

      forever begin
        if (this.ddr_axi_ap.get_item_cnt() > 0) begin
          this.ddr_axi_ap.get(transaction);
          num_bytes = transaction.get_data_width()/8;
          for (int i=0; i<(transaction.get_len()+1); i++) begin
            data_beat = transaction.get_data_beat(i);
            for (int j=0; j<num_bytes; j++) begin
              // put each beat into byte queues
              if (transaction.get_cmd_type() == 1'b1) begin  // WRITE
                `INFOV(("Caught a DDR WRITE transaction: %d -- %d", data_beat[j*8+:8], this.rx_sink_byte_stream_size), 100);
                this.rx_sink_byte_stream.push_back(data_beat[j*8+:8]);
                this.rx_sink_byte_stream_size++;
              end else begin  // READ
                `INFOV(("Caught a DDR READ transaction: %d -- %d", data_beat[j*8+:8], this.tx_source_byte_stream_size), 100);
                this.tx_source_byte_stream.push_back(data_beat[j*8+:8]);
                this.tx_cyclic_sink_byte_stream.push_back(data_beat[j*8+:8]);
                this.tx_source_byte_stream_size++;
                this.tx_transfer_size++;
                if (this.tx_transfer_size == this.tx_comparison_cnt) begin
                  -> end_of_first_cycle;
                end
              end
            end
          end
        end
        #1;
      end

    endtask /* get_ddr_transaction */

    // collect data from the AXI4Strean interface of the DAC stub, this task
    // handles both ONESHOT and CYCLIC scenarios
    task get_tx_sink_transaction();

      axi4stream_transaction transaction;
      xil_axi4stream_data_beat data_beat;
      int num_bytes;

      forever begin
        if (this.tx_sink_axis_ap.get_item_cnt() > 0) begin
          `INFOV(("Caught a TX AXI4 stream transaction: %d", this.tx_sink_axis_ap.get_item_cnt()), 100);
          this.tx_sink_axis_ap.get(transaction);
          // all bytes from a beat are valid
          num_bytes = transaction.get_data_width()/8;
          data_beat = transaction.get_data_beat();
          for (int j=0; j<num_bytes; j++) begin
            this.tx_sink_byte_stream.push_back(data_beat[j*8+:8]);
            this.tx_sink_byte_stream_size++;
          end

          this.tx_all_transfer_size += this.tx_transfer_size;

          // reset the TX source beat counter so we can initiate more than one
          // DMA transfers in the test program and still check the cyclic mode
          if (transaction.get_last())
            this.tx_transfer_size = 0;

          this.tx_all_transfer_size += this.tx_transfer_size;
        end
        #1;
      end

    endtask /* get_tx_sink_transaction */

    // collect data from the AXI4Strean interface of the ADC stub
    task get_rx_source_transaction();

      axi4stream_transaction transaction;
      xil_axi4stream_data_beat data_beat;
      int num_bytes;

      forever begin
        if (this.rx_source_axis_ap.get_item_cnt() > 0) begin
          `INFOV(("Caught a RX AXI4 stream transaction: %d", this.rx_source_axis_ap.get_item_cnt()), 100);
          this.rx_source_axis_ap.get(transaction);
          // all bytes from a beat are valid
          num_bytes = transaction.get_data_width()/8;
          data_beat = transaction.get_data_beat();
          for (int j=0; j<num_bytes; j++) begin
            this.rx_source_byte_stream.push_back(data_beat[j*8+:8]);
            this.rx_source_byte_stream_size++;
          end
        end
        #1;
      end

    endtask /* get_rx_source_transaction */

    // compare the collected data
    task compare_rx_transaction();

      logic [7:0] sink_byte;
      logic [7:0] source_byte;

      forever begin : rx_path
        if ((this.rx_source_byte_stream_size > 0) &&
              (this.rx_sink_byte_stream_size > 0)) begin
          source_byte = this.rx_source_byte_stream.pop_front();
          this.rx_source_byte_stream_size--;
          sink_byte = this.rx_sink_byte_stream.pop_front();
          this.rx_sink_byte_stream_size--;
          `INFOV(("Scoreboard RX sink/source data: exp %h - rcv %h", source_byte, sink_byte), 100);
          if (source_byte !== sink_byte) begin
            `ERROR(("RX Scoreboard failed at: exp %h - rcv %h", source_byte, sink_byte));
            this.rx_error_cnt++;
            this.rx_comparison_cnt++;
          end else begin
            this.rx_comparison_cnt++;
          end
        end
        #1;
      end

    endtask /* compare_rx_transaction */

    task compare_tx_transaction();

      logic [7:0] source_byte;
      logic [7:0] sink_byte;

      forever begin : tx_path
        if ((this.tx_source_byte_stream_size > 0) &&
              (this.tx_sink_byte_stream_size > 0)) begin
          source_byte = this.tx_source_byte_stream.pop_front();
          this.tx_source_byte_stream_size--;
          sink_byte = this.tx_sink_byte_stream.pop_front();
          this.tx_sink_byte_stream_size--;
          `INFOV(("Scoreboard TX sink/source data: exp %h - rcv %h", source_byte, sink_byte), 100);
          if (source_byte !== sink_byte) begin
            `INFOV(("TX Scoreboard failed at: exp %h - rcv %h", source_byte, sink_byte), 100);
            this.tx_error_cnt++;
            this.tx_comparison_cnt++;
          end else begin
            this.tx_comparison_cnt++;
          end
        end
        #1;
      end

    endtask /* compare_tx_transaction */

    // verify cyclic mode
    task verify_tx_cyclic();

      logic [7:0] source_byte;
      logic [7:0] sink_byte;

      @ end_of_first_cycle;
      repeat (1000) #10; // add delay

      forever begin
        if (this.tx_sink_byte_stream_size > 0) begin
          source_byte = this.tx_cyclic_sink_byte_stream.pop_front();
          this.tx_cyclic_sink_byte_stream.push_back(source_byte);
          sink_byte = this.tx_sink_byte_stream.pop_front();
          this.tx_sink_byte_stream_size--;
          if (source_byte !== sink_byte) begin
             `ERROR(("TX cyclic scoreboard failed at %s: exp %h - rcv %h", this.get_type_name(), source_byte, sink_byte));
            this.tx_error_cnt++;
            this.tx_comparison_cnt++;
          end else begin
            this.tx_comparison_cnt++;
          end
        end
        #1;
      end

    endtask /* verify_cyclic */

    function void post_tx_test();
      if (this.enabled == 0) begin
        `INFO(("Scoreboard was inactive."));
      end else begin
          if (tx_comparison_cnt == 0) begin
            `ERROR(("TX scoreboard is empty! Check your interfaces or increase the runtime. Collected transactions are %d for source side and %d for sink side.", this.tx_source_byte_stream_size, this.tx_sink_byte_stream_size));
          end else if (tx_error_cnt > 0) begin
            `ERROR(("ERROR: TX scoreboard has %d errors!", tx_error_cnt));
            `INFO(("TX scoreboard has passed. %d bytes were checked.", this.tx_comparison_cnt));
            `INFO(("TX transfer size are %d bytes.", this.tx_all_transfer_size));
          end else begin
            `INFO(("TX scoreboard has passed. %d bytes were checked.", this.tx_comparison_cnt));
            `INFO(("TX transfer size are %d bytes.", this.tx_all_transfer_size));
          end
      end
    endfunction /* post_tx_test */

    function void post_rx_test();
      if (this.enabled == 0) begin
        `INFO(("Scoreboard was inactive."));
      end else begin
        if (rx_comparison_cnt == 0) begin
          `ERROR(("RX scoreboard is empty! Check your interfaces or increase the runtime. Collected transactions are %d for source side and %d for sink side.", this.rx_source_byte_stream_size, this.rx_sink_byte_stream_size));
        end else if (rx_error_cnt > 0) begin
          `ERROR(("ERROR: RX scoreboard has %d errors!", rx_error_cnt));
        end else begin
          `INFO(("RX scoreboard has passed. %d bytes were checked.", this.rx_comparison_cnt));
        end
      end
    endfunction /* post_rx_test */

  endclass

endpackage
