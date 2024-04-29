interface spi_vip_if #(
  int CPOL=0,
  CPHA=0,
  INV_CS=0,
  DATA_DLENGTH=16,
  SLAVE_TSU=0,
  SLAVE_TH=0,
  MASTER_TSU=0,
  MASTER_TH=0,
  CS_TO_MISO=0
) ();
  logic sclk;
  wire  miso; // need net types here in case tb wants to tristate this
  wire  mosi; // need net types here in case tb wants to tristate this
  logic cs;

  import adi_spi_vip_pkg::*;

  // internal 
  logic intf_slave_mode;
  logic intf_master_mode;
  logic intf_monitor_mode;
  logic cs_active;
  localparam cs_active_level = (INV_CS) ? 1'b1 : 1'b0;

  // hack for parameterized edge. TODO: improve this
  logic sample_edge, drive_edge;
  assign sample_edge  = (CPOL^CPHA) ? !sclk : sclk;
  assign drive_edge   = (CPOL^CPHA) ? sclk : !sclk;
  assign cs_active = (cs == cs_active_level);

  clocking sample_cb @( posedge sample_edge);
    input #(SLAVE_TSU*1ns) mosi;
    input #(MASTER_TSU*1ns) miso;
  endclocking : sample_cb

  clocking drive_cb @( posedge drive_edge);
    output #(MASTER_TH*1ns) mosi;
    output #(SLAVE_TH*1ns) miso;
  endclocking : drive_cb

  clocking cs_cb @(cs);
    output #(CS_TO_MISO*1ns) miso;
  endclocking : cs_cb

  function void set_slave_mode();
    intf_slave_mode   = 1;
    intf_master_mode  = 0;
    intf_monitor_mode = 0;
  endfunction : set_slave_mode

  function void set_master_mode();
    intf_slave_mode   = 0;
    intf_master_mode  = 1;
    intf_monitor_mode = 0;
    $fatal("Unsupported mode master"); //FIXME
  endfunction : set_master_mode

  function void set_monitor_mode();
    intf_slave_mode   = 0;
    intf_master_mode  = 0;
    intf_monitor_mode = 1;
    $fatal("Unsupported mode monitor"); //FIXME
  endfunction : set_monitor_mode


  class adi_spi_driver #(
    int CPOL=0,
    CPHA=0,
    INV_CS=0,
    DATA_DLENGTH=16,
    SLAVE_TSU=0,
    SLAVE_TH=0,
    MASTER_TSU=0,
    MASTER_TH=0,
    CS_TO_MISO=0
  ) extends adi_abstract_spi_driver;

    typedef mailbox #(logic [DATA_DLENGTH-1:0]) spi_mbx_t;
    protected spi_mbx_t mosi_mbx;
    spi_mbx_t miso_mbx;
    protected bit active;
    protected bit stop_flag;
    protected bit [DATA_DLENGTH-1:0] miso_reg;
    protected bit [DATA_DLENGTH-1:0] default_miso_data;

    function new();
      this.active = 0;
      this.stop_flag = 0;
      this.default_miso_data = 0;
      this.miso_mbx = new();
      this.mosi_mbx = new();
    endfunction


    protected function get_active();
      return(this.active);
    endfunction : get_active

    protected function void set_active();
      this.active = 1;
    endfunction : set_active

    protected function void clear_active();
      this.active = 0;
    endfunction : clear_active

    protected task rx_mosi();
      static logic [DATA_DLENGTH-1:0] mosi_data;
      begin
        if (intf_slave_mode) begin
          wait (cs_active); 
          while (cs_active) begin
            for (int i = 0; i<DATA_DLENGTH; i++) begin
              if (!cs_active) begin
                break;
              end
              @(sample_cb)
              mosi_data = {mosi_data[DATA_DLENGTH-2:1], sample_cb.mosi};
            end    
            mosi_mbx.put(mosi_data);
          end
        end
      end
    endtask : rx_mosi

    protected task tx_miso();
      begin  
        wait (cs_active);
        if (!miso_mbx.try_get(miso_reg)) begin
          miso_reg = default_miso_data;
        end
        while (cs_active) begin
          for (int i = 0; i<DATA_DLENGTH; i=i+1) begin
            fork
              begin
                wait (!cs_active);
              end
              begin
                @(drive_cb);
              end
            join_any
            if (!cs_active) begin
              break;
            end
            $display("miso_reg = %h",miso_reg);
            drive_cb.miso <= miso_reg[DATA_DLENGTH-1];
            miso_reg = {miso_reg[DATA_DLENGTH-2:0], 1'b0};
          end
        end        
      end
    endtask : tx_miso

    protected task cs_tristate();
      @(cs_cb) begin
        if (intf_slave_mode) begin
          if (!cs_active) begin
            cs_cb.miso <= 'z;
          end else begin
            cs_cb.miso <= miso_reg[DATA_DLENGTH-1];
          end      
        end
      end
    endtask : cs_tristate

    protected task run();
      fork
          forever begin
            rx_mosi();
          end
          forever begin
            tx_miso();
          end
          //forever begin
            //cs_tristate();
          //end
      join
    endtask : run

    function void set_default_miso_data(
      input bit [DATA_DLENGTH-1:0] default_data
    );
      begin
        this.default_miso_data = default_data;
      end
    endfunction : set_default_miso_data

    task put_tx_data(
      input int unsigned data);
      bit [DATA_DLENGTH-1:0] txdata;
      begin
        $display("put_tx_data: %h",data);
        txdata = data;
        $display("txdata: %h",txdata);
        miso_mbx.put(txdata);
      end
    endtask

    task get_rx_data(
      output int unsigned data);
      bit [DATA_DLENGTH-1:0] rxdata;
      begin
        mosi_mbx.get(rxdata);
        data = rxdata;
      end
    endtask

    task flush_tx();
      begin
        wait (miso_mbx.num()==0);
      end
    endtask

    task start();
      begin
        if (!this.get_active()) begin
          this.set_active();
          fork
            begin
              @(posedge this.stop_flag);
              $display("Stop event triggered.");
            end
            begin
              this.run();
            end
          join_any
          disable fork;
          this.clear_active();
        end else begin
          $error("Already running!");
        end
      end
    endtask

    task stop();
      begin
        this.stop_flag = 1;
      end
    endtask

  endclass

  // Instantiate a driver on this interface
  adi_spi_driver #(
    .CPOL         (CPOL),
    .CPHA         (CPHA),
    .INV_CS       (INV_CS),
    .DATA_DLENGTH (DATA_DLENGTH),
    .SLAVE_TSU    (SLAVE_TSU),
    .SLAVE_TH     (SLAVE_TH),
    .MASTER_TSU   (MASTER_TSU),
    .MASTER_TH    (MASTER_TH),
    .CS_TO_MISO   (CS_TO_MISO)
  ) driver = new();

endinterface