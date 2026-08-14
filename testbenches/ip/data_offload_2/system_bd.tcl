# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2022-2026 Analog Devices, Inc. All rights reserved.
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

source "$ad_hdl_dir/projects/common/xilinx/data_offload_bd.tcl"

## DUT configuration

set path_type $ad_project_params(PATH_TYPE)
set offload_mem_type $ad_project_params(MEM_TYPE)
set offload_size $ad_project_params(OFFLOAD_SIZE)
set offload_src_dwidth $ad_project_params(OFFLOAD_SRC_DWIDTH)
set offload_dst_dwidth $ad_project_params(OFFLOAD_DST_DWIDTH)
set offload_oneshot $ad_project_params(OFFLOAD_ONESHOT)

set ext_mem_axi_data_width $ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH)

set src_clock_freq $ad_project_params(SRC_CLOCK_FREQ)
set dst_clock_freq $ad_project_params(DST_CLOCK_FREQ)
set mem_clock_freq 300000000

################################################################################
# DUTs - Data Offload and its DMA's
################################################################################

ad_data_offload_create DUT \
                       $path_type \
                       $offload_mem_type \
                       $offload_size \
                       $offload_src_dwidth \
                       $offload_dst_dwidth \
                       $ext_mem_axi_data_width \

set DO_BA 0x44A00000
ad_cpu_interconnect $DO_BA DUT
adi_sim_add_define "DOFF_BA=[format "%d" ${DO_BA}]"

# Data Offload control signals

ad_ip_instance io_vip init_req_io_vip
adi_sim_add_define "INIT_REQ=init_req_io_vip"
ad_connect sys_clk_vip/clk_out init_req_io_vip/clk
ad_connect init_req_io_vip/o DUT/init_req

ad_ip_instance io_vip sync_ext_io_vip
adi_sim_add_define "SYNC_EXT=sync_ext_io_vip"
ad_connect sys_clk_vip/clk_out sync_ext_io_vip/clk
ad_connect sync_ext_io_vip/o DUT/sync_ext

# source clock/reset

ad_ip_instance clk_vip src_clk_vip
adi_sim_add_define "SRC_CLK=src_clk_vip"
ad_ip_parameter src_clk_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter src_clk_vip CONFIG.FREQ_HZ $src_clock_freq

ad_ip_instance proc_sys_reset src_axis_rstgen
ad_ip_parameter src_axis_rstgen CONFIG.C_EXT_RST_WIDTH 1
ad_connect sys_rst_vip/rst_out src_axis_rstgen/ext_reset_in
ad_connect src_clk_vip/clk_out src_axis_rstgen/slowest_sync_clk

# destination clock/reset

ad_ip_instance clk_vip dst_clk_vip
adi_sim_add_define "DST_CLK=dst_clk_vip"
ad_ip_parameter dst_clk_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter dst_clk_vip CONFIG.FREQ_HZ $dst_clock_freq

ad_ip_instance proc_sys_reset dst_axis_rstgen
ad_ip_parameter dst_axis_rstgen CONFIG.C_EXT_RST_WIDTH 1
ad_connect sys_rst_vip/rst_out dst_axis_rstgen/ext_reset_in
ad_connect dst_clk_vip/clk_out dst_axis_rstgen/slowest_sync_clk

################################################################################
# src_m_axis_vip  - Master AXIS VIP for source interface
################################################################################

ad_ip_instance axi4stream_vip src_axis
adi_sim_add_define "SRC_AXIS=src_axis"
ad_ip_parameter src_axis CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter src_axis CONFIG.HAS_TREADY {1}
ad_ip_parameter src_axis CONFIG.HAS_TLAST {1}
ad_ip_parameter src_axis CONFIG.TDATA_NUM_BYTES [expr $offload_src_dwidth/8]

ad_connect src_axis/aclk    src_clk_vip/clk_out
ad_connect src_axis/aresetn src_axis_rstgen/peripheral_aresetn

ad_connect DUT/s_axis_aclk    src_clk_vip/clk_out
ad_connect DUT/s_axis_aresetn src_axis_rstgen/peripheral_aresetn

ad_connect src_axis/m_axis DUT/s_axis

if $offload_mem_type {
  ad_connect DUT/i_data_offload/ddr_calib_done VCC
}

################################################################################
# dst_s_axis_vip - Slave AXIS VIP for destination interface
################################################################################

ad_ip_instance axi4stream_vip dst_axis
adi_sim_add_define "DST_AXIS=dst_axis"
ad_ip_parameter dst_axis CONFIG.INTERFACE_MODE {SLAVE}
ad_ip_parameter dst_axis CONFIG.TDATA_NUM_BYTES [expr $offload_dst_dwidth/8]
ad_ip_parameter dst_axis CONFIG.HAS_TLAST {1}

ad_connect dst_axis/aclk    dst_clk_vip/clk_out
ad_connect dst_axis/aresetn dst_axis_rstgen/peripheral_aresetn

ad_connect DUT/m_axis_aclk    dst_clk_vip/clk_out
ad_connect DUT/m_axis_aresetn dst_axis_rstgen/peripheral_aresetn

ad_connect DUT/m_axis dst_axis/s_axis

if {$offload_mem_type == 2} {

  source $ad_hdl_dir/library/util_hbm/scripts/adi_util_hbm.tcl

  # HBM clock/reset

  ad_ip_instance clk_vip mem_clk_vip
  adi_sim_add_define "MEM_CLK=mem_clk_vip"
  ad_ip_parameter mem_clk_vip CONFIG.INTERFACE_MODE {MASTER}
  ad_ip_parameter mem_clk_vip CONFIG.FREQ_HZ $mem_clock_freq

  ad_ip_instance proc_sys_reset mem_rstgen
  ad_ip_parameter mem_rstgen CONFIG.C_EXT_RST_WIDTH 1
  ad_connect sys_rst_vip/rst_out mem_rstgen/ext_reset_in
  ad_connect mem_clk_vip/clk_out mem_rstgen/slowest_sync_clk

  set hbm_clk   mem_clk_vip/clk_out
  set hbm_reset mem_rstgen/peripheral_aresetn

  global hbm_sim
  set hbm_sim 1
  ad_create_hbm HBM_VIP

  ad_connect_hbm HBM_VIP DUT/storage_unit $hbm_clk $hbm_reset

  assign_bd_address
  set num_m [get_property CONFIG.NUM_M [get_bd_cells /DUT/storage_unit]]
  for {set i 0} {$i < $num_m} {incr i} {
    set_property offset 0x00000000 [get_bd_addr_segs DUT/storage_unit/MAXI_${i}/SEG_HBM_VIP_Reg]
    set_property range 4G [get_bd_addr_segs DUT/storage_unit/MAXI_${i}/SEG_HBM_VIP_Reg]
  }

}
