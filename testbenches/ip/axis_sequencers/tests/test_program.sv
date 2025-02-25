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
//
`include "utils.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import environment_pkg::*;
import watchdog_pkg::*;
import axi4stream_vip_pkg::*;
import m_axis_sequencer_pkg::*;
import s_axis_sequencer_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, src_axis)::*;
import `PKGIFY(test_harness, dst_axis)::*;

program test_program;

  // declare the class instances
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  axis_sequencer_environment #(`AXIS_VIP_PARAMS(test_harness, src_axis), `AXIS_VIP_PARAMS(test_harness, dst_axis)) axis_seq_env;

  watchdog send_data_wd;

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

    axis_seq_env.configure();

    axis_seq_env.run();

    axis_seq_env.src_axis_agent.sequencer.set_data_beat_delay(`SRC_BEAT_DELAY);
    axis_seq_env.src_axis_agent.sequencer.set_descriptor_delay(`SRC_DESCRIPTOR_DELAY);

    axis_seq_env.dst_axis_agent.sequencer.set_high_time(`DEST_BEAT_DELAY_HIGH);
    axis_seq_env.dst_axis_agent.sequencer.set_low_time(`DEST_BEAT_DELAY_LOW);

    case (`DEST_BACKPRESSURE)
      1: axis_seq_env.dst_axis_agent.sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_SINGLE);
      2: axis_seq_env.dst_axis_agent.sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
      default: `FATAL(("Destination backpressure mode parameter incorrect!"));
    endcase

    case (`SRC_DESCRIPTORS)
      1: begin
        axis_seq_env.src_axis_agent.sequencer.set_descriptor_gen_mode(0);
        axis_seq_env.src_axis_agent.sequencer.set_stop_policy(STOP_POLICY_DATA_BEAT);
        // axis_seq_env.src_axis_agent.sequencer.add_xfer_descriptor(32'h600, 1, 0);
        axis_seq_env.src_axis_agent.sequencer.add_xfer_descriptor_packet_size(32'd10, 1, 0);

        send_data_wd = new("Axis Sequencer Watchdog", 1000, "Send data");
      end
      2: begin
        axis_seq_env.src_axis_agent.sequencer.set_descriptor_gen_mode(0);
        axis_seq_env.src_axis_agent.sequencer.set_stop_policy(STOP_POLICY_DESCRIPTOR_QUEUE);
        repeat (10) axis_seq_env.src_axis_agent.sequencer.add_xfer_descriptor(32'h600, 1, 0);

        send_data_wd = new("Axis Sequencer Watchdog", 30000, "Send data");
      end
      3: begin
        axis_seq_env.src_axis_agent.sequencer.set_descriptor_gen_mode(1);
        axis_seq_env.src_axis_agent.sequencer.set_stop_policy(STOP_POLICY_PACKET);
        axis_seq_env.src_axis_agent.sequencer.add_xfer_descriptor(32'h600, 1, 0);

        send_data_wd = new("Axis Sequencer Watchdog", 20000, "Send data");
      end
      default: `FATAL(("Source descriptor parameter incorrect!"));
    endcase

    send_data_wd.start();

    axis_seq_env.src_axis_agent.sequencer.start();

    #1step;

    case (`SRC_DESCRIPTORS)
      1: //axis_seq_env.src_axis_agent.sequencer.beat_sent();
        axis_seq_env.src_axis_agent.sequencer.packet_sent();
      2: axis_seq_env.src_axis_agent.sequencer.wait_empty_descriptor_queue();
      3: begin
        #10us;

        axis_seq_env.src_axis_agent.sequencer.stop();

        axis_seq_env.src_axis_agent.sequencer.packet_sent();
      end
      default: ;
    endcase

    send_data_wd.stop();

    base_env.stop();
    
    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
