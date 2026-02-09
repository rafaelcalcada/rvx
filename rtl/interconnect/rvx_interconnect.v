// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_interconnect #(

    // The number of connected peripheral devices
    parameter                          NUM_PERIPHERALS = 1,
    parameter [NUM_PERIPHERALS*32-1:0] BASE_ADDRESSES  = 0,
    parameter [NUM_PERIPHERALS*32-1:0] REGION_SIZES    = 0

) (

    // Global signals
    input wire clock,
    input wire reset_n,

    // Connections with the controller device (RVX Core)
    input  wire [31:0] controller_rw_address,
    output reg  [31:0] controller_read_data,
    input  wire        controller_read_request,
    output reg         controller_read_response,
    input  wire [31:0] controller_write_data,
    input  wire [ 3:0] controller_write_strobe,
    input  wire        controller_write_request,
    output reg         controller_write_response,

    // Connections with the controlled peripheral devices (UART, SPI, GPIO, etc.)
    output wire [                  31:0] peripheral_rw_address,
    input  wire [NUM_PERIPHERALS*32-1:0] peripheral_read_data,
    output wire [   NUM_PERIPHERALS-1:0] peripheral_read_request,
    input  wire [   NUM_PERIPHERALS-1:0] peripheral_read_response,
    output wire [                  31:0] peripheral_write_data,
    output wire [                   3:0] peripheral_write_strobe,
    output wire [   NUM_PERIPHERALS-1:0] peripheral_write_request,
    input  wire [   NUM_PERIPHERALS-1:0] peripheral_write_response

);

  reg [NUM_PERIPHERALS-1:0] peripheral_sel;
  reg [NUM_PERIPHERALS-1:0] peripheral_sel_reg;

  // Read/write request signals (forwarded directly)
  // ---------------------------------------------------------------------------

  assign peripheral_rw_address    = controller_rw_address;
  assign peripheral_read_request  = peripheral_sel & {NUM_PERIPHERALS{controller_read_request}};
  assign peripheral_write_data    = controller_write_data;
  assign peripheral_write_strobe  = controller_write_strobe;
  assign peripheral_write_request = peripheral_sel & {NUM_PERIPHERALS{controller_write_request}};

  // Peripheral selection logic based on their base addresses and region sizes
  // ---------------------------------------------------------------------------

  integer i;
  always @(*) begin
    for (i = 0; i < NUM_PERIPHERALS; i = i + 1) begin
      // Compare addresses per peripheral and set selection signal accordingly
      if ((controller_rw_address >= BASE_ADDRESSES[i*32+:32]) &&
          (controller_rw_address < (BASE_ADDRESSES[i*32+:32] + REGION_SIZES[i*32+:32])))
        peripheral_sel[i] = 1'b1;
      else peripheral_sel[i] = 1'b0;
    end
  end

  // Registering the peripheral selection to align with read/write responses
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) peripheral_sel_reg <= {NUM_PERIPHERALS{1'b0}};
    else if ((controller_read_request || controller_write_request) && (|peripheral_sel))
      peripheral_sel_reg <= peripheral_sel;
    else peripheral_sel_reg <= {NUM_PERIPHERALS{1'b0}};
  end

  // Read and write response multiplexing logic
  // ---------------------------------------------------------------------------

  always @(*) begin
    controller_read_data      = 32'b0;
    controller_read_response  = 1'b1;
    controller_write_response = 1'b1;
    for (i = 0; i < NUM_PERIPHERALS; i = i + 1) begin
      if (peripheral_sel_reg[i]) begin
        controller_read_data      = peripheral_read_data[i*32+:32];
        controller_read_response  = peripheral_read_response[i];
        controller_write_response = peripheral_write_response[i];
      end
    end
  end

endmodule
