// ***************************************************************************
// ***************************************************************************
// Copyright 2021 (c) Analog Devices, Inc. All rights reserved.
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

`define TDD_ADDR_VERSION                  32'h000000
`define TDD_ADDR_ID                       32'h000004
`define TDD_ADDR_SCRATCH                  32'h000008
`define TDD_ADDR_MAGIC                    32'h000008

`define TDD_ADDR_CONTROL_0                32'h000040
`define TDD_BIT_ENABLE                    32'h000000
`define TDD_BIT_SECONDARY                 32'h000001
`define TDD_BIT_RXONLY                    32'h000002
`define TDD_BIT_TXONLY                    32'h000003
`define TDD_BIT_GATED_RX_DMAPATH          32'h000004
`define TDD_BIT_GATED_TX_DMAPATH          32'h000005

`define TDD_ADDR_CONTROL_1                32'h000044
`define TDD_BIT_BURST_COUNT               32'h0000ff

`define TDD_ADDR_CONTROL_2                32'h000048
`define TDD_BIT_COUNTER_INIT              32'hffffff

`define TDD_ADDR_FRAME_LENGTH             32'h00004c
`define TDD_BIT_FRAME_LENGTH              32'hffffff

`define TDD_ADDR_TERMINAL_TYPE            32'h000050
`define TDD_BIT_TERMINAL_TYPE             32'h000001

`define TDD_ADDR_STATUS                   32'h000060
`define TDD_BIT_RXTX_VCO_OVERLAP          32'h000001
`define TDD_BIT_RXTX_RF_OVERLAP           32'h000002

`define TDD_ADDR_VCO_RX_ON_1              32'h000080
`define TDD_ADDR_VCO_RX_OFF_1             32'h000084
`define TDD_ADDR_VCO_TX_ON_1              32'h000088
`define TDD_ADDR_VCO_TX_OFF_1             32'h00008c
`define TDD_ADDR_RX_ON_1                  32'h000090
`define TDD_ADDR_RX_OFF_1                 32'h000094
`define TDD_ADDR_TX_ON_1                  32'h000098
`define TDD_ADDR_TX_OFF_1                 32'h00009c
`define TDD_ADDR_RX_DP_ON_1               32'h0000a0
`define TDD_ADDR_RX_DP_OFF_1              32'h0000a4
`define TDD_ADDR_TX_DP_ON_1               32'h0000a8
`define TDD_ADDR_TX_DP_OFF_1              32'h0000ac

`define TDD_ADDR_VCO_RX_ON_2              32'h0000c0
`define TDD_ADDR_VCO_RX_OFF_2             32'h0000c4
`define TDD_ADDR_VCO_TX_ON_2              32'h0000c8
`define TDD_ADDR_VCO_TX_OFF_2             32'h0000cc
`define TDD_ADDR_RX_ON_2                  32'h0000d0
`define TDD_ADDR_RX_OFF_2                 32'h0000d4
`define TDD_ADDR_TX_ON_2                  32'h0000d8
`define TDD_ADDR_TX_OFF_2                 32'h0000dc
`define TDD_ADDR_RX_DP_ON_2               32'h0000e0
`define TDD_ADDR_RX_DP_OFF_2              32'h0000e4
`define TDD_ADDR_TX_DP_ON_2               32'h0000e8
`define TDD_ADDR_TX_DP_OFF_2              32'h0000ec

`define	TDD_CORE_VERSION 			            32'h00010061
`define	TDD_CORE_MAGIC   			            32'h54444443

