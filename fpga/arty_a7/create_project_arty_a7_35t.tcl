cd [file normalize [file dirname [info script]]]
create_project rvx_arty_a7_35t ./rvx_arty_a7_35t -part xc7a35ticsg324-1L -force

set_msg_config -suppress -id {Synth 8-7080}
set_msg_config -suppress -id {Power 33-332}
set_msg_config -suppress -id {Pwropt 34-321}
set_msg_config -suppress -id {Synth 8-6841}
set_msg_config -suppress -id {Netlist 29-101}
set_msg_config -suppress -id {Device 21-9320}
set_msg_config -suppress -id {Device 21-2174}

set_property simulator_language Verilog [current_project]

add_files -fileset constrs_1 -norecurse { ./rvx_arty_a7_constraints.xdc }
add_files -norecurse { rvx_arty_a7.v }
add_files -norecurse { ../../rtl/rvx_constants.vh }
add_files -norecurse { ../../rtl/rvx.v }
add_files -norecurse { ../../rtl/core/rvx_core.v }
add_files -norecurse { ../../rtl/core/rvx_core_address_gen.v }
add_files -norecurse { ../../rtl/core/rvx_core_alu.v }
add_files -norecurse { ../../rtl/core/rvx_core_branch.v }
add_files -norecurse { ../../rtl/core/rvx_core_bus_controller.v }
add_files -norecurse { ../../rtl/core/rvx_core_csr_file.v }
add_files -norecurse { ../../rtl/core/rvx_core_decoder.v }
add_files -norecurse { ../../rtl/core/rvx_core_immediate_gen.v }
add_files -norecurse { ../../rtl/core/rvx_core_integer_file.v }
add_files -norecurse { ../../rtl/core/rvx_core_load_unit.v }
add_files -norecurse { ../../rtl/core/rvx_core_pc_gen.v }
add_files -norecurse { ../../rtl/core/rvx_core_state.v }
add_files -norecurse { ../../rtl/core/rvx_core_store_unit.v }
add_files -norecurse { ../../rtl/core/rvx_core_trap.v }
add_files -norecurse { ../../rtl/interconnect/rvx_interconnect.v }
add_files -norecurse { ../../rtl/memory/rvx_tightly_coupled_memory.v }
add_files -norecurse { ../../rtl/peripherals/rvx_gpio.v }
add_files -norecurse { ../../rtl/peripherals/rvx_timer.v }
add_files -norecurse { ../../rtl/peripherals/rvx_spi_manager.v }
add_files -norecurse { ../../rtl/peripherals/rvx_uart.v }

if { [file exists ../../examples/hello_world/build/rvx_hello_world.mem] } {
    add_files -norecurse { ../../examples/hello_world/build/rvx_hello_world.mem }
    set_property file_type {Memory File} [get_files ../../examples/hello_world/build/rvx_hello_world.mem]
}