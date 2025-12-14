// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_pc_gen #(

    parameter BOOT_ADDRESS = 32'h00000000

) (

    input wire [ 3:0] core_state_s1,
    input wire [31:0] exception_address_s1,
    input wire [31:0] next_program_counter_s1,
    input wire [31:0] trap_handler_address_s1,

    output reg [31:0] program_counter_s0

);

  always @* begin : program_counter_s0_mux
    case (core_state_s1)
      `RVX_STATE_RESET:       program_counter_s0 = BOOT_ADDRESS;
      `RVX_STATE_TRAP_RETURN: program_counter_s0 = exception_address_s1;
      `RVX_STATE_TRAP_TAKEN:  program_counter_s0 = trap_handler_address_s1;
      `RVX_STATE_OPERATING:   program_counter_s0 = next_program_counter_s1;
      default:                program_counter_s0 = next_program_counter_s1;
    endcase
  end

endmodule
