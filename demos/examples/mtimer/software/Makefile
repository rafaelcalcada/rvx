# -------------------------------------------------------------------------------------------------
# Copyright (c) 2020-2024 RISC-V Steel contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# -------------------------------------------------------------------------------------------------

# Configure your project by setting the variables below
# -------------------------------------------------------------------------------------------------

# Name of the program to be created
PROGRAM_NAME      ?= mtimer
# Memory size (must be set to the same value of the MEMORY_SIZE parameter of rvsteel_soc module)
MEMORY_SIZE       ?= 8192
# Path to RISC-V Steel System-on-Chip API
RVSTEEL_API_DIR   ?= ../../../../software/api
# The full path to RISC-V GNU Toolchain binaries in this machine + RISC-V binaries prefix
RISCV_PREFIX      ?= /opt/riscv/bin/riscv32-unknown-elf-

# Other variables (do not edit)
# -------------------------------------------------------------------------------------------------

# Compiler binary
RISCV_GCC         ?= ${RISCV_PREFIX}gcc
# Object dump binary
RISCV_OBJDUMP     ?= ${RISCV_PREFIX}objdump
# Object copy binary
RISCV_OBJCOPY     ?= ${RISCV_PREFIX}objcopy
# Path to linker script
LINKER_SCRIPT     = link.ld
# Generated ELF name
ELF_NAME          = $(PROGRAM_NAME).elf
# Generated object dump file name
OBJDUMP_NAME      = $(PROGRAM_NAME).objdump
# Generated hexdump file name
HEXDUMP_NAME      = $(PROGRAM_NAME).hex
# List with source file names
SRC_FILES         := $(wildcard *.c)
# List with object file names
OBJ_FILES         := $(patsubst %.c,build/obj/%.o,$(SRC_FILES))

# Compiler options:
# --------------------------------------------------------------------------------------------
# -march=rv32izicsr           RISC-V extensions present in RISC-V Steel (RV32I and Zicsr)
# -mabi=ilp32                 ABI used (32-bit with soft floating point)
# -nostartfiles               Do not link with standard startup code
# -nostdlib                   Do not link with standard libraries
# -nolibc                     Do not link with the standard C library
# -nodefaultlibs              Do not link with default libs
# -mstrict-align              Do not generate unaligned addresses
# -O2                         Set optimization level to 2
COMPILER_OPTIONS  ?=  -march=rv32izicsr -mabi=ilp32 -nostartfiles -nostdlib \
                      -nolibc -nodefaultlibs -mstrict-align -O2             \

# Basic checks: test whether the API and the required binaries are available
# --------------------------------------------------------------------------------------------

ifeq (,$(wildcard $(RVSTEEL_API_DIR)/rvsteel_api.h))
  $(error Could not find RISC-V Steel API files in '$(RVSTEEL_API_DIR)'. Please fix the \
          RVSTEEL_API_DIR variable in the Makefile)
endif

# Test whether it can find GCC binary
ifeq (, $(shell which ${RISCV_GCC}))
  $(error Could not find RISC-V GCC binary at '${RISCV_GCC}'. Please change RISCV_PREFIX  \
          in the Makefile)
endif

# Test whether it can find objdump binary
ifeq (, $(shell which ${RISCV_OBJDUMP}))
  $(error Could not find RISC-V objdump binary at '${RISCV_OBJDUMP}'. Please change       \
          RISCV_PREFIX in the Makefile)
endif

# Test whether it can find objcopy binary
ifeq (, $(shell which ${RISCV_OBJCOPY}))
  $(error Could not find RISC-V objcopy binary at '${RISCV_OBJCOPY}'. Please change       \
          RISCV_PREFIX in the Makefile)
endif

# Targets
# --------------------------------------------------------------------------------------------

all: mkdir_build rvsteel_api $(OBJ_FILES)
	@$(RISCV_GCC) -T ${LINKER_SCRIPT} ${COMPILER_OPTIONS} \
                   $(OBJ_FILES) build/obj/rvsteel_api.o -o build/${ELF_NAME}
	@${RISCV_OBJDUMP} -D build/${ELF_NAME} > build/${OBJDUMP_NAME}
	@${RISCV_OBJCOPY} build/${ELF_NAME} -O verilog --verilog-data-width=4 build/${HEXDUMP_NAME}
	@echo "\nBuild successful.\n\nGenerated files:"
	@echo "-- ELF executable   : build/${ELF_NAME}"
	@echo "-- Disassembly      : build/${OBJDUMP_NAME}"
	@echo "-- Memory init file : build/${HEXDUMP_NAME}"
	@echo "\nThe memory size is set to $(MEMORY_SIZE) bytes.\n"

mkdir_build:
	@mkdir -p build/obj/

rvsteel_api: $(RVSTEEL_API_DIR)/rvsteel_api.c
	@$(RISCV_GCC) -I ${RVSTEEL_API_DIR} ${COMPILER_OPTIONS} \
                -D MEMORY_SIZE=\"$(MEMORY_SIZE)\" -c -o build/obj/rvsteel_api.o $(RVSTEEL_API_DIR)/rvsteel_api.c

build/obj/%.o: %.c
	@$(RISCV_GCC) -I ${RVSTEEL_API_DIR} ${COMPILER_OPTIONS} -c -o $@ $<

clean:
	@rm -rf build/
	@echo "Build directory (./build) removed."