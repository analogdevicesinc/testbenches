global ad_project_params

set rx_dma_cfg [list \
  DMA_TYPE_SRC 1 \
  DMA_TYPE_DEST 0 \
  ID 0 \
  AXI_SLICE_SRC 1 \
  AXI_SLICE_DEST 1 \
  SYNC_TRANSFER_START 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  MAX_BYTES_PER_BURST 4096 \
  CYCLIC 0 \
  DMA_DATA_WIDTH_SRC 32 \
  DMA_DATA_WIDTH_DEST 32 \
  ]

set ad_project_params(rx_dma_cfg) $rx_dma_cfg

set tx_dma_cfg [list \
  DMA_TYPE_SRC 0 \
  DMA_TYPE_DEST 1 \
  ID 0 \
  AXI_SLICE_SRC 1 \
  AXI_SLICE_DEST 1 \
  SYNC_TRANSFER_START 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  CYCLIC 1 \
  DMA_DATA_WIDTH_SRC 32 \
  DMA_DATA_WIDTH_DEST 32 \
  ]

set ad_project_params(tx_dma_cfg) $tx_dma_cfg