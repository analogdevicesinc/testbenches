// ***************************************************************************
// ***************************************************************************
// Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
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
import spi_environment_pkg::*;
import spi_engine_instr_pkg::*;
import adi_spi_vip_pkg::*;

//---------------------------------------------------------------------------
// SPI Engine configuration parameters
//---------------------------------------------------------------------------

program test_sleep_delay (
  inout spi_engine_irq,
  inout spi_engine_spi_sclk,
  inout [(`NUM_OF_CS - 1):0] spi_engine_spi_cs,
  inout spi_engine_spi_clk,
  `ifdef DEF_ECHO_SCLK
  inout spi_engine_echo_sclk,
  `endif
  inout [(`NUM_OF_SDI - 1):0] spi_engine_spi_sdi);

timeunit 1ns;
timeprecision 100ps;

spi_environment env;

// --------------------------
// Wrapper function for AXI read verify
// --------------------------
task axi_read_v(
    input   [31:0]  raddr,
    input   [31:0]  vdata);
  env.mng.RegReadVerify32(raddr,vdata);
endtask

task axi_read(
    input   [31:0]  raddr,
    output  [31:0]  data);
  env.mng.RegRead32(raddr,data);
endtask

// --------------------------
// Wrapper function for AXI write
// --------------------------
task axi_write(
    input [31:0]  waddr,
    input [31:0]  wdata);
  env.mng.RegWrite32(waddr,wdata);
endtask

// --------------------------
// Wrapper function for SPI receive (from DUT)
// --------------------------
task spi_receive(
    output [`DATA_DLENGTH:0]  data);
  env.spi_seq.receive_data(data);
endtask

// --------------------------
// Wrapper function for SPI send (to DUT)
// --------------------------
task spi_send(
    input [`DATA_DLENGTH:0]  data);
  env.spi_seq.send_data(data);
endtask

