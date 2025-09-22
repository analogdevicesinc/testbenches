// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2025-2026 Analog Devices, Inc. All rights reserved.
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

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

localparam NUM_OF_TRANSFERS = 16;

program test_program (
  input           ref_clk_out,
  input           clk_gate,
  output          da_n,
  output          da_p,
  output          db_n,
  output          db_p,
  output reg      dco_p,
  output reg      dco_n,
  input           cnv);

timeunit 1ns;
timeprecision 1ps;

test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

dmac_api dmac_api_inst;
pwm_gen_api pwm_gen_api_inst;
adc_api ltc2387_adc_api;
common_api ltc2387_common_api;

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
    .mng_vip_if(`TH.`MNG_AXI.inst.IF),
    .ddr_vip_if(`TH.`DDR_AXI.inst.IF));

  dmac_api_inst = new(
    .name("CN0577 DMAC API"),
    .bus(base_env.mng.sequencer),
    .base_address(`AXI_LTC2387_DMA_BA));

  pwm_gen_api_inst = new(
    .name("CN0577 AXI PWM GEN API"),
    .bus(base_env.mng.sequencer),
    .base_address(`AXI_PWM_GEN_BA));

  ltc2387_adc_api = new(
    .name("LTC2387 ADC Common API"),
    .bus(base_env.mng.sequencer),
    .base_address(`AXI_LTC2387_BA));

  ltc2387_common_api = new(
    .name("LTC2387 Common API"),
    .bus(base_env.mng.sequencer),
    .base_address(`AXI_LTC2387_BA));

  setLoggerVerbosity(ADI_VERBOSITY_NONE);

  base_env.start();

  `TH.`REF_CLK.inst.IF.start_clock();

  base_env.sys_reset();

  sanity_tests();

  data_acquisition_test();

  base_env.stop();

  `TH.`REF_CLK.inst.IF.stop_clock();

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

// dco delay compared to the reference clk, expressed in ns
localparam DCO_DELAY = 4;

// ---------------------------------------------------------------------------
// Creating a "gate" through which the data clock can run (and only then)
// ---------------------------------------------------------------------------

reg dco_init;

initial begin
  dco_init = 1'b0;
  forever begin
    @(posedge ref_clk_out, negedge ref_clk_out) begin
      dco_init = clk_gate ? ref_clk_out : 1'b0;
    end
  end
end

// ---------------------------------------------------------------------------
// Data clocks generation
// ---------------------------------------------------------------------------

initial begin
  dco_p = 1'b0;
  dco_n = 1'b1;
  forever begin
    @(posedge dco_init) begin
      dco_p <= #(DCO_DELAY * 1ns) dco_init;
      dco_n <= #(DCO_DELAY * 1ns) ~dco_init;
    end
    @(negedge dco_init) begin
      dco_p <= #(DCO_DELAY * 1ns) dco_init;
      dco_n <= #(DCO_DELAY * 1ns) ~dco_init;
    end
  end
end

//---------------------------------------------------------------------------
// Data store
//---------------------------------------------------------------------------

reg   [`ADC_RES-1:0]  data_gen = 'h3a5c2;
reg   [`ADC_RES-1:0]  data_shift = 'h0;
reg                   r_da_p;
reg                   r_da_n;
reg                   r_db_p;
reg                   r_db_n;

assign da_p = r_da_p;
assign da_n = r_da_n;
assign db_p = r_db_p;
assign db_n = r_db_n;

// ---------------------------------------------------------------------------
// Output data ready
// ---------------------------------------------------------------------------

initial begin
  forever begin
    @(posedge dco_init, negedge dco_init) begin
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
    @(negedge clk_gate) begin
      r_da_p = 1'b0;
      r_da_n = 1'b0;
      r_db_p = 1'b0;
      r_db_n = 1'b0;
    end
  end
end

initial begin
  forever begin
    @(posedge cnv) begin
      data_shift = data_gen;
      data_gen = $urandom;
    end
  end
end

// ---------------------------------------------------------------------------
// Generating expected data
// ---------------------------------------------------------------------------

initial begin
  forever begin
    @(posedge cnv);
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
          dma_data_store_arr[(transfer_cnt - 1)] = data_gen;
        end else begin
          dma_data_store_arr[(transfer_cnt - 1)] = data_gen;
        end
      end
    end
    @(negedge dco_init);
  end
end

//---------------------------------------------------------------------------
// Sanity tests
//---------------------------------------------------------------------------

