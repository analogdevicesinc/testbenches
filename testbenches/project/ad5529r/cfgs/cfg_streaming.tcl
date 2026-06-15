####################################################################################
# cfg1.tcl - AD5529R Streaming Mode Configuration
#
# Tests 16-channel streaming mode with 17-word frames
# (1 instruction word + 16 DAC data words)
####################################################################################

global ad_project_params

# Test parameters
# AD5529R uses 16-bit data width (instruction + data packed)
set ad_project_params(DATA_DLENGTH)         16
set ad_project_params(THREE_WIRE)           0
set ad_project_params(CPOL)                 0
set ad_project_params(CPHA)                 1
set ad_project_params(SDO_IDLE_STATE)       0
set ad_project_params(SLAVE_TIN)            0
set ad_project_params(SLAVE_TOUT)           0
set ad_project_params(CS_TO_MISO)           0
set ad_project_params(CLOCK_DIVIDER)        1
# Streaming mode: 17 words per frame (1 instruction + 16 DAC values)
set ad_project_params(NUM_OF_WORDS)         17
set ad_project_params(NUM_OF_TRANSFERS)     1
set ad_project_params(CS_ACTIVE_HIGH)       0
set ad_project_params(PWM_PERIOD)           98

# SPI VIP configuration
set spi_s_vip_cfg [ list \
    MODE            0                                   \
    CPOL            $ad_project_params(CPOL)            \
    CPHA            $ad_project_params(CPHA)            \
    INV_CS          $ad_project_params(CS_ACTIVE_HIGH)  \
    SLAVE_TIN       $ad_project_params(SLAVE_TIN)       \
    SLAVE_TOUT      $ad_project_params(SLAVE_TOUT)      \
    MASTER_TIN      0                                   \
    MASTER_TOUT     0                                   \
    CS_TO_MISO      $ad_project_params(CS_TO_MISO)      \
    DATA_DLENGTH    $ad_project_params(DATA_DLENGTH)    \
]
set ad_project_params(spi_s_vip_cfg) $spi_s_vip_cfg
