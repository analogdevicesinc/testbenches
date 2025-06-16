// ***************************************************************************
// ***************************************************************************
// Copyright 2024 - 2025 (c) Analog Devices, Inc. All rights reserved.
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
`include "axis_definitions.svh"

import logger_pkg::*;

import test_harness_env_pkg::*;
import spi_execution_environment_pkg::*;
import axi4stream_vip_pkg::*;
import spi_engine_api_pkg::*;
import pwm_gen_api_pkg::*;
import clk_gen_api_pkg::*;
import spi_engine_instr_pkg::*;
import adi_spi_vip_pkg::*;
import axi_vip_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, cmd_src)::*;
import `PKGIFY(test_harness, sdo_src)::*;
import `PKGIFY(test_harness, sdi_sink)::*;
import `PKGIFY(test_harness, sync_sink)::*;

program test_program (
  inout spi_execution_spi_sclk,
  inout [(`NUM_OF_CS - 1):0] spi_execution_spi_cs,
  inout spi_execution_spi_clk,
  inout spi_execution_trigger,
  `ifdef DEF_ECHO_SCLK
  inout spi_execution_echo_sclk,
  `endif
  inout [(`NUM_OF_SDI - 1):0] spi_execution_spi_sdi);

timeunit 1ns;
timeprecision 100ps;

spi_execution_environment #(
                            `AXIS_VIP_PARAMS(test_harness, cmd_src),
                            `AXIS_VIP_PARAMS(test_harness, sdo_src),
                            `AXIS_VIP_PARAMS(test_harness, sdi_sink),
                            `AXIS_VIP_PARAMS(test_harness, sync_sink)
                          ) spi_env;
test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
pwm_gen_api pwm_api;
clk_gen_api clkgen_api;

// --------------------------
// Wrapper function for SPI receive (from DUT)
// --------------------------
task spi_receive(
    output [`DATA_DLENGTH:0]  data);
  spi_env.spi_agent.sequencer.receive_data(data);
endtask

// --------------------------
// Wrapper function for SPI receive & verify (from DUT)
// --------------------------
task spi_receive_v(
    input [`DATA_DLENGTH:0]  data);
  spi_env.spi_agent.sequencer.receive_data_verify(data);
endtask


