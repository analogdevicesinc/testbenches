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
`include "../../../library/i3c_controller/i3c_controller_host_interface/i3c_controller_regmap.vh"
`include "../../../library/i3c_controller/i3c_controller_core/i3c_controller_word.vh"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;

//---------------------------------------------------------------------------
// Wait statement with timeout
//---------------------------------------------------------------------------
`define WAIT(CONDITION, TIMEOUT) \
  fork \
  begin \
    #``TIMEOUT``ns \
    `ERROR(("Wait statement expired.")); \
  end \
  begin \
    wait (CONDITION); \
  end \
  join_any \
  disable fork;


localparam I3C_CONTROLLER           = 32'h44A0_0000;

//---------------------------------------------------------------------------
// I3C sanity definitions
//---------------------------------------------------------------------------
localparam I3C_VERSION_CHECK   = 32'h0000_0100;
localparam I3C_DEVICE_ID_CHECK = 32'h0000_0000;
localparam I3C_SCRATCH_CHECK   = 32'hDEAD_BEEF;

//---------------------------------------------------------------------------
// I3C Peripheral first address
//---------------------------------------------------------------------------
// Start DA address, DAA DA stack will be
// START_DA ... START_DA+15
// Being the first the controller addr.
// This info is used to yield known and unknown addrs in the bus.
localparam START_DA   = 3;
localparam DEVICE_DA1 = START_DA+1; // I3C
localparam DEVICE_DA2 = START_DA+2; // I3C
localparam DEVICE_SA1 = START_DA+7; // I2C
localparam DEVICE_SA2 = START_DA+8; // I2C

