// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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
import logger_pkg::*;
import test_harness_env_pkg::*;
import dmac_api_pkg::*;
import adc_api_pkg::*;
import pwm_gen_api_pkg::*;
import common_api_pkg::*;
import cn0577_environment_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

localparam NUM_OF_TRANSFERS = 16;

//---------------------------------------------------------------------------
// SPI Engine configuration parameters
//---------------------------------------------------------------------------

program test_program (
  input           ref_clk,
  input           clk_gate,
  input           dco_in,
  output          da_n,
  output          da_p,
  output          db_n,
  output          db_p,
  output reg      dco_p,
  output reg      dco_n,
  input           cnv);

timeunit 1ns;
timeprecision 1ps;

typedef enum {DATA_MODE_RANDOM, DATA_MODE_RAMP, DATA_MODE_PATTERN} offload_test_t;

test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

// set to active debug messages
localparam bit DEBUG = 1;

// dco delay compared to the reference clk
localparam DCO_DELAY = 12;

dmac_api cn0577_dmac_api;
pwm_gen_api cn0577_pwm_gen_api;
adc_api ltc2387_adc_api;
common_api ltc2387_common_api;

// dma interface
wire                     adc_valid;
wire  [`ADC_RES-1:0]     adc_data;
reg                      adc_dovf = 1'b0;

// --------------------------
// Main procedure
// --------------------------

initial begin

  //creating environment
  base_env = new("Base Environment",
                  `TH.`SYS_CLK.inst.IF,
                  `TH.`DMA_CLK.inst.IF,
                  `TH.`DDR_CLK.inst.IF,
                  `TH.`SYS_RST.inst.IF,
                  `TH.`MNG_AXI.inst.IF,
                  `TH.`DDR_AXI.inst.IF);
  cn0577_dmac_api = new(
      "CN0577 DMAC API",
      base_env.mng.sequencer,
      `AXI_LTC2387_DMA_BA);

  cn0577_pwm_gen_api = new(
      "CN0577 AXI PWM GEN API",
      base_env.mng.sequencer,
      `AXI_PWM_GEN_BA);

  ltc2387_adc_api = new(
      "LTC2387 ADC Common API",
      base_env.mng.sequencer,
      `AXI_LTC2387_BA);

  ltc2387_common_api = new(
      "LTC2387 Common API",
      base_env.mng.sequencer,
      `AXI_LTC2387_BA);

  base_env.start();
  base_env.sys_reset();

  sanity_tests();

  #100ns;

  data_acquisition_test();

  base_env.stop();

  `INFO(("Test Done"), ADI_VERBOSITY_NONE);
  $finish();

end

bit [31:0]  dma_data_store_arr [(NUM_OF_TRANSFERS) - 1:0];
bit transfer_status = 0;
bit [31:0] transfer_cnt;

//---------------------------------------------------------------------------
// Transfer Counter
//---------------------------------------------------------------------------

initial begin
  transfer_cnt = 0;
  forever begin
    @(posedge cnv);
     if (transfer_status) begin
      transfer_cnt = transfer_cnt + 1;
    end
    @(negedge cnv);
  end
end

//---------------------------------------------------------------------------
// Clk_gate shifted copy
//---------------------------------------------------------------------------

localparam int N = (`TWOLANES == 0 && `ADC_RES == 16) ? 16 :
                   (`TWOLANES == 0 && `ADC_RES == 18) ? 18 :
                   (`TWOLANES == 1 && `ADC_RES == 16) ? 8 :
                   (`TWOLANES == 1 && `ADC_RES == 18) ? 10 :
                   -1; // Error case
parameter int num_of_dco = N / 2;

initial begin
  forever begin
    @(posedge dco_in, negedge dco_in) begin
      #1
      dco_p <= dco_in;
      dco_n <= ~dco_in;
    end
  end
 end

//---------------------------------------------------------------------------
// Data store
//---------------------------------------------------------------------------

reg   [`ADC_RES-1:0]  data_gen = 'h3a5a5;
reg   [`ADC_RES-1:0]  data_shift = 'h0;

reg                     r_da_p = 1'b0;
reg                     r_da_n = 1'b0;
reg                     r_db_p = 1'b0;
reg                     r_db_n = 1'b0;

assign da_p = r_da_p;
assign da_n = r_da_n;
assign db_p = r_db_p;
assign db_n = r_db_n;

// ---------------------------------------------------------------------------
// Output data ready
// ---------------------------------------------------------------------------

initial begin
  forever begin
    @ (posedge dco_in, negedge dco_in) begin
      if (`TWOLANES == 1) begin
        r_da_p = data_shift[`ADC_RES - 1];
        r_da_n = ~data_shift[`ADC_RES - 1];
        r_db_p = data_shift[`ADC_RES - 2];
        r_db_n = ~data_shift[`ADC_RES - 2];
        data_shift = data_shift << 2;
      end else begin
        r_da_p = data_shift[`ADC_RES - 1];
        r_da_n = ~data_shift[`ADC_RES - 1];
        data_shift = data_shift << 1;
      end
    end
  end
end

initial begin
  forever begin
    @ (posedge cnv) begin
      data_shift = data_gen;
    end
  end
end

// ---------------------------------------------------------------------------
// Generating expected data
// ---------------------------------------------------------------------------

initial begin
  forever begin
    @(posedge dco_in);
    if (transfer_status) begin
      if (`ADC_RES == 16) begin
        if (`TWOLANES == 0) begin
          if (transfer_cnt[0]) begin
            dma_data_store_arr[(transfer_cnt - 1) >> 1][15:0] = data_gen;
          end else begin
            dma_data_store_arr[(transfer_cnt - 1) >> 1][31:16] = data_gen;
          end
        end else begin
          if (transfer_cnt[0]) begin
            dma_data_store_arr[(transfer_cnt - 1) >> 1][15:0] = data_gen;
          end else begin
            dma_data_store_arr[(transfer_cnt - 1) >> 1][31:16] = data_gen;
          end
        end
      end else if (`ADC_RES == 18) begin
        if (`TWOLANES == 0) begin
          dma_data_store_arr[(transfer_cnt - 1) >> 1] = data_gen;
        end else begin
          dma_data_store_arr[(transfer_cnt - 1) >> 1] = data_gen;
        end
      end
    end
    @(negedge dco_in);
  end
end

//---------------------------------------------------------------------------
// Sanity tests
//---------------------------------------------------------------------------

task sanity_tests();
    ltc2387_common_api.sanity_test();
    cn0577_dmac_api.sanity_test();
    cn0577_pwm_gen_api.sanity_test();
    `INFO(("Sanity Tests Done"), ADI_VERBOSITY_LOW);
endtask

//---------------------------------------------------------------------------
// Data Acquisition Test
//---------------------------------------------------------------------------

reg [31:0] rdata_reg;
bit [31:0] captured_word_arr [(NUM_OF_TRANSFERS) -1 :0];
bit [31:0] config_wr_SIMPLE = 'h0; // write request sent result
bit [31:0] config_SIMPLE = 'h0; // channel static data setup

task data_acquisition_test();

    // Enable all ADC channels
    for (int i = 0; i < 4; i=i+1) begin
        ltc2387_adc_api.enable_channel(
          .channel(i));
    end

    // Configure AXI PWM GEN
    cn0577_pwm_gen_api.reset(); // PWM_GEN reset in regmap (ACTIVE HIGH)

    cn0577_pwm_gen_api.pulse_period_config(
      .channel(8'h00),
      .period(32'h1A));

    cn0577_pwm_gen_api.pulse_width_config(
      .channel(8'h00),
      .width(32'h01));

    cn0577_pwm_gen_api.pulse_period_config(
      .channel(8'h01),
      .period(32'h1A));

    cn0577_pwm_gen_api.pulse_width_config(
      .channel(8'h01),
      .width(num_of_dco));

    cn0577_pwm_gen_api.pulse_offset_config(
      .channel(8'h01),
      .offset(32'h03));

    cn0577_pwm_gen_api.load_config(); // load AXI_PWM_GEN configuration
    cn0577_pwm_gen_api.start();
    `INFO(("AXI_PWM_GEN started"), ADI_VERBOSITY_LOW);

    // Configure DMA
    cn0577_dmac_api.set_irq_mask(
      .transfer_completed(1'b0),
      .transfer_queued(1'b1));
    cn0577_dmac_api.enable_dma();
    cn0577_dmac_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    cn0577_dmac_api.set_lengths(
      .xfer_length_x((NUM_OF_TRANSFERS*4)-1),
      .xfer_length_y(32'h0));
    cn0577_dmac_api.set_dest_addr(`DDR_BA);

    // Configure AXI_LTC2387
    ltc2387_adc_api.reset(
      .ce_n(0),
      .mmcm_rstn(0),
      .rstn(0));

    #5000ns;

    ltc2387_adc_api.reset(
      .ce_n(0),
      .mmcm_rstn(1),
      .rstn(1));

    @(posedge cnv)
    #200ns;

    transfer_status = 1;

    cn0577_dmac_api.transfer_start();

    wait(transfer_cnt == 2 * NUM_OF_TRANSFERS );

    #100ns;
    @(negedge cnv);
    @(posedge ref_clk);
    transfer_status = 0;

    //@(posedge system_tb.test_harness.axi_ltc2387_dma.irq);

    // Clear interrupt
    cn0577_dmac_api.clear_irq_pending(
      .transfer_completed(1'b1),
      .transfer_queued(1'b0));

    // Stop pwm gen
    cn0577_pwm_gen_api.reset();
    `INFO(("AXI_PWM_GEN stopped"), ADI_VERBOSITY_LOW);

    // Configure axi_ltc2387
    ltc2387_adc_api.reset(
      .ce_n(0),
      .mmcm_rstn(1),
      .rstn(1)); // bring out of reset

    ltc2387_adc_api.set_adc_config_wr(
      .cfg(32'h00002181)); // set static data setup in device's reg 0x21

    ltc2387_adc_api.get_adc_config_wr(
      .cfg(config_SIMPLE)); // read last config result
    `INFO(("Config_SIMPLE is set up, ADC_CONFIG_WR contains 0x%h",config_SIMPLE), ADI_VERBOSITY_LOW);

    ltc2387_adc_api.set_adc_config_control(
      .cfg(32'h00000001)); // send WR request

    ltc2387_adc_api.set_adc_config_control(
      .cfg(config_wr_SIMPLE)); // read last config result
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE), ADI_VERBOSITY_LOW);

    ltc2387_adc_api.set_adc_config_control(
      .cfg(32'h00000000)); // set default control value (no rd/wr request)

    ltc2387_adc_api.set_adc_config_control(
      .cfg(config_wr_SIMPLE)); // read last config result
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE), ADI_VERBOSITY_LOW);

    ltc2387_adc_api.set_adc_config_wr(
      .cfg(32'h00000000)); // set exit from register mode sequence

    ltc2387_adc_api.set_adc_config_control(
      .cfg(32'h00000001)); // send WR request

    ltc2387_adc_api.set_adc_config_control(
      .cfg(32'h00000000)); // set default control value (no rd/wr request)

    //set HDL config mode
    ltc2387_adc_api.set_common_control_3(
      .crc_en(0),
      .custom_control('h100)); // set default

    #2000ns;
    for (int i=0; i<=((NUM_OF_TRANSFERS) -1); i=i+1) begin
    #1ns;
      captured_word_arr[i] = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(xil_axi_uint'(`DDR_BA + 4*i));
    end

    `INFO(("captured_word_arr: %x; dma_data_store_arr %x", captured_word_arr, dma_data_store_arr), ADI_VERBOSITY_LOW);

    if (captured_word_arr != dma_data_store_arr) begin
      `ERROR(("Data Acquisition Test FAILED"));
    end else begin
      `INFO(("Data Acquisition Test PASSED"), ADI_VERBOSITY_LOW);
    end

endtask

endprogram
