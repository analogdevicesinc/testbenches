// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2026 Analog Devices, Inc. All rights reserved.
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

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import spi_environment_pkg::*;
import spi_engine_api_pkg::*;
import dmac_api_pkg::*;
import pwm_gen_api_pkg::*;
import clk_gen_api_pkg::*;
import spi_engine_instr_pkg::*;
import adi_spi_vip_pkg::*;
import axi_vip_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

//---------------------------------------------------------------------------
// SPI Engine configuration parameters
//---------------------------------------------------------------------------

program test_program (
  inout ad57xx_spi_irq,
  inout ad57xx_spi_clk);

  timeunit 1ns;
  timeprecision 100ps;

  typedef enum {DATA_MODE_RANDOM, DATA_MODE_RAMP, DATA_MODE_PATTERN} offload_test_t;

  // declare the class instances
  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;
  spi_environment spi_env;
  spi_engine_api spi_api;
  dmac_api dma_api;
  pwm_gen_api pwm_api;
  clk_gen_api clkgen_api;

  // --------------------------
  // Wrapper function for SPI receive (from DUT)
  // --------------------------
  task automatic spi_receive(
      ref int unsigned data[]);
    spi_env.spi_agent.sequencer.receive_data(data);
  endtask

  // --------------------------
  // Wrapper function for SPI send (to DUT)
  // --------------------------
  task spi_send(
      input [`DATA_DLENGTH-1:0] data[]);
    spi_env.spi_agent.sequencer.send_data(data);
  endtask

  // --------------------------
  // Wrapper function for waiting for all SPI
  // --------------------------
  task spi_wait_send();
    spi_env.spi_agent.sequencer.flush_send();
  endtask

  bit   [              7:0] sdi_lane_mask;
  bit   [              7:0] sdo_lane_mask;
  bit [`DATA_DLENGTH-1:0] rx_data [];
  int unsigned            receive_data [];

// --------------------------
// Main procedure
// --------------------------
initial begin

  setLoggerVerbosity(ADI_VERBOSITY_NONE);

  //creating environment
  base_env = new(
    .name("Base Environment"),
    .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
    .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
    .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
    .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
    .irq_base_address(`IRQ_C_BA),
    .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

  mng = new("", `TH.`MNG_AXI.inst.IF);
  ddr = new("", `TH.`DDR_AXI.inst.IF);

  `LINK(mng, base_env, mng)
  `LINK(ddr, base_env, ddr)

  spi_env = new("SPI Environment",
                `TH.`SPI_S.inst.IF.vif);

  spi_api = new("SPI Engine API",
                base_env.mng.master_sequencer,
                `SPI_ENGINE_SPI_REGMAP_BA);

  dma_api = new("TX DMA API",
                base_env.mng.master_sequencer,
                `SPI_ENGINE_TX_DMA_BA);

  clkgen_api = new("CLKGEN API",
                   base_env.mng.master_sequencer,
                   `SPI_ENGINE_AXI_CLKGEN_BA);

  pwm_api = new("PWM API",
                base_env.mng.master_sequencer,
                `SPI_ENGINE_PWM_GEN_BA);

  base_env.start();
  spi_env.start();

  base_env.sys_reset();

  spi_env.spi_agent.sequencer.set_default_miso_data('h0);

  sanity_tests();

  init();

  sdi_lane_mask = (2 ** `NUM_OF_MISO)-1;
  sdo_lane_mask = (2 ** `NUM_OF_MOSI)-1;
  spi_api.fifo_command(`SET_SDI_LANE_MASK(sdi_lane_mask));
  spi_api.fifo_command(`SET_SDO_LANE_MASK(sdo_lane_mask));

  offload_spi_test(`TEST_DATA_MODE);

  spi_env.stop();
  base_env.stop();

  `INFO(("Test Done"), ADI_VERBOSITY_NONE);
  $finish();

end

//---------------------------------------------------------------------------
// Sanity Tests
//---------------------------------------------------------------------------
task sanity_tests();
  spi_api.sanity_test();
  dma_api.sanity_test();
  pwm_api.sanity_test();
endtask

//---------------------------------------------------------------------------
// SPI Engine generate transfer
//---------------------------------------------------------------------------
task generate_transfer_cmd(
    input [7:0] sync_id,
    input [1:0] w_r);
  logic [32:0] transfer_instr;
  case (w_r)
    2'b11: transfer_instr = `INST_WRD;
    2'b10: transfer_instr = `INST_WR;
    default: transfer_instr = `INST_RD;
  endcase
  // assert CSN
  spi_api.fifo_command(`SET_CS(8'hFE));
  // transfer data
  spi_api.fifo_command(transfer_instr);
  // de-assert CSN
  spi_api.fifo_command(`SET_CS(8'hFF));
  // SYNC command to generate interrupt
  spi_api.fifo_command(`INST_SYNC | sync_id);
  `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
endtask

//---------------------------------------------------------------------------
// IRQ callback
//---------------------------------------------------------------------------
reg [4:0] irq_pending = 0;
reg [7:0] sync_id = 0;

initial begin
  forever begin
    @(posedge ad57xx_spi_irq);
    // read pending IRQs
    spi_api.get_irq_pending(irq_pending);
    // IRQ launched by Offload SYNC command
    if (spi_api.check_irq_offload_sync_id_pending(irq_pending)) begin
      spi_api.get_sync_id(sync_id);
      `INFO(("Offload SYNC %d IRQ. An offload transfer just finished.",  sync_id), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SYNC command
    if (spi_api.check_irq_sync_event(irq_pending)) begin
      spi_api.get_sync_id(sync_id);
      `INFO(("SYNC %d IRQ. FIFO transfer just finished.", sync_id), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SDI FIFO
    if (spi_api.check_irq_sdi_almost_full(irq_pending)) begin
      `INFO(("SDI FIFO IRQ."), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SDO FIFO
    if (spi_api.check_irq_sdo_almost_empty(irq_pending)) begin
      `INFO(("SDO FIFO IRQ."), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by CMD FIFO
    if (spi_api.check_irq_cmd_almost_empty(irq_pending)) begin
      `INFO(("CMD FIFO IRQ."), ADI_VERBOSITY_LOW);
    end
    // Clear all pending IRQs
    spi_api.clear_irq_pending(irq_pending);
  end
end

//---------------------------------------------------------------------------
// Offload SPI Test
//---------------------------------------------------------------------------
bit [`DATA_DLENGTH-1:0] sdo_write_data [];
bit [`DATA_DLENGTH-1:0] sdo_write_data_store [];
bit [17:0] dac_word;
bit [`DATA_DLENGTH-1:0] temp_data;

task offload_spi_test(
  input offload_test_t data_mode
);

  // Allocate dynamic arrays
  rx_data              = new [`NUM_OF_MISO];
  receive_data         = new [`NUM_OF_MOSI];
  sdo_write_data       = new [`NUM_OF_MOSI];
  sdo_write_data_store = new [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*(`NUM_OF_MOSI)];

  // Enqueue transfers to DUT
  for (int i = 0; i < ((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)); i++) begin
    case (data_mode)
      DATA_MODE_RANDOM: dac_word = $urandom;
      DATA_MODE_RAMP:   dac_word = i;
      DATA_MODE_PATTERN: dac_word = 'h1A50F;
      default: dac_word = 'h3FFFF;
    endcase
    temp_data = {4'b0001, dac_word, 2'b00};
    sdo_write_data_store[i] = temp_data;

    base_env.ddr.slave_sequencer.BackdoorWrite32(.addr(xil_axi_uint'(`DDR_BA + 4*i)),
                                                  .data(temp_data),
                                                  .strb('1));
    // Enqueue expected data for VIP (zeros since we only write)
    for (int j = 0; j < `NUM_OF_MISO; j++) begin
      rx_data[j] = '0;
    end
    spi_send(rx_data);
  end

  //Configure TX DMA
  dma_api.enable_dma();
  dma_api.set_flags(
    .cyclic(1'b0),
    .tlast(1'b1),
    .partial_reporting_en(1'b1)
  );
  dma_api.set_lengths(((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*(`DATA_WIDTH/8))-1, 0);
  dma_api.set_src_addr(`DDR_BA);
  dma_api.transfer_start();

  // Configure the Offload module
  spi_api.fifo_offload_command(`INST_CFG);
  spi_api.fifo_offload_command(`INST_PRESCALE);
  spi_api.fifo_offload_command(`INST_DLENGTH);
  if (`CS_ACTIVE_HIGH) begin
    spi_api.fifo_offload_command(`SET_CS_INV_MASK(8'hFF));
  end
  spi_api.fifo_offload_command(`SET_CS(8'hFE));
  spi_api.fifo_offload_command(`INST_WR);
  spi_api.fifo_offload_command(`SET_CS(8'hFF));
  spi_api.fifo_offload_command(`INST_SYNC | 2);

  // Start the offload
  #100ns;
  spi_api.start_offload();
  `INFO(("Offload started."), ADI_VERBOSITY_LOW);

  spi_wait_send();

  spi_api.stop_offload();
  `INFO(("Offload stopped."), ADI_VERBOSITY_LOW);

  #2000ns;

  if (irq_pending == 'h0) begin
    `FATAL(("IRQ Test FAILED"));
  end else begin
    `INFO(("IRQ Test PASSED"), ADI_VERBOSITY_LOW);
  end

  for (int i = 0; i < ((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)); i++) begin
    spi_receive(receive_data);
    for (int j = 0; j < `NUM_OF_MOSI; j++) begin
      sdo_write_data[j] = receive_data[j];
      if (sdo_write_data[j] != sdo_write_data_store[i * `NUM_OF_MOSI + j]) begin
        `INFO(("sdo_write_data[%d]: %x; sdo_write_data_store[%d]: %x",
               j, sdo_write_data[j],
               i * `NUM_OF_MOSI + j, sdo_write_data_store[i * `NUM_OF_MOSI + j]), ADI_VERBOSITY_LOW);
        `FATAL(("Offload Write Test FAILED"));
      end
    end
  end
  `INFO(("Offload Test PASSED"), ADI_VERBOSITY_LOW);

endtask

//---------------------------------------------------------------------------
// Test initialization
//---------------------------------------------------------------------------
task init();
  // Start spi clk generator
  clkgen_api.enable_clkgen();

  // Config pwm
  pwm_api.reset();
  pwm_api.pulse_period_config(0, `PWM_PERIOD);
  pwm_api.load_config();
  pwm_api.start();
  `INFO(("axi_pwm_gen started."), ADI_VERBOSITY_LOW);

  // Enable SPI Engine
  spi_api.enable_spi_engine();

  // Configure the execution module
  spi_api.fifo_command(`INST_CFG);
  spi_api.fifo_command(`INST_PRESCALE);
  spi_api.fifo_command(`INST_DLENGTH);
  if (`CS_ACTIVE_HIGH) begin
    spi_api.fifo_command(`SET_CS_INV_MASK(8'hFF));
  end

  // Set up the interrupts
  spi_api.set_interrup_mask(.sync_event(1'b1), .offload_sync_id_pending(1'b1));

endtask

endprogram
