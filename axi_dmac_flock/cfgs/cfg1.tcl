set MAX_NUM_FRAMES 8
set AUTORUN 0
set USE_EXT_SYNC 0
set TDATA_NUM_BYTES 8

set ad_project_params(M_DMA_CFG_MAX_NUM_FRAMES) $MAX_NUM_FRAMES
set ad_project_params(M_DMA_CFG_AUTORUN) $AUTORUN
set ad_project_params(S_DMA_CFG_AUTORUN) $AUTORUN
set ad_project_params(M_DMA_CFG_USE_EXT_SYNC) $USE_EXT_SYNC
set ad_project_params(S_DMA_CFG_USE_EXT_SYNC) $USE_EXT_SYNC
set ad_project_params(SRC_AXIS_VIP_CFG_TDATA_NUM_BYTES) $TDATA_NUM_BYTES
set ad_project_params(DST_AXIS_VIP_CFG_TDATA_NUM_BYTES) $TDATA_NUM_BYTES

set m_dma_cfg [list \
   DMA_TYPE_SRC 1 \
   DMA_TYPE_DEST 0 \
   DMA_2D_TRANSFER 1 \
   CYCLIC 1 \
   FRAMELOCK 1 \
   MAX_NUM_FRAMES $MAX_NUM_FRAMES \
   USE_EXT_SYNC $USE_EXT_SYNC \
   DMA_2D_TLAST_MODE 1 \
]

set s_dma_cfg [list \
   DMA_TYPE_SRC 0 \
   DMA_TYPE_DEST 1 \
   DMA_2D_TRANSFER 1 \
   CYCLIC 1 \
   FRAMELOCK 1 \
   MAX_NUM_FRAMES $MAX_NUM_FRAMES \
   USE_EXT_SYNC $USE_EXT_SYNC \
   DMA_2D_TLAST_MODE 1 \
]

# VDMA config
set vdma_cfg [list \
 c_m_axis_mm2s_tdata_width {64} \
 c_num_fstores {3} \
 c_use_mm2s_fsync {0} \
 c_use_s2mm_fsync {0} \
 c_enable_vert_flip {0} \
 c_mm2s_genlock_mode {3} \
 c_s2mm_genlock_mode {2} \
 c_mm2s_linebuffer_depth {8192} \
 c_s2mm_linebuffer_depth {8192} \
]

# SRC AXIS
set src_axis_vip_cfg [list \
   INTERFACE_MODE {MASTER} \
   HAS_TLAST {1} \
   TDATA_NUM_BYTES $TDATA_NUM_BYTES \
  ]

# DST AXIS
set dst_axis_vip_cfg [list \
   INTERFACE_MODE {SLAVE} \
   HAS_TLAST {1} \
   TDATA_NUM_BYTES $TDATA_NUM_BYTES \
]
