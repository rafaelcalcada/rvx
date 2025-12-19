// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module unit_tests (

    input  wire clock,
    input  wire reset,
    input  wire uart_rx,
    output wire uart_tx

);

  wire sclk;
  wire mosi;
  wire miso;
  wire cs;
  wire gpio_cs;

  reg  clock_50mhz;
  reg  reset_debounced;

  always @(posedge clock) clock_50mhz <= !clock_50mhz;
  always @(posedge clock_50mhz) reset_debounced <= reset;

  rvx_ocelot #(

      .MEMORY_SIZE_IN_BYTES (16384),
      .MEMORY_INIT_FILE_PATH("unit_tests.hex"),
      .BOOT_ADDRESS         (32'h00000000)

  ) rvx_ocelot_instance (

      .clock      (clock_50mhz),
      .reset_n    (!reset_debounced),
      .uart_rx    (uart_rx),
      .uart_tx    (uart_tx),
      .sclk       (sclk),
      .mosi       (mosi),
      .miso       (miso),
      .cs         (cs),
      .gpio_output(gpio_cs),

      // This input port is not used in this example and is hardwired to zero
      .gpio_input(1'b0),

      // This output port is not used in this example and can be left unconnected
      // verilator lint_off PINCONNECTEMPTY
      .gpio_oe()
      // verilator lint_on PINCONNECTEMPTY

  );

  test_spi_subordinate_0 test_spi_subordinate_0_instance (

      .clock  (clock_50mhz),
      .reset_n(!reset_debounced),
      .sclk   (sclk),
      .mosi   (mosi),
      .miso   (miso),
      .cs     (cs)

  );

  test_spi_subordinate_1 test_spi_subordinate_1_instance (

      .clock  (clock_50mhz),
      .reset_n(!reset_debounced),
      .sclk   (sclk),
      .mosi   (mosi),
      .miso   (miso),
      .cs     (gpio_cs)

  );

endmodule

// Subordinate device that samples MOSI on rising SCLK edge and updates MISO
// on falling SCLK edge. This corresponds to SPI modes 0 and 3.
// ----------------------------------------------------------------------------

// verilator lint_off DECLFILENAME
module test_spi_subordinate_0 (

    input  wire clock,
    input  wire reset_n,
    input  wire sclk,
    input  wire mosi,
    input  wire cs,
    output wire miso

);

  reg  [7:0] rx_data;
  reg        tx_bit;

  wire       sample_edge;
  reg        sclk_prev;

  always @(posedge clock) begin
    if (!reset_n) begin
      sclk_prev <= 1'b0;
    end
    else begin
      sclk_prev <= sclk;
    end
  end

  // Sample on rising edge of SCLK
  assign sample_edge = !sclk_prev && sclk;

  always @(posedge clock) begin
    if (!reset_n) rx_data <= 8'h00;
    else if (!cs & sample_edge) rx_data <= {rx_data[6:0], mosi};
  end

  always @(negedge clock) begin
    if (!reset_n) tx_bit <= 1'b0;
    else if (!cs & sample_edge) tx_bit <= rx_data[7];
  end

  assign miso = cs ? 1'bZ : tx_bit;

endmodule

// Subordinate device that samples MOSI on falling SCLK edge and updates MISO
// on rising SCLK edge. This corresponds to SPI modes 1 and 2.
// ----------------------------------------------------------------------------

module test_spi_subordinate_1 (

    input  wire clock,
    input  wire reset_n,
    input  wire sclk,
    input  wire mosi,
    input  wire cs,
    output wire miso

);

  reg  [7:0] rx_data;
  reg        tx_bit;

  wire       sample_edge;
  reg        sclk_prev;

  always @(posedge clock) begin
    if (!reset_n) begin
      sclk_prev <= 1'b0;
    end
    else begin
      sclk_prev <= sclk;
    end
  end

  // Sample on falling edge of SCLK
  assign sample_edge = sclk_prev && !sclk;

  always @(posedge clock) begin
    if (!reset_n) rx_data <= 8'h00;
    else if (!cs & sample_edge) rx_data <= {rx_data[6:0], mosi};
  end

  always @(negedge clock) begin
    if (!reset_n) tx_bit <= 1'b0;
    else if (!cs & sample_edge) tx_bit <= rx_data[7];
  end

  assign miso = cs ? 1'bZ : tx_bit;

endmodule
// verilator lint_on DECLFILENAME
