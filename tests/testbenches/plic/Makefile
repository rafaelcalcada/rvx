.PHONY: all clean

QUIET = $(if $(findstring s,$(MAKEFLAGS)),--quiet)

all:
	@echo "Building RVX PLIC testbench..."
	verilator -f verilator_args.vc --cc --exe --build rvx_plic_tb.c --Mdir verilated -o rvx_plic_tb rvx_plic_tb.v $(QUIET)
	./verilated/rvx_plic_tb

clean:
	rm -rf verilated
	@echo "RVX PLIC testbench build artifacts removed."
