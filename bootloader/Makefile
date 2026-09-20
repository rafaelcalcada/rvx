# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

MAKEFLAGS += --no-print-directory

.PHONY: all build clean

RISCV_TOOLCHAIN_PREFIX ?= riscv32-unknown-elf-

CC      := $(RISCV_TOOLCHAIN_PREFIX)gcc
OBJCOPY := $(RISCV_TOOLCHAIN_PREFIX)objcopy
OBJDUMP := $(RISCV_TOOLCHAIN_PREFIX)objdump

BUILD_DIR := build
BUILD_DIR_STAMP := $(BUILD_DIR)/.dir.stamp

BOOTLOADER_SRC := rvx_bootloader.c
BOOTLOADER_ELF := $(BUILD_DIR)/rvx_bootloader.elf
BOOTLOADER_BIN := $(BUILD_DIR)/rvx_bootloader.bin
BOOTLOADER_DISASM := $(BUILD_DIR)/rvx_bootloader.disasm
BOOTLOADER_ROM_VERILOG := $(BUILD_DIR)/rvx_bootloader.v

CFLAGS := \
	-O3 \
	-DNDEBUG \
	-Wall \
	-Wextra \
	-Wpedantic \
	-mstrict-align \
	-ffreestanding \
	-fno-builtin \
	-ffunction-sections \
	-fdata-sections \
	-march=rv32i_zicsr \
	-mabi=ilp32 \
	-mno-relax

LDFLAGS := \
	-Wl,--gc-sections \
	-mstrict-align \
	-march=rv32i_zicsr \
	-mabi=ilp32 \
	-Wl,--no-warn-rwx-segments \
	-nostartfiles \
	-Trvx_bootloader.ld

all: build

build: $(BOOTLOADER_ELF) $(BOOTLOADER_DISASM) $(BOOTLOADER_ROM_VERILOG)
	@echo "Bootloader build completed:"
	@echo "  - ELF: $(BOOTLOADER_ELF)"
	@echo "  - Disassembly: $(BOOTLOADER_DISASM)"
	@echo "  - Verilog ROM snippet: $(BOOTLOADER_ROM_VERILOG)"

$(BUILD_DIR_STAMP):
	@mkdir -p $(BUILD_DIR)
	@touch $@

$(BOOTLOADER_ELF): $(BOOTLOADER_SRC) | $(BUILD_DIR_STAMP)
	@$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

$(BOOTLOADER_DISASM): $(BOOTLOADER_ELF)
	@$(OBJDUMP) -d $< > $@

$(BOOTLOADER_BIN): $(BOOTLOADER_ELF)
	@$(OBJCOPY) -O binary $< $@

$(BOOTLOADER_ROM_VERILOG): $(BOOTLOADER_BIN)
	@od -An -v -tx4 $< | awk '{for (i = 1; i <= NF; ++i) printf "    rom[%-3d] = 32\x27h%s;\n", n++, toupper($$i)}' > $@

clean:
	@rm -rf $(BUILD_DIR)
	@echo "Bootloader build artifacts deleted."
