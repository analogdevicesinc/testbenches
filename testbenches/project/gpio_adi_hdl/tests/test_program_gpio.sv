`include "utils.svh"
`include "axi_definitions.svh"
`include "gpio_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import environment_pkg::*;
import gpio_api_pkg::*;
import m_axi_sequencer_pkg::*;
import axi_vip_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

`define AXI_GPIO_BA 32'h43C00000  // <-- adresa pentru proiect

program test_program_gpio (
  output logic [31:0] gpio_m_io_i,
  input  logic [31:0] gpio_m_io_o,
  input  logic [31:0] gpio_m_io_t,
  input  logic        irq_0
);
  timeunit 1ns;
  timeprecision 1ps;

  test_harness_env #(
    `AXI_VIP_PARAMS(test_harness, mng_axi_vip),
    `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)
  ) base_env;

  gpio_api gpio;
  logic [31:0] read_data;

  initial begin
    gpio_m_io_i = 32'h0;

    base_env = new("GPIO Base Env",
                   `TH.`SYS_CLK.inst.IF,
                   `TH.`DMA_CLK.inst.IF,
                   `TH.`DDR_CLK.inst.IF,
                   `TH.`SYS_RST.inst.IF,
                   `TH.`MNG_AXI.inst.IF,
                   `TH.`DDR_AXI.inst.IF);

    gpio = new("GPIO API", base_env.mng.sequencer, `AXI_GPIO_BA);

    setLoggerVerbosity(ADI_VERBOSITY_LOW);

    base_env.start();
    base_env.sys_reset();

    `INFO(("Start GPIO full-project test"), ADI_VERBOSITY_LOW);

    gpio.release_reset();
    gpio.set_direction_output();

    test_output();
    test_input();
    test_irq();

    base_env.stop();
    `INFO(("GPIO Project Test Done!"), ADI_VERBOSITY_NONE);
    $finish;
  end

  task test_output();
    for (int i = 0; i < 8; i++) begin
      gpio.write_output(i);
      #50;
      if (gpio_m_io_t[7:0] == 8'h00 && gpio_m_io_o[7:0] == i)
        `INFO(("LED OK: %0h", gpio_m_io_o[7:0]), ADI_VERBOSITY_LOW);
      else
        `ERROR(("Mismatch LED exp=%0h got=%0h", i, gpio_m_io_o[7:0]));
    end
  endtask

  task test_input();
    gpio.set_direction_input();
    for (int i = 0; i < 4; i++) begin
      gpio_m_io_i[1:0] = i[1:0]; // butoane
      #20;
      gpio.read_input(read_data);
      if (read_data[1:0] == i[1:0])
        `INFO(("BTN OK: %0h", read_data[1:0]), ADI_VERBOSITY_LOW);
      else
        `ERROR(("BTN mismatch: exp=%0h got=%0h", i, read_data[1:0]));
    end
  endtask

  task test_irq();
    gpio.unmask_irq(32'hFFFFFFFB); // unmask bit 2
    #50;
    gpio_m_io_i[0] = 1'b0;
    #50;
    gpio_m_io_i[0] = 1'b1; // rising edge
    #50;
    if (irq_0 !== 1'b1)
      `ERROR(("IRQ not asserted!"));
    else
      `INFO(("IRQ OK"), ADI_VERBOSITY_LOW);

    gpio.clear_irq_source(32'h4);
    #100;
    if (irq_0 !== 1'b0)
      `ERROR(("IRQ not cleared!"));
  endtask
endprogram
