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
`define DDR_BASE                        32'h8000_0000

localparam SPI_ENG_ADDR_VERSION       = 32'h0000_0000;
localparam SPI_ENG_ADDR_ID            = 32'h0000_0004;
localparam SPI_ENG_ADDR_SCRATCH       = 32'h0000_0008;
localparam SPI_ENG_ADDR_ENABLE        = 32'h0000_0040;
localparam SPI_ENG_ADDR_IRQMASK       = 32'h0000_0080;
localparam SPI_ENG_ADDR_IRQPEND       = 32'h0000_0084;
localparam SPI_ENG_ADDR_IRQSRC        = 32'h0000_0088;
localparam SPI_ENG_ADDR_SYNCID        = 32'h0000_00C0;
localparam SPI_ENG_ADDR_CMDFIFO_ROOM  = 32'h0000_00D0;
localparam SPI_ENG_ADDR_SDOFIFO_ROOM  = 32'h0000_00D4;
localparam SPI_ENG_ADDR_SDIFIFO_LEVEL = 32'h0000_00D8;
localparam SPI_ENG_ADDR_CMDFIFO       = 32'h0000_00E0;
localparam SPI_ENG_ADDR_SDOFIFO       = 32'h0000_00E4;
localparam SPI_ENG_ADDR_SDIFIFO       = 32'h0000_00E8;
localparam SPI_ENG_ADDR_SDIFIFO_PEEK  = 32'h0000_00F0;
localparam SPI_ENG_ADDR_OFFLOAD_EN    = 32'h0000_0100;
localparam SPI_ENG_ADDR_OFFLOAD_RESET = 32'h0000_0108;
localparam SPI_ENG_ADDR_OFFLOAD_CMD   = 32'h0000_0110;
localparam SPI_ENG_ADDR_OFFLOAD_SDO   = 32'h0000_0114;

//---------------------------------------------------------------------------
// SPI Engine configuration parameters
//---------------------------------------------------------------------------
localparam PCORE_VERSION              = 32'h0001_0071;
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
`define sleep(a)                      = INST_SLEEP | (a & 8'hFF);

localparam PULSAR_ADC_BASE = `PULSAR_ADC_REGMAP;
localparam PULSAR_ADC_CLKGEN_BASE = `PULSAR_ADC_CLKGEN;
localparam PULSAR_ADC_CNV_BASE = `PULSAR_ADC_CNV;

program test_cs_delay (
  input pulsar_adc_irq,
  input pulsar_adc_spi_sclk,
  input pulsar_adc_spi_cs,
  input pulsar_adc_spi_clk,
  input [(`NUM_OF_SDI - 1):0] pulsar_adc_spi_sdi);

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

  cs_delay_test(3,3);

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
// IRQ callback
//---------------------------------------------------------------------------

reg [4:0] irq_pending = 0;
reg [7:0] sync_id = 0;

initial begin
  while (1) begin
    @(posedge pulsar_adc_irq); // TODO: Make sure irq resets even the source remain active after clearing the IRQ register
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

  assign  m_spi_sclk = pulsar_adc_spi_sclk;

  // Add an arbitrary delay to the echo_sclk signal
  initial begin
    while(1) begin
      @(posedge delay_clk) begin
        echo_delay_sclk <= {echo_delay_sclk, m_spi_sclk};
       end
    end
  end
  assign pulsar_adc_echo_sclk = echo_delay_sclk[SDI_PHY_DELAY-1];

initial begin
  while(1) begin
    #0.5   delay_clk = ~delay_clk;
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
  while(1) begin
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
  while(1) begin
    @(posedge shiftreg_sampled && offload_status);
      offload_transfer_cnt <= offload_transfer_cnt + 'h1;
  end
end

//---------------------------------------------------------------------------
// Chip Select Instruction time counter
//---------------------------------------------------------------------------

bit [31:0] cs_instr_time[$];
bit [31:0] cs_current_duration;
wire [15:0] cmd, cmd_d1;
wire cmd_valid, cmd_ready;
wire idle;

assign cmd          = test_harness.spi_pulsar_adc.spi_pulsar_adc_execution.inst.cmd;
assign cmd_d1       = test_harness.spi_pulsar_adc.spi_pulsar_adc_execution.inst.cmd_d1;
assign cmd_valid    = test_harness.spi_pulsar_adc.spi_pulsar_adc_execution.inst.cmd_valid;
assign cmd_ready    = test_harness.spi_pulsar_adc.spi_pulsar_adc_execution.inst.cmd_ready;
assign idle         = test_harness.spi_pulsar_adc.spi_pulsar_adc_execution.inst.idle;

