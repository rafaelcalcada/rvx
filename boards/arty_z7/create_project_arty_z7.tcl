# Install board information
xhub::install [xhub::get_xitems digilentinc.com:xilinx_board_store:arty-z7-20:1.1]

cd [file normalize [file dirname [info script]]]
create_project rvx_arty_z7 ./rvx_arty_z7 -part xc7z020clg400-1 -force
set_property board_part digilentinc.com:arty-z7-20:part0:1.1 [current_project]

set_msg_config -suppress -id {Synth 8-7080}
set_msg_config -suppress -id {Power 33-332}
set_msg_config -suppress -id {Pwropt 34-321}
set_msg_config -suppress -id {Synth 8-6841}
set_msg_config -suppress -id {Netlist 29-101}
set_msg_config -suppress -id {Device 21-9320}
set_msg_config -suppress -id {Device 21-2174}
set_msg_config -suppress -id {filemgmt 56-199}

set_property simulator_language Verilog [current_project]

add_files -fileset constrs_1 -norecurse { ./rvx_arty_z7_constraints.xdc }
add_files -norecurse { rvx_arty_z7.v }
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
add_files -norecurse { ../../rtl/memory/rvx_tcm.v }
add_files -norecurse { ../../rtl/memory/rvx_bootloader_rom.v }
add_files -norecurse { ../../rtl/peripherals/rvx_i2c.v }
add_files -norecurse { ../../rtl/peripherals/rvx_gpio.v }
add_files -norecurse { ../../rtl/peripherals/rvx_timer.v }
add_files -norecurse { ../../rtl/peripherals/rvx_spi.v }
add_files -norecurse { ../../rtl/peripherals/rvx_uart.v }

if { [file exists ../../examples/hello_world/build/rvx_hello_world_example.mem] } {
    add_files -norecurse { ../../examples/hello_world/build/rvx_hello_world_example.mem }
    set_property file_type {Memory File} [get_files ../../examples/hello_world/build/rvx_hello_world_example.mem]
}

if { [file exists ../../examples/uart/build/rvx_uart_example.mem] } {
    add_files -norecurse { ../../examples/uart/build/rvx_uart_example.mem }
    set_property file_type {Memory File} [get_files ../../examples/uart/build/rvx_uart_example.mem]
}

if { [file exists ../../examples/spi/build/rvx_spi_example.mem] } {
    add_files -norecurse { ../../examples/spi/build/rvx_spi_example.mem }
    set_property file_type {Memory File} [get_files ../../examples/spi/build/rvx_spi_example.mem]
}

if { [file exists ../../examples/gpio/build/rvx_gpio_example.mem] } {
    add_files -norecurse { ../../examples/gpio/build/rvx_gpio_example.mem }
    set_property file_type {Memory File} [get_files ../../examples/gpio/build/rvx_gpio_example.mem]
}

if { [file exists ../../examples/timer/build/rvx_timer_example.mem] } {
    add_files -norecurse { ../../examples/timer/build/rvx_timer_example.mem }
    set_property file_type {Memory File} [get_files ../../examples/timer/build/rvx_timer_example.mem]
}

if { [file exists ../../examples/freertos/build/rvx_freertos_example.mem] } {
    add_files -norecurse { ../../examples/freertos/build/rvx_freertos_example.mem }
    set_property file_type {Memory File} [get_files ../../examples/freertos/build/rvx_freertos_example.mem]
}

if { [file exists ../../examples/i2c/build/rvx_i2c_example.mem] } {
    add_files -norecurse { ../../examples/i2c/build/rvx_i2c_example.mem }
    set_property file_type {Memory File} [get_files ../../examples/i2c/build/rvx_i2c_example.mem]
}

# MMCM generation (125 MHz -> 55 MHz)
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {55} \
  CONFIG.MMCM_CLKIN1_PERIOD {8.000} \
  CONFIG.PRIM_IN_FREQ {125} \
  CONFIG.USE_LOCKED {false} \
  CONFIG.USE_RESET {false} \
] [get_ips clk_wiz_0]
generate_target {instantiation_template} [get_files ./rvx_arty_z7/rvx_arty_z7.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]

# Zynq 7 Processing system
create_bd_design "processing_system_bd"
update_compile_order -fileset sources_1
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
startgroup
set_property -dict [list \
  CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {0} \
  CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_SD0_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
  CONFIG.PCW_UART1_UART1_IO {EMIO} \
  CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} \
  CONFIG.PCW_USE_M_AXI_GP0 {0} \
] [get_bd_cells processing_system7_0]
endgroup
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins processing_system7_0/UART_1]
endgroup
set_property name UART_1 [get_bd_intf_ports UART_1_0]
make_wrapper -files [get_files ./rvx_arty_z7/rvx_arty_z7.srcs/sources_1/bd/processing_system_bd/processing_system_bd.bd] -language SystemVerilog -add
update_compile_order -fileset sources_1
update_compile_order -fileset sources_1

# Run write bitstream
launch_runs impl_1 -to_step write_bitstream -jobs $nproc

# Write HW platform
write_hw_platform -fixed -include_bit -force -file ./rvx_arty_z7/rvx_arty_z7.xsa
