global ad_project_params

# AD9910 DRG (Digital Ramp Generator) mode configuration
set ad_project_params(MODE) DRG

# Target board. Without this adi_resolve_fpga_target picks a board at random,
# so the build depends on which device families the local Vivado install has.
# "zed" decodes to xc7z020clg484-1, matching system_project.tcl.
set ad_project_params(FPGA_BOARD) "zed"
