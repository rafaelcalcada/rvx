# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

.PHONY: all run clean

all:
	@test -d build || mkdir -p build
	cmake -B build --log-level=NOTICE -DCMAKE_BUILD_TYPE=Release
	cmake --build build -j$(nproc)

clean:
	-rm -rf build verilated memory_dump *.log *.dmp *.vpd
