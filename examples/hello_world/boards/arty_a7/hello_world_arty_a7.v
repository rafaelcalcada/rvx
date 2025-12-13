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

  rvx_ocelot #(

      .MEMORY_INIT_FILE_PATH("hello_world.hex")

  ) rvx_ocelot_instance (

      .clock  (clock_50mhz),
      .reset_n(!reset_debounced),
      .uart_tx(uart_tx),

      // These input ports are not used in this example and are hardwired to zero
      .gpio_input(1'b0),
      .poci      (1'b0),

      // These output ports are not used in this example and can be left unconnected
      // verilator lint_off PINCONNECTEMPTY
      .uart_rx    (),
      .gpio_oe    (),
      .gpio_output(),
      .sclk       (),
      .pico       (),
      .cs         ()
      // verilator lint_on PINCONNECTEMPTY

  );


endmodule
