###############################################################################
## Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

global ad_project_params

source $ad_hdl_dir/library/spi_engine/scripts/spi_engine.tcl

set data_width              $ad_project_params(DATA_WIDTH)
set async_spi_clk           $ad_project_params(ASYNC_SPI_CLK)
set offload_en              1; # offload capability is needed for the testbenches
set num_cs                  $ad_project_params(NUM_OF_CS)
set num_sdi                 $ad_project_params(NUM_OF_SDI)
set num_sdo                 $ad_project_params(NUM_OF_SDO)
set sdi_delay               $ad_project_params(SDI_DELAY)
set echo_sclk               $ad_project_params(ECHO_SCLK)
set sdo_streaming           $ad_project_params(SDO_STREAMING)
set cmd_mem_addr_width      $ad_project_params(CMD_MEM_ADDR_WIDTH)
set data_mem_addr_width     $ad_project_params(DATA_MEM_ADDR_WIDTH)
set sdi_fifo_addr_width     $ad_project_params(SDI_FIFO_ADDR_WIDTH)
set sdo_fifo_addr_width     $ad_project_params(SDO_FIFO_ADDR_WIDTH)
set sync_fifo_addr_width    $ad_project_params(SYNC_FIFO_ADDR_WIDTH)
set cmd_fifo_addr_width     $ad_project_params(CMD_FIFO_ADDR_WIDTH)

create_bd_intf_port -mode Monitor -vlnv analog.com:interface:spi_engine_rtl:1.0 spi_engine_spi

set hier_spi_engine spi_engine

spi_engine_create $hier_spi_engine  $data_width $async_spi_clk $offload_en \
                                    $num_cs $num_sdi $num_sdo $sdi_delay \
                                    $echo_sclk $sdo_streaming \
                                    $cmd_mem_addr_width $data_mem_addr_width \
                                    $sdi_fifo_addr_width $sdo_fifo_addr_width \
                                    $sync_fifo_addr_width $cmd_fifo_addr_width

if {$ad_project_params(ECHO_SCLK)} {
  ad_ip_parameter $hier_spi_engine/${hier_spi_engine}_execution CONFIG.DEFAULT_SPI_CFG [expr ($ad_project_params(CPOL) * 2) + $ad_project_params(CPHA)]
}

ad_ip_instance axi_clkgen spi_clkgen
ad_ip_parameter spi_clkgen CONFIG.CLK0_DIV 5
ad_ip_parameter spi_clkgen CONFIG.VCO_DIV 1
ad_ip_parameter spi_clkgen CONFIG.VCO_MUL 8

ad_ip_instance axi_pwm_gen spi_engine_trigger_gen
ad_ip_parameter spi_engine_trigger_gen CONFIG.PULSE_0_PERIOD 120
ad_ip_parameter spi_engine_trigger_gen CONFIG.PULSE_0_WIDTH 1

# dma to receive data stream
ad_ip_instance axi_dmac axi_spi_engine_dma
ad_ip_parameter axi_spi_engine_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter axi_spi_engine_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_spi_engine_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_spi_engine_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter axi_spi_engine_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_spi_engine_dma CONFIG.AXI_SLICE_DEST 1
ad_ip_parameter axi_spi_engine_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_spi_engine_dma CONFIG.DMA_DATA_WIDTH_SRC $data_width
ad_ip_parameter axi_spi_engine_dma CONFIG.DMA_DATA_WIDTH_DEST 64

ad_connect $sys_cpu_clk spi_clkgen/clk
ad_connect spi_clk spi_clkgen/clk_0

ad_connect spi_clk spi_engine_trigger_gen/ext_clk
ad_connect $sys_cpu_clk spi_engine_trigger_gen/s_axi_aclk
ad_connect sys_cpu_resetn spi_engine_trigger_gen/s_axi_aresetn
ad_connect spi_engine_trigger_gen/pwm_0 $hier_spi_engine/trigger

ad_connect axi_spi_engine_dma/s_axis $hier_spi_engine/M_AXIS_SAMPLE
ad_connect $hier_spi_engine/m_spi spi_engine_spi

ad_connect $sys_cpu_clk $hier_spi_engine/clk
ad_connect spi_clk $hier_spi_engine/spi_clk
ad_connect spi_clk axi_spi_engine_dma/s_axis_aclk
ad_connect sys_cpu_resetn $hier_spi_engine/resetn
ad_connect sys_cpu_resetn axi_spi_engine_dma/m_dest_axi_aresetn

ad_cpu_interconnect 0x44a00000 $hier_spi_engine/${hier_spi_engine}_axi_regmap
ad_cpu_interconnect 0x44a30000 axi_spi_engine_dma
ad_cpu_interconnect 0x44a70000 spi_clkgen
ad_cpu_interconnect 0x44b00000 spi_engine_trigger_gen

ad_cpu_interrupt "ps-13" "mb-13" axi_spi_engine_dma/irq
ad_cpu_interrupt "ps-12" "mb-12" /$hier_spi_engine/irq

ad_mem_hp1_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect $sys_cpu_clk axi_spi_engine_dma/m_dest_axi

if {$ad_project_params(ECHO_SCLK)} {
  adi_sim_add_define DEF_ECHO_SCLK
}
if {$ad_project_params(SDO_STREAMING)} {
  adi_sim_add_define DEF_SDO_STREAMING
}
