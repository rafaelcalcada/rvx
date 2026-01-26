.PHONY: all clean

QUIET = $(if $(findstring s,$(MAKEFLAGS)),--quiet)

all:
	@echo "Building RVX UART testbench..."
	verilator -f verilator_args.vc --cc --exe --build rvx_uart_tb.c --Mdir verilated -o rvx_uart_tb rvx_uart_tb.v $(QUIET)
	./verilated/rvx_uart_tb

clean:
	rm -rf verilated
	@echo "RVX UART testbench build artifacts removed."