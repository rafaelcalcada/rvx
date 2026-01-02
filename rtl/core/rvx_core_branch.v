// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_branch (

    input wire        branch_s1,
    input wire [ 2:0] funct3_s1,
    input wire        jump_s1,
    input wire [31:0] rs1_data_s1,
    input wire [31:0] rs2_data_s1,

    output wire take_branch_s1
);

  wire equal;
  wire not_equal;
  wire less_than;
  wire less_than_unsigned;
  wire greater_or_equal;
  wire greater_or_equal_unsigned;

  reg  branch_condition_satisfied;

  assign equal                     = rs1_data_s1 == rs2_data_s1;
  assign not_equal                 = !equal;
  assign less_than_unsigned        = rs1_data_s1 < rs2_data_s1;
  assign less_than                 = rs1_data_s1[31] ^ rs2_data_s1[31] ? rs1_data_s1[31] : less_than_unsigned;
  assign greater_or_equal          = !less_than;
  assign greater_or_equal_unsigned = !less_than_unsigned;
  assign take_branch_s1            = (jump_s1 == 1'b1) ? 1'b1 : (branch_s1 == 1'b1) ? branch_condition_satisfied : 1'b0;

  always @* begin : branch_condition_satisfied_mux
    case (funct3_s1)
      `RISCV_FUNCT3_BEQ:  branch_condition_satisfied = equal;
      `RISCV_FUNCT3_BNE:  branch_condition_satisfied = not_equal;
      `RISCV_FUNCT3_BLT:  branch_condition_satisfied = less_than;
      `RISCV_FUNCT3_BGE:  branch_condition_satisfied = greater_or_equal;
      `RISCV_FUNCT3_BLTU: branch_condition_satisfied = less_than_unsigned;
      `RISCV_FUNCT3_BGEU: branch_condition_satisfied = greater_or_equal_unsigned;
      default:            branch_condition_satisfied = 1'b0;
    endcase
  end

endmodule
