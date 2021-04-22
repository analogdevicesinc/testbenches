global ad_hdl_dir

source "$ad_hdl_dir/projects/common/xilinx/data_offload_bd.tcl"

global ad_project_params

## DUT configuration

set adc_data_path_width $ad_project_params(ADC_DATA_PATH_WIDTH)
set dac_data_path_width $ad_project_params(DAC_DATA_PATH_WIDTH)

set adc_path_type $ad_project_params(ADC_PATH_TYPE)
set adc_offload_mem_type $ad_project_params(ADC_OFFLOAD_MEM_TYPE)
set adc_offload_size $ad_project_params(ADC_OFFLOAD_SIZE)
set adc_offload_src_dwidth $ad_project_params(ADC_OFFLOAD_SRC_DWIDTH)
set adc_offload_dst_dwidth $ad_project_params(ADC_OFFLOAD_DST_DWIDTH)

set dac_path_type $ad_project_params(DAC_PATH_TYPE)
set dac_offload_mem_type $ad_project_params(DAC_OFFLOAD_MEM_TYPE)
set dac_offload_size $ad_project_params(DAC_OFFLOAD_SIZE)
set dac_offload_src_dwidth $ad_project_params(DAC_OFFLOAD_SRC_DWIDTH)
set dac_offload_dst_dwidth $ad_project_params(DAC_OFFLOAD_DST_DWIDTH)

set plddr_offload_data_width $ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH)
set plddr_offload_address_width $ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH)

################################################################################
# Create interface ports -- clocks and resets
################################################################################

# system clock/reset

ad_ip_instance clk_vip sys_clk_vip
adi_sim_add_define "SYS_CLK=sys_clk_vip"
ad_ip_parameter sys_clk_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter sys_clk_vip CONFIG.FREQ_HZ {100000000}

ad_ip_instance rst_vip sys_rst_vip
adi_sim_add_define "SYS_RST=sys_rst_vip"
ad_ip_parameter sys_rst_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter sys_rst_vip CONFIG.RST_POLARITY {ACTIVE_LOW}
ad_ip_parameter sys_rst_vip CONFIG.ASYNCHRONOUS {NO}

ad_connect sys_clk_vip/clk_out sys_rst_vip/sync_clk

################################################################################
# DUTs - Data Offload and its DMA's
################################################################################

ad_ip_instance axi_dmac i_rx_dmac [list \
  DMA_TYPE_SRC 1 \
  DMA_TYPE_DEST 0 \
  ID 0 \
  AXI_SLICE_SRC 1 \
  AXI_SLICE_DEST 1 \
  SYNC_TRANSFER_START 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  MAX_BYTES_PER_BURST 4096 \
  CYCLIC 0 \
  DMA_DATA_WIDTH_SRC $adc_offload_dst_dwidth \
  DMA_DATA_WIDTH_DEST 64 \
]

ad_ip_instance axi_dmac i_tx_dmac [list \
  DMA_TYPE_SRC 0 \
  DMA_TYPE_DEST 1 \
  ID 0 \
  AXI_SLICE_SRC 1 \
  AXI_SLICE_DEST 1 \
  SYNC_TRANSFER_START 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  MAX_BYTES_PER_BURST 4096 \
  CYCLIC 1 \
  DMA_DATA_WIDTH_SRC 64 \
  DMA_DATA_WIDTH_DEST $dac_offload_src_dwidth \
]

ad_data_offload_create RX_DUT \
                       0 \
                       $adc_offload_mem_type \
                       $adc_offload_size \
                       $adc_offload_src_dwidth \
                       $adc_offload_dst_dwidth \
                       $plddr_offload_data_width \
                       $plddr_offload_address_width

ad_data_offload_create TX_DUT \
                       1 \
                       $dac_offload_mem_type \
                       $dac_offload_size \
                       $dac_offload_src_dwidth \
                       $dac_offload_dst_dwidth \
                       $plddr_offload_data_width \
                       $plddr_offload_address_width


################################################################################
# mng_axi - AXI4 VIP for configuration
################################################################################

ad_ip_instance axi_interconnect axi_cfg_interconnect [ list \
  NUM_SI {1} \
  NUM_MI {4} \
]

