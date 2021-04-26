# Common setting, these can be overwritten in test specific config files

# all clocks, user can overwrite these values in the test configuration files (e.g. cfg1/tcl)

set src_clk_cfg [list \
  CONFIG.FREQ_HZ {250000000}
]

set dst_clk_cfg [list \
  CONFIG.FREQ_HZ {250000000}
]

set sys_clk_cfg [list \
  CONFIG.FREQ_HZ {100000000}
]

set ddr_clk_cfg [list \
  CONFIG.FREQ_HZ {200000000}
]

# axi lite management port
set mng_axi_vip_cfg [ list \
  CONFIG.ADDR_WIDTH {32} \
  CONFIG.ARUSER_WIDTH {0} \
  CONFIG.AWUSER_WIDTH {0} \
  CONFIG.BUSER_WIDTH {0} \
  CONFIG.DATA_WIDTH {32} \
  CONFIG.HAS_BRESP {1} \
  CONFIG.HAS_BURST {0} \
  CONFIG.HAS_CACHE {0} \
  CONFIG.HAS_LOCK {0} \
  CONFIG.HAS_PROT {1} \
  CONFIG.HAS_QOS {0} \
  CONFIG.HAS_REGION {0} \
  CONFIG.HAS_RRESP {1} \
  CONFIG.HAS_WSTRB {1} \
  CONFIG.ID_WIDTH {0} \
  CONFIG.INTERFACE_MODE {MASTER} \
  CONFIG.PROTOCOL {AXI4LITE} \
  CONFIG.READ_WRITE_MODE {READ_WRITE} \
  CONFIG.RUSER_BITS_PER_BYTE {0} \
  CONFIG.RUSER_WIDTH {0} \
  CONFIG.SUPPORTS_NARROW {0} \
  CONFIG.WUSER_BITS_PER_BYTE {0} \
  CONFIG.WUSER_WIDTH {0} \
]

# Device side VIPs

set dst_s_axis_vip_cfg [ list \
  CONFIG.INTERFACE_MODE {SLAVE} \
]

set src_pt_axis_vip_cfg [ list \
  CONFIG.INTERFACE_MODE {PASS_THROUGH} \
]

set src_m_axis_vip_cfg [list \
  CONFIG.INTERFACE_MODE {MASTER} \
  CONFIG.HAS_TREADY {1} \
  CONFIG.HAS_TLAST {0} \
]

set dst_pt_axis_vip_cfg [list \
  CONFIG.INTERFACE_MODE {PASS_THROUGH} \
  CONFIG.HAS_TREADY {1} \
  CONFIG.HAS_TLAST {0} \
]

