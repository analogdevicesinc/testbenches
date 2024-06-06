global ad_project_params

set max_width 4096

while {$max_width > 2048} {
    set channels  [expr int(15.0*rand()+2)]              ; # 2-16
    set samples   [expr int(pow(2, int(4.0*rand()+1)))]  ; # 2-16
    set width     [expr int(8*pow(2, int(4.0*rand())))]  ; # 8-64

    set max_width [expr $channels * $samples * $width]
}

set ad_project_params(CHANNELS)  $channels
set ad_project_params(SAMPLES)   $samples
set ad_project_params(WIDTH)     $width
