// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

package adi_spi_vip_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import adi_spi_vip_if_base_pkg::*;

  `define SPI_VIP_PARAM_ORDER       SPI_VIP_MODE              ,\
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

  `define SPI_VIP_PARAMS(th,vip)    th``_``vip``_0_VIP_MODE,\
                                    th``_``vip``_0_VIP_CPOL,\
                                    th``_``vip``_0_VIP_CPHA,\
                                    th``_``vip``_0_VIP_INV_CS,\
                                    th``_``vip``_0_VIP_DATA_DLENGTH,\
                                    th``_``vip``_0_VIP_SLAVE_TIN,\
                                    th``_``vip``_0_VIP_SLAVE_TOUT,\
                                    th``_``vip``_0_VIP_MASTER_TIN,\
                                    th``_``vip``_0_VIP_MASTER_TOUT,\
                                    th``_``vip``_0_VIP_CS_TO_MISO,\
                                    th``_``vip``_0_VIP_DEFAULT_MISO_DATA

  class adi_spi_driver extends adi_driver;

    typedef bit bitqueue_t [$];
    protected mailbox mosi_mbx;
    mailbox miso_mbx;
    protected bit active;
    protected bit stop_flag;
    protected int default_miso_data;
    protected event tx_mbx_updated;

    adi_spi_vip_if_base vif;

    function new(
      input string name,
      input adi_spi_vip_if_base intf,
      input adi_agent parent = null);

      super.new(name, parent);

      this.vif = intf;
      this.active = 0;
      this.stop_flag = 0;
      this.default_miso_data = vif.get_param_DEFAULT_MISO_DATA();
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
      bitqueue_t mosi_bits;
      logic mosi_logic;
      bit mosi_bit;
      forever begin
        if (vif.get_mode() == SPI_MODE_SLAVE) begin
          vif.wait_cs_active();
          while (vif.get_cs_active()) begin
            for (int i = 0; i<vif.get_param_DATA_DLENGTH(); i++) begin
              if (!vif.get_cs_active()) begin
                break;
                mosi_bits.delete();
              end
              vif.wait_for_sample_edge();
              mosi_logic = vif.get_mosi_delayed();
              assert(!$isunknown(mosi_logic))
              else this.error($sformatf("[SPI VIP] MOSI Rx: unknown mosi bit at sample edge!"));
              mosi_bit = bit'(mosi_logic);
              bitqueue_push_lsb(mosi_bits, mosi_bit);
            end
            mosi_mbx.put(bitqueue_to_int(mosi_bits));
            mosi_bits.delete();
          end
        end
      end
    endtask : rx_mosi

    protected task tx_miso();
        bit using_default;
        bit pending_mbx;
        int miso_data;
        bitqueue_t miso_bits;
      forever begin
        if (vif.get_mode() == SPI_MODE_SLAVE) begin
          vif.wait_cs_active();
          while (vif.get_cs_active()) begin
            // try to get an item from the mailbox, without popping it
            if (!miso_mbx.try_peek(miso_data)) begin
              miso_data = default_miso_data;
              using_default = 1'b1;
            end else begin
              using_default = 1'b0;
            end
            miso_bits = int_to_bitqueue(miso_data,vif.get_param_DATA_DLENGTH());
            pending_mbx = 1'b0;
            // early drive and shift if CPHA=0
            if (vif.get_param_CPHA() == 0) begin
              vif.set_miso_drive_instantaneous(bitqueue_pop_msb(miso_bits));
            end
            for (int i = 0; i<vif.get_param_DATA_DLENGTH(); i++) begin
              fork
                begin
                  fork
                    begin
                      vif.wait_cs_inactive();
                    end
                    begin
                      vif.wait_for_drive_edge();
                    end
                    begin
                      wait (tx_mbx_updated.triggered && i==0 && using_default);
                      pending_mbx = 1'b1;
                    end
                  join_any
                  disable fork;
                end
              join
              if (!vif.get_cs_active()) begin
                // if i!=0, we got !cs_active in the middle of a transaction
                if (i != 0) begin
                  this.fatal($sformatf("[SPI VIP] MISO Tx: early exit due to unexpected CS inactive!"));
                end
                miso_bits.delete();
                break;
              end else if (pending_mbx) begin
                // we were going to transmit default data, but new data arrived between the cs edge and vif.drive_edge
                using_default = 1'b0;
                pending_mbx = 1'b0;
                miso_bits.delete();
                break;
              end else begin
                // vif.drive_edge has arrived
                // don't shift at last edge if CPHA=0
                if (!(vif.get_param_CPHA() == 0 && i == vif.get_param_DATA_DLENGTH()-1)) begin
                  vif.set_miso_drive(bitqueue_pop_msb(miso_bits));
                end
                if (i == vif.get_param_DATA_DLENGTH()-1) begin
                  this.info($sformatf("[SPI VIP] MISO Tx end of transfer."), ADI_VERBOSITY_HIGH);
                  if (!using_default) begin
                    // finally pop an item from the mailbox after a complete transfer
                    miso_mbx.get(miso_data);
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
        vif.wait_cs();
        if (vif.get_mode() == SPI_MODE_SLAVE) begin
          if (!vif.get_cs_active()) begin
            vif.set_miso_oen(1'b0);
          end else begin
            vif.set_miso_oen(1'b1);
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
      input bit [vif.get_param_DATA_DLENGTH()-1:0] default_data
    );
      this.default_miso_data = default_data;
    endfunction : set_default_miso_data

    task put_tx_data(
      input int unsigned data);
      miso_mbx.put(data);
      ->tx_mbx_updated;
    endtask

    task get_rx_data(
      output int unsigned data);
      mosi_mbx.get(data);
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
                this.info($sformatf("[SPI VIP] Stop event triggered."), ADI_VERBOSITY_HIGH);
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
        this.error($sformatf("Already running!"));
      end
    endtask

    task stop();
      if (this.get_active()) begin
        this.stop_flag = 1;
      end else begin
        this.error($sformatf("Already inactive!"));
      end
    endtask

    automatic function int bitqueue_to_int(bitqueue_t bitq);
      int idx = 0;
      int data = 0;
      while (bitq.size() != 0) begin
        data |= (bitq.pop_front() << idx);
        idx++;
      end
      return data;
    endfunction

    automatic function bitqueue_t int_to_bitqueue(int data, int n_bits);
      bitqueue_t bitq;
      for (int i =0; i<n_bits; i++) begin
        bitq.push_back((data>>i) & 1'b1);
      end
      return bitq;
    endfunction

    automatic function bit bitqueue_pop_msb(ref bitqueue_t bitq);
      bit data;
      data = bitq.pop_back();
      return data;
    endfunction

    automatic function void bitqueue_push_lsb(ref bitqueue_t bitq, bit lsb);
      bitq.push_front(lsb);
    endfunction
  endclass

  class adi_spi_sequencer extends adi_sequencer;

    protected adi_spi_driver driver;

    function new(
      input string name,
      input adi_spi_driver driver,
      input adi_agent parent = null);

      super.new(name, parent);

      this.driver = driver;
    endfunction: new

    virtual task automatic send_data(input int unsigned data);
      this.driver.put_tx_data(data);
    endtask : send_data

    virtual task automatic receive_data(output int unsigned data);
      this.driver.get_rx_data(data);
    endtask : receive_data

    virtual task automatic receive_data_verify(input int unsigned expected);
      int unsigned received;
      this.driver.get_rx_data(received);
      if (received !== expected) begin
        this.error($sformatf("Data mismatch. Received : %h; expected %h", received, expected));
      end
    endtask : receive_data_verify

    virtual task flush_send();
      this.driver.flush_tx();
    endtask : flush_send

    virtual function void set_default_miso_data(input int unsigned data);
      this.driver.set_default_miso_data(data);
    endfunction : set_default_miso_data

  endclass

  class adi_spi_agent extends adi_agent;

    protected adi_spi_driver driver;
    adi_spi_sequencer sequencer;

    function new(
      input string name,
      input adi_spi_vip_if_base intf,
      input adi_environment parent = null);

      super.new(name, parent);

      this.driver = new("Driver", intf, this);
      this.sequencer = new("Sequencer", this.driver, this);
    endfunction

    virtual task start();
      fork
        this.driver.start();
      join_none
    endtask : start

    virtual task stop();
      this.driver.stop();
    endtask : stop

  endclass

endpackage
