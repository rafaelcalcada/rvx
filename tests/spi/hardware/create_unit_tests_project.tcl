cd [file normalize [file dirname [info script]]]
create_project vivado_project ./vivado_project -part xc7a35ticsg324-1L -force
set_property simulator_language Verilog [current_project]
set_property include_dirs [file normalize ../../../rtl] [get_filesets sim_1]
add_files -norecurse {./unit_tests.v ../../../rtl/rvx_constants.vh ../../../rtl/peripherals/rvx_spi_manager.v }
move_files -fileset sim_1 [get_files ./unit_tests.v]
set_property used_in_simulation true [get_files  ../../../rtl/rvx_constants.vh]