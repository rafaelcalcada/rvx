# ----------------------------------------------------------------------------
# Copyright (c) 2020-2024 RISC-V Steel contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# ----------------------------------------------------------------------------

VERILATOR       ?= verilator

# USER_CPPFLAGS   += -CFLAGS ""

VERILATOR_FLAGS += -cc --exe --build
VERILATOR_FLAGS += -Wall
VERILATOR_FLAGS += --trace-fst
VERILATOR_FLAGS += --default-language 1364-2001

VERILATOR_INPUT  = -f vargs.vc
VERILATOR_INPUT += soc_sim.v
VERILATOR_INPUT += vcfg.vlt
VERILATOR_INPUT += main.cpp
VERILATOR_INPUT += argparse.cpp
VERILATOR_INPUT += ram_init.cpp
VERILATOR_INPUT += -o soc_sim

RVSTEEL_ROOT    ?=../../../../
FIRMWARE        ?= $(RVSTEEL_ROOT)/demos/examples/hello_world/software/build/hello_world.hex

RUN_CMD= \
  @obj_dir/soc_sim --log-level=DEBUG --log-out=dump/soc_sim.log \
  --ram-init-h32=$(FIRMWARE) --out-wave=dump/wave.fst --freq-ns=20

default:
	@echo "BUILD"
	@$(VERILATOR)  $(VERILATOR_FLAGS) $(VERILATOR_INPUT) $(USER_CPPFLAGS)

run:
	@echo "RUN"
	@mkdir -p dump
	@$(RUN_CMD)

clean:
	-rm -rf obj_dir *.log *.dump *.vpd core dump *.vcd *.fst
