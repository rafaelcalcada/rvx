.PHONY: all run clean

all:
	verilator -f verilator_args.vc --cc --exe --build rvx_uart_tb.c --Mdir verilated -o rvx_uart_tb ../rvx_uart_tb.v

run: all
	./verilated/rvx_uart_tb

clean:
	@rm -rf verilated 
	@echo "Cleaned up generated files."