task sanity_tests();
  //ltc2387_common_api.sanity_test();
  dmac_api_inst.sanity_test();
  pwm_gen_api_inst.sanity_test();
  `INFO(("Sanity Tests Done"), ADI_VERBOSITY_LOW);
endtask

//---------------------------------------------------------------------------
// Data Acquisition Test
//---------------------------------------------------------------------------

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
  pwm_gen_api_inst.reset(); // PWM_GEN reset in regmap (ACTIVE HIGH)

  pwm_gen_api_inst.pulse_period_config(
    .channel(8'd0),
    .period(32'd26));

  pwm_gen_api_inst.pulse_width_config(
    .channel(8'd0),
    .width(32'd1));

  pwm_gen_api_inst.pulse_period_config(
    .channel(8'd1),
    .period(32'd26));

  pwm_gen_api_inst.pulse_width_config(
    .channel(8'd1),
    .width(num_of_dco));

  pwm_gen_api_inst.pulse_offset_config(
    .channel(8'd1),
    .offset(32'd3));

  pwm_gen_api_inst.load_config(); // load AXI_PWM_GEN configuration

  pwm_gen_api_inst.start();
  `INFO(("AXI_PWM_GEN started"), ADI_VERBOSITY_LOW);

  // Configure DMA
  dmac_api_inst.set_irq_mask(
    .transfer_completed(1'b0),
    .transfer_queued(1'b1));

  dmac_api_inst.enable_dma();

  dmac_api_inst.set_flags(
    .cyclic(1'b0),
    .tlast(1'b1),
    .partial_reporting_en(1'b1));

  dmac_api_inst.set_lengths(
    .xfer_length_x((NUM_OF_TRANSFERS*4)-1),
    .xfer_length_y(32'h0));

  dmac_api_inst.set_dest_addr(`DDR_BA);

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

  dmac_api_inst.transfer_start();

  wait(transfer_cnt == 2 * NUM_OF_TRANSFERS );

  #100ns;
  @(negedge cnv);
  @(posedge ref_clk_out);
  transfer_status = 0;

  // Clear interrupt
  dmac_api_inst.clear_irq_pending(
    .transfer_completed(1'b1),
    .transfer_queued(1'b0));

  // Stop AXI PWM GEN

  pwm_gen_api_inst.pulse_width_config(
    .channel(8'd0),
    .width(32'd0));

  pwm_gen_api_inst.load_config(); // load AXI_PWM_GEN configuration

  // Stop pwm gen
  pwm_gen_api_inst.reset();
  `INFO(("AXI_PWM_GEN stopped"), ADI_VERBOSITY_LOW);

  // Configure axi_ltc2387
  ltc2387_adc_api.reset(
    .ce_n(1'b0),
    .mmcm_rstn(1'b1),
    .rstn(1'b1)); // bring out of reset

  ltc2387_adc_api.set_adc_config_wr(
    .cfg(32'h00002181)); // set static data setup in device's reg 0x21

  ltc2387_adc_api.get_adc_config_wr(
    .cfg(config_SIMPLE)); // read last config result
  `INFO(("Config_SIMPLE is set up, ADC_CONFIG_WR contains 0x%h",config_SIMPLE), ADI_VERBOSITY_LOW);

  ltc2387_adc_api.set_adc_config_control(
    .cfg(32'h00000001)); // send WR request

  ltc2387_adc_api.get_adc_config_control(
    .cfg(config_wr_SIMPLE)); // read last config result
  `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE), ADI_VERBOSITY_LOW);

  ltc2387_adc_api.set_adc_config_control(
    .cfg(32'h00000000)); // set default control value (no rd/wr request)

  ltc2387_adc_api.get_adc_config_control(
    .cfg(config_wr_SIMPLE)); // read last config result
  `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE), ADI_VERBOSITY_LOW);

  ltc2387_adc_api.set_adc_config_wr(
    .cfg(32'h00000000)); // set exit from register mode sequence

  ltc2387_adc_api.set_adc_config_control(
    .cfg(32'h00000001)); // send WR request

  ltc2387_adc_api.set_adc_config_control(
    .cfg(32'h00000000)); // set default control value (no rd/wr request)

  // Set HDL config mode
  ltc2387_adc_api.set_common_control_3(
    .crc_en(0),
    .custom_control('h100)); // set default

   #2000ns;

  for (int i=0; i<=((NUM_OF_TRANSFERS) -1); i=i+1) begin
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
