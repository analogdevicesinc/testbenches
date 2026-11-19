###############################################################################
## Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# Platform Designer counterpart of test_harness_system_bd.tcl. It provides the
# clocks, resets and procedures the hdl Intel *_qsys.tcl scripts expect from a
# carrier, with Intel BFMs in place of the HPS.

global ad_project_params

source $ad_hdl_dir/projects/scripts/adi_board_intel.tcl

ad_ip_instance altera_avalon_clock_source sys_clk_vip [list \
  CLOCK_RATE 100 \
  CLOCK_UNIT 1000000 \
]
adi_sim_add_define "SYS_CLK=sys_clk_vip"

ad_ip_instance altera_avalon_clock_source dma_clk_vip [list \
  CLOCK_RATE 250 \
  CLOCK_UNIT 1000000 \
]
adi_sim_add_define "DMA_CLK=dma_clk_vip"

ad_ip_instance altera_avalon_reset_source sys_rst_vip [list \
  ASSERT_HIGH_RESET 1 \
  INITIAL_RESET_CYCLES 0 \
]
adi_sim_add_define "SYS_RST=sys_rst_vip"

ad_connect sys_clk_vip.clk sys_rst_vip.clk

ad_ip_instance clock_source sys_clk [list \
  clockFrequency 100000000.0 \
  clockFrequencyKnown 1 \
  resetSynchronousEdges DEASSERT \
]
ad_connect sys_clk_vip.clk sys_clk.clk_in
ad_connect sys_rst_vip.reset sys_clk.clk_in_reset

ad_ip_instance clock_source sys_dma_clk [list \
  clockFrequency 250000000.0 \
  clockFrequencyKnown 1 \
  resetSynchronousEdges DEASSERT \
]
ad_connect dma_clk_vip.clk sys_dma_clk.clk_in
ad_connect sys_clk.clk_reset sys_dma_clk.clk_in_reset

# The ADI interfaces bound to the BFMs expect byte addresses
ad_ip_instance altera_avalon_mm_master_bfm mng_avmm_vip [list \
  AV_ADDRESS_W 32 \
  AV_SYMBOL_W 8 \
  AV_NUMSYMBOLS 4 \
  ADDRESS_UNITS SYMBOLS \
  USE_BURSTCOUNT 0 \
  AV_MAX_PENDING_READS 1 \
]
adi_sim_add_define "MNG_AVMM=mng_avmm_vip"

ad_connect sys_clk.clk mng_avmm_vip.clk
ad_connect sys_clk.clk_reset mng_avmm_vip.clk_reset

ad_ip_instance altera_avalon_mm_slave_bfm ddr_avmm_vip [list \
  AV_ADDRESS_W 32 \
  AV_SYMBOL_W 8 \
  AV_NUMSYMBOLS 64 \
  ADDRESS_UNITS SYMBOLS \
  USE_BURSTCOUNT 1 \
  AV_BURSTCOUNT_W 8 \
  AV_BURST_LINEWRAP 0 \
  AV_BURST_BNDR_ONLY 0 \
  AV_MAX_PENDING_READS 16 \
  AV_FIX_READ_LATENCY 0 \
]
adi_sim_add_define "DDR_AVMM=ddr_avmm_vip"

ad_connect sys_dma_clk.clk ddr_avmm_vip.clk
ad_connect sys_dma_clk.clk_reset ddr_avmm_vip.clk_reset

ad_ip_instance altera_avalon_interrupt_sink sys_irq_vip [list \
  AV_IRQ_W 32 \
]
adi_sim_add_define "IRQ=sys_irq_vip"

ad_connect sys_clk.clk sys_irq_vip.clock_reset
ad_connect sys_clk.clk_reset sys_irq_vip.clock_reset_reset

# The slave BFM receives the address relative to its base, a backdoor access
# is only at the DMA address when the DDR is mapped at 0
set DDR_BASE 0x00000000
adi_sim_add_define "DDR_BA=[format "%d" ${DDR_BASE}]"

proc ad_cpu_interconnect {m_base m_port {avl_bridge ""} {avl_bridge_base 0x00000000} {avl_address_width 18}} {
  if {[string equal ${avl_bridge} ""]} {
    add_connection mng_avmm_vip.m0 ${m_port}
    set_connection_parameter_value mng_avmm_vip.m0/${m_port} baseAddress ${m_base}
  } else {
    if {[lsearch -exact [get_instances] ${avl_bridge}] == -1} {
      add_instance ${avl_bridge} altera_avalon_mm_bridge
      set_instance_parameter_value ${avl_bridge} {ADDRESS_WIDTH} $avl_address_width
      set_instance_parameter_value ${avl_bridge} {SYNC_RESET} {1}
      add_connection mng_avmm_vip.m0 ${avl_bridge}.s0
      set_connection_parameter_value mng_avmm_vip.m0/${avl_bridge}.s0 baseAddress ${avl_bridge_base}
      add_connection sys_clk.clk ${avl_bridge}.clk
      add_connection sys_clk.clk_reset ${avl_bridge}.reset
    }
    add_connection ${avl_bridge}.m0 ${m_port}
    set_connection_parameter_value ${avl_bridge}.m0/${m_port} baseAddress ${m_base}
  }
}

proc ad_dma_interconnect {m_port {m_addr 0x00000000} {data_width 128}} {
  global DDR_BASE

  add_connection ${m_port} ddr_avmm_vip.s0
  set_connection_parameter_value ${m_port}/ddr_avmm_vip.s0 baseAddress $DDR_BASE
}

proc ad_cpu_interrupt {m_irq m_port} {
  add_connection sys_irq_vip.irq ${m_port}
  set_connection_parameter_value sys_irq_vip.irq/${m_port} irqNumber ${m_irq}
}
