// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_tcm #(

    // Size of the memory in bytes
    parameter SIZE_IN_BYTES = 8192,

    // Path to the file with program and data
    parameter INIT_FILE_PATH = "",

    // Base address of the memory
    parameter BASE_ADDRESS = 32'h00000000

) (

    // Global signals
    input wire clock,
    input wire reset_n,

    // Port 0 (read-only)
    input  wire [31:0] port0_address,
    output reg  [31:0] port0_rdata,
    input  wire        port0_rrequest,
    output reg         port0_rresponse,

    // Port 1 (read/write)
    input  wire [31:0] port1_address,
    output reg  [31:0] port1_rdata,
    input  wire        port1_rrequest,
    output reg         port1_rresponse,
    input  wire [31:0] port1_wdata,
    input  wire [ 3:0] port1_wstrobe,
    input  wire        port1_wrequest,
    output reg         port1_wresponse

);

  localparam NUM_WORDS = SIZE_IN_BYTES / 4;

  reg  [31:0] tcm [BASE_ADDRESS/4 : BASE_ADDRESS/4 + NUM_WORDS - 1];

  // verilator lint_off UNUSED
  wire [31:0] port0_effective_address;
  wire [31:0] port1_effective_address;
  // verilator lint_on UNUSED

  wire        port0_invalid_address;
  wire        port1_invalid_address;

  // verilog_format: off
  // verilator lint_off UNSIGNED
  assign port0_invalid_address = ($unsigned(port0_address) >= $unsigned(SIZE_IN_BYTES + BASE_ADDRESS)) |
                                 ($unsigned(port0_address) <  $unsigned(BASE_ADDRESS));
  assign port1_invalid_address = ($unsigned(port1_address) >= $unsigned(SIZE_IN_BYTES + BASE_ADDRESS)) |
                                 ($unsigned(port1_address) <  $unsigned(BASE_ADDRESS));
  // verilator lint_on UNSIGNED
  // verilog_format: on

  integer i;
  initial begin
    for (i = BASE_ADDRESS/4; i < BASE_ADDRESS/4 + NUM_WORDS; i = i + 1) tcm[i] = 32'h00000000;
    if (INIT_FILE_PATH != "") $readmemh(INIT_FILE_PATH, tcm);
  end

  assign port0_effective_address = $unsigned(port0_address[31:0]) >> 2;
  assign port1_effective_address = $unsigned(port1_address[31:0]) >> 2;

  always @(posedge clock) begin
    if (!reset_n) begin
      port0_rdata <= 32'h00000000;
      port0_rresponse <= 1'b0;
    end
    else if(port0_rrequest && !port0_invalid_address) begin
      port0_rdata <= tcm[port0_effective_address];
      port0_rresponse <= 1'b1;
    end
    else begin
      port0_rdata <= 32'h00000000;
      port0_rresponse <= 1'b0;
    end
    if (!reset_n) begin
      port1_rdata <= 32'h00000000;
      port1_rresponse <= 1'b0;
    end
    else if(port1_rrequest && !port1_invalid_address) begin
      port1_rdata <= tcm[port1_effective_address];
      port1_rresponse <= 1'b1;
    end
    else begin
      port1_rdata <= 32'h00000000;
      port1_rresponse <= 1'b0;
    end
  end

  always @(posedge clock) begin
    if (port1_wrequest && !port1_invalid_address) begin
      port1_wresponse <= 1'b1;
      if (port1_wstrobe[0]) tcm[port1_effective_address][7:0] <= port1_wdata[7:0];
      if (port1_wstrobe[1]) tcm[port1_effective_address][15:8] <= port1_wdata[15:8];
      if (port1_wstrobe[2]) tcm[port1_effective_address][23:16] <= port1_wdata[23:16];
      if (port1_wstrobe[3]) tcm[port1_effective_address][31:24] <= port1_wdata[31:24];
    end
    else port1_wresponse <= 1'b0;
  end

endmodule
