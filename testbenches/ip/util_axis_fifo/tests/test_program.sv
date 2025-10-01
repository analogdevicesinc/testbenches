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
`include "axis_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import environment_pkg::*;
import watchdog_pkg::*;

import adi_axis_byte_pkg::*;
import adi_axis_transaction_pkg::*;
import adi_axis_packet_pkg::*;
import adi_axis_frame_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, input_axis)::*;
import `PKGIFY(test_harness, output_axis)::*;

program test_program ();

  timeunit 1ns;
  timeprecision 1ps;

  // declare the class instances
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  util_axis_fifo_environment #(`AXIS_VIP_PARAMS(test_harness, input_axis), `AXIS_VIP_PARAMS(test_harness, output_axis), `INPUT_CLK, `OUTPUT_CLK) uaf_env;

  watchdog send_data_wd;

  adi_axis_byte #(
    .EN_TKEEP(1),
    .EN_TSTRB(1),
    .EN_TUSER(1),
    .TUSER_WIDTH(1)
  ) axis_byte, axis_byte2;

  adi_axis_transaction #(
    .BYTES_PER_TRANSACTION(8),
    .EN_TKEEP(1),
    .EN_TSTRB(1),
    .EN_TUSER(1),
    .EN_TLAST(1),
    .EN_TID(1),
    .EN_TDEST(1),
    .TUSER_BYTE_BASED(1),
    .TID_WIDTH(1),
    .TDEST_WIDTH(1),
    .TUSER_WIDTH(1)
  ) axis_transaction, axis_transaction2;

  adi_axis_packet #(
    .BYTES_PER_TRANSACTION(8),
    .EN_TKEEP(1),
    .EN_TSTRB(1),
    .EN_TUSER(1),
    .EN_TLAST(1),
    .EN_TID(1),
    .EN_TDEST(1),
    .TUSER_BYTE_BASED(1),
    .TID_WIDTH(1),
    .TDEST_WIDTH(1),
    .TUSER_WIDTH(1)
  ) axis_packet, axis_packet2;

  adi_axis_frame #(
    .BYTES_PER_TRANSACTION(8),
    .EN_TKEEP(1),
    .EN_TSTRB(1),
    .EN_TUSER(1),
    .EN_TLAST(1),
    .EN_TID(1),
    .EN_TDEST(1),
    .TUSER_BYTE_BASED(1),
    .TID_WIDTH(1),
    .TDEST_WIDTH(1),
    .TUSER_WIDTH(1)
  ) axis_frame, axis_frame2;

  initial begin

    axis_byte = new();
    axis_transaction = new();
    axis_packet = new(.packet_size_limit(8));
    axis_frame = new(
      .frame_size_limit(8),
      .packet_size_limit(8));

    axis_byte.randomize_all();
    axis_transaction.randomize_all();
    axis_packet.randomize_all();
    axis_frame.randomize_all();

    axis_byte2 = new();
    axis_transaction2 = new();
    axis_packet2 = new();
    axis_frame2 = new();

    axis_byte.copy(axis_byte2);
    axis_transaction.copy(axis_transaction2);
    axis_packet.copy(axis_packet2);
    axis_frame.copy(axis_frame2);

    `INFO(("Comparing axis_byte. %0b", axis_byte.compare(axis_byte2)), ADI_VERBOSITY_NONE);
    `INFO(("Comparing axis_transaction. %0b", axis_transaction.compare(axis_transaction2)), ADI_VERBOSITY_NONE);
    `INFO(("Comparing axis_packet. %0b", axis_packet.compare(axis_packet2)), ADI_VERBOSITY_NONE);
    `INFO(("Comparing axis_frame. %0b", axis_frame.compare(axis_frame2)), ADI_VERBOSITY_NONE);

    axis_byte.randomize_all();
    axis_transaction.randomize_all();
    axis_packet.randomize_packet();
    axis_frame.randomize_frame();

    `INFO(("Comparing axis_byte. %0b", axis_byte.compare(axis_byte2)), ADI_VERBOSITY_NONE);
    `INFO(("Comparing axis_transaction. %0b", axis_transaction.compare(axis_transaction2)), ADI_VERBOSITY_NONE);
    `INFO(("Comparing axis_packet. %0b", axis_packet.compare(axis_packet2)), ADI_VERBOSITY_NONE);
    `INFO(("Comparing axis_frame. %0b", axis_frame.compare(axis_frame2)), ADI_VERBOSITY_NONE);

    // byte class updates
    axis_byte.update_tdata(8'ha5);
    axis_byte.update_tkeep(1'b0);
    axis_byte.update_tstrb(1'b1);
    axis_byte.update_tuser(1'b0);

    axis_byte.update_byte_info(8'h5a, 1'b1, 1'b0, 1'b1);
    axis_byte.update_byte_info_class(axis_byte2);

    // transaction class updates
    axis_transaction.update_tlast(1'b0);
    axis_transaction.update_tid(1'b1);
    axis_transaction.update_tdest(1'b0);
    axis_transaction.update_tuser(1'b1);

    axis_transaction.add_transaction_info(1'b1, 1'b0, 1'b1, 1'b0);
    axis_transaction.add_transaction_info_class(axis_transaction2);

    axis_transaction.update_data_byte(0, 8'ha5, 1'b0, 1'b1, 1'b0);
    axis_transaction.update_data_byte_class(0, axis_byte2);

    axis_transaction.bytes[1].update_tdata(8'ha5);
    axis_transaction.bytes[1].update_byte_info(8'h5a, 1'b1, 1'b0, 1'b1);
    axis_transaction.bytes[1].update_byte_info_class(axis_byte2);

    // packet class updates
    axis_packet.create_packet(5);

    axis_packet.transactions[1].update_tlast(1'b0);
    axis_packet.transactions[1].update_tid(axis_packet.transactions[1].tid);
    axis_packet.transactions[1].update_tdest(axis_packet.transactions[1].tdest);
    axis_packet.transactions[1].update_tuser(1'b1);

    axis_packet.transactions[1].add_transaction_info(1'b0, axis_packet.transactions[1].tid, axis_packet.transactions[1].tdest, 1'b0);
    axis_packet.transactions[1].add_transaction_info_class(axis_transaction2);

    axis_packet.transactions[1].update_data_byte(0, 8'ha5, 1'b0, 1'b1, 1'b0);
    axis_packet.transactions[1].update_data_byte_class(0, axis_byte2);

    axis_packet.transactions[1].bytes[1].update_tdata(8'ha5);
    axis_packet.transactions[1].bytes[1].update_byte_info(8'h5a, 1'b1, 1'b0, 1'b1);
    axis_packet.transactions[1].bytes[1].update_byte_info_class(axis_byte2);

    axis_packet.update_transaction_class(4, axis_transaction2);
    axis_packet.add_transaction_class(axis_transaction2);

    // frame class updates

    // create environment
    base_env = new("Base Environment",
                    `TH.`SYS_CLK.inst.IF,
                    `TH.`DMA_CLK.inst.IF,
                    `TH.`DDR_CLK.inst.IF,
                    `TH.`SYS_RST.inst.IF,
                    `TH.`MNG_AXI.inst.IF,
                    `TH.`DDR_AXI.inst.IF);

    uaf_env = new("Util AXIS FIFO Environment",
                  `TH.`INPUT_CLK_VIP.inst.IF,
                  `TH.`OUTPUT_CLK_VIP.inst.IF,
                  `TH.`INPUT_AXIS.inst.IF,
                  `TH.`OUTPUT_AXIS.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    uaf_env.start();

    base_env.sys_reset();

    uaf_env.configure();

    if (!`TKEEP_EN) begin
      uaf_env.input_axis_agent.master_sequencer.set_keep_some();
    end else begin
      uaf_env.input_axis_agent.master_sequencer.set_keep_all();
    end

    uaf_env.run();

    send_data_wd = new("Util AXIS FIFO Watchdog", 500000, "Send data");

    send_data_wd.start();

    uaf_env.input_axis_agent.master_sequencer.start();

    // stimulus
    repeat($urandom_range(5,10)) begin
      send_data_wd.reset();

      if (!`TKEEP_EN) begin
        repeat($urandom_range(1,5)) begin
          uaf_env.input_axis_agent.master_sequencer.add_xfer_descriptor_sample_count($urandom_range(1,128), `TLAST_EN, 0);
        end
      end else begin
        repeat($urandom_range(1,5)) begin
          uaf_env.input_axis_agent.master_sequencer.add_xfer_descriptor_byte_count($urandom_range(1,1024), `TLAST_EN, 0);
        end
      end

      #($urandom_range(1,10)*1us);

      uaf_env.input_axis_agent.master_sequencer.clear_descriptor_queue();
      uaf_env.input_axis_agent.master_sequencer.wait_empty_descriptor_queue();

      uaf_env.scoreboard_inst.wait_until_complete();

      `INFO(("Packet finished."), ADI_VERBOSITY_LOW);
    end

    send_data_wd.stop();

    #100ns;

    uaf_env.stop();
    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
