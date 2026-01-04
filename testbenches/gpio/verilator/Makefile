.PHONY: all run clean

all:
	verilator -f verilator_args.vc --cc --exe --build rvx_gpio_tb.c --Mdir verilated -o rvx_gpio_tb ../rvx_gpio_tb.v

run: all
	./verilated/rvx_gpio_tb

clean:
	@rm -rf verilated 
	@echo "Cleaned up generated files."