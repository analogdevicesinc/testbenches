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

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import ad57xx_environment_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_pwm_gen_pkg::*;
import adi_regmap_spi_engine_pkg::*;
import spi_engine_instr_pkg::*;
import adi_spi_vip_pkg::*;

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

test_harness_env base_env;

adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

ad57xx_environment spi_env;

// --------------------------
// Wrapper function for AXI read verify
// --------------------------
task axi_read_v(
    input   [31:0]  raddr,
    input   [31:0]  vdata);
  base_env.mng.master_sequencer.RegReadVerify32(raddr,vdata);
endtask

task axi_read(
    input   [31:0]  raddr,
    output  [31:0]  data);
  base_env.mng.master_sequencer.RegRead32(raddr,data);
endtask

// --------------------------
// Wrapper function for AXI write
// --------------------------
task axi_write(
    input [31:0]  waddr,
    input [31:0]  wdata);
  base_env.mng.master_sequencer.RegWrite32(waddr,wdata);
endtask

// --------------------------
// Wrapper function for SPI receive (from DUT)
// --------------------------
task spi_receive(
    output [`DATA_DLENGTH:0]  data);
  spi_env.spi_agent.sequencer.receive_data(data);
endtask

// --------------------------
// Wrapper function for SPI send (to DUT)
// --------------------------
task spi_send(
    input [`DATA_DLENGTH:0]  data);
  spi_env.spi_agent.sequencer.send_data(data);
endtask

// --------------------------
// Wrapper function for waiting for all SPI
// --------------------------
task spi_wait_send();
  spi_env.spi_agent.sequencer.flush_send();
endtask



// --------------------------
// Main procedure
// --------------------------
initial begin

  //creating environment
  base_env = new("Base Environment",
      `TH.`SYS_CLK.inst.IF,
      `TH.`DMA_CLK.inst.IF,
      `TH.`DDR_CLK.inst.IF,
      `TH.`SYS_RST.inst.IF);

  mng = new("", `TH.`MNG_AXI.inst.IF);
  ddr = new("", `TH.`DDR_AXI.inst.IF);

  `LINK(mng, base_env, mng)
  `LINK(ddr, base_env, ddr)

  spi_env = new("SPI Environment",
                `TH.`SPI_S.inst.IF.vif);

  setLoggerVerbosity(ADI_VERBOSITY_NONE);

  base_env.start();
  spi_env.start();

  spi_env.spi_agent.sequencer.set_default_miso_data('h0);

  base_env.sys_reset();

  sanity_test();

  #100ns

  config_spi();

  #100ns

  offload_spi_test(`TEST_DATA_MODE);

  spi_env.stop();
  base_env.stop();

  `INFO(("Test Done"), ADI_VERBOSITY_NONE);
  $finish();

end

//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test();
  bit [31:0] pcore_version = (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_PATCH)
                            | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MINOR)<<8
                            | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MAJOR)<<16;
  axi_read_v (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_VERSION), pcore_version);
  axi_write  (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  axi_read_v (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
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
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS(8'hFE));
  // transfer data

  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), transfer_instr);
  // de-assert CSN
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS(8'hFF));
  // SYNC command to generate interrupt
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`INST_SYNC | sync_id));
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

    axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
    // IRQ launched by Offload SYNC command
    if (irq_pending & 5'b10000) begin
      axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
      `INFO(("Offload SYNC %d IRQ. An offload transfer just finished.",  sync_id), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SYNC command
    if (irq_pending & 5'b01000) begin
      axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
      `INFO(("SYNC %d IRQ. FIFO transfer just finished.", sync_id), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SDI FIFO
    if (irq_pending & 5'b00100) begin
      `INFO(("SDI FIFO IRQ."), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SDO FIFO
    if (irq_pending & 5'b00010) begin
      `INFO(("SDO FIFO IRQ."), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SDO FIFO
    if (irq_pending & 5'b00001) begin
      `INFO(("CMD FIFO IRQ."), ADI_VERBOSITY_LOW);
    end
    // Clear all pending IRQs
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
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

    base_env.ddr.slave_sequencer.set_reg_data_in_mem(.addr(`DDR_BA + 4*i),
                                                  .payload(temp_data),
                                                  .strb('1));
    spi_send('0);
  end

  //Configure TX DMA
  base_env.mng.master_sequencer.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1));
  base_env.mng.master_sequencer.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_FLAGS),
    `SET_DMAC_FLAGS_TLAST(1) |
    `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
    ); // Use TLAST
  base_env.mng.master_sequencer.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH(((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*4)-1));
  base_env.mng.master_sequencer.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_SRC_ADDRESS), `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BA));
  base_env.mng.master_sequencer.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

  // Configure the Offload module
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_CFG);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_PRESCALE);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_DLENGTH);
  if (`CS_ACTIVE_HIGH) begin
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS_INV_MASK(8'hFF));
  end
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS(8'hFE));
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_WR);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS(8'hFF));
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_SYNC | 2);

  // Start the offload
  #100ns
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(1));
  `INFO(("Offload started."), ADI_VERBOSITY_LOW);

  spi_wait_send();

  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(0));

  `INFO(("Offload stopped."), ADI_VERBOSITY_LOW);

  #2000ns

  if (irq_pending == 'h0) begin
    `FATAL(("IRQ Test FAILED"));
  end else begin
    `INFO(("IRQ Test PASSED"), ADI_VERBOSITY_LOW);
  end

  for (int i=0; i<=((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1); i=i+1) begin
    spi_receive(sdo_write_data[i]);
    if (sdo_write_data[i] != sdo_write_data_store[i]) begin
      `INFO(("sdo_write_data[%d]: %x; sdo_write_data_store[%d]: %x", i, sdo_write_data[i], i, sdo_write_data_store[i]), ADI_VERBOSITY_LOW);
      `ERROR(("Offload Write Test FAILED"));
    end
  end
  `INFO(("Offload Test PASSED"), ADI_VERBOSITY_LOW);

endtask

//---------------------------------------------------------------------------
// Config SPI
//---------------------------------------------------------------------------

task config_spi();

  bit [23:0] cfg_readback;

  // Start spi clk generator
  axi_write (`SPI_ENGINE_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
    `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
    `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
    );

  // Config pwm
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD(`PWM_PERIOD)); // set PWM period
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
  `INFO(("axi_pwm_gen started."), ADI_VERBOSITY_LOW);

  // Enable SPI Engine
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));

  // Configure the execution module
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_CFG);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_PRESCALE);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_DLENGTH);
  if (`CS_ACTIVE_HIGH) begin
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS_INV_MASK(8'hFF));
  end

  // Set up the interrupts
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_MASK),
    `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(1) |
    `SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(1)
    );

  #100ns

  //  Write ad57xx control register
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDO_FIFO), (24'h200002));
  generate_transfer_cmd(1,2'b10); // write-only

  // Read ad57xx control register
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDO_FIFO), (24'hA00000));
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDO_FIFO), (24'h000000));
  generate_transfer_cmd(1,2'b10); // one write-only, then one write-read (writing 0 for nop)
  spi_send(24'hA00002);
  generate_transfer_cmd(1,2'b11);

  spi_wait_send();

  repeat (3) spi_receive(temp_data);

  axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDI_FIFO), cfg_readback);

  if (cfg_readback !== 24'hA00002) begin
    `INFO(("cfg_readback: %x; expected 'hA00002", cfg_readback), ADI_VERBOSITY_LOW);
    `FATAL(("Cfg Test FAILED"));
  end else begin
    `INFO(("Cfg Test PASSED"), ADI_VERBOSITY_LOW);
  end
endtask

endprogram
