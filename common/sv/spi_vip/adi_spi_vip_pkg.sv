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

package adi_spi_vip_pkg;

  import logger_pkg::*;

  `define SPI_VIP_PARAM_ORDER       SPI_SPIO_SIZE             ,\
                                    SPI_VIP_MODE              ,\
                                    SPI_SYNCHRONOUS_MODE      ,\
                                    SPI_VIP_CPOL              ,\
                                    SPI_VIP_CPHA              ,\
                                    SPI_VIP_INV_CS            ,\
                                    SPI_VIP_DATA_DLENGTH      ,\
                                    SPI_VIP_SLAVE_TIN         ,\
                                    SPI_VIP_SLAVE_TOUT        ,\
                                    SPI_VIP_MASTER_TIN        ,\
                                    SPI_VIP_MASTER_TOUT       ,\
                                    SPI_VIP_CS_TO_MISO        ,\
                                    SPI_VIP_DEFAULT_MISO_DATA

  `define SPI_VIP_PARAMS(th,vip)    th``_``vip``_0_VIP_SPIO_SIZE         ,\
                                    th``_``vip``_0_VIP_MODE              ,\
                                    th``_``vip``_0_VIP_SYNCHRONOUS_MODE  ,\
                                    th``_``vip``_0_VIP_CPOL              ,\
                                    th``_``vip``_0_VIP_CPHA              ,\
                                    th``_``vip``_0_VIP_INV_CS            ,\
                                    th``_``vip``_0_VIP_DATA_DLENGTH      ,\
                                    th``_``vip``_0_VIP_SLAVE_TIN         ,\
                                    th``_``vip``_0_VIP_SLAVE_TOUT        ,\
                                    th``_``vip``_0_VIP_MASTER_TIN        ,\
                                    th``_``vip``_0_VIP_MASTER_TOUT       ,\
                                    th``_``vip``_0_VIP_CS_TO_MISO        ,\
                                    th``_``vip``_0_VIP_DEFAULT_MISO_DATA

  typedef bit [`DATA_DLENGTH-1:0] data_type;
  typedef data_type data_array_type[];
  /** Define a wrapper for the array so it can be added to the mailbox
    * solution: //https://verificationacademy.com/forums/t/how-to-put-unpacked-array-to-systemverilog-mailbox/39645
    * It always define one data for each SDI lane
    * if SPI_SPIO_SIZE is 4 (quad SPI), data contains (SPI_VIP_DATA_DLENGTH/SPI_SPIO_SIZE) valid bits
    * if SPI_SPIO_SIZE is 2 (dual SPI):
      * Instruction phase contains 8 valid bits for data[0], and data[1] does not have any content
      * Data phase contains (SPI_VIP_DATA_DLENGTH/SPI_SPIO_SIZE) valid bits for each data
    * if SPI_SPIO_SIZE is 1, each data contains SPI_VIP_DATA_DLENGTH valid bits
  */
  class array_wrapper;
    data_array_type data = new [`SPIO_SIZE];
  endclass

  class adi_spi_driver #(int `SPI_VIP_PARAM_ORDER);

    typedef mailbox #(array_wrapper) spi_mbx_t;
    protected spi_mbx_t                                mosi_mbx;
    spi_mbx_t                                          miso_mbx;
    protected bit                                      active;
    protected bit                                      stop_flag;
    protected array_wrapper                            miso_reg = new();
    protected array_wrapper                            miso_rearranged_reg = new();
    protected bit [SPI_VIP_DATA_DLENGTH-1:0]           default_miso_data;
    protected event                                    tx_mbx_updated;
    virtual spi_vip_if #(`SPI_VIP_PARAM_ORDER)         vif;

    function new(virtual spi_vip_if #(`SPI_VIP_PARAM_ORDER) intf);
      this.vif                 = intf;
      this.active              = 0;
      this.stop_flag           = 0;
      this.default_miso_data   = SPI_VIP_DEFAULT_MISO_DATA;
      this.miso_mbx            = new();
      this.mosi_mbx            = new();
      // this.miso_reg            = new();
      // this.miso_rearranged_reg = new();
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
      int VIP_DATA_SIZE = (SPI_SPIO_SIZE == 2) ? (8 + (SPI_VIP_DATA_DLENGTH-8)/SPI_SPIO_SIZE) : (SPI_VIP_DATA_DLENGTH/SPI_SPIO_SIZE);
      static array_wrapper mosi_data = new();
      // static logic [SPI_VIP_DATA_DLENGTH-1:0] mosi_data;
      forever begin
        if (vif.intf_slave_mode) begin
          wait (vif.cs_active);
          while (vif.cs_active) begin
            for (int i = 0; i < VIP_DATA_SIZE; i++) begin
              if (!vif.cs_active) begin
                break;
              end
              @(posedge vif.sample_edge)
              foreach (mosi_data.data[j]) begin
                mosi_data.data[j] = {mosi_data.data[j][SPI_VIP_DATA_DLENGTH-2:0], vif.mosi_delayed[j]};
              end
            end
            mosi_mbx.put(mosi_data);
          end
        end
      end
    endtask : rx_mosi

    protected task rearrange_data(output using_default);
      bit empty = !miso_mbx.try_peek(miso_reg); //if it is not empty, miso_reg is already populated
      bit QUAD_SPI = (SPI_SPIO_SIZE == 4);
      int word_index = 0;
      int bit_index = SPI_VIP_DATA_DLENGTH-1;
      int cont = 0;

      for (int i = 0; i < SPI_SPIO_SIZE; i = i+1) begin
        if (SPI_SYNCHRONOUS_MODE) begin //one word copy for each lane
          if (empty) begin
            miso_rearranged_reg.data[i] = default_miso_data;
            using_default = 1'b1;
          end else begin
            miso_rearranged_reg.data[i] = miso_reg.data[i];
            using_default = 1'b0;
          end
        end else begin //a single word shared among the SDI lanes
          for (int j = SPI_VIP_DATA_DLENGTH-1; j >= 0; j = j - 1) begin
            if (empty) begin
              miso_rearranged_reg.data[word_index][bit_index] = default_miso_data[j];
              using_default = 1'b1;
            end else begin
              miso_rearranged_reg.data[word_index][bit_index] = miso_reg.data[i][j];
              using_default = 1'b0;
            end

            if (QUAD_SPI || cont >= 8) begin
              word_index = j % SPI_SPIO_SIZE;
              if ((word_index == 0) && (j != 0)) begin
                bit_index = bit_index - 1;
              end
            end else begin //Dual SPI or Classic SPI always send the first byte (intruction phase) into SDI0 lane
              word_index = 0;
              bit_index = bit_index - 1;
            end
            cont = cont + 1;
          end
        end
      end
    endtask : rearrange_data

    protected task tx_miso();
      bit using_default;
      bit pending_mbx;
      //make it generic for 8 bit and 16 bit addressing
      //Dual SPI or Classic SPI always send the first byte (intruction phase) into SDI0 lane
      int VIP_DATA_SIZE = (SPI_SPIO_SIZE == 2) ? (8 + (SPI_VIP_DATA_DLENGTH-8)/SPI_SPIO_SIZE) : (SPI_VIP_DATA_DLENGTH/SPI_SPIO_SIZE);

      forever begin
        if (vif.intf_slave_mode) begin
          wait (vif.cs_active);
          while (vif.cs_active) begin
            rearrange_data(using_default);
            pending_mbx = 1'b0;
            // early drive and shift if CPHA=0
            if (SPI_VIP_CPHA == 0) begin
              foreach (vif.miso_drive[i]) begin
                vif.miso_drive[i] <= miso_rearranged_reg.data[i][SPI_VIP_DATA_DLENGTH-1];
                miso_rearranged_reg.data[i] = {miso_rearranged_reg.data[i][SPI_VIP_DATA_DLENGTH-2:0], 1'b0};
              end
            end
            for (int i = 0; i < VIP_DATA_SIZE; i++) begin
              fork
                begin
                  fork
                    begin
                      wait (!vif.cs_active);
                    end
                    begin
                      @(posedge vif.drive_edge);
                    end
                    begin
                      @(tx_mbx_updated.triggered);
                      pending_mbx = 1'b1;
                    end
                  join_any
                  disable fork;
                end
              join
              if (!vif.cs_active) begin
                // if i!=0, we got !cs_active in the middle of a transaction
                if (i != 0) begin
                  `ERROR(("tx_miso: early exit due to unexpected CS inactive!"));
                end
                break;
              end else if (pending_mbx && using_default && i == 0) begin
                // we were going to transmit default data, but new data arrived between the cs edge and vif.drive_edge
                using_default = 1'b0;
                pending_mbx = 1'b0;
                break;
              end else begin
                // vif.drive_edge has arrived
                // don't shift at last edge if CPHA=0
                if (!(SPI_VIP_CPHA == 0 && i == VIP_DATA_SIZE-1)) begin
                  foreach (vif.miso_drive[i]) begin
                    vif.miso_drive[i] <= miso_rearranged_reg.data[i][SPI_VIP_DATA_DLENGTH-1];
                    miso_rearranged_reg.data[i] = {miso_rearranged_reg.data[i][SPI_VIP_DATA_DLENGTH-2:0], 1'b0};
                  end
                end
                if (i == VIP_DATA_SIZE-1) begin
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
      end
    endtask : tx_miso

    protected task cs_tristate();
      forever begin
        @(vif.cs)
        if (vif.intf_slave_mode) begin
          if (!vif.cs_active) begin
            vif.miso_oen <= #(SPI_VIP_CS_TO_MISO*1ns) 1'b0;
          end else begin
            vif.miso_oen <= #(SPI_VIP_CS_TO_MISO*1ns) 1'b1;
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
      input bit [SPI_VIP_DATA_DLENGTH-1:0] default_data
    );
      this.default_miso_data = default_data;
    endfunction : set_default_miso_data

    task put_tx_data(
      input data_array_type data);
      array_wrapper txdata;
      txdata = new();

      foreach (data[i]) begin
        txdata.data[i] = data[i];
      end

      miso_mbx.put(txdata);
      ->tx_mbx_updated;
    endtask

    task get_rx_data(
      output data_array_type data);
      array_wrapper rxdata;
      rxdata = new();
      mosi_mbx.get(rxdata);

      foreach (data[i]) begin
        data[i] = rxdata.data[i];
      end
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

  class adi_spi_agent #(int `SPI_VIP_PARAM_ORDER);

    protected adi_spi_driver #(`SPI_VIP_PARAM_ORDER) driver;

    function new(virtual spi_vip_if #(`SPI_VIP_PARAM_ORDER) intf);
      this.driver = new(intf);
    endfunction

    virtual task send_data(input data_array_type data);
      this.driver.put_tx_data(data);
    endtask : send_data

    virtual task receive_data(output data_array_type data);
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

    virtual function void set_default_miso_data(input int unsigned data);
      this.driver.set_default_miso_data(data);
    endfunction : set_default_miso_data

  endclass

endpackage