`include "utils.svh"

interface spi_vip_if #(
  int CPOL=0,
  CPHA=0,
  INV_CS=0,
  DATA_DLENGTH=16,
  SLAVE_TIN=0,
  SLAVE_TOUT=0,
  MASTER_TIN=0,
  MASTER_TOUT=0,
  CS_TO_MISO=0
) ();
  logic sclk;
  wire  miso; // need net types here in case tb wants to tristate this
  wire  mosi; // need net types here in case tb wants to tristate this
  logic cs;

  import adi_spi_vip_pkg::*;
  import logger_pkg::*;

  // internal 
  logic intf_slave_mode;
  logic intf_master_mode;
  logic intf_monitor_mode;
  logic miso_oen;
  logic miso_drive;
  logic cs_active;
  logic mosi_delayed;
  localparam CS_ACTIVE_LEVEL = (INV_CS) ? 1'b1 : 1'b0;

  // hack for parameterized edge. TODO: improve this
  logic sample_edge, drive_edge;
  assign sample_edge  = (CPOL^CPHA) ? !sclk : sclk;
  assign drive_edge   = (CPOL^CPHA) ? sclk : !sclk;
  assign cs_active = (cs == CS_ACTIVE_LEVEL);

  // miso tri-state handling
  assign miso = (!intf_slave_mode)  ? 'z          
              : (miso_oen)          ? miso_drive  
                /*default*/         : 'z;

  // mosi delay
  assign #(SLAVE_TIN*1ns) mosi_delayed =  mosi;

  function void set_slave_mode();
    intf_slave_mode   = 1;
    intf_master_mode  = 0;
    intf_monitor_mode = 0;
  endfunction : set_slave_mode

  function void set_master_mode();
    intf_slave_mode   = 0;
    intf_master_mode  = 1;
    intf_monitor_mode = 0;
    `ERROR(("Unsupported mode master")); //TODO
  endfunction : set_master_mode

  function void set_monitor_mode();
    intf_slave_mode   = 0;
    intf_master_mode  = 0;
    intf_monitor_mode = 1;
    `ERROR(("Unsupported mode monitor")); //TODO
  endfunction : set_monitor_mode


  class adi_spi_driver #(
    int CPOL=0,
    CPHA=0,
    INV_CS=0,
    DATA_DLENGTH=16,
    SLAVE_TIN=0,
    SLAVE_TOUT=0,
    MASTER_TIN=0,
    MASTER_TOUT=0,
    CS_TO_MISO=0
  ) extends adi_abstract_spi_driver;

    typedef mailbox #(logic [DATA_DLENGTH-1:0]) spi_mbx_t;
    protected spi_mbx_t mosi_mbx;
    spi_mbx_t miso_mbx;
    protected bit active;
    protected bit stop_flag;
    protected bit [DATA_DLENGTH-1:0] miso_reg;
    protected bit [DATA_DLENGTH-1:0] default_miso_data;
    protected event tx_mbx_updated;

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
      forever begin
        if (intf_slave_mode) begin
          wait (cs_active); 
          while (cs_active) begin
            for (int i = 0; i<DATA_DLENGTH; i++) begin
              if (!cs_active) begin
                break;
              end
              @(posedge sample_edge)
              mosi_data <= {mosi_data[DATA_DLENGTH-2:0], mosi_delayed};
            end    
            mosi_mbx.put(mosi_data);
          end
        end
      end
    endtask : rx_mosi

    protected task tx_miso();
        bit using_default;
        bit pending_mbx;
      forever begin
        wait (cs_active);
        while (cs_active) begin
           // try to get an item from the mailbox, without popping it
          if (!miso_mbx.try_peek(miso_reg)) begin
            miso_reg = default_miso_data;
            using_default = 1'b1;
          end else begin
            using_default = 1'b0;
          end
          pending_mbx = 1'b0;
          // early drive and shift if CPHA=0
          if (CPHA == 0) begin 
            miso_drive <= miso_reg[DATA_DLENGTH-1];
            miso_reg = {miso_reg[DATA_DLENGTH-2:0], 1'b0};
          end
          for (int i = 0; i<DATA_DLENGTH; i++) begin
            fork
              begin
                fork
                  begin
                    wait (!cs_active);
                  end
                  begin
                    @(posedge drive_edge);
                  end
                  begin
                    @(tx_mbx_updated.triggered);
                    pending_mbx = 1'b1;
                  end
                join_any
                disable fork;
              end
            join
            if (!cs_active) begin
              // if i!=0, we got !cs_active in the middle of a transaction
              if (i != 0) begin
                `ERROR(("tx_miso: early exit due to unexpected CS inactive!"));
              end
              break;
            end else if (pending_mbx && using_default && i == 0) begin
              // we were going to transmit default data, but new data arrived between the cs edge and drive_edge
              using_default = 1'b0;
              pending_mbx = 1'b0;
              break;
            end else begin
              // drive_edge has arrived
              // don't shift at last edge if CPHA=0
              if (!(CPHA == 0 && i == DATA_DLENGTH-1)) begin
                miso_drive <= #(SLAVE_TOUT) miso_reg[DATA_DLENGTH-1];
                miso_reg = {miso_reg[DATA_DLENGTH-2:0], 1'b0};
              end
              if (i == DATA_DLENGTH-1) begin
                `INFO(("[SPI VIP] MISO Tx end of transfer."));
                if (!using_default) begin
                  // finally pop an item from the mailbox after a complete transfer
                  miso_mbx.get(miso_reg);
                end
              end
            end
          end
        end
      end
    endtask : tx_miso

    protected task cs_tristate();
      forever begin
        @(cs) 
        if (intf_slave_mode) begin
          if (!cs_active) begin
            miso_oen <= #(CS_TO_MISO*1ns) 1'b0;
          end else begin
            miso_oen <= #(CS_TO_MISO*1ns) 1'b1;
          end      
        end
      end
    endtask : cs_tristate

    protected task run();
      fork
          begin
            rx_mosi();
          end
          begin
            tx_miso();
          end
          begin
            cs_tristate();
          end
      join
    endtask : run

    function void set_default_miso_data(
      input bit [DATA_DLENGTH-1:0] default_data
    );
      this.default_miso_data = default_data;
    endfunction : set_default_miso_data

    task put_tx_data(
      input int unsigned data);
      bit [DATA_DLENGTH-1:0] txdata;
      txdata = data;
      miso_mbx.put(txdata);
      ->tx_mbx_updated;
    endtask

    task get_rx_data(
      output int unsigned data);
      bit [DATA_DLENGTH-1:0] rxdata;
      mosi_mbx.get(rxdata);
      data = rxdata;
    endtask

    task flush_tx();
      wait (miso_mbx.num()==0);
    endtask

    task start();
      if (!this.get_active()) begin
        this.set_active();
        fork
          begin
            fork
              begin
                @(posedge this.stop_flag);
                `INFO(("[SPI VIP] Stop event triggered."));
                this.stop_flag = 0;
              end
              begin
                this.run();
              end
            join_any
            disable fork;
          end
        join
        this.clear_active();
      end else begin
        `ERROR(("Already running!"));
      end
    endtask

    task stop();
      if (this.get_active()) begin
        this.stop_flag = 1;
      end else begin
        `ERROR(("Already inactive!"));
      end
    endtask

  endclass

  // Instantiate a driver on this interface
  adi_spi_driver #(
    .CPOL         (CPOL),
    .CPHA         (CPHA),
    .INV_CS       (INV_CS),
    .DATA_DLENGTH (DATA_DLENGTH),
    .SLAVE_TIN    (SLAVE_TIN),
    .SLAVE_TOUT   (SLAVE_TOUT),
    .MASTER_TIN   (MASTER_TIN),
    .MASTER_TOUT  (MASTER_TOUT),
    .CS_TO_MISO   (CS_TO_MISO)
  ) driver = new();

endinterface