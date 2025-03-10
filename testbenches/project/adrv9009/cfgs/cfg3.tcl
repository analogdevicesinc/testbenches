global ad_project_params

set ad_project_params(LINK_MODE) 1

set ad_project_params(REF_CLK_RATE) 500
set ad_project_params(LANE_RATE) 10

set ad_project_params(DAC_OFFLOAD_TYPE) 0
set ad_project_params(DAC_OFFLOAD_SIZE) [expr 2*1024*1024]
set ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH) 0

set ad_project_params(TX_JESD_M) 4
set ad_project_params(TX_JESD_L) 2
set ad_project_params(TX_JESD_S) 1
set ad_project_params(TX_JESD_NP) 16
set ad_project_params(TX_JESD_F) 4
set ad_project_params(TX_JESD_K) 32

set ad_project_params(RX_JESD_M) 4
set ad_project_params(RX_JESD_L) 2
set ad_project_params(RX_JESD_S) 1
set ad_project_params(RX_JESD_NP) 16
set ad_project_params(RX_JESD_F) 4
set ad_project_params(RX_JESD_K) 32

set ad_project_params(RX_OS_JESD_M) 4
set ad_project_params(RX_OS_JESD_L) 2
set ad_project_params(RX_OS_JESD_S) 1
set ad_project_params(RX_OS_JESD_NP) 16
set ad_project_params(RX_OS_JESD_F) 4
set ad_project_params(RX_OS_JESD_K) 32
