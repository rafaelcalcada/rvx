# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

.PHONY: all run clean

all:
	$(MAKE) -C ../simulator/ -j$(nproc)
	$(MAKE) -C riscv_test_suite/ all -j$(nproc)

run: all
	python3 run_tests.py --wave

clean:
	$(MAKE) -C ../simulator/ clean
	$(MAKE) -C riscv_test_suite/ clean
	-rm -rf test_output
