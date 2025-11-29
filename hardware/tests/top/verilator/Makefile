# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2025 RVX Project Contributors

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
