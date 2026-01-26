.PHONY: all clean

QUIET = $(if $(findstring s,$(MAKEFLAGS)),--quiet)

all:
	@echo "Building RVX SPI Manager testbench..."
	verilator -f verilator_args.vc --cc --exe --build rvx_spi_manager_tb.c --Mdir verilated -o rvx_spi_manager_tb rvx_spi_manager_tb.v $(QUIET)
	./verilated/rvx_spi_manager_tb

clean:
	rm -rf verilated
	@echo "RVX SPI Manager testbench build artifacts removed."