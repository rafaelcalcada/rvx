cd [file normalize [file dirname [info script]]]
set memory_init_files {../build/unit_tests.hex}
create_project vivado_project ./vivado_project -part xc7a35ticsg324-1L -force
set_property simulator_language Verilog [current_project]
add_files -fileset constrs_1 -norecurse { ./unit_tests_constraints.xdc }
add_files -norecurse $memory_init_files
add_files -norecurse {./unit_tests.v ../../../../core/rvsteel_core.v ../../../../soc/rvsteel_soc.v ../../../../uart/rvsteel_uart.v ../../../../ram/rvsteel_ram.v ../../../../spi/rvsteel_spi.v ../../../../bus/rvsteel_bus.v ../../../../gpio/rvsteel_gpio.v ../../../../mtimer/rvsteel_mtimer.v }
set_property file_type {Memory Initialization Files} [get_files $memory_init_files]
# Suppress "Parallel synthesis criteria not met"
set_msg_config -suppress -id {Synth 8-7080}
# Supress harmless warning about high fanin/fanout nets
set_msg_config -suppress -id {Pwropt 34-321}