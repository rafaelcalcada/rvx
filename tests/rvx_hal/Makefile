# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

# The path below assumes this Makefile will be run from the RVX development container
RVX_SIMULATOR_PATH = /workspaces/rvx/simulator/

all: simulator
	@test -d build || ( mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Debug .. )
	@$(MAKE) -C build
	${RVX_SIMULATOR_PATH}/build/rvx_simulator build/rvx_hal_tests.hex --quiet --dump=rvx_hal_test_memdump.hex --max-cycles=1000000

simulator:
	$(MAKE) -C ${RVX_SIMULATOR_PATH} -j$(nproc)

clean:
	$(MAKE) -C ${RVX_SIMULATOR_PATH} clean
	@rm -rf build
	@echo "Build directory deleted."

again: clean all

.PHONY: all clean simulator
