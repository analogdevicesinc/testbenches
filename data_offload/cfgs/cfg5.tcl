
# Clocks
set adc_clk_cfg [list \
  CONFIG.FREQ_HZ {250000000}
]

set dac_clk_cfg [list \
  CONFIG.FREQ_HZ {250000000}
]

set sys_clk_cfg [list \
  CONFIG.FREQ_HZ {100000000}
]

set dma_clk_cfg [list \
  CONFIG.FREQ_HZ {100000000}
]

set ddr_clk_cfg [list \
  CONFIG.FREQ_HZ {200000000}
]

# DUT
set data_offload_cfg [ list \
   CONFIG.MEM_TYPE {1} \
   CONFIG.MEM_RX_SIZE {1024} \
   CONFIG.MEM_TX_SIZE {1024} \
   CONFIG.RX_ENABLE {1} \
   CONFIG.TX_ENABLE {1} \
   CONFIG.RX_FRONTEND_IF {0} \
   CONFIG.RX_BACKEND_IF {1} \
   CONFIG.RX_FRONTEND_DATA_WIDTH {128} \
   CONFIG.RX_BACKEND_DATA_WIDTH {64} \
   CONFIG.TX_FRONTEND_IF {0} \
   CONFIG.TX_BACKEND_IF {1} \
   CONFIG.TX_FRONTEND_DATA_WIDTH {128} \
   CONFIG.TX_BACKEND_DATA_WIDTH {64}
]

set adc_m_axis_vip_cfg [concat $adc_m_axis_vip_cfg [ list \
  CONFIG.TDATA_NUM_BYTES {8} \
  CONFIG.HAS_TLAST {0}
]]

set dma_s_axis_vip_cfg [concat $dma_s_axis_vip_cfg [ list \
  CONFIG.TDATA_NUM_BYTES {16} \
  CONFIG.HAS_TLAST {1}
]]

set dac_s_axis_vip_cfg [concat $dac_s_axis_vip_cfg [ list \
  CONFIG.TDATA_NUM_BYTES {8} \
  CONFIG.HAS_TLAST {0}
]]

set dma_m_axis_vip_cfg [concat $dma_m_axis_vip_cfg [ list \
  CONFIG.TDATA_NUM_BYTES {16} \
  CONFIG.HAS_TLAST {1}
]]
