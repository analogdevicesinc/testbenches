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

package adc_api_pkg;

  import logger_pkg::*;
  import adi_peripheral_pkg::*;
  import adi_regmap_adc_pkg::*;
  import adi_regmap_pkg::*;
  import reg_accessor_pkg::*;

  class adc_api extends adi_peripheral;

    protected logic [31:0] val;

    function new(
      input string name,
      input reg_accessor bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, bus, base_address, parent);
    endfunction

    task enable();
      this.axi_write(GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(1));
    endtask

    task set_control_2(
      input logic ext_sync_arm,
      input logic ext_sync_disarm,
      input logic manual_sync_request);

      this.axi_write(GetAddrs(ADC_COMMON_REG_CNTRL_2), 
        `SET_ADC_COMMON_REG_CNTRL_2_EXT_SYNC_ARM(ext_sync_arm) |
        `SET_ADC_COMMON_REG_CNTRL_2_EXT_SYNC_DISARM(ext_sync_disarm) |
        `SET_ADC_COMMON_REG_CNTRL_2_MANUAL_SYNC_REQUEST(manual_sync_request));
    endtask

    task get_status(output logic status);
      this.axi_read(GetAddrs(ADC_COMMON_REG_SYNC_STATUS), val);
      status = `GET_ADC_COMMON_REG_SYNC_STATUS_ADC_SYNC(val);
    endtask

    task set_adc_config_wr(input logic [31:0] cfg);
      this.axi_write(GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(cfg));
    endtask

    task get_adc_config_wr(output logic [31:0] cfg);
      this.axi_read(GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), val);
      cfg = `GET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(val);
    endtask

    task set_adc_config_control(input logic [31:0] cfg);
      this.axi_write(GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(cfg));
    endtask

    task get_adc_config_control(output logic [31:0] cfg);
      this.axi_read(GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), val);
      cfg = `GET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(val);
    endtask

    task set_control_3(
      input logic crc_en,
      input logic [7:0] custom_control);

      this.axi_write(GetAddrs(ADC_COMMON_REG_CNTRL_3), 
        `SET_ADC_COMMON_REG_CNTRL_3_CRC_EN(crc_en) |
        `SET_ADC_COMMON_REG_CNTRL_3_CUSTOM_CONTROL(custom_control));
    endtask

  endclass

endpackage
