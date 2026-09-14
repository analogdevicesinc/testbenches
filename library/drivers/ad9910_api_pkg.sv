// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2024 Analog Devices, Inc. All rights reserved.
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

package ad9910_api_pkg;

  import logger_pkg::*;
  import adi_api_pkg::*;
  import adi_regmap_ad9910_pkg::*;
  import adi_regmap_pkg::*;
  import m_axi_sequencer_pkg::*;

  // Register access for the axi_ad9910 IP. Per coding_guidelines I3/I4 all
  // register touches for this IP live here, not in the test programs; the test
  // programs keep the checks and the waveform measurements.
  class ad9910_api extends adi_api;

    protected logic [31:0] val;

    function new(
      input string name,
      input m_axi_sequencer_base bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, bus, base_address, parent);
    endfunction: new

    // I2: version and scratch. This IP has no CORE_MAGIC register, so the
    // magic check other APIs perform is not applicable.
    task sanity_test();
      this.axi_verify(GetAddrs(AXI_AD9910_REG_VERSION),
        `SET_AXI_AD9910_REG_VERSION_VERSION(`DEFAULT_AXI_AD9910_REG_VERSION_VERSION));
      this.axi_write(GetAddrs(AXI_AD9910_REG_SCRATCH), `SET_AXI_AD9910_REG_SCRATCH_SCRATCH(32'hdeadbeef));
      this.axi_verify(GetAddrs(AXI_AD9910_REG_SCRATCH), `SET_AXI_AD9910_REG_SCRATCH_SCRATCH(32'hdeadbeef));
    endtask: sanity_test

    // REG_VERSION
    task get_version(
      output bit [31:0] version);

      this.axi_read(GetAddrs(AXI_AD9910_REG_VERSION), this.val);
      version = `GET_AXI_AD9910_REG_VERSION_VERSION(this.val);
    endtask: get_version

    // REG_ID
    task get_id(
      output bit [31:0] id);

      this.axi_read(GetAddrs(AXI_AD9910_REG_ID), this.val);
      id = `GET_AXI_AD9910_REG_ID_ID(this.val);
    endtask: get_id

    // REG_SCRATCH
    task set_scratch(
      input bit [31:0] scratch);

      this.axi_write(GetAddrs(AXI_AD9910_REG_SCRATCH),
        `SET_AXI_AD9910_REG_SCRATCH_SCRATCH(scratch));
    endtask: set_scratch

    task verify_scratch(
      input bit [31:0] scratch);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_SCRATCH), `SET_AXI_AD9910_REG_SCRATCH_SCRATCH(scratch));
    endtask: verify_scratch

    task get_scratch(
      output bit [31:0] scratch);

      this.axi_read(GetAddrs(AXI_AD9910_REG_SCRATCH), this.val);
      scratch = `GET_AXI_AD9910_REG_SCRATCH_SCRATCH(this.val);
    endtask: get_scratch

    // REG_CONFIG
    task get_config(
      output bit measure_clks_en);

      this.axi_read(GetAddrs(AXI_AD9910_REG_CONFIG), this.val);
      measure_clks_en = `GET_AXI_AD9910_REG_CONFIG_MEASURE_CLKS_EN(this.val);
    endtask: get_config

    // REG_DEVICE_INFO
    task get_device_info(
      output bit [7:0] fpga_technology,
      output bit [7:0] fpga_family,
      output bit [7:0] speed_grade,
      output bit [7:0] dev_package);

      this.axi_read(GetAddrs(AXI_AD9910_REG_DEVICE_INFO), this.val);
      fpga_technology = `GET_AXI_AD9910_REG_DEVICE_INFO_FPGA_TECHNOLOGY(this.val);
      fpga_family = `GET_AXI_AD9910_REG_DEVICE_INFO_FPGA_FAMILY(this.val);
      speed_grade = `GET_AXI_AD9910_REG_DEVICE_INFO_SPEED_GRADE(this.val);
      dev_package = `GET_AXI_AD9910_REG_DEVICE_INFO_DEV_PACKAGE(this.val);
    endtask: get_device_info

    // REG_RESET_CTRL
    task set_reset_ctrl(
      input bit reset);

      this.axi_write(GetAddrs(AXI_AD9910_REG_RESET_CTRL),
        `SET_AXI_AD9910_REG_RESET_CTRL_RESET(reset));
    endtask: set_reset_ctrl

    task verify_reset_ctrl(
      input bit reset);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_RESET_CTRL), `SET_AXI_AD9910_REG_RESET_CTRL_RESET(reset));
    endtask: verify_reset_ctrl

    task get_reset_ctrl(
      output bit reset);

      this.axi_read(GetAddrs(AXI_AD9910_REG_RESET_CTRL), this.val);
      reset = `GET_AXI_AD9910_REG_RESET_CTRL_RESET(this.val);
    endtask: get_reset_ctrl

    // REG_IRQ_MASK
    task set_irq_mask(
      input bit [5:0] irq_mask);

      this.axi_write(GetAddrs(AXI_AD9910_REG_IRQ_MASK),
        `SET_AXI_AD9910_REG_IRQ_MASK_IRQ_MASK(irq_mask));
    endtask: set_irq_mask

    task verify_irq_mask(
      input bit [5:0] irq_mask);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_IRQ_MASK), `SET_AXI_AD9910_REG_IRQ_MASK_IRQ_MASK(irq_mask));
    endtask: verify_irq_mask

    task get_irq_mask(
      output bit [5:0] irq_mask);

      this.axi_read(GetAddrs(AXI_AD9910_REG_IRQ_MASK), this.val);
      irq_mask = `GET_AXI_AD9910_REG_IRQ_MASK_IRQ_MASK(this.val);
    endtask: get_irq_mask

    // REG_IRQ_TABLE
    task set_irq_table(
      input bit [5:0] irq_table);

      this.axi_write(GetAddrs(AXI_AD9910_REG_IRQ_TABLE),
        `SET_AXI_AD9910_REG_IRQ_TABLE_IRQ_TABLE(irq_table));
    endtask: set_irq_table

    task verify_irq_table(
      input bit [5:0] irq_table);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_IRQ_TABLE), `SET_AXI_AD9910_REG_IRQ_TABLE_IRQ_TABLE(irq_table));
    endtask: verify_irq_table

    task get_irq_table(
      output bit [5:0] irq_table);

      this.axi_read(GetAddrs(AXI_AD9910_REG_IRQ_TABLE), this.val);
      irq_table = `GET_AXI_AD9910_REG_IRQ_TABLE_IRQ_TABLE(this.val);
    endtask: get_irq_table

    // REG_IRQ_MON_CFG
    task set_irq_mon_cfg(
      input bit [1:0] irq_monitor_config);

      this.axi_write(GetAddrs(AXI_AD9910_REG_IRQ_MON_CFG),
        `SET_AXI_AD9910_REG_IRQ_MON_CFG_IRQ_MONITOR_CONFIG(irq_monitor_config));
    endtask: set_irq_mon_cfg

    task verify_irq_mon_cfg(
      input bit [1:0] irq_monitor_config);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_IRQ_MON_CFG), `SET_AXI_AD9910_REG_IRQ_MON_CFG_IRQ_MONITOR_CONFIG(irq_monitor_config));
    endtask: verify_irq_mon_cfg

    task get_irq_mon_cfg(
      output bit [1:0] irq_monitor_config);

      this.axi_read(GetAddrs(AXI_AD9910_REG_IRQ_MON_CFG), this.val);
      irq_monitor_config = `GET_AXI_AD9910_REG_IRQ_MON_CFG_IRQ_MONITOR_CONFIG(this.val);
    endtask: get_irq_mon_cfg

    // REG_TRIG_OUT_CTRL
    task set_trig_out_ctrl(
      input bit [5:0] trig_out_mask,
      input bit [1:0] trig_config);

      this.axi_write(GetAddrs(AXI_AD9910_REG_TRIG_OUT_CTRL),
        `SET_AXI_AD9910_REG_TRIG_OUT_CTRL_TRIG_OUT_MASK(trig_out_mask) |
        `SET_AXI_AD9910_REG_TRIG_OUT_CTRL_TRIG_CONFIG(trig_config));
    endtask: set_trig_out_ctrl

    task get_trig_out_ctrl(
      output bit [5:0] trig_out_mask,
      output bit [1:0] trig_config);

      this.axi_read(GetAddrs(AXI_AD9910_REG_TRIG_OUT_CTRL), this.val);
      trig_out_mask = `GET_AXI_AD9910_REG_TRIG_OUT_CTRL_TRIG_OUT_MASK(this.val);
      trig_config = `GET_AXI_AD9910_REG_TRIG_OUT_CTRL_TRIG_CONFIG(this.val);
    endtask: get_trig_out_ctrl

    // REG_EXT_TRIG_CFG
    task set_ext_trig_cfg(
      input bit ext_sync_disarm,
      input bit ext_sync_arm);

      this.axi_write(GetAddrs(AXI_AD9910_REG_EXT_TRIG_CFG),
        `SET_AXI_AD9910_REG_EXT_TRIG_CFG_EXT_SYNC_DISARM(ext_sync_disarm) |
        `SET_AXI_AD9910_REG_EXT_TRIG_CFG_EXT_SYNC_ARM(ext_sync_arm));
    endtask: set_ext_trig_cfg

    task get_ext_trig_cfg(
      output bit ext_sync_disarm,
      output bit ext_sync_arm);

      this.axi_read(GetAddrs(AXI_AD9910_REG_EXT_TRIG_CFG), this.val);
      ext_sync_disarm = `GET_AXI_AD9910_REG_EXT_TRIG_CFG_EXT_SYNC_DISARM(this.val);
      ext_sync_arm = `GET_AXI_AD9910_REG_EXT_TRIG_CFG_EXT_SYNC_ARM(this.val);
    endtask: get_ext_trig_cfg

    // REG_SYNC_CLK_CNT
    task get_sync_clk_cnt(
      output bit [31:0] sync_clk_count);

      this.axi_read(GetAddrs(AXI_AD9910_REG_SYNC_CLK_CNT), this.val);
      sync_clk_count = `GET_AXI_AD9910_REG_SYNC_CLK_CNT_SYNC_CLK_COUNT(this.val);
    endtask: get_sync_clk_cnt

    // REG_DRG_CTRL
    task set_drg_ctrl(
      input bit drctl_toggle_en,
      input bit drctl_init,
      input bit drhold);

      this.axi_write(GetAddrs(AXI_AD9910_REG_DRG_CTRL),
        `SET_AXI_AD9910_REG_DRG_CTRL_DRCTL_TOGGLE_EN(drctl_toggle_en) |
        `SET_AXI_AD9910_REG_DRG_CTRL_DRCTL_INIT(drctl_init) |
        `SET_AXI_AD9910_REG_DRG_CTRL_DRHOLD(drhold));
    endtask: set_drg_ctrl

    task get_drg_ctrl(
      output bit drctl_toggle_en,
      output bit drctl_init,
      output bit drhold);

      this.axi_read(GetAddrs(AXI_AD9910_REG_DRG_CTRL), this.val);
      drctl_toggle_en = `GET_AXI_AD9910_REG_DRG_CTRL_DRCTL_TOGGLE_EN(this.val);
      drctl_init = `GET_AXI_AD9910_REG_DRG_CTRL_DRCTL_INIT(this.val);
      drhold = `GET_AXI_AD9910_REG_DRG_CTRL_DRHOLD(this.val);
    endtask: get_drg_ctrl

    // REG_PROFILE
    task set_profile(
      input bit [2:0] profile);

      this.axi_write(GetAddrs(AXI_AD9910_REG_PROFILE),
        `SET_AXI_AD9910_REG_PROFILE_PROFILE(profile));
    endtask: set_profile

    task verify_profile(
      input bit [2:0] profile);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_PROFILE), `SET_AXI_AD9910_REG_PROFILE_PROFILE(profile));
    endtask: verify_profile

    task get_profile(
      output bit [2:0] profile);

      this.axi_read(GetAddrs(AXI_AD9910_REG_PROFILE), this.val);
      profile = `GET_AXI_AD9910_REG_PROFILE_PROFILE(this.val);
    endtask: get_profile

    // REG_DRCTL_PERIOD
    task set_drctl_period(
      input bit [31:0] drctl_period);

      this.axi_write(GetAddrs(AXI_AD9910_REG_DRCTL_PERIOD),
        `SET_AXI_AD9910_REG_DRCTL_PERIOD_DRCTL_PERIOD(drctl_period));
    endtask: set_drctl_period

    task verify_drctl_period(
      input bit [31:0] drctl_period);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_DRCTL_PERIOD), `SET_AXI_AD9910_REG_DRCTL_PERIOD_DRCTL_PERIOD(drctl_period));
    endtask: verify_drctl_period

    task get_drctl_period(
      output bit [31:0] drctl_period);

      this.axi_read(GetAddrs(AXI_AD9910_REG_DRCTL_PERIOD), this.val);
      drctl_period = `GET_AXI_AD9910_REG_DRCTL_PERIOD_DRCTL_PERIOD(this.val);
    endtask: get_drctl_period

    // REG_DRCTL_WIDTH
    task set_drctl_width(
      input bit [31:0] drctl_width);

      this.axi_write(GetAddrs(AXI_AD9910_REG_DRCTL_WIDTH),
        `SET_AXI_AD9910_REG_DRCTL_WIDTH_DRCTL_WIDTH(drctl_width));
    endtask: set_drctl_width

    task verify_drctl_width(
      input bit [31:0] drctl_width);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_DRCTL_WIDTH), `SET_AXI_AD9910_REG_DRCTL_WIDTH_DRCTL_WIDTH(drctl_width));
    endtask: verify_drctl_width

    task get_drctl_width(
      output bit [31:0] drctl_width);

      this.axi_read(GetAddrs(AXI_AD9910_REG_DRCTL_WIDTH), this.val);
      drctl_width = `GET_AXI_AD9910_REG_DRCTL_WIDTH_DRCTL_WIDTH(this.val);
    endtask: get_drctl_width

    // REG_BST_DELAY
    task set_bst_delay(
      input bit [31:0] delay_bst_ramp_delay);

      this.axi_write(GetAddrs(AXI_AD9910_REG_BST_DELAY),
        `SET_AXI_AD9910_REG_BST_DELAY_DELAY_BST_RAMP_DELAY(delay_bst_ramp_delay));
    endtask: set_bst_delay

    task verify_bst_delay(
      input bit [31:0] delay_bst_ramp_delay);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_BST_DELAY), `SET_AXI_AD9910_REG_BST_DELAY_DELAY_BST_RAMP_DELAY(delay_bst_ramp_delay));
    endtask: verify_bst_delay

    task get_bst_delay(
      output bit [31:0] delay_bst_ramp_delay);

      this.axi_read(GetAddrs(AXI_AD9910_REG_BST_DELAY), this.val);
      delay_bst_ramp_delay = `GET_AXI_AD9910_REG_BST_DELAY_DELAY_BST_RAMP_DELAY(this.val);
    endtask: get_bst_delay

    // REG_RAMP_BURSTS
    task set_ramp_bursts(
      input bit [19:0] ramp_bursts);

      this.axi_write(GetAddrs(AXI_AD9910_REG_RAMP_BURSTS),
        `SET_AXI_AD9910_REG_RAMP_BURSTS_RAMP_BURSTS(ramp_bursts));
    endtask: set_ramp_bursts

    task verify_ramp_bursts(
      input bit [19:0] ramp_bursts);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_RAMP_BURSTS), `SET_AXI_AD9910_REG_RAMP_BURSTS_RAMP_BURSTS(ramp_bursts));
    endtask: verify_ramp_bursts

    task get_ramp_bursts(
      output bit [19:0] ramp_bursts);

      this.axi_read(GetAddrs(AXI_AD9910_REG_RAMP_BURSTS), this.val);
      ramp_bursts = `GET_AXI_AD9910_REG_RAMP_BURSTS_RAMP_BURSTS(this.val);
    endtask: get_ramp_bursts

    // REG_BURST_DELAY
    task set_burst_delay(
      input bit [31:0] burst_delay);

      this.axi_write(GetAddrs(AXI_AD9910_REG_BURST_DELAY),
        `SET_AXI_AD9910_REG_BURST_DELAY_BURST_DELAY(burst_delay));
    endtask: set_burst_delay

    task verify_burst_delay(
      input bit [31:0] burst_delay);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_BURST_DELAY), `SET_AXI_AD9910_REG_BURST_DELAY_BURST_DELAY(burst_delay));
    endtask: verify_burst_delay

    task get_burst_delay(
      output bit [31:0] burst_delay);

      this.axi_read(GetAddrs(AXI_AD9910_REG_BURST_DELAY), this.val);
      burst_delay = `GET_AXI_AD9910_REG_BURST_DELAY_BURST_DELAY(this.val);
    endtask: get_burst_delay

    // REG_RAMP_CFG
    task set_ramp_cfg(
      input bit [1:0] ramp_config);

      this.axi_write(GetAddrs(AXI_AD9910_REG_RAMP_CFG),
        `SET_AXI_AD9910_REG_RAMP_CFG_RAMP_CONFIG(ramp_config));
    endtask: set_ramp_cfg

    task verify_ramp_cfg(
      input bit [1:0] ramp_config);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_RAMP_CFG), `SET_AXI_AD9910_REG_RAMP_CFG_RAMP_CONFIG(ramp_config));
    endtask: verify_ramp_cfg

    task get_ramp_cfg(
      output bit [1:0] ramp_config);

      this.axi_read(GetAddrs(AXI_AD9910_REG_RAMP_CFG), this.val);
      ramp_config = `GET_AXI_AD9910_REG_RAMP_CFG_RAMP_CONFIG(this.val);
    endtask: get_ramp_cfg

    // REG_MONITOR_MAX_PERIOD
    task set_monitor_max_period(
      input bit [31:0] monitor_max_period);

      this.axi_write(GetAddrs(AXI_AD9910_REG_MONITOR_MAX_PERIOD),
        `SET_AXI_AD9910_REG_MONITOR_MAX_PERIOD_MONITOR_MAX_PERIOD(monitor_max_period));
    endtask: set_monitor_max_period

    task verify_monitor_max_period(
      input bit [31:0] monitor_max_period);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_MONITOR_MAX_PERIOD), `SET_AXI_AD9910_REG_MONITOR_MAX_PERIOD_MONITOR_MAX_PERIOD(monitor_max_period));
    endtask: verify_monitor_max_period

    task get_monitor_max_period(
      output bit [31:0] monitor_max_period);

      this.axi_read(GetAddrs(AXI_AD9910_REG_MONITOR_MAX_PERIOD), this.val);
      monitor_max_period = `GET_AXI_AD9910_REG_MONITOR_MAX_PERIOD_MONITOR_MAX_PERIOD(this.val);
    endtask: get_monitor_max_period

    // REG_IRQ_START_INTERVAL
    task set_irq_start_interval(
      input bit [31:0] irq_start_interval);

      this.axi_write(GetAddrs(AXI_AD9910_REG_IRQ_START_INTERVAL),
        `SET_AXI_AD9910_REG_IRQ_START_INTERVAL_IRQ_START_INTERVAL(irq_start_interval));
    endtask: set_irq_start_interval

    task verify_irq_start_interval(
      input bit [31:0] irq_start_interval);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_IRQ_START_INTERVAL), `SET_AXI_AD9910_REG_IRQ_START_INTERVAL_IRQ_START_INTERVAL(irq_start_interval));
    endtask: verify_irq_start_interval

    task get_irq_start_interval(
      output bit [31:0] irq_start_interval);

      this.axi_read(GetAddrs(AXI_AD9910_REG_IRQ_START_INTERVAL), this.val);
      irq_start_interval = `GET_AXI_AD9910_REG_IRQ_START_INTERVAL_IRQ_START_INTERVAL(this.val);
    endtask: get_irq_start_interval

    // REG_IRQ_STOP_INTERVAL
    task set_irq_stop_interval(
      input bit [31:0] irq_stop_interval);

      this.axi_write(GetAddrs(AXI_AD9910_REG_IRQ_STOP_INTERVAL),
        `SET_AXI_AD9910_REG_IRQ_STOP_INTERVAL_IRQ_STOP_INTERVAL(irq_stop_interval));
    endtask: set_irq_stop_interval

    task verify_irq_stop_interval(
      input bit [31:0] irq_stop_interval);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_IRQ_STOP_INTERVAL), `SET_AXI_AD9910_REG_IRQ_STOP_INTERVAL_IRQ_STOP_INTERVAL(irq_stop_interval));
    endtask: verify_irq_stop_interval

    task get_irq_stop_interval(
      output bit [31:0] irq_stop_interval);

      this.axi_read(GetAddrs(AXI_AD9910_REG_IRQ_STOP_INTERVAL), this.val);
      irq_stop_interval = `GET_AXI_AD9910_REG_IRQ_STOP_INTERVAL_IRQ_STOP_INTERVAL(this.val);
    endtask: get_irq_stop_interval

    // REG_TRIG_START_INTERVAL
    task set_trig_start_interval(
      input bit [31:0] trig_start_interval);

      this.axi_write(GetAddrs(AXI_AD9910_REG_TRIG_START_INTERVAL),
        `SET_AXI_AD9910_REG_TRIG_START_INTERVAL_TRIG_START_INTERVAL(trig_start_interval));
    endtask: set_trig_start_interval

    task verify_trig_start_interval(
      input bit [31:0] trig_start_interval);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_TRIG_START_INTERVAL), `SET_AXI_AD9910_REG_TRIG_START_INTERVAL_TRIG_START_INTERVAL(trig_start_interval));
    endtask: verify_trig_start_interval

    task get_trig_start_interval(
      output bit [31:0] trig_start_interval);

      this.axi_read(GetAddrs(AXI_AD9910_REG_TRIG_START_INTERVAL), this.val);
      trig_start_interval = `GET_AXI_AD9910_REG_TRIG_START_INTERVAL_TRIG_START_INTERVAL(this.val);
    endtask: get_trig_start_interval

    // REG_TRIG_STOP_INTERVAL
    task set_trig_stop_interval(
      input bit [31:0] trig_stop_interval);

      this.axi_write(GetAddrs(AXI_AD9910_REG_TRIG_STOP_INTERVAL),
        `SET_AXI_AD9910_REG_TRIG_STOP_INTERVAL_TRIG_STOP_INTERVAL(trig_stop_interval));
    endtask: set_trig_stop_interval

    task verify_trig_stop_interval(
      input bit [31:0] trig_stop_interval);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_TRIG_STOP_INTERVAL), `SET_AXI_AD9910_REG_TRIG_STOP_INTERVAL_TRIG_STOP_INTERVAL(trig_stop_interval));
    endtask: verify_trig_stop_interval

    task get_trig_stop_interval(
      output bit [31:0] trig_stop_interval);

      this.axi_read(GetAddrs(AXI_AD9910_REG_TRIG_STOP_INTERVAL), this.val);
      trig_stop_interval = `GET_AXI_AD9910_REG_TRIG_STOP_INTERVAL_TRIG_STOP_INTERVAL(this.val);
    endtask: get_trig_stop_interval

    // REG_PD_CLK_COUNT
    task get_pd_clk_count(
      output bit [31:0] pd_clk_count);

      this.axi_read(GetAddrs(AXI_AD9910_REG_PD_CLK_COUNT), this.val);
      pd_clk_count = `GET_AXI_AD9910_REG_PD_CLK_COUNT_PD_CLK_COUNT(this.val);
    endtask: get_pd_clk_count

    // REG_UPDATE_CTRL
    task set_update_ctrl(
      input bit transfer_trig_mode,
      input bit enable_p_if,
      input bit load_new_rate);

      this.axi_write(GetAddrs(AXI_AD9910_REG_UPDATE_CTRL),
        `SET_AXI_AD9910_REG_UPDATE_CTRL_TRANSFER_TRIG_MODE(transfer_trig_mode) |
        `SET_AXI_AD9910_REG_UPDATE_CTRL_ENABLE_P_IF(enable_p_if) |
        `SET_AXI_AD9910_REG_UPDATE_CTRL_LOAD_NEW_RATE(load_new_rate));
    endtask: set_update_ctrl

    task get_update_ctrl(
      output bit transfer_trig_mode,
      output bit enable_p_if,
      output bit load_new_rate);

      this.axi_read(GetAddrs(AXI_AD9910_REG_UPDATE_CTRL), this.val);
      transfer_trig_mode = `GET_AXI_AD9910_REG_UPDATE_CTRL_TRANSFER_TRIG_MODE(this.val);
      enable_p_if = `GET_AXI_AD9910_REG_UPDATE_CTRL_ENABLE_P_IF(this.val);
      load_new_rate = `GET_AXI_AD9910_REG_UPDATE_CTRL_LOAD_NEW_RATE(this.val);
    endtask: get_update_ctrl

    // REG_PAR_UPDATE_RATE
    task set_par_update_rate(
      input bit [31:0] par_update_rate);

      this.axi_write(GetAddrs(AXI_AD9910_REG_PAR_UPDATE_RATE),
        `SET_AXI_AD9910_REG_PAR_UPDATE_RATE_PAR_UPDATE_RATE(par_update_rate));
    endtask: set_par_update_rate

    task verify_par_update_rate(
      input bit [31:0] par_update_rate);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_PAR_UPDATE_RATE), `SET_AXI_AD9910_REG_PAR_UPDATE_RATE_PAR_UPDATE_RATE(par_update_rate));
    endtask: verify_par_update_rate

    task get_par_update_rate(
      output bit [31:0] par_update_rate);

      this.axi_read(GetAddrs(AXI_AD9910_REG_PAR_UPDATE_RATE), this.val);
      par_update_rate = `GET_AXI_AD9910_REG_PAR_UPDATE_RATE_PAR_UPDATE_RATE(this.val);
    endtask: get_par_update_rate

    // REG_F_CFG
    task set_f_cfg(
      input bit [1:0] f_cfg);

      this.axi_write(GetAddrs(AXI_AD9910_REG_F_CFG),
        `SET_AXI_AD9910_REG_F_CFG_F_CFG(f_cfg));
    endtask: set_f_cfg

    task verify_f_cfg(
      input bit [1:0] f_cfg);

      this.axi_verify(GetAddrs(AXI_AD9910_REG_F_CFG), `SET_AXI_AD9910_REG_F_CFG_F_CFG(f_cfg));
    endtask: verify_f_cfg

    task get_f_cfg(
      output bit [1:0] f_cfg);

      this.axi_read(GetAddrs(AXI_AD9910_REG_F_CFG), this.val);
      f_cfg = `GET_AXI_AD9910_REG_F_CFG_F_CFG(this.val);
    endtask: get_f_cfg

  endclass: ad9910_api

endpackage
