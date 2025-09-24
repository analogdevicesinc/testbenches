proc create_aurora_node { \
  {NAME aurora_node} \
} {

  set top_design [current_bd_design]

  create_bd_design $NAME

  ad_ip_instance axi_chip2chip axi_chip2chip
  ad_ip_parameter axi_chip2chip CONFIG.C_INTERFACE_TYPE 2
  ad_ip_parameter axi_chip2chip CONFIG.C_MASTER_FPGA 0
  ad_ip_parameter axi_chip2chip CONFIG.C_M_AXI_ID_WIDTH 0
  ad_ip_parameter axi_chip2chip CONFIG.C_M_AXI_WUSER_WIDTH 0

  ad_ip_instance aurora_64b66b aurora_64b66b
  ad_ip_parameter aurora_64b66b CONFIG.SupportLevel 1
  ad_ip_parameter aurora_64b66b CONFIG.C_LINE_RATE 12.5
  ad_ip_parameter aurora_64b66b CONFIG.C_REFCLK_FREQUENCY 300
  ad_ip_parameter aurora_64b66b CONFIG.SINGLEEND_GTREFCLK {true}
  ad_ip_parameter aurora_64b66b CONFIG.interface_mode {Streaming}

  create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 node_RX
  create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 node_TX

  ad_connect node_RX aurora_64b66b/GT_SERIAL_RX
  ad_connect node_TX aurora_64b66b/GT_SERIAL_TX

  create_bd_port -dir I node_ref_clk
  ad_connect node_ref_clk aurora_64b66b/refclk1_in

  ad_connect aurora_64b66b/USER_DATA_M_AXIS_RX axi_chip2chip/AXIS_RX
  ad_connect axi_chip2chip/AXIS_TX aurora_64b66b/USER_DATA_S_AXIS_TX
  ad_connect axi_chip2chip/aurora_pma_init_out aurora_64b66b/pma_init
  ad_connect axi_chip2chip/aurora_reset_pb aurora_64b66b/reset_pb
  ad_connect aurora_64b66b/user_clk_out axi_chip2chip/axi_c2c_phy_clk
  ad_connect aurora_64b66b/channel_up axi_chip2chip/axi_c2c_aurora_channel_up
  ad_connect aurora_64b66b/mmcm_not_locked_out axi_chip2chip/aurora_mmcm_not_locked
  ad_connect aurora_64b66b/init_clk axi_chip2chip/aurora_init_clk

  create_bd_port -dir I node_init_clk
  create_bd_port -dir I node_resetn

  ad_ip_instance proc_sys_reset node_clk_rstgen
  ad_connect node_init_clk node_clk_rstgen/slowest_sync_clk
  ad_connect node_resetn node_clk_rstgen/ext_reset_in

  ad_connect node_init_clk axi_chip2chip/m_aclk
  ad_connect node_clk_rstgen/peripheral_aresetn axi_chip2chip/m_aresetn
  ad_connect node_init_clk aurora_64b66b/init_clk

  make_bd_intf_pins_external [get_bd_intf_pins axi_chip2chip/m_axi]

  validate_bd_design
  save_bd_design
  close_bd_design [current_bd_design]

  current_bd_design [get_bd_designs $top_design]
}