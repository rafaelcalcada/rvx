.PHONY: all run clean

all:
	vivado -nojournal -nolog -mode batch -source create_test_project.tcl

run:
	vivado -nojournal -nolog -mode batch -source run_simulation.tcl

clean:
	rm -rf .Xil rvx_spi_manager_tests vivado*.log vivado*.jou vivado*.zip