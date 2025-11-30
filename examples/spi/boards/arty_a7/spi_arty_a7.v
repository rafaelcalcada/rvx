// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module spi_arty_a7 #(

    parameter GPIO_WIDTH          = 1,
    parameter SPI_NUM_CHIP_SELECT = 1

) (

    input  wire clock,
    input  wire reset,
    input  wire uart_rx,
    output wire uart_tx,
    output wire sclk,
    output wire pico,
    input  wire poci,
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

  rvx #(

      .CLOCK_FREQUENCY    (50000000),
      .UART_BAUD_RATE     (9600),
      .MEMORY_SIZE        (8192),
      .MEMORY_INIT_FILE   ("spi_demo.hex"),
      .BOOT_ADDRESS       (32'h00000000),
      .GPIO_WIDTH         (GPIO_WIDTH),
      .SPI_NUM_CHIP_SELECT(SPI_NUM_CHIP_SELECT)

  ) rvx_instance (

      .clock      (clock_50mhz),
      .reset_n    (!reset_debounced),
      .halt       (1'b0),
      .uart_rx    (uart_rx),
      .uart_tx    (uart_tx),
      .gpio_input ({GPIO_WIDTH{1'b0}}),  // pull-down
      .gpio_oe    (),                    // unused
      .gpio_output(),                    // unused
      .sclk       (sclk),
      .pico       (pico),
      .poci       (poci),
      .cs         (cs)

  );

endmodule
