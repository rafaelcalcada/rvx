# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

# Makefile

SIM ?= verilator
TOPLEVEL_LANG ?= verilog

# Or --trace-fst
EXTRA_ARGS ?= --trace

VERILOG_SOURCES += $(PWD)/../../rtl/rvx_mtimer.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = rvx_mtimer

# MODULE is the basename of the Python test file
MODULE = test_mtimer

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
