cd [file normalize [file dirname [info script]]]
create_project rvx_spi_manager_tests ./rvx_spi_manager_tests -part xc7a35ticsg324-1L -force
set_property simulator_language Verilog [current_project]
set_property include_dirs "[file normalize ../../../rtl] [file normalize ../../../tests]" [get_filesets sim_1]
add_files -norecurse ../rvx_spi_manager_tb.v
add_files -norecurse ../../../rtl/peripherals/rvx_spi_manager.v
add_files -norecurse ../../../rtl/rvx_constants.vh
add_files -norecurse ../../../tb/rvx_test_macros.vh
move_files -fileset sim_1 [get_files ../rvx_spi_manager_tb.v]
move_files -fileset sim_1 [get_files ../../../tb/rvx_test_macros.vh]
set_property used_in_simulation true [get_files  ../../../rtl/rvx_constants.vh]
set_property used_in_simulation true [get_files  ../../../tb/rvx_test_macros.vh]
set_property -name xsim.elaborate.xelab.more_options -value "--timescale 1ns/1ps" -object [get_filesets sim_1]