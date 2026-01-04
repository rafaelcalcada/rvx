cd [file normalize [file dirname [info script]]]
set memory_init_files {../unit_tests/programs/add-01.hex \
					   ../unit_tests/programs/addi-01.hex \
					   ../unit_tests/programs/and-01.hex \
					   ../unit_tests/programs/andi-01.hex \
					   ../unit_tests/programs/auipc-01.hex \
					   ../unit_tests/programs/beq-01.hex \
					   ../unit_tests/programs/bge-01.hex \
					   ../unit_tests/programs/bgeu-01.hex \
					   ../unit_tests/programs/blt-01.hex \
					   ../unit_tests/programs/bltu-01.hex \
					   ../unit_tests/programs/bne-01.hex \
					   ../unit_tests/programs/ebreak.hex \
					   ../unit_tests/programs/ecall.hex \
					   ../unit_tests/programs/fence-01.hex \
					   ../unit_tests/programs/jal-01.hex \
					   ../unit_tests/programs/jalr-01.hex \
					   ../unit_tests/programs/lb-align-01.hex \
					   ../unit_tests/programs/lbu-align-01.hex \
					   ../unit_tests/programs/lh-align-01.hex \
					   ../unit_tests/programs/lhu-align-01.hex \
					   ../unit_tests/programs/lui-01.hex \
					   ../unit_tests/programs/lw-align-01.hex \
					   ../unit_tests/programs/misalign-beq-01.hex \
					   ../unit_tests/programs/misalign-bge-01.hex \
					   ../unit_tests/programs/misalign-bgeu-01.hex \
					   ../unit_tests/programs/misalign-blt-01.hex \
					   ../unit_tests/programs/misalign-bltu-01.hex \
					   ../unit_tests/programs/misalign-bne-01.hex \
					   ../unit_tests/programs/misalign-jal-01.hex \
					   ../unit_tests/programs/misalign1-jalr-01.hex \
					   ../unit_tests/programs/misalign2-jalr-01.hex \
					   ../unit_tests/programs/misalign-beq-01.hex \
					   ../unit_tests/programs/misalign-bge-01.hex \
					   ../unit_tests/programs/misalign-bgeu-01.hex \
					   ../unit_tests/programs/misalign-blt-01.hex \
					   ../unit_tests/programs/misalign-bltu-01.hex \
					   ../unit_tests/programs/misalign-bne-01.hex \
					   ../unit_tests/programs/misalign-jal-01.hex \
					   ../unit_tests/programs/misalign-lh-01.hex \
					   ../unit_tests/programs/misalign-lhu-01.hex \
					   ../unit_tests/programs/misalign-lw-01.hex \
					   ../unit_tests/programs/misalign-sh-01.hex \
					   ../unit_tests/programs/misalign-sw-01.hex \
					   ../unit_tests/programs/mul-01.hex \
					   ../unit_tests/programs/mulh-01.hex \
					   ../unit_tests/programs/mulhsu-01.hex \
					   ../unit_tests/programs/mulhu-01.hex \
					   ../unit_tests/programs/or-01.hex \
					   ../unit_tests/programs/ori-01.hex \
					   ../unit_tests/programs/sb-align-01.hex \
					   ../unit_tests/programs/sh-align-01.hex \
					   ../unit_tests/programs/sll-01.hex \
					   ../unit_tests/programs/slli-01.hex \
					   ../unit_tests/programs/slt-01.hex \
					   ../unit_tests/programs/slti-01.hex \
					   ../unit_tests/programs/sltiu-01.hex \
					   ../unit_tests/programs/sltu-01.hex \
					   ../unit_tests/programs/sra-01.hex \
					   ../unit_tests/programs/srai-01.hex \
					   ../unit_tests/programs/srl-01.hex \
					   ../unit_tests/programs/srli-01.hex \
					   ../unit_tests/programs/sub-01.hex \
					   ../unit_tests/programs/sw-align-01.hex \
					   ../unit_tests/programs/xor-01.hex \
					   ../unit_tests/programs/xori-01.hex \
					   ../unit_tests/references/add-01.reference.hex \
					   ../unit_tests/references/addi-01.reference.hex \
					   ../unit_tests/references/and-01.reference.hex \
					   ../unit_tests/references/andi-01.reference.hex \
					   ../unit_tests/references/auipc-01.reference.hex \
					   ../unit_tests/references/beq-01.reference.hex \
					   ../unit_tests/references/bge-01.reference.hex \
					   ../unit_tests/references/bgeu-01.reference.hex \
					   ../unit_tests/references/blt-01.reference.hex \
					   ../unit_tests/references/bltu-01.reference.hex \
					   ../unit_tests/references/bne-01.reference.hex \
					   ../unit_tests/references/ebreak.reference.hex \
					   ../unit_tests/references/ecall.reference.hex \
					   ../unit_tests/references/fence-01.reference.hex \
					   ../unit_tests/references/jal-01.reference.hex \
					   ../unit_tests/references/jalr-01.reference.hex \
					   ../unit_tests/references/lb-align-01.reference.hex \
					   ../unit_tests/references/lbu-align-01.reference.hex \
					   ../unit_tests/references/lh-align-01.reference.hex \
					   ../unit_tests/references/lhu-align-01.reference.hex \
					   ../unit_tests/references/lui-01.reference.hex \
					   ../unit_tests/references/lw-align-01.reference.hex \
					   ../unit_tests/references/misalign1-jalr-01.reference.hex \
					   ../unit_tests/references/misalign2-jalr-01.reference.hex \
					   ../unit_tests/references/misalign-beq-01.reference.hex \
					   ../unit_tests/references/misalign-bge-01.reference.hex \
					   ../unit_tests/references/misalign-bgeu-01.reference.hex \
					   ../unit_tests/references/misalign-blt-01.reference.hex \
					   ../unit_tests/references/misalign-bltu-01.reference.hex \
					   ../unit_tests/references/misalign-bne-01.reference.hex \
					   ../unit_tests/references/misalign-jal-01.reference.hex \
					   ../unit_tests/references/misalign-lh-01.reference.hex \
					   ../unit_tests/references/misalign-lhu-01.reference.hex \
					   ../unit_tests/references/misalign-lw-01.reference.hex \
					   ../unit_tests/references/misalign-sh-01.reference.hex \
					   ../unit_tests/references/misalign-sw-01.reference.hex \
					   ../unit_tests/references/mul-01.reference.hex \
					   ../unit_tests/references/mulh-01.reference.hex \
					   ../unit_tests/references/mulhsu-01.reference.hex \
					   ../unit_tests/references/mulhu-01.reference.hex \
					   ../unit_tests/references/or-01.reference.hex \
					   ../unit_tests/references/ori-01.reference.hex \
					   ../unit_tests/references/sb-align-01.reference.hex \
					   ../unit_tests/references/sh-align-01.reference.hex \
					   ../unit_tests/references/sll-01.reference.hex \
					   ../unit_tests/references/slli-01.reference.hex \
					   ../unit_tests/references/slt-01.reference.hex \
					   ../unit_tests/references/slti-01.reference.hex \
					   ../unit_tests/references/sltiu-01.reference.hex \
					   ../unit_tests/references/sltu-01.reference.hex \
					   ../unit_tests/references/sra-01.reference.hex \
					   ../unit_tests/references/srai-01.reference.hex \
					   ../unit_tests/references/srl-01.reference.hex \
					   ../unit_tests/references/srli-01.reference.hex \
					   ../unit_tests/references/sub-01.reference.hex \
					   ../unit_tests/references/sw-align-01.reference.hex \
					   ../unit_tests/references/xor-01.reference.hex \
					   ../unit_tests/references/xori-01.reference.hex}