initial begin
  cs_current_duration = 0;
  while(1) begin
    @(posedge pulsar_adc_spi_clk);
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


    //start spi clk generator
    #100 axi_write (PULSAR_ADC_CLKGEN_BASE + 32'h00000040, 32'h0000003);

    //config cnv
    #100 axi_write (PULSAR_ADC_CNV_BASE + 32'h00000010, 32'h00000000);
    #100 axi_write (PULSAR_ADC_CNV_BASE + 32'h00000040, 32'd00001000);
    #100 axi_write (PULSAR_ADC_CNV_BASE + 32'h00000010, 32'h00000002);

    //Configure DMA
    env.mng.RegWrite32(`PULSAR_ADC_DMA+32'h400, 32'h00000001); // Enable DMA
    env.mng.RegWrite32(`PULSAR_ADC_DMA+32'h40c, 32'h00000006); // use TLAST
    env.mng.RegWrite32(`PULSAR_ADC_DMA+32'h418, (NUM_OF_TRANSFERS*4)-1); // X_LENGHTH = 1024-1
    env.mng.RegWrite32(`PULSAR_ADC_DMA+32'h410, `DDR_BASE); // DEST_ADDRESS
    env.mng.RegWrite32(`PULSAR_ADC_DMA+32'h408, 32'h00000001); // Submit transfer to DMA

    // Enable SPI Engine
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_ENABLE, 0);    

    // Set up the interrupts
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_IRQMASK, 32'h00018);

    // Configure the Offload module
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CFG);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_PRESCALE);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_DLENGTH);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_ON);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_RD);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_OFF);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 1);
    
    offload_transfer_cnt = 0;
    offload_status = 1;
    expected_cs_activate_time = 2;
    expected_cs_deactivate_time = 2;

    // Start the offload
    #100
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 1);
    $display("[%t] Offload started.", $time);

    wait(offload_transfer_cnt == NUM_OF_TRANSFERS);

    offload_status = 0;
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 0);
    

    $display("[%t] Offload stopped.", $time);

    #2000

    for (int i=0; i<=((NUM_OF_TRANSFERS) -1); i=i+1) begin
      #1
      offload_captured_word_arr[i] = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(`DDR_BASE + 4*i);
    end

    if (irq_pending == 'h0) begin
      `ERROR(("IRQ Test FAILED"));
    end else begin
      `INFO(("IRQ Test PASSED)"));
    end

    if (offload_captured_word_arr [(NUM_OF_TRANSFERS) - 1:2] != offload_sdi_data_store_arr [(NUM_OF_TRANSFERS) - 1:2]) begin
      `ERROR(("Offload Test FAILED: bad data"));
    end else begin
      cs_activate_time = cs_instr_time.pop_back();
      cs_deactivate_time = cs_instr_time.pop_back();
      if ((cs_activate_time != expected_cs_activate_time)) begin
        `ERROR(("Offload Test FAILED: unexpected chip select activate instruction duration. Expected=%d, Got=%d",expected_cs_activate_time,cs_activate_time));        
      end else if (cs_deactivate_time != expected_cs_deactivate_time) begin
        `ERROR(("Offload Test FAILED: unexpected chip select deactivate instruction duration. Expected=%d, Got=%d",expected_cs_deactivate_time,cs_deactivate_time));    
      end else begin
        `INFO(("Offload Test PASSED)"));  
      end
    end

    #2000    
    env.mng.RegWrite32(`PULSAR_ADC_DMA+32'h408, 32'h00000001); // Submit DMA transfer

    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_RESET, 1);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_RESET, 0);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_ON | ((cs_activate_delay & 2'b11) << 8));
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_RD);
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_CS_OFF | ((cs_deactivate_delay & 2'b11) << 8));
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_CMD, INST_SYNC | 2);

    offload_transfer_cnt = 0;
    sdi_store_cnt = 0;
    offload_status = 1;
    
    // behaviour as per wiki should be 2*cs_activate_delay*(1+CLOCK_DIVIDER), half before and half after cs change
    // behaviour as of 4d676ca: 2+cs_activate_delay*(1+CLOCK_DIVIDER)*2 before cs change, no delay after.
    // behaviour after fix: 3+2*cs_activate_delay*(1+CLOCK_DIVIDER)*2
    // breakdown: cs_activate_delay*(1+CLOCK_DIVIDER)*2, times 2 since it's before and after cs transition, and added 3 cycles (1 for each timer comparison, plus one for fetching next instruction)
    expected_cs_activate_time = 3+2*cs_activate_delay*(1+CLOCK_DIVIDER)*2; 
    expected_cs_deactivate_time = 3+2*cs_deactivate_delay*(1+CLOCK_DIVIDER)*2; 

    // Start the offload
    #100
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 1);
    $display("[%t] Offload started.", $time);

    wait(offload_transfer_cnt == NUM_OF_TRANSFERS);

    offload_status = 0;
    axi_write (PULSAR_ADC_BASE + SPI_ENG_ADDR_OFFLOAD_EN, 0);
    
    $display("[%t] Offload stopped.", $time);

    #2000

    for (int i=0; i<=((NUM_OF_TRANSFERS) -1); i=i+1) begin
      #1
      offload_captured_word_arr[i] = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(`DDR_BASE + 4*i);
    end

    if (irq_pending == 'h0) begin
      `ERROR(("IRQ Test FAILED"));
    end else begin
      `INFO(("IRQ Test PASSED)"));
    end

    if (offload_captured_word_arr [(NUM_OF_TRANSFERS) - 1:2] != offload_sdi_data_store_arr [(NUM_OF_TRANSFERS) - 1:2]) begin
      `ERROR(("Offload Test FAILED: bad data"));
    end else begin
      cs_activate_time = cs_instr_time.pop_back();
      cs_deactivate_time = cs_instr_time.pop_back();
      if ((cs_activate_time != expected_cs_activate_time)) begin
        `ERROR(("Offload Test FAILED: unexpected chip select activate instruction duration. Expected=%d, Got=%d",expected_cs_activate_time,cs_activate_time));        
      end else if (cs_deactivate_time != expected_cs_deactivate_time) begin
        `ERROR(("Offload Test FAILED: unexpected chip select deactivate instruction duration. Expected=%d, Got=%d",expected_cs_deactivate_time,cs_deactivate_time));    
      end else begin
        `INFO(("Offload Test PASSED)"));  
      end
    end

  end
endtask

endprogram
