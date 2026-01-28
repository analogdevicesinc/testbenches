global ad_project_params

set ad_project_params(CLK_MODE) 0
set ad_project_params(NUM_OF_SDI) 1
set ad_project_params(CAPTURE_ZONE) 1
set ad_project_params(DDR_EN) 0

set xilinx_boards {"zed" "coraz7s"}
set chosen_board [lindex $xilinx_boards [expr {int(rand() * [llength $xilinx_boards])}]]
set ad_project_params(FPGA_BOARD) $chosen_board
