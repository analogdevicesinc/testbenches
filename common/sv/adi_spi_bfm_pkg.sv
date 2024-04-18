// ***************************************************************************
// ***************************************************************************
// Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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
//      <https://www.gnu.org/licenses/old-licenses/gpl_2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on_line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

package adi_spi_bfm_pkg;

  import logger_pkg::*;

  // This helps us in dealing with systemverilog's awful parameterized interfaces (since there's no polymorphism there)
  `define SPI_VIF_PARAM_DECL #(int CPOL=0, CPHA=0, INV_CS=0, DATA_DLENGTH=16, SLAVE_TSU=0ns, SLAVE_TH=0ns, MASTER_TSU=0ns, MASTER_TH=0ns, CS_TO_MISO=0ns)
  `define SPI_VIF_PARAM_ORDER #(CPOL, CPHA, INV_CS, DATA_DLENGTH, SLAVE_TSU, SLAVE_TH, MASTER_TSU, MASTER_TH, CS_TO_MISO)
  `define SPI_VIF_PARAMS #(`CPOL, `CPHA, 0, `DATA_DLENGTH, `SLAVE_TSU, `SLAVE_TH, `MASTER_TSU, `MASTER_TH, `CS_TO_MISO)
  
  class adi_spi_driver `SPI_VIF_PARAM_DECL;
    virtual interface spi_bfm_if `SPI_VIF_PARAM_ORDER vif;
    protected string name = "adi_spi_driver";

    typedef mailbox #(logic [DATA_DLENGTH-1:0]) spi_mbx_t;
    protected spi_mbx_t mosi_mbx;
    spi_mbx_t miso_mbx;
    protected bit active;
    protected bit stop_flag;
    protected bit [DATA_DLENGTH-1:0] miso_reg;
    protected bit [DATA_DLENGTH-1:0] default_miso_data;

    function new(string name, virtual spi_bfm_if `SPI_VIF_PARAM_ORDER intf);
      this.name = {name,"_driver"};
      this.vif = intf;
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
        if (vif.intf_slave_mode) begin
          wait (vif.cs_active); 
          while (vif.cs_active) begin
            for (int i = 0; i<DATA_DLENGTH; i++) begin
              if (!vif.cs_active) begin
                break;
              end
              @(vif.sample_cb)
              mosi_data = {mosi_data[DATA_DLENGTH-2:1], vif.sample_cb.mosi};
            end    
            mosi_mbx.put(mosi_data);
          end
        end
      end
    endtask : rx_mosi

    protected task tx_miso();
      begin  
        wait (vif.cs_active);
        if (!miso_mbx.try_get(miso_reg)) begin
          miso_reg = default_miso_data;
          vif.drive_cb.miso <= 0;
        end else begin
          while (vif.cs_active) begin
            for (int i = 0; i<DATA_DLENGTH; i=i+1) begin
              fork
                begin
                  wait (!vif.cs_active);
                end
                begin
                  @(vif.drive_cb);
                end
              join_any
              if (!vif.cs_active) begin
                break;
              end
              vif.drive_cb.miso <= miso_reg[DATA_DLENGTH-1];
              miso_reg = {miso_reg[DATA_DLENGTH-2:0], 1'b0};
            end
          end
        end
      end
    endtask : tx_miso

    protected task cs_tristate();
      @(vif.cs_cb) begin
        if (vif.intf_slave_mode) begin
          if (!vif.cs_active) begin
            vif.cs_cb.miso <= 'z;
          end else begin
            vif.cs_cb.miso <= miso_reg[DATA_DLENGTH-1];
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
      input logic [DATA_DLENGTH-1:0] data);
      begin
        miso_mbx.put(data);
      end
    endtask

    task get_rx_data(
      output logic [DATA_DLENGTH-1:0] data);
      begin
        mosi_mbx.get(data);
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
              `INFOV(("Stop event triggered."),2);
            end
            begin
              this.run();
            end
          join_any
          disable fork;
          this.clear_active();
        end else begin
          `ERROR(("Already running!"));
        end
      end
    endtask

    task stop();
      begin
        this.stop_flag = 1;
      end
    endtask

  endclass


  class adi_spi_agent `SPI_VIF_PARAM_DECL;

    virtual interface spi_bfm_if `SPI_VIF_PARAM_ORDER vif;

    adi_spi_driver `SPI_VIF_PARAM_ORDER driver;
    protected string  name ="adi_spi_agent";


    function new(string name, virtual spi_bfm_if `SPI_VIF_PARAM_ORDER intf);
      this.driver = new(name, intf);
      this.vif = intf;
      this.name = name;
    endfunction

    virtual task send_data(input bit[DATA_DLENGTH-1:0] data);
      this.driver.put_tx_data(data);
    endtask : send_data

    virtual task receive_data(output bit[DATA_DLENGTH-1:0] data);
      this.driver.get_rx_data(data);
    endtask : receive_data

    virtual task flush_send();
      this.driver.flush_tx();
    endtask : flush_send

    virtual task start();
      fork
        this.driver.start();
      join_none
    endtask : start

    virtual task stop();
      this.driver.stop();
    endtask : stop

    virtual function set_default_miso_data(input bit[DATA_DLENGTH-1:0] data);
      this.driver.set_default_miso_data(data);
    endfunction : set_default_miso_data

  endclass

endpackage