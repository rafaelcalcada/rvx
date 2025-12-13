// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_core_constants.vh"

module rvx_core_state (

    input wire clock,
    input wire clock_enable,
    input wire reset_n,

    input wire mret_s1,
    input wire take_trap_s1,

    output reg  [3:0] core_state_s1,
    output wire       flush_pipeline_s1

);

  assign flush_pipeline_s1 = (core_state_s1 != `RVX_STATE_OPERATING);

  always @(posedge clock) begin : core_state_fsm
    if (!reset_n) core_state_s1 <= `RVX_STATE_RESET;
    else if (clock_enable) begin
      case (core_state_s1)
        `RVX_STATE_RESET:       core_state_s1 <= `RVX_STATE_OPERATING;
        `RVX_STATE_OPERATING: begin
          if (take_trap_s1) core_state_s1 <= `RVX_STATE_TRAP_TAKEN;
          else if (mret_s1) core_state_s1 <= `RVX_STATE_TRAP_RETURN;
          else core_state_s1 <= `RVX_STATE_OPERATING;
        end
        `RVX_STATE_TRAP_TAKEN:  core_state_s1 <= `RVX_STATE_OPERATING;
        `RVX_STATE_TRAP_RETURN: core_state_s1 <= `RVX_STATE_OPERATING;
        default:                core_state_s1 <= `RVX_STATE_OPERATING;
      endcase
    end
  end

endmodule
