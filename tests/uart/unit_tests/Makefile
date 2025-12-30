# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2025 RVX Project Contributors

MAKEFLAGS += --no-print-directory

ifdef TOOLCHAIN_PREFIX
TOOLCHAIN_PREFIX_FLAG = -DTOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX}
endif

ifdef PREFIX
TOOLCHAIN_PREFIX_FLAG = -DTOOLCHAIN_PREFIX="${PREFIX}/bin/riscv32-unknown-elf-"
endif

all: 
	@test -d build || ( mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Debug ${TOOLCHAIN_PREFIX_FLAG} .. )
	@$(MAKE) -C build

clean:
	@rm -rf build dump .Xil uart_unit_tests
	@echo "Build directory and Vivado project deleted."

.PHONY: debug release clean