ad_ip_instance axi_vip mng_axi
adi_sim_add_define "MNG_AXI=mng_axi"
set_property -dict [list CONFIG.ADDR_WIDTH {32} \
                         CONFIG.ARUSER_WIDTH {0} \
                         CONFIG.AWUSER_WIDTH {0} \
                         CONFIG.BUSER_WIDTH {0} \
                         CONFIG.DATA_WIDTH {32} \
                         CONFIG.HAS_BRESP {1} \
                         CONFIG.HAS_BURST {0} \
                         CONFIG.HAS_CACHE {0} \
                         CONFIG.HAS_LOCK {0} \
                         CONFIG.HAS_PROT {1} \
                         CONFIG.HAS_QOS {0} \
                         CONFIG.HAS_REGION {0} \
                         CONFIG.HAS_RRESP {1} \
                         CONFIG.HAS_WSTRB {1} \
                         CONFIG.ID_WIDTH {0} \
                         CONFIG.INTERFACE_MODE {MASTER} \
                         CONFIG.PROTOCOL {AXI4LITE} \
                         CONFIG.READ_WRITE_MODE {READ_WRITE} \
                         CONFIG.RUSER_BITS_PER_BYTE {0} \
                         CONFIG.RUSER_WIDTH {0} \
                         CONFIG.SUPPORTS_NARROW {0} \
                         CONFIG.WUSER_BITS_PER_BYTE {0} \
                         CONFIG.WUSER_WIDTH {0}] [get_bd_cells mng_axi]

# Connect AXI VIP to DUT

ad_connect axi_cfg_interconnect/S00_AXI mng_axi/M_AXI
ad_connect axi_cfg_interconnect/M00_AXI RX_DUT/s_axi
ad_connect axi_cfg_interconnect/M01_AXI i_rx_dmac/s_axi
ad_connect axi_cfg_interconnect/M02_AXI TX_DUT/s_axi
ad_connect axi_cfg_interconnect/M03_AXI i_tx_dmac/s_axi

ad_connect sys_clk_vip/clk_out RX_DUT/s_axi_aclk
ad_connect sys_clk_vip/clk_out i_rx_dmac/s_axi_aclk
ad_connect sys_clk_vip/clk_out TX_DUT/s_axi_aclk
ad_connect sys_clk_vip/clk_out i_tx_dmac/s_axi_aclk
ad_connect sys_clk_vip/clk_out mng_axi/aclk
ad_connect sys_clk_vip/clk_out axi_cfg_interconnect/ACLK
ad_connect sys_clk_vip/clk_out axi_cfg_interconnect/S00_ACLK
ad_connect sys_clk_vip/clk_out axi_cfg_interconnect/M00_ACLK
ad_connect sys_clk_vip/clk_out axi_cfg_interconnect/M01_ACLK
ad_connect sys_clk_vip/clk_out axi_cfg_interconnect/M02_ACLK
ad_connect sys_clk_vip/clk_out axi_cfg_interconnect/M03_ACLK

ad_connect sys_rst_vip/rst_out RX_DUT/s_axi_aresetn
ad_connect sys_rst_vip/rst_out i_rx_dmac/s_axi_aresetn
ad_connect sys_rst_vip/rst_out TX_DUT/s_axi_aresetn
ad_connect sys_rst_vip/rst_out i_tx_dmac/s_axi_aresetn
ad_connect sys_rst_vip/rst_out mng_axi/aresetn
ad_connect sys_rst_vip/rst_out axi_cfg_interconnect/ARESETN
ad_connect sys_rst_vip/rst_out axi_cfg_interconnect/S00_ARESETN
ad_connect sys_rst_vip/rst_out axi_cfg_interconnect/M00_ARESETN
ad_connect sys_rst_vip/rst_out axi_cfg_interconnect/M01_ARESETN
ad_connect sys_rst_vip/rst_out axi_cfg_interconnect/M02_ARESETN
ad_connect sys_rst_vip/rst_out axi_cfg_interconnect/M03_ARESETN

# Create address segments

create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 \
    [get_bd_addr_spaces mng_axi/Master_AXI] \
    [get_bd_addr_segs RX_DUT/i_data_offload/s_axi/axi_lite] \
    SEG_rx_data_offload_0_axi_lite
