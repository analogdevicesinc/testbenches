global ad_project_params

#1 lane for both channels
set ad_project_params(NUM_OF_CHANNEL) 2
set ad_project_params(CLK_MODE) 0
set ad_project_params(CAPTURE_ZONE) 1
set ad_project_params(LANES_PER_CHANNEL) 4
set ad_project_params(DDR_EN) 0
set ad_project_params(INTERLEAVE_MODE) 0

if {$ad_project_params(INTERLEAVE_MODE) == 1} {
  set ad_project_params(NUM_OF_SDI_TB)      1
  # REORDER is mandatory in interleaved mode
  set ad_project_params(NO_REORDER)      0
} else {
  set ad_project_params(NUM_OF_SDI_TB)      [expr {$ad_project_params(NUM_OF_CHANNEL) * $ad_project_params(LANES_PER_CHANNEL)}]
  if {$ad_project_params(NUM_OF_SDI_TB) > 2} {
    # REORDER is mandatory when more than 2 lanes are used
    set ad_project_params(NO_REORDER)      0
  } else {
    set ad_project_params(NO_REORDER)      1
  }
}
