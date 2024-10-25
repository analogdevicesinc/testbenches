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

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_pwm_gen_pkg::*;
import adi_regmap_spi_engine_pkg::*;
import logger_pkg::*;
import ad57xx_environment_pkg::*;
import spi_engine_instr_pkg::*;
import adi_spi_vip_pkg::*;
import spi_engine_api_pkg::*;

//---------------------------------------------------------------------------
// SPI Engine configuration parameters
//---------------------------------------------------------------------------

program test_program (
  inout ad57xx_spi_irq,
  inout ad57xx_spi_clk);

timeunit 1ns;
timeprecision 100ps;

typedef enum {DATA_MODE_RANDOM, DATA_MODE_RAMP, DATA_MODE_PATTERN} offload_test_t;

ad57xx_environment env;
spi_engine_api spi_api;

// --------------------------
// Wrapper function for SPI receive (from DUT)
// --------------------------
task spi_vip_receive(
    output [`DATA_DLENGTH:0]  data);
  env.spi_seq.receive_data(data);
endtask

// --------------------------
// Wrapper function for SPI send (to DUT)
// --------------------------
task spi_vip_send(
    input [`DATA_DLENGTH:0]  data);
  env.spi_seq.send_data(data);
endtask

// --------------------------
// Wrapper function for waiting for all SPI
// --------------------------
task spi_vip_wait_send();
  env.spi_seq.flush_send();
endtask

// --------------------------
// Main procedure
// --------------------------
initial begin

  //creating environment
  env = new(`TH.`SYS_CLK.inst.IF,
            `TH.`DMA_CLK.inst.IF,
            `TH.`DDR_CLK.inst.IF,
            `TH.`SYS_RST.inst.IF,
            `TH.`MNG_AXI.inst.IF,
            `TH.`DDR_AXI.inst.IF,
            `TH.`SPI_S.inst.IF);

  spi_api = new("SPI_ENG", env.mng, `SPI_ENGINE_SPI_REGMAP_BA);

  setLoggerVerbosity(6);
  env.start();

  env.spi_seq.set_default_miso_data('h0);

  env.sys_reset();

  sanity_test();

  #100ns

  config_spi();

  #100ns

  offload_spi_test(`TEST_DATA_MODE);
  `INFO(("Test Done"));

  $finish;

end

//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test();
  bit [31:0] pcore_version = (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_PATCH)
                            | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MINOR)<<8
                            | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MAJOR)<<16;
  spi_api.check_version(pcore_version);
  spi_api.write_scratch(32'hDEADBEEF);
  spi_api.check_scratch(32'hDEADBEEF);
  `INFO(("Sanity Test Done"));
endtask

//---------------------------------------------------------------------------
// SPI Engine generate transfer
//---------------------------------------------------------------------------

