// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2026 Analog Devices, Inc. All rights reserved.
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

  // forward declaration to avoid errors
  typedef class adi_spi_agent;

  class adi_spi_driver extends adi_driver;

    typedef bit bitqueue_t [$];
    protected mailbox #(int) mosi_mbx[];
    mailbox #(int) miso_mbx[];
    protected bit active;
    protected bit stop_flag;
    protected int default_miso_data;
    protected event tx_mbx_updated;
    protected int unsigned rx_transaction_count;
    protected int unsigned tx_transaction_count;

    adi_spi_vip_if_base vif;

    function new(
      input string name,
      input adi_spi_vip_if_base intf,
      input adi_spi_agent parent = null);

      super.new(name, parent);

      this.vif = intf;
      this.active = 0;
      this.stop_flag = 0;
      this.default_miso_data = vif.get_param_DEFAULT_MISO_DATA();
      this.miso_mbx = new[vif.get_param_NUM_OF_MISO()];
      this.mosi_mbx = new[vif.get_param_NUM_OF_MOSI()];
      foreach (miso_mbx[i]) begin
        this.miso_mbx[i] = new();
      end
      foreach (mosi_mbx[i]) begin
        this.mosi_mbx[i] = new();
      end
      this.rx_transaction_count = 0;
      this.tx_transaction_count = 0;
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
      bitqueue_t mosi_bit_queue[] = new [vif.get_param_NUM_OF_MOSI()];
      mosi_array_t mosi_logic;
      bit mosi_bit = 0;
      int aux = 0;
      forever begin
        if (vif.get_mode() == SPI_MODE_SLAVE) begin
          vif.wait_cs_active();
          while (vif.get_cs_active()) begin
            for (int i = 0; i<vif.get_param_DATA_DLENGTH(); i++) begin
              if (!vif.get_cs_active()) begin
                foreach(mosi_bit_queue[i]) begin
                  mosi_bit_queue[i].delete();
                end
                break;
              end
              vif.wait_for_sample_edge();
              mosi_logic = vif.get_mosi_delayed();

              for (int j = 0; j < vif.get_param_NUM_OF_MOSI(); j++) begin
                if ($isunknown(mosi_logic[j]))
                  this.error($sformatf("[SPI VIP] MOSI Rx: unknown mosi bit at sample edge!"));
                mosi_bit = bit'(mosi_logic[j]);
                bitqueue_push_lsb(mosi_bit_queue[j], mosi_bit);
              end
            end

            foreach(mosi_bit_queue[i]) begin
              mosi_mbx[i].put(bitqueue_to_int(mosi_bit_queue[i]));
              this.info($sformatf("[SPI VIP] MOSI Rx #%0d lane %0d: received 0x%04x", rx_transaction_count + 1, i, bitqueue_to_int(mosi_bit_queue[i])), ADI_VERBOSITY_HIGH);
              mosi_bit_queue[i].delete();
            end
            rx_transaction_count++;
          end
        end
      end
    endtask : rx_mosi

    protected task tx_miso();
        bit using_default;
        bit pending_mbx;
        bit cs_assertion_edge;
        int miso_data[] = new[vif.get_param_NUM_OF_MISO()];
        bitqueue_t miso_bits [] = new[vif.get_param_NUM_OF_MISO()];
        bit miso_bits_msb [] = new[vif.get_param_NUM_OF_MISO()];
      forever begin
        if (vif.get_mode() == SPI_MODE_SLAVE) begin
          cs_assertion_edge = 1'b1;
          vif.wait_cs_active();
          this.info($sformatf("[SPI VIP] CS active - starting transaction (lane 0 queue depth: %0d)", miso_mbx[0].num()), ADI_VERBOSITY_HIGH);
          while (vif.get_cs_active()) begin
            // try to get an item from the mailbox, without popping it
            using_default = 1'b0;
            foreach (miso_mbx[i]) begin
              if  (!miso_mbx[i].try_peek(miso_data[i])) begin
                using_default = 1'b1;
                break;
              end
            end
            if (using_default) begin
              this.info($sformatf("[SPI VIP] MISO Tx: using DEFAULT data 0x%04x (a lane queue is empty)", default_miso_data), ADI_VERBOSITY_HIGH);
            end else begin
              this.info($sformatf("[SPI VIP] MISO Tx: using QUEUED data"), ADI_VERBOSITY_HIGH);
            end

            //if one lane does not have valid data, all of the lanes use default_data
            foreach (miso_mbx[i]) begin
              if (using_default) begin
                miso_data[i] = default_miso_data;
              end else begin
                miso_mbx[i].try_peek(miso_data[i]);
              end
              miso_bits[i] = int_to_bitqueue(miso_data[i],vif.get_param_DATA_DLENGTH());
              pending_mbx = 1'b0;
            end

            // early drive and shift if CPHA=0
            if (vif.get_param_CPHA() == 0) begin
              for (int i = 0; i < $countones(vif.get_param_MISO_LANE_MASK()); i++) begin
                miso_bits_msb[i] = bitqueue_pop_msb(miso_bits[i]);
              end

              if (cs_assertion_edge) begin
                cs_assertion_edge = 1'b0;
                // for the first driven bit after cs assertion, the only delay should be CS_TO_MISO
                vif.set_miso_drive_instantaneous(miso_bits_msb);
              end else begin
                // for subsequent bits, SLAVE_TOUT applies
                vif.set_miso_drive(miso_bits_msb);
              end
            end

            for (int i = 0; i < vif.get_param_DATA_DLENGTH(); i++) begin
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
                  if (vif.get_resetn() == 1'b0) begin
                    this.info($sformatf("[SPI VIP] MISO Tx: CS inactive mid-transaction during reset (expected)"), ADI_VERBOSITY_HIGH);
                  end else begin
                    this.fatal($sformatf("[SPI VIP] MISO Tx: early exit due to unexpected CS inactive!"));
                  end
                end
                foreach (miso_bits[j]) begin
                  miso_bits[j].delete();
                end
                break;
              end else if (pending_mbx) begin
                // we were going to transmit default data, but new data arrived between the cs edge and vif.drive_edge
                using_default = 1'b0;
                pending_mbx = 1'b0;
                foreach (miso_bits[j]) begin
                  miso_bits[j].delete();
                end
                break;
              end else begin
                foreach (miso_bits[j]) begin
                  if (!(vif.get_param_CPHA() == 0 && i == vif.get_param_DATA_DLENGTH()-1)) begin
                    miso_bits_msb[j] = bitqueue_pop_msb(miso_bits[j]);
                  end
                end

                // vif.drive_edge has arrived
                // don't shift at last edge if CPHA=0
                if (!(vif.get_param_CPHA() == 0 && i == vif.get_param_DATA_DLENGTH()-1)) begin
                  vif.set_miso_drive(miso_bits_msb);
                end

                if (i == vif.get_param_DATA_DLENGTH()-1) begin
                  tx_transaction_count++;
                  this.info($sformatf("[SPI VIP] MISO Tx #%0d: end of transfer%s",
                    tx_transaction_count, using_default ? " (DEFAULT)" : ""), ADI_VERBOSITY_HIGH);
                  if (!using_default) begin
                    // finally pop an item from each lane mailbox after a complete transfer
                    foreach (miso_mbx[j]) begin
                      miso_mbx[j].get(miso_data[j]);
                      this.info($sformatf("[SPI VIP] MISO queue lane %0d: popped 0x%04x (queue depth now: %0d)", j, miso_data[j], miso_mbx[j].num()), ADI_VERBOSITY_HIGH);
                    end
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

    protected task reset_handler();
      int dummy;
      int miso_cleared, mosi_cleared;
      forever begin
        vif.wait_until_reset_asserted();
        miso_cleared = 0;
        mosi_cleared = 0;
        foreach (miso_mbx[i]) begin
          while (miso_mbx[i].try_get(dummy)) miso_cleared++;
        end
        foreach (mosi_mbx[i]) begin
          while (mosi_mbx[i].try_get(dummy)) mosi_cleared++;
        end
        rx_transaction_count = 0;
        tx_transaction_count = 0;
        this.info($sformatf("[SPI VIP] Reset asserted - cleared %0d MISO, %0d MOSI items, reset transaction counters", miso_cleared, mosi_cleared), ADI_VERBOSITY_HIGH);

        vif.wait_until_reset_deasserted();
        this.info($sformatf("[SPI VIP] Reset deasserted"), ADI_VERBOSITY_HIGH);
      end
    endtask : reset_handler

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
          begin
            reset_handler();
          end
      join
    endtask : run

    function void set_default_miso_data(
      input bit [vif.get_param_DATA_DLENGTH()-1:0] default_data
    );
      this.default_miso_data = default_data;
    endfunction : set_default_miso_data

    task put_tx_data(
      input int unsigned data[]);
      foreach (data[i]) begin
        miso_mbx[i].put(data[i]);
        this.info($sformatf("[SPI VIP] MISO queue lane %0d: added 0x%04x (queue depth now: %0d)", i, data[i], miso_mbx[i].num()), ADI_VERBOSITY_HIGH);
      end
      ->tx_mbx_updated;
    endtask

    task get_rx_data(
      ref int unsigned data[]);
      for (int i = 0; i < vif.get_param_NUM_OF_MOSI(); i++) begin
        mosi_mbx[i].get(data[i]);
      end
    endtask

    task flush_tx();
      this.info($sformatf("[SPI VIP] flush_tx: waiting for all lane queues to empty"), ADI_VERBOSITY_HIGH);
      fork
        begin: isolation_process
          foreach (miso_mbx[i]) begin
            fork
              automatic int k = i;
              begin
                wait (miso_mbx[k].num() == 0);
              end
            join_none
          end
          wait fork;
        end : isolation_process
      join
      this.info($sformatf("[SPI VIP] flush_tx: all lane queues are now empty"), ADI_VERBOSITY_HIGH);
    endtask

    // Clear receive buffer - discards any pending received data
    task clear_rx();
      int dummy;
      foreach (mosi_mbx[i]) begin
        while (mosi_mbx[i].try_get(dummy));
      end
    endtask

    // Clear send buffer - discards any pending data to be sent
    task clear_tx();
      int dummy;
      int cleared = 0;
      foreach (miso_mbx[i]) begin
        while (miso_mbx[i].try_get(dummy)) cleared++;
      end
      this.info($sformatf("[SPI VIP] clear_tx: cleared %0d items from MISO queues", cleared), ADI_VERBOSITY_HIGH);
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
    protected int unsigned verify_count;

    function new(
      input string name,
      input adi_spi_driver driver,
      input adi_spi_agent parent = null);

      super.new(name, parent);

      this.driver = driver;
      this.verify_count = 0;
    endfunction: new

    virtual task automatic send_data(input int unsigned data[]);
      this.driver.put_tx_data(data);
    endtask : send_data

    virtual task automatic receive_data(ref int unsigned data[]);
      this.driver.get_rx_data(data);
    endtask : receive_data

    virtual task automatic receive_data_verify(input int unsigned expected[]);
      int unsigned received[] = new[expected.size()];
      this.driver.get_rx_data(received);
      verify_count++;
      foreach (received[i]) begin
        if (received[i] !== expected[i]) begin
          this.error($sformatf({"[SPI VIP] MOSI verify #%0d lane %0d:\n",
                                "        Expected: 0x%04x\n",
                                "        Actual:   0x%04x\n",
                                "        Status:   FAIL"}, verify_count, i, expected[i], received[i]));
        end else begin
          this.info($sformatf({"[SPI VIP] MOSI verify #%0d lane %0d:\n",
                               "        Expected: 0x%04x\n",
                               "        Actual:   0x%04x\n",
                               "        Status:   PASS"}, verify_count, i, expected[i], received[i]), ADI_VERBOSITY_HIGH);
        end
      end
    endtask : receive_data_verify

    virtual task flush_send();
      this.driver.flush_tx();
    endtask : flush_send

    // Clear receive buffer - discards any pending received data
    virtual task clear_receive();
      this.driver.clear_rx();
    endtask : clear_receive

    // Clear send buffer - discards any pending data to be sent
    virtual task clear_send();
      this.driver.clear_tx();
    endtask : clear_send

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