adi_sim_add_define "RX_DOFF_BA=[format "%d" 0x44A00000]"

create_bd_addr_seg -range 0x00010000 -offset 0x44800000 \
    [get_bd_addr_spaces mng_axi/Master_AXI] \
    [get_bd_addr_segs i_rx_dmac/s_axi/axi_lite] \
    SEG_rx_dmac_0_axi_lite
adi_sim_add_define "RX_DMA_BA=[format "%d" 0x44800000]"

create_bd_addr_seg -range 0x00010000 -offset 0x44B00000 \
    [get_bd_addr_spaces mng_axi/Master_AXI] \
    [get_bd_addr_segs TX_DUT/i_data_offload/s_axi/axi_lite] \
    SEG_tx_data_offload_0_axi_lite
adi_sim_add_define "TX_DOFF_BA=[format "%d" 0x44B00000]"

create_bd_addr_seg -range 0x00010000 -offset 0x44C00000 \
    [get_bd_addr_spaces mng_axi/Master_AXI] \
    [get_bd_addr_segs i_tx_dmac/s_axi/axi_lite] \
    SEG_tx_dmac_0_axi_lite
adi_sim_add_define "TX_DMA_BA=[format "%d" 0x44C00000]"

# source lock/reset

ad_ip_instance clk_vip src_clk_vip
adi_sim_add_define "SRC_CLK=src_clk_vip"
ad_ip_parameter src_clk_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter src_clk_vip CONFIG.FREQ_HZ {250000000}

ad_ip_instance rst_vip src_rst_vip
adi_sim_add_define "SRC_RST=src_rst_vip"
ad_ip_parameter src_rst_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter src_rst_vip CONFIG.RST_POLARITY {ACTIVE_LOW}
ad_ip_parameter src_rst_vip CONFIG.ASYNCHRONOUS {NO}
ad_connect src_clk_vip/clk_out src_rst_vip/sync_clk

################################################################################
# adc_src_m_axis_vip  - Master AXIS VIP for source interface --> ADC path
################################################################################

ad_ip_instance axi4stream_vip adc_src_axis
adi_sim_add_define "ADC_SRC_AXIS=adc_src_axis"
ad_ip_parameter adc_src_axis CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter adc_src_axis CONFIG.HAS_TREADY {1}
ad_ip_parameter adc_src_axis CONFIG.HAS_TLAST {0}
ad_ip_parameter adc_src_axis CONFIG.TDATA_NUM_BYTES $adc_data_path_width \

ad_connect src_clk_vip/clk_out adc_src_axis/aclk
ad_connect src_rst_vip/rst_out adc_src_axis/aresetn
ad_connect src_clk_vip/clk_out RX_DUT/s_axis_aclk
ad_connect src_rst_vip/rst_out RX_DUT/s_axis_aresetn
ad_connect sys_clk_vip/clk_out RX_DUT/m_axis_aclk
ad_connect sys_rst_vip/rst_out RX_DUT/m_axis_aresetn
ad_connect sys_clk_vip/clk_out i_rx_dmac/s_axis_aclk

ad_connect adc_src_axis/m_axis RX_DUT/s_axis
ad_connect RX_DUT/m_axis i_rx_dmac/s_axis

ad_connect i_rx_dmac/s_axis_xfer_req RX_DUT/init_req

if ($adc_offload_mem_type) {
  ad_connect RX_DUT/i_data_offload/ddr_calib_done VCC
}

# destination clock/reset

ad_ip_instance clk_vip dst_clk_vip
adi_sim_add_define "DST_CLK=dst_clk_vip"
ad_ip_parameter dst_clk_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter dst_clk_vip CONFIG.FREQ_HZ {250000000}

ad_ip_instance rst_vip dst_rst_vip
adi_sim_add_define "DST_RST=dst_rst_vip"
ad_ip_parameter dst_rst_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter dst_rst_vip CONFIG.RST_POLARITY {ACTIVE_LOW}
ad_ip_parameter dst_rst_vip CONFIG.ASYNCHRONOUS {NO}
ad_connect dst_clk_vip/clk_out dst_rst_vip/sync_clk

################################################################################
# dac_dst_s_axis_vip - Slave AXIS VIP for destination interface --> DAC path
################################################################################