task generate_transfer_cmd(
    input [7:0] sync_id,
    input [1:0] w_r
  );
  logic [32:0] transfer_instr;
  case (w_r)
    2'b11: begin
      transfer_instr = `INST_WRD;
    end
    2'b10: begin
      transfer_instr = `INST_WR;
    end
    default: begin
      transfer_instr = `INST_RD;
    end
  endcase
  // assert CSN
  spi_api.write_fifo_instr(`SET_CS(8'hFE));
  // transfer data
  spi_api.write_fifo_instr(transfer_instr);
  // de-assert CSN
  spi_api.write_fifo_instr(`SET_CS(8'hFF));
  // SYNC command to generate interrupt
  spi_api.write_fifo_instr((`INST_SYNC | sync_id));
  `INFOV(("Transfer generation finished."), 6);
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
    spi_api.get_pending_irq(irq_pending);
    // IRQ launched by Offload SYNC command
    if (irq_pending & 5'b10000) begin
      spi_api.get_sync_id(sync_id);
      `INFOV(("Offload SYNC %d IRQ. An offload transfer just finished.",  sync_id), 6);
    end
    // IRQ launched by SYNC command
    if (irq_pending & 5'b01000) begin
      spi_api.get_sync_id(sync_id);
      `INFOV(("SYNC %d IRQ. FIFO transfer just finished.", sync_id),6);
    end
    // IRQ launched by SDI FIFO
    if (irq_pending & 5'b00100) begin
      `INFOV(("SDI FIFO IRQ."),6);
    end
    // IRQ launched by SDO FIFO
    if (irq_pending & 5'b00010) begin
      `INFOV(("SDO FIFO IRQ."),6);
    end
    // IRQ launched by SDO FIFO
    if (irq_pending & 5'b00001) begin
      `INFOV(("CMD FIFO IRQ."),6);
    end
    // Clear all pending IRQs
    spi_api.clear_irq(irq_pending);
  end
end

//---------------------------------------------------------------------------
// Offload SPI Test
//---------------------------------------------------------------------------

bit [`DATA_DLENGTH-1:0] sdo_write_data [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1 :0] = '{default:'0};
bit [`DATA_DLENGTH-1:0] sdo_write_data_store [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1 :0];
bit [17:0] dac_word;
bit [`DATA_DLENGTH-1:0] temp_data;

task offload_spi_test(
  input offload_test_t data_mode
);

  // Enqueue transfers to DUT
  for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
    case (data_mode)
      DATA_MODE_RANDOM: begin
        dac_word = $urandom;
      end
      DATA_MODE_RAMP: begin
        dac_word = i;
      end
      DATA_MODE_PATTERN: begin
        dac_word = 'h1A50F;
      end
      default: begin
        dac_word = 'h3FFFF;
      end
    endcase
    temp_data = {4'b0001,dac_word,2'b00};
    sdo_write_data_store [i] = temp_data;
    // store dac payload in memory for streaming to DUT
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(.addr(`DDR_BA + 4*i),
                                                  .payload(temp_data),
                                                  .strb('1));
    spi_vip_send('0);
  end

  //Configure TX DMA
  env.mng.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1));
  env.mng.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_FLAGS),
    `SET_DMAC_FLAGS_TLAST(1) |
    `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
    ); // Use TLAST
  env.mng.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH(((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*4)-1));
  env.mng.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_SRC_ADDRESS), `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BA));
  env.mng.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

  // Configure the Offload module
  spi_api.write_offload_instr(`INST_CFG);
  spi_api.write_offload_instr(`INST_PRESCALE);
  spi_api.write_offload_instr(`INST_DLENGTH);
  if (`CS_ACTIVE_HIGH) begin
    spi_api.write_offload_instr(`SET_CS_INV_MASK(8'hFF));
  end
  spi_api.write_offload_instr(`SET_CS(8'hFE));
  spi_api.write_offload_instr(`INST_WR);
  spi_api.write_offload_instr(`SET_CS(8'hFF));
  spi_api.write_offload_instr(`INST_SYNC | 2);

  // Start the offload
  #100ns
  spi_api.enable_offload();
  `INFOV(("Offload started."),6);

  spi_vip_wait_send();

  spi_api.disable_offload();
  `INFOV(("Offload stopped."),6);

  #2000ns

  if (irq_pending == 'h0) begin
    `ERROR(("IRQ Test FAILED"));
  end else begin
    `INFO(("IRQ Test PASSED"));
  end

  for (int i=0; i<=((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1); i=i+1) begin
    spi_vip_receive(sdo_write_data[i]);
    if (sdo_write_data[i] != sdo_write_data_store[i]) begin
      `INFOV(("sdo_write_data[%d]: %x; sdo_write_data_store[%d]: %x", i, sdo_write_data[i], i, sdo_write_data_store[i]),6);
      `ERROR(("Offload Write Test FAILED"));
    end
  end
  `INFO(("Offload Test PASSED"));

endtask

//---------------------------------------------------------------------------
// Config SPI
//---------------------------------------------------------------------------

task config_spi();

  bit [23:0] cfg_readback;

  // Start spi clk generator
  env.mng.RegWrite32(`SPI_ENGINE_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
    `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
    `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
    );

  // Config pwm
  env.mng.RegWrite32(`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
  env.mng.RegWrite32(`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD(`PWM_PERIOD)); // set PWM period
  env.mng.RegWrite32(`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
  `INFOV(("axi_pwm_gen started."),6);

  // Enable SPI Engine
  spi_api.enable_spi();

  // Enable SDO Offload
  spi_api.enable_sdo_streaming();

  // Configure the execution module
  spi_api.write_fifo_instr(`INST_CFG);
  spi_api.write_fifo_instr(`INST_PRESCALE);
  spi_api.write_fifo_instr(`INST_DLENGTH);
  if (`CS_ACTIVE_HIGH) begin
    spi_api.write_fifo_instr(`SET_CS_INV_MASK(8'hFF));
  end

  // Set up the interrupts
  spi_api.set_irq_mask(5'b11000); // SYNC_EVENT | OFFLOAD_SYNC_ID_PENDING

  #100ns

  //  Write ad57xx control register
  spi_api.write_sdo_fifo(24'h200002);
  generate_transfer_cmd(1,2'b10); // write-only

  // Read ad57xx control register
  spi_api.write_sdo_fifo(24'hA00000);
  spi_api.write_sdo_fifo(24'h000000);
  generate_transfer_cmd(1,2'b10); // one write-only, then one write-read (writing 0 for nop)
  spi_vip_send(24'hA00002);
  generate_transfer_cmd(1,2'b11);

  spi_vip_wait_send();

  repeat (3) spi_vip_receive(temp_data);

  spi_api.read_sdi_fifo(cfg_readback);

  if (cfg_readback !== 24'hA00002) begin
    `INFOV(("cfg_readback: %x; expected 'hA00002", cfg_readback),6);
    `ERROR(("Cfg Test FAILED"));
  end else begin
    `INFO(("Cfg Test PASSED"));
  end
endtask

endprogram
