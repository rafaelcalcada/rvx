# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

.PHONY: all clean

all:
	$(MAKE) -C testbenches/gpio
	$(MAKE) -C testbenches/spi
	$(MAKE) -C testbenches/uart
	$(MAKE) -C testbenches/timer
	$(MAKE) -C testbenches/i2c
	$(MAKE) -C compliance
	$(MAKE) -C api

clean:
	$(MAKE) -C testbenches/gpio clean
	$(MAKE) -C testbenches/spi clean
	$(MAKE) -C testbenches/uart clean
	$(MAKE) -C testbenches/timer clean
	$(MAKE) -C testbenches/i2c clean
	$(MAKE) -C compliance clean-all
	$(MAKE) -C api clean-all