// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_store_unit (

    input wire [31:0] rs2_data_s1,
    input wire [ 1:0] target_address_adder_1_0_s1,
    input wire [ 2:0] funct3_s1,
    input wire        dbus_wrequest,

    output reg [31:0] store_aligned_data_s1,
    output reg [ 3:0] store_strobe_s1

);

  reg [31:0] store_data_byte;
  reg [31:0] store_data_half;
  reg [ 3:0] store_strobe_byte;
  reg [ 3:0] store_strobe_half;

  always @* begin
    case (funct3_s1)
      `RISCV_FUNCT3_SB: begin
        store_strobe_s1       = store_strobe_byte;
        store_aligned_data_s1 = store_data_byte;
      end
      `RISCV_FUNCT3_SH: begin
        store_strobe_s1       = store_strobe_half;
        store_aligned_data_s1 = store_data_half;
      end
      `RISCV_FUNCT3_SW: begin
        store_strobe_s1       = {4{dbus_wrequest}};
        store_aligned_data_s1 = rs2_data_s1;
      end
      default: begin
        store_strobe_s1       = {4{dbus_wrequest}};
        store_aligned_data_s1 = rs2_data_s1;
      end
    endcase
  end

  always @* begin
    case (target_address_adder_1_0_s1[1:0])
      2'b00: begin
        store_data_byte   = {24'b0, rs2_data_s1[7:0]};
        store_strobe_byte = {3'b0, dbus_wrequest};
      end
      2'b01: begin
        store_data_byte   = {16'b0, rs2_data_s1[7:0], 8'b0};
        store_strobe_byte = {2'b0, dbus_wrequest, 1'b0};
      end
      2'b10: begin
        store_data_byte   = {8'b0, rs2_data_s1[7:0], 16'b0};
        store_strobe_byte = {1'b0, dbus_wrequest, 2'b0};
      end
      2'b11: begin
        store_data_byte   = {rs2_data_s1[7:0], 24'b0};
        store_strobe_byte = {dbus_wrequest, 3'b0};
      end
    endcase
  end

  always @* begin
    case (target_address_adder_1_0_s1[1])
      1'b0: begin
        store_data_half   = {16'b0, rs2_data_s1[15:0]};
        store_strobe_half = {2'b0, {2{dbus_wrequest}}};
      end
      1'b1: begin
        store_data_half   = {rs2_data_s1[15:0], 16'b0};
        store_strobe_half = {{2{dbus_wrequest}}, 2'b0};
      end
    endcase
  end

endmodule
