# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

.PHONY: all clean

all:
	$(MAKE) -C testbenches/gpio
	$(MAKE) -C testbenches/spi_manager
	$(MAKE) -C testbenches/uart
	$(MAKE) -C testbenches/timer
	$(MAKE) -C compliance
	$(MAKE) -C hal

clean:
	$(MAKE) -C testbenches/gpio clean
	$(MAKE) -C testbenches/spi_manager clean
	$(MAKE) -C testbenches/uart clean
	$(MAKE) -C testbenches/timer clean
	$(MAKE) -C compliance clean-all
	$(MAKE) -C hal clean-all