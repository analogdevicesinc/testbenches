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

import logger_pkg::*;
import test_harness_env_pkg::*;
import environment_pkg::*;
import dmac_api_pkg::*;
import data_offload_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

`define AXI_GPIO_BA 32'h50040000

localparam AXI_GPIO_BA         = `AXI_GPIO_BA;
localparam GPIO_REG_OFFSET     = 4 * 32'h21;
localparam GPIO_REG_OFFSET_RST = 4 * 32'h20;
localparam GPIO_REG_OFFSET_IN  = 4 * 32'h22;

program test_program (
  output logic [31:0] gpio_m_io_i,  // TB → IP
  input  logic [31:0] gpio_m_io_o,  // IP → TB
  input  logic [31:0] gpio_m_io_t,  // directie de la IP
  input  logic        irq_0
);

  // Variabila temporara pentru citiri AXI
  logic [31:0] read_data;

  // AXI wrapper tasks
  task axi_read(input [31:0] addr, output [31:0] data);
    base_env.mng.sequencer.RegRead32(addr, data);
  endtask

  task axi_write(input [31:0] addr, input [31:0] data);
    base_env.mng.sequencer.RegWrite32(addr, data);
  endtask

  // Environment
  test_harness_env #(
    `AXI_VIP_PARAMS(test_harness, mng_axi_vip),
    `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)
  ) base_env;

  initial begin
    gpio_m_io_i = 32'h0;

    base_env = new("Base Environment",
                   `TH.`SYS_CLK.inst.IF,
                   `TH.`DMA_CLK.inst.IF,
                   `TH.`DDR_CLK.inst.IF,
                   `TH.`SYS_RST.inst.IF,
                   `TH.`MNG_AXI.inst.IF,
                   `TH.`DDR_AXI.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    base_env.sys_reset();

    `INFO(("Bring up IP from reset."), ADI_VERBOSITY_LOW);
    axi_write(AXI_GPIO_BA + GPIO_REG_OFFSET_RST, 32'h1);     // scoate din reset
    axi_write(AXI_GPIO_BA + 4 * 32'h24, 32'h00000000);        // GPIO ca iesire din IP (input pt TB)


    // 1. IP scrie pe GPIO - TB citeste

    `INFO(("IP write → TB read"), ADI_VERBOSITY_LOW);
    for (int i = 0; i < 16; i++) begin
      axi_write(AXI_GPIO_BA + GPIO_REG_OFFSET, i);
      #50;
      if (gpio_m_io_t == 32'h0) begin
        if (gpio_m_io_o == i) begin
          `INFO(("GPIO_OUT OK: got = %0h", gpio_m_io_o), ADI_VERBOSITY_LOW);
        end else begin
          `ERROR(("GPIO_OUT mismatch: expected = %0h, got = %0h", i, gpio_m_io_o));
        end
      end else begin
        `ERROR(("GPIO_T indicates tri-state, expected drive."));
      end
    end


    // 2. TB scrie pe GPIO - IP citeste

    `INFO(("TB write → IP read"), ADI_VERBOSITY_LOW);
    axi_write(AXI_GPIO_BA + 4 * 32'h24, 32'hFFFFFFFF); // GPIO ca intrare in IP (scriere din TB)

    for (int i = 0; i < 16; i++) begin
      gpio_m_io_i = i;
      #10;
      axi_read(AXI_GPIO_BA + GPIO_REG_OFFSET_IN, read_data);
      if (read_data == i) begin
        `INFO(("GPIO_IN OK: %0h", read_data), ADI_VERBOSITY_LOW);
      end else begin
        `ERROR(("GPIO_IN mismatch: expected = %0h, got = %0h", i, read_data));
      end
    end


    // 3. Test IRQ logic

    `INFO(("Start IRQ test sequence"), ADI_VERBOSITY_LOW);

    axi_write(AXI_GPIO_BA + 8'h23 * 4, 32'hFFFFFFFB); // unmask IRQ bit 2
    #50;

    gpio_m_io_i = 32'b0;
    #50;
    gpio_m_io_i = 32'b1; // rising edge pe bitul 0
    #50;

    if (irq_0 != 1'b1) begin
      `ERROR(("IRQ NOT asserted after gpio rising edge."));
    end else begin
      `INFO(("IRQ correctly asserted"), ADI_VERBOSITY_LOW);
    end

    axi_write(AXI_GPIO_BA + 8'h11 * 4, 32'h00000004); // clear IRQ source bit 2
    #300;

    if (irq_0 !== 1'b0) begin
      `ERROR(("IRQ still asserted after clearing."));
    end else begin
      `INFO(("IRQ correctly deasserted"), ADI_VERBOSITY_LOW);
    end

    `INFO(("IRQ test completed"), ADI_VERBOSITY_LOW);

    gpio_m_io_i = 32'd15;
    #1000;
    base_env.stop();

    `INFO(("Test done!"), ADI_VERBOSITY_NONE);
    $finish;
  end

endprogram




