global ad_project_params

set packet_format [expr int(2.0*rand())]      ; # 0-1
set crc_enable [expr int(2.0*rand())]         ; # 0-1
set os_enable [expr int(2.0*rand())]          ; # 0-1

set ad_project_params(DEVICE) AD4855
set ad_project_params(LVDS_CMOS_N) 0
set ad_project_params(PACKET_FORMAT) $packet_format
set ad_project_params(CRC_EN) $crc_enable
set ad_project_params(OS_EN) $os_enable
