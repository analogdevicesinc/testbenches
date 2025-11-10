global ad_project_params

set ad_project_params(NUM_OF_CHANNEL) 1
set ad_project_params(CLK_MODE) 0
set ad_project_params(CAPTURE_ZONE) 1
set ad_project_params(NUM_OF_SDI) 4
set ad_project_params(DDR_EN) 0
set ad_project_params(NO_REORDER) 0

if {$ad_project_params(NUM_OF_CHANNEL) == 2 && $ad_project_params(NUM_OF_SDI) == 1 && $ad_project_params(NO_REORDER) == 0} {
  set ad_project_params(NUM_OF_SDI_TB)    1
} else {
  set ad_project_params(NUM_OF_SDI_TB)    [expr {$ad_project_params(NUM_OF_SDI) * $ad_project_params(NUM_OF_CHANNEL)}]
}
