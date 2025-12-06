// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_core_constants.vh"

module rvx_core_alu (

    input wire        alu_2nd_operand_sel_s2,
    input wire [ 3:0] alu_operation_code_s2,
    input wire [31:0] rs1_data_s2,
    input wire [31:0] rs2_data_s2,
    input wire [31:0] immediate_s2,

    output reg [31:0] alu_output_s2

);

  wire [31:0] alu_2nd_operand_s2;
  wire [31:0] alu_adder_2nd_operand_mux_s2;
  wire [31:0] alu_minus_2nd_operand_s2;
  wire [31:0] alu_shift_right_mux_s2;
  wire        alu_slt_result_s2;
  wire        alu_sltu_result_s2;
  wire [31:0] alu_sra_result_s2;
  wire [31:0] alu_srl_result_s2;

  assign alu_2nd_operand_s2 = alu_2nd_operand_sel_s2 ? rs2_data_s2 : immediate_s2;

  assign alu_minus_2nd_operand_s2 = -alu_2nd_operand_s2;

  assign
      alu_adder_2nd_operand_mux_s2 = alu_operation_code_s2[3] == 1'b1 ? alu_minus_2nd_operand_s2 : alu_2nd_operand_s2;

  assign alu_sra_result_s2 = $signed(rs1_data_s2) >>> alu_2nd_operand_s2[4:0];

  assign alu_srl_result_s2 = rs1_data_s2 >> alu_2nd_operand_s2[4:0];

  assign alu_shift_right_mux_s2 = alu_operation_code_s2[3] == 1'b1 ? alu_sra_result_s2 : alu_srl_result_s2;

  assign alu_sltu_result_s2 = rs1_data_s2 < alu_2nd_operand_s2;

  assign alu_slt_result_s2 = rs1_data_s2[31] ^ alu_2nd_operand_s2[31] ? rs1_data_s2[31] : alu_sltu_result_s2;

  always @* begin : alu_output_s2_mux
    case (alu_operation_code_s2[2:0])
      `RISCV_FUNCT3_ADD:  alu_output_s2 = rs1_data_s2 + alu_adder_2nd_operand_mux_s2;
      `RISCV_FUNCT3_SRL:  alu_output_s2 = alu_shift_right_mux_s2;
      `RISCV_FUNCT3_OR:   alu_output_s2 = rs1_data_s2 | alu_2nd_operand_s2;
      `RISCV_FUNCT3_AND:  alu_output_s2 = rs1_data_s2 & alu_2nd_operand_s2;
      `RISCV_FUNCT3_XOR:  alu_output_s2 = rs1_data_s2 ^ alu_2nd_operand_s2;
      `RISCV_FUNCT3_SLT:  alu_output_s2 = {31'b0, alu_slt_result_s2};
      `RISCV_FUNCT3_SLTU: alu_output_s2 = {31'b0, alu_sltu_result_s2};
      `RISCV_FUNCT3_SLL:  alu_output_s2 = rs1_data_s2 << alu_2nd_operand_s2[4:0];
    endcase
  end

endmodule
