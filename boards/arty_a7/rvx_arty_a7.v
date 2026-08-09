// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_arty_a7 #(

    parameter GPIO_PIN_COUNT = 3

) (

    input  wire clock,
    input  wire uart_rx,
    output wire uart_tx,
    output wire sclk,
    output wire mosi,
    input  wire miso,
    output wire cs,
    inout  wire sda,
    inout  wire scl,
    input  wire push_button_0,  // Used for reset
    input  wire push_button_1,  // Used for toggling LED
    output wire led_4,
    output wire led_5

);

  wire                  i2c_sda_output;
  wire                  i2c_scl_output;
  wire [GPIO_PIN_COUNT-1:0] gpio_output_enable;
  wire [GPIO_PIN_COUNT-1:0] gpio_input;
  wire [GPIO_PIN_COUNT-1:0] gpio_output;

  // Number of clock cycles in 20ms at 50MHz (Arty A7 board clock frequency)
  localparam NUM_CYCLES_IN_20_MS = 1000000;

  reg        rvx_clock;
  reg        push_button_0_sync_0;
  reg        push_button_1_sync_0;
  reg        push_button_0_sync_1;
  reg        push_button_1_sync_1;
  reg        push_button_0_debounced;
  reg        push_button_1_debounced;
  reg [20:0] push_button_0_counter;
  reg [20:0] push_button_1_counter;

  // RVX Instantiation
  // ---------------------------------------------------------------------------

  rvx #(

      .TCM_SIZE_IN_BYTES(32768),
      .GPIO_PIN_COUNT       (GPIO_PIN_COUNT)

  ) rvx_instance (

      .clock             (rvx_clock),
      .reset_n           (!push_button_0_debounced),
      .uart_tx           (uart_tx),
      .uart_rx           (uart_rx),
      .sclk              (sclk),
      .mosi              (mosi),
      .miso              (miso),
      .cs                (cs),
      .gpio_input        (gpio_input),
      .gpio_output_enable(gpio_output_enable),
      .gpio_output       (gpio_output),
      .i2c_sda_input     (sda),
      .i2c_scl_input     (scl),
      .i2c_sda_output    (i2c_sda_output),
      .i2c_scl_output    (i2c_scl_output)

  );

  assign sda           = (i2c_sda_output) ? 1'bz : 1'b0;
  assign scl           = (i2c_scl_output) ? 1'bz : 1'b0;
  assign gpio_input[0] = gpio_output_enable[0] ? gpio_output[0] : led_4;
  assign gpio_input[1] = gpio_output_enable[1] ? gpio_output[1] : push_button_1_debounced;
  assign gpio_input[2] = gpio_output_enable[2] ? gpio_output[2] : led_5;
  assign led_4         = gpio_output[0];
  assign led_5         = gpio_output[2];

  // Divide Arty 100MHz board clock by 2
  // ---------------------------------------------------------------------------

  initial rvx_clock = 1'b0;
  always @(posedge clock) rvx_clock <= !rvx_clock;

  // Push-buttons debouncing
  // ---------------------------------------------------------------------------

  always @(posedge rvx_clock) begin
    if (push_button_0) begin
      push_button_0_sync_0    <= 1'b1;
      push_button_0_sync_1    <= 1'b1;
      push_button_0_debounced <= 1'b1;
      push_button_0_counter   <= 0;
      push_button_1_sync_0    <= 1'b1;
      push_button_1_sync_1    <= 1'b1;
      push_button_1_debounced <= 1'b1;
      push_button_1_counter   <= 0;
    end
    else begin
      push_button_0_sync_0 <= push_button_0;
      push_button_0_sync_1 <= push_button_0_sync_0;
      push_button_1_sync_0 <= push_button_1;
      push_button_1_sync_1 <= push_button_1_sync_0;
      if (push_button_0_sync_1 != push_button_0_debounced) begin
        push_button_0_counter <= push_button_0_counter + 1;
        if (push_button_0_counter >= NUM_CYCLES_IN_20_MS) begin
          push_button_0_debounced <= push_button_0_sync_1;
          push_button_0_counter   <= 0;
        end
      end
      else push_button_0_counter <= 0;
      if (push_button_1_sync_1 != push_button_1_debounced) begin
        push_button_1_counter <= push_button_1_counter + 1;
        if (push_button_1_counter >= NUM_CYCLES_IN_20_MS) begin
          push_button_1_debounced <= push_button_1_sync_1;
          push_button_1_counter   <= 0;
        end
      end
      else push_button_1_counter <= 0;
    end
  end

endmodule
