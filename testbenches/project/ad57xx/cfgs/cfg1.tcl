global ad_project_params

# DUT parameters
set ad_project_params(DATA_WIDTH)           32
set ad_project_params(NUM_OF_MISO)          1
set ad_project_params(NUM_OF_SDIO)          $ad_project_params(NUM_OF_MISO)
set ad_project_params(NUM_OF_MOSI)          1

# Test parameters
set ad_project_params(DATA_DLENGTH)         24
set ad_project_params(THREE_WIRE)           0
set ad_project_params(CPOL)                 0
set ad_project_params(CPHA)                 1
set ad_project_params(SDO_IDLE_STATE)       0
set ad_project_params(SLAVE_TIN)            0
set ad_project_params(SLAVE_TOUT)           0
set ad_project_params(MASTER_TIN)           0
set ad_project_params(MASTER_TOUT)          0
set ad_project_params(CS_TO_MISO)           0
set ad_project_params(CLOCK_DIVIDER)        1
set ad_project_params(NUM_OF_WORDS)         1
set ad_project_params(NUM_OF_TRANSFERS)     3
set ad_project_params(MISO_LANE_MASK)       'h01
set ad_project_params(MOSI_LANE_MASK)       'h01
set ad_project_params(CS_ACTIVE_HIGH)       0
set ad_project_params(PWM_PERIOD)           98
set ad_project_params(TEST_DATA_MODE)       DATA_MODE_PATTERN;

set spi_s_vip_cfg [ list \
    MODE             0                                    \
    CPOL             $ad_project_params(CPOL)             \
    CPHA             $ad_project_params(CPHA)             \
    INV_CS           $ad_project_params(CS_ACTIVE_HIGH)   \
    SLAVE_TIN        $ad_project_params(SLAVE_TIN)        \
    SLAVE_TOUT       $ad_project_params(SLAVE_TOUT)       \
    MASTER_TIN       $ad_project_params(MASTER_TIN)       \
    MASTER_TOUT      $ad_project_params(MASTER_TOUT)      \
    CS_TO_MISO       $ad_project_params(CS_TO_MISO)       \
    DATA_DLENGTH     $ad_project_params(DATA_DLENGTH)     \
    NUM_OF_MISO      $ad_project_params(NUM_OF_MISO)      \
    NUM_OF_MOSI      $ad_project_params(NUM_OF_MOSI)      \
    MISO_LANE_MASK   $ad_project_params(MISO_LANE_MASK)   \
    MOSI_LANE_MASK   $ad_project_params(MOSI_LANE_MASK)   \
]
set ad_project_params(spi_s_vip_cfg) $spi_s_vip_cfg

set ad_project_params(FPGA_BOARD) "coraz7s"
