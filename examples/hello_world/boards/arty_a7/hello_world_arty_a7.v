// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module hello_world_arty_a7 (

    input  wire clock,
    input  wire reset,
    output wire uart_tx

);

  // Divides the 100MHz board block by 2
  reg clock_50mhz;
  initial clock_50mhz = 1'b0;
  always @(posedge clock) clock_50mhz <= !clock_50mhz;

  // Push-button debouncing
  reg reset_debounced;
  always @(posedge clock_50mhz) begin
    reset_debounced <= reset;
  end

  rvx #(

      // Please adjust these two parameters accordingly

      .CLOCK_FREQUENCY (50000000),
      .MEMORY_INIT_FILE("hello_world.hex")

  ) rvx_instance (

      // Note that unused inputs are hardwired to zero,
      // while unused outputs are left open.

      .clock      (clock_50mhz),
      .reset      (reset_debounced),
      .halt       (1'b0),
      .uart_rx    (  /* unused, leave open */),
      .uart_tx    (uart_tx),
      .gpio_input (1'b0),
      .gpio_oe    (  /* unused, leave open */),
      .gpio_output(  /* unused, leave open */),
      .sclk       (  /* unused, leave open */),
      .pico       (  /* unused, leave open */),
      .poci       (1'b0),
      .cs         (  /* unused, leave open */)

  );

endmodule
