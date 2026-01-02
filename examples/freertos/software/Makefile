# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

ifdef TOOLCHAIN_PREFIX
TOOLCHAIN_PREFIX_FLAG = -DTOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX}
endif

ifdef PREFIX
TOOLCHAIN_PREFIX_FLAG = -DTOOLCHAIN_PREFIX="${PREFIX}/bin/riscv32-unknown-elf-"
endif

all: debug

check_clock_is_defined:
ifndef CLOCK_FREQUENCY
	$(info Usage: make [debug|release] CLOCK_FREQUENCY=<freq_in_hertz>)
	$(error To build the FreeRTOS example you need to inform the clock frequency)
endif

debug: check_clock_is_defined
	@mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Debug ${TOOLCHAIN_PREFIX_FLAG} -DCLOCK_FREQUENCY=${CLOCK_FREQUENCY} ..
	@$(MAKE) -C build

release: check_clock_is_defined
	@mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Release ${TOOLCHAIN_PREFIX_FLAG} -DCLOCK_FREQUENCY=${CLOCK_FREQUENCY} ..
	@$(MAKE) -C build

clean:
	@rm -rf build dump
	@echo "Build directory deleted."

.PHONY: check_usage debug release clean
