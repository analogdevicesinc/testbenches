global ad_project_params

set ad_project_params(ADC_DATA_PATH_WIDTH)  16     ; ##
set ad_project_params(DAC_DATA_PATH_WIDTH)  16     ; ##

set ad_project_params(ADC_PATH_TYPE) 0             ; ## RX
set ad_project_params(ADC_OFFLOAD_MEM_TYPE) 0      ; ## External storage
set ad_project_params(ADC_OFFLOAD_SIZE) 2048       ; ## Storage size in bytes
set ad_project_params(ADC_OFFLOAD_SRC_DWIDTH) 128  ; ## Source data width
set ad_project_params(ADC_OFFLOAD_DST_DWIDTH) 128  ; ## Destination data width

set ad_project_params(DAC_PATH_TYPE) 0             ; ## TX
set ad_project_params(DAC_OFFLOAD_MEM_TYPE) 0      ; ## External storage
set ad_project_params(DAC_OFFLOAD_SIZE) 2048       ; ## Storage size in bytes
set ad_project_params(DAC_OFFLOAD_SRC_DWIDTH) 128  ; ## Source data width
set ad_project_params(DAC_OFFLOAD_DST_DWIDTH) 128  ; ## Destination data width

set ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH) 512      ; ## PLDDR's AXI4 interface data width

