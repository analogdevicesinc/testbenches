proc create_aurora_bridge { \
  {NAME aurora_bridge} \
} {

  set top_design [current_bd_design]

  create_bd_design $NAME

  ad_ip_instance aurora_64b66b aurora_64b66b_slave
  ad_ip_parameter aurora_64b66b_slave CONFIG.C_LINE_RATE 12.5
  ad_ip_parameter aurora_64b66b_slave CONFIG.C_REFCLK_FREQUENCY 300
  ad_ip_parameter aurora_64b66b_slave CONFIG.SINGLEEND_GTREFCLK {true}
  ad_ip_parameter aurora_64b66b_slave CONFIG.interface_mode {Streaming}

  ad_ip_instance aurora_64b66b aurora_64b66b_master
  ad_ip_parameter aurora_64b66b_master CONFIG.SupportLevel 1
  ad_ip_parameter aurora_64b66b_master CONFIG.C_LINE_RATE 12.5
  ad_ip_parameter aurora_64b66b_master CONFIG.C_REFCLK_FREQUENCY 300
  ad_ip_parameter aurora_64b66b_master CONFIG.SINGLEEND_GTREFCLK {true}
  ad_ip_parameter aurora_64b66b_master CONFIG.interface_mode {Streaming}

  ad_ip_instance axi_chip2chip axi_chip2chip_slave
  ad_ip_parameter axi_chip2chip_slave CONFIG.C_INTERFACE_TYPE 2
  ad_ip_parameter axi_chip2chip_slave CONFIG.C_MASTER_FPGA 0
  ad_ip_parameter axi_chip2chip_slave CONFIG.C_M_AXI_ID_WIDTH 0
  ad_ip_parameter axi_chip2chip_slave CONFIG.C_M_AXI_WUSER_WIDTH 0

  ad_ip_instance axi_chip2chip axi_chip2chip_master
  ad_ip_parameter axi_chip2chip_master CONFIG.C_INTERFACE_TYPE 2

  ad_ip_instance smartconnect smartconnect
  ad_ip_parameter smartconnect CONFIG.NUM_SI 1
  ad_ip_parameter smartconnect CONFIG.NUM_MI 1
  ad_ip_parameter smartconnect CONFIG.NUM_CLKS 1

  create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 bridge_slave_RX
  create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 bridge_slave_TX

  ad_connect bridge_slave_RX aurora_64b66b_slave/GT_SERIAL_RX
  ad_connect bridge_slave_TX aurora_64b66b_slave/GT_SERIAL_TX

  create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 bridge_master_RX
  create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 bridge_master_TX

  ad_connect bridge_master_RX aurora_64b66b_master/GT_SERIAL_RX
  ad_connect bridge_master_TX aurora_64b66b_master/GT_SERIAL_TX

  create_bd_port -dir I bridge_ref_clk
  ad_connect bridge_ref_clk aurora_64b66b_master/refclk1_in
  ad_connect bridge_ref_clk aurora_64b66b_slave/refclk1_in

  ad_connect axi_chip2chip_slave/AXIS_TX aurora_64b66b_slave/USER_DATA_S_AXIS_TX
  ad_connect aurora_64b66b_slave/USER_DATA_M_AXIS_RX axi_chip2chip_slave/AXIS_RX
  ad_connect axi_chip2chip_slave/m_axi smartconnect/S00_AXI

  ad_connect aurora_64b66b_master/USER_DATA_S_AXIS_TX axi_chip2chip_master/AXIS_TX
  ad_connect smartconnect/M00_AXI axi_chip2chip_master/s_axi
  ad_connect axi_chip2chip_master/AXIS_RX aurora_64b66b_master/USER_DATA_M_AXIS_RX

  ad_connect axi_chip2chip_master/aurora_reset_pb aurora_64b66b_master/reset_pb
  ad_connect aurora_64b66b_master/pma_init axi_chip2chip_master/aurora_pma_init_out
  ad_connect aurora_64b66b_master/gt_qpllrefclk_quad1_out aurora_64b66b_slave/gt_qpllrefclk_quad1_in
  ad_connect aurora_64b66b_master/gt_qpllclk_quad1_out aurora_64b66b_slave/gt_qpllclk_quad1_in
  ad_connect aurora_64b66b_master/sync_clk_out aurora_64b66b_slave/sync_clk
  ad_connect aurora_64b66b_master/user_clk_out aurora_64b66b_slave/user_clk
  ad_connect axi_chip2chip_slave/axi_c2c_phy_clk aurora_64b66b_master/user_clk_out
  ad_connect axi_chip2chip_master/axi_c2c_phy_clk aurora_64b66b_master/user_clk_out
  ad_connect aurora_64b66b_master/channel_up axi_chip2chip_master/axi_c2c_aurora_channel_up

  ad_connect aurora_64b66b_master/mmcm_not_locked_out axi_chip2chip_master/aurora_mmcm_not_locked
  ad_connect aurora_64b66b_master/gt_qplllock_quad1_out aurora_64b66b_slave/gt_qplllock_quad1_in
  ad_connect aurora_64b66b_master/gt_qpllrefclklost_quad1_out aurora_64b66b_slave/gt_qpllrefclklost_quad1

  ad_connect aurora_64b66b_slave/reset_pb axi_chip2chip_slave/aurora_reset_pb
  ad_connect aurora_64b66b_slave/pma_init axi_chip2chip_slave/aurora_pma_init_out
  ad_connect aurora_64b66b_slave/channel_up axi_chip2chip_slave/axi_c2c_aurora_channel_up

  create_bd_port -dir I bridge_init_clk
  create_bd_port -dir I bridge_resetn

  ad_ip_instance proc_sys_reset bridge_clk_rstgen
  ad_connect bridge_init_clk bridge_clk_rstgen/slowest_sync_clk
  ad_connect bridge_resetn bridge_clk_rstgen/ext_reset_in

  ad_connect bridge_init_clk aurora_64b66b_slave/init_clk
  ad_connect bridge_init_clk axi_chip2chip_slave/m_aclk
  ad_connect bridge_init_clk axi_chip2chip_slave/aurora_init_clk
  ad_connect bridge_init_clk smartconnect/aclk
  ad_connect bridge_init_clk axi_chip2chip_master/s_aclk
  ad_connect bridge_init_clk axi_chip2chip_master/aurora_init_clk
  ad_connect bridge_init_clk aurora_64b66b_master/init_clk
  ad_connect bridge_clk_rstgen/peripheral_aresetn axi_chip2chip_slave/m_aresetn
  ad_connect bridge_clk_rstgen/peripheral_aresetn smartconnect/aresetn
  ad_connect bridge_clk_rstgen/peripheral_aresetn axi_chip2chip_master/s_aresetn

  assign_bd_address
  set_property offset 0x70000000 [get_bd_addr_segs {axi_chip2chip_slave/MAXI/SEG_axi_chip2chip_master_Mem0}]
  set_property range 256M [get_bd_addr_segs {axi_chip2chip_slave/MAXI/SEG_axi_chip2chip_master_Mem0}]

  validate_bd_design

  save_bd_design
  close_bd_design [current_bd_design]

  current_bd_design [get_bd_designs $top_design]
}