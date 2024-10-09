global ad_project_params

# SPI Engine DUT parameters
set ad_project_params(DATA_WIDTH)           32
set ad_project_params(ASYNC_SPI_CLK)        1
set ad_project_params(NUM_OF_CS)            1
set ad_project_params(NUM_OF_SDI)           1
set ad_project_params(NUM_OF_SDO)           1
set ad_project_params(SDI_DELAY)            1
set ad_project_params(ECHO_SCLK)            0
set ad_project_params(CMD_MEM_ADDR_WIDTH)   4
set ad_project_params(DATA_MEM_ADDR_WIDTH)  4
set ad_project_params(SDI_FIFO_ADDR_WIDTH)  5
set ad_project_params(SDO_FIFO_ADDR_WIDTH)  5
set ad_project_params(SYNC_FIFO_ADDR_WIDTH) 4
set ad_project_params(CMD_FIFO_ADDR_WIDTH)  4

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
set ad_project_params(CS_ACTIVE_HIGH)       0
set ad_project_params(ECHO_SCLK_DELAY)      0.1
set ad_project_params(PWM_PERIOD)           98
set ad_project_params(TEST_DATA_MODE)       DATA_MODE_PATTERN;

set spi_s_vip_cfg [ list \
    MODE            0                                   \
    CPOL            $ad_project_params(CPOL)            \
    CPHA            $ad_project_params(CPHA)            \
    INV_CS          $ad_project_params(CS_ACTIVE_HIGH)  \
    SLAVE_TIN       $ad_project_params(SLAVE_TIN)       \
    SLAVE_TOUT      $ad_project_params(SLAVE_TOUT)      \
    MASTER_TIN      $ad_project_params(MASTER_TIN)      \
    MASTER_TOUT     $ad_project_params(MASTER_TOUT)     \
    CS_TO_MISO      $ad_project_params(CS_TO_MISO)      \
    DATA_DLENGTH    $ad_project_params(DATA_DLENGTH)    \
]
set ad_project_params(spi_s_vip_cfg) $spi_s_vip_cfg
