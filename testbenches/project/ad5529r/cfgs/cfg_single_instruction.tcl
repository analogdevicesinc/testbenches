####################################################################################
# cfg2.tcl - AD5529R Single-Instruction Mode Configuration
#
# Tests single 32-bit transfers (16-bit instruction + 16-bit data)
# Used for register read/write verification
####################################################################################

global ad_project_params

# Test parameters
# Single instruction mode: 16-bit transfers (matches HDL data_width=16)
# The AD5529R uses 16-bit SPI frames
set ad_project_params(DATA_DLENGTH)         16
set ad_project_params(THREE_WIRE)           0
set ad_project_params(CPOL)                 0
set ad_project_params(CPHA)                 1
set ad_project_params(SDO_IDLE_STATE)       0
set ad_project_params(SLAVE_TIN)            0
set ad_project_params(SLAVE_TOUT)           0
set ad_project_params(CS_TO_MISO)           0
set ad_project_params(CLOCK_DIVIDER)        1
# Single instruction mode: 1 word per transfer, 16 transfers (one per channel)
set ad_project_params(NUM_OF_WORDS)         1
set ad_project_params(NUM_OF_TRANSFERS)     16
set ad_project_params(CS_ACTIVE_HIGH)       0
set ad_project_params(PWM_PERIOD)           98
set ad_project_params(TEST_DATA_MODE)       DATA_MODE_RAMP

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
