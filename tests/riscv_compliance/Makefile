# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

# The path below assumes this Makefile will be run from the RVX development container
RVX_SIMULATOR_PATH = /workspaces/rvx/simulator/

.PHONY: all run clean

all: build
	python3 run_tests.py --wave

build:
	$(MAKE) -C ${RVX_SIMULATOR_PATH} -j$(nproc)
	$(MAKE) -C riscv_test_suite/ all -j$(nproc)

clean:
	$(MAKE) -C ${RVX_SIMULATOR_PATH} clean
	$(MAKE) -C riscv_test_suite/ clean
	-rm -rf test_output
