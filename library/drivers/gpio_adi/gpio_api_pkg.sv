`include "utils.svh"
`include "gpio_definitions.svh"

package gpio_api_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;
  import m_axi_sequencer_pkg::*;

  class gpio_api extends adi_api;
    protected logic [31:0] val;

    function new(string name,
                 m_axi_sequencer_base bus,
                 bit [31:0] base_address,
                 adi_component parent = null);
      super.new(name, bus, base_address, parent);
    endfunction

    virtual task axi_write(logic [31:0] addr, logic [31:0] data);
      bus.RegWrite32(addr, data);
    endtask

    virtual task axi_read(logic [31:0] addr, output logic [31:0] data);
      bus.RegRead32(addr, data);
    endtask

    task release_reset();        axi_write(`GPIO_REG_RST,       1); endtask
    task set_direction_output(); axi_write(`GPIO_REG_TRI,       32'hFFFFFFFF); endtask
    task set_direction_input();  axi_write(`GPIO_REG_TRI,       32'h00000000); endtask
    task write_output(input logic [31:0] d);      axi_write(`GPIO_REG_DATA,     d); endtask
    task read_input(output logic [31:0] d);       axi_read (`GPIO_REG_INPUT,    d); endtask
    task unmask_irq(input logic [31:0] m);        axi_write(`GPIO_REG_IRQ_MASK, m); endtask
    task clear_irq_source(input logic [31:0] m);  axi_write(`GPIO_REG_IRQ_CLEAR, m); endtask
  endclass
endpackage


