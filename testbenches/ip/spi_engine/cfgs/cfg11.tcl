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
set ad_project_params(SDO_STREAMING)        0

# Test parameters
set ad_project_params(DATA_DLENGTH)         18
set ad_project_params(THREE_WIRE)           0
set ad_project_params(CPOL)                 1
set ad_project_params(CPHA)                 1
set ad_project_params(SDO_IDLE_STATE)       0
set ad_project_params(SLAVE_TIN)            0
set ad_project_params(SLAVE_TOUT)           0
set ad_project_params(MASTER_TIN)           0
set ad_project_params(MASTER_TOUT)          0
set ad_project_params(CS_TO_MISO)           0
set ad_project_params(CLOCK_DIVIDER)        2
set ad_project_params(NUM_OF_WORDS)         3
set ad_project_params(NUM_OF_TRANSFERS)     5
set ad_project_params(CS_ACTIVE_HIGH)       0
set ad_project_params(ECHO_SCLK_DELAY)      0.1

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

set axis_sdo_src_vip_cfg [ list \
    INTERFACE_MODE {MASTER} \
    HAS_TREADY 1 \
    HAS_TLAST 0 \
    TDATA_NUM_BYTES [expr  $ad_project_params(DATA_WIDTH)/8] \
    TDEST_WIDTH 0 \
    TID_WIDTH 0 \
]
set ad_project_params(axis_sdo_src_vip_cfg) $axis_sdo_src_vip_cfg
