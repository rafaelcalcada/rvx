# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2025 RVX Project Contributors

MAKEFLAGS += --no-print-directory

RUN_FLAGS  = "
RUN_FLAGS += --log-level=DEBUG
RUN_FLAGS += --ram-init-h32=$$PWD/build/mtimer_demo.hex
RUN_FLAGS += --out-wave=$$PWD/dump/wave.fst
RUN_FLAGS += --cycles=1000000
RUN_FLAGS += --freq-ns=20
RUN_FLAGS += "

ifdef TOOLCHAIN_PREFIX
TOOLCHAIN_PREFIX_FLAG = -DTOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX}
endif

all:
	@echo "\nUsage:\n\n  make <target>\n"
	@echo "Available targets:\n"
	@echo "  arty_debug\t\t Debug build for Digilent Arty A7 board"
	@echo "  cmod_debug\t\t Debug build for Digilent Cmod A7 board"
	@echo "  arty_release\t\t Release build for Digilent Arty A7 board"
	@echo "  cmod_release\t\t Release build for Digilent Cmod A7 board"
	@echo "  run_sim\t\t Run the built target on RVX MCU simulator"
	@echo "  clean\t\t\t Remove the build/ folder\n"

arty_debug:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Debug ${TOOLCHAIN_PREFIX_FLAG} -DCLOCK_FREQUENCY=50000000 ..
	$(MAKE) -C build

arty_release:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Release ${TOOLCHAIN_PREFIX_FLAG} -DCLOCK_FREQUENCY=50000000 ..
	$(MAKE) -C build

cmod_debug:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Debug ${TOOLCHAIN_PREFIX_FLAG} -DCLOCK_FREQUENCY=12000000 ..
	$(MAKE) -C build

cmod_release:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Release ${TOOLCHAIN_PREFIX_FLAG} -DCLOCK_FREQUENCY=12000000 ..
	$(MAKE) -C build

run_sim: all
	@mkdir -p dump
	@$(MAKE) -C ../../../hardware/tests/top/verilator/ run RUN_FLAGS=$(RUN_FLAGS)

clean:
	@rm -rf build dump
	@echo "Build directory deleted."

.PHONY: arty_debug arty_release cmod_debug cmod_release run_sim clean
