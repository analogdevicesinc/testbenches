####################################################################################
# cfg_stress.tcl - AD5529R Stress/Throughput Test
#
# Tests sustained streaming at maximum rate with random data.
# Validates:
#   - Back-to-back transfers (100 frames)
#   - Random data patterns (hardest to accidentally pass)
#   - Sustained throughput over extended duration
#   - No dropped samples under load
#
# Throughput math:
#   - 35 MHz SCLK, streaming mode: 17 words x 16 bits = 272 bits
#   - Frame time: 272 / 35 MHz = 7.77 us per frame
#   - 16 samples per frame -> 2.06 MSPS aggregate
#   - Per channel: ~128 kSPS theoretical max
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
set ad_project_params(NUM_OF_TRANSFERS)     100
set ad_project_params(CS_ACTIVE_HIGH)       0
# Aggressive trigger rate - offload queues them
set ad_project_params(PWM_PERIOD)           50

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
