# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

.PHONY: all clean

all:
	@$(MAKE) -C freertos/
	@$(MAKE) -C gpio/
	@$(MAKE) -C hello_world/
	@$(MAKE) -C i2c/
	@$(MAKE) -C spi/
	@$(MAKE) -C timer/
	@$(MAKE) -C uart/

clean:
	@$(MAKE) -C freertos/ clean
	@$(MAKE) -C gpio/ clean
	@$(MAKE) -C hello_world/ clean
	@$(MAKE) -C i2c/ clean
	@$(MAKE) -C spi/ clean
	@$(MAKE) -C timer/ clean
	@$(MAKE) -C uart/ clean