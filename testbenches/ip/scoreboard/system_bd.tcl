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

global ad_project_params

ad_ip_instance axi4stream_vip adc_src_axis [list \
  INTERFACE_MODE {MASTER} \
  TDATA_NUM_BYTES 2 \
  HAS_TREADY {1} \
  HAS_TKEEP {1} \
  HAS_TLAST {1} \
]
adi_sim_add_define "ADC_SRC_AXIS=adc_src_axis"

ad_connect sys_dma_clk adc_src_axis/aclk
ad_connect sys_dma_resetn adc_src_axis/aresetn

ad_ip_instance axi4stream_vip dac_dst_axis [list \
  INTERFACE_MODE {SLAVE} \
  TDATA_NUM_BYTES 2 \
  HAS_TREADY {1} \
  HAS_TKEEP {1} \
  HAS_TLAST {1} \
]
adi_sim_add_define "DAC_DST_AXIS=dac_dst_axis"

ad_connect sys_dma_clk dac_dst_axis/aclk
ad_connect sys_dma_resetn dac_dst_axis/aresetn

ad_connect adc_src_axis/m_axis dac_dst_axis/s_axis
