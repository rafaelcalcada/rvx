// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_mdu (

	input wire [2:0] funct3_s2,
	input wire [31:0] rs1_data_s2,
	input wire [31:0] rs2_data_s2,

	output reg [31:0] mdu_output_s2
);

  wire signed   [31:0] rs1_s;
  wire signed   [31:0] rs2_s;
  wire unsigned [31:0] rs1_u;
  wire unsigned [31:0] rs2_u;

  wire signed   [63:0] result_ss;
  wire signed   [63:0] result_su;
  wire unsigned [63:0] result_uu;

  assign rs1_s = $signed(rs1_data_s2);
  assign rs2_s = $signed(rs2_data_s2);
  assign rs1_u = $unsigned(rs1_data_s2);
  assign rs2_u = $unsigned(rs2_data_s2);

  assign result_ss = rs1_s * rs2_s;
  assign result_su = rs1_s * $signed({1'b0, rs2_s});
  assign result_uu = rs1_u * rs2_u;

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