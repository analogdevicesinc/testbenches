
#global mng_axi_cfg
global use_smartconnect
# axi lite management port
set mng_axi_cfg [ list \
   ADDR_WIDTH {32} \
   ARUSER_WIDTH {0} \
   AWUSER_WIDTH {0} \
   BUSER_WIDTH {0} \
   DATA_WIDTH {32} \
   HAS_BRESP {1} \
   HAS_BURST {0} \
   HAS_CACHE {0} \
   HAS_LOCK {0} \
   HAS_PROT {1} \
   HAS_QOS {0} \
   HAS_REGION {0} \
   HAS_RRESP {1} \
   HAS_WSTRB {1} \
   ID_WIDTH {0} \
   INTERFACE_MODE {MASTER} \
   PROTOCOL {AXI4LITE} \
   READ_WRITE_MODE {READ_WRITE} \
   RUSER_BITS_PER_BYTE {0} \
   RUSER_WIDTH {0} \
   SUPPORTS_NARROW {0} \
   WUSER_BITS_PER_BYTE {0} \
   WUSER_WIDTH {0} \
]

set ddr_axi_cfg [list \
 INTERFACE_MODE {SLAVE} \
 DATA_WIDTH {512} \
]

# Create instance: mng_axi , and set properties
# VIP for management port
ad_ip_instance axi_vip mng_axi_vip $mng_axi_cfg
adi_sim_add_define "MNG_AXI=mng_axi_vip"


# Create data storage DDR controller (AXI slave)
ad_ip_instance axi_vip ddr_axi_vip $ddr_axi_cfg
adi_sim_add_define "DDR_AXI=ddr_axi_vip"

# Interrupt controller
ad_ip_instance axi_intc axi_intc [list \
  C_IRQ_CONNECTION 1 \
  C_HAS_FAST 0 \
]

ad_ip_instance xlconcat sys_concat_intc
ad_ip_parameter sys_concat_intc CONFIG.NUM_PORTS 16

# ---------------------
# Clock gens
# ---------------------

# System clock
ad_ip_instance clk_vip sys_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 100000000 \
]
adi_sim_add_define "SYS_CLK=sys_clk_vip"


# DMA clock
ad_ip_instance clk_vip dma_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 200000000 \
]
adi_sim_add_define "DMA_CLK=dma_clk_vip"

# DDR clock
ad_ip_instance clk_vip ddr_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 400000000 \
]
adi_sim_add_define "DDR_CLK=ddr_clk_vip"

ad_connect sys_cpu_clk sys_clk_vip/clk_out
ad_connect sys_dma_clk dma_clk_vip/clk_out
ad_connect sys_mem_clk ddr_clk_vip/clk_out

# ---------------------
# Reset generators
# ---------------------
ad_ip_instance rst_vip sys_rst_vip [ list \
  INTERFACE_MODE {MASTER} \
  RST_POLARITY {ACTIVE_HIGH} \
]
adi_sim_add_define "SYS_RST=sys_rst_vip"

ad_ip_instance proc_sys_reset sys_rstgen
ad_ip_parameter sys_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_ip_instance proc_sys_reset sys_dma_rstgen
ad_ip_parameter sys_dma_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_ip_instance proc_sys_reset sys_mem_rstgen
ad_ip_parameter sys_mem_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_connect sys_rst_vip/rst_out sys_rstgen/ext_reset_in
ad_connect sys_rst_vip/rst_out sys_dma_rstgen/ext_reset_in
ad_connect sys_rst_vip/rst_out sys_mem_rstgen/ext_reset_in

ad_connect sys_cpu_clk sys_rstgen/slowest_sync_clk
ad_connect sys_dma_clk sys_dma_rstgen/slowest_sync_clk
ad_connect sys_mem_clk sys_mem_rstgen/slowest_sync_clk
ad_connect sys_cpu_reset sys_rstgen/peripheral_reset
ad_connect sys_cpu_resetn sys_rstgen/peripheral_aresetn
ad_connect sys_dma_reset sys_dma_rstgen/peripheral_reset
ad_connect sys_dma_resetn sys_dma_rstgen/peripheral_aresetn
ad_connect sys_mem_reset sys_mem_rstgen/peripheral_reset
ad_connect sys_mem_resetn sys_mem_rstgen/peripheral_aresetn

