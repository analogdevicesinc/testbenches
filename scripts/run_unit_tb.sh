##############################################################################
## Copyright (C) 2014-2024 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: BSD-1-Clause
##############################################################################

export NAME=`basename $0`

export MODE=batch

# MODE not defined or defined to something else than 'batch'
if [[ -z ${MODE+x} ]] || [[ ! "$MODE" =~ "batch" ]]; then MODE="gui";fi
MODE="-"${MODE##*-} #remove any eventual extra dashes

# XSim flow
xvlog --sv -log ${NAME}_xvlog.log -L xilinx_vip --sourcelibdir . ${SOURCE} || exit 1
xelab -log ${NAME}_xelab.log -L xilinx_vip -debug all ${NAME} || exit 1
if [[ "$MODE" == "-gui" ]]; then
	echo "log_wave -r *" > xsim_gui_cmd.tcl
	echo "run all" >> xsim_gui_cmd.tcl
	xsim work.${NAME} -gui -tclbatch xsim_gui_cmd.tcl -log ${NAME}_xsim.log
else
	xsim work.${NAME} -R -log ${NAME}_xsim.log
fi
