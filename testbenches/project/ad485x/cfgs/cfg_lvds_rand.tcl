global ad_project_params

set devices {"AD4851" "AD4852" "AD4853" "AD4854" "AD4855" "AD4856" "AD4857" "AD4858"}
set chosen_device [lindex $devices [expr {int(rand() * [llength $devices])}]]

set ad_project_params(DEVICE) $chosen_device
set ad_project_params(LVDS_CMOS_N) 1
