# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

.PHONY: all run clean

all:
	$(MAKE) -C ../../../simulator/

run: all
	python3 unit_tests.py

clean:
	$(MAKE) -C ../../../simulator/ clean
	-rm -rf memory_dump