package axi_tdd_pkg;

  import axi_vip_pkg::*;
  import reg_accessor_pkg::*;
  import logger_pkg::*;

  class axi_tdd;
    reg_accessor  bus;
    xil_axi_ulong base_address;

    bit [31:0] reg_control;

    function new (reg_accessor bus, xil_axi_ulong base_address);
      this.bus = bus;
      this.base_address = base_address;
      this.reg_control = 'b0;
    endfunction

    task get_core_version (output bit [31:0] version);
      this.bus.RegRead32(this.base_address + `TDD_ADDR_VERSION, version);
    endtask : get_core_version;

    task get_core_magic (output bit [31:0] magic);
      this.bus.RegRead32(this.base_address + `TDD_ADDR_MAGIC, magic);
    endtask : get_core_magic;

    task set_enabled (input bit enabled);
      this.reg_control[`TDD_BIT_ENABLE] = enabled;
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_CONTROL_0, this.reg_control);
    endtask : set_enabled;

    task set_secondary (input bit secondary);
      this.reg_control[`TDD_BIT_SECONDARY] = secondary;
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_CONTROL_0, this.reg_control);
    endtask : set_secondary;

    task set_rxonly (input bit rxonly);
      this.reg_control[`TDD_BIT_RXONLY] = rxonly;
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_CONTROL_0, this.reg_control);
    endtask : set_rxonly;

    task set_txonly (input bit txonly);
      this.reg_control[`TDD_BIT_TXONLY] = txonly;
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_CONTROL_0, this.reg_control);
    endtask : set_txonly;

    task set_gated_rx_dmapath (input bit gated);
      this.reg_control[`TDD_BIT_GATED_RX_DMAPATH] = gated;
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_CONTROL_0, this.reg_control);
    endtask : set_gated_rx_dmapath;

    task set_gated_tx_dmapath (input bit gated);
      this.reg_control[`TDD_BIT_GATED_TX_DMAPATH] = gated;
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_CONTROL_0, this.reg_control);
    endtask : set_gated_tx_dmapath;

    task set_burst_count (input bit [7:0] bursts);
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_CONTROL_1, {24'h0, bursts});
    endtask : set_burst_count;

    task set_counter_init (input bit [23:0] counter_init);
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_CONTROL_2, {8'h0, counter_init});
    endtask : set_counter_init;

    task set_frame_length (input bit [23:0] frame_length);
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_FRAME_LENGTH, {8'h0, frame_length});
    endtask : set_frame_length;

    task set_terminal_type (input bit terminal_type);
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_TERMINAL_TYPE, {31'h0, terminal_type});
    endtask : set_terminal_type;

    task get_rxtx_status (output bit [7:0] status);
      bit [31:0] data;
      this.bus.RegRead32(this.base_address + `TDD_ADDR_STATUS, data);

      status = data[7:0];
    endtask : get_rxtx_status;

    task set_primary_slot(input bit [23:0] rx_vco_on,
                          input bit [23:0] rx_vco_off,
                          input bit [23:0] tx_vco_on,
                          input bit [23:0] tx_vco_off,
                          input bit [23:0] rx_rf_on,
                          input bit [23:0] rx_rf_off,
                          input bit [23:0] tx_rf_on,
                          input bit [23:0] tx_rf_off,
                          input bit [23:0] rx_dp_on,
                          input bit [23:0] rx_dp_off,
                          input bit [23:0] tx_dp_on,
                          input bit [23:0] tx_dp_off);

      this.bus.RegWrite32(this.base_address + `TDD_ADDR_VCO_RX_ON_1, {8'h0, rx_vco_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_VCO_RX_OFF_1, {8'h0, rx_vco_off});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_VCO_TX_ON_1, {8'h0, tx_vco_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_VCO_TX_OFF_1, {8'h0, tx_vco_off});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_RX_ON_1, {8'h0, rx_rf_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_RX_OFF_1, {8'h0, rx_rf_off});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_TX_ON_1, {8'h0, tx_rf_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_TX_OFF_1, {8'h0, tx_rf_off});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_RX_DP_ON_1, {8'h0, rx_dp_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_RX_DP_OFF_1, {8'h0, rx_dp_off});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_TX_DP_ON_1, {8'h0, tx_dp_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_TX_DP_OFF_1, {8'h0, tx_dp_off});
    endtask : set_primary_slot;

    task set_secondary_slot(input bit [23:0] rx_vco_on,
                            input bit [23:0] rx_vco_off,
                            input bit [23:0] tx_vco_on,
                            input bit [23:0] tx_vco_off,
                            input bit [23:0] rx_rf_on,
                            input bit [23:0] rx_rf_off,
                            input bit [23:0] tx_rf_on,
                            input bit [23:0] tx_rf_off,
                            input bit [23:0] rx_dp_on,
                            input bit [23:0] rx_dp_off,
                            input bit [23:0] tx_dp_on,
                            input bit [23:0] tx_dp_off);

      this.bus.RegWrite32(this.base_address + `TDD_ADDR_VCO_RX_ON_2, {8'h0, rx_vco_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_VCO_RX_OFF_2, {8'h0, rx_vco_off});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_VCO_TX_ON_2, {8'h0, tx_vco_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_VCO_TX_OFF_2, {8'h0, tx_vco_off});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_RX_ON_2, {8'h0, rx_rf_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_RX_OFF_2, {8'h0, rx_rf_off});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_TX_ON_2, {8'h0, tx_rf_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_TX_OFF_2, {8'h0, tx_rf_off});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_RX_DP_ON_2, {8'h0, rx_dp_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_RX_DP_OFF_2, {8'h0, rx_dp_off});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_TX_DP_ON_2, {8'h0, tx_dp_on});
      this.bus.RegWrite32(this.base_address + `TDD_ADDR_TX_DP_OFF_2, {8'h0, tx_dp_off});
    endtask : set_secondary_slot;

  endclass

endpackage
