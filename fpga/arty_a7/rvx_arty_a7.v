// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_arty_a7 (

    input  wire clock,
    input  wire reset,
    input  wire uart_rx,
    output wire uart_tx

);

  // Divide Arty 100MHz board clock by 2
  // ---------------------------------------------------------------------------

  reg rvx_clock;
  initial rvx_clock = 1'b0;
  always @(posedge clock) rvx_clock <= !rvx_clock;

  // Reset push-button debouncing
  // ---------------------------------------------------------------------------

  localparam COUNTER_MAX = 1000000;  // Equals to 20ms at 50MHz
  reg        reset_sync_0;
  reg        reset_sync_1;
  reg        reset_debounced;
  reg [19:0] reset_counter;

  always @(posedge clock) begin
    if (reset) begin
      reset_sync_0    <= 1'b1;
      reset_sync_1    <= 1'b1;
      reset_debounced <= 1'b1;
      reset_counter   <= 0;
    end
    else begin
      reset_sync_0 <= reset;
      reset_sync_1 <= reset_sync_0;
      if (reset_sync_1 != reset_debounced) begin
        reset_counter <= reset_counter + 1;
        if (reset_counter >= COUNTER_MAX) begin
          reset_debounced <= reset_sync_1;
          reset_counter   <= 0;
        end
      end
      else reset_counter <= 0;
    end
  end

  // RVX Instantiation
  // ---------------------------------------------------------------------------

  rvx #(

      .MEMORY_INIT_FILE("rvx_hello_world_example.mem")

  ) rvx_instance (

      .clock  (rvx_clock),
      .reset_n(!reset_debounced),
      .uart_tx(uart_tx),
      .uart_rx(uart_rx),

      // These input ports are not used in this example and are hardwired to zero
      .gpio_input(1'b0),
      .miso      (1'b0),

      // These output ports are not used in this example and can be left unconnected
      // verilator lint_off PINCONNECTEMPTY
      .gpio_output_enable(),
      .gpio_output       (),
      .sclk              (),
      .mosi              (),
      .cs                ()
      // verilator lint_on PINCONNECTEMPTY

  );


endmodule
