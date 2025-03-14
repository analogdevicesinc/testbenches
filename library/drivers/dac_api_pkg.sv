// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018 (c) Analog Devices, Inc. All rights reserved.
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

`include "utils.svh"

package dac_api_pkg;

  import logger_pkg::*;
  import adi_peripheral_pkg::*;
  import adi_regmap_dac_pkg::*;
  import adi_regmap_pkg::*;
  import reg_accessor_pkg::*;

  class dac_api extends adi_peripheral;

    protected logic [31:0] val;

    function new(
      input string name,
      input reg_accessor bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, bus, base_address, parent);
    endfunction

    task reset(
      input logic ce_n,
      input logic mmcm_rstn,
      input logic rstn);

      this.axi_write(GetAddrs(DAC_COMMON_REG_RSTN),
        `SET_DAC_COMMON_REG_RSTN_CE_N(ce_n) |
        `SET_DAC_COMMON_REG_RSTN_MMCM_RSTN(mmcm_rstn) |
        `SET_DAC_COMMON_REG_RSTN_RSTN(rstn));
    endtask

    task set_common_control_1(
      input logic sync,
      input logic ext_sync_arm,
      input logic ext_sync_disarm,
      input logic manual_sync_request);

      this.axi_write(GetAddrs(DAC_COMMON_REG_CNTRL_1), 
        `SET_DAC_COMMON_REG_CNTRL_1_SYNC(sync) |
        `SET_DAC_COMMON_REG_CNTRL_1_EXT_SYNC_ARM(ext_sync_arm) |
        `SET_DAC_COMMON_REG_CNTRL_1_EXT_SYNC_DISARM(ext_sync_disarm) |
        `SET_DAC_COMMON_REG_CNTRL_1_MANUAL_SYNC_REQUEST(manual_sync_request));
    endtask

    task set_common_control_2(
      input logic data_format,
      input logic [4:0] num_lanes,
      input logic par_enb,
      input logic par_type,
      input logic r1_mode,
      input logic sdr_ddr_n,
      input logic symb_8_16b,
      input logic symb_op);

      this.axi_write(GetAddrs(DAC_COMMON_REG_CNTRL_2), 
        `SET_DAC_COMMON_REG_CNTRL_2_DATA_FORMAT(data_format) |
        `SET_DAC_COMMON_REG_CNTRL_2_NUM_LANES(num_lanes) |
        `SET_DAC_COMMON_REG_CNTRL_2_PAR_ENB(par_enb) |
        `SET_DAC_COMMON_REG_CNTRL_2_PAR_TYPE(par_type) |
        `SET_DAC_COMMON_REG_CNTRL_2_R1_MODE(r1_mode) |
        `SET_DAC_COMMON_REG_CNTRL_2_SDR_DDR_N(sdr_ddr_n) |
        `SET_DAC_COMMON_REG_CNTRL_2_SYMB_8_16B(symb_8_16b) |
        `SET_DAC_COMMON_REG_CNTRL_2_SYMB_OP(symb_op));
    endtask

    task get_status(output logic status);
      this.axi_read(GetAddrs(DAC_COMMON_REG_SYNC_STATUS), val);
      status = `GET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(val);
    endtask
    
    task set_channel_control_1(
      input bit [7:0] channel,
      input logic [5:0] dds_phase_dw,
      input logic [15:0] dds_scale_1);

      this.axi_write(channel * 'h40 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
        `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_PHASE_DW(dds_phase_dw) |
        `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(dds_scale_1));
    endtask

    task set_channel_control_2(
      input bit [7:0] channel,
      input logic [15:0] dds_init_1,
      input logic [15:0] dds_incr_1);

      this.axi_write(channel * 'h40 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
        `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INIT_1(dds_init_1) |
        `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(dds_incr_1));
    endtask

    task set_channel_control_7(
      input bit [7:0] channel,
      input logic [3:0] dds_sel);

      this.axi_write(channel * 'h40 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7), `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(dds_sel));
    endtask

    task set_rate(input logic [7:0] rate);
      this.axi_write(GetAddrs(DAC_COMMON_REG_RATECNTRL), `SET_DAC_COMMON_REG_RATECNTRL_RATE(rate-1));
    endtask

  endclass

endpackage
