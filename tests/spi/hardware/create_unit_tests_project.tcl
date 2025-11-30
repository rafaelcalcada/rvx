cd [file normalize [file dirname [info script]]]
create_project vivado_project ./vivado_project -part xc7a35ticsg324-1L -force
set_property simulator_language Verilog [current_project]
add_files -norecurse {./unit_tests.v ../../../rtl/rvx_spi.v }
move_files -fileset sim_1 [get_files ./unit_tests.v]