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

  // forward declaration to avoid errors
  typedef class adi_spi_agent;

  class adi_spi_driver extends adi_driver;

    typedef bit bitqueue_t [$];
    protected mailbox mosi_mbx;
    mailbox miso_mbx[];
    protected bit active;
    protected bit stop_flag;
    protected int default_miso_data;
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
      this.default_miso_data = vif.get_param_DEFAULT_MISO_DATA();
      this.miso_mbx = new[vif.get_param_NUM_ACTIVE_LANES()];
      for (int i = 0; i < vif.get_param_NUM_ACTIVE_LANES(); i++) begin
        this.miso_mbx[i] = new();
      end
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
      logic [vif.get_param_NUM_OF_SDO()-1:0] mosi_logic;
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
        int miso_data[] = new[vif.get_param_NUM_ACTIVE_LANES()];
        bitqueue_t miso_bits [] = new[vif.get_param_NUM_ACTIVE_LANES()];
        bit miso_bits_msb [] = new[vif.get_param_NUM_ACTIVE_LANES()];
        string bit_str;
        string str;
      forever begin
        if (vif.get_mode() == SPI_MODE_SLAVE) begin
          vif.wait_cs_active();
          while (vif.get_cs_active()) begin
            // try to get an item from the mailbox, without popping it
            for (int i = 0; i < vif.get_param_NUM_ACTIVE_LANES(); i++) begin
              if  (!miso_mbx[i].try_peek(miso_data[i])) begin
                using_default = 1'b1;
                break;
              end else begin
                using_default = 1'b0;
              end
            end

            //if one lane does not have valid data, all of the lanes use default_data
            for (int i = 0; i < vif.get_param_NUM_ACTIVE_LANES(); i++) begin
              if (using_default) begin
                miso_data[i] = default_miso_data;
              end else begin
                miso_mbx[i].try_peek(miso_data[i]);
              end
              // bit_str = $sformatf("%b", miso_data[i]);
              // str = bit_str.substr(bit_str.len()-vif.get_param_DATA_DLENGTH(), bit_str.len()-1);
              // this.info($sformatf("miso_data[%d] = %s = %x", i, str, miso_data[i]), ADI_VERBOSITY_HIGH);
              miso_bits[i] = int_to_bitqueue(miso_data[i],vif.get_param_DATA_DLENGTH());
              // for (int j = 0; j < vif.get_param_DATA_DLENGTH(); j++) begin
              //   this.info($sformatf("miso_bits[%d][%d] = %d", i, j, miso_bits[i][j]), ADI_VERBOSITY_HIGH);
              // end
              pending_mbx = 1'b0;
            end

            // early drive and shift if CPHA=0
            if (vif.get_param_CPHA() == 0) begin
              for (int i = 0; i < vif.get_param_NUM_ACTIVE_LANES(); i++) begin
                miso_bits_msb[i] = bitqueue_pop_msb(miso_bits[i]);
                // this.info($sformatf("miso_bits_msb[%d] = %d", i, miso_bits_msb[i]), ADI_VERBOSITY_HIGH);
              end
              vif.set_miso_drive_instantaneous(miso_bits_msb);
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
                  this.fatal($sformatf("[SPI VIP] MISO Tx: early exit due to unexpected CS inactive!"));
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
                    // this.info($sformatf("miso_bits_msb[%d] = %d", j, miso_bits_msb[j]), ADI_VERBOSITY_HIGH);
                  end
                end

                // vif.drive_edge has arrived
                // don't shift at last edge if CPHA=0
                if (!(vif.get_param_CPHA() == 0 && i == vif.get_param_DATA_DLENGTH()-1)) begin
                  vif.set_miso_drive_instantaneous(miso_bits_msb);
                end

                foreach (miso_mbx[j]) begin
                  if (i == vif.get_param_DATA_DLENGTH()-1) begin
                    this.info($sformatf("[SPI VIP] MISO Tx end of transfer."), ADI_VERBOSITY_HIGH);
                    if (!using_default) begin
                      // finally pop an item from the mailbox after a complete transfer
                      miso_mbx[j].get(miso_data[j]);
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
      input int unsigned data[]);
      foreach (data[i]) begin
        miso_mbx[i].put(data[i]);
      end
      // miso_mbx.put(data);
      ->tx_mbx_updated;
    endtask

    task get_rx_data(
      output int unsigned data);
      mosi_mbx.get(data);
    endtask

    task flush_tx();
      // fork
        // begin: isolation_process
          foreach (miso_mbx[i]) begin
            // fork
              wait (miso_mbx[i].num() == 0);
            // join_none
          end
          // wait fork;
        // end : isolation_process
      // join
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
      // this.info($sformatf("data = %x", data), ADI_VERBOSITY_HIGH);
      // this.info($sformatf("data = %b", data), ADI_VERBOSITY_HIGH);
      for (int i =0; i<n_bits; i++) begin
        // this.info($sformatf("miso_bits[%d] = %d", i, ((data>>i) & 1'b1)), ADI_VERBOSITY_HIGH);
        bitq.push_back((data>>i) & 1'b1);
        // this.info($sformatf("bitq[%d] = %d", i, bitq[i]), ADI_VERBOSITY_HIGH);
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
      input adi_spi_agent parent = null);

      super.new(name, parent);

      this.driver = driver;
    endfunction: new

    virtual task automatic send_data(input int unsigned data[]);
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
