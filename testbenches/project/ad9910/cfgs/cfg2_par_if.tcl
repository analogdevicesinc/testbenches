global ad_project_params

# AD9910 Parallel Interface mode configuration
set ad_project_params(MODE) PAR_IF

# Target board. Without this adi_resolve_fpga_target picks a board at random,
# so the build depends on which device families the local Vivado install has.
# "zed" decodes to xc7z020clg484-1, matching system_project.tcl.
set ad_project_params(FPGA_BOARD) "zed"

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
