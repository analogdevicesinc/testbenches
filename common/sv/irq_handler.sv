// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2024 (c) Analog Devices, Inc. All rights reserved.
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

package irq_handler_pkg;

  import logger_pkg::*;
  import adi_peripheral_pkg::*;
  import reg_accessor_pkg::*;
  
  class irq_handler_class extends adi_peripheral;

    protected virtual interface io_vip_if #(.MODE(0), .WIDTH(1), .ASYNC(1)) irq_vip_if;

    protected event irq_event_list [31:0];
    protected bit [31:0] irq_valid_list;

    protected bit software_testing;
  
    // constructor
    function new(
      input string name,
      reg_accessor bus,
      input bit [31:0] base_address,
      virtual interface io_vip_if #(.MODE(0), .WIDTH(1), .ASYNC(1)) irq_vip_if);
      
      super.new(name, bus, base_address);
      this.irq_vip_if = irq_vip_if;
      this.irq_valid_list = 'h0;
      this.software_testing = 1'b0;
    endfunction: new

    // enable software testing at startup
    function void enable_software_testing();
      this.software_testing = 1'b1;
    endfunction: enable_software_testing

    // software IRQ test-phase
    task software_irq_testing();
      logic [31:0] enable_irq = 'h0;

      for (int i=0; i<32; ++i) begin
        enable_irq = enable_irq | (this.irq_valid_list[i] << i);
      end
      `INFO(("Enables: %d", enable_irq));
      this.axi_write('h00, enable_irq); // software trigger IRQ

      @(negedge this.irq_vip_if.io);
    endtask: software_irq_testing

    // IRQ event handler
    task run();
      logic [31:0] irq_triggered;
      logic [31:0] enable_irq = 'h0;

      for (int i=0; i<32; ++i) begin
        enable_irq = enable_irq | (this.irq_valid_list[i] << i);
      end

      this.axi_write('h10, enable_irq); // enable all IRQ handles
      this.axi_write('h1C, 'b01); // enable IRQ controller / software interrupt disabled

      fork forever begin
        if (this.irq_vip_if.get_io() == 1'b0) begin
          @(posedge this.irq_vip_if.io);
        end

        `INFOV(("IRQ controller triggered"), 50);

        this.axi_read('h04, irq_triggered); // check pending IRQ (status + enable)

        for (int i=0; i<32; ++i) begin
          if (irq_triggered[i]) begin
            if (this.irq_valid_list[i] == 1'b0)
              `ERROR(("IRQ triggered on a non-registered device!"));
            ->this.irq_event_list[i];
            @(this.irq_event_list[i]);
            this.axi_write('h0C, 'h1 << i); // acknowledge IRQ
          end
        end
      end join_none

      if (this.software_testing)
        this.software_irq_testing();

      this.axi_write('h1C, 'b11); // enable IRQ controller + software interrupt enabled
    endtask: run

    // register IRQ device
    function event register_device(input int position);
      if (this.irq_valid_list[position])
        `ERROR(("An interrupt handler is already assigned to position %0d!", position));
      this.irq_valid_list[position] = 1'b1;
      return this.irq_event_list[position];
    endfunction: register_device

  endclass

endpackage
