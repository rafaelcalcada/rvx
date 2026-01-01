// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module spi_arty_a7 (

    input  wire clock,
    input  wire reset,
    input  wire uart_rx,
    output wire uart_tx,
    output wire sclk,
    output wire mosi,
    input  wire miso,
    output wire cs

);

  // Divides the 100MHz board block by 2
  reg clock_50mhz;
  initial clock_50mhz = 1'b0;
  always @(posedge clock) clock_50mhz <= !clock_50mhz;

  // Buttons debouncing
  reg reset_debounced;
  always @(posedge clock_50mhz) begin
    reset_debounced <= reset;
  end

  rvx_ocelot #(

      .MEMORY_SIZE_IN_BYTES (8192),
      .MEMORY_INIT_FILE_PATH("spi_demo.hex"),
      .BOOT_ADDRESS         (32'h00000000)

  ) rvx_ocelot_instance (

      .clock  (clock_50mhz),
      .reset_n(!reset_debounced),
      .uart_rx(uart_rx),
      .uart_tx(uart_tx),
      .sclk   (sclk),
      .mosi   (mosi),
      .miso   (miso),
      .cs     (cs),

      // This input port is not used in this example and is hardwired to zero
      .gpio_input(1'b0),

      // These output ports are not used in this example and can be left unconnected
      // verilator lint_off PINCONNECTEMPTY
      .gpio_output_enable(),
      .gpio_output       ()
      // verilator lint_on PINCONNECTEMPTY

  );

endmodule
