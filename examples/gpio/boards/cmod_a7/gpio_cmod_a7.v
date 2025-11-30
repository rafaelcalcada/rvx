// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module gpio_cmod_a7 #(

    parameter GPIO_WIDTH = 3

) (

    input  wire                  clock,
    input  wire                  reset,
    input  wire                  uart_rx,
    output wire                  uart_tx,
    inout  wire [GPIO_WIDTH-1:0] gpio

);

  // GPIO signals
  wire [GPIO_WIDTH-1:0] gpio_input;
  wire [GPIO_WIDTH-1:0] gpio_oe;
  wire [GPIO_WIDTH-1:0] gpio_output;

  genvar i;
  for (i = 0; i < GPIO_WIDTH; i = i + 1) begin
    assign gpio_input[i] = gpio_oe[i] == 1'b1 ? gpio_output[i] : gpio[i];
    assign gpio[i]       = gpio_oe[i] == 1'b1 ? gpio_output[i] : 1'bZ;
  end

  // Buttons debouncing
  reg reset_debounced;
  always @(posedge clock) begin
    reset_debounced <= reset;
  end

  rvx #(

      .CLOCK_FREQUENCY (12000000),
      .UART_BAUD_RATE  (9600),
      .MEMORY_SIZE     (8192),
      .MEMORY_INIT_FILE("gpio_demo.hex"),
      .BOOT_ADDRESS    (32'h00000000),
      .GPIO_WIDTH      (3)

  ) rvx_instance (

      .clock      (clock),
      .reset      (reset_debounced),
      .halt       (1'b0),
      .uart_rx    (uart_rx),
      .uart_tx    (uart_tx),
      .gpio_input (gpio_input),
      .gpio_oe    (gpio_oe),
      .gpio_output(gpio_output),
      .sclk       (),                 // unused
      .pico       (),                 // unused
      .poci       (1'b0),
      .cs         ()                  // unused

  );

endmodule
