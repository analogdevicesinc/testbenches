// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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
`include "axi_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import pwmgen_environment_pkg::*;
import pwm_gen_api_pkg::*;
import watchdog_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program (
  inout pwm_0);

  timeunit 1ns;
  timeprecision 1ps;

   // declare the class instances
  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  pwmgen_environment pwm_env;
  pwm_gen_api pwm_api;
  watchdog pwm_wd;

    task set_duty_cycle(int duty_percent);
        int width;
        width = (`PULSE_0_PERIOD * duty_percent) / 100;
        pwm_wd.reset();
        pwm_api.pulse_width_config(0, width);
        pwm_api.load_config();
        `INFO(("Set duty cycle to %0d%%", duty_percent), ADI_VERBOSITY_NONE);
        #12800ns;
    endtask

  initial begin
    
        // create environment
    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(`IRQ_C_BA),
      .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));
  

    mng = new("", `TH.`MNG_AXI.inst.IF);
    ddr = new("", `TH.`DDR_AXI.inst.IF);

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

     // create PWM environment
    pwm_env = new("PWM Environment",
                  `TH.`PWM_CLK.inst.IF);

    pwm_api = new("PWM API",
              base_env.mng.master_sequencer,
              `AXI_PWM_GEN_BA);

    pwm_wd = new("PWM Watchdog", 500000, "PWM test");
  
    setLoggerVerbosity(ADI_VERBOSITY_HIGH);

    `TH.`SYS_CLK.inst.IF.set_clk_frq(.user_frequency(125000000));

    base_env.start();
    pwm_env.start();
    pwm_wd.start();

    base_env.sys_reset();

    pwm_api.start();
    pwm_api.load_config();

     #12800ns;

     set_duty_cycle(25);
     set_duty_cycle(50);
     set_duty_cycle(75);
     set_duty_cycle(100);


    #100ns;

    pwm_wd.stop();
    pwm_env.stop();
    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();


  end
endprogram