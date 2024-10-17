# TX / oneshot
global ad_project_params

set ad_project_params(DATA_PATH_WIDTH) 16             ; ## 16 bytes

set ad_project_params(MEM_TYPE) 2                     ; ## External storage (HBM)
set ad_project_params(PATH_TYPE) 1                    ; ## TX
set ad_project_params(OFFLOAD_SIZE) [expr 4*256*1024*1024] ; ## 4 segments of 256MB
set ad_project_params(OFFLOAD_SRC_DWIDTH) 1024        ; ## Source data width
set ad_project_params(OFFLOAD_DST_DWIDTH) 1024        ; ## Destination data width
set ad_project_params(OFFLOAD_ONESHOT) 0              ; ## Enable oneshot mode

set ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH) 256   ; ## PLDDR's AXI4 interface data width

set ad_project_params(SRC_CLOCK_FREQ) 250000000       ; ## Source clock frequency in Hz
set ad_project_params(DST_CLOCK_FREQ) 300000000       ; ## Destination clock frequency in Hz

set ad_project_params(SRC_TRANSFERS_INITIAL_COUNT) 20 ; ## Count of transfers initially queued up.
                                                      ; ## These will be transferred back to back
set ad_project_params(SRC_TRANSFERS_LENGTH) 512       ; ## Transfer length
set ad_project_params(SRC_TRANSFERS_DELAY) 10000      ; ## Delay in ns before the next batch is queued
set ad_project_params(SRC_TRANSFERS_DELAYED_COUNT) 1  ; ## Count of transfers queued in second batch

set ad_project_params(DST_READY_MODE) XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE
set ad_project_params(DST_READY_HIGH) 1
set ad_project_params(DST_READY_LOW) 3

set ad_project_params(TIME_TO_WAIT) 40000             ; ## Delay after queuing the second batch
                                                      ; ## before exiting the simulation

set ad_project_params(OFFLOAD_TRANSFER_LENGTH) 4096
