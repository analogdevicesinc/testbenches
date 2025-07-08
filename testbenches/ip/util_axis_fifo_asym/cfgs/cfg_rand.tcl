global ad_project_params

set async_clk [expr int(rand()*2)]
set ad_project_params(ASYNC_CLK) $async_clk

set tkeep_en [expr int(rand()*2)]
set ad_project_params(TKEEP_EN) $tkeep_en

set tlast_en [expr int(rand()*2)]
set ad_project_params(TLAST_EN) $tlast_en

set tstrb_en [expr int(rand()*2)]
set ad_project_params(TSTRB_EN) $tstrb_en

set tid_width [expr int(int(rand()*2)*int(rand()*33.0))]
set ad_project_params(TID_WIDTH) $tid_width

set tdest_width [expr int(int(rand()*2)*int(rand()*33.0))]
set ad_project_params(TDEST_WIDTH) $tdest_width

set input_width [expr int(8*pow(2, int(9.0*rand())))]
set ad_project_params(INPUT_WIDTH) $input_width

set output_width [expr int(8*pow(2, int(9.0*rand())))]
set ad_project_params(OUTPUT_WIDTH) $output_width

set reduced_fifo [expr int(rand()*2)]
set ad_project_params(REDUCED_FIFO) $reduced_fifo

if {$input_width > $output_width} {
  set ratio $input_width/$output_width
  set min_user_bits $input_width/8
} else {
  set ratio $output_width/$input_width
  set min_user_bits $output_width/8
}

set tuser_bits_per_byte [expr int(rand()*2)]
set ad_project_params(TUSER_BITS_PER_BYTE) $tuser_bits_per_byte

set tuser_width [expr int($min_user_bits * int(8.0*rand()+1))]
set ad_project_params(TUSER_WIDTH) $tuser_width

if {$reduced_fifo == 0} {
  set ratio 1
}

set address_width [expr int(int(log($ratio)/log(2))+4.0*rand()+1)]
set ad_project_params(ADDRESS_WIDTH) $address_width

set input_clk [expr int(rand()*9)+1]
set ad_project_params(INPUT_CLK) $input_clk

if {$async_clk} {
  set output_clk [expr int(rand()*9)+1]
  set ad_project_params(OUTPUT_CLK) $output_clk
} else {
  set ad_project_params(OUTPUT_CLK) $input_clk
}
