.PHONY: all clean

QUIET = $(if $(findstring s,$(MAKEFLAGS)),--quiet)

all:
	@echo "Building RVX SPI testbench..."
	verilator -f verilator_args.vc --cc --exe --build rvx_spi_tb.c --Mdir verilated -o rvx_spi_tb rvx_spi_tb.v $(QUIET)
	./verilated/rvx_spi_tb

clean:
	rm -rf verilated
	@echo "RVX SPI testbench build artifacts removed."