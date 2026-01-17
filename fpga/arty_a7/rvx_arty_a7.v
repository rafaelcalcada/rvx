// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_arty_a7 (

    input  wire clock,
    input  wire reset,
    output wire uart_tx

);

  // Divide Arty 100MHz board clock by 2
  reg rvx_clock;
  initial rvx_clock = 1'b0;
  always @(posedge clock) rvx_clock <= !rvx_clock;

  // Push-button debouncing
  reg reset_debounced;
  always @(posedge rvx_clock) reset_debounced <= reset;

  rvx #(

      .MEMORY_INIT_FILE("rvx_hello_world.mem")

  ) rvx_instance (

      .clock  (rvx_clock),
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
