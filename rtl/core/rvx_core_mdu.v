// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_mdu (

    input wire [ 2:0] funct3_s2,
    input wire [31:0] rs1_data_s2,
    input wire [31:0] rs2_data_s2,

    output reg [31:0] mdu_output_s2

);

  wire [63:0] result_ss;
  // verilator lint_off UNUSEDSIGNAL
  wire [63:0] result_su;
  wire [63:0] result_uu;
  // verilator lint_on UNUSEDSIGNAL

  assign result_ss = $signed(rs1_data_s2) * $signed(rs2_data_s2);
  assign result_su = $signed(rs1_data_s2) * $signed({1'b0, rs2_data_s2});
  assign result_uu = rs1_data_s2 * rs2_data_s2;

  always @* begin
    case (funct3_s2)
      `RISCV_FUNCT3_MUL:    mdu_output_s2 = result_ss[31:0];
      `RISCV_FUNCT3_MULH:   mdu_output_s2 = result_ss[63:32];
      `RISCV_FUNCT3_MULHSU: mdu_output_s2 = result_su[63:32];
      `RISCV_FUNCT3_MULHU:  mdu_output_s2 = result_uu[63:32];
      default:              mdu_output_s2 = result_ss[31:0];
    endcase
  end

endmodule
