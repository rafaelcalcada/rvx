# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

.PHONY: all build clean

all: build

build:
	@test -d build || mkdir -p build
	@cmake -B build --log-level=NOTICE -DCMAKE_BUILD_TYPE=Release
	@cmake --build build -j$(nproc)

clean:
	@rm -rf build
	@echo "SPI Manager example application build artifacts deleted."
