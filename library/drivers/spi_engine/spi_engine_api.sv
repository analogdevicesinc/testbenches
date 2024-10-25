`include "utils.svh"

package spi_engine_api_pkg;

  import logger_pkg::*;
  import adi_peripheral_pkg::*;
  import adi_regmap_spi_engine_pkg::*;
  import adi_regmap_pkg::*;
  import reg_accessor_pkg::*;
  import spi_engine_instr_pkg::*;

  class spi_engine_api extends adi_peripheral;

    function new (string name, reg_accessor bus, bit [31:0] base_address);
      super.new(name, bus, base_address);
    endfunction

    task get_version(output bit [31:0] ver);
      this.axi_read(GetAddrs(AXI_SPI_ENGINE_VERSION),ver);
    endtask : get_version

    task check_version(input bit [31:0] expected);
      this.axi_verify(GetAddrs(AXI_SPI_ENGINE_VERSION), expected);
    endtask : check_version

    task write_scratch(input bit [31:0] data);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_SCRATCH), `SET_AXI_SPI_ENGINE_SCRATCH_SCRATCH(data));
    endtask : write_scratch

    task read_scratch(output bit [31:0] data);
      bit [31:0] regData;
      this.axi_read(GetAddrs(AXI_SPI_ENGINE_SCRATCH), regData);
      data = `GET_AXI_SPI_ENGINE_SCRATCH_SCRATCH(regData);
    endtask : read_scratch

    task check_scratch(input bit [31:0] expected);
      this.axi_verify(GetAddrs(AXI_SPI_ENGINE_SCRATCH), expected);
    endtask : check_scratch

    task enable_spi();
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_ENABLE),
                      `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));
    endtask : enable_spi

    task disable_spi();
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_ENABLE),
                      `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(1));
    endtask : disable_spi

    task enable_offload();
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN),
                      `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(1));
    endtask : enable_offload

    task disable_offload();
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN),
                      `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(0));
    endtask : disable_offload

    task enable_sdo_streaming();
      this.axi_write('h10C, 1); // FIXME: use regmap
    endtask : enable_sdo_streaming

    task disable_sdo_streaming();
      this.axi_write('h10C, 0); // FIXME: use regmap
    endtask : disable_sdo_streaming

    task set_irq_mask(input bit[4:0] flags);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_IRQ_MASK),
                        `SET_AXI_SPI_ENGINE_IRQ_MASK_CMD_ALMOST_EMPTY(flags[0])|
                        `SET_AXI_SPI_ENGINE_IRQ_MASK_SDO_ALMOST_EMPTY(flags[1])|
                        `SET_AXI_SPI_ENGINE_IRQ_MASK_SDI_ALMOST_FULL(flags[2]) |
                        `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(flags[3])      |
                        `SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(flags[4]));
    endtask : set_irq_mask

    task write_sdo_fifo(input bit[31:0] data);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_SDO_FIFO), `SET_AXI_SPI_ENGINE_SDO_FIFO_SDO_FIFO(data));
    endtask : write_sdo_fifo

    task read_sdi_fifo(output bit [31:0] data);
      bit [31:0] regData;
      this.axi_read(GetAddrs(AXI_SPI_ENGINE_SDI_FIFO), regData);
      data = `GET_AXI_SPI_ENGINE_SDI_FIFO_SDI_FIFO(regData);
    endtask : read_sdi_fifo

    //FIXME: IRQ callback? Or maybe something that allows the user to register a callback?
    task get_pending_irq(output bit [4:0] irq_pending);
      bit [31:0] regData;
      this.axi_read(GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING),regData);
      irq_pending = `GET_AXI_SPI_ENGINE_IRQ_PENDING_IRQ_PENDING(regData);
    endtask : get_pending_irq

    task clear_irq(input bit [4:0] irq_pending);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING),`SET_AXI_SPI_ENGINE_IRQ_PENDING_IRQ_PENDING(irq_pending));
    endtask : clear_irq

    task get_sync_id(output bit [7:0] sync_id);
      bit [31:0] regData;
      this.axi_read(GetAddrs(AXI_SPI_ENGINE_SYNC_ID), regData);
      regData = `GET_AXI_SPI_ENGINE_SYNC_ID_SYNC_ID(sync_id);
    endtask : get_sync_id

    task write_offload_instr(input bit [31:0] instr);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO_OFFLOAD0_CDM_FIFO(instr));
    endtask : write_offload_instr

    task write_fifo_instr(input bit [31:0] instr);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_AXI_SPI_ENGINE_CMD_FIFO_CMD_FIFO(instr));
    endtask : write_fifo_instr

    task write_offload_sdo_fifo(input bit [31:0] data);
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO), `SET_AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO_OFFLOAD0_SDO_FIFO(data));
    endtask : write_offload_sdo_fifo

    task reset_offload_mem();
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET), `SET_AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(1));
      this.axi_write(GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET), `SET_AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(0));
    endtask : reset_offload_mem

  endclass : spi_engine_api

endpackage : spi_engine_api_pkg