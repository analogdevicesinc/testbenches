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

source ../../scripts/adi_env.tcl

global ad_project_params

adi_project_files [list \
	"../../library/common/ad_edge_detect.v" \
	"../../library/util_cdc/sync_bits.v" \
        "../../library/common/ad_iobuf.v" \
]

#
#  Block design under test
#

create_bd_intf_port -mode Master -vlnv analog.com:interface:i3c_controller_rtl:1.0 i3c_controller_0

source $ad_hdl_dir/library/i3c_controller/scripts/i3c_controller.tcl

set async_clk 0
set offload 1
set max_devs 16

set hier_i3c_controller i3c_controller_0

i3c_controller_create $hier_i3c_controller $async_clk $offload $max_devs

# pwm to trigger on offload data burst
ad_ip_instance axi_pwm_gen i3c_offload_pwm
ad_ip_parameter i3c_offload_pwm CONFIG.PULSE_0_PERIOD 120
ad_ip_parameter i3c_offload_pwm CONFIG.PULSE_0_WIDTH 1

# dma to receive offload data stream
ad_ip_instance axi_dmac i3c_offload_dma
ad_ip_parameter i3c_offload_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter i3c_offload_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter i3c_offload_dma CONFIG.CYCLIC 0
ad_ip_parameter i3c_offload_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter i3c_offload_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter i3c_offload_dma CONFIG.AXI_SLICE_DEST 1
ad_ip_parameter i3c_offload_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter i3c_offload_dma CONFIG.DMA_DATA_WIDTH_SRC 32
ad_ip_parameter i3c_offload_dma CONFIG.DMA_DATA_WIDTH_DEST 64

ad_connect $sys_cpu_clk i3c_offload_pwm/ext_clk
ad_connect $sys_cpu_clk i3c_offload_pwm/s_axi_aclk
ad_connect sys_cpu_resetn i3c_offload_pwm/s_axi_aresetn
ad_connect i3c_offload_pwm/pwm_0 $hier_i3c_controller/trigger

ad_connect i3c_offload_dma/s_axis $hier_i3c_controller/m_offload
ad_connect $hier_i3c_controller/m_i3c i3c_controller_0

ad_connect $sys_cpu_clk $hier_i3c_controller/clk
ad_connect $sys_cpu_clk i3c_offload_dma/s_axis_aclk
ad_connect sys_cpu_resetn $hier_i3c_controller/reset_n
ad_connect sys_cpu_resetn i3c_offload_dma/m_dest_axi_aresetn

ad_cpu_interconnect 0x44a00000 $hier_i3c_controller/host_interface
ad_cpu_interconnect 0x44a30000 i3c_offload_dma
ad_cpu_interconnect 0x44b00000 i3c_offload_pwm

ad_cpu_interrupt "ps-13" "mb-13" i3c_offload_dma/irq
ad_cpu_interrupt "ps-12" "mb-12" /$hier_i3c_controller/irq

ad_mem_hp1_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect $sys_cpu_clk i3c_offload_dma/m_dest_axi

create_bd_port -dir O i3c_irq
create_bd_port -dir O i3c_clk

ad_connect i3c_irq i3c_controller_0/irq
ad_connect i3c_clk sys_clk_vip/clk_out
