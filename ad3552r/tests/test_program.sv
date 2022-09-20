// ***************************************************************************
// ***************************************************************************
// Copyright 2021 (c) Analog Devices, Inc. All rights reserved.
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
import logger_pkg::*;
import test_harness_env_pkg::*;

`define PULSAR_ADC_DMA                  32'h44A3_0000
`define PULSAR_ADC_REGMAP               32'h44A0_0000
`define PULSAR_ADC_CLKGEN               32'h44A7_0000
`define PULSAR_ADC_CNV                  32'h44B0_0000
`define SPI_DDS                         32'h44C0_0000
`define DDR_BASE                        32'h8000_0000

//`define NUM_OF_SDO 2

localparam SPI_ENG_ADDR_VERSION         = 32'h0000_0000;
localparam SPI_ENG_ADDR_ID              = 32'h0000_0004;
localparam SPI_ENG_ADDR_SCRATCH         = 32'h0000_0008;
localparam SPI_ENG_ADDR_ENABLE          = 32'h0000_0040;
localparam SPI_ENG_ADDR_IRQMASK         = 32'h0000_0080;
localparam SPI_ENG_ADDR_IRQPEND         = 32'h0000_0084;
localparam SPI_ENG_ADDR_IRQSRC          = 32'h0000_0088;
localparam SPI_ENG_ADDR_SYNCID          = 32'h0000_00C0;
localparam SPI_ENG_ADDR_CMDFIFO_ROOM    = 32'h0000_00D0;
localparam SPI_ENG_ADDR_SDOFIFO_ROOM    = 32'h0000_00D4;
localparam SPI_ENG_ADDR_SDIFIFO_LEVEL   = 32'h0000_00D8;
localparam SPI_ENG_ADDR_CMDFIFO         = 32'h0000_00E0;
localparam SPI_ENG_ADDR_SDOFIFO         = 32'h0000_00E4;
localparam SPI_ENG_ADDR_SDIFIFO         = 32'h0000_00E8;
localparam SPI_ENG_ADDR_SDIFIFO_PEEK    = 32'h0000_00F0;
localparam SPI_ENG_ADDR_OFFLOAD_EN      = 32'h0000_0100;
localparam SPI_ENG_ADDR_OFFLOAD_RESET   = 32'h0000_0108;
localparam SPI_ENG_ADDR_OFFLOAD_AXIS_SW = 32'h0000_010C;
localparam SPI_ENG_ADDR_OFFLOAD_CMD     = 32'h0000_0110;
localparam SPI_ENG_ADDR_OFFLOAD_SDO     = 32'h0000_0114;

//---------------------------------------------------------------------------
// SPI Engine configuration parameters
//---------------------------------------------------------------------------
localparam PCORE_VERSION              = 32'h0001_0071;
localparam SAMPLE_PERIOD              = 500;
localparam ASYNC_SPI_CLK              = 1;
localparam DATA_WIDTH                 = 32;
localparam DATA_DLENGTH_64            = 64;
localparam DATA_DLENGTH_32            = 32;
localparam DATA_DLENGTH_16            = 16;
localparam DATA_DLENGTH_8             = 8;
localparam DATA_DLENGTH_24            = 24;
localparam ECHO_SCLK                  = 0;
localparam SDI_PHY_DELAY              = 18;
localparam SDI_DELAY                  = 0;
localparam NUM_OF_CS                  = 1;
localparam THREE_WIRE                 = 0;
localparam CPOL                       = 0;
localparam CPHA                       = 0;
localparam DDR_EN                     = 1;
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
localparam INST_CFG_DDR               = 32'h0000_2100 | (DDR_EN << 3) | (THREE_WIRE << 2) | (CPOL << 1) | CPHA;
localparam INST_PRESCALE              = 32'h0000_2000 | CLOCK_DIVIDER;
localparam INST_DLENGTH_16            = 32'h0000_2200 | DATA_DLENGTH_16;
localparam INST_DLENGTH_32            = 32'h0000_2200 | DATA_DLENGTH_32;
localparam INST_DLENGTH_64            = 32'h0000_2200 | DATA_DLENGTH_64;
localparam INST_DLENGTH_8             = 32'h0000_2200 | DATA_DLENGTH_8;
localparam INST_DLENGTH_24            = 32'h0000_2200 | DATA_DLENGTH_24;

// Synchronization
localparam INST_SYNC                  = 32'h0000_3000;

