// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module hello_world_cmod_a7 (

  input   wire clock,
  input   wire reset,
  output  wire uart_tx

  );

  // Push-button debouncing
  reg reset_debounced;
  always @(posedge clock) begin
    reset_debounced <= reset;
  end

  rvx #(

  // Please adjust these two parameters accordingly

  .CLOCK_FREQUENCY          (12000000                   ),
  .MEMORY_INIT_FILE         ("hello_world.hex"          )

  ) rvx_instance (

  // Note that unused inputs are hardwired to zero,
  // while unused outputs are left open.

  .clock                    (clock                      ),
  .reset                    (reset_debounced            ),
  .halt                     (1'b0                       ),
  .uart_rx                  (/* unused, leave open */   ),
  .uart_tx                  (uart_tx                    ),
  .gpio_input               (1'b0                       ),
  .gpio_oe                  (/* unused, leave open */   ),
  .gpio_output              (/* unused, leave open */   ),
  .sclk                     (/* unused, leave open */   ),
  .pico                     (/* unused, leave open */   ),
  .poci                     (1'b0                       ),
  .cs                       (/* unused, leave open */   )

  );

endmodule