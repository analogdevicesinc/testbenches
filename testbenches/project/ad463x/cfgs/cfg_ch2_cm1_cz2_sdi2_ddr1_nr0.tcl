global ad_project_params

# AD463x project parameters
#1 lane for both channels
set ad_project_params(NUM_OF_CHANNEL) 2
set ad_project_params(CLK_MODE) 1
set ad_project_params(CAPTURE_ZONE) 2
set ad_project_params(LANES_PER_CHANNEL) 2
set ad_project_params(DDR_EN) 1
set ad_project_params(INTERLEAVE_MODE) 0

if {$ad_project_params(INTERLEAVE_MODE) == 1} {
  set ad_project_params(NUM_OF_SDI)      1
  # REORDER is mandatory in interleaved mode
  set ad_project_params(NO_REORDER)      0
} else {
  set ad_project_params(NUM_OF_SDI)      [expr {$ad_project_params(NUM_OF_CHANNEL) * $ad_project_params(LANES_PER_CHANNEL)}]
  if {$ad_project_params(NUM_OF_SDI) > 2} {
    # REORDER is mandatory when more than 2 lanes are used
    set ad_project_params(NO_REORDER)      0
  } else {
    set ad_project_params(NO_REORDER)      1
  }
}

# SPI Engine parameters for spi_engine_instr_pkg
set ad_project_params(DATA_WIDTH)       32
set ad_project_params(DATA_DLENGTH)     32
set ad_project_params(NUM_OF_WORDS)     1
set ad_project_params(NUM_OF_TRANSFERS) 10
set ad_project_params(THREE_WIRE)       0
set ad_project_params(CPOL)             0
set ad_project_params(CPHA)             0
set ad_project_params(SDO_IDLE_STATE)   0
set ad_project_params(CLOCK_DIVIDER)    0
set ad_project_params(CS_ACTIVE_HIGH)   0
set ad_project_params(ECHO_SCLK)        1
