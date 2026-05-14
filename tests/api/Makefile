# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

REDIRECT = $(if $(findstring s,$(MAKEFLAGS)),> /dev/null 2>&1, )
QUIET = $(if $(findstring s,$(MAKEFLAGS)),--log-level=NOTICE, )

.PHONY: all run clean clean-all simulator

# The path below assumes this Makefile will be run from tests/hal/
RVX_SIMULATOR_PATH = ../../simulator/

all: simulator tests run

tests:
	test -d build || mkdir -p build
	cmake -B build -DCMAKE_BUILD_TYPE=Debug ${QUIET} ${REDIRECT}
	cmake --build build -j$(nproc) ${REDIRECT}

run:
	@test -f ${RVX_SIMULATOR_PATH}/build/rvx_simulator || { echo "rvx_simulator not found. Run 'make simulator' first."; exit 1; }
	@test -f build/rvx_hal_tests.mem || { echo "rvx_hal_tests.mem not found. Run 'make tests' to build the tests first."; exit 1; }
	${RVX_SIMULATOR_PATH}/build/rvx_simulator build/rvx_hal_tests.mem --max-cycles=10000000

simulator:
	$(MAKE) -C ${RVX_SIMULATOR_PATH} -j$(nproc)

clean:
	rm -rf build
	@echo "RVX HAL tests artifacts removed."

clean-all: clean
	$(MAKE) -C ${RVX_SIMULATOR_PATH} clean