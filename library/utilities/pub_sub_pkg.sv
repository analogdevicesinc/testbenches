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
  import adi_component_pkg::*;
  import adi_fifo_pkg::*;

  virtual class adi_subscriber #(type data_type = int) extends adi_component;

    protected static bit [15:0] last_id = 'd0;
    protected bit [15:0] id;

    function new(
      input string name,
      input adi_component parent = null);

      super.new(name, parent);

      this.last_id++;
      this.id = this.last_id;
    endfunction: new

    function bit[15:0] get_id();
      return this.id;
    endfunction: get_id

    pure virtual task update(input adi_fifo #(data_type) data);

  endclass: adi_subscriber


  class adi_publisher #(type data_type = int) extends adi_component;

    protected adi_subscriber #(data_type) subscriber_list[bit[15:0]];

    function new(
      input string name,
      input adi_component parent = null);

      super.new(name, parent);
    endfunction: new

    function void subscribe(input adi_subscriber #(data_type) subscriber);
      if (this.subscriber_list.exists(subscriber.get_id())) begin
        this.error($sformatf("Subscriber already on the list!"));
      end else begin
        this.subscriber_list[subscriber.get_id()] = subscriber;
      end
    endfunction: subscribe

    function void unsubscribe(input adi_subscriber #(data_type) subscriber);
      if (!this.subscriber_list.exists(subscriber.get_id())) begin
        this.error($sformatf("Subscriber does not exist on list!"));
      end else begin
        this.subscriber_list.delete(subscriber.get_id());
      end
    endfunction: unsubscribe

    task notify(input adi_fifo #(data_type) data);
      foreach (this.subscriber_list[i]) begin
        this.subscriber_list[i].update(data);
      end
    endtask: notify

  endclass: adi_publisher

endpackage
