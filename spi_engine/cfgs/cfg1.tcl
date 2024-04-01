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
set ad_project_params(DATA_DLENGTH)         18
set ad_project_params(THREE_WIRE)           0
set ad_project_params(CPOL)                 0
set ad_project_params(CPHA)                 1
set ad_project_params(SDI_PHY_DELAY)        18
set ad_project_params(CLOCK_DIVIDER)        2
set ad_project_params(NUM_OF_WORDS)         1
set ad_project_params(NUM_OF_TRANSFERS)     4