//---------------------------------------------------------------------------
// I3C Controller instructions
//---------------------------------------------------------------------------
localparam I3C_CCC_RSTDAA = 32'h6;
localparam I3C_CCC_ENTDAA = 32'h7;
localparam I3C_CCC_DISEC  = 32'h1;
localparam I3C_CCC_GETPID = 32'h8d;
localparam I3C_CCC_GETDCR = 32'h8f;
//                               { Flags,Length, Addr,  Rnw}
// CCC, length 0
localparam  I3C_CCC_CMD_RSTDAA = {3'b100, 12'd0, 7'b0, 1'b0};
// CCC, length tx 1
localparam  I3C_CCC_CMD_DISEC  = {3'b100, 12'd1, 7'b0, 1'b0};
// CCC, length 0
localparam I3C_CCC_CMD_ENTDAA  = {3'b100, 12'd0, 7'b0, 1'b0};
// Wrong DA, CCC read 6 bytes
localparam I3C_CMD_GETPID_UDA  = {3'b100, 12'd6,   START_DA[6:0], 1'b1};
// CCC read 6 bytes
localparam I3C_CMD_GETPID      = {3'b100, 12'd6, DEVICE_DA1[6:0], 1'b1};
// CCC read 1 byte
localparam I3C_CMD_GETDCR      = {3'b100, 12'd1, DEVICE_DA1[6:0], 1'b1};
// Write 2 bytes
localparam I3C_CMD_1           = {3'b010, 12'd2, DEVICE_DA1[6:0], 1'b0};
// Write 6 bytes
localparam I3C_CMD_2           = {3'b011, 12'd6, DEVICE_DA1[6:0], 1'b0};
// Read 5 bytes
localparam I3C_CMD_3           = {3'b010, 12'd5, DEVICE_DA2[6:0], 1'b1};
// Wrong DA, write 2 bytes
localparam I3C_CMD_4           = {3'b010, 12'd2,   START_DA[6:0], 1'b0};
// Read 1 byte, no bcast address
localparam I3C_CMD_5           = {3'b000, 12'd1, DEVICE_DA2[6:0], 1'b1};
// Write 2 bytes
localparam I2C_CMD_1           = {3'b010, 12'd2, DEVICE_SA1[6:0], 1'b0};
// Read 5 bytes
localparam I2C_CMD_2           = {3'b010, 12'd5, DEVICE_SA2[6:0], 1'b1};
// Write 6 bytes
localparam I2C_CMD_3           = {3'b010, 12'd6, DEVICE_SA1[6:0], 1'b0};

//---------------------------------------------------------------------------
// Aliases
//---------------------------------------------------------------------------
`define DUT_I3C_CORE $root.system_tb.test_harness.i3c_controller_0.core.inst
`define DUT_I3C_HOST $root.system_tb.test_harness.i3c_controller_0.host_interface.inst
`define DUT_I3C_WORD    `DUT_I3C_CORE.i_i3c_controller_word
`define DUT_I3C_BIT_MOD `DUT_I3C_CORE.i_i3c_controller_bit_mod
`define DUT_I3C_FRAMING `DUT_I3C_CORE.i_i3c_controller_framing
`define DUT_I3C_REGMAP  `DUT_I3C_HOST.i_i3c_controller_regmap
`define STOP `DUT_I3C_WORD.st == `CMDW_STOP_OD | `DUT_I3C_WORD.st == `CMDW_STOP_PP

program test_program (
  input i3c_irq,
  input i3c_clk,
  input i3c_controller_0_scl,
  input i3c_controller_0_sda);

test_harness_env env;

//---------------------------------------------------------------------------
// Wrapper function for AXI read verify using dword
//---------------------------------------------------------------------------
task axi_read_v(
    input   [31:0]  baddr,
    input   [13:0]  raddr,
    input   [31:0]  vdata);
begin
  env.mng.RegReadVerify32(baddr+{raddr,2'b00},vdata);
end
endtask

task axi_read(
    input   [31:0]  baddr,
    input   [13:0]  raddr,
    output  [31:0]  data);
begin
  env.mng.RegRead32(baddr+{raddr,2'b00},data);
end
endtask

//---------------------------------------------------------------------------
// Wrapper function for AXI write using dword
//---------------------------------------------------------------------------
task axi_write(
  input [31:0]  baddr,
  input [13:0]  waddr,
  input [31:0]  wdata);
begin
  env.mng.RegWrite32(baddr+{waddr,2'b00},wdata);
end
endtask

//---------------------------------------------------------------------------
// Write a DA to the sdi lane, for IBI request mock
//---------------------------------------------------------------------------
task write_ibi_da(input int da);
 begin
  force `DUT_I3C_BIT_MOD.sdi = 1'b0;
  wait (`DUT_I3C_WORD.st == `CMDW_BCAST_7E_W0);
  for (int i = 0; i < 7; i++) begin
    wait (`DUT_I3C_BIT_MOD.cmdb_ready == 1'b1);
    force `DUT_I3C_BIT_MOD.sdi = da[7-i] ? 1'bZ : 1'b0;
    wait (`DUT_I3C_BIT_MOD.cmdb_ready == 1'b0);
  end
  wait (`DUT_I3C_WORD.st != `CMDW_BCAST_7E_W0);
  release `DUT_I3C_BIT_MOD.sdi;
end
endtask

//---------------------------------------------------------------------------
// Information
//---------------------------------------------------------------------------
task print_cmdr (input int data);
begin
  $display("[%t] Got CMDR error %d, length %d, sync %d", $time, data[23:20], data[19:8], data[7:0]);
end
endtask

task print_ibi(input int data);
begin
  $display("[%t] Got IBI DA %b, MDB %b, Sync %d.", $time, data[23:17], data[15:08], data[7:0]);
end
endtask

//---------------------------------------------------------------------------
// Peripheral ACK & Stop RX
//---------------------------------------------------------------------------
// Mock acknowledge by the peripheral without having to make a method call for
// every byte transferred.
// Limitation: If on do_ack or CMDW_DAA_DEV_CHAR, do_ack <= 1'b0 will not
// release the sdi
logic do_ack = 1'b1;
logic do_rx_t = 1'b1;
logic auto_ack = 1'b1;
logic dev_char_state = 1'b1;
initial begin
  while (1) begin
    @(posedge i3c_clk);
    if (auto_ack) begin
      if (`DUT_I3C_WORD.do_ack && do_ack) begin
        force `DUT_I3C_BIT_MOD.sdi = 1'b0;
      end else if (`DUT_I3C_WORD.do_rx_t && ~do_rx_t) begin
        force `DUT_I3C_BIT_MOD.sdi = 1'b0;
      end else begin
        if (`DUT_I3C_WORD.st == `CMDW_DAA_DEV_CHAR) begin
          force `DUT_I3C_BIT_MOD.sdi = dev_char_state;
        end else begin
          release `DUT_I3C_BIT_MOD.sdi;
        end
      end
    end
  end
end

//---------------------------------------------------------------------------
// Main procedure
//---------------------------------------------------------------------------
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

  #100 sanity_test;

  // Enable I3C Controller
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_ENABLE, 0);
  // Set speed grade to 3.12 MHz
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_OPS, {2'b01, 4'd0, 1'b0});

  #100 dev_char_i3c_test;

  #100 daa_i3c_test;

  #100 ccc_i3c_test;

  #100 priv_i3c_test;

  #100 priv_i2c_test;

  #100 offload_i3c_test;

  #100 ibi_i3c_test;

  `INFO(("Test Done"));

  $finish;

end

//---------------------------------------------------------------------------
// IRQ callback
//---------------------------------------------------------------------------
reg [`I3C_REGMAP_IRQ_WIDTH:0] irq_pending = 0;
initial begin
  while (1) begin
    @(posedge i3c_irq);
    // read pending IRQs
    axi_read (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, irq_pending);

    if (irq_pending & (1'b1 << `I3C_REGMAP_IRQ_CMDR_PENDING)) begin
      $display("[%t] NOTE: Got CMDR IRQ", $time);
    end else if (irq_pending & (1'b1 << `I3C_REGMAP_IRQ_IBI_PENDING)) begin
      $display("[%t] NOTE: Got IBI IRQ", $time);
    end else if (irq_pending & (1'b1 << `I3C_REGMAP_IRQ_DAA_PENDING)) begin
      $display("[%t] NOTE: Got DAA IRQ", $time);
    end else begin
      $display("[%t] NOTE: Got IRQ %h", $time, irq_pending);
    end
  end
end

//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------
task sanity_test;
begin
  `INFO(("Sanity Started"));
  axi_read_v (I3C_CONTROLLER, `I3C_REGMAP_VERSION,       I3C_VERSION_CHECK);
  axi_read_v (I3C_CONTROLLER, `I3C_REGMAP_DEVICE_ID,     I3C_DEVICE_ID_CHECK);
  axi_write  (I3C_CONTROLLER, `I3C_REGMAP_SCRATCH,       I3C_SCRATCH_CHECK);
  axi_read_v (I3C_CONTROLLER, `I3C_REGMAP_SCRATCH,       I3C_SCRATCH_CHECK);
  `INFO(("Sanity Test Done"));
end
endtask

//---------------------------------------------------------------------------
// CCC I3C Test
//---------------------------------------------------------------------------
bit   [31:0]  cmdr_fifo_data = 0;
bit   [31:0]  sdi_fifo_data = 0;

task ccc_i3c_test;
begin
  `INFO(("CCC I3C Started"));

  auto_ack <= 1'b1;

  // Disable IBI
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IBI_CONFIG, 2'b00);

  // Unmask CMDR interrupt
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_MASK, 32'h20);

  // Test #1, CCC without payload
  `INFO(("CCC I3C Test #1"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CCC_CMD_RSTDAA); // CCC, length 0
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CCC_RSTDAA);
  @(posedge i3c_irq);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_CMDR_PENDING);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != 0)
    `ERROR(("CMD -> CMDR read length test FAILED"));

  // Test #2, CCC with length 1 write payload
  `INFO(("CCC I3C Test #2"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_SDO_FIFO, 32'h0000000b); // See DISEC spec. for +info
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CCC_CMD_DISEC); // CCC, length tx 1
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CCC_DISEC);
  @(posedge i3c_irq);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_CMDR_PENDING);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != 1)
    `ERROR(("CMD -> CMDR write length test FAILED"));

  // Test #3, CCC with length 6 read payload but DA is unknown
  `INFO(("CCC I3C Test #3"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CMD_GETPID_UDA); // CCC, length rx 6
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CCC_GETPID);
  wait (i3c_irq);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_CMDR_PENDING);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[23:20] != 8)
    `ERROR(("#4: CMD -> CMDR UDA_ERROR assertion FAILED"));

  // Test #4, CCC with length 6 read payload, DA is known
  `INFO(("CCC I3C Test #4"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CMD_GETPID); // CCC, length rx 6
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CCC_GETPID);
  wait (`DUT_I3C_WORD.st == `CMDW_MSG_RX);
  auto_ack <= 1'b0;
  force `DUT_I3C_BIT_MOD.sdi = 1'b1;
  repeat (6) @(posedge `DUT_I3C_WORD.sdi_valid);
  force `DUT_I3C_BIT_MOD.sdi = 1'b0;
  wait (`STOP);
  release `DUT_I3C_BIT_MOD.sdi;
  auto_ack <= 1'b1;
  @(posedge i3c_irq);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_CMDR_PENDING);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != 6)
    `ERROR(("CMD -> CMDR read length test FAILED"));

  // Test #5, CCC with length 1 read payload, DA is known
  `INFO(("CCC I3C Test #5"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CMD_GETDCR); // CCC, length rx 1
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CCC_GETDCR);
  wait (`DUT_I3C_WORD.st == `CMDW_MSG_RX);
  auto_ack <= 1'b0;
  force `DUT_I3C_BIT_MOD.sdi = 1'b1;
  wait (`STOP);
  release `DUT_I3C_BIT_MOD.sdi;
  auto_ack <= 1'b1;
  @(posedge i3c_irq);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_CMDR_PENDING);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != 1)
    `ERROR(("CMD -> CMDR read length test FAILED"));
  // Mask CMDR interrupt
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_MASK, 32'h00);
  // Clear all pending IRQs
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, irq_pending);

  `INFO(("CCC I3C Test Done"));
end
endtask

//---------------------------------------------------------------------------
// Private transfer I3C Test
//---------------------------------------------------------------------------
task priv_i3c_test;
begin
  `INFO(("Private Transfer I3C Started"));

  // Disable IBI
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IBI_CONFIG, 2'b00);

  // Change speed grade to 12.5 MHz
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_OPS, {2'b11, 4'd0, 1'b0});

  // Unmask CMDR interrupt
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_MASK, 32'h20);

  // Test #1, controller does private write transfer that is ACK
  `INFO(("PRIV I3C Test #1"));

  // Write SDO payload
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_SDO_FIFO, 32'hDEAD_BEEF);

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CMD_1);
  wait (`DUT_I3C_BIT_MOD.nop == 0);
  `WAIT (`DUT_I3C_BIT_MOD.nop == 1, 100000);

  // Test #2, controller does private read transfer that is ACK
  `INFO(("PRIV I3C Test #2"));

  // Change speed grade to 6.25 MHz
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_OPS, {2'b10, 4'd0, 1'b0});
  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CMD_3);

  // Dummy HIGH peripheral write + T_bit continue
  wait (`DUT_I3C_WORD.st == `CMDW_MSG_RX);
  auto_ack <= 1'b0;
  force `DUT_I3C_BIT_MOD.sdi = 1'b1;
  wait (`STOP);
  release `DUT_I3C_BIT_MOD.sdi;
  auto_ack <= 1'b1;
  wait (`DUT_I3C_BIT_MOD.nop == 0);
  wait (`DUT_I3C_BIT_MOD.nop == 1);

  // Test #3, controller does private read transfer that is cancelled
  // at the first T-Bit
  `INFO(("PRIV I3C Test #3"));

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CMD_3);

  // Dummy LOW peripheral write + T_bit stop
  wait (`DUT_I3C_WORD.st == `CMDW_MSG_RX);
  auto_ack <= 1'b0;
  force `DUT_I3C_BIT_MOD.sdi = 1'b0;
  wait (`STOP);
  release `DUT_I3C_BIT_MOD.sdi;
  auto_ack <= 1'b1;
  wait (`DUT_I3C_BIT_MOD.nop == 0);
  wait (`DUT_I3C_BIT_MOD.nop == 1);

  // Test #4, controller does private write transfer to an unknown DA.
  // Expected result: return UDA_ERROR in receipt
  `INFO(("PRIV I3C Test #4"));

  // Write SDO payload
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_SDO_FIFO, 32'hDEAD_BEEF);

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CMD_4);
  wait (`DUT_I3C_BIT_MOD.nop == 1);

  // Test #5, controller does private read transfer that is NACK
  `INFO(("PRIV I3C Test #5"));

  // Write SDO payload
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_SDO_FIFO, 32'hDEAD_BEEF);

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CMD_1);
  wait (`DUT_I3C_BIT_MOD.nop == 0);
  auto_ack <= 1'b0;
  force `DUT_I3C_BIT_MOD.sdi = 1'b1;
  wait (`DUT_I3C_BIT_MOD.nop == 1);
  auto_ack <= 1'b1;
  release `DUT_I3C_BIT_MOD.sdi;

  // Test #6, controller does private read transfer that is ACK,
  // no broadcast address.
  `INFO(("PRIV I3C Test #6"));

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CMD_5);

  // Dummy HIGH peripheral write + T_bit continue
  wait (`DUT_I3C_WORD.st == `CMDW_MSG_RX);
  auto_ack <= 1'b0;
  force `DUT_I3C_BIT_MOD.sdi = 1'b1;
  wait (`STOP);
  release `DUT_I3C_BIT_MOD.sdi;
  auto_ack <= 1'b1;
  wait (`DUT_I3C_BIT_MOD.nop == 0);
  wait (`DUT_I3C_BIT_MOD.nop == 1);

  // Read Results

  if (~`DUT_I3C_REGMAP.up_irq_pending[`I3C_REGMAP_IRQ_CMDR_PENDING])
    `ERROR(("#0: IRQ CMDR FAILED"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_CMDR_PENDING);

  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != I3C_CMD_1[19:8]) // Wrote all bytes
    `ERROR(("#1: CMD -> CMDR write length test FAILED"));
  if (cmdr_fifo_data[23:20] != 0)
    `ERROR(("#1: CMD -> CMDR NO_ERROR assertion FAILED"));

  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != I3C_CMD_3[19:8]) // Read all bytes
    `ERROR(("#2: CMD -> CMDR read length test FAILED"));
  if (cmdr_fifo_data[23:20] != 0)
    `ERROR(("#2: CMD -> CMDR NO_ERROR assertion FAILED"));

  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != 1) // Read one byte
    `ERROR(("#3: CMD -> CMDR read length test FAILED"));
  if (cmdr_fifo_data[23:20] != 6)
    `ERROR(("#3: CMD -> CMDR NACK_RESP assertion FAILED"));

  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[23:20] != 8)
    `ERROR(("#4: CMD -> CMDR UDA_ERROR assertion FAILED"));

  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != 0) // Wrote no bytes
    `ERROR(("#5: CMD -> CMDR write length test FAILED"));
  if (cmdr_fifo_data[23:20] != 4)
    `ERROR(("#5: CMD -> CMDR CEO_ERROR assertion FAILED"));

  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != I3C_CMD_5[19:8]) // Read all bytes
    `ERROR(("#6: CMD -> CMDR read length test FAILED"));
  if (cmdr_fifo_data[23:20] != 0)
    `ERROR(("#6: CMD -> CMDR NO_ERROR assertion FAILED"));

  // Mask CMDR interrupt
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_MASK, 32'h00);
  // Clear all pending IRQs
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, irq_pending);

  `INFO(("Private Transfer I3C Ended"));
end
endtask

//---------------------------------------------------------------------------
// Private transfer I²C Test
//---------------------------------------------------------------------------
task priv_i2c_test;
begin
  `INFO(("Private Transfer I2C Started"));

  // Unmask CMDR interrupt
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_MASK, 32'h20);

  // Test #1, controller does private write transfer that is ACK
  `INFO(("PRIV I2C Test #1"));
  auto_ack <= 1'b1;

  // Write SDO payload
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_SDO_FIFO, 32'hDEAD_BEEF);

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I2C_CMD_1);
  wait (`DUT_I3C_BIT_MOD.nop == 0);
  // Assert is in I²C mode
  if (`DUT_I3C_BIT_MOD.i2c_mode !== 1)
   `ERROR(("Not in I2C mode!"));
  wait (`DUT_I3C_BIT_MOD.nop == 1);

  // Test #2, controller does private read transfer and ACKs all receiving
  // bytes.
  `INFO(("PRIV I2C Test #2"));

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I2C_CMD_2);

  // Dummy LOW peripheral write + ACK continue
  wait (`DUT_I3C_WORD.st == `CMDW_I2C_RX);
  auto_ack <= 1'b0;
  force `DUT_I3C_BIT_MOD.sdi = 1'b0;
  // Count 5 ACK-bit asserted low by the controller
  repeat (5) @(negedge i3c_controller_0_sda);
  release `DUT_I3C_BIT_MOD.sdi;

  wait (`DUT_I3C_BIT_MOD.nop == 0);
  wait (`DUT_I3C_BIT_MOD.nop == 1);
  auto_ack <= 1'b1;

  // Test #3, controller does private write transfer that stalls for a while
  `INFO(("PRIV I2C Test #3"));
  auto_ack <= 1'b1;

  // Write SDO payload
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_SDO_FIFO, 32'hDEAD_BEEF);

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I2C_CMD_3);
  wait (`DUT_I3C_BIT_MOD.nop == 0);
  // Wait a while to write second payload, stalling the bus
  wait (`DUT_I3C_BIT_MOD.sm == 1);
  # 10000
  if (i3c_controller_0_scl !== 0)
    `ERROR(("Bus is not stalled (SCL != 0)"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_SDO_FIFO, 32'h0000_00DE);
  wait (`DUT_I3C_BIT_MOD.nop == 1);

  // Read Results

  if (~`DUT_I3C_REGMAP.up_irq_pending[`I3C_REGMAP_IRQ_CMDR_PENDING])
    `ERROR(("#0: IRQ CMDR FAILED"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_CMDR_PENDING);

  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != I2C_CMD_1[19:8]) // Wrote all bytes
    `ERROR(("#1: CMD -> CMDR write length test FAILED"));

  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[23:20] == 4'd1)
    `ERROR(("#2: CMD -> CMDR CE0_ERROR check FAILED"));

  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != 12'd6) // Wrote 6 bytes
    `ERROR(("#3: CMD -> CMDR write length test FAILED"));

  // Mask CMDR interrupt
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_MASK, 32'h00);
  // Clear all pending IRQs
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, irq_pending);
  // Clear any sdi data from the cmd
  while(`DUT_I3C_REGMAP.i_sdi_fifo.m_axis_level) begin
    axi_read (I3C_CONTROLLER, `I3C_REGMAP_SDI_FIFO, sdi_fifo_data);
  end

  `INFO(("Private Transfer I2C Ended"));
end
endtask

//---------------------------------------------------------------------------
// IBI I3C Test
//---------------------------------------------------------------------------
bit   [31:0]  ibi_fifo_data = 0;

task ibi_i3c_test;
begin
  auto_ack <= 1'b0;

  `INFO(("IBI I3C Test Started"));

  // Unask IBI, CMDR interrupt
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_MASK, 32'h60);

  // Enable IBI
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IBI_CONFIG, 2'b11);

  // Test #1, peripheral does IBI request by pulling SDA low
  // Expected result: the controller accepts the IBI by driving SCL,
  // obtains the DA and MDB from the IBI.

  `INFO(("IBI I3C Test #1"));
  write_ibi_da(DEVICE_DA1);

  @(posedge i3c_irq);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_IBI_FIFO, ibi_fifo_data);
  print_ibi(ibi_fifo_data);
  if (ibi_fifo_data[23:17] != DEVICE_DA1)
    `ERROR(("Wrong IBI DA"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_IBI_PENDING);

  // Test #2, peripheral does an IBI request by sending its DA during broadcast
  // address.
  // Expected result: the controller retrieves the DA and MDB from the IBI,
  // and continues the cmd transfer after resolving the IBI request.

  `INFO(("IBI I3C Test #2"));
  // Write SDO payload
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_SDO_FIFO, 32'hDEAD_BEEF);

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CMD_1);

  wait (`DUT_I3C_BIT_MOD.nop == 0);
  // Write DA during low during broadcast address
  write_ibi_da(DEVICE_DA1);
  wait (`DUT_I3C_WORD.st == `CMDW_IBI_MDB);
  force `DUT_I3C_BIT_MOD.sdi = 1'bZ;
  wait (`DUT_I3C_WORD.st == `CMDW_SR);
  release `DUT_I3C_BIT_MOD.sdi;
  // Enable ACK during the cmd transfer
  auto_ack <= 1'b1;
  wait (i3c_irq);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_IBI_FIFO, ibi_fifo_data);
  print_ibi (ibi_fifo_data);
  if (ibi_fifo_data[23:17] != DEVICE_DA1)
    `ERROR(("Wrong IBI DA"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_IBI_PENDING);

  wait (i3c_irq); // cmdr_irq
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_CMDR_PENDING);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != I3C_CMD_1[19:8])
    `ERROR(("CMD transfer after resolving IBI FAILED"));

  // Test #3, peripheral does IBI request by pulling SDA low,
  // but the DA is unkown.
  // Expected result: the controller rejects the IBI by NACKIng the,
  // request. No ibi is written to the FIFO.

  `INFO(("IBI I3C Test #3"));
  auto_ack <= 1'b0;
  write_ibi_da(START_DA);

  # 10000
  if (`DUT_I3C_REGMAP.ibi_fifo_valid)
    `ERROR(("IBI should not have thrown IBI"));

  // Test #4, peripheral does an IBI request by sending its DA during broadcast
  // address, but the DA is unknown
  // Expected result: the controller rejects the IBI by NACKIng the,
  // request. No ibi is written to the FIFO. Then continue the request
  // after resolving the IBI request.

  #12000
  `INFO(("IBI I3C Test #4"));
  // Write SDO payload
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_SDO_FIFO, 32'hDEAD_BEEF);

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CMD_1);

  wait (`DUT_I3C_BIT_MOD.nop == 0);
  // Write DA during low during broadcast address
  write_ibi_da(START_DA-1);
  // Enable ACK during the cmd transfer
  auto_ack <= 1'b1;
  @(posedge i3c_irq);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_CMDR_PENDING);
  print_cmdr (cmdr_fifo_data);
  if (cmdr_fifo_data[19:8] != I3C_CMD_1[19:8])
    `ERROR(("CMD transfer after resolving IBI FAILED"));
  if (`DUT_I3C_REGMAP.ibi_fifo_valid)
    `ERROR(("IBI should not throwed IBI"));

  // Test #5, peripheral does IBI request by pulling SDA low, DA is known but
  // BCR[2] is Low (no following MDB)
  // Expected result: the controller accepts the IBI by driving SCL,
  // ACKs the IBI and follows with a Stop.

  #12000
  `INFO(("IBI I3C Test #5"));
  auto_ack <= 1'b0;
  write_ibi_da(DEVICE_DA1+1);

  wait (i3c_irq);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_IBI_FIFO, ibi_fifo_data);
  print_ibi(ibi_fifo_data);
  if (ibi_fifo_data[23:17] != DEVICE_DA1+1)
    `ERROR(("Wrong IBI DA"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_IBI_PENDING);

  auto_ack <= 1'b1;

  // Clear any sdi data from the cmd
  while(`DUT_I3C_REGMAP.i_sdi_fifo.m_axis_level) begin
    axi_read (I3C_CONTROLLER, `I3C_REGMAP_SDI_FIFO, sdi_fifo_data);
  end
  // Mask IBI and CMDR interrupt
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_MASK, 32'h00);
  // Clear all pending IRQs
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, irq_pending);

  `INFO(("IBI I3C Test Done"));
end
endtask

//---------------------------------------------------------------------------
// DAA I3C Test
//---------------------------------------------------------------------------
bit   [31:0]  dev_char_data = 0;
task daa_i3c_test;
begin
  `INFO(("DAA I3C Started"));

  // Unmask the CMDR and DAA interrupt
  axi_write (I3C_CONTROLLER,`I3C_REGMAP_IRQ_MASK, 32'ha0);

  if (`DUT_I3C_REGMAP.i_sdi_fifo.m_axis_level)
    `ERROR(("SDI FIFO must be empty for the DAA procedure"));

  auto_ack <= 1'b1;
  // Disable IBI
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IBI_CONFIG, 2'b00);

  // Test #1, controller does the DAA until no peripherals ACKs or there is
  // no slots left.
  // Note: this is a long procedure that must occur in open-drain mode.

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CCC_CMD_ENTDAA);
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_CMD_FIFO, I3C_CCC_ENTDAA);
  `WAIT (`DUT_I3C_FRAMING.st == `CMDW_START, 10000);

  @(posedge i3c_irq);
  `INFO(("GOT DAA IRQ"));
  // Assert 2x32-bit in SDI FIFO (PID+BCR+DCR)
  if (`DUT_I3C_REGMAP.i_sdi_fifo.m_axis_level != 2)
    `ERROR(("Wrong SDI FIFO level"));
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_SDI_FIFO, sdi_fifo_data);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_SDI_FIFO, sdi_fifo_data);
  // Assert that irq won't be cleared if SDO is empty
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_DAA_PENDING);
  if (~`DUT_I3C_REGMAP.up_irq_pending[`I3C_REGMAP_IRQ_DAA_PENDING])
    `ERROR(("DAA IRQ should not have been cleared"));
  `INFO(("Writing DA 1"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_SDO_FIFO, {24'h0, DEVICE_DA1, ~^DEVICE_DA1[6:0]});
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_DAA_PENDING);

  // Write DEV_CHAR_2 all Low for the second peripheral,
  // so BCR[2] is Low (used in the ibi_i3c_test).
  wait (`DUT_I3C_WORD.st == `CMDW_DAA_DEV_CHAR);
  dev_char_state <= 1'b0;
  @(posedge i3c_irq);
  // Assert 2x32-bit in SDI FIFO (PID+BCR+DCR)
  if (`DUT_I3C_REGMAP.i_sdi_fifo.m_axis_level != 2)
    `ERROR(("Wrong SDI FIFO level"));
  dev_char_state <= 1'b1;
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_SDI_FIFO, sdi_fifo_data);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_SDI_FIFO, sdi_fifo_data);

  `INFO(("Writing DA 2"));
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_SDO_FIFO, {24'h0, DEVICE_DA2, ~^DEVICE_DA2[6:0]});
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_DAA_PENDING);

  // Wait next start, do not ACK to exit DAA (no other dev on bus needs addr)
  `WAIT (`DUT_I3C_WORD.st == `CMDW_START, 100000);
  #10 auto_ack <= 1'b0;
  @(posedge i3c_irq);
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_CMDR_FIFO, cmdr_fifo_data);
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, 1'b1 << `I3C_REGMAP_IRQ_CMDR_PENDING);
  print_cmdr (cmdr_fifo_data);

  // Mask the DAA interrupt
  axi_write (I3C_CONTROLLER,`I3C_REGMAP_IRQ_MASK, 32'h20);
  // Clear all pending IRQs
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_PENDING, irq_pending);

  `INFO(("DAA I3C Test Done"));
end
endtask

//---------------------------------------------------------------------------
// Device Characteristics I3C Test
//---------------------------------------------------------------------------
bit [6:0]  dev_char_addr = START_DA+1;
bit [3:0]  dev_char_0 = 4'b1110;
bit [3:0]  dev_char_1 = 4'b0010;
bit [3:0]  dev_char_2 = 4'b0011;
bit [3:0]  dev_char_3 = 4'b0011;
bit [31:0] dev_char_data = 0;
task dev_char_i3c_test;
begin
  `INFO(("Device Characteristics I3C Test Started"));
  // Write DEV_CHAR of four devices
  axi_write(I3C_CONTROLLER, `I3C_REGMAP_DEV_CHAR, {DEVICE_DA1 , 1'b1, 4'h0, dev_char_0});
  axi_write(I3C_CONTROLLER, `I3C_REGMAP_DEV_CHAR, {DEVICE_DA2, 1'b1, 4'h0, dev_char_1});
  axi_write(I3C_CONTROLLER, `I3C_REGMAP_DEV_CHAR, {DEVICE_SA1 , 1'b1, 4'h0, dev_char_2});
  axi_write(I3C_CONTROLLER, `I3C_REGMAP_DEV_CHAR, {DEVICE_SA2, 1'b1, 4'h0, dev_char_3});

  // Read first and check value
  axi_write(I3C_CONTROLLER, `I3C_REGMAP_DEV_CHAR, {DEVICE_DA1 , 9'h0});
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_DEV_CHAR, dev_char_data);
  $display("[%t] Got DEV_CHAR_0 %h", $time, dev_char_data);
  if (dev_char_data[3:0] != dev_char_0 || dev_char_data[15:9] != DEVICE_DA1)
    `ERROR(("DEV_CHAR_0 FAILED"));
  // Read second and check value
  axi_write(I3C_CONTROLLER, `I3C_REGMAP_DEV_CHAR, {DEVICE_DA2, 9'h0});
  axi_read (I3C_CONTROLLER, `I3C_REGMAP_DEV_CHAR, dev_char_data);
  $display("[%t] Got DEV_CHAR_0 %h", $time, dev_char_data);
  if (dev_char_data[3:0] != dev_char_1 || dev_char_data[15:9] != DEVICE_DA2)
    `ERROR(("DEV_CHAR_0 FAILED"));

  `INFO(("Device Characteristics I3C Test Done"));
end
endtask

//---------------------------------------------------------------------------
// Offload I3C Test
//---------------------------------------------------------------------------
task offload_i3c_test;
begin
  // TODO: improve the offload test.
  // Test #1, controller does offload transfer

  #10000

  // Mask all interrupts
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_IRQ_MASK, 32'h00);

  `INFO(("Offload I3C Test Started"));

  #10 force `DUT_I3C_HOST.offload_trigger = 1'b0;
  #10 force `DUT_I3C_HOST.offload_sdi_ready = 1'b1;
  // Write SDO payload
  axi_write (I3C_CONTROLLER, {`I3C_REGMAP_OFFLOAD_SDO_, 4'h0}, 32'hDEAD_BEEF);

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, {`I3C_REGMAP_OFFLOAD_CMD_, 4'h0}, I3C_CMD_1);

  // Write CMD instruction
  axi_write (I3C_CONTROLLER, {`I3C_REGMAP_OFFLOAD_CMD_, 4'h1}, I3C_CMD_3);

  // Set offload length and enter offload mode
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_OPS, {2'b11, 4'd2, 1'b1});

  #10 force `DUT_I3C_HOST.offload_trigger = 1'b1;
  #10 force `DUT_I3C_HOST.offload_trigger = 1'b0;

  #50000

  #10 force `DUT_I3C_HOST.offload_trigger = 1'b1;
  #10 force `DUT_I3C_HOST.offload_trigger = 1'b0;

  #50000

  // Exit offload mode
  axi_write (I3C_CONTROLLER, `I3C_REGMAP_OPS, {4'd0, 1'b0});
  #10 release `DUT_I3C_HOST.offload_trigger;
  #10 release `DUT_I3C_HOST.offload_sdi_ready;

  `INFO(("Offload I3C Test Done"));
end
endtask

endprogram
