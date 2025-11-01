global ad_project_params

# SPI Engine DUT parameters
set ad_project_params(CLK_MODE)             0
set ad_project_params(NUM_OF_SDIO)          2
set ad_project_params(NUM_OF_SDO)           1
set ad_project_params(CAPTURE_ZONE)         1
set ad_project_params(DDR_EN)               0
set ad_project_params(NO_REORDER)           0
set ad_project_params(DATA_WIDTH)           32
set ad_project_params(ASYNC_SPI_CLK)        1
set ad_project_params(NUM_OF_CS)            1

# default values for the SPI ENGINE DUT parameters
# set ad_project_params(CMD_MEM_ADDR_WIDTH)   4
# set ad_project_params(SDO_DATA_MEM_ADDR_WIDTH)  4
# set ad_project_params(SDI_FIFO_ADDR_WIDTH)  5
# set ad_project_params(SDO_FIFO_ADDR_WIDTH)  5
# set ad_project_params(SYNC_FIFO_ADDR_WIDTH) 4
# set ad_project_params(CMD_FIFO_ADDR_WIDTH)  4
# set ad_project_params(SDO_STREAMING)        0

# Delay parameters in ns (VIO = 1.8V, VADJ = 2.5V)
set U9                                      5.6
set U10                                     5.1
set U11                                     4.5
set LENGTH                                  32
set SKEW                                    1
set SPI_MODE_TDSDO                          5.6
set SPI_MODE_TCSEN                          6.8
set ECHO_CLK_SDR_TCSSCK                     9.8
set ECHO_CLK_SDR_TDSDO                      5.6
set ECHO_CLK_DDR_TCSSCK                     12.3
set ECHO_CLK_DDR_TDSDO                      6.2
set SPI_MODE_ECHO_SCK                       [expr { $U9 + $U11}]
set ECHO_CLK_SDR_SCK                        [expr { $U9 + $ECHO_CLK_SDR_TDSDO + $U11}]
set ECHO_CLK_DDR_SCK                        [expr { $U9 + $ECHO_CLK_DDR_TDSDO + $U11}]
set SPI_MODE_CS_TO_MISO_DELAY               [expr { $SPI_MODE_TCSEN + $U9}]
set ECHO_CLK_SDR_CS_TO_MISO_DELAY           [expr { $ECHO_CLK_SDR_TCSSCK + $ECHO_CLK_SDR_TDSDO + $U9}]
set ECHO_CLK_DDR_CS_TO_MISO_DELAY           [expr { $ECHO_CLK_DDR_TCSSCK + $ECHO_CLK_DDR_TDSDO + $U9}]
set SPI_MODE_SLAVE_TOUT                     [expr { $SPI_MODE_TDSDO + $U10}]
set ECHO_CLK_SDR_SLAVE_TOUT                 [expr { $ECHO_CLK_SDR_TDSDO + $U10}]
set ECHO_CLK_DDR_SLAVE_TOUT                 [expr { $ECHO_CLK_DDR_TDSDO + $U10}]

# Test parameters
set ad_project_params(NUM_OF_SDI)           $ad_project_params(NUM_OF_SDIO)
set ad_project_params(DATA_DLENGTH_SDR)     [expr {$ad_project_params(NUM_OF_SDIO) > 1 ? $LENGTH / ($ad_project_params(NUM_OF_SDIO)/2) : $LENGTH}]
set ad_project_params(DATA_DLENGTH_DDR)     [expr $ad_project_params(DATA_DLENGTH_SDR)/2]
set ad_project_params(DATA_DLENGTH)         $ad_project_params(DATA_DLENGTH_SDR)
set ad_project_params(THREE_WIRE)           0
set ad_project_params(CPOL)                 0
set ad_project_params(CPHA)                 1
set ad_project_params(SDO_IDLE_STATE)       0
set ad_project_params(SLAVE_TIN)            0
set ad_project_params(SLAVE_TOUT)           [expr {$ad_project_params(CLK_MODE) ? ($ad_project_params(DDR_EN) ? $ECHO_CLK_DDR_SCK - $SKEW : $ECHO_CLK_SDR_SCK - $SKEW) : $SPI_MODE_SLAVE_TOUT}]
set ad_project_params(MASTER_TIN)           0
set ad_project_params(MASTER_TOUT)          0
set ad_project_params(CS_TO_MISO)           [expr {$ad_project_params(CLK_MODE) ? ($ad_project_params(DDR_EN) ? $ECHO_CLK_DDR_CS_TO_MISO_DELAY : $ECHO_CLK_SDR_CS_TO_MISO_DELAY) : $SPI_MODE_CS_TO_MISO_DELAY}]
set ad_project_params(CLOCK_DIVIDER)        0
set ad_project_params(NUM_OF_WORDS)         1
set ad_project_params(NUM_OF_TRANSFERS)     10
set ad_project_params(SDI_LANE_MASK)        'h3
set ad_project_params(SDO_LANE_MASK)        'h1
set ad_project_params(CS_ACTIVE_HIGH)       0
set ad_project_params(ECHO_SCLK_DELAY)      [expr {$ad_project_params(CLK_MODE) ? ($ad_project_params(DDR_EN) ? $ECHO_CLK_DDR_SCK : $ECHO_CLK_SDR_SCK) : $SPI_MODE_ECHO_SCK}]

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
    NUM_OF_SDI       $ad_project_params(NUM_OF_SDI)       \
    NUM_OF_SDO       $ad_project_params(NUM_OF_SDO)       \
    SDI_LANE_MASK    $ad_project_params(SDI_LANE_MASK)    \
    SDO_LANE_MASK    $ad_project_params(SDO_LANE_MASK)    \
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
