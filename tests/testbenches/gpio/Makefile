.PHONY: all clean

QUIET = $(if $(findstring s,$(MAKEFLAGS)),--quiet)

all:
	@echo "Building RVX GPIO testbench..."
	verilator -f verilator_args.vc --cc --exe --build rvx_gpio_tb.c --Mdir verilated -o rvx_gpio_tb rvx_gpio_tb.v $(QUIET)
	./verilated/rvx_gpio_tb

clean:
	rm -rf verilated
	@echo "RVX GPIO testbench build artifacts removed."