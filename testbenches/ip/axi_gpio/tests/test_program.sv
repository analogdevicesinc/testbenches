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
  logic [31:0] irq_pending = 32'h0;
  logic [31:0] regval;


  // Test sequence: 0 -> 1 -> 0 -> 2 -> 0 -> 4 -> 0 -> 8 -> 0
  // This creates rising and falling edges on individual GPIO pins (bits 0,1,2,3)
  // Values 1,2,4,8 correspond to GPIO bits 0,1,2,3 respectively
  int irq_seq[0:8] = '{32'h0, 32'h1, 32'h0, 32'h2, 32'h0, 32'h4, 32'h0, 32'h8, 32'h0};

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
    // Don't set direction here - let the IRQ test handle it

   // test_tb_input();
    test_irq_multiple();

    base_env.stop();
    `INFO(("GPIO Test Done!"), ADI_VERBOSITY_NONE);
    $finish;
  end

  task test_ip_output();
    `INFO(("IP write - TB read"), ADI_VERBOSITY_LOW);

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
    `INFO(("TB write - IP read"), ADI_VERBOSITY_LOW);

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


task test_irq_multiple();
  `INFO(("Start GPIO IRQ test (fan control style sequence)"), ADI_VERBOSITY_LOW);

  // Debug: Print register addresses
  $display("[%0t] GPIO Register addresses:", $time);
  $display("  GPIO_REG_INPUT = 0x%0h", `GPIO_REG_INPUT);
  $display("  GPIO_REG_IRQ_PENDING = 0x%0h", `GPIO_REG_IRQ_PENDING);
  $display("  GPIO_REG_IRQ_MASK = 0x%0h", `GPIO_REG_IRQ_MASK);

  // Set direction to input for IRQ testing
  gpio.set_direction_input();

  // Enable interrupts for bits 0-3 (mask logic is inverted: 0=enabled, 1=disabled)
  // So we need to write ~(0x0F) = 0xFFFFFFF0 to enable IRQs for bits 0-3
  gpio.unmask_irq(32'hFFFFFFF0);

  // Verify mask was set correctly
  gpio.axi_read(`GPIO_REG_IRQ_MASK, regval);
  $display("[%0t] IRQ mask set to: 0x%0h", $time, regval);

  // Wait for configuration to settle
  #500;

  // Initialize gpio_m_io_i to ensure clean starting state
  gpio_m_io_i = 32'h0;
  #200;

  // Read initial state
  gpio.read_input(read_data);
  $display("[%0t] Initial state: gpio_m_io_i = 0x%0h, read_data = 0x%0h, irq = %0b",
           $time, gpio_m_io_i, read_data, irq_0);



  for (int i = 0; i < 9; i++) begin
    // Drive new value
    gpio_m_io_i = irq_seq[i];

    // Wait for edge detection and propagation
    #500;

    // Read the input register with additional wait for AXI transaction
    gpio.read_input(read_data);
    #100; // Additional wait for AXI read completion

    $display("[%0t] Step %0d: gpio_m_io_i = 0x%0h, read_data = 0x%0h, irq = %0b",
             $time, i, gpio_m_io_i, read_data, irq_0);

    // Check if IRQ is asserted
    if (irq_0) begin
      gpio.axi_read(`GPIO_REG_IRQ_PENDING, irq_pending);
      $display("[%0t] *** IRQ ASSERTED *** - IRQ_PENDING = 0x%0h", $time, irq_pending);

      // Decode which bits triggered
      if (irq_pending & 32'h1) $display("[%0t] NOTE: GPIO IRQ[0] pending", $time);
      if (irq_pending & 32'h2) $display("[%0t] NOTE: GPIO IRQ[1] pending", $time);
      if (irq_pending & 32'h4) $display("[%0t] NOTE: GPIO IRQ[2] pending", $time);
      if (irq_pending & 32'h8) $display("[%0t] NOTE: GPIO IRQ[3] pending", $time);

      // Clear the pending interrupts
      gpio.axi_write(`GPIO_REG_IRQ_CLEAR, irq_pending);
      $display("[%0t] Cleared IRQ sources = 0x%0h", $time, irq_pending);

      // Wait for IRQ to clear
      #200;

      if (!irq_0) begin
        $display("[%0t] IRQ successfully cleared", $time);
      end else begin
        $display("[%0t] WARNING: IRQ still asserted after clear", $time);
      end
    end else begin
      $display("[%0t] IRQ not asserted", $time);
    end

    #300; // Wait before next transition
  end

  `INFO(("GPIO IRQ sequence complete."), ADI_VERBOSITY_LOW);
endtask



endprogram
