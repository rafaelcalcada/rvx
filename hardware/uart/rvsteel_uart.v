// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module rvsteel_uart #(

  parameter CLOCK_FREQUENCY = 50000000,
  parameter UART_BAUD_RATE  = 9600

  )(

  // Global signals

  input   wire          clock,
  input   wire          reset,

  // IO interface

  input  wire   [4:0 ]  rw_address,
  output reg    [31:0]  read_data,
  input  wire           read_request,
  output reg            read_response,
  input  wire   [7:0]   write_data,
  input  wire           write_request,
  output reg            write_response,

  // RX/TX signals

  input   wire          uart_rx,
  output  wire          uart_tx,

  // Interrupt signaling

  output  reg           uart_irq,
  input   wire          uart_irq_response

  );

  localparam CYCLES_PER_BAUD = CLOCK_FREQUENCY / UART_BAUD_RATE;

  reg [31:0] tx_cycle_counter = 0;
  reg [31:0] rx_cycle_counter = 0;
  reg [3:0]  tx_bit_counter;
  reg [3:0]  rx_bit_counter;
  reg [9:0]  tx_register;
  reg [7:0]  rx_register;
  reg [7:0]  rx_data;
  reg        rx_active;
  reg        reset_reg;

  wire       reset_internal;

  always @(posedge clock)
    reset_reg <= reset;

  assign reset_internal = reset | reset_reg;

  assign uart_tx = tx_register[0];

  always @(posedge clock) begin
    if (reset_internal) begin
      tx_cycle_counter <= 0;
      tx_register <= 10'b1111111111;
      tx_bit_counter <= 0;
    end
    else if (tx_bit_counter == 0 &&
             rw_address == 5'h00 &&
             write_request == 1'b1) begin
      tx_cycle_counter <= 0;
      tx_register <= {1'b1, write_data[7:0], 1'b0};
      tx_bit_counter <= 10;
    end
    else begin
      if (tx_cycle_counter < CYCLES_PER_BAUD) begin
        tx_cycle_counter <= tx_cycle_counter + 1;
        tx_register <= tx_register;
        tx_bit_counter <= tx_bit_counter;
      end
      else begin
        tx_cycle_counter <= 0;
        tx_register <= {1'b1, tx_register[9:1]};
        tx_bit_counter <= tx_bit_counter > 0 ? tx_bit_counter - 1 : 0;
      end
    end
  end

  always @(posedge clock) begin
    if (reset_internal) begin
      rx_cycle_counter <= 0;
      rx_register <= 8'h00;
      rx_data <= 8'h00;
      rx_bit_counter <= 0;
      uart_irq <= 1'b0;
      rx_active <= 1'b0;
    end
    else if (uart_irq == 1'b1) begin
      if (uart_irq_response == 1'b1) begin
        rx_cycle_counter <= 0;
        rx_register <= 8'h00;
        rx_data <= rx_data;
        rx_bit_counter <= 0;
        uart_irq <= 1'b0;
        rx_active <= 1'b0;
      end
      else begin
        rx_cycle_counter <= 0;
        rx_register <= 8'h00;
        rx_data <= rx_data;
        rx_bit_counter <= 0;
        uart_irq <= 1'b1;
        rx_active <= 1'b0;
      end
    end
    else if (rx_bit_counter == 0 && rx_active == 1'b0) begin
      if (uart_rx == 1'b1) begin
        rx_cycle_counter <= 0;
        rx_register <= 8'h00;
        rx_data <= rx_data;
        rx_bit_counter <= 0;
        uart_irq <= 1'b0;
        rx_active <= 1'b0;
      end
      else if (uart_rx == 1'b0) begin
        if (rx_cycle_counter < CYCLES_PER_BAUD / 2) begin
          rx_cycle_counter <= rx_cycle_counter + 1;
          rx_register <= 8'h00;
          rx_data <= rx_data;
          rx_bit_counter <= 0;
          uart_irq <= 1'b0;
          rx_active <= 1'b0;
        end
        else begin
          rx_cycle_counter <= 0;
          rx_register <= 8'h00;
          rx_data <= rx_data;
          rx_bit_counter <= 8;
          uart_irq <= 1'b0;
          rx_active <= 1'b1;
        end
      end
    end
    else begin
      if (rx_cycle_counter < CYCLES_PER_BAUD) begin
        rx_cycle_counter <= rx_cycle_counter + 1;
        rx_register <= rx_register;
        rx_data <= rx_data;
        rx_bit_counter <= rx_bit_counter;
        uart_irq <= 1'b0;
        rx_active <= 1'b1;
      end
      else begin
        rx_cycle_counter <= 0;
        rx_register <= {uart_rx, rx_register[7:1]};
        rx_data <= (rx_bit_counter == 0) ? rx_register : rx_data;
        rx_bit_counter <= rx_bit_counter > 0 ? rx_bit_counter - 1 : 0;
        uart_irq <= (rx_bit_counter == 0) ? 1'b1 : 1'b0;
        rx_active <= 1'b1;
      end
    end
  end

  always @(posedge clock) begin
    if (reset_internal) begin
      read_response  <= 1'b0;
      write_response <= 1'b0;
    end
    else begin
      read_response  <= read_request;
      write_response <= write_request;
    end
  end

  always @(posedge clock) begin
    if (reset_internal)
      read_data <= 32'h00000000;
    else if (rw_address == 5'h00 && read_request == 1'b1)
      read_data <= {31'b0, tx_bit_counter == 0};
    else if (rw_address == 5'h04 && read_request == 1'b1)
      read_data <= {24'b0, rx_data};
    else
      read_data <= 32'h00000000;
  end

endmodule
