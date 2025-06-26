// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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
  import adi_vip_pkg::*;
  import adi_environment_pkg::*;
  import adi_spi_vip_if_base_pkg::*;
  import pub_sub_pkg::*;
  import adi_datatypes_pkg::*;

  // forward declaration to avoid errors
  typedef class adi_spi_agent;

  class adi_spi_driver extends adi_driver;

    typedef bit bitqueue_t [$];
    protected mailbox mosi_mbx;
    protected mailbox mosi_monitor_mbx;
    mailbox miso_mbx;
    protected mailbox miso_monitor_mbx;
    protected bit active;
    protected bit stop_flag;
    protected adi_fifo #(bit) default_miso_data;
    protected event tx_mbx_updated;

    adi_spi_vip_if_base vif;

    function new(
      input string name,
      input adi_spi_vip_if_base intf,
      input adi_spi_agent parent = null);

      super.new(name, parent);

      this.vif = intf;
      this.active = 0;
      this.stop_flag = 0;
      this.miso_mbx = new();
      this.mosi_mbx = new();
      //this.default_miso_data = new("default MISO data",32);
      this.set_default_miso_data(vif.get_param_DEFAULT_MISO_DATA());
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
      adi_fifo #(bit) mosi_bits = new("MOSI bits",32); // max DATA_DLENGTH=32
      logic mosi_logic;
      bit mosi_bit;
      forever begin
        if (vif.get_mode() == SPI_MODE_SLAVE) begin
          vif.wait_cs_active();
          while (vif.get_cs_active()) begin
            for (int i = 0; i<vif.get_param_DATA_DLENGTH(); i++) begin
              if (!vif.get_cs_active()) begin
                break;
                mosi_bits.clear();
              end
              vif.wait_for_sample_edge();
              mosi_logic = vif.get_mosi_delayed();
              assert(!$isunknown(mosi_logic))
              else this.error($sformatf("MOSI Rx: unknown MOSI bit at sample edge!"));
              mosi_bit = bit'(mosi_logic);
              mosi_bits.push(mosi_bit);
            end
            mosi_mbx.put(mosi_bits);
            mosi_monitor_mbx.put(mosi_bits);
            mosi_bits.clear();
          end
        end
      end
    endtask : rx_mosi

    protected task tx_miso();
        bit using_default;
        bit pending_mbx;
        //int miso_data;
        //bitqueue_t miso_bits;
        adi_fifo #(bit) miso_bits; // max DATA_DLENGTH=32
      forever begin
        if (vif.get_mode() == SPI_MODE_SLAVE) begin
          vif.wait_cs_active();
          while (vif.get_cs_active()) begin
            // try to get an item from the mailbox, without popping it
            if (!miso_mbx.try_peek(miso_bits)) begin
              miso_bits = new default_miso_data;
              using_default = 1'b1;
            end else begin
              using_default = 1'b0;
            end
            pending_mbx = 1'b0;
            // early drive and shift if CPHA=0
            if (vif.get_param_CPHA() == 0) begin
              vif.set_miso_drive_instantaneous(miso_bits.pop());
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
                miso_bits.clear();
                break;
              end else if (pending_mbx) begin
                // we were going to transmit default data, but new data arrived between the cs edge and vif.drive_edge
                using_default = 1'b0;
                pending_mbx = 1'b0;
                miso_bits.clear();
                break;
              end else begin
                // vif.drive_edge has arrived
                // don't shift at last edge if CPHA=0
                if (!(vif.get_param_CPHA() == 0 && i == vif.get_param_DATA_DLENGTH()-1)) begin
                  vif.set_miso_drive(miso_bits.pop());
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
      adi_fifo #(bit) default_bits = new("default bits",32); // max DATA_DLENGTH=32
      for (int i=vif.get_param_DATA_DLENGTH()-1, i>=0,) begin
        default_bits.push(default_data[i]);
      end
      this.default_miso_data = default_bits;
    endfunction : set_default_miso_data

    task put_tx_data(
      input adi_fifo #(bit) data);
      miso_mbx.put(data);
      ->tx_mbx_updated;
    endtask

    task get_rx_data(
      output adi_fifo #(bit) data);
      mosi_mbx.get(data);
    endtask

    task get_mosi_transaction(
      output adi_fifo #(bit) data);
      mosi_monitor_mbx.get(data);
    endtask

    task get_miso_transaction(
      output adi_fifo #(bit) data);
      miso_monitor_mbx.get(data);
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

  endclass


  class adi_spi_sequencer extends adi_sequencer;

    protected adi_spi_driver driver;

    function new(
      input string name,
      input adi_spi_driver driver,
      input adi_spi_agent parent = null);

      super.new(name, parent);

      this.driver = driver;
    endfunction: new

    // TODO: decide whether this is better with an int unsigned or bit fifo parameter
    // bit fifo, while cleaner, would force whoever uses this class to be aware of the datatypes
    virtual task automatic send_data(input int unsigned data);
      adi_fifo #(bit) tx_data = new("tx data",32);
      for (int i=driver.vif.get_param_DATA_DLENGTH()-1, i>=0,) begin
        tx_data.push((data>>i)&1);
      end
      this.driver.put_tx_data(tx_data);
    endtask : send_data

    // TODO: decide whether this is better with an int unsigned or bit fifo parameter
    // bit fifo, while cleaner, would force whoever uses this class to be aware of the datatypes
    virtual task automatic receive_data(output int unsigned data);
      adi_fifo #(bit) rx_data;
      this.driver.get_rx_data(rx_data);
      data = 0;
      for (int i=driver.vif.get_param_DATA_DLENGTH()-1, i>=0,) begin
        data = ((data<<1) & rx_data.pop());
      end
    endtask : receive_data

    // TODO: does this task make sense with the new infrastructure?
    virtual task automatic receive_data_verify(input int unsigned expected);
      int unsigned received;
      adi_fifo #(bit) expected_data = new("expected data",32);
      for (int i=driver.vif.get_param_DATA_DLENGTH()-1, i>=0,) begin
        expected_data.push((expected>>i)&1);
      end
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

  class adi_spi_monitor extends adi_monitor;

    unsigned int mosi_publisher; // TODO: decide whether to use adi_fifo #(bit) for representing each transfer
    unsigned int miso_publisher; // TODO: decide whether to use adi_fifo #(bit) for representing each transfer
    protected adi_spi_driver driver;
    protected bit enabled;
    protected bit stop_flag;

    function new(
      input string name,
      input adi_spi_driver driver,
      input adi_spi_agent parent = null);

      super.new(name, parent);
      this.driver = driver;
      this.mosi_publisher = new("MOSI Publisher", this);
      this.miso_publisher = new("MISO Publisher", this);
    endfunction: new

    task run();
      if (this.enabled) begin
        this.error($sformatf("Monitor is already running!");
        return;
      end

      this.enabled = 1;
      this.info($sformatf("Monitor enabled"), ADI_VERBOSITY_MEDIUM);

      fork begin
        fork
          begin
            this.get_transaction();
          end
          begin
            @(posedge this.stop_flag);
            this.stop_flag = 0;
            disable fork;
          end
        join_none
      end join
    endtask: run

    function void stop();
      if (this.get_active()) begin
        this.stop_flag = 1;
      end else begin
        this.error($sformatf("Already inactive!"));
      end
    endfunction: stop

    task get_transaction();
      adi_fifo #(bit) mosi_transaction;
      adi_fifo #(bit) miso_transaction;
      // TODO: decide whether to use adi_fifo #(bit) for representing each transfer
      int unsigned mosi_word;
      int unsigned miso_word;
      int unsigned word_len = driver.vif.get_param_DATA_DLENGTH();
      fork
        begin
          forever begin
            this.driver.get_mosi_transaction(mosi_transaction);
            this.info($sformatf("Caught a MOSI SPI transaction: %d bits", mosi_transaction.size()), ADI_VERBOSITY_MEDIUM);
            // TODO: decide whether to use adi_fifo #(bit) for representing each transfer
            mosi_word = 0;
            for (int i=word_len-1, i>=0,) begin
              mosi_word = ((mosi_word<<1) & mosi_transaction.pop());
            end
            this.mosi_publisher.notify(mosi_word);
            mosi_transaction.clear();
          end
        end
        begin
          forever begin
            this.driver.get_miso_transaction(miso_transaction);
            this.info($sformatf("Caught a MISO SPI transaction: %d bits", miso_transaction.size()), ADI_VERBOSITY_MEDIUM);
            // TODO: decide whether to use adi_fifo #(bit) for representing each transfer
            miso_word = 0;
            for (int i=word_len-1, i>=0,) begin
              miso_word = ((miso_word<<1) & miso_transaction.pop());
            end
            this.miso_publisher.notify(miso_transaction);
            miso_transaction.clear();
          end
        end
      join
    endtask: get_transaction

  endclass


  class adi_spi_agent extends adi_agent;

    protected adi_spi_driver driver;
    adi_spi_sequencer sequencer;
    adi_spi_monitor monitor;

    function new(
      input string name,
      input adi_spi_vip_if_base intf,
      input adi_environment parent = null);

      super.new(name, parent);

      this.driver = new("Driver", intf, this);
      this.sequencer = new("Sequencer", this.driver, this);
      this.monitor = new("Monitor", this.driver, this);
    endfunction

    virtual task start();
      fork
        this.driver.start();
        this.monitor.start();
      join_none
    endtask : start

    virtual task stop();
      this.driver.stop();
      this.monitor.stop();
    endtask : stop

  endclass

endpackage
