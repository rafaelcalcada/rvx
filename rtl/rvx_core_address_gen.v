// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_address_gen (

    input wire [31:0] immediate_s1,
    input wire [ 1:0] instruction_funct3_1_0,
    input wire        load_s1,
    input wire [31:0] program_counter_s1,
    input wire [31:0] rs1_data_s1,
    input wire        store_s1,
    input wire        take_branch_s1,
    input wire        target_address_source_s1,

    output wire        misaligned_instruction_address_s1,
    output wire        misaligned_load_s1,
    output wire        misaligned_store_s1,
    output wire [31:0] target_address_s1,
    output wire [31:0] next_program_counter_s1

);

  wire [31:0] branch_target_address;
  wire        misaligned_word;
  wire        misaligned_half;
  wire        misaligned;

  assign target_address_s1 = target_address_source_s1 == 1'b1 ? rs1_data_s1 + immediate_s1 :
      program_counter_s1 + immediate_s1;

  assign branch_target_address = {target_address_s1[31:1], 1'b0};

  assign next_program_counter_s1 = take_branch_s1 ? branch_target_address : program_counter_s1 + 32'h00000004;

  assign misaligned_word = instruction_funct3_1_0 == 2'b10 & (target_address_s1[1] | target_address_s1[0]);

  assign misaligned_half = instruction_funct3_1_0 == 2'b01 & target_address_s1[0];

  assign misaligned = misaligned_word | misaligned_half;

  assign misaligned_store_s1 = store_s1 & misaligned;

  assign misaligned_load_s1 = load_s1 & misaligned;

  assign misaligned_instruction_address_s1 = take_branch_s1 & next_program_counter_s1[1];

endmodule
