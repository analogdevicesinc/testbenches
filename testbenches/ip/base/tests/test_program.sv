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
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

import axi_vip_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

/////////////////////////////////////

class abs_sub #(type data_type = int);
  protected static bit [15:0] last_id = 'd0;
  bit [15:0] id;

  function new();
  endfunction: new

  virtual function void update(input data_type data);
  endfunction: update
endclass: abs_sub

/////////////////////////////////////

class pub #(type data_type = int);
  protected abs_sub #(data_type) subscriber_list[bit[15:0]];
  
  function new();
  endfunction: new

  function void subscribe(input abs_sub #(data_type) subscriber);
    if (this.subscriber_list.exists(subscriber.id))
      `ERROR(("Subscriber already in the list!"));
    else
      this.subscriber_list[subscriber.id] = subscriber;
  endfunction: subscribe

  function void unsubscribe(input abs_sub #(data_type) subscriber);
    if (!this.subscriber_list.exists(subscriber.id))
      `ERROR(("Subscriber does not exist in list!"));
    else
      this.subscriber_list.delete(subscriber.id);
  endfunction: unsubscribe

  function void notify(input data_type data);
    foreach (this.subscriber_list[i])
      this.subscriber_list[i].update(data);
  endfunction: notify
endclass: pub

/////////////////////////////////////

class axis;
  pub #(logic [7:0]) publisher;

  function new();
    this.publisher = new();
  endfunction: new

  function void subscribe(input abs_sub #(logic [7:0]) subscriber);
    this.publisher.subscribe(subscriber);
  endfunction: subscribe

  task job();
    this.publisher.notify('hA);
    this.publisher.notify('h5);
  endtask: job
endclass: axis

/////////////////////////////////////

class scoreboard;
  class sub extends abs_sub #(logic [7:0]);
    protected scoreboard scb_ref;

    function new(input scoreboard scb_ref);
      this.scb_ref = scb_ref;

      this.last_id++;
      this.id = this.last_id;
    endfunction: new

    virtual function void update(input data_type data);
      `INFO(("Data received: %h", data), ADI_VERBOSITY_NONE);
    endfunction: update
  endclass: sub

  sub subscriber_tx;
  sub subscriber_rx;

  function new();
    this.subscriber_tx = new(this);
    this.subscriber_rx = new(this);
  endfunction: new

  task run();
  endtask: run
endclass: scoreboard

/////////////////////////////////////

program test_program;

  // Declare the class instances
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) env;

  // Process variables
  process current_process;
  string current_process_random_state;

  axis axis1;
  axis axis2;

  scoreboard scb;
  

  initial begin

    current_process = process::self();
    current_process_random_state = current_process.get_randstate();
    `INFO(("Randomization state: %s", current_process_random_state), ADI_VERBOSITY_NONE);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    // Create environment
    env = new("Base Environment",
              `TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    env.start();
    env.sys_reset();

    /* Add stimulus tasks */

    axis1 = new();
    axis2 = new();
    
    scb = new();

    axis1.subscribe(scb.subscriber_tx);
    axis2.subscribe(scb.subscriber_rx);

    scb.run();

    axis1.job();
    axis2.job();
        
    env.stop();
    
    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
