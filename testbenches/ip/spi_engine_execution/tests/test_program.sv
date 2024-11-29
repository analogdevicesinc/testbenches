// ***************************************************************************
// ***************************************************************************
// Copyright 2021 - 2024 (c) Analog Devices, Inc. All rights reserved.
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
import m_axis_sequencer_pkg::*;
import s_axis_sequencer_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_pwm_gen_pkg::*;
import adi_regmap_spi_engine_pkg::*;
import logger_pkg::*;
import spi_execution_environment_pkg::*;
import spi_engine_instr_pkg::*;
import adi_spi_vip_pkg::*;


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

spi_execution_environment env;

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
// Wrapper function for SPI receive (from DUT)
// --------------------------
task spi_receive(
    output [`DATA_DLENGTH:0]  data);
  env.spi_seq.receive_data(data);
endtask

// --------------------------
// Wrapper function for SPI receive & verify (from DUT)
// --------------------------
task spi_receive_v(
    input [`DATA_DLENGTH:0]  data);
  env.spi_seq.receive_data_verify(data);
endtask


// --------------------------
// Wrapper function for SPI send (to DUT)
// --------------------------
task spi_send(
    input [`DATA_DLENGTH:0]  data);
  env.spi_seq.send_data(data);
endtask

// --------------------------
// Wrapper function for waiting for all SPI
// --------------------------
task spi_wait_send();
  env.spi_seq.flush_send();
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
            `TH.`DDR_AXI.inst.IF,
            `TH.`CMD_SRC.inst.IF,
            `TH.`SDO_SRC.inst.IF,
            `TH.`SDI_SINK.inst.IF,
            `TH.`SYNC_SINK.inst.IF,
            `TH.`SPI_S.inst.IF
            );

  setLoggerVerbosity(6);
  `INFO(("Test Start"));
  env.start();

  env.configure();

  env.sys_reset();

  env.run();

  env.spi_seq.set_default_miso_data('h2AA55);

  env.cmd_src_seq.start(); // start command source (will wait for data enqueued)
  env.sdo_src_seq.start();

  #100ns

  spi_execution_test();

  `INFO(("Test Done"));

  $finish;

end


//---------------------------------------------------------------------------
// SPI Engine generate transfer
//---------------------------------------------------------------------------
task generate_transfer(
    input [7:0] sync_id);
  xil_axi4stream_data_byte cmd[1:0];
  `INFOV(("Transfer generation waiting for trigger."), 6);
  @(posedge spi_execution_trigger);
  // assert CS
  cmd[0] = (`SET_CS(8'hFE)) & 8'hFF;
  cmd[1] = ((`SET_CS(8'hFE)) & 16'hFF00) >> 8;
  env.cmd_src_seq.push_byte_for_stream(cmd[0]);
  env.cmd_src_seq.push_byte_for_stream(cmd[1]);
  // transfer data
  cmd[0] = (`INST_WRD) & 8'hFF;
  cmd[1] = ((`INST_WRD) & 16'hFF00) >> 8;
  env.cmd_src_seq.push_byte_for_stream(cmd[0]);
  env.cmd_src_seq.push_byte_for_stream(cmd[1]);
  // de-assert CS
  cmd[0] = (`SET_CS(8'hFF)) & 8'hFF;
  cmd[1] = ((`SET_CS(8'hFF)) & 16'hFF00) >> 8;
  env.cmd_src_seq.push_byte_for_stream(cmd[0]);
  env.cmd_src_seq.push_byte_for_stream(cmd[1]);
  // SYNC command 
  cmd[0] = (`INST_SYNC) & 8'hFF;
  cmd[1] = ((`INST_SYNC) & 16'hFF00) >> 8;
  env.cmd_src_seq.push_byte_for_stream(cmd[0]);
  env.cmd_src_seq.push_byte_for_stream(cmd[1]);
  // generate transfer descriptor
  env.cmd_src_seq.add_xfer_descriptor(8,0,0);
  `INFOV(("Transfer generation finished."), 6);
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
  env.cmd_src_seq.push_byte_for_stream(cmd[0]);
  env.cmd_src_seq.push_byte_for_stream(cmd[1]);
  // write prescaler value
  cmd[0] = (`INST_PRESCALE) & 8'hFF;
  cmd[1] = ((`INST_PRESCALE) & 16'hFF00) >> 8;
  env.cmd_src_seq.push_byte_for_stream(cmd[0]);
  env.cmd_src_seq.push_byte_for_stream(cmd[1]);
  // write data length
  cmd[0] = (`INST_DLENGTH) & 8'hFF;
  cmd[1] = ((`INST_DLENGTH) & 16'hFF00) >> 8;
  env.cmd_src_seq.push_byte_for_stream(cmd[0]);
  env.cmd_src_seq.push_byte_for_stream(cmd[1]);
  // write cs inv mask
  if (`CS_ACTIVE_HIGH) begin
    mask = 8'hFF;
  end else begin
    mask = 8'h00;
  end
  cmd[0] = (`SET_CS_INV_MASK(mask)) & 8'hFF;
  cmd[1] = ((`SET_CS_INV_MASK(mask)) & 16'hFF00) >> 8;
  env.cmd_src_seq.push_byte_for_stream(cmd[0]);
  env.cmd_src_seq.push_byte_for_stream(cmd[1]);
  // generate transfer descriptor
  env.cmd_src_seq.add_xfer_descriptor(8,0,0);
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
    env.sdo_src_seq.push_byte_for_stream(data[i]);
  end
  env.sdo_src_seq.add_xfer_descriptor((`DATA_WIDTH/8),0,0);
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
  axi_write (`SPI_ENGINE_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
    `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
    `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
    );

  // Config pwm
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('d1000)); // set PWM period

   // Configure the execution module
  configure_spi_execution();

  // Enqueue transfer to DUT
  for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
    rx_data = $urandom;
    spi_send(rx_data);
    sdi_read_data_store[i] = rx_data;
    generate_sdo_data(tx_data);
    sdo_write_data_store[i] = tx_data;
  end

  axi_write (`SPI_ENGINE_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
  `INFOV(("axi_pwm_gen started."),6);

  for (int i = 0; i<(`NUM_OF_TRANSFERS) ; i=i+1) begin
    generate_transfer(i);
    //#100
  end

  spi_wait_send();

  for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
    env.sdi_sink_seq.get_transfer();
    for (int b =0; b<((`DATA_WIDTH+7)/8);b++) begin
      env.sdi_sink_seq.get_byte(data_byte);
      data[8*b+:8] = data_byte;
    end
    sdi_read_data[i] = data[`DATA_DLENGTH-1:0];
    if (sdi_read_data_store[i] !== sdi_read_data[i]) begin
      `INFOV(("sdi_read_data[i]: %x; sdi_read_data_store[i]: %x", sdi_read_data[i], sdi_read_data_store[i]),6);
      `ERROR(("SPI Execution Read Test FAILED"));
    end
  end
  `INFO(("SPI Execution Read Test PASSED"));

  for (int i = 0; i<((`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS)) ; i=i+1) begin
    spi_receive(sdo_write_data[i]);
    if (sdo_write_data_store[i] !== sdo_write_data[i]) begin
      `INFOV(("sdo_write_data[i]: %x; sdo_write_data_store[i]: %x", sdo_write_data[i], sdo_write_data_store[i]),6);
      `ERROR(("SPI Execution Write Test FAILED"));
    end
  end
  `INFO(("SPI Execution Write Test PASSED"));

  #200ns

  `INFO(("SPI Execution Test PASSED"));
endtask

endprogram
