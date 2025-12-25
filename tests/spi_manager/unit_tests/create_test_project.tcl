cd [file normalize [file dirname [info script]]]

# Check if the memory initialization file exists
if {![file exists "./build/spi_manager_unit_tests.hex"]} {
  send_msg_id "RVX-001" ERROR "Memory initialization file 'spi_manager_unit_tests.hex' does not exist. This file needs to be generated to run the unit tests." -continue
  puts "Tip: To generate this file, run 'make' from the tests/spi_manager/unit_tests directory (from RVX development container)."
  return
}

set memory_init_files {./build/spi_manager_unit_tests.hex}
create_project spi_manager_unit_tests ./spi_manager_unit_tests -part xc7a35ticsg324-1L -force
set_property simulator_language Verilog [current_project]
add_files -fileset constrs_1 -norecurse { ./arty_a7_35t_constraints.xdc }
add_files -norecurse $memory_init_files
add_files -norecurse { ../../../rtl/rvx_constants.vh }
add_files -norecurse { ../../../rtl/rvx_ocelot.v }
add_files -norecurse { ../../../rtl/core/rvx_core.v }
add_files -norecurse { ../../../rtl/core/rvx_core_address_gen.v }
add_files -norecurse { ../../../rtl/core/rvx_core_alu.v }
add_files -norecurse { ../../../rtl/core/rvx_core_branch.v }
add_files -norecurse { ../../../rtl/core/rvx_core_bus_controller.v }
add_files -norecurse { ../../../rtl/core/rvx_core_csr_file.v }
add_files -norecurse { ../../../rtl/core/rvx_core_decoder.v }
add_files -norecurse { ../../../rtl/core/rvx_core_immediate_gen.v }
add_files -norecurse { ../../../rtl/core/rvx_core_integer_file.v }
add_files -norecurse { ../../../rtl/core/rvx_core_load_unit.v }
add_files -norecurse { ../../../rtl/core/rvx_core_pc_gen.v }
add_files -norecurse { ../../../rtl/core/rvx_core_state.v }
add_files -norecurse { ../../../rtl/core/rvx_core_store_unit.v }
add_files -norecurse { ../../../rtl/core/rvx_core_trap.v }
add_files -norecurse { ../../../rtl/interconnect/rvx_bus.v }
add_files -norecurse { ../../../rtl/memory/rvx_tightly_coupled_memory.v }
add_files -norecurse { ../../../rtl/peripherals/rvx_gpio.v }
add_files -norecurse { ../../../rtl/peripherals/rvx_mtimer.v }
add_files -norecurse { ../../../rtl/peripherals/rvx_spi_manager.v }
add_files -norecurse { ../../../rtl/peripherals/rvx_uart.v }
add_files -norecurse { ./spi_manager_unit_tests.v }
set_property file_type {Memory Initialization Files} [get_files $memory_init_files]
set_msg_config -suppress -id {Synth 8-7080}
set_msg_config -suppress -id {Power 33-332}
set_msg_config -suppress -id {Pwropt 34-321}
set_msg_config -suppress -id {Synth 8-6841}
set_msg_config -suppress -id {Netlist 29-101}
set_msg_config -suppress -id {Device 21-9320} 
set_msg_config -suppress -id {Device 21-2174}