ad_ip_instance axi4stream_vip dac_dst_axis
adi_sim_add_define "DAC_DST_AXIS=dac_dst_axis"
ad_ip_parameter dac_dst_axis CONFIG.INTERFACE_MODE {SLAVE}
ad_ip_parameter dac_dst_axis CONFIG.TDATA_NUM_BYTES $dac_data_path_width
ad_ip_parameter dac_dst_axis CONFIG.HAS_TLAST {1}

ad_connect dst_clk_vip/clk_out dac_dst_axis/aclk
ad_connect dst_rst_vip/rst_out dac_dst_axis/aresetn
ad_connect dst_clk_vip/clk_out TX_DUT/m_axis_aclk
ad_connect dst_rst_vip/rst_out TX_DUT/m_axis_aresetn
ad_connect sys_clk_vip/clk_out TX_DUT/s_axis_aclk
ad_connect sys_rst_vip/rst_out TX_DUT/s_axis_aresetn
ad_connect sys_clk_vip/clk_out i_tx_dmac/m_axis_aclk

ad_connect TX_DUT/m_axis dac_dst_axis/s_axis
ad_connect TX_DUT/s_axis i_tx_dmac/m_axis

ad_connect i_tx_dmac/m_axis_xfer_req TX_DUT/init_req

if ($dac_offload_mem_type) {
  ad_connect TX_DUT/i_data_offload/ddr_calib_done VCC
}

################################################################################
# sys_ddr_axi_vip - AXI4 VIP for DDR stub
################################################################################

ad_ip_instance axi_vip ddr_axi
adi_sim_add_define "DDR_AXI=ddr_axi"
set_property -dict [list  CONFIG.ADDR_WIDTH {32} \
                          CONFIG.ARUSER_WIDTH {0} \
                          CONFIG.AWUSER_WIDTH {0} \
                          CONFIG.BUSER_WIDTH {0} \
                          CONFIG.DATA_WIDTH {64} \
                          CONFIG.HAS_BRESP {1} \
                          CONFIG.HAS_BURST {0} \
                          CONFIG.HAS_CACHE {0} \
                          CONFIG.HAS_LOCK {0} \
                          CONFIG.HAS_PROT {1} \
                          CONFIG.HAS_QOS {0} \
                          CONFIG.HAS_REGION {0} \
                          CONFIG.HAS_RRESP {1} \
                          CONFIG.HAS_WSTRB {1} \
                          CONFIG.ID_WIDTH {0} \
                          CONFIG.INTERFACE_MODE {SLAVE} \
                          CONFIG.PROTOCOL {AXI4} \
                          CONFIG.READ_WRITE_MODE {READ_WRITE} \
                          CONFIG.RUSER_BITS_PER_BYTE {0} \
                          CONFIG.RUSER_WIDTH {0} \
                          CONFIG.SUPPORTS_NARROW {0} \
                          CONFIG.WUSER_BITS_PER_BYTE {0} \
                          CONFIG.WUSER_WIDTH {0} \
                          CONFIG.HAS_BURST.VALUE_SRC {USER} \
                          CONFIG.HAS_BURST {1}] [get_bd_cells ddr_axi]
ad_connect sys_clk_vip/clk_out ddr_axi/aclk
ad_connect sys_rst_vip/rst_out ddr_axi/aresetn

ad_ip_instance axi_interconnect axi_ddr_interconnect [ list \
  NUM_SI {2} \
  NUM_MI {1} \
]

ad_connect sys_clk_vip/clk_out axi_ddr_interconnect/ACLK
ad_connect sys_clk_vip/clk_out axi_ddr_interconnect/S00_ACLK
ad_connect sys_clk_vip/clk_out axi_ddr_interconnect/S01_ACLK
ad_connect sys_clk_vip/clk_out axi_ddr_interconnect/M00_ACLK

ad_connect sys_rst_vip/rst_out axi_ddr_interconnect/ARESETN
ad_connect sys_rst_vip/rst_out axi_ddr_interconnect/S00_ARESETN
ad_connect sys_rst_vip/rst_out axi_ddr_interconnect/S01_ARESETN
ad_connect sys_rst_vip/rst_out axi_ddr_interconnect/M00_ARESETN

