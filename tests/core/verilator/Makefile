# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

.PHONY: all run clean

all:
	verilator -f verilator_args.vc verilator_config.vlt unit_tests.v main.cpp argparse.cpp ram_init.cpp -o unit_tests

run: all
	python3 unit_tests.py

clean:
	-rm -rf verilated memory_dump *.log *.dmp *.vpd
