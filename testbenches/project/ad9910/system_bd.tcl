# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

#
#  Block design under test
#

# Create axi_ad9910 instance
ad_ip_instance axi_ad9910 axi_ad9910 [list \
  IODELAY_ENABLE 0 \
]

# Create external port for sync_clk (from AD9910 device - simulated in testbench)
create_bd_port -dir I sync_clk_in
ad_connect sync_clk_in axi_ad9910/sync_clk

ad_connect sys_cpu_clk axi_ad9910/delay_clk

# Create external port for parallel data clock (directly from testbench)
create_bd_port -dir I pd_clk_in
ad_connect pd_clk_in axi_ad9910/pd_clk_in

# Connect AXI interface
ad_cpu_interconnect 0x44A00000 axi_ad9910

# Create external ports for device control
create_bd_port -dir O ad9910_main_reset
create_bd_port -dir O ad9910_io_reset
create_bd_port -dir O pw_down
create_bd_port -dir I ext_sync
create_bd_port -dir O ad9910_irq
create_bd_port -dir O trig_out

# Create external ports for DDS ramp control interface
create_bd_port -dir O osk
create_bd_port -dir O drctl
create_bd_port -dir O drhold
create_bd_port -dir I drover
create_bd_port -dir I sync_smp_err
create_bd_port -dir I ram_swp_ovr
create_bd_port -dir O -from 2 -to 0 profile
create_bd_port -dir O io_update

# Create external ports for parallel data interface
create_bd_port -dir O -from 17 -to 0 db_o
create_bd_port -dir O tx_enable

# Connect device control signals
ad_connect axi_ad9910/main_reset ad9910_main_reset
ad_connect axi_ad9910/io_reset ad9910_io_reset
ad_connect axi_ad9910/pw_down pw_down
ad_connect axi_ad9910/ext_sync ext_sync
ad_connect axi_ad9910/irq ad9910_irq
ad_connect axi_ad9910/trig_out trig_out

# Connect ramp control signals
ad_connect axi_ad9910/osk osk
ad_connect axi_ad9910/drctl drctl
ad_connect axi_ad9910/drhold drhold
ad_connect axi_ad9910/drover drover
ad_connect axi_ad9910/sync_smp_err sync_smp_err
ad_connect axi_ad9910/ram_swp_ovr ram_swp_ovr
ad_connect axi_ad9910/profile profile
ad_connect axi_ad9910/io_update io_update

# Connect parallel data interface
ad_connect axi_ad9910/db_o db_o
ad_connect axi_ad9910/tx_enable tx_enable

# AXI-Stream interface - tie off for DRG mode (no DMA needed)
ad_connect sys_cpu_clk axi_ad9910/s_axis_aclk
ad_connect sys_cpu_resetn axi_ad9910/s_axis_aresetn

create_bd_port -dir O s_axis_tready
ad_connect axi_ad9910/s_axis_tready s_axis_tready

# Tie AXI-Stream inputs to ground for DRG mode
ad_connect axi_ad9910/s_axis_tvalid GND
ad_connect axi_ad9910/s_axis_tlast GND
ad_connect axi_ad9910/s_axis_tdata GND

# Set base address define
set BA_AD9910 0x44A00000
adi_sim_add_define "AXI_AD9910_BA=[format "%d" ${BA_AD9910}]"
