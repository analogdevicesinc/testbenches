# Common setting, these can be overwritten in test specific config files

# all clocks, user can overwrite these values in the test configuration files (e.g. cfg1/tcl)

set sys_clk_cfg [list \
  CONFIG.FREQ_HZ {100000000}
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
