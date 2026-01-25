# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

.PHONY: all clean

all:
	@$(MAKE) -C ../tb/gpio/verilator run
	@$(MAKE) -C ../tb/spi_manager/verilator run
	@$(MAKE) -C ../tb/uart/verilator run
	@$(MAKE) -C ../tb/timer/verilator run
	@$(MAKE) -C riscv_compliance
	@$(MAKE) -C hal

clean:
	@$(MAKE) -C ../tb/gpio/verilator clean
	@$(MAKE) -C ../tb/spi_manager/verilator clean
	@$(MAKE) -C ../tb/uart/verilator clean
	@$(MAKE) -C ../tb/timer/verilator clean
	@$(MAKE) -C riscv_compliance clean-all
	@$(MAKE) -C hal clean-all