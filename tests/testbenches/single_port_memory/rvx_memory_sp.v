// ----------------------------------------------------------------------------
// SPDX-FileCopyrightText: Copyright (c) 2026 Universidade Federal do Rio Grande do Sul
// SPDX-FileCopyrightText: Copyright (c) 2026 Fabio Benevenuti
// SPDX-FileCopyrightText: Copyright (c) 2020-2026 RVX Project Contributors
// SPDX-License-Identifier: MIT
//
// Derived from: 
//    https://github.com/rafaelcalcada/rvx commit 8281e4368a5bcc304fb9520960d6d842dcd9c2e9
// Source file: 
//    rtl/memory/rvx_tcm.v
//
// Modifications: parametrized memory content from image file.
// ----------------------------------------------------------------------------


module rvx_memory_sp #(

    // Size of the memory in bytes
    parameter SIZE_IN_BYTES = 8192,

    // Path to the file with program and data
    parameter INIT_FILE_PATH = "",

    // Base address of the memory
    parameter BASE_ADDRESS = 32'h00000000,

    // Port 0 is read only
    parameter PORT0_IS_READ_ONLY = 1'b0

) (

    // Global signals
    input wire clock,
    input wire reset_n,

    // Port 0 (read/write)
    input  wire [31:0] port0_rw_address,
    output reg  [31:0] port0_read_data,
    input  wire        port0_read_request,
    output reg         port0_read_response,
    input  wire [31:0] port0_write_data,
    input  wire [ 3:0] port0_write_strobe,
    input  wire        port0_write_request,
    output reg         port0_write_response
);

  localparam NUM_WORDS = SIZE_IN_BYTES / 4;

  //(* ram_style="block" *)
  //(* rom_style="block" *)
  reg  [31:0] memory                  [BASE_ADDRESS/4 : BASE_ADDRESS/4 + NUM_WORDS - 1];

  // verilator lint_off UNUSED
  wire [31:0] port0_effective_address;
  // verilator lint_on UNUSED

  wire        port0_invalid_address;

  // verilog_format: off
  // verilator lint_off UNSIGNED
  assign port0_invalid_address = ($unsigned(port0_rw_address) >= $unsigned(SIZE_IN_BYTES + BASE_ADDRESS)) |
                                 ($unsigned(port0_rw_address) <  $unsigned(BASE_ADDRESS));
  // verilator lint_on UNSIGNED
  // verilog_format: on

  integer i;
  initial begin
    for (i = BASE_ADDRESS / 4; i < BASE_ADDRESS / 4 + NUM_WORDS; i = i + 1) begin
      memory[i] = 32'h00000000;
    end
    $display("Memory initialized: =================");
    #10;
    for (i = 0; i < 10; i = i + 1) begin
      $display("idx : %d data : %x", i, memory[i]);
    end
    for (i = BASE_ADDRESS / 4; i < BASE_ADDRESS / 4 + 10; i = i + 1) begin
      $display("idx : %d data : %x", i, memory[i]);
    end
    $display("======================");


    if (INIT_FILE_PATH != "") begin
      $display("Loading memory '%s'.", INIT_FILE_PATH);
      $readmemh(INIT_FILE_PATH, memory);

      // Just for debugging readmemh in case it does not work as expected
      $display("Memory loaded: =================");
      #10;
      for (i = 0; i < 10; i = i + 1) begin
        $display("idx : %d data : %x", i, memory[i]);
      end
      for (i = BASE_ADDRESS / 4; i < BASE_ADDRESS / 4 + 10; i = i + 1) begin
        $display("idx : %d data : %x", i, memory[i]);
      end
      $display("======================");
    end

  end

  assign port0_effective_address = $unsigned(port0_rw_address[31:0]) >> 2;

  always @(posedge clock) begin
    if (!reset_n) begin
      port0_read_data     <= 32'h00000000;
      port0_read_response <= 1'b0;
    end
    else if (port0_read_request && !port0_invalid_address) begin
      port0_read_data     <= memory[port0_effective_address];
      port0_read_response <= 1'b1;
    end
    else begin
      port0_read_data     <= 32'h00000000;
      port0_read_response <= 1'b0;
    end
  end



  generate
    if (!PORT0_IS_READ_ONLY) begin : gen_write
      always @(posedge clock) begin
        if (port0_write_request && !port0_invalid_address) begin
          if (port0_write_strobe[0]) begin
            memory[port0_effective_address][7:0] <= port0_write_data[7:0];
          end
          if (port0_write_strobe[1]) begin
            memory[port0_effective_address][15:8] <= port0_write_data[15:8];
          end
          if (port0_write_strobe[2]) begin
            memory[port0_effective_address][23:16] <= port0_write_data[23:16];
          end
          if (port0_write_strobe[3]) begin
            memory[port0_effective_address][31:24] <= port0_write_data[31:24];
          end
        end
      end
    end
  endgenerate


  always @(posedge clock) begin
    if (port0_write_request && !port0_invalid_address) begin
      port0_write_response <= 1'b1;
    end
    else begin
      port0_write_response <= 1'b0;
    end
  end

endmodule