create_project test_project ./test_project -part xc7a35ticsg324-1L -force
set_property simulator_language Verilog [current_project]
add_files -norecurse $memory_init_files
add_files -norecurse {./unit_tests.v}
add_files -norecurse {../../../rtl/rvx_constants.vh}
add_files -norecurse {../../../rtl/core/rvx_core.v}
add_files -norecurse {../../../rtl/core/rvx_core_address_gen.v}
add_files -norecurse {../../../rtl/core/rvx_core_alu.v}
add_files -norecurse {../../../rtl/core/rvx_core_branch.v}
add_files -norecurse {../../../rtl/core/rvx_core_bus_controller.v}
add_files -norecurse {../../../rtl/core/rvx_core_csr_file.v}
add_files -norecurse {../../../rtl/core/rvx_core_decoder.v}
add_files -norecurse {../../../rtl/core/rvx_core_immediate_gen.v}
add_files -norecurse {../../../rtl/core/rvx_core_integer_file.v}
add_files -norecurse {../../../rtl/core/rvx_core_load_unit.v}
add_files -norecurse {../../../rtl/core/rvx_core_mdu.v}
add_files -norecurse {../../../rtl/core/rvx_core_pc_gen.v}
add_files -norecurse {../../../rtl/core/rvx_core_state.v}
add_files -norecurse {../../../rtl/core/rvx_core_store_unit.v}
add_files -norecurse {../../../rtl/core/rvx_core_trap.v}
add_files -norecurse {../../../rtl/memory/rvx_tightly_coupled_memory.v}
move_files -fileset sim_1 [get_files ./unit_tests.v]
set_property file_type {Memory Initialization Files} [get_files $memory_init_files]
set_property -name xsim.elaborate.xelab.more_options -value "--timescale 1ns/1ps" -object [get_filesets sim_1]