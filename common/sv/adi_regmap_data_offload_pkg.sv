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
/* Auto generated Register Map */
/* Tue May  3 15:36:59 2022 */

package adi_regmap_data_offload_pkg;
  import adi_regmap_pkg::*;


  const reg_t DO_VERSION = '{ 'h0000, "VERSION" , '{
    "MAJOR": '{ 31, 16, RO, 'h04 },
    "MINOR": '{ 15, 8, RO, 'h03 },
    "PATCH": '{ 7, 0, RO, 'h61 }}};
  `define SET_DO_VERSION_MAJOR(x) SetField(DO_VERSION,"MAJOR",x)
  `define GET_DO_VERSION_MAJOR(x) GetField(DO_VERSION,"MAJOR",x)
  `define SET_DO_VERSION_MINOR(x) SetField(DO_VERSION,"MINOR",x)
  `define GET_DO_VERSION_MINOR(x) GetField(DO_VERSION,"MINOR",x)
  `define SET_DO_VERSION_PATCH(x) SetField(DO_VERSION,"PATCH",x)
  `define GET_DO_VERSION_PATCH(x) GetField(DO_VERSION,"PATCH",x)

  const reg_t DO_PERIPHERAL_ID = '{ 'h0004, "PERIPHERAL_ID" , '{
    "PERIPHERAL_ID": '{ 31, 0, RO, 0 }}};
  `define SET_DO_PERIPHERAL_ID_PERIPHERAL_ID(x) SetField(DO_PERIPHERAL_ID,"PERIPHERAL_ID",x)
  `define GET_DO_PERIPHERAL_ID_PERIPHERAL_ID(x) GetField(DO_PERIPHERAL_ID,"PERIPHERAL_ID",x)

  const reg_t DO_SCRATCH = '{ 'h0008, "SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h000 }}};
  `define SET_DO_SCRATCH_SCRATCH(x) SetField(DO_SCRATCH,"SCRATCH",x)
  `define GET_DO_SCRATCH_SCRATCH(x) GetField(DO_SCRATCH,"SCRATCH",x)

  const reg_t DO_IDENTIFICATION = '{ 'h000c, "IDENTIFICATION" , '{
    "IDENTIFICATION": '{ 31, 0, RW, 'h444D4143 }}};
  `define SET_DO_IDENTIFICATION_IDENTIFICATION(x) SetField(DO_IDENTIFICATION,"IDENTIFICATION",x)
  `define GET_DO_IDENTIFICATION_IDENTIFICATION(x) GetField(DO_IDENTIFICATION,"IDENTIFICATION",x)

  const reg_t DO_SYNTHESIS_CONFIG = '{ 'h0010, "SYNTHESIS_CONFIG" , '{
    "MEM_SIZE_LOG2": '{ 13, 8, R, 0 },
    "HAS_BYPASS": '{ 2, 2, R, 0 },
    "TX_OR_RXN_PATH": '{ 1, 1, R, 0 },
    "MEMORY_TYPE": '{ 0, 0, R, 0 }}};
  `define SET_DO_SYNTHESIS_CONFIG_MEM_SIZE_LOG2(x) SetField(DO_SYNTHESIS_CONFIG,"MEM_SIZE_LOG2",x)
  `define GET_DO_SYNTHESIS_CONFIG_MEM_SIZE_LOG2(x) GetField(DO_SYNTHESIS_CONFIG,"MEM_SIZE_LOG2",x)
  `define SET_DO_SYNTHESIS_CONFIG_HAS_BYPASS(x) SetField(DO_SYNTHESIS_CONFIG,"HAS_BYPASS",x)
  `define GET_DO_SYNTHESIS_CONFIG_HAS_BYPASS(x) GetField(DO_SYNTHESIS_CONFIG,"HAS_BYPASS",x)
  `define SET_DO_SYNTHESIS_CONFIG_TX_OR_RXN_PATH(x) SetField(DO_SYNTHESIS_CONFIG,"TX_OR_RXN_PATH",x)
  `define GET_DO_SYNTHESIS_CONFIG_TX_OR_RXN_PATH(x) GetField(DO_SYNTHESIS_CONFIG,"TX_OR_RXN_PATH",x)
  `define SET_DO_SYNTHESIS_CONFIG_MEMORY_TYPE(x) SetField(DO_SYNTHESIS_CONFIG,"MEMORY_TYPE",x)
  `define GET_DO_SYNTHESIS_CONFIG_MEMORY_TYPE(x) GetField(DO_SYNTHESIS_CONFIG,"MEMORY_TYPE",x)

  const reg_t DO_TRANSFER_LENGTH = '{ 'h001C, "TRANSFER_LENGTH" , '{
    "PARTIAL_LENGTH": '{ 31, 0, RW, 'h0 }}};
  `define SET_DO_TRANSFER_LENGTH_PARTIAL_LENGTH(x) SetField(DO_TRANSFER_LENGTH,"PARTIAL_LENGTH",x)
  `define GET_DO_TRANSFER_LENGTH_PARTIAL_LENGTH(x) GetField(DO_TRANSFER_LENGTH,"PARTIAL_LENGTH",x)

  const reg_t DO_MEM_PHY_STATE = '{ 'h0080, "MEM_PHY_STATE" , '{
    "UNDERFLOW": '{ 5, 5, R, 0 },
    "OVERFLOW": '{ 4, 4, R, 0 },
    "CALIB_COMPLETE": '{ 0, 0, R, 0 }}};
  `define SET_DO_MEM_PHY_STATE_UNDERFLOW(x) SetField(DO_MEM_PHY_STATE,"UNDERFLOW",x)
  `define GET_DO_MEM_PHY_STATE_UNDERFLOW(x) GetField(DO_MEM_PHY_STATE,"UNDERFLOW",x)
  `define SET_DO_MEM_PHY_STATE_OVERFLOW(x) SetField(DO_MEM_PHY_STATE,"OVERFLOW",x)
  `define GET_DO_MEM_PHY_STATE_OVERFLOW(x) GetField(DO_MEM_PHY_STATE,"OVERFLOW",x)
  `define SET_DO_MEM_PHY_STATE_CALIB_COMPLETE(x) SetField(DO_MEM_PHY_STATE,"CALIB_COMPLETE",x)
  `define GET_DO_MEM_PHY_STATE_CALIB_COMPLETE(x) GetField(DO_MEM_PHY_STATE,"CALIB_COMPLETE",x)

  const reg_t DO_RESETN_OFFLOAD = '{ 'h0084, "RESETN_OFFLOAD" , '{
    "RESETN": '{ 0, 0, RW, 'h0 }}};
  `define SET_DO_RESETN_OFFLOAD_RESETN(x) SetField(DO_RESETN_OFFLOAD,"RESETN",x)
  `define GET_DO_RESETN_OFFLOAD_RESETN(x) GetField(DO_RESETN_OFFLOAD,"RESETN",x)

  const reg_t DO_CONTROL = '{ 'h0088, "CONTROL" , '{
    "ONESHOT_EN": '{ 1, 1, RW, 'h0 },
    "OFFLOAD_BYPASS": '{ 0, 0, RW, 'h0 }}};
  `define SET_DO_CONTROL_ONESHOT_EN(x) SetField(DO_CONTROL,"ONESHOT_EN",x)
  `define GET_DO_CONTROL_ONESHOT_EN(x) GetField(DO_CONTROL,"ONESHOT_EN",x)
  `define SET_DO_CONTROL_OFFLOAD_BYPASS(x) SetField(DO_CONTROL,"OFFLOAD_BYPASS",x)
  `define GET_DO_CONTROL_OFFLOAD_BYPASS(x) GetField(DO_CONTROL,"OFFLOAD_BYPASS",x)

  const reg_t DO_SYNC_TRIGGER = '{ 'h0100, "SYNC_TRIGGER" , '{
    "SYNC_TRIGGER": '{ 0, 0, RW1C, 'h0 }}};
  `define SET_DO_SYNC_TRIGGER_SYNC_TRIGGER(x) SetField(DO_SYNC_TRIGGER,"SYNC_TRIGGER",x)
  `define GET_DO_SYNC_TRIGGER_SYNC_TRIGGER(x) GetField(DO_SYNC_TRIGGER,"SYNC_TRIGGER",x)

  const reg_t DO_SYNC_CONFIG = '{ 'h0104, "SYNC_CONFIG" , '{
    "SYNC_CONFIG": '{ 1, 0, RW, 'h0 }}};
  `define SET_DO_SYNC_CONFIG_SYNC_CONFIG(x) SetField(DO_SYNC_CONFIG,"SYNC_CONFIG",x)
  `define GET_DO_SYNC_CONFIG_SYNC_CONFIG(x) GetField(DO_SYNC_CONFIG,"SYNC_CONFIG",x)

  const reg_t DO_FSM_DBG = '{ 'h0200, "FSM_DBG" , '{
    "FSM_STATE_READ": '{ 11, 8, RO, 'h0 },
    "FSM_STATE_WRITE": '{ 4, 0, RO, 'h0 }}};
  `define SET_DO_FSM_DBG_FSM_STATE_READ(x) SetField(DO_FSM_DBG,"FSM_STATE_READ",x)
  `define GET_DO_FSM_DBG_FSM_STATE_READ(x) GetField(DO_FSM_DBG,"FSM_STATE_READ",x)
  `define SET_DO_FSM_DBG_FSM_STATE_WRITE(x) SetField(DO_FSM_DBG,"FSM_STATE_WRITE",x)
  `define GET_DO_FSM_DBG_FSM_STATE_WRITE(x) GetField(DO_FSM_DBG,"FSM_STATE_WRITE",x)

endpackage
