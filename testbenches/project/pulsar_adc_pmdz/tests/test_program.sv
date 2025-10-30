// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2021-2023 Analog Devices, Inc. All rights reserved.
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
//
//

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
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

//---------------------------------------------------------------------------
// SPI Engine configuration parameters
//---------------------------------------------------------------------------
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
localparam CLOCK_DIVIDER              = 0;
localparam NUM_OF_WORDS               = 1;
localparam NUM_OF_TRANSFERS           = 8;

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
`define sleep(a)                      = INST_SLEEP | (a & 8'hFF);

program test_program (
  input pulsar_adc_irq,
  input pulsar_adc_spi_sclk,
  input pulsar_adc_spi_cs,
  input pulsar_adc_spi_clk,
  input [(`NUM_OF_SDI - 1):0] pulsar_adc_spi_sdi);

  timeunit 1ns;
  timeprecision 1ps;

test_harness_env base_env;

adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

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
// Main procedure
// --------------------------
initial begin

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

  setLoggerVerbosity(ADI_VERBOSITY_NONE);

  base_env.start();
  base_env.sys_reset();

  sanity_test();

  #100ns;

  fifo_spi_test();

  #100ns;

  offload_spi_test();

  base_env.stop();

  `INFO(("Test Done"), ADI_VERBOSITY_NONE);
  $finish();

end

//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test;
  bit [31:0] pcore_version = (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_PATCH)
                            | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MINOR)<<8
                            | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MAJOR)<<16;
  axi_read_v (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_VERSION), pcore_version);
  axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  axi_read_v (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
endtask

//---------------------------------------------------------------------------
// SPI Engine generate transfer
//---------------------------------------------------------------------------

task generate_transfer_cmd(
  input [7:0] sync_id);

    // assert CSN
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_CS_ON);
    // transfer data
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_WRD);
    // de-assert CSN
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_CS_OFF);
    // SYNC command to generate interrupt
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (INST_SYNC | sync_id));
    `INFO(("Transfer generation finished"), ADI_VERBOSITY_LOW);
endtask

//---------------------------------------------------------------------------
// IRQ callback
//---------------------------------------------------------------------------

reg [4:0] irq_pending = 0;
reg [7:0] sync_id = 0;