// --------------------------
// Wrapper function for SPI send (to DUT)
// --------------------------
task spi_send(
    input [`DATA_DLENGTH:0]  data);
  spi_env.spi_agent.sequencer.send_data(data);
endtask

// --------------------------
// Wrapper function for waiting for all SPI
// --------------------------
task spi_wait_send();
  spi_env.spi_agent.sequencer.flush_send();
endtask

// --------------------------
// Main procedure
// --------------------------
initial begin

  setLoggerVerbosity(ADI_VERBOSITY_NONE);

  //creating environment
  base_env = new("Base Environment",
                 `TH.`SYS_CLK.inst.IF,
                 `TH.`DMA_CLK.inst.IF,
                 `TH.`DDR_CLK.inst.IF,
                 `TH.`SYS_RST.inst.IF,
                 `TH.`MNG_AXI.inst.IF,
                 `TH.`DDR_AXI.inst.IF);

  spi_env = new( "SPI Execution Environment",
                `TH.`SPI_S.inst.IF.vif,
                `TH.`CMD_SRC.inst.IF,
                `TH.`SDO_SRC.inst.IF,
                `TH.`SDI_SINK.inst.IF,
                `TH.`SYNC_SINK.inst.IF);

  clkgen_api = new("CLKGEN API",
                   base_env.mng.sequencer,
                   `SPI_ENGINE_AXI_CLKGEN_BA);

  pwm_api = new("PWM API",
                base_env.mng.sequencer,
                `SPI_ENGINE_PWM_GEN_BA);

  base_env.start();
  spi_env.start();

  base_env.sys_reset();

  spi_env.configure();

  spi_env.run();

  spi_env.spi_agent.sequencer.set_default_miso_data('h2AA55);

  spi_env.cmd_src_agent.sequencer.start(); // start command source (will wait for data enqueued)
  spi_env.sdo_src_agent.sequencer.start();

  #100ns

  spi_execution_test();

  spi_env.stop();
  base_env.stop();

  `INFO(("Test Done"), ADI_VERBOSITY_NONE);

  $finish;

end


//---------------------------------------------------------------------------
// SPI Engine generate transfer
//---------------------------------------------------------------------------
task generate_transfer(
    input [7:0] sync_id);
  xil_axi4stream_data_byte cmd[1:0];
  `INFO(("Transfer generation waiting for trigger."), ADI_VERBOSITY_LOW);
  @(posedge spi_execution_trigger);
  // assert CS
  cmd[0] = (`SET_CS(8'hFE)) & 8'hFF;
  cmd[1] = ((`SET_CS(8'hFE)) & 16'hFF00) >> 8;
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[0]);
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[1]);
  // transfer data
  cmd[0] = (`INST_WRD) & 8'hFF;
  cmd[1] = ((`INST_WRD) & 16'hFF00) >> 8;
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[0]);
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[1]);
  // de-assert CS
  cmd[0] = (`SET_CS(8'hFF)) & 8'hFF;
  cmd[1] = ((`SET_CS(8'hFF)) & 16'hFF00) >> 8;
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[0]);
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[1]);
  // SYNC command 
  cmd[0] = (`INST_SYNC) & 8'hFF;
  cmd[1] = ((`INST_SYNC) & 16'hFF00) >> 8;
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[0]);
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[1]);
  // generate transfer descriptor
  spi_env.cmd_src_agent.sequencer.add_xfer_descriptor_byte_count(8,0,0);
  `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
endtask

//---------------------------------------------------------------------------
// SPI Engine configure 
//---------------------------------------------------------------------------
task configure_spi_execution();
  xil_axi4stream_data_byte cmd[1:0];
  bit [7:0] mask;
  // write cfg bits
  cmd[0] = (`INST_CFG) & 8'hFF;
  cmd[1] = ((`INST_CFG) & 16'hFF00) >> 8;
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[0]);
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[1]);
  // write prescaler value
  cmd[0] = (`INST_PRESCALE) & 8'hFF;
  cmd[1] = ((`INST_PRESCALE) & 16'hFF00) >> 8;
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[0]);
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[1]);
  // write data length
  cmd[0] = (`INST_DLENGTH) & 8'hFF;
  cmd[1] = ((`INST_DLENGTH) & 16'hFF00) >> 8;
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[0]);
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[1]);
  // write cs inv mask
  if (`CS_ACTIVE_HIGH) begin
    mask = 8'hFF;
  end else begin
    mask = 8'h00;
  end
  cmd[0] = (`SET_CS_INV_MASK(mask)) & 8'hFF;
  cmd[1] = ((`SET_CS_INV_MASK(mask)) & 16'hFF00) >> 8;
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[0]);
  spi_env.cmd_src_agent.sequencer.push_byte_for_stream(cmd[1]);
  // generate transfer descriptor
  spi_env.cmd_src_agent.sequencer.add_xfer_descriptor_byte_count(8,0,0);
endtask

//---------------------------------------------------------------------------
// SPI Engine SDO data
//---------------------------------------------------------------------------
task generate_sdo_data(
    output [`DATA_DLENGTH:0]  rand_data);
  xil_axi4stream_data_byte data[(`DATA_WIDTH/8)-1:0];
  rand_data = $urandom;
  for (int i = 0; i<(`DATA_WIDTH/8);i++) begin
    data[i] = (rand_data & (8'hFF << 8*i)) >> 8*i;
    spi_env.sdo_src_agent.sequencer.push_byte_for_stream(data[i]);
  end
  spi_env.sdo_src_agent.sequencer.add_xfer_descriptor_byte_count((`DATA_WIDTH/8),0,0);
endtask

//---------------------------------------------------------------------------
// Echo SCLK generation - we need this only if ECHO_SCLK is enabled
//---------------------------------------------------------------------------
`ifdef DEF_ECHO_SCLK
  assign #(`ECHO_SCLK_DELAY * 1ns) spi_execution_echo_sclk = spi_execution_spi_sclk;
`endif


//---------------------------------------------------------------------------
// SPI Execution Test
//---------------------------------------------------------------------------

bit   [`DATA_DLENGTH-1:0]  sdi_read_data [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)-1:0]= '{default:'0};
bit   [`DATA_DLENGTH-1:0]  sdi_read_data_store [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)-1:0];
bit   [`DATA_DLENGTH-1:0]  sdo_write_data [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)-1:0]= '{default:'0};
bit   [`DATA_DLENGTH-1:0]  sdo_write_data_store [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)-1:0];
bit [`DATA_DLENGTH-1:0] rx_data;
bit [`DATA_DLENGTH-1:0] tx_data;
bit [`DATA_DLENGTH-1:0] temp_data;
bit [7:0] data_byte;
bit [`DATA_WIDTH:0] data;

task spi_execution_test();
  // Start spi clk generator
  clkgen_api.enable_clkgen();

  // Config pwm
  pwm_api.reset();
  pwm_api.pulse_period_config(0,'d1000); // config channel 0 period

  // Configure the spi engine execution module
  configure_spi_execution();

  // Enqueue transfer to DUT
  for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
    rx_data = $urandom;
    spi_send(rx_data);
    sdi_read_data_store[i] = rx_data;
    generate_sdo_data(tx_data);
    sdo_write_data_store[i] = tx_data;
  end

  pwm_api.load_config();
  pwm_api.start();
  `INFO(("axi_pwm_gen started."), ADI_VERBOSITY_LOW);

  for (int i = 0; i<(`NUM_OF_TRANSFERS) ; i=i+1) begin
    generate_transfer(i);
    //#100
  end

  `INFO(("Waiting for SPI VIP send..."), ADI_VERBOSITY_LOW);
  spi_wait_send();
  `INFO(("SPI sent"), ADI_VERBOSITY_LOW);

  for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
    spi_env.sdi_sink_agent.sequencer.get_transfer();
    for (int b =0; b<((`DATA_WIDTH+7)/8);b++) begin
      spi_env.sdi_sink_agent.sequencer.get_byte(data_byte);
      data[8*b+:8] = data_byte;
    end
    sdi_read_data[i] = data[`DATA_DLENGTH-1:0];
    if (sdi_read_data_store[i] !== sdi_read_data[i]) begin
      `INFO(("sdi_read_data[i]: %x; sdi_read_data_store[i]: %x", sdi_read_data[i], sdi_read_data_store[i]), ADI_VERBOSITY_LOW);
      `ERROR(("SPI Execution Read Test FAILED"));
    end
  end
  `INFO(("SPI Execution Read Test PASSED"), ADI_VERBOSITY_LOW);

  for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
    spi_receive(sdo_write_data[i]);
    if (sdo_write_data_store[i] !== sdo_write_data[i]) begin
      `INFO(("sdo_write_data[i]: %x; sdo_write_data_store[i]: %x", sdo_write_data[i], sdo_write_data_store[i]), ADI_VERBOSITY_LOW);
      `ERROR(("SPI Execution Write Test FAILED"));
    end
  end
  `INFO(("SPI Execution Write Test PASSED"), ADI_VERBOSITY_LOW);

  #200ns

  `INFO(("SPI Execution Test PASSED"), ADI_VERBOSITY_LOW);
endtask

endprogram
