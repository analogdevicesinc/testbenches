# TX / oneshot
global ad_project_params

set ad_project_params(TDD_SECONDARY)        1
set ad_project_params(TDD_GATED_DATAPATH)   1

set ad_project_params(TDD_FRAME_LENGTH)     2000
set ad_project_params(TDD_COUNTER_INIT)     0
set ad_project_params(TDD_BURST_COUNT)      5

# Sync master
set ad_project_params(TDD_TERMINAL_TYPE)    1
set ad_project_params(TDD_PRIMARY_PARAMS)   [list 10 90 110 190 20 80 120 180 20 80 120 180]
set ad_project_params(TDD_SECONDARY_PARAMS) [list 1010 1090 1110 1190 1020 1080 1120 1180 1020 1080 1120 1180]

set ad_project_params(SIM_WAIT)             200000
