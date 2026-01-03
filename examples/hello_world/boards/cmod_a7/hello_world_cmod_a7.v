// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module hello_world_cmod_a7 (

    input  wire clock,
    input  wire reset,
    output wire uart_tx

);

  // Push-button debouncing
  reg reset_debounced;
  always @(posedge clock) begin
    reset_debounced <= reset;
  end

  rvx #(

      .MEMORY_INIT_FILE_PATH("hello_world.hex")

  ) rvx_instance (

      // Note that unused inputs are hardwired to zero,
      // while unused outputs are left open.

      .clock  (clock),
      .reset_n(!reset_debounced),
      .uart_tx(uart_tx),

      // These input ports are not used in this example and are hardwired to zero
      .gpio_input(1'b0),
      .miso      (1'b0),

      // These output ports are not used in this example and can be left unconnected
      // verilator lint_off PINCONNECTEMPTY
      .uart_rx           (),
      .gpio_output_enable(),
      .gpio_output       (),
      .sclk              (),
      .mosi              (),
      .cs                ()
      // verilator lint_on PINCONNECTEMPTY

  );

endmodule
