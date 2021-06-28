# ***************************************************************************
# ***************************************************************************
# Copyright 2021 (c) Analog Devices, Inc. All rights reserved.
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

source ../../library/scripts/adi_env.tcl

global ad_project_params

adi_project_files [list \
	"../../library/common/ad_edge_detect.v" \
	"../../library/util_cdc/sync_bits.v" \
        "../../library/common/ad_iobuf.v" \
]

#
#  Block design under test
#

source ../../projects/pulsar_adc_pmdz/common/pulsar_adc_pmdz_bd.tcl

create_bd_port -dir O pulsar_adc_spi_clk
create_bd_port -dir O pulsar_adc_irq

ad_connect pulsar_adc_spi_clk spi_clkgen/clk_0
ad_connect pulsar_adc_irq spi_pulsar_adc/irq

