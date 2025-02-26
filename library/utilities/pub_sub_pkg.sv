// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

package pub_sub_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import adi_datatypes_pkg::*;
  import filter_pkg::*;
  import packet_processor_pkg::*;

  class adi_subscriber #(type data_type = int) extends adi_component;

    protected static bit [15:0] last_id = 'd0;
    bit [15:0] id;

    function new(
      input string name,
      input adi_component parent = null);

      super.new(name, parent);

      this.last_id++;
      this.id = this.last_id;
    endfunction: new

    virtual function void update(input adi_fifo #(data_type) data);
      this.fatal($sformatf("This function is not implemented!"));
    endfunction: update

  endclass: adi_subscriber


  class adi_publisher #(type data_type = int) extends adi_component;

    protected adi_subscriber #(data_type) subscriber_list[bit[15:0]];

    protected adi_filter #(data_type) filter;
    protected adi_packet_processor #(data_type) packet_processor;

    function new(
      input string name,
      input adi_component parent = null);

      super.new(name, parent);
    endfunction: new
    
    function void setup_filter(input adi_filter #(data_type) filter);
      this.filter = filter;
    endfunction: setup_filter

    function void remove_filter();
      this.filter = null;
    endfunction: remove_filter

    function void setup_processor(input adi_packet_processor #(data_type) packet_processor);
      this.packet_processor = packet_processor;
    endfunction: setup_processor

    function void remove_processor();
      this.packet_processor = null;
    endfunction: remove_processor

    function void subscribe(input adi_subscriber #(data_type) subscriber);
      if (this.subscriber_list.exists(subscriber.id)) begin
        this.error($sformatf("Subscriber already on the list!"));
      end else begin
        this.subscriber_list[subscriber.id] = subscriber;
      end
    endfunction: subscribe

    function void unsubscribe(input adi_subscriber #(data_type) subscriber);
      if (!this.subscriber_list.exists(subscriber.id)) begin
        this.error($sformatf("Subscriber does not exist on list!"));
      end else begin
        this.subscriber_list.delete(subscriber.id);
      end
    endfunction: unsubscribe

    function void notify(input adi_fifo #(data_type) data);
      adi_fifo #(data_type) processed_data;

      if (this.filter != null) begin
        if (!this.filter.filter(data)) begin
          this.info($sformatf("Data filtered"), ADI_VERBOSITY_HIGH);
          return;
        end
      end

      // data processing
      if (this.packet_processor != null) begin
        processed_data = this.packet_processor.process_data(data);
        this.info($sformatf("Data processed"), ADI_VERBOSITY_HIGH);
      end else begin
        processed_data = data;
      end

      // data publishing
      foreach (this.subscriber_list[i]) begin
        this.subscriber_list[i].update(processed_data);
      end
      this.info($sformatf("Data published"), ADI_VERBOSITY_HIGH);
    endfunction: notify

  endclass: adi_publisher

endpackage: pub_sub_pkg