ad_connect axi_ddr_interconnect/M00_AXI ddr_axi/S_AXI
ad_connect sys_clk_vip/clk_out i_rx_dmac/m_dest_axi_aclk
ad_connect sys_rst_vip/rst_out i_rx_dmac/m_dest_axi_aresetn
ad_connect axi_ddr_interconnect/S00_AXI i_rx_dmac/m_dest_axi
ad_connect sys_clk_vip/clk_out i_tx_dmac/m_src_axi_aclk
ad_connect sys_rst_vip/rst_out i_tx_dmac/m_src_axi_aresetn
ad_connect axi_ddr_interconnect/S01_AXI i_tx_dmac/m_src_axi

create_bd_addr_seg -range 2G -offset 0x80000000 \
    [get_bd_addr_spaces i_rx_dmac/m_dest_axi] \
    [get_bd_addr_segs ddr_axi/S_AXI/Reg] \
    SEG_rx_dmac_0_mm_slave
create_bd_addr_seg -range 2G -offset 0x80000000 \
    [get_bd_addr_spaces i_tx_dmac/m_src_axi] \
    [get_bd_addr_segs ddr_axi/S_AXI/Reg] \
    SEG_tx_dmac_0_mm_slave
adi_sim_add_define "SYS_MEM_BA=[format "%d" 0x80000000]"

################################################################################
# pl_ddr_axi_vip - AXI4 VIP for DDR stub
################################################################################

# NOTE: Current architecture allows just one offload controller to be connected
# to the PLDDR

set plddr_iname ""

if {$adc_offload_mem_type} {
  set plddr_iname "RX_DUT"
} elseif {$dac_offload_mem_type} {
  set plddr_iname "TX_DUT"
}

# DDR clock/reset and DDR stub instantiation

ad_ip_instance clk_vip plddr_clk_vip
adi_sim_add_define "PLDDR_CLK=plddr_clk_vip"
ad_ip_parameter plddr_clk_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter plddr_clk_vip CONFIG.FREQ_HZ {200000000}

ad_ip_instance rst_vip plddr_rst_vip
adi_sim_add_define "PLDDR_RST=plddr_rst_vip"
ad_ip_parameter plddr_rst_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter plddr_rst_vip CONFIG.RST_POLARITY {ACTIVE_LOW}

ad_ip_instance axi_vip plddr_axi
adi_sim_add_define "PLDDR_AXI=plddr_axi"
ad_ip_parameter plddr_axi CONFIG.PROTOCOL {AXI4}
ad_ip_parameter plddr_axi CONFIG.INTERFACE_MODE {SLAVE}
ad_ip_parameter plddr_axi CONFIG.READ_WRITE_MODE.VALUE_SRC PROPAGATED
ad_ip_parameter plddr_axi CONFIG.PROTOCOL.VALUE_SRC PROPAGATED
ad_ip_parameter plddr_axi CONFIG.ADDR_WIDTH.VALUE_SRC PROPAGATED
ad_ip_parameter plddr_axi CONFIG.DATA_WIDTH.VALUE_SRC PROPAGATED
ad_ip_parameter plddr_axi CONFIG.HAS_USER_BITS_PER_BYTE {0}

ad_connect plddr_clk_vip/clk_out plddr_axi/aclk
ad_connect plddr_rst_vip/rst_out plddr_axi/aresetn

if {$adc_offload_mem_type || $dac_offload_mem_type} {

  # clocks and resets for the DUT
  ad_connect plddr_clk_vip/clk_out $plddr_iname/fifo2axi_bridge/axi_clk
  ad_connect plddr_rst_vip/rst_out $plddr_iname/fifo2axi_bridge/axi_resetn

  ad_connect plddr_axi/S_AXI $plddr_iname/fifo2axi_bridge/ddr_axi

  create_bd_addr_seg -range 2G -offset 0x00000000 \
      [get_bd_addr_spaces $plddr_iname/fifo2axi_bridge/ddr_axi] \
      [get_bd_addr_segs plddr_axi/S_AXI/Reg] \
      SEG_plddr_0_mm_slave
  adi_sim_add_define "PL_MEM_BA=[format "%d" 0x00000000]"

}

# Not using external SYNC at the moment
ad_connect RX_DUT/sync_ext GND
ad_connect TX_DUT/sync_ext GND

