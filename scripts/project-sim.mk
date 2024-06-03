####################################################################################
####################################################################################
## Copyright 2018-2024 (c) Analog Devices, Inc.
####################################################################################
####################################################################################

# Assumes this file is in <HDL>/testbenches/scripts/project-sim.mk 
ADI_HDL_DIR := $(subst /testbenches/scripts/project-sim.mk,,$(abspath $(lastword $(MAKEFILE_LIST))))
HDL_LIBRARY_PATH := $(ADI_HDL_DIR)/library/
include $(ADI_HDL_DIR)/quiet.mk

ENV_DEPS += $(foreach dep,$(LIB_DEPS),$(HDL_LIBRARY_PATH)$(dep)/component.xml)
ENV_DEPS += $(foreach dep,$(SIM_LIB_DEPS),$(ADI_HDL_DIR)/testbenches/common/sv/$(dep)/component.xml)

SHELL:=/bin/bash

# simulate - Run a sim command and look in logfile for errors; creates JUnit XML
# $(1): Command to execute
# $(2): Logfile name
# $(3): Textual description of the start of the task
# $(4): Textual description of the end of the task
# $(5): configuration name
# $(6): test  name
FOLDER=$(shell basename $(CURDIR))
define simulate
@echo "$(strip $(3)) [$(HL)$(CURDIR)/$(strip $(2))$(NC)] ..."
if [ -f $(CURDIR)/runs/$(strip $(5))/system_good.tmp ] || [ $(6) = BuildEnv ]; then \
	START=$$(date +%s); \
	$(strip $(1)) >> $(strip $(2)) 2>&1; \
	(ERR=$$?; \
	END=$$(date +%s); \
	DIFF=$$(( $$END - $$START )); \
	ERRS=`grep -v ^# $(2) | grep -w -i -e ^error -e ^fatal -e ^fatal_error -e "\[ERROR\]" -e "while\\ executing" -C 10 |  sed 's/</\&lt;/g' | sed 's/>/\&gt;/g'`; \
	if [[ $$ERRS > 0 ]] ; then ERR=1; fi;\
	JUnitFile='results/$(strip $(5))_$(strip $(6)).xml'; \
	echo \<testsuite\> > $$JUnitFile; \
	echo \<testcase classname=\"$(FOLDER)_$(strip $(5))\" name=\"$(strip $(6))\" time=\"$$DIFF\" \> >> $$JUnitFile; \
	echo -n "$(strip $(4)) [$(HL)$(CURDIR)/$(strip $(2))$(NC)]"; \
	if [ $$ERR = 0 ]; then \
		echo " $(GREEN)OK$(NC)"; \
		echo \<passed\/\> >> $$JUnitFile; \
		echo '' > $(CURDIR)/runs/$(strip $(5))/system_good.tmp; \
	else \
		echo " $(RED)FAILED$(NC)"; \
		echo "For details see $(HL)$(CURDIR)/$(strip $(2))$(NC)"; \
		echo ""; \
		echo \<failure\> >> $$JUnitFile; \
		echo "$$ERRS" >>  $$JUnitFile; \
		echo \<\/failure\> >> $$JUnitFile; \
	fi; \
	echo \<\/testcase\> >> $$JUnitFile; \
	echo \<\/testsuite\> >> $$JUnitFile; \
	exit $$ERR); \
else \
	echo -n "$(strip $(4)) [$(HL)$(CURDIR)/$(strip $(2))$(NC)]"; \
	echo " $(HL)SKIPPED$(NC)"; \
fi;
endef

# For Cygwin, Vivado must be called from the Windows environment
ifeq ($(OS), Windows_NT)
CMD_PRE = cmd /C "
CMD_POST = "
RUN_SIM_PATH = $(shell cygpath -m $(ADI_HDL_DIR)/testbenches/scripts/run_sim.tcl)
else
CMD_PRE =
CMD_POST =
RUN_SIM_PATH = $(ADI_HDL_DIR)/testbenches/scripts/run_sim.tcl
endif

# This rule template will build the environment
# $(1): configuration name
define build
$(addprefix runs/,$(1)/system_project.log) : $(addprefix cfgs/,$(1).tcl) $(ENV_DEPS)
	-rm -rf $(addprefix runs/,$(1))
	mkdir -p runs
	mkdir -p $(addprefix runs/,$(1))
	mkdir -p results
	$(RUN_PRE_OPT)$$(call simulate, \
		$(CMD_PRE) $(M_VIVADO_BATCH) system_project.tcl -tclargs $(1).tcl $(CMD_POST), \
		$$@, \
		Building $(HL)$(strip $(1))$(NC) env, \
		Build $(HL)$(strip $(1))$(NC) env, \
		$(1), \
		BuildEnv)
endef

# This rule template will run the simulation
# $(1): configuration name
# $(2): test name
define sim
$(1) += $(addprefix runs/,$(addprefix $(1)/,$(2).log))
$(addprefix runs/,$(addprefix $(1)/,$(2).log)): $(addprefix runs/,$(1)/system_project.log) $(addprefix tests/,$(2).sv) $(SV_DEPS) FORCE
	$(RUN_PRE_OPT)$$(call simulate, \
		$(CMD_PRE) flock runs/$(1)/.lock sh -c "$(M_VIVADO) $(RUN_SIM_PATH) -tclargs $(1) $(2) $(MODE) $(CMD_POST)", \
		$$@, \
		Running $(HL)$(strip $(2))$(NC) test on $(HL)$(strip $(1))$(NC) env, \
		Run $(HL)$(strip $(2))$(NC) test on $(HL)$(strip $(1))$(NC) env, \
		$(1), \
		$(2))
FORCE:
endef

# Run an arbitrary test on an arbitrary configuration by taking
# the values from the command line and overwriting the target goal
ifneq ($(CFG),)
ifneq ($(TST),)
TESTS += $(CFG):$(TST)
.DEFAULT_GOAL := runs/$(CFG)/$(TST).log
endif
endif

MODE ?= batch

STOP_ON_ERROR ?= y

ifeq ($(STOP_ON_ERROR), y)
	RUN_PRE_OPT =
else
	RUN_PRE_OPT = -
endif

M_VIVADO := vivado -nolog -nojournal -mode ${MODE} -source
M_VIVADO_BATCH := vivado -nolog -nojournal -mode batch -source

BUILD_CFGS =
# Extract the list of configurations
$(foreach cfg_test, $(TESTS),\
	$(eval cfg = $(word 1,$(subst :, ,$(cfg_test)))) \
	$(eval BUILD_CFGS += $(cfg))\
)
# Make list unique
BUILD_CFGS := $(sort $(BUILD_CFGS))

.PHONY: all clean $(BUILD_CFGS)

all: $(BUILD_CFGS) 

clean:
	-rm -rf runs
	-rm -rf results
	-rm -rf vivado*

# Create here the targets which build the libraries
$(HDL_LIBRARY_PATH)%/component.xml: TARGET:=xilinx
FORCE:
$(HDL_LIBRARY_PATH)%/component.xml: FORCE
	flock $(dir $@).lock sh -c " \
	$(MAKE) -C $(dir $@) $(TARGET); \
	"; exit $$?

# Create here the targets which build the sim libraries
$(ADI_HDL_DIR)/testbenches/common/sv/%/component.xml: TARGET:=xilinx
FORCE:
$(ADI_HDL_DIR)/testbenches/common/sv/%/component.xml: FORCE
	flock $(dir $@).lock -c " \
	$(MAKE) -C $(dir $@) xilinx; \
	"; exit $$?

# Create here the targets which build the test env
$(foreach cfg, $(BUILD_CFGS), $(eval $(call build, $(cfg))))

# Create here the targets which run the actual simulations
# TESTS format:  <configuration>:<test name>
$(foreach cfg_test, $(TESTS),\
	$(eval cfg = $(strip $(word 1,$(subst :, ,$(cfg_test))))) \
	$(eval test = $(strip $(word 2,$(subst :, ,$(cfg_test))))) \
	$(eval $(call sim,$(cfg),$(test))) \
)

# Group sim targets based on env config so we can run easily all test 
# from one configuration 
# e.g "make cfg1"  will run all tests associated to that configuration
$(foreach cfg, $(BUILD_CFGS),\
	$(eval $(cfg): $($(cfg))) \
)

