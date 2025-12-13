// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_core_constants.vh"

module rvx_core_state (

    input wire clock,
    input wire clock_enable,
    input wire reset_n,

    input wire mret_s1,
    input wire take_trap_s1,

    output reg  [3:0] current_state_s1,
    output wire       flush_pipeline_s1

);

  reg [3:0] next_state;

  assign flush_pipeline_s1 = (current_state_s1 != `RVX_STATE_OPERATING);

  always @* begin : next_state_logic
    case (current_state_s1)
      `RVX_STATE_RESET:       next_state = `RVX_STATE_OPERATING;
      `RVX_STATE_OPERATING: begin
        if (take_trap_s1) next_state = `RVX_STATE_TRAP_TAKEN;
        else if (mret_s1) next_state = `RVX_STATE_TRAP_RETURN;
        else next_state = `RVX_STATE_OPERATING;
      end
      `RVX_STATE_TRAP_TAKEN:  next_state = `RVX_STATE_OPERATING;
      `RVX_STATE_TRAP_RETURN: next_state = `RVX_STATE_OPERATING;
      default:                next_state = `RVX_STATE_OPERATING;
    endcase
  end

  always @(posedge clock) begin : current_state_register
    if (!reset_n) current_state_s1 <= `RVX_STATE_RESET;
    else if (clock_enable) current_state_s1 <= next_state;
  end

endmodule
