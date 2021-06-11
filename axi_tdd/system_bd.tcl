global ad_hdl_dir

global ad_project_params

## DUT configuration

set tdd_secondary $ad_project_params(TDD_SECONDARY)
set tdd_gated_datapath $ad_project_params(TDD_GATED_DATAPATH)

set tdd_frame_length $ad_project_params(TDD_FRAME_LENGTH)
set tdd_counter_init $ad_project_params(TDD_COUNTER_INIT)
set tdd_burst_count $ad_project_params(TDD_BURST_COUNT)

set tdd_terminal_type $ad_project_params(TDD_TERMINAL_TYPE)

set tdd_primary_params $ad_project_params(TDD_PRIMARY_PARAMS)
set tdd_secondary_params $ad_project_params(TDD_SECONDARY_PARAMS)

set tdd_primary_vco_rx_on     [lindex $tdd_primary_params 0]
set tdd_primary_vco_rx_off    [lindex $tdd_primary_params 1]
set tdd_primary_vco_tx_on     [lindex $tdd_primary_params 2]
set tdd_primary_vco_tx_off    [lindex $tdd_primary_params 3]

set tdd_primary_rx_on         [lindex $tdd_primary_params 4]
set tdd_primary_rx_off        [lindex $tdd_primary_params 5]
set tdd_primary_tx_on         [lindex $tdd_primary_params 6]
set tdd_primary_tx_off        [lindex $tdd_primary_params 7]

set tdd_primary_dp_rx_on      [lindex $tdd_primary_params 8]
set tdd_primary_dp_rx_off     [lindex $tdd_primary_params 9]
set tdd_primary_dp_tx_on      [lindex $tdd_primary_params 10]
set tdd_primary_dp_tx_off     [lindex $tdd_primary_params 11]

set tdd_secondary_vco_rx_on   [lindex $tdd_secondary_params 0]
set tdd_secondary_vco_rx_off  [lindex $tdd_secondary_params 1]
set tdd_secondary_vco_tx_on   [lindex $tdd_secondary_params 2]
set tdd_secondary_vco_tx_off  [lindex $tdd_secondary_params 3]

set tdd_secondary_rx_on       [lindex $tdd_secondary_params 4]
set tdd_secondary_rx_off      [lindex $tdd_secondary_params 5]
set tdd_secondary_tx_on       [lindex $tdd_secondary_params 6]
set tdd_secondary_tx_off      [lindex $tdd_secondary_params 7]

set tdd_secondary_dp_rx_on    [lindex $tdd_secondary_params 8]
set tdd_secondary_dp_rx_off   [lindex $tdd_secondary_params 9]
set tdd_secondary_dp_tx_on    [lindex $tdd_secondary_params 10]
set tdd_secondary_dp_tx_off   [lindex $tdd_secondary_params 11]

set sim_wait $ad_project_params(SIM_WAIT)

# Parameter passthrough
adi_sim_add_define "TDD_SECONDARY=$tdd_secondary"
adi_sim_add_define "TDD_GATED_DATAPATH=$tdd_gated_datapath"

adi_sim_add_define "TDD_FRAME_LENGTH=$tdd_frame_length"
adi_sim_add_define "TDD_COUNTER_INIT=$tdd_counter_init"
adi_sim_add_define "TDD_BURST_COUNT=$tdd_burst_count"

adi_sim_add_define "TDD_TERMINAL_TYPE=$tdd_terminal_type"

adi_sim_add_define "TDD_VCO_RX_ON_1=$tdd_primary_vco_rx_on"
adi_sim_add_define "TDD_VCO_RX_OFF_1=$tdd_primary_vco_rx_off"
adi_sim_add_define "TDD_VCO_TX_ON_1=$tdd_primary_vco_tx_on"
adi_sim_add_define "TDD_VCO_TX_OFF_1=$tdd_primary_vco_tx_off"
adi_sim_add_define "TDD_RX_ON_1=$tdd_primary_rx_on"
adi_sim_add_define "TDD_RX_OFF_1=$tdd_primary_rx_off"
adi_sim_add_define "TDD_TX_ON_1=$tdd_primary_tx_on"
adi_sim_add_define "TDD_TX_OFF_1=$tdd_primary_tx_off"
adi_sim_add_define "TDD_RX_DP_ON_1=$tdd_primary_dp_rx_on"
adi_sim_add_define "TDD_RX_DP_OFF_1=$tdd_primary_dp_rx_off"
adi_sim_add_define "TDD_TX_DP_ON_1=$tdd_primary_dp_tx_on"
adi_sim_add_define "TDD_TX_DP_OFF_1=$tdd_primary_dp_tx_off"

adi_sim_add_define "TDD_VCO_RX_ON_2=$tdd_secondary_vco_rx_on"
adi_sim_add_define "TDD_VCO_RX_OFF_2=$tdd_secondary_vco_rx_off"
adi_sim_add_define "TDD_VCO_TX_ON_2=$tdd_secondary_vco_tx_on"
adi_sim_add_define "TDD_VCO_TX_OFF_2=$tdd_secondary_vco_tx_off"
adi_sim_add_define "TDD_RX_ON_2=$tdd_secondary_rx_on"
adi_sim_add_define "TDD_RX_OFF_2=$tdd_secondary_rx_off"
adi_sim_add_define "TDD_TX_ON_2=$tdd_secondary_tx_on"
adi_sim_add_define "TDD_TX_OFF_2=$tdd_secondary_tx_off"
adi_sim_add_define "TDD_RX_DP_ON_2=$tdd_secondary_dp_rx_on"
adi_sim_add_define "TDD_RX_DP_OFF_2=$tdd_secondary_dp_rx_off"
adi_sim_add_define "TDD_TX_DP_ON_2=$tdd_secondary_dp_tx_on"
adi_sim_add_define "TDD_TX_DP_OFF_2=$tdd_secondary_dp_tx_off"

adi_sim_add_define "SIM_WAIT=$sim_wait"

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

ad_ip_instance clk_vip dev_clk_vip
adi_sim_add_define "DEV_CLK=dev_clk_vip"
ad_ip_parameter dev_clk_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter dev_clk_vip CONFIG.FREQ_HZ {100000000}

ad_ip_instance rst_vip dev_rst_vip
adi_sim_add_define "DEV_RST=dev_rst_vip"
ad_ip_parameter dev_rst_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter dev_rst_vip CONFIG.RST_POLARITY {ACTIVE_HIGH}
ad_ip_parameter dev_rst_vip CONFIG.ASYNCHRONOUS {NO}

ad_connect dev_clk_vip/clk_out dev_rst_vip/sync_clk

################################################################################
# DUTs - Data Offload and its DMA's
################################################################################

ad_ip_instance axi_tdd DUT

create_bd_port -dir I -type data tdd_sync
ad_connect tdd_sync DUT/tdd_sync

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

ad_connect dev_clk_vip/clk_out DUT/clk
ad_connect dev_rst_vip/rst_out DUT/rst

# Create address segments

create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 \
    [get_bd_addr_spaces mng_axi/Master_AXI] \
    [get_bd_addr_segs DUT/s_axi/axi_lite] \
    SEG_data_offload_0_axi_lite
adi_sim_add_define "TDD_BA=[format "%d" 0x44A00000]"

