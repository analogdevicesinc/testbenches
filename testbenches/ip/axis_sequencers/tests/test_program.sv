// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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

import logger_pkg::*;
import test_harness_env_pkg::*;
import environment_pkg::*;
import watchdog_pkg::*;
import axi4stream_vip_pkg::*;
import m_axis_sequencer_pkg::*;
import s_axis_sequencer_pkg::*;
import adi_axis_packet_pkg::*;
import adi_axis_config_pkg::*;
import adi_axis_rand_config_pkg::*;
import adi_axis_rand_obj_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, src_axis)::*;
import `PKGIFY(test_harness, dst_axis)::*;

program test_program;

  timeunit 1ns;
  timeprecision 1ps;

  //============================================================================
  // Source (Master) Sequencer Configuration
  //============================================================================

  // Source data generation mode (determines how descriptors are handled)
  // 1 - Single descriptor
  // 2 - Multiple descriptors
  // 3 - Infinite descriptors
  localparam int SRC_DESCRIPTORS = 3;

  // Source stop policy
  // 1 - STOP_POLICY_TRANSACTION
  // 2 - STOP_POLICY_PACKET
  // 3 - STOP_POLICY_FRAME
  // 4 - STOP_POLICY_SEQUENCE
  // 5 - STOP_POLICY_QUEUE
  localparam int SRC_STOP_POLICY = 2;

  // Inter-beat valid delays (transaction delay)
  localparam int SRC_TRANSACTION_DELAY = 0;

  // Inter-packet valid delays
  localparam int SRC_PACKET_DELAY = 0;

  // Inter-frame valid delays
  localparam int SRC_FRAME_DELAY = 0;

  // Inter-sequence valid delays
  localparam int SRC_SEQUENCE_DELAY = 0;

  // Repeat transaction mode (0 - disabled, 1 - enabled)
  localparam bit SRC_REPEAT_MODE = 0;

  // Drive output to 0 when inactive (0 - disabled, 1 - enabled)
  localparam bit SRC_INACTIVE_DRIVE_0 = 0;

  //============================================================================
  // Destination (Slave) Sequencer Configuration
  //============================================================================

  // Destination ready generation mode
  // 1 - XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE
  // 2 - XIL_AXI4STREAM_READY_GEN_SINGLE
  // 3 - XIL_AXI4STREAM_READY_GEN_EVENTS
  // 4 - XIL_AXI4STREAM_READY_GEN_OSC
  // 5 - XIL_AXI4STREAM_READY_GEN_RANDOM
  // 6 - XIL_AXI4STREAM_READY_GEN_AFTER_VALID_SINGLE
  // 7 - XIL_AXI4STREAM_READY_GEN_AFTER_VALID_EVENTS
  // 8 - XIL_AXI4STREAM_READY_GEN_AFTER_VALID_OSC
  localparam int DEST_READY_MODE = 1;

  // Use variable high/low time ranges (0 - use fixed times, 1 - use ranges)
  localparam bit DEST_USE_VARIABLE_RANGES = 0;

  // Fixed high time (used when DEST_USE_VARIABLE_RANGES is 0)
  localparam int DEST_HIGH_TIME = 1;

  // Fixed low time (used when DEST_USE_VARIABLE_RANGES is 0)
  localparam int DEST_LOW_TIME = 5;

  // High time range (used when DEST_USE_VARIABLE_RANGES is 1)
  localparam int DEST_HIGH_TIME_MIN = 1;
  localparam int DEST_HIGH_TIME_MAX = 5;

  // Low time range (used when DEST_USE_VARIABLE_RANGES is 1)
  localparam int DEST_LOW_TIME_MIN = 1;
  localparam int DEST_LOW_TIME_MAX = 5;

  // Event count (fixed value)
  localparam int DEST_EVENT_COUNT = 1;

  // Event count range (used when DEST_USE_VARIABLE_RANGES is 1)
  localparam int DEST_EVENT_COUNT_MIN = 1;
  localparam int DEST_EVENT_COUNT_MAX = 5;

  //============================================================================
  // Class Instances
  //============================================================================

  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  axis_sequencer_environment #(`AXIS_VIP_PARAMS(test_harness, src_axis), `AXIS_VIP_PARAMS(test_harness, dst_axis)) axis_seq_env;

  watchdog send_data_wd;

  adi_axis_config axis_cfg;
  adi_axis_rand_config axis_rand_cfg;
  adi_axis_rand_obj axis_rand_obj;
  adi_axis_packet axis_packet;

  initial begin

    // create environment
    base_env = new("Base Environment",
                    `TH.`SYS_CLK.inst.IF,
                    `TH.`DMA_CLK.inst.IF,
                    `TH.`DDR_CLK.inst.IF,
                    `TH.`SYS_RST.inst.IF,
                    `TH.`MNG_AXI.inst.IF,
                    `TH.`DDR_AXI.inst.IF);

    axis_seq_env = new("Axis Sequencers Environment",
                        `TH.`SRC_AXIS.inst.IF,
                        `TH.`DST_AXIS.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    axis_seq_env.start();

    base_env.sys_reset();

    // Configure environment with local parameters
    axis_seq_env.configure(
      // Source (Master) configuration
      .src_stop_policy(SRC_STOP_POLICY),
      .src_transaction_delay(SRC_TRANSACTION_DELAY),
      .src_packet_delay(SRC_PACKET_DELAY),
      .src_frame_delay(SRC_FRAME_DELAY),
      .src_sequence_delay(SRC_SEQUENCE_DELAY),
      .src_repeat_mode(SRC_REPEAT_MODE),
      .src_inactive_drive_0(SRC_INACTIVE_DRIVE_0),
      // Destination (Slave) configuration
      .dest_ready_mode(DEST_READY_MODE),
      .dest_use_variable_ranges(DEST_USE_VARIABLE_RANGES),
      .dest_high_time(DEST_HIGH_TIME),
      .dest_low_time(DEST_LOW_TIME),
      .dest_high_time_min(DEST_HIGH_TIME_MIN),
      .dest_high_time_max(DEST_HIGH_TIME_MAX),
      .dest_low_time_min(DEST_LOW_TIME_MIN),
      .dest_low_time_max(DEST_LOW_TIME_MAX),
      .dest_event_count(DEST_EVENT_COUNT),
      .dest_event_count_min(DEST_EVENT_COUNT_MIN),
      .dest_event_count_max(DEST_EVENT_COUNT_MAX)
    );

    axis_cfg = new(`AXIS_TRANSACTION_PARAM(test_harness, src_axis));
    axis_rand_cfg = new();
    axis_rand_obj = new();

    // tdata - ramp
    axis_rand_cfg.TDATA_MODE = 1;

    // tkeep - constant 1
    axis_rand_cfg.TKEEP_MODE = 1;
    axis_rand_obj.tkeep = 1'b1;

    axis_packet = new(
      .transactions_per_packet(5),
      .cfg(axis_cfg),
      .rand_cfg(axis_rand_cfg),
      .rand_obj(axis_rand_obj));

    axis_packet.randomize_packet();

    // Add packets based on descriptor mode
    case (SRC_DESCRIPTORS)
      1: begin
        // Single descriptor mode
        axis_seq_env.src_axis_agent.master_sequencer.add_packet(axis_packet);
        send_data_wd = new("Axis Sequencer Watchdog", 1000, "Send data");
      end
      2: begin
        // Multiple descriptors mode
        repeat (10) begin
          axis_packet.randomize_packet();
          axis_seq_env.src_axis_agent.master_sequencer.add_packet(axis_packet);
        end
        send_data_wd = new("Axis Sequencer Watchdog", 30000, "Send data");
      end
      3: begin
        // Infinite descriptors mode (requires SRC_REPEAT_MODE=1)
        axis_packet.randomize_packet();
        axis_seq_env.src_axis_agent.master_sequencer.add_packet(axis_packet);
        send_data_wd = new("Axis Sequencer Watchdog", 20000, "Send data");
      end
      default: `FATAL(("Source descriptor parameter incorrect!"));
    endcase

    send_data_wd.start();

    axis_seq_env.src_axis_agent.master_sequencer.start();

    #100ns;

    case (SRC_DESCRIPTORS)
      1: //axis_seq_env.src_axis_agent.master_sequencer.beat_sent();
        axis_seq_env.src_axis_agent.master_sequencer.packet_sent();
      2: axis_seq_env.src_axis_agent.master_sequencer.wait_empty_sequences();
      3: begin
        #10us;

        axis_seq_env.src_axis_agent.master_sequencer.stop();

        axis_seq_env.src_axis_agent.master_sequencer.packet_sent();
      end
      default: ;
    endcase

    axis_seq_env.src_axis_agent.master_sequencer.sequence_sent();

    send_data_wd.stop();

    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
