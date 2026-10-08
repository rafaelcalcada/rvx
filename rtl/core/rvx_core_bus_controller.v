// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core_bus_controller (

    // Global signals
    input wire clock,
    input wire reset_n,

    // Instruction bus interface
    input  wire [31:0] ibus_rdata,
    input  wire        ibus_rresponse,
    output wire [31:0] ibus_address,
    output wire        ibus_rrequest,

    // Data bus interface
    input  wire [31:0] dbus_rdata,
    input  wire        dbus_rresponse,
    input  wire        dbus_wresponse,
    output wire [31:0] dbus_address,
    output wire        dbus_rrequest,
    output wire [31:0] dbus_wdata,
    output wire        dbus_wrequest,
    output wire [ 3:0] dbus_wstrobe,

    // Inputs
    input wire        flush_pipeline_s1,
    input wire        load_s1,
    input wire        misaligned_load_s1,
    input wire        misaligned_store_s1,
    input wire [31:0] program_counter_s0,
    input wire        store_s1,
    input wire [31:0] store_data_s1,
    input wire [ 3:0] store_strobe_s1,
    input wire        take_trap_s1,
    input wire [31:2] target_address_31_2_s1,

    // Outputs
    output wire        clock_enable,
    output wire [31:0] instruction_s1,
    output wire [31:0] memory_data_s2


);

  // Instruction bus previous state registers
  // ---------------------------------------------------------------------------

  reg [31:0] prev_instruction;
  reg [31:0] prev_ibus_address;
  reg        prev_ibus_rrequest;

  // Data bus previous state registers
  // ---------------------------------------------------------------------------

  reg [31:0] prev_dbus_address;
  reg [31:0] prev_dbus_wdata;
  reg [ 3:0] prev_dbus_wstrobe;
  reg        prev_dbus_rrequest;
  reg        prev_dbus_wrequest;

  // Held bus response registers
  // ---------------------------------------------------------------------------

  reg        ibus_rresponse_held;
  reg [31:0] ibus_rdata_held;
  reg        dbus_rresponse_held;
  reg [31:0] dbus_rdata_held;
  reg        dbus_wresponse_held;

  always @(posedge clock) begin
    if (!reset_n | clock_enable) begin
      ibus_rresponse_held <= 1'b0;
      ibus_rdata_held     <= 32'h00000000;
      dbus_rresponse_held <= 1'b0;
      dbus_rdata_held     <= 32'h00000000;
      dbus_wresponse_held <= 1'b0;
    end
    else begin
      if (ibus_rresponse & !ibus_rresponse_held) begin
        ibus_rresponse_held <= 1'b1;
        ibus_rdata_held     <= ibus_rdata;
      end
      if (dbus_rresponse & !dbus_rresponse_held) begin
        dbus_rresponse_held <= 1'b1;
        dbus_rdata_held     <= dbus_rdata;
      end
      if (dbus_wresponse & !dbus_wresponse_held) begin
        dbus_wresponse_held <= 1'b1;
      end
    end
  end

  // Bus acknowledge
  // ---------------------------------------------------------------------------

  wire ibus_racknowledge;
  wire dbus_racknowledge;
  wire dbus_wacknowledge;

  assign ibus_racknowledge = ibus_rresponse | ibus_rresponse_held;
  assign dbus_racknowledge = dbus_rresponse | dbus_rresponse_held;
  assign dbus_wacknowledge = dbus_wresponse | dbus_wresponse_held;

  // Global clock enable
  // ---------------------------------------------------------------------------

  assign clock_enable = !((prev_dbus_rrequest & !dbus_racknowledge) | (prev_dbus_wrequest & !dbus_wacknowledge) |
                          (prev_ibus_rrequest & !ibus_racknowledge));

  // Instruction bus control
  // ---------------------------------------------------------------------------

  assign ibus_address = !reset_n ? 32'h00000000 : (clock_enable ? program_counter_s0 : prev_ibus_address);

  assign ibus_rrequest = !reset_n ? 1'b0 : (clock_enable ? 1'b1 : (prev_ibus_rrequest & ~ibus_racknowledge));

  assign instruction_s1 = flush_pipeline_s1 ? `RISCV_NOP_INSTRUCTION :
      (!clock_enable ? prev_instruction : (ibus_rresponse_held ? ibus_rdata_held : ibus_rdata));

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
      prev_ibus_address  <= 32'h00000000;
      prev_ibus_rrequest <= 1'b0;
    end
    else if (clock_enable) begin
      prev_ibus_address  <= ibus_address;
      prev_ibus_rrequest <= ibus_rrequest;
    end
  end

  // Data bus control
  // ---------------------------------------------------------------------------

  wire store_request = store_s1 & ~misaligned_store_s1 & ~take_trap_s1;

  wire load_request = load_s1 & ~misaligned_load_s1 & ~take_trap_s1 & ~store_s1;

  assign dbus_rrequest = !reset_n ? 1'b0 : (clock_enable ? load_request : (prev_dbus_rrequest & ~dbus_racknowledge));

  assign dbus_address = !reset_n ?
      32'h00000000 : (clock_enable ? {target_address_31_2_s1[31:2], 2'b00} : prev_dbus_address);

  assign dbus_wrequest = !reset_n ? 1'b0 : (clock_enable ? store_request : (prev_dbus_wrequest & ~dbus_wacknowledge));

  assign dbus_wdata = !reset_n ? 32'h00000000 : (clock_enable ? store_data_s1 : prev_dbus_wdata);

  assign dbus_wstrobe = !reset_n ? 4'b0 : (clock_enable ? store_strobe_s1 : prev_dbus_wstrobe);

  assign memory_data_s2 = dbus_rresponse_held ? dbus_rdata_held : dbus_rdata;

  always @(posedge clock) begin
    if (!reset_n) begin
      prev_dbus_address  <= 32'h00000000;
      prev_dbus_rrequest <= 1'b0;
      prev_dbus_wdata    <= 32'h00000000;
      prev_dbus_wrequest <= 1'b0;
      prev_dbus_wstrobe  <= 4'b0000;
    end
    else if (clock_enable) begin
      prev_dbus_address  <= dbus_address;
      prev_dbus_rrequest <= dbus_rrequest;
      prev_dbus_wdata    <= dbus_wdata;
      prev_dbus_wrequest <= dbus_wrequest;
      prev_dbus_wstrobe  <= dbus_wstrobe;
    end
  end

endmodule
