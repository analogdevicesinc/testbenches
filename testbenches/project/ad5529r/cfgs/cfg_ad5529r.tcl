####################################################################################
# cfg_ad5529r.tcl - AD5529R common HDL / SPI-VIP configuration
#
# Holds only the real compile-time / SPI-VIP settings shared by every test.
# The TB-only parameters NUM_OF_WORDS / NUM_OF_TRANSFERS / PWM_PERIOD are NOT set
# here — each test program (tests/test_*.sv) `defines them and includes the
# shared flow (tests/ad5529r_test_flow.svh).
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
set ad_project_params(CS_ACTIVE_HIGH)       0

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
