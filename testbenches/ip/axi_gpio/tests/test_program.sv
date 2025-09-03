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

`define AXI_GPIO_BA 32'h50040000

program test_program (
  output logic [31:0] gpio_m_io_i,  // TB → IP
  input  logic [31:0] gpio_m_io_o,  // IP → TB
  input  logic [31:0] gpio_m_io_t,  // direcție de la IP
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

    base_env = new("Base Environment",
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

    `INFO(("Start GPIO test"), ADI_VERBOSITY_LOW);

    gpio.release_reset();
    gpio.set_direction_output();

    test_ip_output();
    test_tb_input();
    test_irq();

    base_env.stop();
    `INFO(("GPIO Test Done!"), ADI_VERBOSITY_NONE);
    $finish;
  end

  task test_ip_output();
    `INFO(("IP write → TB read"), ADI_VERBOSITY_LOW);

    for (int i = 0; i < 16; i++) begin
      gpio.write_output(i);
      #50;
      if (gpio_m_io_t == 32'h0) begin
        if (gpio_m_io_o == i)
          `INFO(("GPIO_OUT OK: got = %0h", gpio_m_io_o), ADI_VERBOSITY_LOW);
        else
          `ERROR(("GPIO_OUT mismatch: expected = %0h, got = %0h", i, gpio_m_io_o));
      end else
        `ERROR(("GPIO_T indicates tri-state, expected drive."));
    end
  endtask

  task test_tb_input();
    `INFO(("TB write → IP read"), ADI_VERBOSITY_LOW);

    gpio.set_direction_input();

    for (int i = 0; i < 16; i++) begin
      gpio_m_io_i = i;
      #10;
      gpio.read_input(read_data);
      if (read_data == i)
        `INFO(("GPIO_IN OK: %0h", read_data), ADI_VERBOSITY_LOW);
      else
        `ERROR(("GPIO_IN mismatch: expected = %0h, got = %0h", i, read_data));
    end
  endtask

  task test_irq();
    `INFO(("Start IRQ test sequence"), ADI_VERBOSITY_LOW);

    gpio.unmask_irq(32'hFFFFFFFB); // unmask bit 2
    #50;

    gpio_m_io_i = 32'b0;
    #50;
    gpio_m_io_i = 32'b1; // rising edge on bit 0
    #50;

    if (irq_0 != 1'b1)
      `ERROR(("IRQ NOT asserted after GPIO rising edge."));
    else
      `INFO(("IRQ correctly asserted"), ADI_VERBOSITY_LOW);

    gpio.clear_irq_source(32'h4); // clear bit 2
    #300;

    if (irq_0 !== 1'b0)
      `ERROR(("IRQ still asserted after clearing."));
    else
      `INFO(("IRQ correctly deasserted"), ADI_VERBOSITY_LOW);
  endtask

endprogram
