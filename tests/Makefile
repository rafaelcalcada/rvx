# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

.PHONY: all clean

all:
	@$(MAKE) -C testbench/gpio/verilator run
	@$(MAKE) -C testbench/spi_manager/verilator run
	@$(MAKE) -C testbench/uart/verilator run
	@$(MAKE) -C testbench/timer/verilator run
	@$(MAKE) -C riscv_compliance
	@$(MAKE) -C hal

clean:
	@$(MAKE) -C testbench/gpio/verilator clean
	@$(MAKE) -C testbench/spi_manager/verilator clean
	@$(MAKE) -C testbench/uart/verilator clean
	@$(MAKE) -C testbench/timer/verilator clean
	@$(MAKE) -C riscv_compliance clean-all
	@$(MAKE) -C hal clean-all