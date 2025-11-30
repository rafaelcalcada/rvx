cd [file normalize [file dirname [info script]]]
create_project hello_world_cmod_a7_35t ./hello_world_cmod_a7_35t -part xc7a35tcpg236-1 -force
set_msg_config -suppress -id {Synth 8-7080}
set_msg_config -suppress -id {Power 33-332}
set_msg_config -suppress -id {Pwropt 34-321}
set_msg_config -suppress -id {Synth 8-6841}
set_msg_config -suppress -id {Netlist 29-101}
set_msg_config -suppress -id {Device 21-9320} 
set_msg_config -suppress -id {Device 21-2174}
set_property simulator_language Verilog [current_project]
add_files -fileset constrs_1 -norecurse { ./hello_world_cmod_a7_constraints.xdc }
add_files -norecurse .
add_files -norecurse { ../../../../rtl/rvx.v }
add_files -norecurse { ../../../../rtl/rvx_core.v }
add_files -norecurse { ../../../../rtl/rvx_bus.v }
add_files -norecurse { ../../../../rtl/rvx_uart.v }
add_files -norecurse { ../../../../rtl/rvx_mtimer.v }
add_files -norecurse { ../../../../rtl/rvx_gpio.v }
add_files -norecurse { ../../../../rtl/rvx_spi.v }
add_files -norecurse { ../../../../rtl/rvx_ram.v }
add_files -norecurse { ../../software/build/hello_world.hex }
set_property file_type {Memory Initialization Files} [get_files ../../software/build/hello_world.hex]