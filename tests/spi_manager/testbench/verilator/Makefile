.PHONY: all run clean

all:
	verilator -f verilator_args.vc --cc --exe --build rvx_spi_manager_tb.c --Mdir verilated -o rvx_spi_manager_tb ../rvx_spi_manager_tb.v

run: all
	./verilated/rvx_spi_manager_tb

clean:
	@rm -rf verilated
	@echo "Cleaned up generated files."