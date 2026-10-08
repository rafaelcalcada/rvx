// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_single_port_arbiter #(

    // Data bus wins when both buses request in the same cycle
    parameter DATA_BUS_HAS_PRIORITY = 1

) (

    // Global signals
    input wire clock,
    input wire reset_n,

    // Instruction bus (read-only)
    input  wire [31:0] ibus_address,
    output wire [31:0] ibus_rdata,
    input  wire        ibus_rrequest,
    output wire        ibus_rresponse,

    // Data bus (read/write)
    input  wire [31:0] dbus_address,
    output wire [31:0] dbus_rdata,
    input  wire        dbus_rrequest,
    output wire        dbus_rresponse,
    input  wire [31:0] dbus_wdata,
    input  wire [ 3:0] dbus_wstrobe,
    input  wire        dbus_wrequest,
    output wire        dbus_wresponse,

    // Memory port
    output wire [31:0] memory_address,
    input  wire [31:0] memory_rdata,
    output wire        memory_rrequest,
    input  wire        memory_rresponse,
    output wire [31:0] memory_wdata,
    output wire [ 3:0] memory_wstrobe,
    output wire        memory_wrequest,
    input  wire        memory_wresponse

);

  wire data_bus_request;
  wire grant_data_bus;
  wire grant_instruction_bus;
  reg  granted_data_bus;
  reg  granted_instruction_bus;

  // Arbitration
  assign data_bus_request      = dbus_rrequest | dbus_wrequest;
  assign grant_data_bus        = DATA_BUS_HAS_PRIORITY ? data_bus_request : (data_bus_request & ~ibus_rrequest);
  assign grant_instruction_bus = ~grant_data_bus & ibus_rrequest;

  // Memory port
  assign memory_address        = grant_data_bus ? dbus_address : ibus_address;
  assign memory_rrequest       = grant_data_bus ? dbus_rrequest : grant_instruction_bus;
  assign memory_wdata          = dbus_wdata;
  assign memory_wstrobe        = dbus_wstrobe;
  assign memory_wrequest       = grant_data_bus & dbus_wrequest;

  // Register the grant to route the response, which arrives one cycle later
  always @(posedge clock) begin
    if (!reset_n) begin
      granted_data_bus        <= 1'b0;
      granted_instruction_bus <= 1'b0;
    end
    else begin
      granted_data_bus        <= grant_data_bus;
      granted_instruction_bus <= grant_instruction_bus;
    end
  end

  // Response routing
  assign ibus_rdata     = memory_rdata;
  assign ibus_rresponse = memory_rresponse & granted_instruction_bus;
  assign dbus_rdata     = memory_rdata;
  assign dbus_rresponse = memory_rresponse & granted_data_bus;
  assign dbus_wresponse = memory_wresponse & granted_data_bus;

endmodule
