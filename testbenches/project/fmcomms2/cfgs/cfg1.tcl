global ad_project_params

# Put project configs here
# e.g.
# set ad_project_params(CMOS_LVDS_N) 1

set xilinx_boards {"zc706" "zc702" "zcu102" "zed" "kcu105"}
set chosen_board [lindex $xilinx_boards [expr {int(rand() * [llength $xilinx_boards])}]]
set ad_project_params(FPGA_BOARD) $chosen_board
