// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module rvx_ram #(

    // Memory size in bytes
    parameter MEMORY_SIZE = 8192,

    // File with program and data
    parameter MEMORY_INIT_FILE = ""

) (

    // Global signals

    input wire clock,
    input wire reset_n,

    // Port 0 (read/wrire)

    input  wire [31:0] port0_address,
    output reg  [31:0] port0_rdata,
    input  wire        port0_rrequest,
    output reg         port0_rresponse,
    input  wire [31:0] port0_wdata,
    input  wire [ 3:0] port0_wstrobe,
    input  wire        port0_wrequest,
    output reg         port0_wresponse,

    // Port 1 (read-only)

    input  wire [31:0] port1_address,
    output reg  [31:0] port1_rdata,
    input  wire        port1_rrequest,
    output reg         port1_rresponse


);

  wire        reset_internal;
  wire [31:0] port0_effective_address;
  wire [31:0] port1_effective_address;
  wire        port0_invalid_address;
  wire        port1_invalid_address;

  reg         reset_reg;
  reg  [31:0] ram                     [0:(MEMORY_SIZE/4)-1];

  always @(posedge clock) reset_reg <= !reset_n;

  assign reset_internal        = !reset_n | reset_reg;
  assign port0_invalid_address = $unsigned(port0_address) >= $unsigned(MEMORY_SIZE);
  assign port1_invalid_address = $unsigned(port1_address) >= $unsigned(MEMORY_SIZE);

  integer i;
  initial begin
    for (i = 0; i < MEMORY_SIZE / 4; i = i + 1) ram[i] = 32'h00000000;
    if (MEMORY_INIT_FILE != "") $readmemh(MEMORY_INIT_FILE, ram);
  end

  assign port0_effective_address = $unsigned(port0_address[31:0] >> 2);
  assign port1_effective_address = $unsigned(port1_address[31:0] >> 2);

  always @(posedge clock) begin
    if (reset_internal | port0_invalid_address) port0_rdata <= 32'h00000000;
    else port0_rdata <= ram[port0_effective_address];
    if (reset_internal | port1_invalid_address) port1_rdata <= 32'h00000000;
    else port1_rdata <= ram[port1_effective_address];
  end

  always @(posedge clock) begin
    if (port0_wrequest) begin
      if (port0_wstrobe[0]) ram[port0_effective_address][7:0] <= port0_wdata[7:0];
      if (port0_wstrobe[1]) ram[port0_effective_address][15:8] <= port0_wdata[15:8];
      if (port0_wstrobe[2]) ram[port0_effective_address][23:16] <= port0_wdata[23:16];
      if (port0_wstrobe[3]) ram[port0_effective_address][31:24] <= port0_wdata[31:24];
    end
  end

  always @(posedge clock) begin
    if (reset_internal) begin
      port0_rresponse <= 1'b0;
      port1_rresponse <= 1'b0;
      port0_wresponse <= 1'b0;
    end
    else begin
      port0_rresponse <= port0_rrequest;
      port1_rresponse <= port1_rrequest;
      port0_wresponse <= port0_wrequest;
    end
  end

  // Avoid warnings about intentionally unused pins/wires
  wire unused_ok = &{1'b0, port0_effective_address[31:11], port1_effective_address[31:11], 1'b0};

endmodule
