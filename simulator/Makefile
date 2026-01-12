# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

.PHONY: all build install clean

all: build

build:
	@test -d build || mkdir -p build
	@cmake -B build --log-level=NOTICE -DCMAKE_BUILD_TYPE=Release
	@cmake --build build -j$(nproc)

install: build
	@cd build && cmake --install . --prefix ${HOME}/.local

clean:
	@-rm -rf build verilated
	@echo "RVX Simulator build artifacts cleaned."
