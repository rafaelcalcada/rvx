// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module unit_tests (

  input   wire clock,
  input   wire reset,
  input   wire halt,
  input   wire uart_rx,
  output  wire uart_tx

  );

  localparam NUM_CS_LINES = 2;

  wire sclk;
  wire pico;
  wire poci;
  wire [NUM_CS_LINES-1:0] cs;

  // Divides the 100MHz board block by 4
  reg clock_50mhz;
  initial clock_50mhz = 1'b0;
  always @(posedge clock) clock_50mhz <= !clock_50mhz;

  // Buttons debouncing
  reg reset_debounced;
  reg halt_debounced;
  always @(posedge clock_50mhz) begin
    reset_debounced <= reset;
    halt_debounced <= halt;
  end

  rvsteel_soc #(

    .CLOCK_FREQUENCY          (50000000           ),
    .UART_BAUD_RATE           (9600               ),
    .MEMORY_SIZE              (8192               ),
    .MEMORY_INIT_FILE         ("unit_tests.hex"   ),
    .BOOT_ADDRESS             (32'h00000000       ),
    .NUM_CS_LINES             (2                  )

  ) rvsteel_soc_instance (

    .clock                    (clock_50mhz        ),
    .reset                    (reset_debounced    ),
    .halt                     (halt_debounced     ),
    .uart_rx                  (uart_rx            ),
    .uart_tx                  (uart_tx            ),
    .gpio_input               (                   ),
    .gpio_oe                  (                   ),
    .gpio_output              (                   ),
    .sclk                     (sclk               ),
    .pico                     (pico               ),
    .poci                     (poci               ),
    .cs                       (cs                 )

  );

  dummy_spi_peripheral_modes03
  spi_modes03 (

    .sclk                           (sclk                        ),
    .pico                           (pico                        ),
    .poci                           (poci                        ),
    .cs                             (cs[0]                       )

  );

  dummy_spi_peripheral_modes12
  spi_modes12 (

    .sclk                           (sclk                        ),
    .pico                           (pico                        ),
    .poci                           (poci                        ),
    .cs                             (cs[1]                       )

  );

endmodule

module dummy_spi_peripheral_modes03 (

  input wire sclk,
  input wire pico,
  input wire cs,
  output wire poci

  );

  reg [7:0] rx_data = 8'h00;
  reg tx_bit = 1'b0;
  reg [3:0] bit_count = 7;

  always @(posedge sclk) begin
    if (!cs) rx_data <= {rx_data[6:0], pico};
  end

  always @(negedge sclk) begin
    if (!cs) tx_bit <= rx_data[7];
  end

  assign poci = cs ? 1'bZ : tx_bit;

endmodule

module dummy_spi_peripheral_modes12 (

  input wire sclk,
  input wire pico,
  input wire cs,
  output wire poci

  );

  reg [7:0] rx_data = 8'h00;
  reg tx_bit = 1'b0;
  reg [3:0] bit_count = 7;

  always @(negedge sclk) begin
    if (!cs) rx_data <= {rx_data[6:0], pico};
  end

  always @(posedge sclk) begin
    if (!cs) tx_bit <= rx_data[7];
  end

  assign poci = cs ? 1'bZ : tx_bit;

endmodule