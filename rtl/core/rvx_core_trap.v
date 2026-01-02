// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_trap (

    input wire ecall_s1,
    input wire ebreak_s1,
    input wire global_interrupt_enable_s1,
    input wire illegal_instruction_s1,
    input wire interrupt_pending_s1,
    input wire misaligned_instruction_address_s1,
    input wire misaligned_load_s1,
    input wire misaligned_store_s1,

    output wire take_trap_s1

);

  wire exception_pending = illegal_instruction_s1 | misaligned_load_s1 | misaligned_store_s1 |
      misaligned_instruction_address_s1 | ecall_s1 | ebreak_s1;

  assign take_trap_s1 = (global_interrupt_enable_s1 & interrupt_pending_s1) | exception_pending;

endmodule
