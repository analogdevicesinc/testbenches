`include "utils.svh"

package transaction_monitor_pkg;

  import xil_common_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import axi_vip_pkg::*;
  import logger_pkg::*;

  class transaction_monitor extends xil_component;

    typedef enum bit { CYCLIC=0, ONESHOT } sink_type_t;
    sink_type_t tx_sink_type;

    typedef enum bit { AXI=0, AXIS } axi_type_t;
    axi_type_t axi_type;

    // List of analysis ports from the monitors
    xil_analysis_port #(axi_monitor_transaction) axi_ap;
    xil_analysis_port #(axi4stream_monitor_transaction) axis_ap;

    // transaction queues (because the source and sink interface can have
    // different widths, byte streams are used)
    logic [7:0] axi_tx_byte_stream [$];
    logic [7:0] axi_rx_byte_stream [$];
    logic [7:0] axis_byte_stream [$];

    // int transfer_size;
    // int all_transfer_size;
    int axi_tx_byte_stream_size;
    int axi_rx_byte_stream_size;
    int axis_byte_stream_size;

    // counters and synchronizers
    bit enabled;
    event end_of_first_cycle;

    // constructor
    function new(input string name);

      super.new(name);

      this.enabled = 0;
      this.axi_type = AXI;
      this.tx_sink_type = CYCLIC;
      // this.transfer_size = 0;
      // this.all_transfer_size = 0;
      this.axi_tx_byte_stream_size = 0;
      this.axi_rx_byte_stream_size = 0;
      this.axis_byte_stream_size = 0;

    endfunction /* new */

    // connect the analysis ports of the monitor to the scoreboard
    function void set_axi_port(
      xil_analysis_port #(axi_monitor_transaction)         axi_ap);

      if (!this.enabled) begin
        this.axi_ap = axi_ap;
        this.axi_type = AXI;
      end else begin
        `ERROR(("ERROR Scoreboard: Can not configure port while scoreboard is running."));
      end

    endfunction /* set_ports */

    // connect the analysis ports of the monitor to the scoreboard
    function void set_axis_port(
      xil_analysis_port #(axi4stream_monitor_transaction)  axis_ap);
      
      if (!this.enabled) begin
        this.axis_ap = axis_ap;
        this.axi_type = AXIS;
      end else begin
        `ERROR(("ERROR Scoreboard: Can not configure port while scoreboard is running."));
      end

    endfunction /* set_ports */

    // run task
    task run();

      fork
        this.enabled = 1;
        if (this.axi_type == AXI)
          get_axi_transaction();
        else
          get_axis_transaction();
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
    task get_axi_transaction();

      axi_monitor_transaction transaction;
      xil_axi_data_beat data_beat;
      int num_bytes;

      forever begin
        if (this.axi_ap.get_item_cnt() > 0) begin
          this.axi_ap.get(transaction);
          num_bytes = transaction.get_data_width()/8;
          for (int i=0; i<(transaction.get_len()+1); i++) begin
            data_beat = transaction.get_data_beat(i);
            for (int j=0; j<num_bytes; j++) begin
              // put each beat into byte queues
              if (transaction.get_cmd_type() == 1'b1) begin  // WRITE
                `INFOV(("Caught a DDR WRITE transaction: %d -- %d", data_beat[j*8+:8], this.axi_rx_byte_stream_size), 100);
                this.axi_rx_byte_stream.push_back(data_beat[j*8+:8]);
                this.axi_rx_byte_stream_size++;
              end else begin  // READ
                `INFOV(("Caught a DDR READ transaction: %d -- %d", data_beat[j*8+:8], this.axi_tx_byte_stream_size), 100);
                this.axi_tx_byte_stream.push_back(data_beat[j*8+:8]);
                this.axi_tx_byte_stream_size++;
                // this.transfer_size++;
                // if (this.transfer_size == this.tx_comparison_cnt) begin
                //   -> end_of_first_cycle;
                // end
              end
            end
          end
        end
        #1;
      end

    endtask /* get_ddr_transaction */

    // collect data from the AXI4Strean interface of the DAC stub, this task
    // handles both ONESHOT and CYCLIC scenarios
    task get_axis_transaction();

      axi4stream_transaction transaction;
      xil_axi4stream_data_beat data_beat;
      int num_bytes;

      forever begin
        if (this.axis_ap.get_item_cnt() > 0) begin
          `INFOV(("Caught a TX AXI4 stream transaction: %d", this.axis_ap.get_item_cnt()), 100);
          this.axis_ap.get(transaction);
          // all bytes from a beat are valid
          num_bytes = transaction.get_data_width()/8;
          data_beat = transaction.get_data_beat();
          for (int j=0; j<num_bytes; j++) begin
            this.axis_byte_stream.push_back(data_beat[j*8+:8]);
            this.axis_byte_stream_size++;
          end

          // this.all_transfer_size += this.transfer_size;

          // // reset the TX source beat counter so we can initiate more than one
          // // DMA transfers in the test program and still check the cyclic mode
          // if (transaction.get_last())
          //   this.transfer_size = 0;

          // this.all_transfer_size += this.transfer_size;
        end
        #1;
      end

    endtask /* get_tx_sink_transaction */

    // collect data from the AXI4Strean interface of the ADC stub
    task get_axis_rx_transaction();

      axi4stream_transaction transaction;
      xil_axi4stream_data_beat data_beat;
      int num_bytes;

      forever begin
        if (this.axis_ap.get_item_cnt() > 0) begin
          `INFOV(("Caught a RX AXI4 stream transaction: %d", this.axis_ap.get_item_cnt()), 100);
          this.axis_ap.get(transaction);
          // all bytes from a beat are valid
          num_bytes = transaction.get_data_width()/8;
          data_beat = transaction.get_data_beat();
          for (int j=0; j<num_bytes; j++) begin
            this.axis_byte_stream.push_back(data_beat[j*8+:8]);
            this.axis_byte_stream_size++;
          end
        end
        #1;
      end

    endtask /* get_rx_source_transaction */

  endclass

endpackage
