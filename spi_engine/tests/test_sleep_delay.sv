// ***************************************************************************
// ***************************************************************************
// Copyright 2023 (c) Analog Devices, Inc. All rights reserved.
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
`include "spi_engine.svh"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_pwm_gen_pkg::*;
import adi_regmap_spi_engine_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*

//---------------------------------------------------------------------------
// SPI Engine configuration parameters
//---------------------------------------------------------------------------
localparam PCORE_VERSION              = 32'h0001_0171;
localparam SAMPLE_PERIOD              = 500;
localparam ASYNC_SPI_CLK              = 1;
localparam DATA_WIDTH                 = 32;
localparam DATA_DLENGTH               = 18;
localparam ECHO_SCLK                  = 0;
localparam SDI_PHY_DELAY              = 18;
localparam SDI_DELAY                  = 0;
localparam NUM_OF_CS                  = 1;
localparam THREE_WIRE                 = 0;
localparam CPOL                       = 0;
localparam CPHA                       = 1;
localparam CLOCK_DIVIDER              = 2;
localparam NUM_OF_WORDS               = 1;
localparam NUM_OF_TRANSFERS           = 1;

//---------------------------------------------------------------------------
// SPI Engine instructions
//---------------------------------------------------------------------------

// Chip select instructions
localparam INST_CS_OFF                = 32'h0000_10FF;
localparam INST_CS_ON                 = 32'h0000_10FE;
localparam INST_CS_OFF_DELAY          = 32'h0000_13FF;
localparam INST_CS_ON_DELAY           = 32'h0000_13FE;

// Transfer instructions
localparam INST_WR                    = 32'h0000_0100 | (NUM_OF_WORDS-1);
localparam INST_RD                    = 32'h0000_0200 | (NUM_OF_WORDS-1);
localparam INST_WRD                   = 32'h0000_0300 | (NUM_OF_WORDS-1);

// Configuration register instructions
localparam INST_CFG                   = 32'h0000_2100 | (THREE_WIRE << 2) | (CPOL << 1) | CPHA;
localparam INST_PRESCALE              = 32'h0000_2000 | CLOCK_DIVIDER;
localparam INST_DLENGTH               = 32'h0000_2200 | DATA_DLENGTH;

// Synchronization
localparam INST_SYNC                  = 32'h0000_3000;

// Sleep instruction
localparam INST_SLEEP                 = 32'h0000_3100;
`define sleep(a)                      (INST_SLEEP | (a & 8'hFF))

program test_sleep_delay (
  input spi_engine_irq,
  input spi_engine_spi_sclk,
  input spi_engine_spi_cs,
  input spi_engine_spi_clk,
  `ifdef DEF_ECHO_SCLK
  input spi_engine_echo_sclk,
  `endif
  input [(`NUM_OF_SDI - 1):0] spi_engine_spi_sdi);

test_harness_env env;

// --------------------------
// Wrapper function for AXI read verify
// --------------------------
task axi_read_v(
    input   [31:0]  raddr,
    input   [31:0]  vdata);
begin
  env.mng.RegReadVerify32(raddr,vdata);
end
endtask

task axi_read(
    input   [31:0]  raddr,
    output  [31:0]  data);
begin
  env.mng.RegRead32(raddr,data);
end
endtask

// --------------------------
// Wrapper function for AXI write
// --------------------------
task axi_write;
  input [31:0]  waddr;
  input [31:0]  wdata;
begin
  env.mng.RegWrite32(waddr,wdata);
end
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
            `TH.`DDR_AXI.inst.IF);

  setLoggerVerbosity(6);
  env.start();

  //asserts all the resets for 100 ns
  `TH.`SYS_RST.inst.IF.assert_reset;
  #100
  `TH.`SYS_RST.inst.IF.deassert_reset;
  #100

  sanity_test;

  #100

  sleep_delay_test(7);

  cs_delay_test(3,3);

  `INFO(("Test Done"));

  $finish;

end

//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test;
begin
  #100 axi_read_v (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_VERSION), PCORE_VERSION);
  #100 axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  #100 axi_read_v (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  `INFO(("Sanity Test Done"));
end
endtask

//---------------------------------------------------------------------------
// IRQ callback
//---------------------------------------------------------------------------

reg [4:0] irq_pending = 0;
reg [7:0] sync_id = 0;

initial begin
  while (1) begin
    @(posedge spi_engine_irq); // TODO: Make sure irq resets even the source remain active after clearing the IRQ register
    // read pending IRQs
    axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
    // IRQ launched by Offload SYNC command
    if (irq_pending & 5'b10000) begin
      axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
      $display("[%t] NOTE: Offload SYNC %d IRQ. An offload transfer just finished.", $time, sync_id);
    end
    // IRQ launched by SYNC command
    if (irq_pending & 5'b01000) begin
      axi_read (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
      $display("[%t] NOTE: SYNC %d IRQ. FIFO transfer just finished.", $time, sync_id);
    end
    // IRQ launched by SDI FIFO
    if (irq_pending & 5'b00100) begin
      $display("[%t] NOTE: SDI FIFO IRQ.", $time);
    end
    // IRQ launched by SDO FIFO
    if (irq_pending & 5'b00010) begin
      $display("[%t] NOTE: SDO FIFO IRQ.", $time);
    end
    // IRQ launched by SDO FIFO
    if (irq_pending & 5'b00001) begin
      $display("[%t] NOTE: CMD FIFO IRQ.", $time);
    end
    // Clear all pending IRQs
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
  end
end

//---------------------------------------------------------------------------
// Echo SCLK generation - we need this only if ECHO_SCLK is enabled
//---------------------------------------------------------------------------

  reg     [SDI_PHY_DELAY:0] echo_delay_sclk = {SDI_PHY_DELAY{1'b0}};
  reg     delay_clk = 0;
  wire    m_spi_sclk;

  assign  m_spi_sclk = spi_engine_spi_sclk;

  // Add an arbitrary delay to the echo_sclk signal
  initial begin
    while(1) begin
      @(posedge delay_clk) begin
        echo_delay_sclk <= {echo_delay_sclk, m_spi_sclk};
       end
    end
  end
  assign spi_engine_echo_sclk = echo_delay_sclk[SDI_PHY_DELAY-1];

initial begin
  while(1) begin
    #0.5   delay_clk = ~delay_clk;
  end
end

//---------------------------------------------------------------------------
// SDI data generator
//---------------------------------------------------------------------------

wire          end_of_word;
wire          spi_sclk_bfm = spi_engine_echo_sclk;
wire          m_spi_csn_negedge_s;
wire          m_spi_csn_int_s = &spi_engine_spi_cs;
bit           m_spi_csn_int_d = 0;
bit   [31:0]  sdi_shiftreg;
bit   [7:0]   spi_sclk_pos_counter = 0;
bit   [7:0]   spi_sclk_neg_counter = 0;
bit   [31:0]  sdi_preg[$];
bit   [31:0]  sdi_nreg[$];

initial begin
  while(1) begin
    @(posedge spi_engine_spi_clk);
      m_spi_csn_int_d <= m_spi_csn_int_s;
  end
end

assign m_spi_csn_negedge_s = ~m_spi_csn_int_s & m_spi_csn_int_d;

genvar i;
for (i = 0; i < `NUM_OF_SDI; i++) begin
  assign spi_engine_spi_sdi[i] = sdi_shiftreg[DATA_DLENGTH-1]; // all SDI lanes got the same data
end

assign end_of_word = (CPOL ^ CPHA) ?
                     (spi_sclk_pos_counter == DATA_DLENGTH) :
                     (spi_sclk_neg_counter == DATA_DLENGTH);

initial begin
  while(1) begin
    @(posedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);
    if (m_spi_csn_negedge_s) begin
      spi_sclk_pos_counter <= 8'b0;
    end else begin
      spi_sclk_pos_counter <= (spi_sclk_pos_counter == DATA_DLENGTH) ? 0 : spi_sclk_pos_counter+1;
    end
  end
end

initial begin
  while(1) begin
    @(negedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);
    if (m_spi_csn_negedge_s) begin
      spi_sclk_neg_counter <= 8'b0;
    end else begin
      spi_sclk_neg_counter <= (spi_sclk_neg_counter == DATA_DLENGTH) ? 0 : spi_sclk_neg_counter+1;
    end
  end
end

// SDI shift register
initial begin
  while(1) begin
    // synchronization
    if (CPHA ^ CPOL)
      @(posedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);
    else
      @(negedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);
    if ((m_spi_csn_negedge_s) || (end_of_word)) begin
      // delete the last word at end_of_word
      if (end_of_word) begin
        sdi_preg.pop_back();
        sdi_nreg.pop_back();
      end
      if (m_spi_csn_negedge_s) begin
        // NOTE: assuming queue is empty
        repeat (NUM_OF_WORDS) begin
          sdi_preg.push_front($urandom);
          sdi_nreg.push_front($urandom);
        end
        #1; // prevent race condition
        sdi_shiftreg <= (CPOL ^ CPHA) ?
                        sdi_preg[$] :
                        sdi_nreg[$];
      end else begin
        sdi_shiftreg <= (CPOL ^ CPHA) ?
                        sdi_preg[$] :
                        sdi_nreg[$];
      end
      if (m_spi_csn_negedge_s) @(posedge spi_sclk_bfm); // NOTE: when PHA=1 first shift should be at the second positive edge
    end else begin /* if ((m_spi_csn_negedge_s) || (end_of_word)) */
      sdi_shiftreg <= {sdi_shiftreg[DATA_DLENGTH-2:0], 1'b0};
    end
  end
end

//---------------------------------------------------------------------------
// Storing SDI Data for later comparison
//---------------------------------------------------------------------------

bit         offload_status = 0;
bit         shiftreg_sampled = 0;
bit [15:0]  sdi_store_cnt = 'h0;
bit [31:0]  offload_sdi_data_store_arr [(NUM_OF_TRANSFERS) - 1:0];
bit [31:0]  sdi_fifo_data_store;
bit [DATA_DLENGTH-1:0]  sdi_data_store;

initial begin
  while(1) begin
    @(posedge spi_engine_echo_sclk);
    sdi_data_store <= {sdi_shiftreg[27:0], 4'b0};
    if (sdi_data_store == 'h0 && shiftreg_sampled == 'h1 && sdi_shiftreg != 'h0) begin
      shiftreg_sampled <= 'h0;
      if (offload_status) begin
        sdi_store_cnt <= sdi_store_cnt + 1;
      end
    end else if (shiftreg_sampled == 'h0 && sdi_data_store != 'h0) begin
      if (offload_status) begin
        offload_sdi_data_store_arr [sdi_store_cnt] = sdi_shiftreg;
      end else begin
        sdi_fifo_data_store = sdi_shiftreg;
      end
      shiftreg_sampled <= 'h1;
    end
  end
end

//---------------------------------------------------------------------------
// Offload Transfer Counter
//---------------------------------------------------------------------------

bit [31:0] offload_transfer_cnt;

initial begin
  while(1) begin
    @(posedge shiftreg_sampled && offload_status);
      offload_transfer_cnt <= offload_transfer_cnt + 'h1;
  end
end

//---------------------------------------------------------------------------
// Sleep and Chip Select Instruction time counter
//---------------------------------------------------------------------------

bit [31:0] sleep_instr_time[$];
bit [31:0] sleep_current_duration;
bit [31:0] cs_instr_time[$];
bit [31:0] cs_current_duration;
wire [15:0] cmd, cmd_d1;
wire cmd_valid, cmd_ready;
wire idle;

assign cmd          = test_harness.spi_engine.spi_engine_execution.inst.cmd;
assign cmd_d1       = test_harness.spi_engine.spi_engine_execution.inst.cmd_d1;
assign cmd_valid    = test_harness.spi_engine.spi_engine_execution.inst.cmd_valid;
assign cmd_ready    = test_harness.spi_engine.spi_engine_execution.inst.cmd_ready;
assign idle         = test_harness.spi_engine.spi_engine_execution.inst.idle;

initial begin
  sleep_current_duration = 0;
  while(1) begin
    @(posedge spi_engine_spi_clk);
      if (idle && (cmd_d1[15:8] == 8'h31)) begin
        sleep_instr_time.push_front(sleep_current_duration+1); // add one to account for this cycle
      end
      if (cmd_valid && cmd_ready && (cmd[15:8] == 8'h31)) begin
        sleep_current_duration = 0;
      end else begin
        sleep_current_duration = sleep_current_duration+1;
      end
      if (idle && (cmd_d1[15:10] == 6'h4)) begin
        cs_instr_time.push_front(cs_current_duration+1); // add one to account for this cycle
      end
      if (cmd_valid && cmd_ready && (cmd[15:10] == 6'h4)) begin
        cs_current_duration = 0;
      end else begin
        cs_current_duration = cs_current_duration+1;
      end
  end
end

//---------------------------------------------------------------------------
// Sleep delay Test
//---------------------------------------------------------------------------

bit [31:0] offload_captured_word_arr [(NUM_OF_TRANSFERS) -1 :0];
bit [31:0] sleep_time;
bit [31:0] expected_sleep_time;

task sleep_delay_test;
  input [7:0] sleep_param;
begin

  // Start spi clk generator
  axi_write (`SPI_ENGINE_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
    `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
    `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
    );

  // Config cnv
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(REG_RSTN), `SET_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(REG_PULSE_0_PERIOD), `SET_REG_PULSE_0_PERIOD_PULSE_0_PERIOD('d1000)); // set PWM period
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(REG_RSTN), `SET_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
  $display("[%t] axi_pwm_gen started.", $time);

  // Enable SPI Engine
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));

  // Set up the interrupts
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_MASK),
    `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(1) |
    `SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(1)
    );

  // Write commnads stack
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_CFG);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_PRESCALE);
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_DLENGTH);

  expected_sleep_time = 2+(sleep_param)*((CLOCK_DIVIDER+1)*2);
  // Start the test
  #100
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (`sleep(sleep_param)));

  #2000
  sleep_time = sleep_instr_time.pop_back();
  if ((sleep_time != expected_sleep_time)) begin
      `ERROR(("Sleep Test FAILED: unexpected sleep instruction duration. Expected=%d, Got=%d",expected_sleep_time,sleep_time));
  end else begin
      `INFO(("Sleep Test PASSED"));
  end
  // Disable SPI Engine
  axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), 1);
end
endtask

//---------------------------------------------------------------------------
// CS delay Test
//---------------------------------------------------------------------------

bit [31:0] offload_captured_word_arr [(NUM_OF_TRANSFERS) -1 :0];
bit [31:0] cs_activate_time;
bit [31:0] expected_cs_activate_time;
bit [31:0] cs_deactivate_time;
bit [31:0] expected_cs_deactivate_time;

task cs_delay_test;
  input [1:0] cs_activate_delay;
  input [1:0] cs_deactivate_delay;
begin

    // Start spi clk generator
    axi_write (`SPI_ENGINE_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
      `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
      `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
      );

    // Config cnv
    axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(REG_RSTN), `SET_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
    axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(REG_PULSE_0_PERIOD), `SET_REG_PULSE_0_PERIOD_PULSE_0_PERIOD('d1000)); // set PWM period
    axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(REG_RSTN), `SET_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
    $display("[%t] axi_pwm_gen started.", $time);

    //Configure DMA
    env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_FLAGS),
      `SET_DMAC_FLAGS_TLAST(1) |
      `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
      ); // Use TLAST
    env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH((NUM_OF_TRANSFERS*4)-1)); // X_LENGHTH = 1024-1
    env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_DEST_ADDRESS), `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA));  // DEST_ADDRESS
    env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer DMA

    // Enable SPI Engine
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + `SPI_ENG_ADDR_ENABLE, 0);

    // Set up the interrupts
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + `SPI_ENG_ADDR_IRQMASK, 32'h00018);

    // Configure the Offload module
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET), `SET_AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(1));
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET), `SET_AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET_OFFLOAD0_MEM_RESET(0));
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CFG);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_PRESCALE);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_DLENGTH);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CS_ON);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_RD);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CS_OFF);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_SYNC | 1);

    offload_transfer_cnt = 0;
    offload_status = 1;
    expected_cs_activate_time = 2;
    expected_cs_deactivate_time = 2;

    // Start the offload
    #100
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(1));
    $display("[%t] Offload started (no delay on CS change).", $time);

    wait(offload_transfer_cnt == NUM_OF_TRANSFERS);

    offload_status = 0;
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(0));


    $display("[%t] Offload stopped (no delay on CS change).", $time);

    #2000

    for (int i=0; i<=((NUM_OF_TRANSFERS) -1); i=i+1) begin
      #1
      offload_captured_word_arr[i] = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(`DDR_BA + 4*i);
    end

    if (irq_pending == 'h0) begin
      `ERROR(("IRQ Test FAILED"));
    end else begin
      `INFO(("IRQ Test PASSED"));
    end

    if (offload_captured_word_arr [(NUM_OF_TRANSFERS) - 1:2] != offload_sdi_data_store_arr [(NUM_OF_TRANSFERS) - 1:2]) begin
      `ERROR(("CS Delay Test FAILED: bad data"));
    end

    cs_activate_time = cs_instr_time.pop_back();
    cs_deactivate_time = cs_instr_time.pop_back();
    if ((cs_activate_time != expected_cs_activate_time)) begin
      `ERROR(("CS Delay Test FAILED: unexpected chip select activate instruction duration. Expected=%d, Got=%d",expected_cs_activate_time,cs_activate_time));
    end
    if (cs_deactivate_time != expected_cs_deactivate_time) begin
      `ERROR(("CS Delay Test FAILED: unexpected chip select deactivate instruction duration. Expected=%d, Got=%d",expected_cs_deactivate_time,cs_deactivate_time));
    end
    `INFO(("CS Delay Test PASSED"));

    #2000
    env.mng.RegWrite32(`SPI_ENGINE_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer DMA

    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + `SPI_ENG_ADDR_OFFLOAD_RESET, 1);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + `SPI_ENG_ADDR_OFFLOAD_RESET, 0);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CS_ON | ((cs_activate_delay & 2'b11) << 8));
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_RD);
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CS_OFF | ((cs_deactivate_delay & 2'b11) << 8));
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_SYNC | 2);

    offload_transfer_cnt = 0;
    sdi_store_cnt = 0;
    offload_status = 1;

    // breakdown: cs_activate_delay*(1+CLOCK_DIVIDER)*2, times 2 since it's before and after cs transition, and added 3 cycles (1 for each timer comparison, plus one for fetching next instruction)
    expected_cs_activate_time = 2+2*cs_activate_delay*(1+CLOCK_DIVIDER)*2;
    expected_cs_deactivate_time = 2+2*cs_deactivate_delay*(1+CLOCK_DIVIDER)*2;

    // Start the offload
    #100
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + `SPI_ENG_ADDR_OFFLOAD_EN, 1);
    $display("[%t] Offload started (with delay on CS change).", $time);

    wait(offload_transfer_cnt == NUM_OF_TRANSFERS);

    offload_status = 0;
    axi_write (`SPI_ENGINE_SPI_REGMAP_BA + `SPI_ENG_ADDR_OFFLOAD_EN, 0);

    $display("[%t] Offload stopped (with delay on CS change).", $time);

    #2000

    for (int i=0; i<=((NUM_OF_TRANSFERS) -1); i=i+1) begin
      #1
      offload_captured_word_arr[i] = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(`DDR_BA + 4*i);
    end

    if (irq_pending == 'h0) begin
      `ERROR(("IRQ Test FAILED"));
    end else begin
      `INFO(("IRQ Test PASSED"));
    end

    if (offload_captured_word_arr [(NUM_OF_TRANSFERS) - 1:2] != offload_sdi_data_store_arr [(NUM_OF_TRANSFERS) - 1:2]) begin
      `ERROR(("CS Delay Test FAILED: bad data"));
    end
    cs_activate_time = cs_instr_time.pop_back();
    cs_deactivate_time = cs_instr_time.pop_back();
    if ((cs_activate_time != expected_cs_activate_time)) begin
      `ERROR(("CS Delay Test FAILED: unexpected chip select activate instruction duration. Expected=%d, Got=%d",expected_cs_activate_time,cs_activate_time));
    end
    if (cs_deactivate_time != expected_cs_deactivate_time) begin
      `ERROR(("CS Delay Test FAILED: unexpected chip select deactivate instruction duration. Expected=%d, Got=%d",expected_cs_deactivate_time,cs_deactivate_time));
    end
    `INFO(("CS Delay Test PASSED"));

  end
endtask
endprogram
