// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_integer_file (

    input wire clock,
    input wire clock_enable,
    input wire reset_n,

    // Read port 1
    input  wire [ 4:0] rs1_address_s1,
    output wire [31:0] rs1_data_s1,

    // Read port 2
    input  wire [ 4:0] rs2_address_s1,
    output wire [31:0] rs2_data_s1,

    // Write port
    input wire        write_request_s2,
    input wire [ 4:0] rd_address_s2,
    input wire [31:0] rd_data_s2

);

  // verilog_format: off
  integer i;
  reg [31:0] integer_file [31:1];
  // verilog_format: on

  wire        write_enable = clock_enable & write_request_s2;
  wire        forward_rs1 = rs1_address_s1 == rd_address_s2 && write_enable;
  wire        forward_rs2 = rs2_address_s1 == rd_address_s2 && write_enable;
  wire [31:0] rs1_mux = forward_rs1 ? rd_data_s2 : integer_file[rs1_address_s1];
  wire [31:0] rs2_mux = forward_rs2 ? rd_data_s2 : integer_file[rs2_address_s1];

  assign rs1_data_s1 = rs1_address_s1 == 5'b00000 ? 32'h00000000 : rs1_mux;
  assign rs2_data_s1 = rs2_address_s1 == 5'b00000 ? 32'h00000000 : rs2_mux;

  always @(posedge clock) begin
    if (!reset_n) begin
      for (i = 1; i < 32; i = i + 1) begin
        integer_file[i] <= 32'h00000000;
      end
    end
    else if (write_enable) begin
      integer_file[rd_address_s2] <= rd_data_s2;
    end
  end

endmodule
