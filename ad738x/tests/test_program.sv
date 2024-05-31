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
//
//

`include "utils.svh"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_pwm_gen_pkg::*;
import adi_regmap_spi_engine_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;

//---------------------------------------------------------------------------
// SPI Engine configuration parameters
//---------------------------------------------------------------------------
localparam PCORE_VERSION              = 32'h0001_0200;
localparam SAMPLE_PERIOD              = 500;
localparam ASYNC_SPI_CLK              = 1;
localparam DATA_WIDTH                 = 16;
localparam DATA_DLENGTH               = 16;
localparam ECHO_SCLK                  = 0;
localparam SDI_PHY_DELAY              = 18;
localparam SDI_DELAY                  = 0;
localparam NUM_OF_CS                  = 1;
localparam THREE_WIRE                 = 0;
localparam CPOL                       = 0;
localparam CPHA                       = 1;
localparam CLOCK_DIVIDER              = 0;
localparam NUM_OF_WORDS               = 1;
localparam NUM_OF_TRANSFERS           = 10;

//---------------------------------------------------------------------------
// SPI Engine instructions
//---------------------------------------------------------------------------

// Chip select instructions
localparam INST_CS_OFF                = 32'h0000_10FF;
localparam INST_CS_ON                 = 32'h0000_10FE;

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
`define sleep(a)                     = INST_SLEEP | (a & 8'hFF);

program test_program (
  input       spi_clk,
  input       ad738x_irq,
  input       ad738x_spi_sclk,
  input [1:0] ad738x_spi_sdi,
  input       ad738x_spi_cs);


test_harness_env env;

// --------------------------
// Wrapper function for AXI read verif
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

  sanity_test();

  #100

  fifo_spi_test();

  #100

  offload_spi_test();

  `INFO(("Test Done"));

  $finish;

end

//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test();
  axi_read_v (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_VERSION), PCORE_VERSION);
  axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  axi_read_v (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  `INFO(("Sanity Test Done"));
endtask

//---------------------------------------------------------------------------
// SPI Engine generate transfer
//---------------------------------------------------------------------------

task generate_transfer_cmd(
   input [7:0] sync_id);

    // assert CSN
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_CS_ON);
    // transfer data
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_WRD);
    // de-assert CSN
    axi_write (`SPI_AD738x_REGMAP_BA+ GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_CS_OFF);
    // SYNC command to generate interrupt
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (INST_SYNC | sync_id));
    $display("[%t] NOTE: Transfer generation finished.", $time);
endtask

//---------------------------------------------------------------------------
// IRQ callback
//---------------------------------------------------------------------------

reg [4:0] irq_pending = 0;
reg [7:0] sync_id = 0;

initial begin
  while (1) begin
    @(posedge ad738x_irq);
    // read pending IRQs
    axi_read (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
    // IRQ launched by Offload SYNC command
    if (irq_pending & 5'b10000) begin
      axi_read (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
      $display("[%t] NOTE: Offload SYNC %d IRQ. An offload transfer just finished.", $time, sync_id);
    end
    // IRQ launched by SYNC command
    if (irq_pending & 5'b01000) begin
      axi_read (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
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
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
  end
end

//---------------------------------------------------------------------------
// Echo SCLK generation - we need this only if ECHO_SCLK is enabled
//---------------------------------------------------------------------------

  reg     [SDI_PHY_DELAY:0] echo_delay_sclk = {SDI_PHY_DELAY{1'b0}};
  reg     delay_clk = 0;
  wire    m_rx_sclk;

  assign  m_rx_sclk = ad738x_spi_sclk;

  // Add an arbitrary delay to the echo_sclk signal
  initial begin
    while(1) begin
      @(posedge delay_clk) begin
        echo_delay_sclk <= {echo_delay_sclk, m_rx_sclk};
       end
    end
  end
  assign ad738x_echo_sclk = echo_delay_sclk[SDI_PHY_DELAY-1];

initial begin
  while(1) begin
    #0.5   delay_clk = ~delay_clk;
  end
end

//---------------------------------------------------------------------------
// SDI data generator
//---------------------------------------------------------------------------

wire          end_of_word;
wire          rx_sclk_bfm = ad738x_echo_sclk;
wire          m_spi_csn_negedge_s;
wire          m_spi_csn_int_s = ad738x_spi_cs;
bit           m_spi_csn_int_d = 0;
bit   [15:0]  sdi_shiftreg;
wire  [15:0]  sdi_shiftreg2;
bit   [7:0]   rx_sclk_pos_counter = 0;
bit   [7:0]   rx_sclk_neg_counter = 0;
bit   [31:0]  sdi_preg[$];
bit   [31:0]  sdi_nreg[$];

initial begin
  while(1) begin
    @(posedge spi_clk);
      m_spi_csn_int_d <= m_spi_csn_int_s;
  end
end

assign m_spi_csn_negedge_s = ~m_spi_csn_int_s & m_spi_csn_int_d;

assign ad738x_spi_sdi[0] = sdi_shiftreg2[15];
assign ad738x_spi_sdi[1] = sdi_shiftreg[15];

assign end_of_word = (CPOL ^ CPHA) ?
                     (rx_sclk_pos_counter == 16) :
                     (rx_sclk_neg_counter == 16);

initial begin
  while(1) begin
    @(posedge rx_sclk_bfm or posedge m_spi_csn_negedge_s);
    if (m_spi_csn_negedge_s) begin
      rx_sclk_pos_counter <= 8'b0;
    end else begin
      rx_sclk_pos_counter <= (rx_sclk_pos_counter == DATA_DLENGTH*2) ? 0 : rx_sclk_pos_counter+1;
    end
  end
end

initial begin
  while(1) begin
    @(negedge rx_sclk_bfm or posedge m_spi_csn_negedge_s);
    if (m_spi_csn_negedge_s) begin
      rx_sclk_neg_counter <= 8'b0;
    end else begin
      rx_sclk_neg_counter <= (rx_sclk_neg_counter == DATA_DLENGTH*2) ? 0 : rx_sclk_neg_counter+1;
    end
  end
end

// SDI shift register
initial begin
  while(1) begin
    // synchronization
    if (CPHA ^ CPOL)
      @(posedge rx_sclk_bfm or posedge m_spi_csn_negedge_s);
    else
      @(negedge rx_sclk_bfm or posedge m_spi_csn_negedge_s);
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
      if (m_spi_csn_negedge_s) @(posedge rx_sclk_bfm); // NOTE: when PHA=1 first shift should be at the second positive edge
    end else begin /* if ((m_spi_csn_negedge_s) || (end_of_word)) */
      sdi_shiftreg <= {sdi_shiftreg[15:0], 1'b0};  //????????????? vezi pulsar
      //sdi_shiftreg2 <= {sdi_shiftreg2[15:0], 1'b0};
    end
  end
end

assign sdi_shiftreg2 = {sdi_shiftreg[14:0], 1'b0}; //????????? vezi pulsar

//---------------------------------------------------------------------------
// Storing SDI Data for later comparison
//---------------------------------------------------------------------------

bit         offload_status = 0;
bit         shiftreg_sampled = 0;
bit [15:0]  sdi_store_cnt = 'h0;
bit [31:0]  offload_sdi_data_store_arr [(NUM_OF_TRANSFERS) - 1:0];
bit [31:0]  sdi_fifo_data_store;
bit [31:0]  sdi_data_store;

initial begin
  while(1) begin
    @(posedge rx_sclk_bfm);
    sdi_data_store <= {sdi_shiftreg[13:0], 2'b00};
    if (sdi_data_store == 'h0 && shiftreg_sampled == 'h1 && sdi_shiftreg != 'h0) begin
      shiftreg_sampled <= 'h0;
      if (offload_status) begin
        sdi_store_cnt <= sdi_store_cnt + 1;
      end
    end else if (shiftreg_sampled == 'h0 && sdi_data_store != 'h0) begin
      if (offload_status) begin
          offload_sdi_data_store_arr [sdi_store_cnt] [15:0] = sdi_shiftreg2;
          offload_sdi_data_store_arr [sdi_store_cnt] [31:16] = sdi_shiftreg;
      end else begin
        sdi_fifo_data_store[31:16] = sdi_shiftreg;
        sdi_fifo_data_store[15:0] = sdi_shiftreg2;
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
// Offload SPI Test
//---------------------------------------------------------------------------

bit [31:0] offload_captured_word_arr [(NUM_OF_TRANSFERS) -1 :0];

task offload_spi_test();
    // Configure pwm
    axi_write (`AD738x_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
    axi_write (`AD738x_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('h64)); // set PWM period
    axi_write (`AD738x_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
    $display("[%t] axi_pwm_gen started.", $time);

    //Configure DMA
    env.mng.RegWrite32(`AD738x_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    env.mng.RegWrite32(`AD738x_DMA_BA + GetAddrs(DMAC_FLAGS),
      `SET_DMAC_FLAGS_TLAST(1) |
      `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
      ); // Use TLAST
    env.mng.RegWrite32(`AD738x_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH((NUM_OF_TRANSFERS*4)-1)); // X_LENGHTH = 1024-1
    env.mng.RegWrite32(`AD738x_DMA_BA + GetAddrs(DMAC_DEST_ADDRESS), `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA));  // DEST_ADDRESS
    env.mng.RegWrite32(`AD738x_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer DMA

    // Configure the Offload module
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CFG);
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_PRESCALE);
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_DLENGTH);
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CS_ON);
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_RD);
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CS_OFF);
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_SYNC | 2);
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO), 16'hBEAF << (DATA_WIDTH - DATA_DLENGTH));

    offload_status = 1;

    // Start the offload
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(1));
    $display("[%t] Offload started.", $time);

    wait(offload_transfer_cnt == NUM_OF_TRANSFERS);

    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(0));
    offload_status = 0;

    $display("[%t] Offload stopped.", $time);

    #2000

    for (int i=0; i<=((NUM_OF_TRANSFERS) -1); i=i+1) begin
      #1
      offload_captured_word_arr[i] = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(`DDR_BA + 4*i);
    end

    if (offload_captured_word_arr [(NUM_OF_TRANSFERS) - 1:2] != offload_sdi_data_store_arr [(NUM_OF_TRANSFERS) - 1:2]) begin
      `ERROR(("Offload Test FAILED"));
    end else begin
      `INFO(("Offload Test PASSED"));
    end
endtask

//---------------------------------------------------------------------------
// FIFO SPI Test
//---------------------------------------------------------------------------

bit   [31:0]  sdi_fifo_data = 0;

task fifo_spi_test();
  // Start spi clk generator
  axi_write (`AD738x_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
    `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
    `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
    );

  // Enable SPI Engine
  axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));

  // Configure the execution module
  axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_CFG);
  axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_PRESCALE);
  axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_DLENGTH);

  // Set up the interrupts
  axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_MASK),
    `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(1) |
    `SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(1)
    );

  #100
  // Generate a FIFO transaction, write SDO first
  repeat (NUM_OF_WORDS) begin
    axi_write (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDO_FIFO), (16'hDEAD << (DATA_WIDTH - DATA_DLENGTH)));
  end

  generate_transfer_cmd(1);

  #100
  wait(sync_id == 1);
  #100

  repeat (NUM_OF_WORDS) begin
    axi_read (`SPI_AD738x_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDI_FIFO_PEEK) , sdi_fifo_data);
  end

  if (sdi_fifo_data != sdi_fifo_data_store) begin
    $display("sdi_fifo_data: %x; sdi_fifo_data_store %x", sdi_fifo_data, sdi_fifo_data_store);
    `ERROR(("Fifo Read Test FAILED"));
  end else begin
    $display("sdi_fifo_data: %x; sdi_fifo_data_store %x", sdi_fifo_data, sdi_fifo_data_store);
    `INFO(("Fifo Read Test PASSED"));
  end
endtask

endprogram
