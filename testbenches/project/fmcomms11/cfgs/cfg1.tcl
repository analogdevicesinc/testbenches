global ad_project_params

set ad_project_params(REF_CLK_RATE) 125

set ad_project_params(RX_LANE_RATE) 5
set ad_project_params(TX_LANE_RATE) 10

set ad_project_params(DAC_OFFLOAD_TYPE) 0
set ad_project_params(DAC_OFFLOAD_SIZE) [expr 1*1024*1024]
set ad_project_params(ADC_OFFLOAD_TYPE) 0
set ad_project_params(ADC_OFFLOAD_SIZE) [expr 1*1024*1024]
set ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH) 0

set ad_project_params(RX_JESD_M) 1
set ad_project_params(RX_JESD_L) 8
set ad_project_params(RX_JESD_S) 4
set ad_project_params(RX_JESD_NP) 16
set ad_project_params(RX_JESD_F) 1
set ad_project_params(RX_JESD_K) 32

set ad_project_params(TX_JESD_M) 2
set ad_project_params(TX_JESD_L) 8
set ad_project_params(TX_JESD_S) 2
set ad_project_params(TX_JESD_NP) 16
set ad_project_params(TX_JESD_F) 1
set ad_project_params(TX_JESD_K) 32
