// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_pc_gen #(

    parameter BOOT_ADDRESS = 32'h00000000

) (

    input wire [ 3:0] current_state_s1,
    input wire [31:0] exception_address_s1,
    input wire [31:0] trap_handler_address_s1,
    input wire [31:0] next_program_counter_s1,

    output reg [31:0] program_counter_s0

);

  reg [1:0] program_counter_source;

  always @* begin : program_counter_mux
    case (program_counter_source)
      `RVX_PC_BOOT: program_counter_s0 = BOOT_ADDRESS;
      `RVX_PC_EPC:  program_counter_s0 = exception_address_s1;
      `RVX_PC_TRAP: program_counter_s0 = trap_handler_address_s1;
      `RVX_PC_NEXT: program_counter_s0 = next_program_counter_s1;
    endcase
  end

  always @* begin : program_counter_source_mux
    case (current_state_s1)
      `RVX_STATE_RESET:       program_counter_source = `RVX_PC_BOOT;
      `RVX_STATE_OPERATING:   program_counter_source = `RVX_PC_NEXT;
      `RVX_STATE_TRAP_TAKEN:  program_counter_source = `RVX_PC_TRAP;
      `RVX_STATE_TRAP_RETURN: program_counter_source = `RVX_PC_EPC;
      default:                program_counter_source = `RVX_PC_NEXT;
    endcase
  end

endmodule