ad_connect sys_cpu_clk /mng_axi_vip/aclk
ad_connect sys_cpu_resetn /mng_axi_vip/aresetn
ad_connect sys_mem_resetn /ddr_axi_vip/aresetn

# Clock and reset interface to system_bd
set sys_mem_clk sys_mem_clk

set sys_cpu_clk sys_cpu_clk
set sys_cpu_reset sys_cpu_reset
set sys_cpu_resetn sys_cpu_resetn

set sys_dma_clk sys_dma_clk
set sys_dma_clk_source dma_clk_vip/clk_out
set sys_dma_reset sys_dma_reset
set sys_dma_resetn sys_dma_resetn

set sys_mem_clk sys_mem_clk
set sys_mem_reset sys_mem_reset
set sys_mem_resetn sys_mem_resetn

ad_connect axi_intc/intr sys_concat_intc/dout

# TODO : this should be a 500MHz clock
set sys_iodelay_clk sys_mem_clk

# defaults (interrupts)

ad_connect sys_concat_intc/In0    GND
ad_connect sys_concat_intc/In1    GND
ad_connect sys_concat_intc/In2    GND
ad_connect sys_concat_intc/In3    GND
ad_connect sys_concat_intc/In4    GND
ad_connect sys_concat_intc/In5    GND
ad_connect sys_concat_intc/In6    GND
ad_connect sys_concat_intc/In7    GND
ad_connect sys_concat_intc/In8    GND
ad_connect sys_concat_intc/In9    GND
ad_connect sys_concat_intc/In10   GND
ad_connect sys_concat_intc/In11   GND
ad_connect sys_concat_intc/In12   GND
ad_connect sys_concat_intc/In13   GND
ad_connect sys_concat_intc/In14   GND
ad_connect sys_concat_intc/In15   GND

# interconnect - processor

ad_cpu_interconnect 0x41200000 axi_intc

# interconnect - memory

ad_mem_hp0_interconnect sys_mem_clk ddr_axi_vip/S_AXI

# connect mng_vip to ddr_vip
set_property -dict [list CONFIG.NUM_MI {2}] [get_bd_cells axi_cpu_interconnect]
ad_connect axi_cpu_interconnect/M01_AXI /axi_mem_interconnect/S00_AXI

global sys_mem_clk_index
if { $use_smartconnect == 1} {
  incr sys_mem_clk_index
  set_property CONFIG.NUM_CLKS [expr $sys_mem_clk_index +1] [get_bd_cells axi_mem_interconnect]
  ad_connect sys_cpu_clk axi_mem_interconnect/ACLK$sys_mem_clk_index
} else {
  ad_connect sys_cpu_clk axi_cpu_interconnect/M01_ACLK
  ad_connect sys_cpu_clk axi_mem_interconnect/S00_ACLK
  ad_connect sys_cpu_resetn axi_cpu_interconnect/M01_ARESETN
  ad_connect sys_cpu_resetn axi_mem_interconnect/S00_ARESETN
}

#fake an ad_cpu_interconnect
global sys_cpu_interconnect_index
incr sys_cpu_interconnect_index
#fake an ad_mem_hpx_interconnect
global sys_mem_interconnect_index
incr sys_mem_interconnect_index

# create external port for IRQ
create_bd_port -dir O -type intr irq

ad_connect irq axi_intc/irq

# Set DDR VIP to a range of 2G
set DDR_BASE 0x80000000
create_bd_addr_seg -range ${DDR_BASE} -offset ${DDR_BASE} [get_bd_addr_spaces /mng_axi_vip/Master_AXI] \
  [get_bd_addr_segs ddr_axi_vip/S_AXI/Reg] SEG_mng_ddr_cntlr
adi_sim_add_define "DDR_BA=[format "%d" ${DDR_BASE}]"
