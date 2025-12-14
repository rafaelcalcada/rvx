// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_decoder (

    input wire [31:0] instruction_s1,

    output wire [3:0] alu_operation_code_s1,
    output wire       alu_2nd_operand_sel_s1,
    output wire       branch_s1,
    output wire [2:0] csr_operation_s1,
    output wire       csr_write_request_s1,
    output wire       ebreak_s1,
    output wire       ecall_s1,
    output reg  [2:0] immediate_type_s1,
    output wire       illegal_instruction_s1,
    output wire       integer_file_write_request_s1,
    output wire       jump_s1,
    output wire [1:0] load_size_s1,
    output wire       load_s1,
    output wire       load_unsigned_s1,
    output wire       mret_s1,
    output wire       store_s1,
    output wire       target_address_sel_s1,
    output reg  [2:0] writeback_mux_sel_s1

);

  // Instruction fields decoding
  // ---------------------------------------------------------------------------

  wire [6:0] opcode = instruction_s1[6:0];
  wire [2:0] funct3 = instruction_s1[14:12];
  wire [6:0] funct7 = instruction_s1[31:25];
  wire [4:0] rs1_address = instruction_s1[19:15];
  wire [4:0] rs2_address = instruction_s1[24:20];
  wire [4:0] rd_address = instruction_s1[11:7];

  // Instruction type decoding
  // ---------------------------------------------------------------------------

  wire       branch_type = opcode == `RISCV_OPCODE_BRANCH;
  wire       jal_type = opcode == `RISCV_OPCODE_JAL;
  wire       jalr_type = opcode == `RISCV_OPCODE_JALR;
  wire       auipc_type = opcode == `RISCV_OPCODE_AUIPC;
  wire       lui_type = opcode == `RISCV_OPCODE_LUI;
  wire       load_type = opcode == `RISCV_OPCODE_LOAD;
  wire       store_type = opcode == `RISCV_OPCODE_STORE;
  wire       system_type = opcode == `RISCV_OPCODE_SYSTEM;
  wire       op_type = opcode == `RISCV_OPCODE_OP;
  wire       op_imm_type = opcode == `RISCV_OPCODE_OP_IMM;
  wire       misc_mem_type = opcode == `RISCV_OPCODE_MISC_MEM;

  // RV32I instructions decoding (excluding fence, load/store, branch, jumps)
  // ---------------------------------------------------------------------------

  wire       addi = op_imm_type & funct3 == `RISCV_FUNCT3_ADDI;
  wire       slti = op_imm_type & funct3 == `RISCV_FUNCT3_SLTI;
  wire       sltiu = op_imm_type & funct3 == `RISCV_FUNCT3_SLTIU;
  wire       andi = op_imm_type & funct3 == `RISCV_FUNCT3_ANDI;
  wire       ori = op_imm_type & funct3 == `RISCV_FUNCT3_ORI;
  wire       xori = op_imm_type & funct3 == `RISCV_FUNCT3_XORI;
  wire       slli = op_imm_type & funct3 == `RISCV_FUNCT3_SLLI & funct7 == `RISCV_FUNCT7_SLLI;
  wire       srli = op_imm_type & funct3 == `RISCV_FUNCT3_SRLI & funct7 == `RISCV_FUNCT7_SRLI;
  wire       srai = op_imm_type & funct3 == `RISCV_FUNCT3_SRAI & funct7 == `RISCV_FUNCT7_SRAI;
  wire       add = op_type & funct3 == `RISCV_FUNCT3_ADD & funct7 == `RISCV_FUNCT7_ADD;
  wire       sub = op_type & funct3 == `RISCV_FUNCT3_SUB & funct7 == `RISCV_FUNCT7_SUB;
  wire       slt = op_type & funct3 == `RISCV_FUNCT3_SLT & funct7 == `RISCV_FUNCT7_SLT;
  wire       sltu = op_type & funct3 == `RISCV_FUNCT3_SLTU & funct7 == `RISCV_FUNCT7_SLTU;
  wire       is_and = op_type & funct3 == `RISCV_FUNCT3_AND & funct7 == `RISCV_FUNCT7_AND;
  wire       is_or = op_type & funct3 == `RISCV_FUNCT3_OR & funct7 == `RISCV_FUNCT7_OR;
  wire       is_xor = op_type & funct3 == `RISCV_FUNCT3_XOR & funct7 == `RISCV_FUNCT7_XOR;
  wire       sll = op_type & funct3 == `RISCV_FUNCT3_SLL & funct7 == `RISCV_FUNCT7_SLL;
  wire       srl = op_type & funct3 == `RISCV_FUNCT3_SRL & funct7 == `RISCV_FUNCT7_SRL;
  wire       sra = op_type & funct3 == `RISCV_FUNCT3_SRA & funct7 == `RISCV_FUNCT7_SRA;

  // Zicsr instructions decoding
  // ---------------------------------------------------------------------------

  wire       csr_type = system_type & funct3 != 3'b000 & funct3 != 3'b100;

  // System instructions decoding
  // ---------------------------------------------------------------------------

  assign ecall_s1 = system_type & funct3 == `RISCV_FUNCT3_ECALL & funct7 == `RISCV_FUNCT7_ECALL &
      rs1_address == `RISCV_RS1_ECALL & rs2_address == `RISCV_RS2_ECALL & rd_address == `RISCV_RD_ECALL;

  assign ebreak_s1 = system_type & funct3 == `RISCV_FUNCT3_EBREAK & funct7 == `RISCV_FUNCT7_EBREAK &
      rs1_address == `RISCV_RS1_EBREAK & rs2_address == `RISCV_RS2_EBREAK & rd_address == `RISCV_RD_EBREAK;

  assign mret_s1 = system_type & funct3 == `RISCV_FUNCT3_MRET & funct7 == `RISCV_FUNCT7_MRET &
      rs1_address == `RISCV_RS1_MRET & rs2_address == `RISCV_RS2_MRET & rd_address == `RISCV_RD_MRET;

  // Illegal instruction detection
  // ---------------------------------------------------------------------------

  wire illegal_store = store_type & (funct3[2] == 1'b1 || funct3[1:0] == 2'b11);
  wire illegal_load = load_type & (funct3 == 3'b011 || funct3 == 3'b110 || funct3 == 3'b111);
  wire illegal_jalr = jalr_type & funct3 != 3'b000;
  wire illegal_branch = branch_type & (funct3 == 3'b010 || funct3 == 3'b011);
  wire illegal_op = op_type & ~(add | sub | slt | sltu | is_and | is_or | is_xor | sll | srl | sra);
  wire illegal_op_imm = op_imm_type & ~(addi | slti | sltiu | andi | ori | xori | slli | srli | srai);
  wire illegal_system = system_type & ~(csr_type | ecall_s1 | ebreak_s1 | mret_s1);
  wire unknown_type = ~(branch_type | jal_type | jalr_type | auipc_type | lui_type | load_type | store_type |
                        system_type | op_type | op_imm_type | misc_mem_type);

  assign illegal_instruction_s1 = unknown_type | illegal_store | illegal_load | illegal_jalr | illegal_branch |
      illegal_op | illegal_op_imm | illegal_system;

  // Load and Store instructions decoding
  // ---------------------------------------------------------------------------

  assign load_s1 = load_type & ~illegal_load;
  assign store_s1 = store_type & ~illegal_store;

  // Jump and Branch instructions decoding
  // ---------------------------------------------------------------------------

  assign branch_s1 = branch_type & !illegal_branch;
  assign jump_s1 = jal_type | (jalr_type & !illegal_jalr);

  // Control signals generation
  // ---------------------------------------------------------------------------

  assign alu_operation_code_s1[2:0] = funct3;
  assign alu_operation_code_s1[3] = funct7[5] & ~(addi | slti | sltiu | andi | ori | xori);
  assign load_size_s1 = funct3[1:0];
  assign load_unsigned_s1 = funct3[2];
  assign alu_2nd_operand_sel_s1 = opcode[5];
  assign target_address_sel_s1 = load_type | store_type | jalr_type;
  assign integer_file_write_request_s1 = lui_type | auipc_type | jalr_type | jal_type | op_type | op_imm_type |
      load_type | csr_type;
  assign csr_write_request_s1 = csr_type;
  assign csr_operation_s1 = funct3;

  always @* begin : writeback_mux_sel_decoding
    if (op_type == 1'b1 || op_imm_type == 1'b1) writeback_mux_sel_s1 = `RVX_WB_ALU;
    else if (load_type == 1'b1) writeback_mux_sel_s1 = `RVX_WB_LOAD_UNIT;
    else if (jal_type == 1'b1 || jalr_type == 1'b1) writeback_mux_sel_s1 = `RVX_WB_PC_PLUS_4;
    else if (lui_type == 1'b1) writeback_mux_sel_s1 = `RVX_WB_UPPER_IMM;
    else if (auipc_type == 1'b1) writeback_mux_sel_s1 = `RVX_WB_TARGET_ADDER;
    else if (csr_type == 1'b1) writeback_mux_sel_s1 = `RVX_WB_CSR;
    else writeback_mux_sel_s1 = `RVX_WB_ALU;
  end

  always @* begin : immediate_type_decoding
    if (op_imm_type == 1'b1 || load_type == 1'b1 || jalr_type == 1'b1) immediate_type_s1 = `RISCV_I_TYPE_IMMEDIATE;
    else if (store_type == 1'b1) immediate_type_s1 = `RISCV_S_TYPE_IMMEDIATE;
    else if (branch_type == 1'b1) immediate_type_s1 = `RISCV_B_TYPE_IMMEDIATE;
    else if (jal_type == 1'b1) immediate_type_s1 = `RISCV_J_TYPE_IMMEDIATE;
    else if (lui_type == 1'b1 || auipc_type == 1'b1) immediate_type_s1 = `RISCV_U_TYPE_IMMEDIATE;
    else if (csr_type == 1'b1) immediate_type_s1 = `RISCV_CSR_TYPE_IMMEDIATE;
    else immediate_type_s1 = `RISCV_I_TYPE_IMMEDIATE;
  end

endmodule
