.PHONY: all clean

all:
	@echo "Building RVX Timer testbench..."
	@verilator -f verilator_args.vc --cc --exe --build rvx_timer_tb.c --Mdir verilated -o rvx_timer_tb rvx_timer_tb.v --quiet-build
	./verilated/rvx_timer_tb

clean:
	@rm -rf verilated
	@echo "RVX Timer testbench build artifacts cleaned."