// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2023 (c) Analog Devices, Inc. All rights reserved.
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
import adi_regmap_common_pkg::*;
import adi_regmap_pwm_gen_pkg::*;

`define AXI_PWMGEN     32'h7c00_0000

program test_program (
  input    pwm_gen_o_0,
  input    pwm_gen_o_1,
  input    pwm_gen_o_2,
  input    pwm_gen_o_3,
  input    pwm_gen_o_4,
  input    pwm_gen_o_5,
  input    pwm_gen_o_6,
  input    pwm_gen_o_7,
  input    pwm_gen_o_8,
  input    pwm_gen_o_9,
  input    pwm_gen_o_10,
  input    pwm_gen_o_11,
  input    pwm_gen_o_12,
  input    pwm_gen_o_13,
  input    pwm_gen_o_14,
  input    pwm_gen_o_15,

  input    sys_clk);

  test_harness_env env;

// --------------------------
// Wrapper function for AXI read verif
// --------------------------
task axi_read_v(
    input   [31:0]  raddr,
    input   [31:0]  vdata);
begin
  env.mng.RegReadVerify32(raddr,vdata);
end
endtask

task axi_read(
    input   [31:0]  raddr,
    output  [31:0]  data);
begin
  env.mng.RegRead32(raddr,data);
end
endtask

// --------------------------
// Wrapper function for AXI write
// --------------------------
task axi_write;
  input [31:0]  waddr;
  input [31:0]  wdata;
begin
  env.mng.RegWrite32(waddr,wdata);
end
endtask

  initial begin

    //creating environment
     env = new(`TH.`SYS_CLK.inst.IF,
            `TH.`DMA_CLK.inst.IF,
            `TH.`DDR_CLK.inst.IF,
            `TH.`MNG_AXI.inst.IF,
            `TH.`DDR_AXI.inst.IF);

     #2ps;
     setLoggerVerbosity(6);
     env.start();

     //asserts all the resets for 100 ns
     `TH.`SYS_RST.inst.IF.assert_reset;
     #100
     `TH.`SYS_RST.inst.IF.deassert_reset;
     #100

     #100 sanity_test;
     #100 test_config;
     `INFO(("Test Done"));

     $finish;

  end

task sanity_test;
   begin
    // check PWM_GEN N_PWMS
    logic [31:0] n_pwms = 'h0;
    axi_read(`AXI_PWMGEN + GetAddrs(REG_N_PWMS),n_pwms);
    $display("[%t] Sanity Test Done. %h", $time, n_pwms);
  end
endtask

task test_config;
  begin
    #100 axi_write (`AXI_PWMGEN + GetAddrs(REG_RSTN), `SET_REG_RSTN_RESET(0)); // PWM_GEN reset in regmap (ACTIVE HIGH)
    #100 axi_write (`AXI_PWMGEN + GetAddrs(REG_PULSE_0_PERIOD), `SET_REG_PULSE_0_PERIOD_PULSE_0_PERIOD('d10)); // set PWM period
    #100 axi_write (`AXI_PWMGEN + GetAddrs(REG_PULSE_0_WIDTH), `SET_REG_PULSE_0_WIDTH_PULSE_0_WIDTH('d4)); // set PWM width
    #100 axi_write (`AXI_PWMGEN + GetAddrs(REG_PULSE_15_PERIOD), `SET_REG_PULSE_15_PERIOD_PULSE_15_PERIOD('d10)); // set PWM period
    #100 axi_write (`AXI_PWMGEN + GetAddrs(REG_PULSE_15_WIDTH), `SET_REG_PULSE_15_WIDTH_PULSE_15_WIDTH('d6)); // set PWM width
    #100 axi_write (`AXI_PWMGEN + GetAddrs(REG_PULSE_15_OFFSET), `SET_REG_PULSE_15_OFFSET_PULSE_15_OFFSET('d2)); // set PWM offset

    #100 axi_write (`AXI_PWMGEN + GetAddrs(REG_RSTN), `SET_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
 
    $display("[%t] axi_pwm_gen started.", $time);
    #100000;

    axi_write (`AXI_PWMGEN + 32'h00000010, 'h2); // stop PWM_GEN
    $display("[%t] axi_pwm_gen stopped.", $time);
  end
endtask

endprogram
