// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_trap (

    input wire [3:0] current_state_s1,
    input wire       ecall_s1,
    input wire       ebreak_s1,
    input wire       global_interrupt_enable_s1,
    input wire       illegal_instruction_s1,
    input wire       interrupt_pending_s1,
    input wire       misaligned_instruction_address_s1,
    input wire       misaligned_load_s1,
    input wire       misaligned_store_s1,
    input wire [4:0] trap_cause_s1,

    output wire [15:0] irq_fast_response_s1,
    output wire        irq_external_response_s1,
    output wire        irq_software_response_s1,
    output wire        irq_timer_response_s1,
    output wire        take_trap_s1

);

  wire exception_pending = illegal_instruction_s1 | misaligned_load_s1 | misaligned_store_s1 |
      misaligned_instruction_address_s1 | ecall_s1 | ebreak_s1;

  assign irq_external_response_s1 = (current_state_s1 == `RVX_STATE_TRAP_TAKEN) && (trap_cause_s1 == 5'd11);
  assign irq_timer_response_s1    = (current_state_s1 == `RVX_STATE_TRAP_TAKEN) && (trap_cause_s1 == 5'd7);
  assign irq_software_response_s1 = (current_state_s1 == `RVX_STATE_TRAP_TAKEN) && (trap_cause_s1 == 5'd3);
  assign take_trap_s1             = (global_interrupt_enable_s1 & interrupt_pending_s1) | exception_pending;

  generate
    genvar ifast;
    for (ifast = 0; ifast < 16; ifast = ifast + 1) begin
      assign irq_fast_response_s1[ifast] = (current_state_s1 == `RVX_STATE_TRAP_TAKEN) && (trap_cause_s1 == ifast + 16);
    end
  endgenerate

endmodule
