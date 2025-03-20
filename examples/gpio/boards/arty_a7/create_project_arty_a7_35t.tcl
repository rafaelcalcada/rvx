cd [file normalize [file dirname [info script]]]
create_project gpio_arty_a7_35t ./gpio_arty_a7_35t -part xc7a35ticsg324-1L -force
set_msg_config -suppress -id {Synth 8-7080}
set_msg_config -suppress -id {Power 33-332}
set_msg_config -suppress -id {Pwropt 34-321}
set_msg_config -suppress -id {Synth 8-6841}
set_msg_config -suppress -id {Netlist 29-101}
set_msg_config -suppress -id {Device 21-9320} 
set_msg_config -suppress -id {Device 21-2174}
set_property simulator_language Verilog [current_project]
add_files -fileset constrs_1 -norecurse { ./gpio_arty_a7_constraints.xdc }
add_files -norecurse .
add_files -norecurse { ../../../../hardware/rvx.v }
add_files -norecurse { ../../../../hardware/rvx_core.v }
add_files -norecurse { ../../../../hardware/rvx_bus.v }
add_files -norecurse { ../../../../hardware/rvx_uart.v }
add_files -norecurse { ../../../../hardware/rvx_mtimer.v }
add_files -norecurse { ../../../../hardware/rvx_gpio.v }
add_files -norecurse { ../../../../hardware/rvx_spi.v }
add_files -norecurse { ../../../../hardware/rvx_ram.v }
add_files -norecurse { ../../software/build/gpio_demo.hex }
set_property file_type {Memory Initialization Files} [get_files ../../software/build/gpio_demo.hex]