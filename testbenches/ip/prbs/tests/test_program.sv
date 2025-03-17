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
`include "axi_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import io_vip_if_base_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program;

  // Declare the class instances
  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  io_vip_if_base input_vip_if;
  io_vip_if_base output_vip_if;
  io_vip_if_base polynomial_vip_if;

  io_vip_if_base ready_vip_if;
  io_vip_if_base rstn_vip_if;
  io_vip_if_base error_vip_if;

  localparam MAX_WIDTH = `MAX(`DATA_WIDTH, `POLYNOMIAL_WIDTH);

  logic [`DATA_WIDTH-1:0] input_data;
  logic [`DATA_WIDTH-1:0] output_data;
  logic [`DATA_WIDTH-1:0] calculated_data = 'h0;
  logic [`POLYNOMIAL_WIDTH-1:0] processed_data = 'h0;

  logic [`POLYNOMIAL_WIDTH-1:0] polynomial;

  // Process variables
  process current_process;
  string current_process_random_state;


  initial begin

    setLoggerVerbosity(ADI_VERBOSITY_LOW);
    // setLoggerVerbosity(ADI_VERBOSITY_NONE);

    current_process = process::self();
    current_process_random_state = current_process.get_randstate();
    `INFO(("Randomization state: %s", current_process_random_state), ADI_VERBOSITY_NONE);

    // Create environment
    base_env = new("Base Environment",
      `TH.`SYS_CLK.inst.IF,
      `TH.`DMA_CLK.inst.IF,
      `TH.`DDR_CLK.inst.IF,
      `TH.`SYS_RST.inst.IF);

    mng = new("", `TH.`MNG_AXI.inst.IF);
    ddr = new("", `TH.`DDR_AXI.inst.IF);

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    input_vip_if = `TH.`INPUT_VIP.inst.inst.IF.vif;
    output_vip_if = `TH.`OUTPUT_VIP.inst.inst.IF.vif;
    polynomial_vip_if = `TH.`POLYNOMIAL_VIP.inst.inst.IF.vif;

    ready_vip_if = `TH.`READY_VIP.inst.inst.IF.vif;
    rstn_vip_if = `TH.`RSTN_VIP.inst.inst.IF.vif;
    error_vip_if = `TH.`ERROR_VIP.inst.inst.IF.vif;

    base_env.start();
    base_env.sys_reset();

    // verification on negedge
    polynomial = $urandom();
    polynomial_vip_if.set_io(polynomial);

    input_data = $urandom();
    processed_data = {{MAX_WIDTH-`DATA_WIDTH{1'b0}}, input_data};

    `INFO(("Negative edge verification"), ADI_VERBOSITY_LOW);
    output_vip_if.set_negative_edge();
    repeat(100) begin
      polynomial_vip_if.wait_posedge_clk();

      input_vip_if.set_io(input_data);

      polynomial_vip_if.wait_negedge_clk();

      output_data = output_vip_if.get_io();

      // calculate PRBS
      for(int i=0; i<`DATA_WIDTH; i=i+1) begin
        calculated_data[`DATA_WIDTH-i-1] = processed_data[`POLYNOMIAL_WIDTH-1];
        processed_data = {processed_data[`POLYNOMIAL_WIDTH-2:0], ^(polynomial & processed_data)};
      end

      if (output_data !== calculated_data) begin
        `ERROR(("Output PRBS: %0h | Calculated PRBS: %0h", output_data, calculated_data));
      end

      input_data = {{MAX_WIDTH-`POLYNOMIAL_WIDTH{1'b0}}, processed_data};
    end

    #1ns;

    // verification on posedge
    polynomial = $urandom();
    polynomial_vip_if.set_io(polynomial);

    input_data = $urandom();
    processed_data = {{MAX_WIDTH-`DATA_WIDTH{1'b0}}, input_data};

    `INFO(("Positive edge verification"), ADI_VERBOSITY_LOW);
    output_vip_if.set_positive_edge();
    repeat(100) begin
      polynomial_vip_if.wait_negedge_clk();

      input_vip_if.set_io(input_data);

      polynomial_vip_if.wait_posedge_clk();

      output_data = output_vip_if.get_io();

      // calculate PRBS
      for(int i=0; i<`DATA_WIDTH; i=i+1) begin
        calculated_data[`DATA_WIDTH-i-1] = processed_data[`POLYNOMIAL_WIDTH-1];
        processed_data = {processed_data[`POLYNOMIAL_WIDTH-2:0], ^(polynomial & processed_data)};
      end

      if (output_data !== calculated_data) begin
        `ERROR(("Output PRBS: %0h | Calculated PRBS: %0h", output_data, calculated_data));
      end

      input_data = {{MAX_WIDTH-`POLYNOMIAL_WIDTH{1'b0}}, processed_data};
    end

    // gen-mon verification
    polynomial = $urandom();
    polynomial_vip_if.set_io(polynomial);

    input_data = $urandom();
    processed_data = {{MAX_WIDTH-`DATA_WIDTH{1'b0}}, input_data};

    `INFO(("Generator-monitor verification"), ADI_VERBOSITY_LOW);

    rstn_vip_if.set_io(1'b0);
    ready_vip_if.set_io(1'b0);
    rstn_vip_if.wait_posedge_clk();

    rstn_vip_if.set_io(1'b1);
    rstn_vip_if.wait_posedge_clk();

    ready_vip_if.set_io(1'b1);
    ready_vip_if.wait_posedge_clk();

    repeat(100) begin
      error_vip_if.wait_negedge_clk();
      if (error_vip_if.get_io()) begin
        `ERROR(("PRBS check failed!"));
      end
      polynomial_vip_if.wait_posedge_clk();
    end

    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
