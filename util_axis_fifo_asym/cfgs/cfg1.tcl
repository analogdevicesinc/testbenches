global ad_project_params

set random_width [expr int(8*pow(2, int(7.0*rand()+1)))]
set ad_project_params(INPUT_WIDTH) $random_width

set random_width [expr int(8*pow(2, int(7.0*rand()+1)))]
set ad_project_params(OUTPUT_WIDTH) $random_width