initial begin
  while (1) begin
    @(posedge pulsar_adc_irq); // TODO: Make sure irq resets even the source remain active after clearing the IRQ register
    // read pending IRQs
    axi_read (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
    // IRQ launched by Offload SYNC command
    if (irq_pending & 5'b10000) begin
      axi_read (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
      `INFO(("Offload SYNC %d IRQ. An offload transfer just finished", sync_id), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SYNC command
    if (irq_pending & 5'b01000) begin
      axi_read (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
      `INFO(("SYNC %d IRQ. FIFO transfer just finished", sync_id), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SDI FIFO
    if (irq_pending & 5'b00100) begin
      `INFO(("SDI FIFO IRQ"), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SDO FIFO
    if (irq_pending & 5'b00010) begin
      `INFO(("SDO FIFO IRQ"), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SDO FIFO
    if (irq_pending & 5'b00001) begin
      `INFO(("CMD FIFO IRQ"), ADI_VERBOSITY_LOW);
    end
    // Clear all pending IRQs
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
  end
end

//---------------------------------------------------------------------------
// Echo SCLK generation - we need this only if ECHO_SCLK is enabled
//---------------------------------------------------------------------------

  reg     [SDI_PHY_DELAY:0] echo_delay_sclk = {SDI_PHY_DELAY{1'b0}};
  reg     delay_clk = 0;
  wire    m_spi_sclk;

  assign  m_spi_sclk = pulsar_adc_spi_sclk;

  // Add an arbitrary delay to the echo_sclk signal
  initial begin
    forever begin
      @(posedge delay_clk) begin
        echo_delay_sclk <= {echo_delay_sclk, m_spi_sclk};
       end
    end
  end
  assign pulsar_adc_echo_sclk = echo_delay_sclk[SDI_PHY_DELAY-1];

initial begin
  forever begin
    #0.5ns   delay_clk = ~delay_clk;
  end
end

//---------------------------------------------------------------------------
// SDI data generator
//---------------------------------------------------------------------------

wire          end_of_word;
wire          spi_sclk_bfm = pulsar_adc_echo_sclk;
wire          m_spi_csn_negedge_s;
wire          m_spi_csn_int_s = &pulsar_adc_spi_cs;
bit           m_spi_csn_int_d = 0;
bit   [31:0]  sdi_shiftreg;
bit   [7:0]   spi_sclk_pos_counter = 0;
bit   [7:0]   spi_sclk_neg_counter = 0;
bit   [31:0]  sdi_preg[$];
bit   [31:0]  sdi_nreg[$];

initial begin
  forever begin
    @(posedge pulsar_adc_spi_clk);
      m_spi_csn_int_d <= m_spi_csn_int_s;
  end
end

assign m_spi_csn_negedge_s = ~m_spi_csn_int_s & m_spi_csn_int_d;

genvar i;
for (i = 0; i < `NUM_OF_SDI; i++) begin
  assign pulsar_adc_spi_sdi[i] = sdi_shiftreg[DATA_DLENGTH-1]; // all SDI lanes got the same data
end

assign end_of_word = (CPOL ^ CPHA) ?
                     (spi_sclk_pos_counter == DATA_DLENGTH) :
                     (spi_sclk_neg_counter == DATA_DLENGTH);

initial begin
  forever begin
    @(posedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);
    if (m_spi_csn_negedge_s) begin
      spi_sclk_pos_counter <= 8'b0;
    end else begin
      spi_sclk_pos_counter <= (spi_sclk_pos_counter == DATA_DLENGTH) ? 0 : spi_sclk_pos_counter+1;
    end
  end
end

initial begin
  forever begin
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
  forever begin
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
        #1step; // prevent race condition
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
  forever begin
    @(posedge pulsar_adc_echo_sclk);
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
  forever begin
    @(posedge shiftreg_sampled && offload_status);
      offload_transfer_cnt <= offload_transfer_cnt + 'h1;
  end
end

//---------------------------------------------------------------------------
// Offload SPI Test
//---------------------------------------------------------------------------

bit [31:0] offload_captured_word_arr [(NUM_OF_TRANSFERS) -1 :0];

task offload_spi_test();
    //Configure DMA
    base_env.mng.master_sequencer.RegWrite32(`PULSAR_ADC_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    base_env.mng.master_sequencer.RegWrite32(`PULSAR_ADC_DMA_BA + GetAddrs(DMAC_FLAGS),
      `SET_DMAC_FLAGS_TLAST(1) |
      `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
      ); // Use TLAST
    base_env.mng.master_sequencer.RegWrite32(`PULSAR_ADC_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH((NUM_OF_TRANSFERS*4)-1)); // X_LENGHTH = 1024-1
    base_env.mng.master_sequencer.RegWrite32(`PULSAR_ADC_DMA_BA + GetAddrs(DMAC_DEST_ADDRESS), `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA));  // DEST_ADDRESS
    base_env.mng.master_sequencer.RegWrite32(`PULSAR_ADC_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer DMA

    // Configure the Offload module
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CFG);
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_PRESCALE);
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_DLENGTH);
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CS_ON);
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_RD);
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CS_OFF);
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_SYNC | 2);

    offload_status = 1;

    // Start the offload
    #100ns;
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(1));
    `INFO(("Offload started"), ADI_VERBOSITY_LOW);

    wait(offload_transfer_cnt == NUM_OF_TRANSFERS);

    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(0));
    offload_status = 0;

    `INFO(("Offload stopped"), ADI_VERBOSITY_LOW);

    #2000ns;

    for (int i=0; i<=((NUM_OF_TRANSFERS) -1); i=i+1) begin
      offload_captured_word_arr[i] = base_env.ddr.slave_sequencer.BackdoorRead32(xil_axi_uint'(`DDR_BA + 4*i));
    end

    if (irq_pending == 'h0) begin
      `FATAL(("IRQ Test FAILED"));
    end else begin
      `INFO(("IRQ Test PASSED"), ADI_VERBOSITY_LOW);
    end

    if (offload_captured_word_arr [(NUM_OF_TRANSFERS) - 1:2] != offload_sdi_data_store_arr [(NUM_OF_TRANSFERS) - 1:2]) begin
      `ERROR(("Offload Test FAILED"));
    end else begin
      `INFO(("Offload Test PASSED"), ADI_VERBOSITY_LOW);
    end
endtask

//---------------------------------------------------------------------------
// FIFO SPI Test
//---------------------------------------------------------------------------

bit   [31:0]  sdi_fifo_data = 0;

task fifo_spi_test();
  // Start spi clk generator
  axi_write (`PULSAR_ADC_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
    `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
    `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
    );

  // Config cnv
  axi_write (`PULSAR_ADC_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
  axi_write (`PULSAR_ADC_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('d121)); // set PWM period
  axi_write (`PULSAR_ADC_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
  `INFO(("Axi_pwm_gen started"), ADI_VERBOSITY_LOW);

  // Enable SPI Engine
  axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));

  // Configure the execution module
  axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_CFG);
  axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_PRESCALE);
  axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_DLENGTH);

  // Set up the interrupts
  axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_MASK),
    `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(1) |
    `SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(1)
    );

  #100ns;
  // Generate a FIFO transaction, write SDO first
  repeat (NUM_OF_WORDS) begin
    axi_write (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDO_FIFO), (16'hDEAD << (DATA_WIDTH - DATA_DLENGTH)));
  end

  generate_transfer_cmd(1);

  #100ns;
  wait(sync_id == 1);
  #100ns;

  repeat (NUM_OF_WORDS) begin
    axi_read (`PULSAR_ADC_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDI_FIFO_PEEK), sdi_fifo_data);
  end

  `INFO(("sdi_fifo_data: %x; sdi_fifo_data_store %x", sdi_fifo_data, sdi_fifo_data_store), ADI_VERBOSITY_LOW);

  if (sdi_fifo_data != sdi_fifo_data_store) begin
    `ERROR(("Fifo Read Test FAILED"));
  end else begin
    `INFO(("Fifo Read Test PASSED"), ADI_VERBOSITY_LOW);
  end
endtask

endprogram