// --------------------------
// Wrapper function for waiting for all SPI
// --------------------------
task spi_wait_send();
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
            `TH.`SPI_S.inst.IF
            );

  setLoggerVerbosity(6);
  env.start();

  env.spi_seq.set_default_miso_data('h2AA55);

  env.sys_reset();

  sanity_test();

  #100ns

  sleep_delay_test(7);

  cs_delay_test(3,3);

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
  axi_read_v (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_VERSION), pcore_version);
  axi_write  (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  axi_read_v (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  `INFO(("Sanity Test Done"));
endtask

//---------------------------------------------------------------------------
// IRQ callback
//---------------------------------------------------------------------------

reg [4:0] irq_pending = 0;
reg [7:0] sync_id = 0;

initial begin
  forever begin
    @(posedge spi_engine_irq);
    // read pending IRQs
    axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
    // IRQ launched by Offload SYNC command
    if (irq_pending & 5'b10000) begin
      axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD_SYNC_ID), sync_id);
      `INFOV(("Offload SYNC %d IRQ. An offload transfer just finished.", sync_id),6);
    end
    // IRQ launched by SYNC command
    if (irq_pending & 5'b01000) begin
      axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
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
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
  end
end

//---------------------------------------------------------------------------
// Echo SCLK generation - we need this only if ECHO_SCLK is enabled
//---------------------------------------------------------------------------
`ifdef DEF_ECHO_SCLK
  assign #(`ECHO_SCLK_DELAY * 1ns) spi_engine_echo_sclk = spi_engine_spi_sclk;
`endif

//---------------------------------------------------------------------------
// Sleep and Chip Select Instruction time counter
//---------------------------------------------------------------------------

int sleep_instr_time[$];
int sleep_duration;
int sleep_current_duration;
bit sleeping;
int cs_instr_time[$];
int cs_current_duration;
int cs_duration;
bit cs_sleeping;
wire [15:0] cmd, cmd_d1;
wire cmd_valid, cmd_ready;
wire idle;

assign cmd          = `TH.spi_engine.spi_engine_execution.inst.cmd;
assign cmd_d1       = `TH.spi_engine.spi_engine_execution.inst.cmd_d1;
assign cmd_valid    = `TH.spi_engine.spi_engine_execution.inst.cmd_valid;
assign cmd_ready    = `TH.spi_engine.spi_engine_execution.inst.cmd_ready;
assign idle         = `TH.spi_engine.spi_engine_execution.inst.idle;

initial begin
  sleep_current_duration = 0;
  sleep_duration = 0;
  sleeping = 1'b0;
  cs_current_duration = 0;
  cs_duration = 0;
  cs_sleeping = 1'b0;
  forever begin
    @(posedge spi_engine_spi_clk);
      if (idle && (cmd_d1[15:8] == 8'h31) && sleeping) begin
        sleeping <= 1'b0;
        sleep_duration = sleep_current_duration+1;
        sleep_instr_time.push_front(sleep_current_duration+1); // add one to account for this cycle
      end
      if (cmd_valid && cmd_ready && (cmd[15:8] == 8'h31)) begin
        sleep_current_duration <= 0;
        sleeping <= 1'b1;
      end else begin
        sleep_current_duration <= sleep_current_duration+1;
      end
      if (idle && (cmd_d1[15:10] == 6'h4) && cs_sleeping) begin
        cs_sleeping = 1'b0;
        cs_duration = cs_current_duration+1;
        cs_instr_time.push_front(cs_current_duration+1); // add one to account for this cycle
      end
      if (cmd_valid && cmd_ready && (cmd[15:10] == 6'h4)) begin
        cs_current_duration <= 0;
        cs_sleeping <= 1'b1;
      end else begin
        cs_current_duration <= cs_current_duration+1;
      end
  end
end

//---------------------------------------------------------------------------
// Sleep delay Test
//---------------------------------------------------------------------------

int sleep_time;
int expected_sleep_time;

task sleep_delay_test(
    input [7:0] sleep_param);
  // Start spi clk generator
  axi_write (`SPI_ENGINE_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
    `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
    `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
    );

  // Config pwm
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('d1000)); // set PWM period
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
  `INFOV(("axi_pwm_gen started."),6);

  // Enable SPI Engine
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));

  // Set up the interrupts
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_MASK),
    `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(1) |
    `SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(1)
    );

  // Write commands
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_CFG);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_PRESCALE);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_DLENGTH(`DATA_WIDTH - `DATA_DLENGTH));
  if (`CS_ACTIVE_HIGH) begin
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS_INV_MASK(8'hFF));
  end

  expected_sleep_time = 2+(sleep_param+1)*((`CLOCK_DIVIDER+1)*2);
  // Start the test
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`SLEEP(sleep_param)));

  #2000ns
  sleep_time = sleep_instr_time.pop_back();
  if ((sleep_time != expected_sleep_time)) begin
      `ERROR(("Sleep Test FAILED: unexpected sleep instruction duration. Expected=%d, Got=%d",expected_sleep_time,sleep_time));
  end else begin
      `INFO(("Sleep Test PASSED"));
  end

  // change the SPI word size (this should not affect sleep delay)
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_DLENGTH);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`SLEEP(sleep_param)));
  #2000ns
  sleep_time = sleep_instr_time.pop_back();
  #100ns
  if ((sleep_time != expected_sleep_time)) begin
      `ERROR(("Sleep Test FAILED: unexpected sleep instruction duration. Expected=%d, Got=%d",expected_sleep_time,sleep_time));
  end else begin
      `INFO(("Sleep Test PASSED"));
  end

  // Disable SPI Engine
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), 1);
endtask

//---------------------------------------------------------------------------
// CS delay Test
//---------------------------------------------------------------------------

