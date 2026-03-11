.PHONY: all clean

QUIET = $(if $(findstring s,$(MAKEFLAGS)),--quiet)

all:
	@echo "Building RVX I2C testbench..."
	verilator -f verilator_args.vc --cc --exe --build rvx_i2c_tb.c --Mdir verilated -o rvx_i2c_tb rvx_i2c_tb.v $(QUIET)
	./verilated/rvx_i2c_tb

clean:
	rm -rf verilated
	@echo "RVX I2C testbench build artifacts removed."