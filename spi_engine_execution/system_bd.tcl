# ***************************************************************************
# ***************************************************************************
# Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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
#      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
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

source ./spi_execution_test_bd.tcl

# Add test-specific VIPs
ad_ip_instance adi_spi_vip spi_s_vip $ad_project_params(spi_s_vip_cfg)

adi_sim_add_define "SPI_S=spi_s_vip"
ad_connect spi_execution/spi spi_s_vip/s_spi

ad_ip_instance axi4stream_vip cmd_src [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY 1 \
  HAS_TLAST 0 \
  TDATA_NUM_BYTES 2 \
  TDEST_WIDTH 0 \
  TID_WIDTH 0 \
]
adi_sim_add_define "CMD_SRC=cmd_src"
ad_connect spi_clk cmd_src/aclk
ad_connect sys_cpu_resetn cmd_src/aresetn
ad_connect cmd_src/m_axis_tdata spi_execution/cmd
ad_connect cmd_src/m_axis_tvalid spi_execution/cmd_valid
ad_connect cmd_src/m_axis_tready spi_execution/cmd_ready

ad_ip_instance axi4stream_vip sdo_src [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY 1 \
  HAS_TLAST 0 \
  TDATA_NUM_BYTES [expr $data_width/8] \
  TDEST_WIDTH 0 \
  TID_WIDTH 0 \
]
adi_sim_add_define "SDO_SRC=sdo_src"
ad_connect spi_clk sdo_src/aclk
ad_connect sys_cpu_resetn sdo_src/aresetn
ad_connect sdo_src/m_axis_tdata spi_execution/sdo_data
ad_connect sdo_src/m_axis_tvalid spi_execution/sdo_data_valid
ad_connect sdo_src/m_axis_tready spi_execution/sdo_data_ready

ad_ip_instance axi4stream_vip sdi_sink [list \
  INTERFACE_MODE {SLAVE} \
  HAS_TREADY 1 \
  HAS_TLAST 0 \
  TDATA_NUM_BYTES [expr $num_sdi*$data_width/8] \
  TDEST_WIDTH 0 \
  TID_WIDTH 0 \
]
adi_sim_add_define "SDI_SINK=sdi_sink"
ad_connect spi_clk sdi_sink/aclk
ad_connect sys_cpu_resetn sdi_sink/aresetn
ad_connect sdi_sink/s_axis_tdata spi_execution/sdi_data
ad_connect sdi_sink/s_axis_tvalid spi_execution/sdi_data_valid
ad_connect sdi_sink/s_axis_tready spi_execution/sdi_data_ready

ad_ip_instance axi4stream_vip sync_sink [list \
  INTERFACE_MODE {SLAVE} \
  HAS_TREADY 1 \
  HAS_TLAST 0 \
  TDATA_NUM_BYTES 1 \
  TDEST_WIDTH 0 \
  TID_WIDTH 0 \
]
adi_sim_add_define "SYNC_SINK=sync_sink"
ad_connect spi_clk sync_sink/aclk
ad_connect sys_cpu_resetn sync_sink/aresetn
ad_connect sync_sink/s_axis_tdata spi_execution/sync
ad_connect sync_sink/s_axis_tvalid spi_execution/sync_valid
ad_connect sync_sink/s_axis_tready spi_execution/sync_ready

# Last tasks
create_bd_port -dir O spi_execution_spi_clk
if {$ad_project_params(ECHO_SCLK)} {
    create_bd_port -dir I spi_execution_echo_sclk
    ad_connect spi_execution_echo_sclk spi_execution/echo_sclk
}

ad_connect spi_execution_spi_clk spi_clkgen/clk_0

set BA_CLKGEN 0x44A70000
set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_spi_clkgen}]
adi_sim_add_define "SPI_ENGINE_AXI_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"

set BA_PWM 0x44B00000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_spi_engine_trigger_gen}]
adi_sim_add_define "SPI_ENGINE_PWM_GEN_BA=[format "%d" ${BA_PWM}]"