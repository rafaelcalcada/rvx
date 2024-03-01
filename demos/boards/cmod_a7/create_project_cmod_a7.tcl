cd [file normalize [file dirname [info script]]]
create_project hello_world_cmod_a7_35t ./hello_world_cmod_a7_35t -part xc7a35tcpg236-1 -force
set_msg_config -suppress -id {Synth 8-7080}
set_msg_config -suppress -id {Power 33-332}
set_property simulator_language Verilog [current_project]
add_files -fileset constrs_1 -norecurse { ../../examples/hello_world/hardware/hello_world_cmod_a7_constraints.xdc }
add_files -norecurse { ../../examples/hello_world/hardware/hello_world_cmod_a7.v ../../../hardware/core/rvsteel_core.v ../../../hardware/ram/rvsteel_ram.v ../../../hardware/soc/rvsteel_soc.v ../../../hardware/bus/rvsteel_bus.v ../../../hardware/uart/rvsteel_uart.v ../../examples/hello_world/software/build/hello_world.hex }
set_property file_type {Memory Initialization Files} [get_files ../../examples/hello_world/software/build/hello_world.hex]