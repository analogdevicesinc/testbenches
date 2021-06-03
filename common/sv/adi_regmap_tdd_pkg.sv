// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2021 (c) Analog Devices, Inc. All rights reserved.
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
//      <https://www.gnu.org/licenses/old_licenses/gpl-2.0.html>
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
/* Auto generated Register Map */
/* Fri May 28 12:27:32 2021 */

package adi_regmap_tdd_pkg;
  import adi_regmap_pkg::*;


/* Transceiver TDD Control (axi_ad*) */

  const reg_t TDD_CNTRL_REG_TDD_CONTROL_0 = '{ 'h0040, "REG_TDD_CONTROL_0" , '{
    "TDD_GATED_TX_DMAPATH": '{ 5, 5, RW, 'h0 },
    "TDD_GATED_RX_DMAPATH": '{ 4, 4, RW, 'h0 },
    "TDD_TXONLY": '{ 3, 3, RW, 'h0 },
    "TDD_RXONLY": '{ 2, 2, RW, 'h0 },
    "TDD_SECONDARY": '{ 1, 1, RW, 'h0 },
    "TDD_ENABLE": '{ 0, 0, RW, 'h0 }}};
  `define SET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_GATED_TX_DMAPATH(x) SetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_GATED_TX_DMAPATH",x)
  `define GET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_GATED_TX_DMAPATH(x) GetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_GATED_TX_DMAPATH",x)
  `define SET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_GATED_RX_DMAPATH(x) SetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_GATED_RX_DMAPATH",x)
  `define GET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_GATED_RX_DMAPATH(x) GetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_GATED_RX_DMAPATH",x)
  `define SET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_TXONLY(x) SetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_TXONLY",x)
  `define GET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_TXONLY(x) GetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_TXONLY",x)
  `define SET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_RXONLY(x) SetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_RXONLY",x)
  `define GET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_RXONLY(x) GetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_RXONLY",x)
  `define SET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_SECONDARY(x) SetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_SECONDARY",x)
  `define GET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_SECONDARY(x) GetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_SECONDARY",x)
  `define SET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_ENABLE(x) SetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_ENABLE",x)
  `define GET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_ENABLE(x) GetField(TDD_CNTRL_REG_TDD_CONTROL_0,"TDD_ENABLE",x)

  const reg_t TDD_CNTRL_REG_TDD_CONTROL_1 = '{ 'h0044, "REG_TDD_CONTROL_1" , '{
    "TDD_BURST_COUNT": '{ 7, 0, RW, 'h00 }}};
  `define SET_TDD_CNTRL_REG_TDD_CONTROL_1_TDD_BURST_COUNT(x) SetField(TDD_CNTRL_REG_TDD_CONTROL_1,"TDD_BURST_COUNT",x)
  `define GET_TDD_CNTRL_REG_TDD_CONTROL_1_TDD_BURST_COUNT(x) GetField(TDD_CNTRL_REG_TDD_CONTROL_1,"TDD_BURST_COUNT",x)

  const reg_t TDD_CNTRL_REG_TDD_CONTROL_2 = '{ 'h0048, "REG_TDD_CONTROL_2" , '{
    "TDD_COUNTER_INIT": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_CONTROL_2_TDD_COUNTER_INIT(x) SetField(TDD_CNTRL_REG_TDD_CONTROL_2,"TDD_COUNTER_INIT",x)
  `define GET_TDD_CNTRL_REG_TDD_CONTROL_2_TDD_COUNTER_INIT(x) GetField(TDD_CNTRL_REG_TDD_CONTROL_2,"TDD_COUNTER_INIT",x)

  const reg_t TDD_CNTRL_REG_TDD_FRAME_LENGTH = '{ 'h004c, "REG_TDD_FRAME_LENGTH" , '{
    "TDD_FRAME_LENGTH": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_FRAME_LENGTH_TDD_FRAME_LENGTH(x) SetField(TDD_CNTRL_REG_TDD_FRAME_LENGTH,"TDD_FRAME_LENGTH",x)
  `define GET_TDD_CNTRL_REG_TDD_FRAME_LENGTH_TDD_FRAME_LENGTH(x) GetField(TDD_CNTRL_REG_TDD_FRAME_LENGTH,"TDD_FRAME_LENGTH",x)

  const reg_t TDD_CNTRL_REG_TDD_SYNC_TERMINAL_TYPE = '{ 'h0050, "REG_TDD_SYNC_TERMINAL_TYPE" , '{
    "TDD_SYNC_TERMINAL_TYPE": '{ 0, 0, RW, 'h0 }}};
  `define SET_TDD_CNTRL_REG_TDD_SYNC_TERMINAL_TYPE_TDD_SYNC_TERMINAL_TYPE(x) SetField(TDD_CNTRL_REG_TDD_SYNC_TERMINAL_TYPE,"TDD_SYNC_TERMINAL_TYPE",x)
  `define GET_TDD_CNTRL_REG_TDD_SYNC_TERMINAL_TYPE_TDD_SYNC_TERMINAL_TYPE(x) GetField(TDD_CNTRL_REG_TDD_SYNC_TERMINAL_TYPE,"TDD_SYNC_TERMINAL_TYPE",x)

  const reg_t TDD_CNTRL_REG_TDD_STATUS = '{ 'h0060, "REG_TDD_STATUS" , '{
    "TDD_RXTX_VCO_OVERLAP": '{ 0, 0, RO, 'h0 },
    "TDD_RXTX_RF_OVERLAP": '{ 1, 1, RO, 'h0 }}};
  `define SET_TDD_CNTRL_REG_TDD_STATUS_TDD_RXTX_VCO_OVERLAP(x) SetField(TDD_CNTRL_REG_TDD_STATUS,"TDD_RXTX_VCO_OVERLAP",x)
  `define GET_TDD_CNTRL_REG_TDD_STATUS_TDD_RXTX_VCO_OVERLAP(x) GetField(TDD_CNTRL_REG_TDD_STATUS,"TDD_RXTX_VCO_OVERLAP",x)
  `define SET_TDD_CNTRL_REG_TDD_STATUS_TDD_RXTX_RF_OVERLAP(x) SetField(TDD_CNTRL_REG_TDD_STATUS,"TDD_RXTX_RF_OVERLAP",x)
  `define GET_TDD_CNTRL_REG_TDD_STATUS_TDD_RXTX_RF_OVERLAP(x) GetField(TDD_CNTRL_REG_TDD_STATUS,"TDD_RXTX_RF_OVERLAP",x)

  const reg_t TDD_CNTRL_REG_TDD_VCO_RX_ON_1 = '{ 'h0080, "REG_TDD_VCO_RX_ON_1" , '{
    "TDD_VCO_RX_ON_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_VCO_RX_ON_1_TDD_VCO_RX_ON_1(x) SetField(TDD_CNTRL_REG_TDD_VCO_RX_ON_1,"TDD_VCO_RX_ON_1",x)
  `define GET_TDD_CNTRL_REG_TDD_VCO_RX_ON_1_TDD_VCO_RX_ON_1(x) GetField(TDD_CNTRL_REG_TDD_VCO_RX_ON_1,"TDD_VCO_RX_ON_1",x)

  const reg_t TDD_CNTRL_REG_TDD_VCO_RX_OFF_1 = '{ 'h0084, "REG_TDD_VCO_RX_OFF_1" , '{
    "TDD_VCO_RX_OFF_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_VCO_RX_OFF_1_TDD_VCO_RX_OFF_1(x) SetField(TDD_CNTRL_REG_TDD_VCO_RX_OFF_1,"TDD_VCO_RX_OFF_1",x)
  `define GET_TDD_CNTRL_REG_TDD_VCO_RX_OFF_1_TDD_VCO_RX_OFF_1(x) GetField(TDD_CNTRL_REG_TDD_VCO_RX_OFF_1,"TDD_VCO_RX_OFF_1",x)

  const reg_t TDD_CNTRL_REG_TDD_VCO_TX_ON_1 = '{ 'h0088, "REG_TDD_VCO_TX_ON_1" , '{
    "TDD_VCO_TX_ON_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_VCO_TX_ON_1_TDD_VCO_TX_ON_1(x) SetField(TDD_CNTRL_REG_TDD_VCO_TX_ON_1,"TDD_VCO_TX_ON_1",x)
  `define GET_TDD_CNTRL_REG_TDD_VCO_TX_ON_1_TDD_VCO_TX_ON_1(x) GetField(TDD_CNTRL_REG_TDD_VCO_TX_ON_1,"TDD_VCO_TX_ON_1",x)

  const reg_t TDD_CNTRL_REG_TDD_VCO_TX_OFF_1 = '{ 'h008c, "REG_TDD_VCO_TX_OFF_1" , '{
    "TDD_VCO_TX_OFF_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_VCO_TX_OFF_1_TDD_VCO_TX_OFF_1(x) SetField(TDD_CNTRL_REG_TDD_VCO_TX_OFF_1,"TDD_VCO_TX_OFF_1",x)
  `define GET_TDD_CNTRL_REG_TDD_VCO_TX_OFF_1_TDD_VCO_TX_OFF_1(x) GetField(TDD_CNTRL_REG_TDD_VCO_TX_OFF_1,"TDD_VCO_TX_OFF_1",x)

  const reg_t TDD_CNTRL_REG_TDD_RX_ON_1 = '{ 'h0090, "REG_TDD_RX_ON_1" , '{
    "TDD_RX_ON_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_RX_ON_1_TDD_RX_ON_1(x) SetField(TDD_CNTRL_REG_TDD_RX_ON_1,"TDD_RX_ON_1",x)
  `define GET_TDD_CNTRL_REG_TDD_RX_ON_1_TDD_RX_ON_1(x) GetField(TDD_CNTRL_REG_TDD_RX_ON_1,"TDD_RX_ON_1",x)

  const reg_t TDD_CNTRL_REG_TDD_RX_OFF_1 = '{ 'h0094, "REG_TDD_RX_OFF_1" , '{
    "TDD_RX_OFF_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_RX_OFF_1_TDD_RX_OFF_1(x) SetField(TDD_CNTRL_REG_TDD_RX_OFF_1,"TDD_RX_OFF_1",x)
  `define GET_TDD_CNTRL_REG_TDD_RX_OFF_1_TDD_RX_OFF_1(x) GetField(TDD_CNTRL_REG_TDD_RX_OFF_1,"TDD_RX_OFF_1",x)

  const reg_t TDD_CNTRL_REG_TDD_TX_ON_1 = '{ 'h0098, "REG_TDD_TX_ON_1" , '{
    "TDD_TX_ON_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_TX_ON_1_TDD_TX_ON_1(x) SetField(TDD_CNTRL_REG_TDD_TX_ON_1,"TDD_TX_ON_1",x)
  `define GET_TDD_CNTRL_REG_TDD_TX_ON_1_TDD_TX_ON_1(x) GetField(TDD_CNTRL_REG_TDD_TX_ON_1,"TDD_TX_ON_1",x)

  const reg_t TDD_CNTRL_REG_TDD_TX_OFF_1 = '{ 'h009c, "REG_TDD_TX_OFF_1" , '{
    "TDD_TX_OFF_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_TX_OFF_1_TDD_TX_OFF_1(x) SetField(TDD_CNTRL_REG_TDD_TX_OFF_1,"TDD_TX_OFF_1",x)
  `define GET_TDD_CNTRL_REG_TDD_TX_OFF_1_TDD_TX_OFF_1(x) GetField(TDD_CNTRL_REG_TDD_TX_OFF_1,"TDD_TX_OFF_1",x)

  const reg_t TDD_CNTRL_REG_TDD_RX_DP_ON_1 = '{ 'h00a0, "REG_TDD_RX_DP_ON_1" , '{
    "TDD_RX_DP_ON_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_RX_DP_ON_1_TDD_RX_DP_ON_1(x) SetField(TDD_CNTRL_REG_TDD_RX_DP_ON_1,"TDD_RX_DP_ON_1",x)
  `define GET_TDD_CNTRL_REG_TDD_RX_DP_ON_1_TDD_RX_DP_ON_1(x) GetField(TDD_CNTRL_REG_TDD_RX_DP_ON_1,"TDD_RX_DP_ON_1",x)

  const reg_t TDD_CNTRL_REG_TDD_RX_DP_OFF_1 = '{ 'h00a4, "REG_TDD_RX_DP_OFF_1" , '{
    "TDD_RX_DP_OFF_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_RX_DP_OFF_1_TDD_RX_DP_OFF_1(x) SetField(TDD_CNTRL_REG_TDD_RX_DP_OFF_1,"TDD_RX_DP_OFF_1",x)
  `define GET_TDD_CNTRL_REG_TDD_RX_DP_OFF_1_TDD_RX_DP_OFF_1(x) GetField(TDD_CNTRL_REG_TDD_RX_DP_OFF_1,"TDD_RX_DP_OFF_1",x)

  const reg_t TDD_CNTRL_REG_TDD_TX_DP_ON_1 = '{ 'h00a8, "REG_TDD_TX_DP_ON_1" , '{
    "TDD_TX_DP_ON_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_TX_DP_ON_1_TDD_TX_DP_ON_1(x) SetField(TDD_CNTRL_REG_TDD_TX_DP_ON_1,"TDD_TX_DP_ON_1",x)
  `define GET_TDD_CNTRL_REG_TDD_TX_DP_ON_1_TDD_TX_DP_ON_1(x) GetField(TDD_CNTRL_REG_TDD_TX_DP_ON_1,"TDD_TX_DP_ON_1",x)

  const reg_t TDD_CNTRL_REG_TDD_TX_DP_OFF_1 = '{ 'h00ac, "REG_TDD_TX_DP_OFF_1" , '{
    "TDD_TX_DP_OFF_1": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_TX_DP_OFF_1_TDD_TX_DP_OFF_1(x) SetField(TDD_CNTRL_REG_TDD_TX_DP_OFF_1,"TDD_TX_DP_OFF_1",x)
  `define GET_TDD_CNTRL_REG_TDD_TX_DP_OFF_1_TDD_TX_DP_OFF_1(x) GetField(TDD_CNTRL_REG_TDD_TX_DP_OFF_1,"TDD_TX_DP_OFF_1",x)

  const reg_t TDD_CNTRL_REG_TDD_VCO_RX_ON_2 = '{ 'h00c0, "REG_TDD_VCO_RX_ON_2" , '{
    "TDD_VCO_RX_ON_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_VCO_RX_ON_2_TDD_VCO_RX_ON_2(x) SetField(TDD_CNTRL_REG_TDD_VCO_RX_ON_2,"TDD_VCO_RX_ON_2",x)
  `define GET_TDD_CNTRL_REG_TDD_VCO_RX_ON_2_TDD_VCO_RX_ON_2(x) GetField(TDD_CNTRL_REG_TDD_VCO_RX_ON_2,"TDD_VCO_RX_ON_2",x)

  const reg_t TDD_CNTRL_REG_TDD_VCO_RX_OFF_2 = '{ 'h00c4, "REG_TDD_VCO_RX_OFF_2" , '{
    "TDD_VCO_RX_OFF_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_VCO_RX_OFF_2_TDD_VCO_RX_OFF_2(x) SetField(TDD_CNTRL_REG_TDD_VCO_RX_OFF_2,"TDD_VCO_RX_OFF_2",x)
  `define GET_TDD_CNTRL_REG_TDD_VCO_RX_OFF_2_TDD_VCO_RX_OFF_2(x) GetField(TDD_CNTRL_REG_TDD_VCO_RX_OFF_2,"TDD_VCO_RX_OFF_2",x)

  const reg_t TDD_CNTRL_REG_TDD_VCO_TX_ON_2 = '{ 'h00c8, "REG_TDD_VCO_TX_ON_2" , '{
    "TDD_VCO_TX_ON_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_VCO_TX_ON_2_TDD_VCO_TX_ON_2(x) SetField(TDD_CNTRL_REG_TDD_VCO_TX_ON_2,"TDD_VCO_TX_ON_2",x)
  `define GET_TDD_CNTRL_REG_TDD_VCO_TX_ON_2_TDD_VCO_TX_ON_2(x) GetField(TDD_CNTRL_REG_TDD_VCO_TX_ON_2,"TDD_VCO_TX_ON_2",x)

  const reg_t TDD_CNTRL_REG_TDD_VCO_TX_OFF_2 = '{ 'h00cc, "REG_TDD_VCO_TX_OFF_2" , '{
    "TDD_VCO_TX_OFF_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_VCO_TX_OFF_2_TDD_VCO_TX_OFF_2(x) SetField(TDD_CNTRL_REG_TDD_VCO_TX_OFF_2,"TDD_VCO_TX_OFF_2",x)
  `define GET_TDD_CNTRL_REG_TDD_VCO_TX_OFF_2_TDD_VCO_TX_OFF_2(x) GetField(TDD_CNTRL_REG_TDD_VCO_TX_OFF_2,"TDD_VCO_TX_OFF_2",x)

  const reg_t TDD_CNTRL_REG_TDD_RX_ON_2 = '{ 'h00d0, "REG_TDD_RX_ON_2" , '{
    "TDD_RX_ON_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_RX_ON_2_TDD_RX_ON_2(x) SetField(TDD_CNTRL_REG_TDD_RX_ON_2,"TDD_RX_ON_2",x)
  `define GET_TDD_CNTRL_REG_TDD_RX_ON_2_TDD_RX_ON_2(x) GetField(TDD_CNTRL_REG_TDD_RX_ON_2,"TDD_RX_ON_2",x)

  const reg_t TDD_CNTRL_REG_TDD_RX_OFF_2 = '{ 'h00d4, "REG_TDD_RX_OFF_2" , '{
    "TDD_RX_OFF_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_RX_OFF_2_TDD_RX_OFF_2(x) SetField(TDD_CNTRL_REG_TDD_RX_OFF_2,"TDD_RX_OFF_2",x)
  `define GET_TDD_CNTRL_REG_TDD_RX_OFF_2_TDD_RX_OFF_2(x) GetField(TDD_CNTRL_REG_TDD_RX_OFF_2,"TDD_RX_OFF_2",x)

  const reg_t TDD_CNTRL_REG_TDD_TX_ON_2 = '{ 'h00d8, "REG_TDD_TX_ON_2" , '{
    "TDD_TX_ON_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_TX_ON_2_TDD_TX_ON_2(x) SetField(TDD_CNTRL_REG_TDD_TX_ON_2,"TDD_TX_ON_2",x)
  `define GET_TDD_CNTRL_REG_TDD_TX_ON_2_TDD_TX_ON_2(x) GetField(TDD_CNTRL_REG_TDD_TX_ON_2,"TDD_TX_ON_2",x)

  const reg_t TDD_CNTRL_REG_TDD_TX_OFF_2 = '{ 'h00dc, "REG_TDD_TX_OFF_2" , '{
    "TDD_TX_OFF_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_TX_OFF_2_TDD_TX_OFF_2(x) SetField(TDD_CNTRL_REG_TDD_TX_OFF_2,"TDD_TX_OFF_2",x)
  `define GET_TDD_CNTRL_REG_TDD_TX_OFF_2_TDD_TX_OFF_2(x) GetField(TDD_CNTRL_REG_TDD_TX_OFF_2,"TDD_TX_OFF_2",x)

  const reg_t TDD_CNTRL_REG_TDD_RX_DP_ON_2 = '{ 'h00e0, "REG_TDD_RX_DP_ON_2" , '{
    "TDD_RX_DP_ON_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_RX_DP_ON_2_TDD_RX_DP_ON_2(x) SetField(TDD_CNTRL_REG_TDD_RX_DP_ON_2,"TDD_RX_DP_ON_2",x)
  `define GET_TDD_CNTRL_REG_TDD_RX_DP_ON_2_TDD_RX_DP_ON_2(x) GetField(TDD_CNTRL_REG_TDD_RX_DP_ON_2,"TDD_RX_DP_ON_2",x)

  const reg_t TDD_CNTRL_REG_TDD_RX_DP_OFF_2 = '{ 'h00e4, "REG_TDD_RX_DP_OFF_2" , '{
    "TDD_RX_DP_OFF_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_RX_DP_OFF_2_TDD_RX_DP_OFF_2(x) SetField(TDD_CNTRL_REG_TDD_RX_DP_OFF_2,"TDD_RX_DP_OFF_2",x)
  `define GET_TDD_CNTRL_REG_TDD_RX_DP_OFF_2_TDD_RX_DP_OFF_2(x) GetField(TDD_CNTRL_REG_TDD_RX_DP_OFF_2,"TDD_RX_DP_OFF_2",x)

  const reg_t TDD_CNTRL_REG_TDD_TX_DP_ON_2 = '{ 'h00e8, "REG_TDD_TX_DP_ON_2" , '{
    "TDD_TX_DP_ON_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_TX_DP_ON_2_TDD_TX_DP_ON_2(x) SetField(TDD_CNTRL_REG_TDD_TX_DP_ON_2,"TDD_TX_DP_ON_2",x)
  `define GET_TDD_CNTRL_REG_TDD_TX_DP_ON_2_TDD_TX_DP_ON_2(x) GetField(TDD_CNTRL_REG_TDD_TX_DP_ON_2,"TDD_TX_DP_ON_2",x)

  const reg_t TDD_CNTRL_REG_TDD_TX_DP_OFF_2 = '{ 'h00ec, "REG_TDD_TX_DP_OFF_2" , '{
    "TDD_TX_DP_OFF_2": '{ 23, 0, RW, 'h000000 }}};
  `define SET_TDD_CNTRL_REG_TDD_TX_DP_OFF_2_TDD_TX_DP_OFF_2(x) SetField(TDD_CNTRL_REG_TDD_TX_DP_OFF_2,"TDD_TX_DP_OFF_2",x)
  `define GET_TDD_CNTRL_REG_TDD_TX_DP_OFF_2_TDD_TX_DP_OFF_2(x) GetField(TDD_CNTRL_REG_TDD_TX_DP_OFF_2,"TDD_TX_DP_OFF_2",x)


endpackage
