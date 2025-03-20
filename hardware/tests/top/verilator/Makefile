# ----------------------------------------------------------------------------
# Copyright (c) 2020-2025 RVX contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# ----------------------------------------------------------------------------

RUN_FLAGS ?= --log-level=QUIET --cycles=100
MAKEFLAGS += --no-print-directory

all: build

build:
	@cmake -B build -S .
	@cmake --build build

run: build
	@build/mcu_sim $(RUN_FLAGS)

clean:
	@rm -rf build
	@echo "Build directory deleted."

.PHONY: build run clean
