# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2022 Analog Devices, Inc. All rights reserved.
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


source $ad_hdl_dir/projects/scripts/adi_board.tcl

global ad_project_params

## DUT configuration


ad_ip_instance axi_gpio_adi gpio_ip


set BA 0x50000000


ad_cpu_interconnect [expr ${BA} + 0x40000] gpio_ip


create_bd_port -dir O  -from 31 -to 0 gpio_m_io_o
create_bd_port -dir I  -from 31 -to 0 gpio_m_io_i
create_bd_port -dir O  -from 31 -to 0 gpio_m_io_t
create_bd_port -dir O irq_0


ad_connect gpio_m_io_i gpio_ip/gpio_io_i
ad_connect gpio_m_io_o gpio_ip/gpio_io_o
ad_connect gpio_m_io_t gpio_ip/gpio_io_t
ad_connect irq_0       gpio_ip/irq


ad_cpu_interrupt "ps-0" "mb-0" gpio_ip/irq



