.PHONY: all run clean

all:
	verilator -f verilator_args.vc --cc --exe --build rvx_timer_tb.c --Mdir verilated -o rvx_timer_tb ../rvx_timer_tb.v

run: all
	./verilated/rvx_timer_tb

clean:
	@rm -rf verilated 
	@echo "Cleaned up generated files."