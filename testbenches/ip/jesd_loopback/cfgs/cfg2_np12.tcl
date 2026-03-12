source [file dirname [file normalize [info script]]]/common.tcl

set xilinx_boards {
    "zc706"
    "zcu102"
    "kv260"
    "k26"
    "vcu118"
    "vcu128"
}
set chosen_board [lindex $xilinx_boards [expr {int(rand() * [llength $xilinx_boards])}]]
set ad_project_params(FPGA_BOARD) $chosen_board

set ad_project_params(LINK_MODE) $JESD_8B10B

set ad_project_params(JESD_M) 4
set ad_project_params(JESD_L) 2
set ad_project_params(JESD_F) 3
set ad_project_params(JESD_K) 32
set ad_project_params(JESD_S) 1
set ad_project_params(JESD_NP) 12

set ad_project_params(REF_CLK_RATE) 250
set ad_project_params(LANE_RATE) 10
