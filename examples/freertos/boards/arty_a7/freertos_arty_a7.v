// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module freertos_arty_a7 #(

    parameter GPIO_WIDTH = 2

) (

    input  wire                  clock,
    input  wire                  reset,
    input  wire                  halt,
    input  wire                  uart_rx,
    output wire                  uart_tx,
    inout  wire [GPIO_WIDTH-1:0] gpio

);

  // GPIO signals
  wire [GPIO_WIDTH-1:0] gpio_input;
  wire [GPIO_WIDTH-1:0] gpio_output_enable;
  wire [GPIO_WIDTH-1:0] gpio_output;

  genvar i;
  for (i = 0; i < GPIO_WIDTH; i = i + 1) begin
    assign gpio_input[i] = gpio_output_enable[i] == 1'b1 ? gpio_output[i] : gpio[i];
    assign gpio[i]       = gpio_output_enable[i] == 1'b1 ? gpio_output[i] : 1'bZ;
  end

  // Divides the 100MHz board block by 2
  reg clock_50mhz;
  initial clock_50mhz = 1'b0;
  always @(posedge clock) clock_50mhz <= !clock_50mhz;

  // Buttons debouncing
  reg reset_debounced;
  reg halt_debounced;
  always @(posedge clock_50mhz) begin
    reset_debounced <= reset;
    halt_debounced  <= halt;
  end

  rvx #(

      .CLOCK_FREQUENCY (50000000),
      .UART_BAUD_RATE  (9600),
      .MEMORY_SIZE     (32768),
      .MEMORY_INIT_FILE("freertos.hex"),
      .BOOT_ADDRESS    (32'h00000000),
      .GPIO_WIDTH      (2)

  ) rvx_instance (

      .clock             (clock_50mhz),
      .reset_n           (!reset_debounced),
      .halt              (halt_debounced),
      .uart_rx           (uart_rx),
      .uart_tx           (uart_tx),
      .gpio_input        (gpio_input),
      .gpio_output_enable(gpio_output_enable),
      .gpio_output       (gpio_output),
      .sclk              (),                    // unused
      .mosi              (),                    // unused
      .miso              (1'b0),
      .cs                ()                     // unused

  );

endmodule
