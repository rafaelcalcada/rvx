RV32_DIRS := $(wildcard rv32/*)
RV32_TESTS := $(foreach dir,$(RV32_DIRS),$(wildcard $(dir)/*.S))
RV32_TEST_NAMES := $(notdir $(RV32_TESTS:.S=))
RV32_ELFS := $(addprefix test_programs/,$(addsuffix .elf,$(RV32_TEST_NAMES)))
RV32_SIGNATURES := $(addprefix signatures/,$(addsuffix .signature,$(RV32_TEST_NAMES)))

RISCV_PREFIX ?= riscv32-unknown-elf-
CC := $(RISCV_PREFIX)gcc
AS := $(RISCV_PREFIX)as
OBJDUMP := $(RISCV_PREFIX)objdump
OBJCOPY := $(RISCV_PREFIX)objcopy

CFLAGS := -static -mcmodel=medany -g -fvisibility=hidden -nostdlib \
          -nostartfiles -DXLEN=32 $(RVTEST_DEFINES)                \
          -march=rv32imzicsr -mabi=ilp32 -nolibc -nodefaultlibs    \
          -mstrict-align -O2

.PHONY: clean

all: test_programs signatures

test_programs: $(RV32_ELFS)

signatures: $(RV32_SIGNATURES)

test_programs/%.elf: rv32/*/%.S
	mkdir -p test_programs
	$(if $(findstring privilege,$<), \
		$(CC) $(CFLAGS) -Drvtest_mtrap_routine=True -Iinclude/ $< -o $@ -T rvx.ld, \
		$(CC) $(CFLAGS) -Iinclude/ $< -o $@ -T rvx.ld)	  
	$(OBJCOPY) -O verilog --verilog-data-width=4 $@ $(@:.elf=.mem)
	$(OBJDUMP) --source $@ > $(@:.elf=.disasm)

signatures/%.signature: rv32/*/%.S
	mkdir -p signatures
	$(if $(findstring privilege,$<), \
		$(CC) $(CFLAGS) -Drvtest_mtrap_routine=True -Iinclude/ $< -o signatures/$*.elf -T spike.ld, \
		$(CC) $(CFLAGS) -Iinclude/ $< -o signatures/$*.elf -T spike.ld)
	$(OBJDUMP) --source signatures/$*.elf > signatures/$*.disasm
	spike --isa=rv32imzicsr -m0x2000:0x200000 +signature=$@ +signature-granularity=4 signatures/$*.elf

clean:
	rm -rf test_programs
	rm -rf signatures