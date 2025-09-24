global ad_project_params

set async_clk [expr int(rand()*2)]
set ad_project_params(ASYNC_CLK) $async_clk

set tkeep_en 1
set ad_project_params(TKEEP_EN) $tkeep_en

set tlast_en [expr int(rand()*2)]
set ad_project_params(TLAST_EN) $tlast_en

set random_width [expr int(8*pow(2, int(7.0*rand()+1)))]
set INPUT_WIDTH $random_width
set ad_project_params(INPUT_WIDTH) $INPUT_WIDTH

set random_width [expr int(8*pow(2, int(7.0*rand()+1)))]
set OUTPUT_WIDTH $random_width
set ad_project_params(OUTPUT_WIDTH) $OUTPUT_WIDTH

set reduced_fifo [expr int(rand()*2)]
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
set ad_project_params(ADDRESS_WIDTH) $random_width

set input_clk [expr int(rand()*9)+1]
set ad_project_params(INPUT_CLK) $input_clk

if {$async_clk} {
    set output_clk [expr int(rand()*9)+1]
    set ad_project_params(OUTPUT_CLK) $output_clk
} else {
    set ad_project_params(OUTPUT_CLK) $input_clk
}
