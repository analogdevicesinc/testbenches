// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import spi_engine_api_pkg::*;
import spi_engine_instr_pkg::*;
import dmac_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

//---------------------------------------------------------------------------
// SPI Engine configuration parameters
//---------------------------------------------------------------------------
localparam SAMPLE_PERIOD              = 500;
localparam ASYNC_SPI_CLK              = 1;
localparam ECHO_SCLK                  = 0;
localparam SDI_PHY_DELAY              = 18;
localparam SDI_DELAY                  = 0;
localparam NUM_OF_TRANSFERS           = 10;

// SPI Engine instructions are defined in spi_engine_instr_pkg

program test_program (
  input cn0363_spi_clk,
  input cn0363_irq,
  input cn0363_spi_sclk,
  input cn0363_spi_sdi,
  input [1:0] cn0363_spi_cs);

  timeunit 1ns;
  timeprecision 1ps;

test_harness_env base_env;

adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

// API instances
spi_engine_api spi_api;
dmac_api dma_api;

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

  mng = new(.name(""), .master_vip_if(`TH.`MNG_AXI.inst.IF));
  ddr = new(.name(""), .slave_vip_if(`TH.`DDR_AXI.inst.IF));

  `LINK(mng, base_env, mng)
  `LINK(ddr, base_env, ddr)

  // Initialize API instances
  spi_api = new(.name("SPI Engine API"),
                .bus(base_env.mng.master_sequencer),
                .base_address(`SPI_CN0363_REGMAP_BA));

  dma_api = new(.name("CN0363 DMA API"),
                .bus(base_env.mng.master_sequencer),
                .base_address(`CN0363_DMA_BA));

  setLoggerVerbosity(.value(ADI_VERBOSITY_NONE));

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

