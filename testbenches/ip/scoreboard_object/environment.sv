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
`include "axi_definitions.svh"
`include "axis_definitions.svh"

package environment_pkg;

  import logger_pkg::*;
  import adi_environment_pkg::*;

  import adi_vip_pkg::*;
  import scoreboard_pkg::*;
  import scoreboard_object_pkg::*;
  import pub_sub_pkg::*;
  import adi_datatypes_pkg::*;


  class dummy_fifo_monitor extends adi_monitor;

    typedef enum {
      INCR,
      CONST,
      RAND
    } gen_t;

    typedef adi_fifo #(int unsigned) fifo_t;

    adi_publisher #(adi_datatype) publisher;
    protected bit enabled;
    protected bit stop_flag;
    protected gen_t gen_type;
    local int unsigned to_gen;
    local int unsigned generated;
    local int unsigned last_gen;
    local int unsigned transaction_len = 3;
    local int unsigned constant = 'hCAFE;

    function new(
      input int to_gen,
      input gen_t gen_type,
      input string name,
      input adi_agent parent = null);

      super.new(name, parent);
      this.publisher = new("Dummy Publisher", this);
      this.generated = 0;
      this.to_gen = to_gen;
      this.gen_type = gen_type;
      this.last_gen = 0;
      this.info($sformatf("Dummy Monitor created, gen_type=%s", this.gen_type.name()), ADI_VERBOSITY_MEDIUM);
    endfunction: new

    task run();
      if (this.enabled) begin
        this.error($sformatf("Monitor is already running!"));
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
      this.info($sformatf("Stopping Monitor"), ADI_VERBOSITY_MEDIUM);
      if (this.enabled) begin
        this.stop_flag = 1;
        this.enabled = 0;
        this.info($sformatf("Monitor disabled"), ADI_VERBOSITY_MEDIUM);
      end else begin
        this.error($sformatf("Already inactive!"));
      end
    endfunction: stop

    task get_transaction();
      fifo_t transaction;
      fifo_t transaction_q [$];
      forever begin
        #1step;
        if (this.generated < this.to_gen) begin
          this.gen_transaction(transaction);
          this.info($sformatf("dbg gen transaction: %s", transaction.to_string()), ADI_VERBOSITY_MEDIUM);
          this.info($sformatf("Caught a transaction: %d bits", transaction.size()), ADI_VERBOSITY_MEDIUM);
          transaction_q.push_back(transaction);
          this.publisher.notify(transaction_q);
          transaction.clean();
          transaction_q.delete();
          this.generated++;
        end else begin
          return;
        end
      end
    endtask: get_transaction

    function void gen_transaction(output fifo_t trans);
      int elem;
      trans = new(32);
      case (this.gen_type)
        INCR: begin
          elem = this.last_gen+1;
          for (int i = 0; i<this.transaction_len; i++ ) begin
            trans.push(elem);
            elem++;
          end
        end
        CONST: begin
          for (int i = 0; i<this.transaction_len; i++ ) begin
            elem = this.constant;
            trans.push(elem);
          end
        end
        RAND: begin
          for (int i = 0; i<this.transaction_len; i++ ) begin
            elem = $urandom;
            trans.push(elem);
          end
        end
      endcase
      this.generated++;
      this.last_gen = elem;
    endfunction: gen_transaction
  endclass: dummy_fifo_monitor


  class scoreboard_object_environment extends adi_environment;

    dummy_fifo_monitor dummy_ref;
    dummy_fifo_monitor dummy_src;
    typedef adi_fifo #(int unsigned) fifo_t;
    scoreboard_object scoreboard;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      input string name);

      // creating the agents
      super.new(name);

      dummy_ref = new(5, 0, "Dummy Reference Monitor");
      dummy_src = new(5, 1, "Dummy Source Monitor");

      this.scoreboard = new("Dummy Object Scoreboard", this);
    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure(int bytes_to_generate);

    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.dummy_ref.publisher.subscribe(this.scoreboard.subscriber_source);
      this.dummy_src.publisher.subscribe(this.scoreboard.subscriber_sink);
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      fork
        this.scoreboard.run();
        this.dummy_ref.run();
        this.dummy_src.run();
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.dummy_ref.stop();
      this.dummy_src.stop();
      this.scoreboard.stop();
    endtask

  endclass

endpackage
