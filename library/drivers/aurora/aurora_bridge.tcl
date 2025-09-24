proc create_aurora_bridge { \
  {NAME aurora_bridge} \
  {NUM_NODES 1} \
} {

  set top_design [current_bd_design]

  create_bd_design $NAME

  for {set i 0} {$i < $NUM_NODES} {incr i} {
    ad_ip_instance aurora_64b66b aurora_64b66b_master_$i
    ad_ip_parameter aurora_64b66b_master_$i CONFIG.C_LINE_RATE 12.5
    ad_ip_parameter aurora_64b66b_master_$i CONFIG.C_REFCLK_FREQUENCY 300
    ad_ip_parameter aurora_64b66b_master_$i CONFIG.SINGLEEND_GTREFCLK {true}
    ad_ip_parameter aurora_64b66b_master_$i CONFIG.interface_mode {Streaming}

    ad_ip_instance axi_chip2chip axi_chip2chip_master_$i
    ad_ip_parameter axi_chip2chip_master_$i CONFIG.C_INTERFACE_TYPE 2

    create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 bridge_master_${i}_RX
    create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 bridge_master_${i}_TX

    ad_connect bridge_master_${i}_RX aurora_64b66b_master_$i/GT_SERIAL_RX
    ad_connect bridge_master_${i}_TX aurora_64b66b_master_$i/GT_SERIAL_TX
  }

  ad_ip_instance aurora_64b66b aurora_64b66b_slave
  ad_ip_parameter aurora_64b66b_slave CONFIG.SupportLevel 1
  ad_ip_parameter aurora_64b66b_slave CONFIG.C_LINE_RATE 12.5
  ad_ip_parameter aurora_64b66b_slave CONFIG.C_REFCLK_FREQUENCY 300
  ad_ip_parameter aurora_64b66b_slave CONFIG.SINGLEEND_GTREFCLK {true}
  ad_ip_parameter aurora_64b66b_slave CONFIG.interface_mode {Streaming}

  ad_ip_instance axi_chip2chip axi_chip2chip_slave
  ad_ip_parameter axi_chip2chip_slave CONFIG.C_INTERFACE_TYPE 2
  ad_ip_parameter axi_chip2chip_slave CONFIG.C_MASTER_FPGA 0
  ad_ip_parameter axi_chip2chip_slave CONFIG.C_M_AXI_ID_WIDTH 0
  ad_ip_parameter axi_chip2chip_slave CONFIG.C_M_AXI_WUSER_WIDTH 0

  ad_ip_instance smartconnect smartconnect
  ad_ip_parameter smartconnect CONFIG.NUM_SI 1
  ad_ip_parameter smartconnect CONFIG.NUM_MI $NUM_NODES
  ad_ip_parameter smartconnect CONFIG.NUM_CLKS 1

  create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 bridge_slave_RX
  create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 bridge_slave_TX

  ad_connect bridge_slave_RX aurora_64b66b_slave/GT_SERIAL_RX
  ad_connect bridge_slave_TX aurora_64b66b_slave/GT_SERIAL_TX

  create_bd_port -dir I bridge_ref_clk
  ad_connect bridge_ref_clk aurora_64b66b_slave/refclk1_in

  for {set i 0} {$i < $NUM_NODES} {incr i} {
    ad_connect bridge_ref_clk aurora_64b66b_master_$i/refclk1_in

    ad_connect aurora_64b66b_master_$i/USER_DATA_S_AXIS_TX axi_chip2chip_master_$i/AXIS_TX
    ad_connect smartconnect/M0${i}_AXI axi_chip2chip_master_$i/s_axi
    ad_connect axi_chip2chip_master_$i/AXIS_RX aurora_64b66b_master_$i/USER_DATA_M_AXIS_RX

    ad_connect axi_chip2chip_master_$i/aurora_reset_pb aurora_64b66b_master_$i/reset_pb
    ad_connect aurora_64b66b_master_$i/pma_init axi_chip2chip_master_$i/aurora_pma_init_out
    ad_connect aurora_64b66b_slave/gt_qpllrefclk_quad1_out aurora_64b66b_master_$i/gt_qpllrefclk_quad1_in
    ad_connect aurora_64b66b_slave/gt_qpllclk_quad1_out aurora_64b66b_master_$i/gt_qpllclk_quad1_in
    ad_connect aurora_64b66b_slave/sync_clk_out aurora_64b66b_master_$i/sync_clk
    ad_connect aurora_64b66b_slave/user_clk_out aurora_64b66b_master_$i/user_clk
    ad_connect axi_chip2chip_master_$i/axi_c2c_phy_clk aurora_64b66b_slave/user_clk_out
    ad_connect aurora_64b66b_master_$i/channel_up axi_chip2chip_master_$i/axi_c2c_aurora_channel_up
    ad_connect aurora_64b66b_slave/gt_qplllock_quad1_out aurora_64b66b_master_$i/gt_qplllock_quad1_in
    ad_connect aurora_64b66b_slave/gt_qpllrefclklost_quad1_out aurora_64b66b_master_$i/gt_qpllrefclklost_quad1
  }

  ad_connect axi_chip2chip_slave/AXIS_TX aurora_64b66b_slave/USER_DATA_S_AXIS_TX
  ad_connect aurora_64b66b_slave/USER_DATA_M_AXIS_RX axi_chip2chip_slave/AXIS_RX
  ad_connect axi_chip2chip_slave/m_axi smartconnect/S00_AXI

  ad_connect axi_chip2chip_slave/axi_c2c_phy_clk aurora_64b66b_slave/user_clk_out
  ad_connect aurora_64b66b_slave/mmcm_not_locked_out axi_chip2chip_slave/aurora_mmcm_not_locked
  ad_connect aurora_64b66b_slave/reset_pb axi_chip2chip_slave/aurora_reset_pb
  ad_connect aurora_64b66b_slave/pma_init axi_chip2chip_slave/aurora_pma_init_out
  ad_connect aurora_64b66b_slave/channel_up axi_chip2chip_slave/axi_c2c_aurora_channel_up

  create_bd_port -dir I bridge_init_clk
  create_bd_port -dir I bridge_resetn

  ad_ip_instance proc_sys_reset bridge_clk_rstgen
  ad_connect bridge_init_clk bridge_clk_rstgen/slowest_sync_clk
  ad_connect bridge_resetn bridge_clk_rstgen/ext_reset_in

  for {set i 0} {$i < $NUM_NODES} {incr i} {
    ad_connect bridge_init_clk axi_chip2chip_master_$i/s_aclk
    ad_connect bridge_init_clk axi_chip2chip_master_$i/aurora_init_clk
    ad_connect bridge_init_clk aurora_64b66b_master_$i/init_clk
    ad_connect bridge_clk_rstgen/peripheral_aresetn axi_chip2chip_master_$i/s_aresetn
  }

  ad_connect bridge_init_clk aurora_64b66b_slave/init_clk
  ad_connect bridge_init_clk axi_chip2chip_slave/m_aclk
  ad_connect bridge_init_clk axi_chip2chip_slave/aurora_init_clk
  ad_connect bridge_init_clk smartconnect/aclk

  ad_connect bridge_clk_rstgen/peripheral_aresetn axi_chip2chip_slave/m_aresetn
  ad_connect bridge_clk_rstgen/peripheral_aresetn smartconnect/aresetn

  assign_bd_address

  for {set i 0} {$i < $NUM_NODES} {incr i} {
    set addr [expr {0x70000000 + 0x1000000 * $i}]
    set seg_name axi_chip2chip_slave/MAXI/SEG_axi_chip2chip_master_${i}_Mem0
    set_property offset $addr [get_bd_addr_segs $seg_name]
    set_property range 16M [get_bd_addr_segs $seg_name]
  }

  validate_bd_design
  save_bd_design
  close_bd_design [current_bd_design]

  current_bd_design [get_bd_designs $top_design]
}