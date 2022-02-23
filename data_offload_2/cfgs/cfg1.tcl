# TX / oneshot / oscillating ready
global ad_project_params

set ad_project_params(DATA_PATH_WIDTH) 16             ; ## 16 bytes

set ad_project_params(MEM_TYPE) 0                     ; ## Internal storage (BRAM)
set ad_project_params(PATH_TYPE) 1                    ; ## TX
set ad_project_params(OFFLOAD_SIZE) 1024              ; ## 1 KiB
set ad_project_params(OFFLOAD_SRC_DWIDTH) 128         ; ## Source data width
set ad_project_params(OFFLOAD_DST_DWIDTH) 128         ; ## Destination data width
set ad_project_params(OFFLOAD_ONESHOT) 1              ; ## Enable oneshot mode

set ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH) 512   ; ## PLDDR's AXI4 interface data width
set ad_project_params(PLDDR_OFFLOAD_ADDRESS_WIDTH) 28 ; ## PLDDR's AXI4 interface address width

set ad_project_params(SRC_CLOCK_FREQ) 250000000       ; ## Source clock frequency in Hz
set ad_project_params(DST_CLOCK_FREQ) 300000000       ; ## Destination clock frequency in Hz

set ad_project_params(SRC_TRANSFERS_INITIAL_COUNT) 20 ; ## Count of transfers initially queued up.
                                                      ; ## These will be transferred back to back
set ad_project_params(SRC_TRANSFERS_LENGTH) 512       ; ## Transfer length
set ad_project_params(SRC_TRANSFERS_DELAY) 20000      ; ## Delay in ns before the next batch is queued
set ad_project_params(SRC_TRANSFERS_DELAYED_COUNT) 1  ; ## Count of transfers queued in second batch

set ad_project_params(DST_READY_MODE) XIL_AXI4STREAM_READY_GEN_OSC
set ad_project_params(DST_READY_HIGH) 1
set ad_project_params(DST_READY_LOW) 3

set ad_project_params(TIME_TO_WAIT) 10000             ; ## Delay after queuing the second batch
                                                      ; ## before exiting the simulation
