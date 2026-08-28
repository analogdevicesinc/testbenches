global ad_project_params

set async_clk [expr int(rand()*2)]
set async_clk 0
set ad_project_params(ASYNC_CLK) $async_clk

set random_width [expr int(8*pow(2, int(7.0*rand()+1)))]
set INPUT_WIDTH $random_width
set INPUT_WIDTH 32
set ad_project_params(INPUT_WIDTH) $INPUT_WIDTH

set random_width [expr int(8*pow(2, int(7.0*rand()+1)))]
set OUTPUT_WIDTH $random_width
set OUTPUT_WIDTH 64
set ad_project_params(OUTPUT_WIDTH) $OUTPUT_WIDTH

set reduced_fifo [expr int(rand()*2)]
set reduced_fifo 0
set ad_project_params(REDUCED_FIFO) $reduced_fifo

if {$reduced_fifo} {
    if {$INPUT_WIDTH > $OUTPUT_WIDTH} {
        set RATIO $INPUT_WIDTH/$OUTPUT_WIDTH
    } else {
        set RATIO $OUTPUT_WIDTH/$INPUT_WIDTH
    }
} else {
    set RATIO 1
}

set random_width [expr int(int(log($RATIO)/log(2))+4.0*rand()+1)]
set random_width 4
set ad_project_params(ADDRESS_WIDTH) $random_width

set random_almost_empty_threshold [expr int(rand()*(pow(2, $random_width)-log($RATIO)/log(2))-1)]
set random_almost_empty_threshold 4
set ad_project_params(ALMOST_EMPTY_THRESHOLD) $random_almost_empty_threshold

set random_almost_full_threshold [expr int(rand()*(pow(2, $random_width)-log($RATIO)/log(2))-1)]
set random_almost_full_threshold 4
set ad_project_params(ALMOST_FULL_THRESHOLD) $random_almost_full_threshold

set tkeep_en [expr int(rand()*2)]
set ad_project_params(TKEEP_EN) $tkeep_en

set tstrb_en [expr int(rand()*2)]
set ad_project_params(TSTRB_EN) $tkeep_en

set tlast_en [expr int(rand()*2)]
set ad_project_params(TLAST_EN) $tlast_en

set tuser_en [expr int(rand()*2)]
set ad_project_params(TUSER_EN) $tuser_en

set tid_en [expr int(rand()*2)]
set ad_project_params(TID_EN) $tid_en

set tdest_en [expr int(rand()*2)]
set ad_project_params(TDEST_EN) $tdest_en

set tuser_bits_per_byte [expr int(rand()*2)]
set ad_project_params(TUSER_BITS_PER_BYTE) $tuser_bits_per_byte

set random_width [expr int(rand()*8)+1]
set ad_project_params(TUSER_WIDTH) $random_width

set random_width [expr int(rand()*8)+1]
set ad_project_params(TID_WIDTH) $random_width

set random_width [expr int(rand()*8)+1]
set ad_project_params(TDEST_WIDTH) $random_width

set input_clk [expr int(rand()*9)+1]
set input_clk 4
set ad_project_params(INPUT_CLK) $input_clk

if {$async_clk} {
    set output_clk [expr int(rand()*9)+1]
    set output_clk 4
    set ad_project_params(OUTPUT_CLK) $output_clk
} else {
    set ad_project_params(OUTPUT_CLK) $input_clk
}
