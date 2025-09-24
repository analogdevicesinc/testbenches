proc create_aurora_controller { \
  {NAME aurora_controller} \
} {

  set top_design [current_bd_design]

  create_bd_design $NAME

  ad_ip_instance axi_chip2chip axi_chip2chip
  ad_ip_parameter axi_chip2chip CONFIG.C_INTERFACE_TYPE 2

  ad_ip_instance aurora_64b66b aurora_64b66b
  ad_ip_parameter aurora_64b66b CONFIG.SupportLevel 1
  ad_ip_parameter aurora_64b66b CONFIG.C_LINE_RATE 12.5
  ad_ip_parameter aurora_64b66b CONFIG.C_REFCLK_FREQUENCY 300
  ad_ip_parameter aurora_64b66b CONFIG.SINGLEEND_GTREFCLK {true}
  ad_ip_parameter aurora_64b66b CONFIG.interface_mode {Streaming}

  create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 controller_RX
  create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 controller_TX

  ad_connect controller_RX aurora_64b66b/GT_SERIAL_RX
  ad_connect controller_TX aurora_64b66b/GT_SERIAL_TX

  create_bd_port -dir I controller_ref_clk
  ad_connect controller_ref_clk aurora_64b66b/refclk1_in

  ad_connect axi_chip2chip/aurora_pma_init_out aurora_64b66b/pma_init
  ad_connect axi_chip2chip/aurora_reset_pb aurora_64b66b/reset_pb
  ad_connect aurora_64b66b/init_clk axi_chip2chip/aurora_init_clk
  ad_connect axi_chip2chip/AXIS_TX aurora_64b66b/USER_DATA_S_AXIS_TX
  ad_connect aurora_64b66b/USER_DATA_M_AXIS_RX axi_chip2chip/AXIS_RX
  ad_connect axi_chip2chip/aurora_mmcm_not_locked aurora_64b66b/mmcm_not_locked_out
  ad_connect aurora_64b66b/channel_up axi_chip2chip/axi_c2c_aurora_channel_up
  ad_connect aurora_64b66b/user_clk_out axi_chip2chip/axi_c2c_phy_clk

  create_bd_port -dir I controller_init_clk
  create_bd_port -dir I controller_resetn

  ad_ip_instance proc_sys_reset controller_clk_rstgen
  ad_connect controller_init_clk controller_clk_rstgen/slowest_sync_clk
  ad_connect controller_resetn controller_clk_rstgen/ext_reset_in

  ad_connect controller_init_clk axi_chip2chip/s_aclk
  ad_connect controller_clk_rstgen/peripheral_aresetn axi_chip2chip/s_aresetn
  ad_connect controller_init_clk aurora_64b66b/init_clk

  make_bd_intf_pins_external [get_bd_intf_pins axi_chip2chip/s_axi]

  validate_bd_design
  save_bd_design
  close_bd_design [current_bd_design]

  current_bd_design [get_bd_designs $top_design]
}