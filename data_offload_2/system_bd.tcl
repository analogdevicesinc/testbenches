global ad_hdl_dir

source "$ad_hdl_dir/projects/common/xilinx/data_offload_bd.tcl"

global ad_project_params

## DUT configuration

set data_path_width $ad_project_params(DATA_PATH_WIDTH)

set path_type $ad_project_params(PATH_TYPE)
set offload_mem_type 0 ; ## Internal storage (BRAM)
set offload_size $ad_project_params(OFFLOAD_SIZE)
set offload_src_dwidth $ad_project_params(OFFLOAD_SRC_DWIDTH)
set offload_dst_dwidth $ad_project_params(OFFLOAD_DST_DWIDTH)
set offload_oneshot $ad_project_params(OFFLOAD_ONESHOT)

set plddr_offload_data_width $ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH)
set plddr_offload_address_width $ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH)

set src_clock_freq $ad_project_params(SRC_CLOCK_FREQ)
set dst_clock_freq $ad_project_params(DST_CLOCK_FREQ)

set dst_ready_mode $ad_project_params(DST_READY_MODE)
set dst_ready_high $ad_project_params(DST_READY_HIGH)
set dst_ready_low  $ad_project_params(DST_READY_LOW)

set src_transfers_initial_count $ad_project_params(SRC_TRANSFERS_INITIAL_COUNT)
set src_transfers_length $ad_project_params(SRC_TRANSFERS_LENGTH)
set src_transfers_delay $ad_project_params(SRC_TRANSFERS_DELAY)
set src_transfers_delayed_count $ad_project_params(SRC_TRANSFERS_DELAYED_COUNT)

set time_to_wait $ad_project_params(TIME_TO_WAIT)

## Define passthrough

if {[info exists ad_project_params(OFFLOAD_TRANSFER_LENGTH)]} {
  set offload_transfer_length $ad_project_params(OFFLOAD_TRANSFER_LENGTH)
  adi_sim_add_define "OFFLOAD_TRANSFER_LENGTH=$offload_transfer_length"
}
adi_sim_add_define "OFFLOAD_PATH_TYPE=$path_type"
adi_sim_add_define "DST_READY_MODE=$dst_ready_mode"
adi_sim_add_define "DST_READY_HIGH=$dst_ready_high"
adi_sim_add_define "DST_READY_LOW=$dst_ready_low"
adi_sim_add_define "SRC_TRANSFERS_INITIAL_COUNT=$src_transfers_initial_count"
adi_sim_add_define "SRC_TRANSFERS_LENGTH=$src_transfers_length"
adi_sim_add_define "SRC_TRANSFERS_DELAY=$src_transfers_delay"
adi_sim_add_define "SRC_TRANSFERS_DELAYED_COUNT=$src_transfers_delayed_count"
adi_sim_add_define "TIME_TO_WAIT=$time_to_wait"
adi_sim_add_define "OFFLOAD_ONESHOT=$offload_oneshot"

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

ad_data_offload_create DUT \
                       $path_type \
                       $offload_mem_type \
                       $offload_size \
                       $offload_src_dwidth \
                       $offload_dst_dwidth \
                       $plddr_offload_data_width \
                       $plddr_offload_address_width


create_bd_port -dir I -type data init_req
ad_connect init_req DUT/init_req

create_bd_port -dir I -type data sync_ext
ad_connect sync_ext DUT/sync_ext

################################################################################
# mng_axi - AXI4 VIP for configuration
################################################################################

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

ad_connect DUT/s_axi mng_axi/M_AXI

ad_connect sys_clk_vip/clk_out DUT/s_axi_aclk
ad_connect sys_clk_vip/clk_out mng_axi/aclk

ad_connect sys_rst_vip/rst_out DUT/s_axi_aresetn
ad_connect sys_rst_vip/rst_out mng_axi/aresetn

# Create address segments

create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 \
    [get_bd_addr_spaces mng_axi/Master_AXI] \
    [get_bd_addr_segs DUT/i_data_offload/s_axi/axi_lite] \
    SEG_data_offload_0_axi_lite
adi_sim_add_define "DOFF_BA=[format "%d" 0x44A00000]"

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
ad_connect src_rst_vip/rst_out DUT/s_axis_aresetn

ad_connect src_axis/m_axis DUT/s_axis
# Always assert tready for RX tests
if !$path_type {
  ad_connect src_axis/m_axis_tready VCC
}

if $offload_mem_type {
  ad_connect DUT/i_data_offload/ddr_calib_done VCC
}

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
ad_connect dst_rst_vip/rst_out DUT/m_axis_aresetn

ad_connect DUT/m_axis dst_axis/s_axis