task sanity_test();
  spi_api.sanity_test();
  dma_api.sanity_test();
  `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
endtask

//---------------------------------------------------------------------------
// SPI Engine generate transfer
//---------------------------------------------------------------------------

task generate_transfer_cmd(
  input [7:0] sync_id);

  // assert CSN
  spi_api.fifo_command(.cmd(`SET_CS(8'hFE)));
  // transfer data
  spi_api.fifo_command(.cmd(`INST_WRD));
  // de-assert CSN
  spi_api.fifo_command(.cmd(`SET_CS(8'hFF)));
  // SYNC command to generate interrupt
  spi_api.fifo_command(.cmd((`INST_SYNC | sync_id)));
  `INFO(("Transfer generation finished"), ADI_VERBOSITY_LOW);
endtask

//---------------------------------------------------------------------------
// IRQ callback
//---------------------------------------------------------------------------

reg [4:0] irq_pending = 0;
reg [7:0] sync_id = 0;

initial begin
  forever begin
    @(posedge cn0363_irq);
    // read pending IRQs
    spi_api.get_irq_pending(.irq_pending(irq_pending));
    // IRQ launched by Offload SYNC command
    if (irq_pending & 5'b10000) begin
      spi_api.get_sync_id(.sync_id(sync_id));
      if (offload_status) begin
        offload_transfer_cnt <= offload_transfer_cnt + 1;
      end
      `INFO(("Offload SYNC %d IRQ. An offload transfer just finished (cnt=%0d)", sync_id, offload_transfer_cnt), ADI_VERBOSITY_LOW);
    end
    // IRQ launched by SYNC command
    if (irq_pending & 5'b01000) begin
      spi_api.get_sync_id(.sync_id(sync_id));
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
    // IRQ launched by CMD FIFO
    if (irq_pending & 5'b00001) begin
      `INFO(("CMD FIFO IRQ"), ADI_VERBOSITY_LOW);
    end
    // Clear all pending IRQs
    spi_api.clear_irq_pending(.irq_pending(irq_pending));
  end
end

//---------------------------------------------------------------------------
// Echo SCLK generation - we need this only if ECHO_SCLK is enabled
//---------------------------------------------------------------------------

reg     [SDI_PHY_DELAY:0] echo_delay_sclk = {SDI_PHY_DELAY{1'b0}};
reg     delay_clk = 0;
wire    m_spi_sclk;

assign  m_spi_sclk = cn0363_spi_sclk;

// Add an arbitrary delay to the echo_sclk signal
initial begin
  forever begin
    @(posedge delay_clk) begin
      echo_delay_sclk <= {echo_delay_sclk, m_spi_sclk};
    end
  end
end
assign cn0363_echo_sclk = echo_delay_sclk[SDI_PHY_DELAY-1];

initial begin
  forever begin
    #0.5ns   delay_clk = ~delay_clk;
  end
end

//---------------------------------------------------------------------------
// SDI data generator
//---------------------------------------------------------------------------

wire          end_of_word;
wire          spi_sclk_bfm = cn0363_echo_sclk;
wire          m_spi_csn_negedge_s;
wire          m_spi_csn_int_s = &cn0363_spi_cs;
bit           m_spi_csn_int_d = 0;
bit   [31:0]  sdi_shiftreg;
bit   [7:0]   spi_sclk_pos_counter = 0;
bit   [7:0]   spi_sclk_neg_counter = 0;
bit   [31:0]  sdi_preg[$];
bit   [31:0]  sdi_nreg[$];

initial begin
  forever begin
    @(posedge cn0363_spi_clk);
    m_spi_csn_int_d <= m_spi_csn_int_s;
  end
end

assign m_spi_csn_negedge_s = ~m_spi_csn_int_s & m_spi_csn_int_d;

assign cn0363_spi_sdi = sdi_shiftreg[31];

assign end_of_word = (`CPOL ^ `CPHA) ?
                     (spi_sclk_pos_counter == `DATA_DLENGTH) :
                     (spi_sclk_neg_counter == `DATA_DLENGTH);

initial begin
  forever begin
    @(posedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);
    if (m_spi_csn_negedge_s) begin
      spi_sclk_pos_counter <= 8'b0;
    end else begin
      spi_sclk_pos_counter <= (spi_sclk_pos_counter == `DATA_DLENGTH) ? 0 : spi_sclk_pos_counter+1;
    end
  end
end

initial begin
  forever begin
    @(negedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);
    if (m_spi_csn_negedge_s) begin
      spi_sclk_neg_counter <= 8'b0;
    end else begin
      spi_sclk_neg_counter <= (spi_sclk_neg_counter == `DATA_DLENGTH) ? 0 : spi_sclk_neg_counter+1;
    end
  end
end

// SDI shift register
initial begin
  forever begin
    // synchronization
    if (`CPHA ^ `CPOL) begin
      @(posedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);
    end else begin
      @(negedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);
    end
    if ((m_spi_csn_negedge_s) || (end_of_word)) begin
      // delete the last word at end_of_word
      if (end_of_word) begin
        sdi_preg.pop_back();
        sdi_nreg.pop_back();
      end
      if (m_spi_csn_negedge_s) begin
        // NOTE: assuming queue is empty
        repeat (`NUM_OF_WORDS) begin
          sdi_preg.push_front($urandom << (32 - `DATA_DLENGTH));
          sdi_nreg.push_front($urandom << (32 - `DATA_DLENGTH));
        end
        #1step; // prevent race condition
        sdi_shiftreg <= (`CPOL ^ `CPHA) ?
                        sdi_preg[$] :
                        sdi_nreg[$];
      end else begin
        sdi_shiftreg <= (`CPOL ^ `CPHA) ?
                        sdi_preg[$] :
                        sdi_nreg[$];
      end
      if (m_spi_csn_negedge_s) begin
        @(posedge spi_sclk_bfm); // NOTE: when PHA=1 first shift should be at the second positive edge
      end
    end else begin /* if ((m_spi_csn_negedge_s) || (end_of_word)) */
      sdi_shiftreg <= {sdi_shiftreg[30:0], 1'b0};
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
bit [31:0]  sdi_data_store;

// FIFO test: capture SDI data using shiftreg edge detection
initial begin
  forever begin
    @(posedge cn0363_echo_sclk);
    sdi_data_store <= {sdi_shiftreg[27:0], 4'b0};
    if (sdi_data_store == 'h0 && shiftreg_sampled == 'h1 && sdi_shiftreg != 'h0) begin
      shiftreg_sampled <= 'h0;
    end else if (shiftreg_sampled == 'h0 && sdi_data_store != 'h0) begin
      if (!offload_status) begin
        sdi_fifo_data_store = sdi_shiftreg >> (32 - `DATA_DLENGTH);
      end
      shiftreg_sampled <= 'h1;
    end
  end
end

// Offload test: capture SDI data on each CS falling edge
initial begin
  forever begin
    @(posedge m_spi_csn_negedge_s);
    if (offload_status && sdi_store_cnt < NUM_OF_TRANSFERS) begin
      @(posedge cn0363_spi_clk);
      offload_sdi_data_store_arr[sdi_store_cnt] = sdi_shiftreg >> (32 - `DATA_DLENGTH);
      sdi_store_cnt = sdi_store_cnt + 1;
    end
  end
end

//---------------------------------------------------------------------------
// Offload Transfer Counter
//---------------------------------------------------------------------------

bit [31:0] offload_transfer_cnt = 0;

//---------------------------------------------------------------------------
// Offload SDI capture - monitor SPI engine offload output
//---------------------------------------------------------------------------
// In CN0363, offload SDI data passes through a processing pipeline before
// reaching DDR, so we tap the offload module's SDI output directly to
// verify the SPI engine captured the correct data from the bus.

bit [31:0] offload_captured_word_arr [NUM_OF_TRANSFERS - 1:0];
bit [31:0] offload_sdi_capture_cnt = 0;

initial begin
  wait(offload_status == 1);
  forever begin
    @(posedge cn0363_spi_clk);
    if (!offload_status) break;
    if (`TH.spi_cn0363.spi_cn0363_offload.offload_sdi_valid &&
        `TH.spi_cn0363.spi_cn0363_offload.offload_sdi_ready) begin
      if (offload_sdi_capture_cnt < NUM_OF_TRANSFERS) begin
        offload_captured_word_arr[offload_sdi_capture_cnt] =
          `TH.spi_cn0363.spi_cn0363_offload.offload_sdi_data;
        offload_sdi_capture_cnt <= offload_sdi_capture_cnt + 1;
      end
    end
  end
end

//---------------------------------------------------------------------------
// Trigger simulation - simulate periodic ADC data_ready for offload
//---------------------------------------------------------------------------
// The util_sigma_delta_spi generates data_ready when CS is LOW for 63 clocks
// and MISO is LOW. In the offload flow, the offload module needs a rising edge
// on data_ready (trigger) to start each transfer cycle. But the first trigger
// can never come naturally because CS only goes LOW when the offload executes.
// This process forces periodic data_ready pulses to break the chicken-and-egg
// dependency and simulate the ADC signaling conversion-complete.

initial begin
  wait(offload_status == 1);
  forever begin
    @(posedge cn0363_spi_clk);
    if (!offload_status) break;
    // Force data_ready HIGH for 2 clock cycles to create a trigger_posedge
    force `TH.util_sigma_delta_spi.data_ready = 1'b1;
    @(posedge cn0363_spi_clk);
    @(posedge cn0363_spi_clk);
    release `TH.util_sigma_delta_spi.data_ready;
    // Wait for the offload transfer cycle to complete before next trigger
    #2000ns;
  end
end

//---------------------------------------------------------------------------
// Offload SPI Test
//---------------------------------------------------------------------------

task offload_spi_test();

    // Configure DMA
    dma_api.enable_dma();
    dma_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    dma_api.set_lengths(.xfer_length_x((NUM_OF_TRANSFERS*4*2)-1), .xfer_length_y(0));
    dma_api.set_dest_addr(.xfer_addr(xil_axi_uint'(`DDR_BA)));
    dma_api.transfer_start();

    // Configure the Offload module
    spi_api.fifo_offload_command(.cmd(`INST_CFG));
    spi_api.fifo_offload_command(.cmd(`INST_PRESCALE));
    spi_api.fifo_offload_command(.cmd(`INST_DLENGTH));
    spi_api.fifo_offload_command(.cmd(`SET_CS(8'hFE)));
    spi_api.fifo_offload_command(.cmd(`INST_RD));
    spi_api.fifo_offload_command(.cmd(`SET_CS(8'hFF)));
    spi_api.fifo_offload_command(.cmd(`INST_SYNC | 2));

    offload_status = 1;

    // Start the offload
    spi_api.start_offload();
    `INFO(("Offload started"), ADI_VERBOSITY_LOW);

    wait(offload_transfer_cnt >= NUM_OF_TRANSFERS);

    spi_api.stop_offload();
    offload_status = 0;

    `INFO(("Offload stopped"), ADI_VERBOSITY_LOW);

    #2000ns;

    if (irq_pending == 'h0) begin
      `FATAL(("IRQ Test FAILED"));
    end else begin
      `INFO(("IRQ Test PASSED"), ADI_VERBOSITY_LOW);
    end

    // Compare stored SDI data with data captured at the offload SDI
    // output (before the CN0363 processing pipeline).
    for (int i=0; i<NUM_OF_TRANSFERS; i++) begin
      `INFO(("offload[%0d]: captured=%x  stored=%x %s", i,
             offload_captured_word_arr[i], offload_sdi_data_store_arr[i],
             (offload_captured_word_arr[i] != offload_sdi_data_store_arr[i]) ? "MISMATCH" : "OK"), ADI_VERBOSITY_LOW);
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

  // Enable SPI Engine
  spi_api.enable_spi_engine();

  // Configure the execution module
  spi_api.fifo_command(.cmd(`INST_CFG));
  spi_api.fifo_command(.cmd(`INST_PRESCALE));
  spi_api.fifo_command(.cmd(`INST_DLENGTH));

  // Set up the interrupts
  spi_api.set_interrup_mask(
    .sync_event(1'b1),
    .offload_sync_id_pending(1'b1),
    .sdi_almost_full(1'b0),
    .sdo_almost_empty(1'b0),
    .cmd_almost_empty(1'b0));

  #100ns;
  // Generate a FIFO transaction, write SDO first
  repeat (`NUM_OF_WORDS) begin
    spi_api.sdo_fifo_write(.data((16'hDEAD << (`DATA_WIDTH - `DATA_DLENGTH))));
  end

  generate_transfer_cmd(.sync_id(1));

  #100ns;
  wait(sync_id == 1);
  #100ns;

  repeat (`NUM_OF_WORDS) begin
    spi_api.peek_sdi_fifo(.data(sdi_fifo_data));
  end

  `INFO(("sdi_fifo_data: %x; sdi_fifo_data_store %x", sdi_fifo_data, sdi_fifo_data_store), ADI_VERBOSITY_LOW);

  if (sdi_fifo_data != sdi_fifo_data_store) begin
    `ERROR(("Fifo Read Test FAILED"));
  end else begin
    `INFO(("Fifo Read Test PASSED"), ADI_VERBOSITY_LOW);
  end
endtask

endprogram
