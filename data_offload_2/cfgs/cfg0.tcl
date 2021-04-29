global ad_project_params

set ad_project_params(DATA_PATH_WIDTH) 16             ; ## 16 bytes

set ad_project_params(PATH_TYPE) 1                    ; ## TX
set ad_project_params(OFFLOAD_SIZE) 1024              ; ## 1 KiB
set ad_project_params(OFFLOAD_SRC_DWIDTH) 128         ; ## Source data width
set ad_project_params(OFFLOAD_DST_DWIDTH) 128         ; ## Destination data width

set ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH) 512   ; ## PLDDR's AXI4 interface data width
set ad_project_params(PLDDR_OFFLOAD_ADDRESS_WIDTH) 28 ; ## PLDDR's AXI4 interface address width

set ad_project_params(SRC_CLOCK_FREQ) 250000000       ; ## Source clock frequency in Hz
set ad_project_params(DST_CLOCK_FREQ) 300000000       ; ## Destination clock frequency in Hz

