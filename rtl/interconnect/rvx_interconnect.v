// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_interconnect #(

    // Number of connected peripheral devices
    parameter NUM_PERIPHERALS = 1,

    // Base addresses for the the peripheral devices
    parameter [NUM_PERIPHERALS*32-1:0] BASE_ADDRESSES = 0,

    // Region sizes for the peripheral devices
    parameter [NUM_PERIPHERALS*32-1:0] REGION_SIZES = 0

) (

    // Global signals
    input wire clock,
    input wire reset_n,

    // Connections with the device controlling the interconnect (RVX Core)
    input  wire [31:0] controller_address,
    output reg  [31:0] controller_rdata,
    input  wire        controller_rrequest,
    output reg         controller_rresponse,
    input  wire [31:0] controller_wdata,
    input  wire [ 3:0] controller_wstrobe,
    input  wire        controller_wrequest,
    output reg         controller_wresponse,

    // Connections with the controlled peripheral devices
    output wire [                  31:0] peripheral_address,
    input  wire [NUM_PERIPHERALS*32-1:0] peripheral_rdata,
    output wire [   NUM_PERIPHERALS-1:0] peripheral_rrequest,
    input  wire [   NUM_PERIPHERALS-1:0] peripheral_rresponse,
    output wire [                  31:0] peripheral_wdata,
    output wire [                   3:0] peripheral_wstrobe,
    output wire [   NUM_PERIPHERALS-1:0] peripheral_wrequest,
    input  wire [   NUM_PERIPHERALS-1:0] peripheral_wresponse

);

  reg [NUM_PERIPHERALS-1:0] peripheral_sel;
  reg [NUM_PERIPHERALS-1:0] peripheral_sel_reg;

  // Read/write request signals (directly forwarded to the peripherals)
  // ---------------------------------------------------------------------------

  assign peripheral_address  = controller_address;
  assign peripheral_rrequest = peripheral_sel & {NUM_PERIPHERALS{controller_rrequest}};
  assign peripheral_wdata    = controller_wdata;
  assign peripheral_wstrobe  = controller_wstrobe;
  assign peripheral_wrequest = peripheral_sel & {NUM_PERIPHERALS{controller_wrequest}};

  // Selecting the peripheral based on the address provided by the controller
  // ---------------------------------------------------------------------------

  integer i;
  always @(*) begin
    for (i = 0; i < NUM_PERIPHERALS; i = i + 1) begin
      // Compare addresses per peripheral and set selection signal accordingly
      if ((controller_address >= BASE_ADDRESSES[i*32+:32]) &&
          (controller_address < (BASE_ADDRESSES[i*32+:32] + REGION_SIZES[i*32+:32])))
        peripheral_sel[i] = 1'b1;
      else peripheral_sel[i] = 1'b0;
    end
  end

  // Registering the peripheral selection to align with read/write responses
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) peripheral_sel_reg <= {NUM_PERIPHERALS{1'b0}};
    else if ((controller_rrequest || controller_wrequest) && (|peripheral_sel)) peripheral_sel_reg <= peripheral_sel;
    else peripheral_sel_reg <= {NUM_PERIPHERALS{1'b0}};
  end

  // Read and write response multiplexing logic
  // ---------------------------------------------------------------------------

  always @(*) begin
    controller_rdata     = 32'b0;
    controller_rresponse = 1'b1;
    controller_wresponse = 1'b1;
    for (i = 0; i < NUM_PERIPHERALS; i = i + 1) begin
      if (peripheral_sel_reg[i]) begin
        controller_rdata     = peripheral_rdata[i*32+:32];
        controller_rresponse = peripheral_rresponse[i];
        controller_wresponse = peripheral_wresponse[i];
      end
    end
  end

endmodule
