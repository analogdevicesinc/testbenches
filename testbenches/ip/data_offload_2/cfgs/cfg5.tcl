# TX / cyclic
global ad_project_params

set ad_project_params(MEM_TYPE) 2                     ; ## External storage (HBM)
set ad_project_params(PATH_TYPE) 1                    ; ## TX
set ad_project_params(OFFLOAD_SIZE) [expr 4*256*1024*1024] ; ## 4 segments of 256MB
set ad_project_params(OFFLOAD_TRANSFER_LENGTH) 4096   ; ## 4096 bytes
set ad_project_params(OFFLOAD_SRC_DWIDTH) 1024        ; ## Source data width
set ad_project_params(OFFLOAD_DST_DWIDTH) 1024        ; ## Destination data width
set ad_project_params(OFFLOAD_ONESHOT) 0              ; ## Enable cyclic mode

set ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH) 256   ; ## HBM's AXI3 interface data width

set ad_project_params(SRC_CLOCK_FREQ) 250000000       ; ## Source clock frequency in Hz
set ad_project_params(DST_CLOCK_FREQ) 300000000       ; ## Destination clock frequency in Hz
