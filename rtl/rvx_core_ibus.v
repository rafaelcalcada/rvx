// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_ibus #(

    parameter BOOT_ADDRESS = 32'h00000000

) (

    input wire clock,
    input wire clock_enable,
    input wire reset_n,

    input  wire [31:0] program_counter_s0,
    input  wire        flush_pipeline_s1,
    output wire [31:0] instruction_s1,

    output wire [31:0] ibus_address,
    output wire        ibus_rrequest,
    output reg         prev_ibus_rrequest,
    input  wire [31:0] ibus_rdata

);

  reg [31:0] prev_instruction;
  reg [31:0] prev_ibus_address;

  assign ibus_address   = !reset_n ? BOOT_ADDRESS : (clock_enable ? program_counter_s0 : prev_ibus_address);

  assign ibus_rrequest  = !reset_n ? 1'b0 : (clock_enable ? 1'b1 : prev_ibus_rrequest);

  assign instruction_s1 = flush_pipeline_s1 ? `RISCV_NOP_INSTRUCTION : (!clock_enable ? prev_instruction : ibus_rdata);

  always @(posedge clock) begin
    if (!reset_n) begin
      prev_instruction <= `RISCV_NOP_INSTRUCTION;
    end
    else begin
      prev_instruction <= instruction_s1;
    end
  end

  always @(posedge clock) begin
    if (!reset_n) begin
      prev_ibus_address  <= BOOT_ADDRESS;
      prev_ibus_rrequest <= 1'b0;
    end
    else if (clock_enable) begin
      prev_ibus_address  <= ibus_address;
      prev_ibus_rrequest <= ibus_rrequest;
    end
  end


endmodule
