# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

.PHONY: all run clean clean-all simulator

# The path below assumes this Makefile will be run from the RVX development container
RVX_SIMULATOR_PATH = /workspaces/rvx/simulator/

all: simulator tests run

tests:
	@test -d build || mkdir -p build
	@cmake -B build --log-level=NOTICE -DCMAKE_BUILD_TYPE=Debug
	@cmake --build build -j$(nproc)

run:
	@test -f ${RVX_SIMULATOR_PATH}/build/rvx_simulator || { echo "rvx_simulator not found. Run 'make simulator' first."; exit 1; }
	@test -f build/rvx_hal_tests.mem || { echo "rvx_hal_tests.mem not found. Run 'make tests' to build the tests first."; exit 1; }
	@${RVX_SIMULATOR_PATH}/build/rvx_simulator build/rvx_hal_tests.mem

simulator:
	@$(MAKE) -C ${RVX_SIMULATOR_PATH} -j$(nproc)

clean:
	@rm -rf build
	@echo "RVX HAL tests artifacts deleted."

clean-all: clean
	@$(MAKE) -C ${RVX_SIMULATOR_PATH} clean

again: clean all

