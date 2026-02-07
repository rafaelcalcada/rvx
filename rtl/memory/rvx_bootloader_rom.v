// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

// RVX Bootloader Read-Only Memory (ROM) Module
module rvx_bootloader_rom #(

    // Size of the memory in bytes
    parameter SIZE_IN_BYTES = 1024,

    // Path to the file with program and data
    parameter INIT_FILE_PATH = ""

) (

    // Global signals
    input wire clock,
    input wire reset_n,

    // Read-only port
    input  wire [31:0] address,
    output reg  [31:0] rdata,
    input  wire        rrequest,
    output reg         rresponse

);

  reg  [31:0] rom               [0:SIZE_IN_BYTES/4-1];

  // verilator lint_off UNUSEDSIGNAL
  wire [31:0] effective_address;
  // verilator lint_on UNUSEDSIGNAL

  wire        invalid_address;

  assign invalid_address = $unsigned(address) >= $unsigned(SIZE_IN_BYTES);

  integer i;
  initial begin
    for (i = 0; i < SIZE_IN_BYTES / 4; i = i + 1) rom[i] = 32'h00000000;
    if (INIT_FILE_PATH != "") $readmemh(INIT_FILE_PATH, rom);
  end

  assign effective_address = $unsigned(address[31:0] >> 2);

  always @(posedge clock) begin
    if (!reset_n | invalid_address) rdata <= 32'h00000000;
    else rdata <= rom[effective_address];
  end

  always @(posedge clock) begin
    if (!reset_n) begin
      rresponse <= 1'b0;
    end
    else begin
      rresponse <= rrequest;
    end
  end

endmodule
