# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

.PHONY: all clean

all:
	@$(MAKE) -C testbench/gpio
	@$(MAKE) -C testbench/spi_manager
	@$(MAKE) -C testbench/uart
	@$(MAKE) -C testbench/timer
	@$(MAKE) -C riscv_compliance
	@$(MAKE) -C hal

clean:
	@$(MAKE) -C testbench/gpio clean
	@$(MAKE) -C testbench/spi_manager clean
	@$(MAKE) -C testbench/uart clean
	@$(MAKE) -C testbench/timer clean
	@$(MAKE) -C riscv_compliance clean-all
	@$(MAKE) -C hal clean-all