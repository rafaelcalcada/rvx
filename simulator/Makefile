# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

REDIRECT = $(if $(findstring s,$(MAKEFLAGS)),> /dev/null 2>&1, )
QUIET = $(if $(findstring s,$(MAKEFLAGS)),--log-level=NOTICE, )

SIMULATOR_SOURCES := $(shell find include source -type f 2>/dev/null)
RTL_SOURCES := $(shell find ../rtl -type f 2>/dev/null)

.PHONY: all install clean

all: build

build: $(SIMULATOR_SOURCES) $(RTL_SOURCES)
	test -d build || mkdir -p build
	@echo "Building RVX Simulator..."
	cmake -B build -DCMAKE_BUILD_TYPE=Release ${QUIET} ${REDIRECT}
	cmake --build build -j$(nproc) ${REDIRECT}

install: build
	@echo "Installing RVX Simulator at ${HOME}/.local..."
	cd build && cmake --install . --prefix ${HOME}/.local ${REDIRECT}

clean:
	-rm -rf build verilated
	@echo "RVX Simulator build artifacts removed."
