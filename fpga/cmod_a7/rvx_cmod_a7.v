// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_cmod_a7 (

    input  wire clock,
    input  wire reset,
    input  wire uart_rx,
    output wire uart_tx,
    output wire sclk,
    output wire mosi,
    input  wire miso,
    output wire cs

);

  // Reset push-button debouncing
  // ---------------------------------------------------------------------------

  localparam COUNTER_MAX = 240000;  // Equals to 20ms at 12MHz
  reg        reset_sync_0;
  reg        reset_sync_1;
  reg        reset_debounced;
  reg [17:0] reset_counter;

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

      .MEMORY_INIT_FILE("rvx_spi_manager_example.mem")

  ) rvx_instance (

      .clock  (clock),
      .reset_n(!reset_debounced),
      .uart_tx(uart_tx),
      .uart_rx(uart_rx),
      .sclk   (sclk),
      .mosi   (mosi),
      .miso   (miso),
      .cs     (cs),

      // These input ports are not used in this example and are hardwired to zero
      .gpio_input(1'b0),

      // These output ports are not used in this example and can be left unconnected
      // verilator lint_off PINCONNECTEMPTY
      .gpio_output_enable(),
      .gpio_output       ()
      // verilator lint_on PINCONNECTEMPTY

  );

endmodule
