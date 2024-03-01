// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module hello_world_cmod_a7 (

  input   wire clock,
  input   wire reset,  
  input   wire halt,
  input   wire uart_rx,
  output  wire uart_tx

  );
  
  // Buttons debouncing
  reg reset_debounced;
  reg halt_debounced;  
  always @(posedge clock) begin
    reset_debounced <= reset;
    halt_debounced <= halt;
  end

  rvsteel_soc #(

    .CLOCK_FREQUENCY          (12000000           ),
    .UART_BAUD_RATE           (9600               ),
    .MEMORY_SIZE              (8192               ),
    .MEMORY_INIT_FILE         ("hello_world.hex"  ),
    .BOOT_ADDRESS             (32'h00000000       )

  ) rvsteel_soc_instance (
    
    .clock                    (clock              ),
    .reset                    (reset_debounced    ),
    .halt                     (halt_debounced     ),
    .uart_rx                  (uart_rx            ),
    .uart_tx                  (uart_tx            )

  );

endmodule