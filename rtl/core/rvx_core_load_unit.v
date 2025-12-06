// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_load_unit (

    input wire [ 1:0] load_size_s2,
    input wire        load_unsigned_s2,
    input wire [31:0] read_data_s2,
    input wire [ 1:0] target_address_1_0_s2,

    output reg [31:0] load_aligned_data_s2

);

  reg  [ 7:0] load_data_byte_s2;
  reg  [15:0] load_data_half_s2;

  wire [23:0] load_byte_upper_bits_s2 = load_unsigned_s2 == 1'b1 ? 24'b0 : {24{load_data_byte_s2[7]}};
  wire [15:0] load_half_upper_bits_s2 = load_unsigned_s2 == 1'b1 ? 16'b0 : {16{load_data_half_s2[15]}};

  always @* begin : load_size_s2_mux
    case (load_size_s2)
      `RVX_LOAD_SIZE_BYTE: load_aligned_data_s2 = {load_byte_upper_bits_s2, load_data_byte_s2};
      `RVX_LOAD_SIZE_HALF: load_aligned_data_s2 = {load_half_upper_bits_s2, load_data_half_s2};
      `RVX_LOAD_SIZE_WORD: load_aligned_data_s2 = read_data_s2;
      default:             load_aligned_data_s2 = read_data_s2;
    endcase
  end

  always @* begin : load_byte_data_s2_mux
    case (target_address_1_0_s2[1:0])
      2'b00: load_data_byte_s2 = read_data_s2[7:0];
      2'b01: load_data_byte_s2 = read_data_s2[15:8];
      2'b10: load_data_byte_s2 = read_data_s2[23:16];
      2'b11: load_data_byte_s2 = read_data_s2[31:24];
    endcase
  end

  always @* begin : load_half_data_s2_mux
    case (target_address_1_0_s2[1])
      1'b0: load_data_half_s2 = read_data_s2[15:0];
      1'b1: load_data_half_s2 = read_data_s2[31:16];
    endcase
  end

endmodule