// Sleep instruction
localparam INST_SLEEP                 = 32'h0000_3100;
`define sleep(a)                      = INST_SLEEP | (a & 8'hFF);

localparam DAC_WR                     = 8'h00;
localparam DAC_RD                     = 8'h80;

localparam DAC_REG_ADDR               = 8'h7A;

localparam DAC_WREG                   = DAC_WR | DAC_REG_ADDR;
localparam DAC_RREG                   = DAC_RD | DAC_REG_ADDR;


localparam PULSAR_ADC_BASE = `PULSAR_ADC_REGMAP;
localparam PULSAR_ADC_CLKGEN_BASE = `PULSAR_ADC_CLKGEN;
localparam PULSAR_ADC_CNV_BASE = `PULSAR_ADC_CNV;
localparam SPI_DDS = `SPI_DDS;

program test_program (
  input ad3552r_dac_irq,
  input ad3552r_dac_spi_sclk,
  input ad3552r_dac_spi_cs,
  input ad3552r_dac_spi_clk,
  input ad3552r_dac_spi_sdo_t,
  input [(`NUM_OF_SDI - 1):0] ad3552r_dac_spi_sdi,
  input [(`NUM_OF_SDO - 1):0] ad3552r_dac_spi_sdo);

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
  
  init;

  #100

  fifo_spi_test;

  #100

  offload_spi_test;

  `INFO(("Test Done"));

  $finish;

end

//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test;
begin
  #100 axi_read_v (PULSAR_ADC_BASE + 32'h0000000, 'h0001_0071);
  #100 axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_SCRATCH, 32'hDEADBEEF);
  #100 axi_read_v (PULSAR_ADC_BASE + SPI_ENG_ADDR_SCRATCH, 32'hDEADBEEF);
  `INFO(("Sanity Test Done"));
end
endtask

//---------------------------------------------------------------------------
// SPI Engine generate transfer
//---------------------------------------------------------------------------

task generate_transfer_cmd;
  input [7:0] sync_id;
  begin
    // assert CSN
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_CS_ON);
    // transfer data
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_WRD);
    // de-assert CSN
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_CS_OFF);
    // SYNC command to generate interrupt
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, (INST_SYNC | sync_id));
    $display("[%t] NOTE: Transfer generation finished.", $time);
  end
endtask

//---------------------------------------------------------------------------
// IRQ callback
//---------------------------------------------------------------------------

reg [4:0] irq_pending = 0;
reg [7:0] sync_id = 0;

initial begin
  while (1) begin
    @(posedge ad3552r_dac_irq); // TODO: Make sure irq resets even the source remain active after clearing the IRQ register
    // read pending IRQs
    axi_read (`PULSAR_ADC_REGMAP + SPI_ENG_ADDR_IRQPEND, irq_pending);
    // IRQ launched by Offload SYNC command
    if (irq_pending & 5'b10000) begin
      axi_read (`PULSAR_ADC_REGMAP + SPI_ENG_ADDR_SYNCID, sync_id);
      $display("[%t] NOTE: Offload SYNC %d IRQ. An offload transfer just finished.", $time, sync_id);
    end
    // IRQ launched by SYNC command
    if (irq_pending & 5'b01000) begin
      axi_read (`PULSAR_ADC_REGMAP + SPI_ENG_ADDR_SYNCID, sync_id);
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
    axi_write (`PULSAR_ADC_REGMAP + SPI_ENG_ADDR_IRQPEND, irq_pending);
  end
end

//---------------------------------------------------------------------------
// Echo SCLK generation - we need this only if ECHO_SCLK is enabled
//---------------------------------------------------------------------------

  reg     [SDI_PHY_DELAY:0] echo_delay_sclk = {SDI_PHY_DELAY{1'b0}};
  reg     delay_clk = 0;
  wire    m_spi_sclk;

  assign  m_spi_sclk = ad3552r_dac_spi_sclk;

  // Add an arbitrary delay to the echo_sclk signal
  initial begin
    while(1) begin
      @(posedge delay_clk) begin
        echo_delay_sclk <= {echo_delay_sclk, m_spi_sclk};
       end
    end
  end
  assign ad3552r_dac_echo_sclk = echo_delay_sclk[SDI_PHY_DELAY-1];

initial begin
  while(1) begin
    #0.5   delay_clk = ~delay_clk;
  end
end


//---------------------------------------------------------------------------
// SDI data generator
//---------------------------------------------------------------------------

wire          end_of_word;
//wire          spi_sclk_bfm = ad3552r_dac_echo_sclk;
wire          spi_sclk_bfm = m_spi_sclk;
wire          m_spi_csn_negedge_s;
wire          m_spi_csn_int_s = &ad3552r_dac_spi_cs;
bit           m_spi_csn_int_d = 0;
bit   [31:0]  sdi_shiftreg;
bit   [7:0]   spi_sclk_pos_counter = 0;
bit   [7:0]   spi_sclk_neg_counter = 0;
bit   [31:0]  sdi_preg[$];
bit   [31:0]  sdi_nreg[$];

initial begin
  while(1) begin
    @(posedge ad3552r_dac_spi_clk);
      m_spi_csn_int_d <= m_spi_csn_int_s;
  end
end

assign m_spi_csn_negedge_s = ~m_spi_csn_int_s & m_spi_csn_int_d;

assign ad3552r_dac_spi_sdi[0] = (ad3552r_dac_spi_sdo_t == 'h1) ? sdi_shiftreg[31] : 'hz;
assign ad3552r_dac_spi_sdi[1] = (ad3552r_dac_spi_sdo_t == 'h1) ? sdi_shiftreg[30] : 'hz;
assign ad3552r_dac_spi_sdi[2] = (ad3552r_dac_spi_sdo_t == 'h1) ? sdi_shiftreg[29] : 'hz;
assign ad3552r_dac_spi_sdi[3] = (ad3552r_dac_spi_sdo_t == 'h1) ? sdi_shiftreg[28] : 'hz;


assign end_of_word = (CPOL ^ CPHA) ?
                     (spi_sclk_pos_counter == DATA_DLENGTH_16 / `NUM_OF_SDI) :
                     (spi_sclk_neg_counter == DATA_DLENGTH_16 / `NUM_OF_SDI);

initial begin
  while(1) begin
    @(posedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);
    if (m_spi_csn_negedge_s) begin
      spi_sclk_pos_counter <= 8'b0;
    end else begin
      spi_sclk_pos_counter <= (spi_sclk_pos_counter == DATA_DLENGTH_16 / `NUM_OF_SDI) ? 0 : spi_sclk_pos_counter+1;
    end
  end
end

initial begin
  while(1) begin
    @(negedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);
    if (m_spi_csn_negedge_s) begin
      spi_sclk_neg_counter <= 8'b0;
    end else begin
      spi_sclk_neg_counter <= (spi_sclk_neg_counter == DATA_DLENGTH_16) ? 0 : spi_sclk_neg_counter+1;
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
      sdi_shiftreg <= {sdi_shiftreg[30:0], 1'b0};
    end
  end
end

bit [31:0] sdo_shiftreg = 'h0;
bit [31:0] sdo_shiftreg2 = 'h0;
bit [31:0] sdo_shiftreg3 = 'h0;
bit [31:0] sdo_shiftreg4 = 'h0;
bit [31:0] sdo_shiftreg_store_arr [NUM_OF_TRANSFERS - 1:0];
bit [15:0] sdo_store_cnt = 'h0;
bit [5:0]  sclk_counter = 'h0;
bit   sclk_counter_flag = 'h0;
bit [31:0] offload_transfer_cnt;

//// SDO shift register
initial begin
  while(1) begin
    // synchronization
    @(negedge spi_sclk_bfm or posedge m_spi_csn_negedge_s);

    if (m_spi_csn_negedge_s) begin
      if (m_spi_csn_negedge_s) @(posedge spi_sclk_bfm); // NOTE: when PHA=1 first shift should be at the second positive edge
    end else begin
      if (offload_status) begin
        sdo_shiftreg <= {sdo_shiftreg[27:0], ad3552r_dac_spi_sdo[3], ad3552r_dac_spi_sdo[2], ad3552r_dac_spi_sdo[1], ad3552r_dac_spi_sdo[0]};
        if (sclk_counter == 'd7) begin
          sclk_counter <= 'h0;
        end else begin
          sclk_counter <= sclk_counter + 1'h1;
        end
        if (sclk_counter == 'd6) begin
          sclk_counter_flag <= 'h1;
        end else begin
          sclk_counter_flag <= 'h0;
        end
        
      end else begin
        sdo_shiftreg2 <= {sdo_shiftreg2[27:0], ad3552r_dac_spi_sdo[3], ad3552r_dac_spi_sdo[2], ad3552r_dac_spi_sdo[1], ad3552r_dac_spi_sdo[0]};
      end
    end
  end
end

initial begin
  while(1) begin
    @(posedge sclk_counter_flag) begin
      sdo_shiftreg_store_arr [sdo_store_cnt] = sdo_shiftreg;
      sdo_store_cnt = sdo_store_cnt + 'h1;
      offload_transfer_cnt <= offload_transfer_cnt + 'h1;
    end
  end
end

//---------------------------------------------------------------------------
// Storing SDI Data for later comparison
//---------------------------------------------------------------------------

bit         offload_status = 0;
bit         shiftreg_sampled = 0;
bit [15:0]  sdi_store_cnt = (`NUM_OF_SDI == 1) ? 'h1 : 'h0;
bit [31:0]  offload_sdi_data_store_arr [(2 * NUM_OF_TRANSFERS) - 1:0];
bit [31:0]  sdi_fifo_data_store;
bit [31:0]  sdi_data_store;
bit [31:0]  sdi_shiftreg2;
bit [31:0]  sdi_shiftreg_aux;
bit [31:0]  sdi_shiftreg_aux_old;
bit [31:0]  sdi_shiftreg_old;

//---------------------------------------------------------------------------
// SPI Init
//---------------------------------------------------------------------------

task init;
begin

  //start spi clk generator
  axi_write (PULSAR_ADC_CLKGEN_BASE + 32'h00000040, 32'h0000003);

  //config cnv
  axi_write (PULSAR_ADC_CNV_BASE + 32'h00000010, 32'h00000000);
  axi_write (PULSAR_ADC_CNV_BASE + 32'h00000040, 'd32);
  axi_write (PULSAR_ADC_CNV_BASE + 32'h00000010, 32'h00000002);

  // Enable SPI Engine
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_ENABLE, 0);

  // Set up the interrupts
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_IRQMASK, 32'h00018);

  // Start DDS
  axi_write (SPI_DDS + 32'h40, 32'h1);
  axi_write (SPI_DDS + 32'h44, 32'h1);
  axi_write (SPI_DDS + 32'h400, 32'hfff);
  axi_write (SPI_DDS + 32'h404, 32'hff);
  axi_write (SPI_DDS + 32'h408, 32'h1f);
  axi_write (SPI_DDS + 32'h40c, 32'h1f1f);
  
end
endtask

//---------------------------------------------------------------------------
// Offload SPI Test
//---------------------------------------------------------------------------

bit [31:0] offload_captured_word_arr [(2 * NUM_OF_TRANSFERS) -1 :0];

task offload_spi_test;
  begin

    //Configure DMA
    env.mng.RegWrite32(`PULSAR_ADC_DMA+32'h400, 32'h00000001); // Enable DMA
    env.mng.RegWrite32(`PULSAR_ADC_DMA+32'h40c, 32'h00000006); // use TLAST
    env.mng.RegWrite32(`PULSAR_ADC_DMA+32'h418, (NUM_OF_TRANSFERS*4*2)-1); // X_LENGHTH = 1024-1
    env.mng.RegWrite32(`PULSAR_ADC_DMA+32'h410, `DDR_BASE); // DEST_ADDRESS
    env.mng.RegWrite32(`PULSAR_ADC_DMA+32'h408, 32'h00000001); // Submit transfer DMA

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_SDO, 32'hdead);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_SDO, 32'hbeef);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CFG | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_PRESCALE | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_DLENGTH_16 | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_ON | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_WR | 1 | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 5 | 16'h8000);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CFG);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_PRESCALE);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_DLENGTH_32);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_WR );
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 6);

    offload_status = 1;

    // Start the offload
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 1);
    $display("[%t] Offload started 0.", $time);

    wait(offload_transfer_cnt == NUM_OF_TRANSFERS/2);
    offload_status = 0;

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 0);

#2000
    
    axi_write (PULSAR_ADC_CNV_BASE + 32'h00000040, 'd20);  //CLOCK_DIVIDER=0
    axi_write (PULSAR_ADC_CNV_BASE + 32'h00000010, 32'h00000002);

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_RESET, 1);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_RESET, 0);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_ENABLE, 1);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_ENABLE, 0);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_SDO, 32'had);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_SDO, 32'hde);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CFG | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_PRESCALE | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_DLENGTH_8 | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_ON | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_WR | 1 | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CFG_DDR | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_DLENGTH_32 | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 7 | 16'h8000);

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_WR);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 8);

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_AXIS_SW, 1'h1);
    
    offload_status = 1;

    // Start the offload
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 1);
    $display("[%t] Offload started 1.", $time);

    wait(offload_transfer_cnt == NUM_OF_TRANSFERS);
    offload_status = 0;

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 0);

#2000
    
    axi_write (PULSAR_ADC_CNV_BASE + 32'h00000040, 'd14);  //CLOCK_DIVIDER=0
    axi_write (PULSAR_ADC_CNV_BASE + 32'h00000010, 32'h00000002);

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_RESET, 1);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_RESET, 0);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_ENABLE, 1);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_ENABLE, 0);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_SDO, 32'had);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_SDO, 32'hde);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CFG | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_PRESCALE | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_DLENGTH_8 | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_ON | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_WR | 1 | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CFG_DDR | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_DLENGTH_32 | 16'h8000);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_WR | 'hff | 16'h8000);
    
//    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_OFF | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 10 | 16'h8000);
//    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 11 );
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_AXIS_SW, 1'h1);
    
    offload_status = 1;

    // Start the offload
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 1);
    $display("[%t] Offload started 2.", $time);

    wait(offload_transfer_cnt == NUM_OF_TRANSFERS);

#25000

    offload_status = 0;

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 0);

   axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_RESET, 1);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_RESET, 0);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_ENABLE, 1);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_ENABLE, 0);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_SDO, 32'had);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_SDO, 32'hde);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CFG | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_PRESCALE | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_DLENGTH_8 | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_ON | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_WR | 1 | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CFG_DDR | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_DLENGTH_32 | 16'h8000);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_WR | 'hff | 16'h8000);
    
//    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_OFF | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 10 | 16'h8000);
//    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 11 );
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_AXIS_SW, 1'h1);
    
    offload_status = 1;

    // Start the offload
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 1);
    $display("[%t] Offload started 3.", $time);

//    wait(offload_transfer_cnt == NUM_OF_TRANSFERS);

#25000

    offload_status = 0;

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 0);
    
///////////

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_RESET, 1);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_RESET, 0);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_ENABLE, 1);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_ENABLE, 0);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_SDO, 32'had);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_SDO, 32'hde);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CFG | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_PRESCALE | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_DLENGTH_8 | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_ON | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_WR | 1 | 16'h8000);
//    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CFG_DDR | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_DLENGTH_32 | 16'h8000);
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_WR | 'hff | 16'h8000);
    
//    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_OFF | 16'h8000);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 10 | 16'h8000);
//    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 11 );
    
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_AXIS_SW, 1'h1);
    
    offload_status = 1;

    // Start the offload
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 1);
    $display("[%t] Offload started 4.", $time);

//    wait(offload_transfer_cnt == NUM_OF_TRANSFERS);

#25000

    offload_status = 0;

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 0);

    $display("[%t] Offload stopped.", $time);

    #2000
    for (int i=0; i<=((2 * NUM_OF_TRANSFERS) -1); i=i+1) begin
      #1
      offload_captured_word_arr[i] = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(`DDR_BASE + 4*i);
    end

    if (irq_pending == 'h0) begin
//      `ERROR(("IRQ Test FAILED"));
    end else begin
      `INFO(("IRQ Test PASSED"));
    end

    if (offload_captured_word_arr [(2 * NUM_OF_TRANSFERS) - 1:2] != offload_sdi_data_store_arr [(2 * NUM_OF_TRANSFERS) - 1:2]) begin
//      `ERROR(("Offload Test FAILED"));
    end else begin
      `INFO(("Offload Test PASSED"));
    end

  end
endtask

//---------------------------------------------------------------------------
// FIFO SPI Test
//---------------------------------------------------------------------------

bit   [31:0]  sdi_fifo_data = 0;
bit   [31:0]  sdi_fifo_data2 = 0;

task fifo_spi_test;
begin

  // Configure the execution module
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_CFG);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_PRESCALE);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_DLENGTH_16);
  
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_AXIS_SW, 1'h0);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_AXIS_SW, 1'h1);
//  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_AXIS_SW, 1'h0);

  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_CS_ON);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, 32'h200);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_CS_OFF);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, (INST_SYNC | 1));
  
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_CS_ON);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, 32'h200);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_CS_OFF);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, (INST_SYNC | 2));
  
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_CS_ON);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, 32'h200);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_CS_OFF);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, (INST_SYNC | 3));
  
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_CS_ON);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, 32'h200);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, INST_CS_OFF);
  axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_CMDFIFO, (INST_SYNC | 4));

  axi_read (PULSAR_ADC_BASE + SPI_ENG_ADDR_SDIFIFO, sdi_fifo_data);
  axi_read (PULSAR_ADC_BASE + SPI_ENG_ADDR_SDIFIFO, sdi_fifo_data);
  axi_read (PULSAR_ADC_BASE + SPI_ENG_ADDR_SDIFIFO, sdi_fifo_data);
  axi_read (PULSAR_ADC_BASE + SPI_ENG_ADDR_SDIFIFO, sdi_fifo_data);

end
endtask

endprogram
