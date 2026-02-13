global ad_project_params

set devices {"AD4851" "AD4852" "AD4853" "AD4854" "AD4855" "AD4856" "AD4857" "AD4858"}
set chosen_device [lindex $devices [expr {int(rand() * [llength $devices])}]]
set packet_format [expr int(4.0*rand())]    ; # 0-3
set crc_enable [expr int(2*rand())]         ; # 0-1
set os_enable [expr int(2*rand())]          ; # 0-1

set ad_project_params(DEVICE) $chosen_device
set ad_project_params(LVDS_CMOS_N) 1
set ad_project_params(PACKET_FORMAT) $packet_format
set ad_project_params(CRC_EN) $crc_enable
set ad_project_params(OS_EN) $os_enable