bit [`DATA_DLENGTH:0] offload_captured_word_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)-1:0];
bit [`DATA_DLENGTH:0] offload_sdi_data_store_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)-1:0];
int cs_activate_time;
int expected_cs_activate_time;
int cs_deactivate_time;
int expected_cs_deactivate_time;
bit [`DATA_DLENGTH-1:0] temp_data;

task cs_delay_test(
    input [1:0] cs_activate_delay,
    input [1:0] cs_deactivate_delay);
  // Start spi clk generator
  axi_write (`SPI_ENGINE_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
    `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
    `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
    );

  // Config cnv
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1));
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('d1000)); // set PWM period
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1));
  `INFOV(("axi_pwm_gen started."), 6);

  //Configure DMA
  env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1));
  env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_FLAGS),
    `SET_DMAC_FLAGS_TLAST(1) |
    `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
    ); // Use TLAST
  env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH(((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)*4)-1));
  env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_DEST_ADDRESS), `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA));
  env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

  // Enable SPI Engine
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));

  // Set up the interrupts
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_MASK),
  `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(1) |
  `SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(1)
  );

  // Configure the Offload module
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET), `SET_AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(1));
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET), `SET_AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(0));
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_CFG);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_PRESCALE);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_DLENGTH);
  if (`CS_ACTIVE_HIGH) begin
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS_INV_MASK(8'hFF));
  end
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS(8'hFE));
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_RD);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS(8'hFF));
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_SYNC | 1);

  expected_cs_activate_time = 2;
  expected_cs_deactivate_time = 2;

  // Enqueue transfers to DUT
  for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
    temp_data = $urandom;
    spi_send(temp_data);
    offload_sdi_data_store_arr[i] = temp_data;
  end

  // Start the offload
  #100ns
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(1));
  `INFOV(("Offload started (no delay on CS change)."), 6);

  spi_wait_send();

  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(0));

  `INFOV(("Offload stopped (no delay on CS change)."), 6);

  #2000ns

  for (int i=0; i<=(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS); i=i+1) begin
    offload_captured_word_arr[i][`DATA_DLENGTH-1:0] = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(`DDR_BA + 4*i);
  end

  if (irq_pending == 'h0) begin
    `ERROR(("IRQ Test FAILED"));
  end else begin
    `INFO(("IRQ Test PASSED"));
  end

  if (offload_captured_word_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) - 1:0] !== offload_sdi_data_store_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) - 1:0]) begin
    `ERROR(("CS Delay Test FAILED: bad data"));
  end

  repeat (`NUM_OF_TRANSFERS) begin
    cs_activate_time = cs_instr_time.pop_back();
    cs_deactivate_time = cs_instr_time.pop_back();
  end
  if ((cs_activate_time != expected_cs_activate_time)) begin
    `ERROR(("CS Delay Test FAILED: unexpected chip select activate instruction duration. Expected=%d, Got=%d",expected_cs_activate_time,cs_activate_time));
  end
  if (cs_deactivate_time != expected_cs_deactivate_time) begin
    `ERROR(("CS Delay Test FAILED: unexpected chip select deactivate instruction duration. Expected=%d, Got=%d",expected_cs_deactivate_time,cs_deactivate_time));
  end
  `INFO(("CS Delay Test PASSED"));

  #2000ns
  env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET), `SET_AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(1));
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET), `SET_AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(0));
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS_DELAY(8'hFE,cs_activate_delay));
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_RD);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS_DELAY(8'hFF,cs_deactivate_delay));
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_SYNC | 2);

  // breakdown: cs_activate_delay*(1+`CLOCK_DIVIDER)*2, times 2 since it's before and after cs transition, and added 3 cycles (1 for each timer comparison, plus one for fetching next instruction)
  expected_cs_activate_time = 2+2*cs_activate_delay*(1+`CLOCK_DIVIDER)*2;
  expected_cs_deactivate_time = 2+2*cs_deactivate_delay*(1+`CLOCK_DIVIDER)*2;

  // Enqueue transfers to DUT
  for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
    temp_data = $urandom;
    spi_send(temp_data);
    offload_sdi_data_store_arr[i] = temp_data;
  end

  // Start the offload
  #100ns
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(1));
  `INFOV(("Offload started (with delay on CS change)."), 6);

  spi_wait_send();

  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(0));

  `INFOV(("Offload stopped (with delay on CS change)."), 6);

  #2000ns

  for (int i=0; i<=((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1); i=i+1) begin
    offload_captured_word_arr[i][`DATA_DLENGTH-1:0] = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(`DDR_BA + 4*i);
  end

  if (irq_pending == 'h0) begin
    `ERROR(("IRQ Test FAILED"));
  end else begin
    `INFO(("IRQ Test PASSED"));
  end

  if (offload_captured_word_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) - 1:0] !== offload_sdi_data_store_arr [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) - 1:0]) begin
    `ERROR(("CS Delay Test FAILED: bad data"));
  end
  repeat (`NUM_OF_TRANSFERS) begin
    cs_activate_time = cs_instr_time.pop_back();
    cs_deactivate_time = cs_instr_time.pop_back();
  end
  if ((cs_activate_time != expected_cs_activate_time)) begin
    `ERROR(("CS Delay Test FAILED: unexpected chip select activate instruction duration. Expected=%d, Got=%d",expected_cs_activate_time,cs_activate_time));
  end
  if (cs_deactivate_time != expected_cs_deactivate_time) begin
    `ERROR(("CS Delay Test FAILED: unexpected chip select deactivate instruction duration. Expected=%d, Got=%d",expected_cs_deactivate_time,cs_deactivate_time));
  end
  `INFO(("CS Delay Test PASSED"));
endtask

endprogram
