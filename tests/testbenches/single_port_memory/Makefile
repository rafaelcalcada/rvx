.PHONY: all clean

QUIET = $(if $(findstring s,$(MAKEFLAGS)),--quiet)

all:
	@echo "Building RVX single-port memory testbench..."
	verilator -f verilator_args.vc --cc --exe --build rvx_single_port_memory_tb.c --Mdir verilated -o rvx_single_port_memory_tb rvx_single_port_memory_tb.v $(QUIET)
	./verilated/rvx_single_port_memory_tb

clean:
	rm -rf verilated
	@echo "RVX single-port memory testbench build artifacts removed."