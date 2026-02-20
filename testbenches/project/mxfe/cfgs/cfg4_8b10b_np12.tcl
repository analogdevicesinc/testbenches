global ad_project_params

set ad_project_params(JESD_MODE) 8B10B
set ad_project_params(RX_LANE_RATE) 10
set ad_project_params(RX_PLL_SEL) 2
set ad_project_params(TX_LANE_RATE) 10
set ad_project_params(TX_PLL_SEL) 2
set ad_project_params(REF_CLK_RATE) 500 ;# [R/T]X_RATE/20

set ad_project_params(RX_NUM_LINKS) 1
set ad_project_params(RX_JESD_M) 8
set ad_project_params(RX_JESD_L) 2
set ad_project_params(RX_JESD_S) 1
set ad_project_params(RX_JESD_NP) 12
set ad_project_params(RX_JESD_F) 6
set ad_project_params(RX_JESD_K) 32

set ad_project_params(TX_NUM_LINKS) 1
set ad_project_params(TX_JESD_M) 8
set ad_project_params(TX_JESD_L) 2
set ad_project_params(TX_JESD_S) 1
set ad_project_params(TX_JESD_NP) 12
set ad_project_params(TX_JESD_F) 6
set ad_project_params(TX_JESD_K) 32

set ad_project_params(TDD_SUPPORT) 0

set xilinx_boards {"zc706" "zcu102" "zed" "kcu105" "vck190" "vcu118" "vpk180"}
set chosen_board [lindex $xilinx_boards [expr {int(rand() * [llength $xilinx_boards])}]]
set ad_project_params(FPGA_BOARD) $chosen_board
