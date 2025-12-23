// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_uart (

    // Global signals
    input wire clock,
    input wire reset_n,

    // Register read/write
    input  wire [ 4:0] rw_address,
    output reg  [31:0] read_data,
    input  wire        read_request,
    output reg         read_response,
    input  wire [31:0] write_data,
    input  wire        write_request,
    output reg         write_response,

    // RX/TX signals
    input  wire uart_rx,
    output wire uart_tx,

    // Interrupt request
    output reg uart_irq

);

  // Signals and registers
  reg [31:0] cycles_per_baud;
  reg [31:0] tx_cycle_counter;
  reg [31:0] rx_cycle_counter;
  reg [ 3:0] tx_bit_counter;
  reg [ 3:0] rx_bit_counter;
  reg [ 9:0] tx_register;
  reg [ 7:0] rx_register;
  reg [ 7:0] rx_data;
  reg        rx_started;

  // Write and read responses
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) begin
      read_response  <= 1'b0;
      write_response <= 1'b0;
    end
    else begin
      read_response  <= read_request;
      write_response <= write_request;
    end
  end

  // Register read logic
  // ---------------------------------------------------------------------------

  wire ready_to_send = (tx_bit_counter == 0);

  always @(posedge clock) begin
    if (!reset_n) begin
      read_data <= 32'h00000000;
    end
    else if (read_request == 1'b1) begin
      case (rw_address[4:0])
        `RVX_UART_READ_REG_ADDR:   read_data <= {24'b0, rx_data};
        `RVX_UART_STATUS_REG_ADDR: read_data <= {30'b0, uart_irq, ready_to_send};
        `RVX_UART_BAUD_REG_ADDR:   read_data <= cycles_per_baud;
        default:                   read_data <= 32'h00000000;
      endcase
    end
  end

  // Register write logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) begin
      cycles_per_baud <= 0;
    end
    else if (rw_address == `RVX_UART_BAUD_REG_ADDR && write_request == 1'b1) begin
      cycles_per_baud <= write_data;
    end
  end

  // TX logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n || cycles_per_baud == 0) begin
      tx_cycle_counter <= 0;
      tx_register      <= 10'b1111111111;
      tx_bit_counter   <= 0;
    end
    else if (tx_bit_counter == 0 && rw_address == `RVX_UART_WRITE_REG_ADDR && write_request == 1'b1) begin
      tx_cycle_counter <= 1;
      tx_register      <= {1'b1, write_data[7:0], 1'b0};
      tx_bit_counter   <= 10;
    end
    else begin
      if (tx_cycle_counter < cycles_per_baud) begin
        tx_cycle_counter <= tx_cycle_counter + 1;
        tx_register      <= tx_register;
        tx_bit_counter   <= tx_bit_counter;
      end
      else begin
        tx_cycle_counter <= 1;
        tx_register      <= {1'b1, tx_register[9:1]};
        tx_bit_counter   <= tx_bit_counter > 0 ? tx_bit_counter - 1 : 0;
      end
    end
  end

  // RX logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n || cycles_per_baud == 0) begin
      rx_cycle_counter <= 1;
      rx_register      <= 8'h00;
      rx_data          <= 8'h00;
      rx_bit_counter   <= 0;
      uart_irq         <= 1'b0;
      rx_started       <= 1'b0;
    end
    else if (uart_irq == 1'b1) begin
      if (rw_address == `RVX_UART_READ_REG_ADDR && read_request == 1'b1) begin
        uart_irq <= 1'b0;
      end
    end
    else if (!rx_started) begin
      if (uart_rx == 1'b0) begin
        if (rx_cycle_counter < {1'b0, cycles_per_baud[31:1]}) begin
          rx_cycle_counter <= rx_cycle_counter + 1;
        end
        else begin
          rx_cycle_counter <= 1;
          rx_bit_counter   <= 0;
          rx_started       <= 1'b1;
        end
      end
      else begin
        rx_cycle_counter <= 1;
      end
    end
    else begin
      if (rx_cycle_counter < cycles_per_baud) begin
        rx_cycle_counter <= rx_cycle_counter + 1;
      end
      else begin
        rx_cycle_counter <= 1;
        rx_register      <= {uart_rx, rx_register[7:1]};
        rx_bit_counter   <= rx_bit_counter + 1;
        if (rx_bit_counter == 8) begin
          rx_data    <= rx_register;
          uart_irq   <= 1'b1;
          rx_started <= 1'b0;
        end
      end
    end
  end

  // TX output assignment
  // ---------------------------------------------------------------------------

  assign uart_tx = tx_register[0];

endmodule
