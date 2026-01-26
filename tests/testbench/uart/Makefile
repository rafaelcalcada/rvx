.PHONY: all clean

all:
	@echo "Building RVX UART testbench..."
	@verilator -f verilator_args.vc --cc --exe --build rvx_uart_tb.c --Mdir verilated -o rvx_uart_tb rvx_uart_tb.v --quiet-build
	./verilated/rvx_uart_tb

clean:
	@rm -rf verilated
	@echo "RVX UART testbench build artifacts cleaned."