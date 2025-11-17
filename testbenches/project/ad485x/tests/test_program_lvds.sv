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
`include "axi_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import dmac_api_pkg::*;
import pwm_gen_api_pkg::*;
import clk_gen_api_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_common_pkg::*;
//import adi_regmap_clkgen_pkg::*;
//import adi_regmap_dmac_pkg::*;
//import adi_regmap_pwm_gen_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program_lvds (
    input cnvs_tp,
    output busy_tp,
    input scki_p_tp,
    input scki_n_tp,
    output scko_p_tp,
    output scko_n_tp,
    output sdo_p_tp,
    output sdo_n_tp
);

  timeunit 1ns;
  timeprecision 1ps;

  // Declare the class instances
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  dmac_api dma_api;
  pwm_gen_api pwm_api;
  clk_gen_api clkgen_api;

  // Variables for ADC
  // Parameters for differents cases to test
  localparam PACKET_WIDTH = `PACKET_WIDTH; //16, 20, 24, 32
  //localparam TESTPATTERN_EN = 1'b1; // 1 - const vecs; 0 - incremental
  localparam NUMB_OF_CH   = `NUMB_OF_CH;
  localparam OCTA_CHANNEL = `OCTA_CHANNEL; //8ch+meta; 0 - 4ch+meta
  localparam RESOLUTION   = `RESOLUTION;

  localparam             MAXR_INDEX = OCTA_CHANNEL ? 9 : 5;
  localparam             MAXC_INDEX = OCTA_CHANNEL ? 9 : 5;

  reg         [31:0]      rx_db_i[0:8];
  reg         [ 5:0]      db_i_index = 0;
  reg         [ 3:0]      ring_buffer_index = 0;

  wire        [ 3:0]      ch_index_lane;
  reg                     db_i_shift = 'd0;

  reg                     oversampling = 'd0; //trebuie scrise in ADC_COMMON prin axi
  reg         [1:0]       packet_format = 0; // 0 - 20 bits, 1 - 24 bits, 2 - 32 bits; 16bits la ad4851- cum fac?
  reg                     crc_en = 1;
  reg         [31:0]      testpattern_en = 1;
  reg         [7:0]       adc_custom_ctrl = 0;

  reg         [31:0]      packet_sz = 20;
  reg                     busy = 'd0;
  reg                     busy_d = 'd0;
  reg                     busy_os = 'd0;
  reg                     cnvs_d = 'd0;

  reg         [15:0]      oversampling_counter = 'd0;
  reg         [15:0]      busy_counter = 'd0;

  wire        [ 9:0]      busy_period = 133; // 665/5=133

  reg       scki_p_d = 'd0;
  reg       scki_p_d2 = 'd0;
  reg       scki_n_d = 'd0;
  reg       scki_n_d2 = 'd0;

  bit [31:0] captured_word_arr [0:8];
  bit [31:0] expected_adc_data[0:8];
  bit [12:0] crc_err = 0;
  bit crc_err_found = 0;

  // --------------------------
  // Wrapper function for AXI read verif
  // --------------------------
  task axi_read_v(
      input   [31:0]  raddr,
      input   [31:0]  vdata);

    base_env.mng.sequencer.RegReadVerify32(raddr,vdata);
  endtask

  task axi_read(
      input   [31:0]  raddr,
      output  [31:0]  data);

    base_env.mng.sequencer.RegRead32(raddr,data);
  endtask

  // --------------------------
  // Wrapper function for AXI write
  // --------------------------
  task axi_write(
    input [31:0]  waddr,
    input [31:0]  wdata);

    base_env.mng.sequencer.RegWrite32(waddr,wdata);
  endtask

  // Process variables
  process current_process;
  string current_process_random_state;


  initial begin

    setLoggerVerbosity(ADI_VERBOSITY_LOW);

    current_process = process::self();
    current_process_random_state = current_process.get_randstate();
    `INFO(("Randomization state: %s", current_process_random_state), ADI_VERBOSITY_NONE);

    // Create environment
    base_env = new("Base Environment",
              `TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    dma_api = new("RX DMA API",
                  base_env.mng.sequencer,
                  `AD485X_DMA_BA);

    clkgen_api = new("CLKGEN API",
                    base_env.mng.sequencer,
                    `AD485X_ADC_CLKGEN_BA);

    pwm_api = new("PWM API",
                  base_env.mng.sequencer,
                  `AD485X_AXI_PWM_GEN_BA);

    base_env.start();
    base_env.sys_reset();

    /* Add stimulus tasks */
    sanity_test();

    // configure axi
    configure_axi();
    #500ns;

    //enable channels
    enable_adc_ch();
    #500ns;

    // prepare test data
    prepare_data();

    // start clocks and timing
    config_test();
    #2000ns; // wait for data acquisition

    capture_data();
    #1000ns;

    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end


  task sanity_test_axi();
       `INFO(("Running AXI Sanity Check on ADC Scratch Register..."), ADI_VERBOSITY_LOW);

       axi_write(`AXI_AD485X_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
       axi_read_v(`AXI_AD485X_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));

       `INFO(("AXI Sanity Test PASSED. Register access confirmed."), ADI_VERBOSITY_LOW);
  endtask

  task sanity_test();
    `INFO(("Running sanity tests"), ADI_VERBOSITY_LOW);
    dma_api.sanity_test();
    pwm_api.sanity_test();
    sanity_test_axi();

  endtask

  task configure_axi();
    // Configure AXI_AD485x -
    // CRC - in adc common
    // OVERSAMPLING - in datasheet - register summary: reg adr 0x27
    // TEST_PAT si PACKET_SIZE - datasheet - register summary: reg adr 0x26
    `INFO(("Configuring ADC core..."), ADI_VERBOSITY_LOW);

    // Reset ADC core first
    axi_write (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    #100ns;
    axi_write (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(1));
    #100ns;

    // Configure ADC parameters
    adc_custom_ctrl[2] = oversampling;
    adc_custom_ctrl[1:0] = packet_format;
    axi_write (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_CNTRL_3),`SET_ADC_COMMON_REG_CNTRL_3_CRC_EN(crc_en) | `SET_ADC_COMMON_REG_CNTRL_3_CUSTOM_CONTROL(adc_custom_ctrl));
    axi_write (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_CNTRL), `SET_ADC_COMMON_REG_CNTRL_NUM_LANES(NUMB_OF_CH));

    axi_read_v (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_CNTRL_3),`SET_ADC_COMMON_REG_CNTRL_3_CRC_EN(crc_en) | `SET_ADC_COMMON_REG_CNTRL_3_CUSTOM_CONTROL(adc_custom_ctrl));
    axi_read_v (`AXI_AD485X_BA + GetAddrs(ADC_COMMON_REG_CNTRL), `SET_ADC_COMMON_REG_CNTRL_NUM_LANES(NUMB_OF_CH));

    `INFO(("ADC core configured."), ADI_VERBOSITY_LOW);
  endtask


  task enable_adc_ch();
  //Enable ADC channels
    for (int i = 0; i < NUMB_OF_CH; i=i+1) begin
        axi_write (`AXI_AD485X_BA + i*'h40 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL), `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end

      // Verify channel enables
    for (int i = 0; i < NUMB_OF_CH; i=i+1) begin
        axi_read_v(`AXI_AD485X_BA + i*'h40 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL), `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end
    `INFO(("Enabled channels."), ADI_VERBOSITY_LOW);
  endtask;

  task config_test();
    // Start ADC clk generator
    clkgen_api.enable_clkgen();
    //#500ns

    dma_api.enable_dma();
    dma_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b0));
    dma_api.set_lengths(
      .xfer_length_x((NUMB_OF_CH * 32 / 8) - 1), // Number of bytes to transfer - 1, 9*32/8 -1 => 35 bytes
      .xfer_length_y(32'h0));
      dma_api.set_dest_addr(xil_axi_uint'(`DDR_BA));
    dma_api.transfer_start();

    // Config pwm - genereaza cnvs pentru axi si adc
    pwm_api.reset();
    #100ns
    pwm_api.pulse_period_config(0,'d200); // config channel 0 period
    pwm_api.pulse_width_config(0,'d8); // config channel 0 width
    pwm_api.load_config();
    pwm_api.start();
    `INFO(("axi_pwm_gen started."), ADI_VERBOSITY_LOW);

  endtask

  task prepare_data();
    case (packet_format)
      0 : packet_sz <= 20;
      1 : packet_sz <= 24;
      2 : packet_sz <= 32;
      default: packet_sz <= 20;
    endcase

    db_i_index <= packet_sz;

    if (testpattern_en == 1) begin
      // if (packet_format == 16) begin  //ad4851
      //   rx_db_i[0] <= 'h0ACE;
      //   rx_db_i[1] <= 'h1ACE;
      //   rx_db_i[2] <= 'h2ACE;
      //   rx_db_i[3] <= 'h3ACE;
      //   rx_db_i[4] <= OCTA_CHANNEL ? 'h4ACE : 'h709c; // channel or CRC
      //   rx_db_i[5] <= 'h5ACE;
      //   rx_db_i[6] <= 'h6ACE;
      //   rx_db_i[7] <= 'h7ACE;
      //   rx_db_i[8] <= 'hf1be;
      // end else

      if (packet_format == 0) begin
        //20 - pt ad4858
        rx_db_i[0] <= 'h0ACE3;
        rx_db_i[1] <= 'h1ACE3;
        rx_db_i[2] <= 'h2ACE3;
        rx_db_i[3] <= 'h3ACE3;
        rx_db_i[4] <= OCTA_CHANNEL ? 'h4ACE3 : 'h7696;
        rx_db_i[5] <= 'h5ACE3;
        rx_db_i[6] <= 'h6ACE3;
        rx_db_i[7] <= 'h7ACE3;
        rx_db_i[8] <= 'h4c3b;
      end else if (packet_format == 1) begin
        //24 pt ad4858
        rx_db_i[0] <= 'h0ACE3C;
        rx_db_i[1] <= 'h1ACE3C;
        rx_db_i[2] <= 'h2ACE3C;
        rx_db_i[3] <= 'h3ACE3C;
        rx_db_i[4] <= OCTA_CHANNEL ? 'h4ACE3C : 'h25e2;
        rx_db_i[5] <= 'h5ACE3C;
        rx_db_i[6] <= 'h6ACE3C;
        rx_db_i[7] <= 'h7ACE3C;
        rx_db_i[8] <= 'h5435;
      end else if (packet_format == 2) begin
        //32 pt ad4858
        rx_db_i[0] <= 'h0ACE3C2A;
        rx_db_i[1] <= 'h1ACE3C2A;
        rx_db_i[2] <= 'h2ACE3C2A;
        rx_db_i[3] <= 'h3ACE3C2A;
        rx_db_i[4] <= OCTA_CHANNEL ? 'h4ACE3C2A : 'h78ee;
        rx_db_i[5] <= 'h5ACE3C2A;
        rx_db_i[6] <= 'h6ACE3C2A;
        rx_db_i[7] <= 'h7ACE3C2A;
        rx_db_i[8] <= 'h2118;
      end
    end
    else begin
      rx_db_i[0] <= 'h80000;
      rx_db_i[1] <= 'h80001;
      rx_db_i[2] <= 'h80002;
      rx_db_i[3] <= 'h80003;
      rx_db_i[4] <= 'h80004;
      rx_db_i[5] <= 'h80005;
      rx_db_i[6] <= 'h80006;
      rx_db_i[7] <= 'h80007;
      rx_db_i[8] <= 'h0; // crc gen will not be implemented
    end

  endtask

  task capture_data();
        #1000ns;

        // Capture DMA data
        for (int i=0; i<NUMB_OF_CH; i=i+1) begin
          captured_word_arr[i] = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(xil_axi_uint'(`DDR_BA) + xil_axi_uint'(4*i));
        end

        // Read what the ADC interface actually output

        expected_adc_data[0] = `TH.axi_ad485x_adc_data_0;
        expected_adc_data[1] = `TH.axi_ad485x_adc_data_1;
        expected_adc_data[2] = `TH.axi_ad485x_adc_data_2;
        expected_adc_data[3] = `TH.axi_ad485x_adc_data_3;
        expected_adc_data[4] = `TH.axi_ad485x_adc_data_4;
        expected_adc_data[5] = `TH.axi_ad485x_adc_data_5;
        expected_adc_data[6] = `TH.axi_ad485x_adc_data_6;
        expected_adc_data[7] = `TH.axi_ad485x_adc_data_7;

        `INFO(("DMA captured: %x", captured_word_arr), ADI_VERBOSITY_LOW);
        `INFO(("ADC expected: %x", expected_adc_data), ADI_VERBOSITY_LOW);

        if (captured_word_arr != expected_adc_data) begin
          `ERROR(("DMA Test FAILED - Data mismatch between ADC and DMA"));
        end else begin
          `INFO(("DMA Test PASSED - ADC data correctly transferred"), ADI_VERBOSITY_LOW);
        end

        if (crc_en == 1) begin
          for (int i = 0; i < NUMB_OF_CH; i=i+1) begin
            axi_read(`AXI_AD485X_BA + i*'h40 + GetAddrs(ADC_CHANNEL_REG_CHAN_STATUS), crc_err);
            if (crc_err[12] == 1) begin
              crc_err_found = 1;
              break;
            end
          end

          if (crc_err_found == 1) begin
            `ERROR(("CRC check FAILED"));
          end else begin
            `INFO(("CRC check PASSED: %d", crc_err_found), ADI_VERBOSITY_LOW);
          end
        end
  endtask


// initial begin
//   forever begin
//       @(posedge `TH.adc_fast_clk) begin
//       if (`TH.axi_ad485x_adc_valid && `TH.axi_ad485x_adc_data_0 == rx_db_i[0] && testpattern_en == 0) begin
//           rx_db_i[0] <= rx_db_i[0] + 1;
//           rx_db_i[1] <= rx_db_i[1] + 1;
//           rx_db_i[2] <= rx_db_i[2] + 1;
//           rx_db_i[3] <= rx_db_i[3] + 1;
//           rx_db_i[4] <= rx_db_i[4] + 1;
//           rx_db_i[5] <= rx_db_i[5] + 1;
//           rx_db_i[6] <= rx_db_i[6] + 1;
//           rx_db_i[7] <= rx_db_i[7] + 1;
//         end else begin
//           rx_db_i[0] <= rx_db_i[0];
//           rx_db_i[1] <= rx_db_i[1];
//           rx_db_i[2] <= rx_db_i[2];
//           rx_db_i[3] <= rx_db_i[3];
//           rx_db_i[4] <= rx_db_i[4];
//           rx_db_i[5] <= rx_db_i[5];
//           rx_db_i[6] <= rx_db_i[6];
//           rx_db_i[7] <= rx_db_i[7];
//         end

//       if (busy_d & !busy) begin //negedge
//           db_i_index <= packet_sz-1;
//           ring_buffer_index <= 0;
//           db_i_shift <= db_i_shift;

//         end else if (scki_p_tp ^ scki_p_d) begin
//           db_i_index <= (db_i_index != 'd0) ? db_i_index - 1 : packet_sz-1;
//           ring_buffer_index <= (db_i_index == 'd0) ? ring_buffer_index +1 : (ring_buffer_index == MAXR_INDEX) ? 0 : ring_buffer_index;
//           db_i_shift <= rx_db_i[ch_index_lane][db_i_index];
//         end
//       end
//     end
//   end

//   assign ch_index_lane = (0 + ring_buffer_index) == MAXC_INDEX ? 0 : (0 + ring_buffer_index) > MAXC_INDEX ? (0 + ring_buffer_index) -8 : 0 + ring_buffer_index;

//   assign sdo_p_tp = db_i_shift;
//   assign sdo_n_tp = ~db_i_shift;

  // initial begin
  //   forever begin
  //   @(posedge `TH.adc_clk);
  //     if (busy_d & !busy) begin
  //       db_i_index <= packet_sz-1;
  //       ring_buffer_index <= 0;
  //       db_i_shift <= db_i_shift;
  //     end
  //   end
  // end

initial begin
    forever begin
      @(posedge `TH.adc_clk);

        // Update data when ADC valid changes
        if (`TH.axi_ad485x_adc_valid && `TH.axi_ad485x_adc_data_0 ==
  rx_db_i[0] && testpattern_en == 0) begin
          rx_db_i[0] <= rx_db_i[0] + 1;
          rx_db_i[1] <= rx_db_i[1] + 1;
          rx_db_i[2] <= rx_db_i[2] + 1;
          rx_db_i[3] <= rx_db_i[3] + 1;
          rx_db_i[4] <= rx_db_i[4] + 1;
          rx_db_i[5] <= rx_db_i[5] + 1;
          rx_db_i[6] <= rx_db_i[6] + 1;
          rx_db_i[7] <= rx_db_i[7] + 1;
        end

        // Reset counters on busy falling edge
        if (busy_d & !busy) begin
          db_i_index <= packet_sz-1;
          ring_buffer_index <= 0;
          db_i_shift <= db_i_shift;
        end
      end
    end

  // DDR data serialization - use SCKO both edges
  initial begin
    forever begin
      @(posedge `TH.adc_fast_clk, negedge `TH.adc_fast_clk);
        // if (busy_d & !busy) begin
        //   db_i_index <= packet_sz-1;
        //   ring_buffer_index <= 0;
        //   db_i_shift <= db_i_shift;
        // end else
        // begin  // Only during active conversion
          if (scki_p_tp ^ scki_p_d) begin
            db_i_index <= (db_i_index != 'd0) ? db_i_index - 1 : packet_sz-1;
            ring_buffer_index <= (db_i_index == 'd0) ? ring_buffer_index +1 : (ring_buffer_index == MAXR_INDEX) ? 0 : ring_buffer_index;
            db_i_shift <= rx_db_i[ch_index_lane][db_i_index];
          end

          // // Bounds checking to prevent crashes
          // if (ch_index_lane < NUMB_OF_CH && db_i_index < packet_sz) begin
          //   db_i_shift <= rx_db_i[ch_index_lane][db_i_index];

          //   // Update index safely
          //   if (db_i_index > 0) begin
          //     db_i_index <= db_i_index - 1;
          //   end else begin
          //     db_i_index <= packet_sz - 1;
          //     // Move to next channel
          //     if (ring_buffer_index < MAXR_INDEX) begin
          //       ring_buffer_index <= ring_buffer_index + 1;
          //     end else begin
          //       ring_buffer_index <= 0;
          //     end
          //   end
          // end else begin
          //   db_i_shift <= 1'b0;  // Default value
          // end

        //end
        // else begin
        //   // No data during idle
        //   sdo_p_tp <= 1'b0;
        //   sdo_n_tp <= 1'b1;
        // end
      end
    end

  assign ch_index_lane = (0 + ring_buffer_index) == MAXC_INDEX ? 0 : (0 + ring_buffer_index) > MAXC_INDEX ? (0 + ring_buffer_index) -8 : 0 + ring_buffer_index;
  assign sdo_p_tp = db_i_shift;
  assign sdo_n_tp = ~db_i_shift;


  //`TH.`SYS_CLK.inst.IF.clk
  initial begin
    forever begin
    @(posedge `TH.adc_clk);

      cnvs_d <= cnvs_tp;
      busy_d <= busy;

      if (~cnvs_d & cnvs_tp && busy == 0 || busy_os == 1) begin
        busy_counter <= 'd0;
        busy <= 1'b1;
      end
      else if (busy_counter == busy_period) begin
        busy_counter <= 'd0;
        busy <= busy_os;
      end
      else if (busy == 1'b1) begin
        busy_counter <= 1 + busy_counter;
        busy <= 1'b1;
      end

      if (oversampling == 1) begin
      if (oversampling_counter == 'd4) begin
        oversampling_counter <= 'd0;
        busy_os <= 1'b0;
      end else if (~cnvs_tp & cnvs_d && oversampling_counter < 'd4 && busy == 1'b1) begin
        oversampling_counter <= oversampling_counter +1;
        busy_os <= 1'b1;
      end
      end
    end
  end




  // initial begin
  //   forever begin
  //     @(posedge `TH.adc_fast_clk or negedge `TH.adc_fast_clk);
  //       scki_p_d <= scki_p_tp;
  //       scki_p_d2 <= scki_p_d;

  //       scki_n_d <= scki_n_tp;
  //       scki_n_d2 <= scki_n_d;
  //   end
  // end

  // assign scko_p_tp = scki_p_d2;
  // assign scko_n_tp = scki_n_d2;

  // Generate SCKO from SCKI with proper timing
  initial begin
    forever begin
      @(posedge `TH.adc_fast_clk, negedge `TH.adc_fast_clk);  // Single edge only
      scki_p_d <= scki_p_tp;
      scki_n_d <= scki_n_tp;
      scki_p_d2 <= scki_p_d;
      scki_n_d2 <= scki_n_d;
    end
  end

  // Simple delay for SCKO (represents ADC processing delay)
  assign scko_p_tp = scki_p_d;   // 2ns delay  #1.875
  assign scko_n_tp = scki_n_d;

  assign busy_tp = busy;

endprogram
