# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
#
# In this HDL repository, there are many different and unique modules, consisting
# of various HDL (Verilog or VHDL) components. The individual modules are
# developed independently, and may be accompanied by separate and unique license
# terms.
#
# The user should read each of these license terms, and understand the
# freedoms and responsibilities that he or she has by using this source/core.
#
# This core is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.
#
# Redistribution and use of source or resulting binaries, with or without modification
# of this file, are permitted under one of the following two license terms:
#
#   1. The GNU General Public License version 2 as published by the
#      Free Software Foundation, which can be found in the top level directory
#      of this repository (LICENSE_GPL2), and also online at:
#      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
#
# OR
#
#   2. An ADI specific BSD license, which can be found in the top level directory
#      of this repository (LICENSE_ADIBSD), and also on-line at:
#      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
#      This will allow to generate bit files and not release the source code,
#      as long as it attaches to an ADI device.
#
# ***************************************************************************
# ***************************************************************************

global ad_project_params

set DATA_WIDTH $ad_project_params(DATA_WIDTH)
set POLYNOMIAL_WIDTH $ad_project_params(POLYNOMIAL_WIDTH)

# Add design sources to the project
add_files -norecurse "$ad_hdl_dir/library/corundum/application_core/prbs.v"

create_bd_cell -type module -reference prbs prbs_dut

ad_ip_parameter prbs_dut CONFIG.DATA_WIDTH $DATA_WIDTH
ad_ip_parameter prbs_dut CONFIG.POLYNOMIAL_WIDTH $POLYNOMIAL_WIDTH

# create input data VIP
ad_ip_instance io_vip input_vip [ list \
  MODE 1 \
  WIDTH $DATA_WIDTH \
  ASYNC 0 \
]
adi_sim_add_define "INPUT_VIP=input_vip"

ad_connect input_vip/clk sys_cpu_clk
ad_connect input_vip/o prbs_dut/input_data

# create output data VIP
ad_ip_instance io_vip output_vip [ list \
  MODE 0 \
  WIDTH $DATA_WIDTH \
  ASYNC 0 \
]
adi_sim_add_define "OUTPUT_VIP=output_vip"

ad_connect output_vip/clk sys_cpu_clk
ad_connect output_vip/i prbs_dut/output_data

# create state VIP
ad_ip_instance io_vip state_vip [ list \
  MODE 0 \
  WIDTH $POLYNOMIAL_WIDTH \
  ASYNC 0 \
]
adi_sim_add_define "STATE_VIP=state_vip"

ad_connect state_vip/clk sys_cpu_clk
ad_connect state_vip/i prbs_dut/state

# create polynomial VIP
ad_ip_instance io_vip polynomial_vip [ list \
  MODE 1 \
  WIDTH $POLYNOMIAL_WIDTH \
  ASYNC 0 \
]
adi_sim_add_define "POLYNOMIAL_VIP=polynomial_vip"

ad_connect polynomial_vip/clk sys_cpu_clk
ad_connect polynomial_vip/o prbs_dut/polynomial

ad_connect GND prbs_dut/inverted

# generator
add_files -norecurse "$ad_hdl_dir/library/corundum/application_core/prbs_gen.v"

create_bd_cell -type module -reference prbs_gen prbs_gen_dut

ad_ip_parameter prbs_gen_dut CONFIG.DATA_WIDTH $DATA_WIDTH
ad_ip_parameter prbs_gen_dut CONFIG.POLYNOMIAL_WIDTH $POLYNOMIAL_WIDTH

# monitor
add_files -norecurse "$ad_hdl_dir/library/corundum/application_core/prbs_mon.v"

create_bd_cell -type module -reference prbs_mon prbs_mon_dut

ad_ip_parameter prbs_mon_dut CONFIG.DATA_WIDTH $DATA_WIDTH
ad_ip_parameter prbs_mon_dut CONFIG.POLYNOMIAL_WIDTH $POLYNOMIAL_WIDTH

# create ready VIP
ad_ip_instance io_vip ready_vip [ list \
  MODE 1 \
  WIDTH 1 \
  ASYNC 0 \
]
adi_sim_add_define "READY_VIP=ready_vip"

# create reset VIP
ad_ip_instance io_vip rstn_vip [ list \
  MODE 1 \
  WIDTH 1 \
  ASYNC 0 \
]
adi_sim_add_define "RSTN_VIP=rstn_vip"

# create reset VIP
ad_ip_instance io_vip init_vip [ list \
  MODE 1 \
  WIDTH 1 \
  ASYNC 0 \
]
adi_sim_add_define "INIT_VIP=init_vip"

# create error VIP
ad_ip_instance io_vip error_sample_vip [ list \
  MODE 0 \
  WIDTH 1 \
  ASYNC 0 \
]
adi_sim_add_define "ERROR_SAMPLE_VIP=error_sample_vip"

# create oos VIP
ad_ip_instance io_vip oos_vip [ list \
  MODE 0 \
  WIDTH 1 \
  ASYNC 0 \
]
adi_sim_add_define "OOS_VIP=oos_vip"

# create error VIP
ad_ip_instance io_vip error_bits_vip [ list \
  MODE 0 \
  WIDTH 1 \
  ASYNC 0 \
]
adi_sim_add_define "ERROR_BITS_VIP=error_bits_vip"

ad_connect prbs_gen_dut/clk sys_cpu_clk
ad_connect prbs_mon_dut/clk sys_cpu_clk
ad_connect ready_vip/clk sys_cpu_clk
ad_connect rstn_vip/clk sys_cpu_clk
ad_connect init_vip/clk sys_cpu_clk
ad_connect error_sample_vip/clk sys_cpu_clk
ad_connect error_bits_vip/clk sys_cpu_clk
ad_connect oos_vip/clk sys_cpu_clk

ad_connect ready_vip/o prbs_gen_dut/input_ready
ad_connect input_vip/o prbs_gen_dut/initial_value
ad_connect error_sample_vip/i prbs_mon_dut/error_sample
ad_connect error_bits_vip/i prbs_mon_dut/error_bits
ad_connect oos_vip/i prbs_mon_dut/out_of_sync

ad_connect prbs_gen_dut/output_valid prbs_mon_dut/input_valid
ad_connect prbs_gen_dut/output_data prbs_mon_dut/input_data

ad_connect rstn_vip/o prbs_gen_dut/rstn
ad_connect polynomial_vip/o prbs_gen_dut/polynomial
ad_connect GND prbs_gen_dut/inverted

ad_connect rstn_vip/o prbs_mon_dut/rstn
ad_connect polynomial_vip/o prbs_mon_dut/polynomial
ad_connect GND prbs_mon_dut/inverted

ad_connect init_vip/o prbs_gen_dut/init
ad_connect init_vip/o prbs_mon_dut/init
