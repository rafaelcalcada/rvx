# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

REDIRECT = $(if $(findstring s,$(MAKEFLAGS)),> /dev/null 2>&1, )
QUIET = $(if $(findstring s,$(MAKEFLAGS)),--log-level=NOTICE, )

.PHONY: all install clean

all: build

build: include/rvx_simulator_logger.h include/rvx_simulator_argparser.h source/rvx_simulator.cpp source/rvx_simulator_argparser.cpp source/rvx_simulator.v
	test -d build || mkdir -p build
	@echo "Building RVX Simulator..."
	cmake -B build -DCMAKE_BUILD_TYPE=Release ${QUIET} ${REDIRECT}
	cmake --build build -j$(nproc) ${REDIRECT}

install: build
	@echo "Installing RVX Simulator at ${HOME}/.local..."
	cd build && cmake --install . --prefix ${HOME}/.local ${REDIRECT}

clean:
	-rm -rf build verilated
	@echo "RVX Simulator build artifacts removed."
