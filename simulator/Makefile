# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

.PHONY: all run clean

all:
	verilator -f verilator_args.vc verilator_config.vlt rvx_simulator.v rvx_simulator.cpp argparse.cpp ram_init.cpp -o rvx_simulator

run: all
	python3 unit_tests.py

clean:
	-rm -rf verilated memory_dump *.log *.dmp *.vpd
