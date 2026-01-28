global ad_project_params

set ad_project_params(CMOS_LVDS_N) 1
set ad_project_params(SDR_DDR_N) 1
set ad_project_params(SINGLE_LANE) 0
set ad_project_params(USE_RX_CLK_FOR_TX) 0
set ad_project_params(SYMB_OP) 0
set ad_project_params(SYMB_8_16B) 0
set ad_project_params(DDS_DISABLE) 0

set xilinx_boards {"zc706" "zcu102" "zed"}
set chosen_board [lindex $xilinx_boards [expr {int(rand() * [llength $xilinx_boards])}]]
set ad_project_params(FPGA_BOARD) $chosen_board
