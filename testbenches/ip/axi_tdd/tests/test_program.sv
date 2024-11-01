// ***************************************************************************
// ***************************************************************************
// Copyright 2022 (c) Analog Devices, Inc. All rights reserved.
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

import test_harness_env_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_tdd_gen_pkg::*;

program test_program;

  //instantiate the environment
  test_harness_env env;

  //written variables
  int unsigned ch_on  [32];
  int unsigned ch_off [32];

  //read variables
  bit [31:0]   val, expected_val;
  bit [31:0]   ch_en, ch_pol;
  int unsigned burst_count, startup_delay, frame_length;
  int unsigned sync_count_low, sync_count_high;
  bit [ 1:0]   current_state;

  //read variables (interface info)
  int unsigned channel_count, sync_count_width;
  int unsigned reg_count_width, burst_count_width;
  bit          sync_ext_cdc, sync_ext, sync_int;

  //misc variables
  int success_count;
  time tdd_clk_s1, tdd_clk_s2, tdd_clk_per;
  time delay_start, delay_stop, read_delay, expected_delay;

  //internal signals used in verification
  assign idle_state    = (`TH.dut_tdd.inst.tdd_cstate == 2'b00);
  assign armed_state   = (`TH.dut_tdd.inst.tdd_cstate == 2'b01);
  assign waiting_state = (`TH.dut_tdd.inst.tdd_cstate == 2'b10);
  assign running_state = (`TH.dut_tdd.inst.tdd_cstate == 2'b11);

  //sample tdd clk's period
  initial begin
    repeat (10) @(posedge `TH.dut_tdd.inst.clk);
    tdd_clk_s1 = $time;
    @(posedge `TH.dut_tdd.inst.clk);
    tdd_clk_s2 = $time;
    tdd_clk_per = tdd_clk_s2 - tdd_clk_s1;
  end

  initial begin

    //creating environment
    env = new("Axi TDD Environment",
              `TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    #2ps;

    setLoggerVerbosity(ADI_VERBOSITY_NONE);
    env.start();

    start_clocks();
    sys_reset();

    #1us;

    //  -------------------------------------------------------
    //  Test start
    //  -------------------------------------------------------

    // Init test data
    // Read the interface description
    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_INTERFACE_DESCRIPTION), val);
    channel_count     = `GET_TDDN_CNTRL_INTERFACE_DESCRIPTION_CHANNEL_COUNT_EXTRA(val);
    reg_count_width   = `GET_TDDN_CNTRL_INTERFACE_DESCRIPTION_REGISTER_WIDTH(val);
    burst_count_width = `GET_TDDN_CNTRL_INTERFACE_DESCRIPTION_BURST_COUNT_WIDTH(val);
    sync_count_width  = `GET_TDDN_CNTRL_INTERFACE_DESCRIPTION_SYNC_COUNT_WIDTH(val);
    sync_int          = `GET_TDDN_CNTRL_INTERFACE_DESCRIPTION_SYNC_INTERNAL(val);
    sync_ext          = `GET_TDDN_CNTRL_INTERFACE_DESCRIPTION_SYNC_EXTERNAL(val);
    sync_ext_cdc      = `GET_TDDN_CNTRL_INTERFACE_DESCRIPTION_SYNC_EXTERNAL_CDC(val);

    // Register configuration
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_ENABLE),
                       `SET_TDDN_CNTRL_CHANNEL_ENABLE_CHANNEL_ENABLE(32'hFFFFFFFF));

    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY),
                       `SET_TDDN_CNTRL_CHANNEL_POLARITY_CHANNEL_POLARITY(32'h00000000));

    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_BURST_COUNT),
                       `SET_TDDN_CNTRL_BURST_COUNT_BURST_COUNT(channel_count+1));

    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_STARTUP_DELAY),
                       `SET_TDDN_CNTRL_STARTUP_DELAY_STARTUP_DELAY(32'h0000007F));

    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_FRAME_LENGTH),
                       `SET_TDDN_CNTRL_FRAME_LENGTH_FRAME_LENGTH(32'h0000007F));

    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_SYNC_COUNTER_LOW),
                       `SET_TDDN_CNTRL_SYNC_COUNTER_LOW_SYNC_COUNTER_LOW(32'h000001FF));

    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_SYNC_COUNTER_HIGH),
                       `SET_TDDN_CNTRL_SYNC_COUNTER_HIGH_SYNC_COUNTER_HIGH(32'h00000000));

    // Reading back the actual register values (the values may change depending on the synthesis configuration)
    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_ENABLE), ch_en);

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY), ch_pol);

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_BURST_COUNT), burst_count);

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_STARTUP_DELAY), startup_delay);

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_FRAME_LENGTH), frame_length);

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_SYNC_COUNTER_LOW), sync_count_low);

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_SYNC_COUNTER_HIGH), sync_count_high);


    //  -------------------------------------------------------
    //  TEST1: Incremental channel triggering values
    //  -------------------------------------------------------

    // Set the incremental values for each channel
    for (int i=0,j=0,k=0; i<32; i++) begin
      ch_on[i] = j;
      ch_off[i] = k;
      j = j+8;
      k = k+16;
    end 

    for (int i=0; i<32; i++) begin
      env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH0_ON)+i*8,
                         `SET_TDDN_CNTRL_CH0_ON_CH0_ON(ch_on[i]));

      env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH0_OFF)+i*8,
                         `SET_TDDN_CNTRL_CH0_OFF_CH0_OFF(ch_off[i]));
    end 


    // Read back the values; unimplemented channels should not store these values
    for (int i=0; i<32; i++) begin
      env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH0_ON)+i*8, val);

      if (i <= channel_count) begin
        expected_val = ch_on[i];
      end else begin
        expected_val = 0;
      end

      if (val !== expected_val) begin
        `FATAL(("Address 0x%h Expected 0x%h found 0x%h", GetAddrs(TDDN_CNTRL_CH0_ON)+i*8, expected_val, val));
      end else begin
        success_count++;
      end

      env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH0_OFF)+i*8, val);

      if (i <= channel_count) begin
        expected_val = ch_off[i];
      end else begin
        expected_val = 0;
      end

      if (val !== expected_val) begin
        `FATAL(("Address 0x%h Expected 0x%h found 0x%h", GetAddrs(TDDN_CNTRL_CH0_OFF)+i*8, expected_val, val));
      end else begin
        success_count++;
      end
    end 

    // Read the status register to validate the current state 
    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_STATUS), current_state);

    if (current_state !== 2'b00) begin
      `FATAL(("Idle state: Expected 2'b00 found 2'b%b", current_state));
    end else begin
      success_count++;
    end


    // Enable the module; use internal sync for transfer triggering
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_SYNC_SOFT(0)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_EXT(0)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_INT(1)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_RST(0)|
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(1));


    //*********//
    // WAITING //
    //*********//
    @(posedge waiting_state);
    delay_start = $time;

    // Read the status register to validate the current state 
    repeat (8) @(posedge `TH.dut_tdd.inst.up_clk);
    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_STATUS), current_state);

    if (current_state !== 2'b10) begin
      `FATAL(("Waiting state: Expected 2'b10 found 2'b%b", current_state));
    end else begin
      success_count++;
    end


    //*********//
    // RUNNING //
    //*********//
    @(posedge running_state);
    delay_stop = $time;
    read_delay = delay_stop - delay_start;
    expected_delay = (startup_delay+1)*tdd_clk_per;

    // Check the initial startup delay
    if (expected_delay !== read_delay) begin
      `FATAL(("Initial counter delay: Expected %t found %t", expected_delay, read_delay));
    end else begin
      success_count++;
    end

    // Read the status register to validate the current state issuing a parallel thread
    repeat (8) @(posedge `TH.dut_tdd.inst.up_clk);
    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_STATUS), current_state);

    if (current_state !== 2'b11) begin
      `FATAL(("Running state: Expected 2'b11 found 2'b%b", current_state));
    end else begin
      success_count++;
    end

    // Check the pulse length using a loop on all available channels
    check_pulse_length();


    //*******//
    // ARMED //
    //*******//
    // Read the status register to validate the current state 
    repeat (8) @(posedge `TH.dut_tdd.inst.up_clk);
    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_STATUS), current_state);

    if (current_state !== 2'b01) begin
      `FATAL(("Armed state: Expected 2'b01 found 2'b%b", current_state));
    end else begin
      success_count++;
    end

    // Disable the module to change the polarity
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(0));

    // Switch to inverted polarity
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY),
                       `SET_TDDN_CNTRL_CHANNEL_POLARITY_CHANNEL_POLARITY(32'hFFFFFFFF));

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY), ch_pol);

    // Re-enable the module
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_SYNC_SOFT(0)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_EXT(0)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_INT(1)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_RST(0)|
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(1));


    //*********//
    // RUNNING //
    //*********//
    @(posedge running_state);

    // Check the pulse length using a loop on all available channels
    check_pulse_length();


    //*******//
    // ARMED //
    //*******//
    // Disable the module
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(0));

    // Switch to direct polarity
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY),
                       `SET_TDDN_CNTRL_CHANNEL_POLARITY_CHANNEL_POLARITY(32'h00000000));

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY), ch_pol);


    //  -------------------------------------------------------
    //  TEST2: High duty triggering values
    //  -------------------------------------------------------

    // Set the values of each specific channel
    for (int i=0,j=0,k=frame_length; i<32; i++) begin
      ch_on[i] = j;
      ch_off[i] = k;
      j = j+8;
      k = k-8;
    end 

    for (int i=0; i<32; i++) begin
      env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH0_ON)+i*8,
                         `SET_TDDN_CNTRL_CH0_ON_CH0_ON(ch_on[i]));

      env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH0_OFF)+i*8,
                         `SET_TDDN_CNTRL_CH0_OFF_CH0_OFF(ch_off[i]));
    end 

    // Read back the values; unimplemented channels should not store these values
    for (int i=0; i<32; i++) begin
      env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH0_ON)+i*8, val);

      if (i <= channel_count) begin
        expected_val = ch_on[i];
      end else begin
        expected_val = 0;
      end

      if (val !== expected_val) begin
        `FATAL(("Address 0x%h Expected 0x%h found 0x%h", GetAddrs(TDDN_CNTRL_CH0_ON)+i*8, expected_val, val));
      end else begin
        success_count++;
      end

      env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_CH0_OFF)+i*8, val);

      if (i <= channel_count) begin
        expected_val = ch_off[i];
      end else begin
        expected_val = 0;
      end

      if (val !== expected_val) begin
        `FATAL(("Address 0x%h Expected 0x%h found 0x%h", GetAddrs(TDDN_CNTRL_CH0_OFF)+i*8, expected_val, val));
      end else begin
        success_count++;
      end
    end 


    // Enable the module; use external sync for transfer triggering
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_SYNC_SOFT(0)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_EXT(1)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_INT(0)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_RST(0)|
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(1));

    // Trigger an external sync on the input pin
    trigger_ext_event();


    //*********//
    // RUNNING //
    //*********//
    @(posedge running_state);

    // Check the pulse length using a loop on all available channels
    check_pulse_length();


    //*******//
    // ARMED //
    //*******//
    // Disable the module
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(0));

    // Switch to inverted polarity
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY),
                       `SET_TDDN_CNTRL_CHANNEL_POLARITY_CHANNEL_POLARITY(32'hFFFFFFFF));

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY), ch_pol);

    // Keep the module enabled; issue a software sync
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_SYNC_SOFT(1)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_EXT(0)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_INT(0)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_RST(0)|
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(1));


    //*********//
    // RUNNING //
    //*********//
    @(posedge running_state);

    // Check the pulse length using a loop on all available channels
    check_pulse_length();


    //*******//
    // ARMED //
    //*******//
    // Disable the module
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(0));

    // Switch to direct polarity
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY),
                       `SET_TDDN_CNTRL_CHANNEL_POLARITY_CHANNEL_POLARITY(32'h00000000));

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY), ch_pol);


    //  -------------------------------------------------------
    //  TEST3: Testing some special features
    //  -------------------------------------------------------

    // Increase the burst count value by 1
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_BURST_COUNT),
                       `SET_TDDN_CNTRL_BURST_COUNT_BURST_COUNT(channel_count+2));

    // Keep the module enabled; issue a software sync; enable external sync and reset on sync
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_SYNC_SOFT(1)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_EXT(1)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_INT(0)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_RST(1)|
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(1));


    //*********//
    // RUNNING //
    //*********//
    @(posedge running_state);

    // Trigger an external sync on the input pin
    // Since the initial software sync started the frame, the external sync will reset the tdd counter
    // Test this by issuing a parralel thread which counts and expects that the number of channel[0] sets per initial frame is 3
    fork
      trigger_ext_event();
      repeat (3) @(posedge `TH.dut_tdd.inst.genblk1[0].i_channel.tdd_ch_set);
    join

    // Check the burst count value, thus validating that the TDD is still transferring the first frame
    if (`TH.dut_tdd.inst.i_counter.tdd_burst_counter !== (channel_count+2)) begin
      `FATAL(("Burst counter: Expected %d found %d", channel_count+1, `TH.dut_tdd.inst.i_counter.tdd_burst_counter));
    end else begin
      success_count++;
    end

    // Disable the module before the end of the burst
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(0));

    @(posedge `TH.dut_tdd.inst.tdd_endof_frame);

    // Check the pulse length using a loop on all available channels
    check_pulse_length();

    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_ENABLE),
                       `SET_TDDN_CNTRL_CHANNEL_ENABLE_CHANNEL_ENABLE(0));

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_ENABLE), ch_en);

    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_BURST_COUNT),
                       `SET_TDDN_CNTRL_BURST_COUNT_BURST_COUNT(0));

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_BURST_COUNT), burst_count);

    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_STARTUP_DELAY),
                       `SET_TDDN_CNTRL_STARTUP_DELAY_STARTUP_DELAY(0));

    env.mng.RegRead32(`TDD_BA+GetAddrs(TDDN_CNTRL_STARTUP_DELAY), startup_delay);


    // Enable the module with external synchronization actived
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_SYNC_SOFT(0)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_EXT(1)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_INT(0)|
                       `SET_TDDN_CNTRL_CONTROL_SYNC_RST(0)|
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(1));

    // Trigger an external sync on the input pin
    trigger_ext_event();

    // Test a continuous burst
    ch_en = 32'b1;

    // Enable the channels one by one
    for (int i=0; i<channel_count; i++) begin
      @(posedge `TH.dut_tdd.inst.tdd_endof_frame);

      if (`TH.dut_tdd.inst.i_counter.tdd_burst_counter !== 0) begin
        `FATAL(("Burst counter: Expected 0 found %d", `TH.dut_tdd.inst.i_counter.tdd_burst_counter));
      end else begin
        success_count++;
      end

      env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_ENABLE),
                         `SET_TDDN_CNTRL_CHANNEL_ENABLE_CHANNEL_ENABLE(ch_en));

      ch_en = (ch_en << 1) | 32'b1;

    end


    // Disable the channels one by one
    for (int i=0; i<channel_count+2; i++) begin
      @(posedge `TH.dut_tdd.inst.tdd_endof_frame);

      if (`TH.dut_tdd.inst.i_counter.tdd_burst_counter !== 0) begin
        `FATAL(("Burst counter: Expected 0 found %d", `TH.dut_tdd.inst.i_counter.tdd_burst_counter));
      end else begin
        success_count++;
      end

      env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CHANNEL_ENABLE),
                         `SET_TDDN_CNTRL_CHANNEL_ENABLE_CHANNEL_ENABLE(ch_en));

      ch_en = (ch_en >> 1);

    end

    // Disable the module
    env.mng.RegWrite32(`TDD_BA+GetAddrs(TDDN_CNTRL_CONTROL),
                       `SET_TDDN_CNTRL_CONTROL_ENABLE(0));

    stop_clocks();

    `INFO(("Testbench finished!"), ADI_VERBOSITY_NONE);
    $finish;

  end


  task start_clocks();
    `TH.`DEVICE_CLK.inst.IF.start_clock;
  endtask


  task stop_clocks();
    `TH.`DEVICE_CLK.inst.IF.stop_clock;
  endtask


  task sys_reset();
    //asserts all the resets for 100 ns
    `TH.`SYS_RST.inst.IF.assert_reset;
    #100
    `TH.`SYS_RST.inst.IF.deassert_reset;
  endtask


  task trigger_ext_event();
    #20ns;
    `TB.sync_in =1'b1;
    #10ns;
    `TB.sync_in =1'b0;
    #50ns;
    `TB.sync_in =1'b1;
    #20ns;
    `TB.sync_in =1'b0;
  endtask


  task check_pulse_length();
    for (int i=0; i<=channel_count; i++) begin
      time t1=0, t2=0, expected_pulse_lengh;

      fork
        channel_probe(i, t1, t2);
      join_none
      @(posedge `TH.dut_tdd.inst.tdd_endof_frame);
      repeat (3) @(posedge `TH.dut_tdd.inst.clk);
      disable fork;

      if (ch_on[i] == ch_off[i]) begin
        expected_pulse_lengh = 0;
      end else begin
        expected_pulse_lengh = (ch_off[i] - ch_on[i])*tdd_clk_per;
      end

      if (expected_pulse_lengh !== (t2-t1)) begin
        `FATAL(("Pulse length channel[%2d]: Expected %t found %t", i, expected_pulse_lengh, t2-t1));
      end else begin
        success_count++;
      end
    end
  endtask


  task channel_probe (input int i, output time t1, t2);
    t1 = $time;
    t2 = $time;

    if (!ch_pol[i]) @(posedge `TB.tdd_channel[i]);
    else            @(negedge `TB.tdd_channel[i]);
    t1 = $time;

    if (!ch_pol[i]) @(negedge `TB.tdd_channel[i]);
    else            @(posedge `TB.tdd_channel[i]);
    t2 = $time;
  endtask

endprogram
