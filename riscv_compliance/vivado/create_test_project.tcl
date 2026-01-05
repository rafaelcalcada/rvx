cd [file normalize [file dirname [info script]]]
set memory_init_files {../test_programs/add-01.hex \
					   ../test_programs/addi-01.hex \
					   ../test_programs/and-01.hex \
					   ../test_programs/andi-01.hex \
					   ../test_programs/auipc-01.hex \
					   ../test_programs/beq-01.hex \
					   ../test_programs/bge-01.hex \
					   ../test_programs/bgeu-01.hex \
					   ../test_programs/blt-01.hex \
					   ../test_programs/bltu-01.hex \
					   ../test_programs/bne-01.hex \
					   ../test_programs/ebreak.hex \
					   ../test_programs/ecall.hex \
					   ../test_programs/fence-01.hex \
					   ../test_programs/jal-01.hex \
					   ../test_programs/jalr-01.hex \
					   ../test_programs/lb-align-01.hex \
					   ../test_programs/lbu-align-01.hex \
					   ../test_programs/lh-align-01.hex \
					   ../test_programs/lhu-align-01.hex \
					   ../test_programs/lui-01.hex \
					   ../test_programs/lw-align-01.hex \
					   ../test_programs/misalign-beq-01.hex \
					   ../test_programs/misalign-bge-01.hex \
					   ../test_programs/misalign-bgeu-01.hex \
					   ../test_programs/misalign-blt-01.hex \
					   ../test_programs/misalign-bltu-01.hex \
					   ../test_programs/misalign-bne-01.hex \
					   ../test_programs/misalign-jal-01.hex \
					   ../test_programs/misalign1-jalr-01.hex \
					   ../test_programs/misalign2-jalr-01.hex \
					   ../test_programs/misalign-beq-01.hex \
					   ../test_programs/misalign-bge-01.hex \
					   ../test_programs/misalign-bgeu-01.hex \
					   ../test_programs/misalign-blt-01.hex \
					   ../test_programs/misalign-bltu-01.hex \
					   ../test_programs/misalign-bne-01.hex \
					   ../test_programs/misalign-jal-01.hex \
					   ../test_programs/misalign-lh-01.hex \
					   ../test_programs/misalign-lhu-01.hex \
					   ../test_programs/misalign-lw-01.hex \
					   ../test_programs/misalign-sh-01.hex \
					   ../test_programs/misalign-sw-01.hex \
					   ../test_programs/mul-01.hex \
					   ../test_programs/mulh-01.hex \
					   ../test_programs/mulhsu-01.hex \
					   ../test_programs/mulhu-01.hex \
					   ../test_programs/or-01.hex \
					   ../test_programs/ori-01.hex \
					   ../test_programs/sb-align-01.hex \
					   ../test_programs/sh-align-01.hex \
					   ../test_programs/sll-01.hex \
					   ../test_programs/slli-01.hex \
					   ../test_programs/slt-01.hex \
					   ../test_programs/slti-01.hex \
					   ../test_programs/sltiu-01.hex \
					   ../test_programs/sltu-01.hex \
					   ../test_programs/sra-01.hex \
					   ../test_programs/srai-01.hex \
					   ../test_programs/srl-01.hex \
					   ../test_programs/srli-01.hex \
					   ../test_programs/sub-01.hex \
					   ../test_programs/sw-align-01.hex \
					   ../test_programs/xor-01.hex \
					   ../test_programs/xori-01.hex \
					   ../golden_references/add-01.reference.hex \
					   ../golden_references/addi-01.reference.hex \
					   ../golden_references/and-01.reference.hex \
					   ../golden_references/andi-01.reference.hex \
					   ../golden_references/auipc-01.reference.hex \
					   ../golden_references/beq-01.reference.hex \
					   ../golden_references/bge-01.reference.hex \
					   ../golden_references/bgeu-01.reference.hex \
					   ../golden_references/blt-01.reference.hex \
					   ../golden_references/bltu-01.reference.hex \
					   ../golden_references/bne-01.reference.hex \
					   ../golden_references/ebreak.reference.hex \
					   ../golden_references/ecall.reference.hex \
					   ../golden_references/fence-01.reference.hex \
					   ../golden_references/jal-01.reference.hex \
					   ../golden_references/jalr-01.reference.hex \
					   ../golden_references/lb-align-01.reference.hex \
					   ../golden_references/lbu-align-01.reference.hex \
					   ../golden_references/lh-align-01.reference.hex \
					   ../golden_references/lhu-align-01.reference.hex \
					   ../golden_references/lui-01.reference.hex \
					   ../golden_references/lw-align-01.reference.hex \
					   ../golden_references/misalign1-jalr-01.reference.hex \
					   ../golden_references/misalign2-jalr-01.reference.hex \
					   ../golden_references/misalign-beq-01.reference.hex \
					   ../golden_references/misalign-bge-01.reference.hex \
					   ../golden_references/misalign-bgeu-01.reference.hex \
					   ../golden_references/misalign-blt-01.reference.hex \
					   ../golden_references/misalign-bltu-01.reference.hex \
					   ../golden_references/misalign-bne-01.reference.hex \
					   ../golden_references/misalign-jal-01.reference.hex \
					   ../golden_references/misalign-lh-01.reference.hex \
					   ../golden_references/misalign-lhu-01.reference.hex \
					   ../golden_references/misalign-lw-01.reference.hex \
					   ../golden_references/misalign-sh-01.reference.hex \
					   ../golden_references/misalign-sw-01.reference.hex \
					   ../golden_references/mul-01.reference.hex \
					   ../golden_references/mulh-01.reference.hex \
					   ../golden_references/mulhsu-01.reference.hex \
					   ../golden_references/mulhu-01.reference.hex \
					   ../golden_references/or-01.reference.hex \
					   ../golden_references/ori-01.reference.hex \
					   ../golden_references/sb-align-01.reference.hex \
					   ../golden_references/sh-align-01.reference.hex \
					   ../golden_references/sll-01.reference.hex \
					   ../golden_references/slli-01.reference.hex \
					   ../golden_references/slt-01.reference.hex \
					   ../golden_references/slti-01.reference.hex \
					   ../golden_references/sltiu-01.reference.hex \
					   ../golden_references/sltu-01.reference.hex \
					   ../golden_references/sra-01.reference.hex \
					   ../golden_references/srai-01.reference.hex \
					   ../golden_references/srl-01.reference.hex \
					   ../golden_references/srli-01.reference.hex \
					   ../golden_references/sub-01.reference.hex \
					   ../golden_references/sw-align-01.reference.hex \
					   ../golden_references/xor-01.reference.hex \
					   ../golden_references/xori-01.reference.hex}
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