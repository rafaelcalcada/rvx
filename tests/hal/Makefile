# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory
RVX_SIMULATOR_PATH = ../../simulator/verilated/rvx_simulator

all: ${RVX_SIMULATOR_PATH}
	@test -d build || ( mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Debug .. )
	@$(MAKE) -C build
	${RVX_SIMULATOR_PATH} --log-level=QUIET --ram-init-h32=build/rvx_hal_tests.hex --ram-dump-h32=rvx_hal_test_memdump.hex --cycles=1000000 --wr-addr=0x00000000

${RVX_SIMULATOR_PATH}:
	$(MAKE) -C ../../simulator/ -j$(nproc)

clean:
	$(MAKE) -C ../../simulator/ clean
	@rm -rf build
	@echo "Build directory deleted."

.PHONY: all clean

again: clean all