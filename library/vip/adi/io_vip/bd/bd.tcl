###############################################################################
## Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

proc init {cellpath otherInfo} {
	set ip [get_bd_cells $cellpath]

	bd::mark_propagate_overrideable $ip \
		"WIDTH"
}

proc parameter_set {cellpath} {
	set ip [get_bd_cells $cellpath]

	set pin_source [find_bd_objs -relation connected_to [get_bd_pins -of_objects $ip -filter {NAME =~ i}]]
	if {$pin_source != {}} {
		set data_width [get_property "LEFT" $pin_source]
		if {$data_width != {}} {
			set_property "CONFIG.WIDTH" [expr $data_width + 1] $ip
		} else {
			set_property "CONFIG.WIDTH" 1 $ip
		}
	}
}

proc pre_propagate {cellpath otherinfo} {

}

proc propagate {cellpath otherinfo} {
	parameter_set $cellpath
}

proc post_propagate {cellpath otherinfo} {

}
