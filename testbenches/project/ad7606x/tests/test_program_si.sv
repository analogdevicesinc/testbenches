// ***************************************************************************
// ***************************************************************************
// Copyright 2022 (c) Analog Devices, Inc. All rights reserved.
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
localparam SAMPLE_PERIOD              = 500;
localparam ASYNC_SPI_CLK              = 1;
localparam DATA_WIDTH                 = 32;
localparam DATA_DLENGTH               = 32;
localparam ECHO_SCLK                  = 0;
localparam SDI_PHY_DELAY              = 18;
localparam SDI_DELAY                  = 0;
localparam NUM_OF_CS                  = 1;
localparam THREE_WIRE                 = 0;
localparam CPOL                       = 0;
localparam CPHA                       = 1;
localparam CLOCK_DIVIDER              = 0;
localparam NUM_OF_WORDS               = 1;
localparam NUM_OF_TRANSFERS           = 3;

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


program test_program_si (
  input         spi_clk,
  input         ad7606_irq,
  output        ad7606_spi_cs,
  output        ad7606_spi_sclk,
  input  [`NUM_OF_SDI-1:0] ad7606_spi_sdi,
  input         rx_busy,
  output        rx_cnvst_n);

  test_harness_env env;

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
  // Main procedure
  // --------------------------
  initial begin

    //creating environment
    env = new("AD7606X Environment",
              `TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    env.start();
    env.sys_reset();

    sanity_test();

    #100

    fifo_spi_test();

    #100

    offload_spi_test();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish;

  end

  //---------------------------------------------------------------------------
  // Sanity test reg interface
  //---------------------------------------------------------------------------

  task sanity_test();
    bit [31:0] pcore_version = (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_PATCH)
                            | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MINOR)<<8
                            | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MAJOR)<<16;
    axi_read_v (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_VERSION), pcore_version);
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
    axi_read_v (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
    `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // SPI Engine generate transfer
  //---------------------------------------------------------------------------

  task generate_transfer_cmd(
   input [7:0] sync_id);

    // assert CSN
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_CS_ON);
    // transfer data
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_WRD);
    // de-assert CSN
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_CS_OFF);
    // SYNC command to generate interrupt
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), (INST_SYNC | sync_id));
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // IRQ callback
  //---------------------------------------------------------------------------

  reg [4:0] irq_pending = 0;
  reg [7:0] sync_id = 0;

  initial begin
    forever begin
      @(posedge ad7606_irq);
      // read pending IRQs
      axi_read (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
      // IRQ launched by Offload SYNC command
      if (irq_pending & 5'b10000) begin
        axi_read (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
        `INFO(("Offload SYNC %d IRQ. An offload transfer just finished.", sync_id), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by SYNC command
      if (irq_pending & 5'b01000) begin
        axi_read (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
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
      axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
    end
  end

  //---------------------------------------------------------------------------
  // Echo SCLK generation - we need this only if ECHO_SCLK is enabled
  //---------------------------------------------------------------------------

  reg     [SDI_PHY_DELAY:0] echo_delay_sclk = {SDI_PHY_DELAY{1'b0}};
  reg     delay_clk = 0;
  wire    m_rx_sclk;

  assign  m_rx_sclk = ad7606_spi_sclk;

  // Add an arbitrary delay to the echo_sclk signal
  initial begin
    forever begin
      @(posedge delay_clk) begin
        echo_delay_sclk <= {echo_delay_sclk, m_rx_sclk};
       end
    end
  end
  assign ad7606_echo_sclk = echo_delay_sclk[SDI_PHY_DELAY-1];

  initial begin
    forever begin
      #0.5   delay_clk = ~delay_clk;
    end
  end

  //---------------------------------------------------------------------------
  // SDI data generator
  //---------------------------------------------------------------------------

  wire          end_of_word;
  wire          rx_sclk_bfm = ad7606_echo_sclk;
  wire          m_spi_csn_negedge_s;
  wire          m_spi_csn_int_s = &ad7606_spi_cs;
  bit           m_spi_csn_int_d = 0;
  bit   [31:0]  sdi_shiftreg;
  wire  [31:0]  sdi_shiftreg2;
  bit   [7:0]   rx_sclk_pos_counter = 0;
  bit   [7:0]   rx_sclk_neg_counter = 0;
  bit   [31:0]  sdi_preg[$];
  bit   [31:0]  sdi_nreg[$];

  initial begin
    forever begin
      @(posedge spi_clk);
        m_spi_csn_int_d <= m_spi_csn_int_s;
    end
  end

  assign m_spi_csn_negedge_s = ~m_spi_csn_int_s & m_spi_csn_int_d;

  genvar i;
  for (i = 0; i < `NUM_OF_SDI; i++) begin
    assign ad7606_spi_sdi[i] = sdi_shiftreg[31]; // all SDI lanes got the same data
  end

  assign end_of_word = (CPOL ^ CPHA) ?
                      (rx_sclk_pos_counter == 32) :
                      (rx_sclk_neg_counter == 32);

  initial begin
    forever begin
      @(posedge rx_sclk_bfm or posedge m_spi_csn_negedge_s);
      if (m_spi_csn_negedge_s) begin
        rx_sclk_pos_counter <= 8'b0;
      end else begin
        rx_sclk_pos_counter <= (rx_sclk_pos_counter == DATA_DLENGTH) ? 0 : rx_sclk_pos_counter+1;
      end
    end
  end

  initial begin
    forever begin
      @(negedge rx_sclk_bfm or posedge m_spi_csn_negedge_s);
      if (m_spi_csn_negedge_s) begin
        rx_sclk_neg_counter <= 8'b0;
      end else begin
        rx_sclk_neg_counter <= (rx_sclk_neg_counter == DATA_DLENGTH) ? 0 : rx_sclk_neg_counter+1;
      end
    end
  end

  // SDI shift register
  initial begin
    forever begin
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
          `INFO(("SR 1"), ADI_VERBOSITY_LOW);
        end else begin
          sdi_shiftreg <= (CPOL ^ CPHA) ?
                          sdi_preg[$] :
                          sdi_nreg[$];
          `INFO(("SR 2"), ADI_VERBOSITY_LOW);
        end
        if (m_spi_csn_negedge_s) @(posedge rx_sclk_bfm); // NOTE: when PHA=1 first shift should be at the second positive edge
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
  bit [31:0]  offload_sdi_data_store_arr [(`NUM_OF_SDI * NUM_OF_TRANSFERS)-1:0];
  bit [31:0]  sdi_fifo_data_store;
  bit [31:0]  sdi_data_store;
  bit [31:0]  sdi_shiftreg2;
  bit [31:0]  sdi_shiftreg_aux;
  bit [31:0]  sdi_shiftreg_aux_old;

  assign sdi_shiftreg2 = {1'b0, sdi_shiftreg[31:1]};

  initial begin
    forever begin
      @(posedge ad7606_echo_sclk);
      sdi_data_store <= {sdi_shiftreg[27:0], 4'b0};
      if (sdi_data_store == 'h0 && shiftreg_sampled == 'h1 && sdi_shiftreg != 'h0) begin
        shiftreg_sampled <= 'h0;
        if (offload_status) begin
            sdi_store_cnt <= sdi_store_cnt + 1;
        end
      end else if (shiftreg_sampled == 'h0 && sdi_data_store != 'h0) begin
        if (offload_status) begin
          if (`NUM_OF_SDI == 1) begin
                  offload_sdi_data_store_arr[sdi_store_cnt] = sdi_shiftreg;
          end else if (`NUM_OF_SDI == 2) begin
                  offload_sdi_data_store_arr[0+(2*sdi_store_cnt)] = sdi_shiftreg;
                  offload_sdi_data_store_arr[1+(2*sdi_store_cnt)] = sdi_shiftreg;
          end else if (`NUM_OF_SDI == 4) begin
                  offload_sdi_data_store_arr[0+(4*sdi_store_cnt)] = sdi_shiftreg;
                  offload_sdi_data_store_arr[1+(4*sdi_store_cnt)] = sdi_shiftreg;
                  offload_sdi_data_store_arr[2+(4*sdi_store_cnt)] = sdi_shiftreg;
                  offload_sdi_data_store_arr[3+(4*sdi_store_cnt)] = sdi_shiftreg;
          end else if (`NUM_OF_SDI == 8) begin
                  offload_sdi_data_store_arr[0+(8*sdi_store_cnt)] = sdi_shiftreg;
                  offload_sdi_data_store_arr[1+(8*sdi_store_cnt)] = sdi_shiftreg;
                  offload_sdi_data_store_arr[2+(8*sdi_store_cnt)] = sdi_shiftreg;
                  offload_sdi_data_store_arr[3+(8*sdi_store_cnt)] = sdi_shiftreg;
                  offload_sdi_data_store_arr[4+(8*sdi_store_cnt)] = sdi_shiftreg;
                  offload_sdi_data_store_arr[5+(8*sdi_store_cnt)] = sdi_shiftreg;
                  offload_sdi_data_store_arr[6+(8*sdi_store_cnt)] = sdi_shiftreg;
                  offload_sdi_data_store_arr[7+(8*sdi_store_cnt)] = sdi_shiftreg;
            end
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

  bit [31:0] offload_captured_word_arr [(`NUM_OF_SDI * NUM_OF_TRANSFERS) -1 :0];

  task offload_spi_test();
    //Configure DMA
    env.mng.RegWrite32(`AD7606X_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    env.mng.RegWrite32(`AD7606X_DMA_BA + GetAddrs(DMAC_FLAGS),
      `SET_DMAC_FLAGS_TLAST(1) |
      `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
      ); // Use TLAST
    env.mng.RegWrite32(`AD7606X_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH((NUM_OF_TRANSFERS*4*`NUM_OF_SDI)-1)); // X_LENGHTH
    env.mng.RegWrite32(`AD7606X_DMA_BA + GetAddrs(DMAC_DEST_ADDRESS), `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA));  // DEST_ADDRESS
    env.mng.RegWrite32(`AD7606X_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer DMA

    // Configure the Offload module
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CFG);
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_PRESCALE);
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_DLENGTH);
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CS_ON);
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_RD);
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_CS_OFF);
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), INST_SYNC | 2);
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_SDO_FIFO), 16'hBEAF << (DATA_WIDTH - DATA_DLENGTH));

    offload_status = 1;

    // Start the offload
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(1));
    `INFO(("Offload started."), ADI_VERBOSITY_LOW);

      wait(offload_transfer_cnt == NUM_OF_TRANSFERS);

    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(0));
    offload_status = 0;

    `INFO(("Offload stopped."), ADI_VERBOSITY_LOW);

    #2000

    for (int i=0; i<=((`NUM_OF_SDI * NUM_OF_TRANSFERS) -1); i=i+1) begin
      #1
      offload_captured_word_arr[i] = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(`DDR_BA + 4*i);
    end
    if (offload_captured_word_arr != offload_sdi_data_store_arr) begin
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

  `ifdef AD7606X_AXI_CLKGEN_BA
    // Start spi clk generator
    axi_write (`AD7606X_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
      `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
      `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
      );
  `endif

    // Configure pwm
    axi_write (`AXI_PWMGEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
    axi_write (`AXI_PWMGEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('h64)); // set PWM period
    axi_write (`AXI_PWMGEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
    `INFO(("axi_pwm_gen started."), ADI_VERBOSITY_LOW);

    // Enable SPI Engine
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));

    // Configure the execution module
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_CFG);
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_PRESCALE);
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), INST_DLENGTH);

    // Set up the interrupts
    axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_MASK),
      `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(1) |
      `SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(1)
      );

    #100
    // Generate a FIFO transaction, write SDO first
    repeat (NUM_OF_WORDS) begin
      axi_write (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDO_FIFO), (16'hDEAD << (DATA_WIDTH - DATA_DLENGTH)));
    end

    generate_transfer_cmd(1);

    #100
    wait(sync_id == 1);
    #100

    repeat (NUM_OF_WORDS) begin
      axi_read (`SPI_AD7606_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SDI_FIFO_PEEK) , sdi_fifo_data);
    end

    `INFO(("sdi_fifo_data: %x; sdi_fifo_data_store %x", sdi_fifo_data, sdi_fifo_data_store), ADI_VERBOSITY_LOW);

    if (sdi_fifo_data != sdi_fifo_data_store) begin
      `ERROR(("Fifo Read Test FAILED"));
    end else begin
      `INFO(("Fifo Read Test PASSED"), ADI_VERBOSITY_LOW);
    end
  endtask

endprogram
