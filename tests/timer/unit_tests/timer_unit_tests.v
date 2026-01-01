// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module timer_unit_tests (

    input  wire clock,
    input  wire reset,
    output wire uart_tx

);

  reg clock_50mhz;
  reg reset_debounced;

  always @(posedge clock) clock_50mhz <= !clock_50mhz;
  always @(posedge clock_50mhz) reset_debounced <= reset;

  rvx_ocelot #(

      .MEMORY_SIZE_IN_BYTES (16384),
      .MEMORY_INIT_FILE_PATH("timer_unit_tests.hex"),
      .BOOT_ADDRESS         (32'h00000000)

  ) rvx_ocelot_instance (

      .clock  (clock_50mhz),
      .reset_n(!reset_debounced),
      .uart_rx(uart_tx),           // Loopback TX to RX
      .uart_tx(uart_tx),

      // These input ports are not used in this test and are hardwired to zero
      .gpio_input(1'b0),
      .miso      (1'b0),

      // These output ports are not used in this test and can be left unconnected
      // verilator lint_off PINCONNECTEMPTY
      .gpio_output_enable(),
      .gpio_output       (),
      .sclk              (),
      .mosi              (),
      .cs                ()

      // verilator lint_on PINCONNECTEMPTY

  );

endmodule
