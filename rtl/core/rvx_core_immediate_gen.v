// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_immediate_gen (

    input wire [31:7] instruction_31_7_s1,
    input wire [ 2:0] immediate_type_s1,

    output reg [31:0] immediate_s1

);

  wire [19:0] immediate_sign_extension = {20{instruction_31_7_s1[31]}};
  wire [31:0] immediate_i_type = {immediate_sign_extension, instruction_31_7_s1[31:20]};
  wire [31:0] immediate_s_type = {immediate_sign_extension, instruction_31_7_s1[31:25], instruction_31_7_s1[11:7]};
  wire [31:0] immediate_u_type = {instruction_31_7_s1[31:12], 12'h000};
  wire [31:0] immediate_csr_type = {27'b0, instruction_31_7_s1[19:15]};
  wire [31:0] immediate_j_type = {
    immediate_sign_extension[11:0],
    instruction_31_7_s1[19:12],
    instruction_31_7_s1[20],
    instruction_31_7_s1[30:21],
    1'b0
  };
  wire [31:0] immediate_b_type = {
    immediate_sign_extension, instruction_31_7_s1[7], instruction_31_7_s1[30:25], instruction_31_7_s1[11:8], 1'b0
  };

  always @(*) begin : immediate_mux
    case (immediate_type_s1)
      `RISCV_I_TYPE_IMMEDIATE:   immediate_s1 = immediate_i_type;
      `RISCV_S_TYPE_IMMEDIATE:   immediate_s1 = immediate_s_type;
      `RISCV_B_TYPE_IMMEDIATE:   immediate_s1 = immediate_b_type;
      `RISCV_U_TYPE_IMMEDIATE:   immediate_s1 = immediate_u_type;
      `RISCV_J_TYPE_IMMEDIATE:   immediate_s1 = immediate_j_type;
      `RISCV_CSR_TYPE_IMMEDIATE: immediate_s1 = immediate_csr_type;
      default:                   immediate_s1 = immediate_i_type;
    endcase
  end

endmodule
