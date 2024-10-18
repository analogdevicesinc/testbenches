global ad_project_params

set random_width [expr int(8*pow(2, int(7.0*rand()+1)))]
set INPUT_WIDTH $random_width
set ad_project_params(INPUT_WIDTH) $INPUT_WIDTH

set random_width [expr int(8*pow(2, int(7.0*rand()+1)))]
set OUTPUT_WIDTH $random_width
set ad_project_params(OUTPUT_WIDTH) $OUTPUT_WIDTH

set FIFO_LIMITED [expr int(rand()*2)]
set ad_project_params(FIFO_LIMITED) $FIFO_LIMITED

if {$FIFO_LIMITED} {
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

set ad_project_params(INPUT_CLK) [expr int(rand()*9000)+1000]
set ad_project_params(OUTPUT_CLK) [expr int(rand()*9000)+1000]
