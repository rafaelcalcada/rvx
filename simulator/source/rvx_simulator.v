// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_simulator #(

    /* verilator public_flat_rd_on */
    parameter RAM_SIZE_IN_BYTES = 2097152,
    parameter ENABLE_ZMMUL      = 1
    /* verilator public_off */

) (

    input clock,
    input reset_n

);

  // SPI signals
  wire        spi_sclk;
  wire        spi_mosi;
  wire        spi_miso;
  wire        spi_cs;

  // GPIO outputs
  // verilator lint_off UNUSEDSIGNAL
  wire [31:0] gpio_output;  // Only bit 0 is used for SPI subordinate CS
  // verilator lint_on UNUSEDSIGNAL

  // UART loopback
  wire        uart_loopback;

  rvx #(

      .RAM_SIZE_IN_BYTES(RAM_SIZE_IN_BYTES),
      .ENABLE_ZMMUL     (ENABLE_ZMMUL),
      .GPIO_PIN_COUNT   (32)

  ) rvx_instance (

      .clock      (clock),
      .reset_n    (reset_n),
      .uart_rx    (uart_loopback),
      .uart_tx    (uart_loopback),
      .spi_sclk   (spi_sclk),
      .spi_mosi   (spi_mosi),
      .spi_miso   (spi_miso),
      .spi_cs     (spi_cs),
      .gpio_output(gpio_output),

      // The GPIO and I2C input ports are hardwired to a known value for simulation purposes
      .gpio_input   (32'ha5a5a5a5),
      .i2c_sda_input(1'b1),
      .i2c_scl_input(1'b1),

      // The output enable port is not used by the simulator and is left unconnected
      // verilator lint_off PINCONNECTEMPTY
      .gpio_output_enable(),
      .i2c_sda_output    (),
      .i2c_scl_output    ()
      // verilator lint_on PINCONNECTEMPTY

  );

  test_spi_subordinate_0 test_spi_subordinate_0_instance (

      .clock   (clock),
      .reset_n (reset_n),
      .spi_sclk(spi_sclk),
      .spi_mosi(spi_mosi),
      .spi_miso(spi_miso),
      .spi_cs  (spi_cs)

  );

  test_spi_subordinate_1 test_spi_subordinate_1_instance (

      .clock   (clock),
      .reset_n (reset_n),
      .spi_sclk(spi_sclk),
      .spi_mosi(spi_mosi),
      .spi_miso(spi_miso),
      .spi_cs  (gpio_output[0])

  );

endmodule

// Subordinate device that samples MOSI on rising SCLK edge and updates MISO
// on falling SCLK edge. This corresponds to SPI modes 0 and 3.
// ----------------------------------------------------------------------------

// verilator lint_off DECLFILENAME
module test_spi_subordinate_0 (

    input  wire clock,
    input  wire reset_n,
    input  wire spi_sclk,
    input  wire spi_mosi,
    input  wire spi_cs,
    output wire spi_miso

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
      sclk_prev <= spi_sclk;
    end
  end

  // Sample on rising edge of SCLK
  assign sample_edge = !sclk_prev && spi_sclk;

  always @(posedge clock) begin
    if (!reset_n) rx_data <= 8'h00;
    else if (!spi_cs & sample_edge) rx_data <= {rx_data[6:0], spi_mosi};
  end

  always @(negedge clock) begin
    if (!reset_n) tx_bit <= 1'b0;
    else if (!spi_cs & sample_edge) tx_bit <= rx_data[7];
  end

  assign spi_miso = spi_cs ? 1'bZ : tx_bit;

endmodule

// Subordinate device that samples MOSI on falling SCLK edge and updates MISO
// on rising SCLK edge. This corresponds to SPI modes 1 and 2.
// ----------------------------------------------------------------------------

module test_spi_subordinate_1 (

    input  wire clock,
    input  wire reset_n,
    input  wire spi_sclk,
    input  wire spi_mosi,
    input  wire spi_cs,
    output wire spi_miso

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
      sclk_prev <= spi_sclk;
    end
  end

  // Sample on falling edge of SCLK
  assign sample_edge = sclk_prev && !spi_sclk;

  always @(posedge clock) begin
    if (!reset_n) rx_data <= 8'h00;
    else if (!spi_cs & sample_edge) rx_data <= {rx_data[6:0], spi_mosi};
  end

  always @(negedge clock) begin
    if (!reset_n) tx_bit <= 1'b0;
    else if (!spi_cs & sample_edge) tx_bit <= rx_data[7];
  end

  assign spi_miso = spi_cs ? 1'bZ : tx_bit;

endmodule
// verilator lint_on DECLFILENAME
