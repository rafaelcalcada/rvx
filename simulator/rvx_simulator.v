// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_simulator #(

    parameter MEMORY_SIZE_IN_BYTES = 2097152,
    parameter BOOT_ADDRESS         = 32'h00000000,
    parameter ENABLE_ZMMUL         = 1

) (

    input clock,
    input reset_n

);

  // SPI signals
  wire sclk;
  wire mosi;
  wire miso;
  wire cs;

  rvx #(

      .MEMORY_SIZE_IN_BYTES(MEMORY_SIZE_IN_BYTES),
      .BOOT_ADDRESS        (BOOT_ADDRESS),
      .ENABLE_ZMMUL        (ENABLE_ZMMUL),
      .GPIO_WIDTH          (32)

  ) rvx_instance (

      .clock  (clock),
      .reset_n(reset_n),
      .sclk   (sclk),
      .mosi   (mosi),
      .miso   (miso),
      .cs     (cs),

      // The GPIO input ports are hardwired to a known value for simulation purposes
      .gpio_input(32'ha5a5a5a5),

      // The UART RX line is held high (idle) for simulation purposes
      .uart_rx(1'b1),

      // These output ports are not used by the simulator and are left unconnected
      // verilator lint_off PINCONNECTEMPTY
      .uart_tx           (),
      .gpio_output_enable(),
      .gpio_output       ()
      // verilator lint_on PINCONNECTEMPTY

  );

  test_spi_subordinate test_spi_subordinate_instance (

      .clock  (clock),
      .reset_n(reset_n),
      .sclk   (sclk),
      .mosi   (mosi),
      .miso   (miso),
      .cs     (cs)

  );

endmodule

// Subordinate device that samples MOSI on rising SCLK edge and updates MISO
// on falling SCLK edge. This corresponds to SPI modes 0 and 3.
// ----------------------------------------------------------------------------

// verilator lint_off DECLFILENAME
module test_spi_subordinate (

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
// verilator lint_on DECLFILENAME
