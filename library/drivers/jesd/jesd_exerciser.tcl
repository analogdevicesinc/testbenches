
# JESD exerciser for simulation purposes

proc create_jesd_exerciser { \
  {NAME jesd_exerciser} \
  {TX_OR_RX_N 1} \
  {ENCODER_SEL 2} \
  {LANE_RATE 24.75} \
  {JESD_M 4 } \
  {JESD_L 4 } \
  {JESD_S 2 } \
  {JESD_NP 12} \
} {

  # TODO set these constant for now
  set NUM_LINKS 1

  # calculate parameters
   if {$ENCODER_SEL == 1} {
    # 8b10b
    set DATAPATH_WIDTH 4
    set NP12_DATAPATH_WIDTH 6
  } else {
    # 64b66b
    set DATAPATH_WIDTH 8
    set NP12_DATAPATH_WIDTH 12
  }

  set NUM_OF_LANES      [expr $JESD_L * $NUM_LINKS]
  set NUM_OF_CONVERTERS [expr $JESD_M * $NUM_LINKS]
  set SAMPLES_PER_FRAME $JESD_S
  set SAMPLE_WIDTH      $JESD_NP
  set DMA_SAMPLE_WIDTH  $JESD_NP
  if {$DMA_SAMPLE_WIDTH == 12} {
    set DMA_SAMPLE_WIDTH 16
  }

  set JESD_F [expr ($JESD_M*$JESD_S*$JESD_NP)/(8*$JESD_L)]
  # For F=3,6,12 use dual clock
  if {$JESD_F % 3 == 0} {
    set TPL_DATAPATH_WIDTH [expr max($JESD_F,$NP12_DATAPATH_WIDTH)]
  } else {
    set TPL_DATAPATH_WIDTH [expr max($JESD_F,$DATAPATH_WIDTH)]
  }


  set top_design [current_bd_design]

  create_bd_design $NAME

  if {$TX_OR_RX_N == 1} {
    set rxtx tx
    set tpl_core tx_tpl_core/dac_tpl_core
    set TX_NUM_OF_LANES $NUM_OF_LANES
    set RX_NUM_OF_LANES 0
  } else {
    set rxtx rx
    set tpl_core rx_tpl_core/adc_tpl_core
    set TX_NUM_OF_LANES 0
    set RX_NUM_OF_LANES $NUM_OF_LANES
  }

  # create common system interface
  create_bd_port -dir I sys_cpu_clk
  create_bd_port -dir I sys_cpu_resetn

  create_bd_port -dir I device_clk
  create_bd_port -dir I link_clk
  create_bd_port -dir I ref_clk


  ad_ip_instance util_adxcvr util_xcvr
  ad_ip_parameter util_xcvr CONFIG.TX_NUM_OF_LANES $TX_NUM_OF_LANES
  ad_ip_parameter util_xcvr CONFIG.RX_NUM_OF_LANES $RX_NUM_OF_LANES
  ad_ip_parameter util_xcvr CONFIG.LINK_MODE $ENCODER_SEL
  ad_ip_parameter util_xcvr CONFIG.TX_LANE_RATE $LANE_RATE
  ad_ip_parameter util_xcvr CONFIG.XCVR_TYPE.VALUE_SRC USER
  ad_ip_parameter util_xcvr CONFIG.XCVR_TYPE {9}

  ad_ip_instance axi_adxcvr axi_xcvr
  ad_ip_parameter axi_xcvr CONFIG.ID 0
  ad_ip_parameter axi_xcvr CONFIG.LINK_MODE $ENCODER_SEL
  ad_ip_parameter axi_xcvr CONFIG.NUM_OF_LANES $NUM_OF_LANES
  ad_ip_parameter axi_xcvr CONFIG.TX_OR_RX_N $TX_OR_RX_N
  ad_ip_parameter axi_xcvr CONFIG.QPLL_ENABLE 1
  ad_ip_parameter axi_xcvr CONFIG.XCVR_TYPE.VALUE_SRC USER
  ad_ip_parameter axi_xcvr CONFIG.XCVR_TYPE {9}

  adi_axi_jesd204_${rxtx}_create axi_jesd $NUM_OF_LANES $NUM_LINKS $ENCODER_SEL
  ad_ip_parameter axi_jesd/${rxtx} CONFIG.TPL_DATA_PATH_WIDTH $TPL_DATAPATH_WIDTH


  adi_tpl_jesd204_${rxtx}_create ${rxtx}_tpl_core $NUM_OF_LANES \
                                                  $NUM_OF_CONVERTERS \
                                                  $SAMPLES_PER_FRAME \
                                                  $SAMPLE_WIDTH \
                                                  $TPL_DATAPATH_WIDTH \
                                                  $DMA_SAMPLE_WIDTH

  if {$TX_OR_RX_N == 0} {
    ad_ip_parameter ${rxtx}_tpl_core/adc_tpl_core CONFIG.EN_FRAME_ALIGN {0}
  }

  for {set i 0} {$i < $NUM_OF_LANES} {incr i} {
    ad_xcvrpll  ref_clk  util_xcvr/cpll_ref_clk_$i
    if {[expr $i % 4] == 0} {
      ad_xcvrpll  ref_clk  util_xcvr/qpll_ref_clk_$i
    }
  }

  ad_xcvrpll  axi_xcvr/up_pll_rst util_xcvr/up_qpll_rst_*
  ad_xcvrpll  axi_xcvr/up_pll_rst util_xcvr/up_cpll_rst_*

  ad_connect  sys_cpu_resetn util_xcvr/up_rstn
  ad_connect  sys_cpu_clk    util_xcvr/up_clk

  ad_connect device_clk $tpl_core/link_clk

  if {$TX_OR_RX_N == 1} {
    ad_connect tx_tpl_core/link axi_jesd/tx_data
    for {set i 0} {$i < $NUM_OF_CONVERTERS} {incr i} {
      make_bd_pins_external [get_bd_pins tx_tpl_core/dac_data_$i]
    }
  } else {
    ad_connect axi_jesd/rx_data_tdata  rx_tpl_core/link_data
    ad_connect axi_jesd/rx_data_tvalid rx_tpl_core/link_valid
  }

  # connections

  # Workaround: ad_xcvrcon was made for a singe util_xcvr, reset it's internal counters
  global xcvr_index
  global xcvr_tx_index
  global xcvr_rx_index
  global xcvr_instance

  set xcvr_index -1
  set xcvr_tx_index 0
  set xcvr_rx_index 0
  set xcvr_instance NONE

  ad_xcvrcon  util_xcvr axi_xcvr axi_jesd {} link_clk device_clk


  # list of peripherals to connect to the control interface
  set peripherals {axi_jesd axi_xcvr}
  set peripherals [lappend peripherals $tpl_core]

  # create local interconnect for register control
  ad_ip_instance smartconnect interconnect [list \
    NUM_MI [llength $peripherals] \
    NUM_SI 1 \
  ]
  ad_connect  sys_cpu_clk interconnect/aclk
  ad_connect  sys_cpu_resetn interconnect/aresetn

  set i 0
  foreach p $peripherals {
    ad_connect  interconnect/M0${i}_AXI $p/s_axi
    ad_connect  sys_cpu_clk $p/s_axi_aclk
    ad_connect  sys_cpu_resetn $p/s_axi_aresetn
    incr i
  }

  make_bd_intf_pins_external  [get_bd_intf_pins interconnect/S00_AXI]


  validate_bd_design

  save_bd_design
  close_bd_design [current_bd_design]

  current_bd_design [get_bd_designs $top_design]

}

