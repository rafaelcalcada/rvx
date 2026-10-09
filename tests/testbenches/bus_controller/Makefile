.PHONY: all clean

QUIET = $(if $(findstring s,$(MAKEFLAGS)),--quiet)

all:
	@echo "Building RVX core bus controller testbench..."
	verilator -f verilator_args.vc --trace-fst --cc --exe --build rvx_core_bus_controller_tb.c \
		--Mdir verilated -o rvx_core_bus_controller_tb rvx_core_bus_controller_tb.v $(QUIET)
	./verilated/rvx_core_bus_controller_tb

clean:
	rm -rf verilated rvx_core_bus_controller.fst
	@echo "RVX core bus controller testbench build artifacts removed."
