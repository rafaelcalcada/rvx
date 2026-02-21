# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

# The path below assumes this Makefile will be run from tests/compliance/
RVX_SIMULATOR_PATH = ../../simulator/

.PHONY: all build run clean

all: build run

run:
	python3 run_tests.py

build:
	$(MAKE) -C ${RVX_SIMULATOR_PATH} -j$(nproc)
	$(MAKE) -C riscv_tests/ all -j$(nproc)

clean:
	-rm -rf test_output
	@echo "RISC-V Tests results removed."

clean-all: clean
	$(MAKE) -C ${RVX_SIMULATOR_PATH} clean
	$(MAKE) -C riscv_tests/ clean