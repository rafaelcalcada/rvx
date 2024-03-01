// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module hello_world_arty_a7 (

  input   wire clock,
  input   wire reset,
  input   wire halt,
  input   wire uart_rx,
  output  wire uart_tx

  );

  // Divides the 100MHz board block by 2
  reg clock_50mhz;
  initial clock_50mhz = 1'b0;  
  always @(posedge clock) clock_50mhz <= !clock_50mhz;
  
  // Buttons debouncing
  reg reset_debounced;
  reg halt_debounced;  
  always @(posedge clock_50mhz) begin
    reset_debounced <= reset;
    halt_debounced <= halt;
  end

  rvsteel_soc #(

    .CLOCK_FREQUENCY          (50000000           ),
    .UART_BAUD_RATE           (9600               ),
    .MEMORY_SIZE              (8192               ),
    .MEMORY_INIT_FILE         ("hello_world.hex"  ),
    .BOOT_ADDRESS             (32'h00000000       )

  ) rvsteel_soc_instance (
    
    .clock                    (clock_50mhz        ),
    .reset                    (reset_debounced    ),
    .halt                     (halt_debounced     ),
    .uart_rx                  (uart_rx            ),
    .uart_tx                  (uart_tx            )

  );

endmodule