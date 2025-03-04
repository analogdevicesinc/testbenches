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
/* Auto generated Register Map */
/* Thu Mar 28 13:22:23 2024 */

package adi_regmap_clock_monitor_pkg;
  import adi_regmap_pkg::*;


/* Clock Monitor (axi_clock_monitor) */

  const reg_t axi_clock_monitor_PCORE_VERSION = '{ 'h0000, "PCORE_VERSION" , '{
    "PCORE_VERSION": '{ 31, 0, RO, 'h00000001 }}};
  `define SET_axi_clock_monitor_PCORE_VERSION_PCORE_VERSION(x) SetField(axi_clock_monitor_PCORE_VERSION,"PCORE_VERSION",x)
  `define GET_axi_clock_monitor_PCORE_VERSION_PCORE_VERSION(x) GetField(axi_clock_monitor_PCORE_VERSION,"PCORE_VERSION",x)
  `define DEFAULT_axi_clock_monitor_PCORE_VERSION_PCORE_VERSION GetResetValue(axi_clock_monitor_PCORE_VERSION,"PCORE_VERSION")
  `define UPDATE_axi_clock_monitor_PCORE_VERSION_PCORE_VERSION(x,y) UpdateField(axi_clock_monitor_PCORE_VERSION,"PCORE_VERSION",x,y)

  const reg_t axi_clock_monitor_ID = '{ 'h0004, "ID" , '{
    "ID": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_axi_clock_monitor_ID_ID(x) SetField(axi_clock_monitor_ID,"ID",x)
  `define GET_axi_clock_monitor_ID_ID(x) GetField(axi_clock_monitor_ID,"ID",x)
  `define DEFAULT_axi_clock_monitor_ID_ID GetResetValue(axi_clock_monitor_ID,"ID")
  `define UPDATE_axi_clock_monitor_ID_ID(x,y) UpdateField(axi_clock_monitor_ID,"ID",x,y)

  const reg_t axi_clock_monitor_NUM_OF_CLOCKS = '{ 'h000c, "NUM_OF_CLOCKS" , '{
    "NUM_OF_CLOCKS": '{ 31, 0, RW, 'h00000008 }}};
  `define SET_axi_clock_monitor_NUM_OF_CLOCKS_NUM_OF_CLOCKS(x) SetField(axi_clock_monitor_NUM_OF_CLOCKS,"NUM_OF_CLOCKS",x)
  `define GET_axi_clock_monitor_NUM_OF_CLOCKS_NUM_OF_CLOCKS(x) GetField(axi_clock_monitor_NUM_OF_CLOCKS,"NUM_OF_CLOCKS",x)
  `define DEFAULT_axi_clock_monitor_NUM_OF_CLOCKS_NUM_OF_CLOCKS GetResetValue(axi_clock_monitor_NUM_OF_CLOCKS,"NUM_OF_CLOCKS")
  `define UPDATE_axi_clock_monitor_NUM_OF_CLOCKS_NUM_OF_CLOCKS(x,y) UpdateField(axi_clock_monitor_NUM_OF_CLOCKS,"NUM_OF_CLOCKS",x,y)

  const reg_t axi_clock_monitor_OUT_RESET = '{ 'h0010, "OUT_RESET" , '{
    "reset": '{ 0x0, 0x0, RW, 'h00 }}};
  `define SET_axi_clock_monitor_OUT_RESET_reset(x) SetField(axi_clock_monitor_OUT_RESET,"reset",x)
  `define GET_axi_clock_monitor_OUT_RESET_reset(x) GetField(axi_clock_monitor_OUT_RESET,"reset",x)
  `define DEFAULT_axi_clock_monitor_OUT_RESET_reset GetResetValue(axi_clock_monitor_OUT_RESET,"reset")
  `define UPDATE_axi_clock_monitor_OUT_RESET_reset(x,y) UpdateField(axi_clock_monitor_OUT_RESET,"reset",x,y)

  const reg_t axi_clock_monitor_CLOCK_0 = '{ 'h0040, "CLOCK_0" , '{
    "clock_0": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_0_clock_0(x) SetField(axi_clock_monitor_CLOCK_0,"clock_0",x)
  `define GET_axi_clock_monitor_CLOCK_0_clock_0(x) GetField(axi_clock_monitor_CLOCK_0,"clock_0",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_0_clock_0 GetResetValue(axi_clock_monitor_CLOCK_0,"clock_0")
  `define UPDATE_axi_clock_monitor_CLOCK_0_clock_0(x,y) UpdateField(axi_clock_monitor_CLOCK_0,"clock_0",x,y)

  const reg_t axi_clock_monitor_CLOCK_1 = '{ 'h0044, "CLOCK_1" , '{
    "clock_1": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_1_clock_1(x) SetField(axi_clock_monitor_CLOCK_1,"clock_1",x)
  `define GET_axi_clock_monitor_CLOCK_1_clock_1(x) GetField(axi_clock_monitor_CLOCK_1,"clock_1",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_1_clock_1 GetResetValue(axi_clock_monitor_CLOCK_1,"clock_1")
  `define UPDATE_axi_clock_monitor_CLOCK_1_clock_1(x,y) UpdateField(axi_clock_monitor_CLOCK_1,"clock_1",x,y)

  const reg_t axi_clock_monitor_CLOCK_2 = '{ 'h0048, "CLOCK_2" , '{
    "clock_2": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_2_clock_2(x) SetField(axi_clock_monitor_CLOCK_2,"clock_2",x)
  `define GET_axi_clock_monitor_CLOCK_2_clock_2(x) GetField(axi_clock_monitor_CLOCK_2,"clock_2",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_2_clock_2 GetResetValue(axi_clock_monitor_CLOCK_2,"clock_2")
  `define UPDATE_axi_clock_monitor_CLOCK_2_clock_2(x,y) UpdateField(axi_clock_monitor_CLOCK_2,"clock_2",x,y)

  const reg_t axi_clock_monitor_CLOCK_3 = '{ 'h004c, "CLOCK_3" , '{
    "clock_3": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_3_clock_3(x) SetField(axi_clock_monitor_CLOCK_3,"clock_3",x)
  `define GET_axi_clock_monitor_CLOCK_3_clock_3(x) GetField(axi_clock_monitor_CLOCK_3,"clock_3",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_3_clock_3 GetResetValue(axi_clock_monitor_CLOCK_3,"clock_3")
  `define UPDATE_axi_clock_monitor_CLOCK_3_clock_3(x,y) UpdateField(axi_clock_monitor_CLOCK_3,"clock_3",x,y)

  const reg_t axi_clock_monitor_CLOCK_4 = '{ 'h0050, "CLOCK_4" , '{
    "clock_4": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_4_clock_4(x) SetField(axi_clock_monitor_CLOCK_4,"clock_4",x)
  `define GET_axi_clock_monitor_CLOCK_4_clock_4(x) GetField(axi_clock_monitor_CLOCK_4,"clock_4",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_4_clock_4 GetResetValue(axi_clock_monitor_CLOCK_4,"clock_4")
  `define UPDATE_axi_clock_monitor_CLOCK_4_clock_4(x,y) UpdateField(axi_clock_monitor_CLOCK_4,"clock_4",x,y)

  const reg_t axi_clock_monitor_CLOCK_5 = '{ 'h0054, "CLOCK_5" , '{
    "clock_5": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_5_clock_5(x) SetField(axi_clock_monitor_CLOCK_5,"clock_5",x)
  `define GET_axi_clock_monitor_CLOCK_5_clock_5(x) GetField(axi_clock_monitor_CLOCK_5,"clock_5",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_5_clock_5 GetResetValue(axi_clock_monitor_CLOCK_5,"clock_5")
  `define UPDATE_axi_clock_monitor_CLOCK_5_clock_5(x,y) UpdateField(axi_clock_monitor_CLOCK_5,"clock_5",x,y)

  const reg_t axi_clock_monitor_CLOCK_6 = '{ 'h0058, "CLOCK_6" , '{
    "clock_6": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_6_clock_6(x) SetField(axi_clock_monitor_CLOCK_6,"clock_6",x)
  `define GET_axi_clock_monitor_CLOCK_6_clock_6(x) GetField(axi_clock_monitor_CLOCK_6,"clock_6",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_6_clock_6 GetResetValue(axi_clock_monitor_CLOCK_6,"clock_6")
  `define UPDATE_axi_clock_monitor_CLOCK_6_clock_6(x,y) UpdateField(axi_clock_monitor_CLOCK_6,"clock_6",x,y)

  const reg_t axi_clock_monitor_CLOCK_7 = '{ 'h005c, "CLOCK_7" , '{
    "clock_7": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_7_clock_7(x) SetField(axi_clock_monitor_CLOCK_7,"clock_7",x)
  `define GET_axi_clock_monitor_CLOCK_7_clock_7(x) GetField(axi_clock_monitor_CLOCK_7,"clock_7",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_7_clock_7 GetResetValue(axi_clock_monitor_CLOCK_7,"clock_7")
  `define UPDATE_axi_clock_monitor_CLOCK_7_clock_7(x,y) UpdateField(axi_clock_monitor_CLOCK_7,"clock_7",x,y)

  const reg_t axi_clock_monitor_CLOCK_8 = '{ 'h0060, "CLOCK_8" , '{
    "clock_8": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_8_clock_8(x) SetField(axi_clock_monitor_CLOCK_8,"clock_8",x)
  `define GET_axi_clock_monitor_CLOCK_8_clock_8(x) GetField(axi_clock_monitor_CLOCK_8,"clock_8",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_8_clock_8 GetResetValue(axi_clock_monitor_CLOCK_8,"clock_8")
  `define UPDATE_axi_clock_monitor_CLOCK_8_clock_8(x,y) UpdateField(axi_clock_monitor_CLOCK_8,"clock_8",x,y)

  const reg_t axi_clock_monitor_CLOCK_9 = '{ 'h0064, "CLOCK_9" , '{
    "clock_9": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_9_clock_9(x) SetField(axi_clock_monitor_CLOCK_9,"clock_9",x)
  `define GET_axi_clock_monitor_CLOCK_9_clock_9(x) GetField(axi_clock_monitor_CLOCK_9,"clock_9",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_9_clock_9 GetResetValue(axi_clock_monitor_CLOCK_9,"clock_9")
  `define UPDATE_axi_clock_monitor_CLOCK_9_clock_9(x,y) UpdateField(axi_clock_monitor_CLOCK_9,"clock_9",x,y)

  const reg_t axi_clock_monitor_CLOCK_10 = '{ 'h0068, "CLOCK_10" , '{
    "clock_10": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_10_clock_10(x) SetField(axi_clock_monitor_CLOCK_10,"clock_10",x)
  `define GET_axi_clock_monitor_CLOCK_10_clock_10(x) GetField(axi_clock_monitor_CLOCK_10,"clock_10",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_10_clock_10 GetResetValue(axi_clock_monitor_CLOCK_10,"clock_10")
  `define UPDATE_axi_clock_monitor_CLOCK_10_clock_10(x,y) UpdateField(axi_clock_monitor_CLOCK_10,"clock_10",x,y)

  const reg_t axi_clock_monitor_CLOCK_11 = '{ 'h006c, "CLOCK_11" , '{
    "clock_11": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_11_clock_11(x) SetField(axi_clock_monitor_CLOCK_11,"clock_11",x)
  `define GET_axi_clock_monitor_CLOCK_11_clock_11(x) GetField(axi_clock_monitor_CLOCK_11,"clock_11",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_11_clock_11 GetResetValue(axi_clock_monitor_CLOCK_11,"clock_11")
  `define UPDATE_axi_clock_monitor_CLOCK_11_clock_11(x,y) UpdateField(axi_clock_monitor_CLOCK_11,"clock_11",x,y)

  const reg_t axi_clock_monitor_CLOCK_12 = '{ 'h0070, "CLOCK_12" , '{
    "clock_12": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_12_clock_12(x) SetField(axi_clock_monitor_CLOCK_12,"clock_12",x)
  `define GET_axi_clock_monitor_CLOCK_12_clock_12(x) GetField(axi_clock_monitor_CLOCK_12,"clock_12",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_12_clock_12 GetResetValue(axi_clock_monitor_CLOCK_12,"clock_12")
  `define UPDATE_axi_clock_monitor_CLOCK_12_clock_12(x,y) UpdateField(axi_clock_monitor_CLOCK_12,"clock_12",x,y)

  const reg_t axi_clock_monitor_CLOCK_13 = '{ 'h0074, "CLOCK_13" , '{
    "clock_13": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_13_clock_13(x) SetField(axi_clock_monitor_CLOCK_13,"clock_13",x)
  `define GET_axi_clock_monitor_CLOCK_13_clock_13(x) GetField(axi_clock_monitor_CLOCK_13,"clock_13",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_13_clock_13 GetResetValue(axi_clock_monitor_CLOCK_13,"clock_13")
  `define UPDATE_axi_clock_monitor_CLOCK_13_clock_13(x,y) UpdateField(axi_clock_monitor_CLOCK_13,"clock_13",x,y)

  const reg_t axi_clock_monitor_CLOCK_14 = '{ 'h0078, "CLOCK_14" , '{
    "clock_14": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_14_clock_14(x) SetField(axi_clock_monitor_CLOCK_14,"clock_14",x)
  `define GET_axi_clock_monitor_CLOCK_14_clock_14(x) GetField(axi_clock_monitor_CLOCK_14,"clock_14",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_14_clock_14 GetResetValue(axi_clock_monitor_CLOCK_14,"clock_14")
  `define UPDATE_axi_clock_monitor_CLOCK_14_clock_14(x,y) UpdateField(axi_clock_monitor_CLOCK_14,"clock_14",x,y)

  const reg_t axi_clock_monitor_CLOCK_15 = '{ 'h007c, "CLOCK_15" , '{
    "clock_15": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_axi_clock_monitor_CLOCK_15_clock_15(x) SetField(axi_clock_monitor_CLOCK_15,"clock_15",x)
  `define GET_axi_clock_monitor_CLOCK_15_clock_15(x) GetField(axi_clock_monitor_CLOCK_15,"clock_15",x)
  `define DEFAULT_axi_clock_monitor_CLOCK_15_clock_15 GetResetValue(axi_clock_monitor_CLOCK_15,"clock_15")
  `define UPDATE_axi_clock_monitor_CLOCK_15_clock_15(x,y) UpdateField(axi_clock_monitor_CLOCK_15,"clock_15",x,y)


endpackage
