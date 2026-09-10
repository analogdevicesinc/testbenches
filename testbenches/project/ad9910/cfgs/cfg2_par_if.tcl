global ad_project_params

# AD9910 Parallel Interface mode configuration
set ad_project_params(MODE) PAR_IF

# TX DMA: reads from DDR (AXI MM) → outputs AXI-Stream to axi_ad9910
set tx_dma_cfg [list \
  DMA_TYPE_SRC 0 \
  DMA_TYPE_DEST 1 \
  ID 0 \
  AXI_SLICE_SRC 1 \
  AXI_SLICE_DEST 1 \
  SYNC_TRANSFER_START 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  CYCLIC 0 \
  DMA_DATA_WIDTH_SRC 32 \
  DMA_DATA_WIDTH_DEST 16 \
]
set ad_project_params(tx_dma_cfg) $tx_dma_cfg
