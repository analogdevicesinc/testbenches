# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2018 Analog Devices, Inc. All rights reserved.
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

source $ad_hdl_dir/library/util_hbm/scripts/adi_util_hbm.tcl

# hbm clk/reset
ad_ip_instance clk_vip hbm_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "HBM_CLK=hbm_clk_vip"

set hbm_clk hbm_clk_vip/clk_out

ad_ip_instance rst_vip hbm_rst_vip
adi_sim_add_define "HBM_RST=hbm_rst_vip"
ad_ip_parameter hbm_rst_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter hbm_rst_vip CONFIG.RST_POLARITY {ACTIVE_LOW}
ad_ip_parameter hbm_rst_vip CONFIG.ASYNCHRONOUS {NO}
ad_connect hbm_clk_vip/clk_out hbm_rst_vip/sync_clk
set hbm_reset hbm_rst_vip/rst_out

## DUT configuration

set src_clock_freq $ad_project_params(SRC_CLOCK_FREQ)
set dst_clock_freq $ad_project_params(DST_CLOCK_FREQ)

set data_path_width $ad_project_params(DATA_PATH_WIDTH)

set rx_tx_n 1
set src_width 1024
set dst_width 1024
set mem_size [expr 4*1024*1024*1024]

global hbm_sim


set hbm_sim 1 ; # 0 - Actual HBM   ; Requires 3rd party sim tool
                # 1 - AXI VIP

#  ------------------
#
# Blocks under test
#
#  ------------------

ad_create_hbm HBM
ad_create_util_hbm DUT $rx_tx_n $src_width $dst_width $mem_size
ad_ip_parameter DUT CONFIG.AXI_PROTOCOL 1

ad_connect_hbm HBM DUT $hbm_clk $hbm_reset

if {$hbm_sim == 0} {
  ad_connect HBM/HBM_REF_CLK_0 $sys_cpu_clk
  ad_connect HBM/APB_0_PCLK $sys_cpu_clk
}


#  ------------------
#
# Test harness
#
#  ------------------
# source clock/reset

ad_ip_instance clk_vip src_clk_vip
adi_sim_add_define "SRC_CLK=src_clk_vip"
ad_ip_parameter src_clk_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter src_clk_vip CONFIG.FREQ_HZ $src_clock_freq

ad_ip_instance rst_vip src_rst_vip
adi_sim_add_define "SRC_RST=src_rst_vip"
ad_ip_parameter src_rst_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter src_rst_vip CONFIG.RST_POLARITY {ACTIVE_LOW}
ad_ip_parameter src_rst_vip CONFIG.ASYNCHRONOUS {NO}
ad_connect src_clk_vip/clk_out src_rst_vip/sync_clk

# destination clock/reset

ad_ip_instance clk_vip dst_clk_vip
adi_sim_add_define "DST_CLK=dst_clk_vip"
ad_ip_parameter dst_clk_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter dst_clk_vip CONFIG.FREQ_HZ $dst_clock_freq

ad_ip_instance rst_vip dst_rst_vip
adi_sim_add_define "DST_RST=dst_rst_vip"
ad_ip_parameter dst_rst_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter dst_rst_vip CONFIG.RST_POLARITY {ACTIVE_LOW}
ad_ip_parameter dst_rst_vip CONFIG.ASYNCHRONOUS {NO}
ad_connect dst_clk_vip/clk_out dst_rst_vip/sync_clk


################################################################################
# src_m_axis_vip  - Master AXIS VIP for source interface
################################################################################

ad_ip_instance axi4stream_vip src_axis
adi_sim_add_define "SRC_AXIS=src_axis"
ad_ip_parameter src_axis CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter src_axis CONFIG.HAS_TREADY {1}
ad_ip_parameter src_axis CONFIG.HAS_TLAST {1}
ad_ip_parameter src_axis CONFIG.TDATA_NUM_BYTES $data_path_width

ad_connect src_clk_vip/clk_out src_axis/aclk
ad_connect src_rst_vip/rst_out src_axis/aresetn

ad_connect src_clk_vip/clk_out DUT/s_axis_aclk

ad_connect src_axis/m_axis DUT/s_axis

################################################################################
# dst_s_axis_vip - Slave AXIS VIP for destination interface
################################################################################

ad_ip_instance axi4stream_vip dst_axis
adi_sim_add_define "DST_AXIS=dst_axis"
ad_ip_parameter dst_axis CONFIG.INTERFACE_MODE {SLAVE}
ad_ip_parameter dst_axis CONFIG.TDATA_NUM_BYTES $data_path_width
ad_ip_parameter dst_axis CONFIG.HAS_TLAST {1}

ad_connect dst_clk_vip/clk_out dst_axis/aclk
ad_connect dst_rst_vip/rst_out dst_axis/aresetn

ad_connect dst_clk_vip/clk_out DUT/m_axis_aclk

ad_connect DUT/m_axis dst_axis/s_axis

