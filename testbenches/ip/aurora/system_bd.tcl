global ad_project_params

# Ref clk
ad_ip_instance clk_vip ref_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 300000000 \
]
adi_sim_add_define "REF_CLK=ref_clk_vip"

# Controller clk
ad_ip_instance clk_vip controller_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 100000000 \
]
adi_sim_add_define "CONTROLLER_CLK=controller_clk_vip"

# Node clk
ad_ip_instance clk_vip node_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 100000000 \
]
adi_sim_add_define "NODE_CLK=node_clk_vip"

# Bridge clk
ad_ip_instance clk_vip bridge_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 100000000 \
]
adi_sim_add_define "BRIDGE_CLK=bridge_clk_vip"

#
#  Block design under test
#

# set_property CONFIG.FREQ_HZ 100000000 [get_bd_ports controller_clk]
# set_property CONFIG.FREQ_HZ 100000000 [get_bd_ports node_clk]

source $ad_tb_dir/library/drivers/aurora/aurora_controller.tcl
create_aurora_controller aurora_controller
create_bd_cell -type container -reference aurora_controller i_aurora_controller

source $ad_tb_dir/library/drivers/aurora/aurora_node.tcl
create_aurora_node aurora_node
create_bd_cell -type container -reference aurora_node i_aurora_node

source $ad_tb_dir/library/drivers/aurora/aurora_bridge.tcl
create_aurora_bridge aurora_bridge
create_bd_cell -type container -reference aurora_bridge i_aurora_bridge

ad_connect $sys_cpu_resetn i_aurora_controller/controller_resetn
ad_connect controller_clk_vip/clk_out i_aurora_controller/controller_init_clk
ad_connect ref_clk_vip/clk_out i_aurora_controller/controller_ref_clk

ad_connect $sys_cpu_resetn i_aurora_node/node_resetn
ad_connect node_clk_vip/clk_out i_aurora_node/node_init_clk
ad_connect ref_clk_vip/clk_out i_aurora_node/node_ref_clk

ad_connect $sys_cpu_resetn i_aurora_bridge/bridge_resetn
ad_connect bridge_clk_vip/clk_out i_aurora_bridge/bridge_init_clk
ad_connect ref_clk_vip/clk_out i_aurora_bridge/bridge_ref_clk

ad_connect i_aurora_node/node_RX_rxp i_aurora_bridge/bridge_master_TX_txp
ad_connect i_aurora_node/node_RX_rxn i_aurora_bridge/bridge_master_TX_txn

ad_connect i_aurora_node/node_TX_txp i_aurora_bridge/bridge_master_RX_rxp
ad_connect i_aurora_node/node_TX_txn i_aurora_bridge/bridge_master_RX_rxn

ad_connect i_aurora_controller/controller_RX_rxp i_aurora_bridge/bridge_slave_TX_txp
ad_connect i_aurora_controller/controller_RX_rxn i_aurora_bridge/bridge_slave_TX_txn

ad_connect i_aurora_controller/controller_TX_txp i_aurora_bridge/bridge_slave_RX_rxp
ad_connect i_aurora_controller/controller_TX_txn i_aurora_bridge/bridge_slave_RX_rxn

set_property -dict [list CONFIG.NUM_MI {3}] [get_bd_cells axi_axi_interconnect]
# ad_cpu_interconnect 0x70000000 i_aurora_controller
ad_connect i_aurora_controller/s_axi_0 axi_axi_interconnect/M02_AXI
ad_connect sys_cpu_clk axi_axi_interconnect/M02_ACLK
ad_connect sys_cpu_resetn axi_axi_interconnect/M02_ARESETN

ad_ip_instance smartconnect axi_smartconnect
ad_ip_parameter axi_smartconnect CONFIG.NUM_SI 1
ad_ip_parameter axi_smartconnect CONFIG.NUM_MI 1
ad_ip_parameter axi_smartconnect CONFIG.NUM_CLKS 1

ad_connect $sys_cpu_clk axi_smartconnect/aclk
ad_connect $sys_cpu_resetn axi_smartconnect/aresetn
ad_connect i_aurora_node/m_axi_0 axi_smartconnect/S00_AXI

ad_ip_instance axi_gpio axi_gpio
ad_connect axi_smartconnect/aclk axi_gpio/s_axi_aclk
ad_connect axi_smartconnect/aresetn axi_gpio/s_axi_aresetn
ad_connect axi_smartconnect/M00_AXI axi_gpio/S_AXI

make_bd_intf_pins_external [get_bd_intf_pins axi_gpio/GPIO]

assign_bd_address

set_property offset 0x70000000 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_axi_chip2chip_Mem0}]
set_property range 256M [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_axi_chip2chip_Mem0}]

set AXI_GPIO 0x71000000
set_property offset $AXI_GPIO [get_bd_addr_segs {i_aurora_node/axi_chip2chip/MAXI/SEG_axi_gpio_Reg}]
adi_sim_add_define "AXI_GPIO_BA=[format "%d" ${AXI_GPIO}]"
