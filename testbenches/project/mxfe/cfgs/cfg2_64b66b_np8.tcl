global ad_project_params

set ad_project_params(JESD_MODE) 64B66B
set ad_project_params(RX_LANE_RATE) 16.5
set ad_project_params(RX_PLL_SEL) 2
set ad_project_params(TX_LANE_RATE) 16.5
set ad_project_params(TX_PLL_SEL) 2
set ad_project_params(REF_CLK_RATE) 500

set ad_project_params(RX_NUM_LINKS) 1
set ad_project_params(RX_JESD_M) 2
set ad_project_params(RX_JESD_L) 8
set ad_project_params(RX_JESD_S) 4
set ad_project_params(RX_JESD_NP) 8
set ad_project_params(RX_JESD_F) 1
set ad_project_params(RX_JESD_K) 256

set ad_project_params(TX_NUM_LINKS) 1
set ad_project_params(TX_JESD_M) 2
set ad_project_params(TX_JESD_L) 8
set ad_project_params(TX_JESD_S) 4
set ad_project_params(TX_JESD_NP) 8
set ad_project_params(TX_JESD_F) 1
set ad_project_params(TX_JESD_K) 256

set ad_project_params(TDD_SUPPORT) 0

set xilinx_boards {"zc706" "zcu102" "zed" "kcu105" "vck190" "vcu118" "vpk180"}
set chosen_board [lindex $xilinx_boards [expr {int(rand() * [llength $xilinx_boards])}]]
set ad_project_params(FPGA_BOARD) $chosen_board
