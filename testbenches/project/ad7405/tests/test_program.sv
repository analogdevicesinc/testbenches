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
import adi_regmap_adc_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_dmac_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;

localparam DATA_WIDTH                 = 16;
localparam DATA_DLENGTH               = 16;
localparam NUM_OF_WORDS               = 1;
localparam NUM_OF_TRANSFERS           = 10;
localparam AD7405_CTRL_RESETN         = 1;

program test_program (
    input         ad7405_adc_clk,
    output        ad7405_adc_data,
    output [15:0] ad7405_filter_dec_ratio);


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

  //#100

  data_acquisition_test();

  `INFO(("Test Done"));

  $finish;

end

//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test();
  axi_write (`AXI_AD7405_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
  axi_read_v (`AXI_AD7405_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
  `INFO(("Sanity Test Done"));
endtask

//---------------------------------------------------------------------------
// Data generator
//---------------------------------------------------------------------------

reg [15:0] sample = 0;
reg [15:0] counter = 0;
reg [15:0] sdi_shiftreg;
reg        div_clk;
reg        div_clk_s;

assign ad7405_adc_data = sdi_shiftreg[15];

initial begin
  while(1) begin
    @(posedge div_clk_s)
    sample <= sample + 1'h1;
  end
end

initial begin
  while(1) begin
    @(posedge ad7405_adc_clk);
    counter <= counter + 1;
  end
end

initial begin
  while(1) begin
    @(posedge ad7405_adc_clk);
    if (div_clk == 1)
        sdi_shiftreg <= sample;
    else
        sdi_shiftreg <= {sdi_shiftreg[14:0], 1'b0};
    end
end

initial begin
  while (1) begin
    @(posedge ad7405_adc_clk);
      div_clk_s <= counter[3];
      div_clk <= (counter[3] && !div_clk_s);
  end
end

//---------------------------------------------------------------------------
// Storing Data for later comparison
//---------------------------------------------------------------------------

bit         offload_status = 0;
bit         shiftreg_sampled = 0;
bit [15:0]  sdi_store_cnt = 'h0;
bit [31:0]  offload_sdi_data_store_arr [(NUM_OF_TRANSFERS) - 1:0];
bit [DATA_DLENGTH-1:0]  sdi_data_store;

initial begin
  while (1) begin
    @(posedge ad7405_adc_clk);
    sdi_data_store <= {sdi_shiftreg[27:0], 4'b0};
    if (sdi_data_store == 'h0 && shiftreg_sampled == 'h1 && sdi_shiftreg != 'h0) begin
      shiftreg_sampled <= 'h0;
      if (offload_status) begin
        sdi_store_cnt <= sdi_store_cnt + 1;
      end
    end else if (shiftreg_sampled == 'h0 && sdi_data_store != 'h0) begin
        if (offload_status) begin
          offload_sdi_data_store_arr [sdi_store_cnt] = sdi_shiftreg;
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
// Data Acquisition Test
//---------------------------------------------------------------------------

bit [31:0] offload_captured_word_arr [(NUM_OF_TRANSFERS) -1 :0];
reg [15:0] set_dec_rate = 16'h20;
assign ad7405_filter_dec_ratio = set_dec_rate;

task data_acquisition_test();

    // Configure DMA
    env.mng.RegWrite32(`AD7405_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    env.mng.RegWrite32(`AD7405_DMA_BA + GetAddrs(DMAC_FLAGS),
      `SET_DMAC_FLAGS_TLAST(1) |
      `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
      ); // Use TLAST
    env.mng.RegWrite32(`AD7405_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH((NUM_OF_TRANSFERS*4)-1)); // X_LENGHTH
    env.mng.RegWrite32(`AD7405_DMA_BA + GetAddrs(DMAC_DEST_ADDRESS), `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA));  // DEST_ADDRESS
    env.mng.RegWrite32(`AD7405_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer DMA

    // Start axi clk generator
    axi_write (`AD7405_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
      `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
      `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
      );

    offload_status = 1;

    // Configure AXI_AD7405
    axi_write (`AXI_AD7405_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    #1000
    axi_write (`AXI_AD7405_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(AD7405_CTRL_RESETN));
    axi_write (`AXI_AD7405_BA + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL), `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));

    wait(offload_transfer_cnt == NUM_OF_TRANSFERS);

    offload_status = 0;

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

endprogram
