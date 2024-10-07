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

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import m_axis_sequencer_pkg::*;
import s_axis_sequencer_pkg::*;
import logger_pkg::*;
import environment_pkg::*;
import watchdog_pkg::*;

//=============================================================================
// Register Maps
//=============================================================================

program test_program;

  // declare the class instances
  environment env;

  watchdog send_data_wd;

  initial begin

    // create environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF,
              `TH.`SRC_AXIS.inst.IF,
              `TH.`DST_AXIS.inst.IF
             );

    #1step;

    setLoggerVerbosity(250);
    
    env.start();
    env.sys_reset();

    env.configure();

    env.run();

    env.src_axis_seq.set_data_beat_delay(`SRC_BEAT_DELAY);
    env.src_axis_seq.set_descriptor_delay(`SRC_DESCRIPTOR_DELAY);

    env.dst_axis_seq.set_high_time(`DEST_BEAT_DELAY_HIGH);
    env.dst_axis_seq.set_low_time(`DEST_BEAT_DELAY_LOW);

    case (`DEST_BACKPRESSURE)
      1: env.dst_axis_seq.set_mode(XIL_AXI4STREAM_READY_GEN_SINGLE);
      2: env.dst_axis_seq.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
      default: `ERROR(("Destination backpressure mode parameter incorrect!"));
    endcase

    case (`SRC_DESCRIPTORS)
      1: begin
        env.src_axis_seq.set_descriptor_gen_mode(0);
        env.src_axis_seq.set_stop_policy(STOP_POLICY_DATA_BEAT);
        // env.src_axis_seq.add_xfer_descriptor(32'h600, 1, 0);
        env.src_axis_seq.add_xfer_descriptor_packet_size(32'd10, 1, 0);

        send_data_wd = new(1000, "Send data");
      end
      2: begin
        env.src_axis_seq.set_descriptor_gen_mode(0);
        env.src_axis_seq.set_stop_policy(STOP_POLICY_DESCRIPTOR_QUEUE);
        repeat (10) env.src_axis_seq.add_xfer_descriptor(32'h600, 1, 0);

        send_data_wd = new(30000, "Send data");
      end
      3: begin
        env.src_axis_seq.set_descriptor_gen_mode(1);
        env.src_axis_seq.set_stop_policy(STOP_POLICY_PACKET);
        env.src_axis_seq.add_xfer_descriptor(32'h600, 1, 0);

        send_data_wd = new(20000, "Send data");
      end
      default:
        `ERROR(("Source descriptor parameter incorrect!"));
    endcase

    send_data_wd.start();

    env.src_axis_seq.start();

    #1step;

    case (`SRC_DESCRIPTORS)
      1: //env.src_axis_seq.beat_sent();
        env.src_axis_seq.packet_sent();
      2: env.src_axis_seq.wait_empty_descriptor_queue();
      3: begin
        #10us;

        env.src_axis_seq.stop();

        env.src_axis_seq.packet_sent();
      end
      default: ;
    endcase

    send_data_wd.stop();

    env.stop();
    
    `INFO(("Test bench done!"));
    $finish();

  end

endprogram
