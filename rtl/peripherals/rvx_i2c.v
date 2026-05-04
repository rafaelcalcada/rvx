// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_i2c (

    // Global signals
    input wire clock,
    input wire reset_n,

    // IO interface
    input  wire [ 4:0] rw_address,
    output reg  [31:0] read_data,
    input  wire        read_request,
    output reg         read_response,
    input  wire [15:0] write_data,
    input  wire [ 3:0] write_strobe,
    input  wire        write_request,
    output reg         write_response,

    // I2C signals
    input  wire sda_input,
    output reg  sda_output,
    output reg  scl_output,

    // Interrupt request
    output reg i2c_irq

);

  // TX and RX registers
  // ---------------------------------------------------------------------------

  reg  [ 7:0] tx_data;
  reg         tx_ack_bit;
  wire [ 8:0] tx_reg = {tx_data, tx_ack_bit};
  reg  [ 7:0] rx_data;
  reg         rx_ack_bit;
  reg  [ 8:0] rx_reg;

  // Control and status signals
  // ---------------------------------------------------------------------------

  reg         busy;
  reg         start;
  reg         clear_irq;
  reg  [ 2:0] command;
  wire [ 2:0] status = {i2c_irq, rx_ack_bit, busy | start};

  // Shift registers for start, restart, stop, and data commands.
  // They are used to generate the appropriate SDA and SCL waveforms.
  // ---------------------------------------------------------------------------

  reg  [ 3:0] sda_start_shift_reg;
  reg  [ 3:0] scl_start_shift_reg;
  reg  [ 3:0] sda_restart_shift_reg;
  reg  [ 3:0] scl_restart_shift_reg;
  reg  [ 3:0] sda_stop_shift_reg;
  reg  [ 3:0] scl_stop_shift_reg;
  reg  [17:0] sda_data_shift_reg;
  reg  [17:0] scl_data_shift_reg;

  // Counters
  // ---------------------------------------------------------------------------

  reg  [15:0] divider;
  reg  [15:0] cycle_counter;
  wire        shift_enable = (cycle_counter == divider);
  reg  [ 5:0] shift_counter;
  reg  [ 5:0] num_shifts;
  wire        shift_completed = (shift_counter == num_shifts);

  // Register read logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n || !read_request) begin
      read_response <= 1'b0;
      read_data     <= 32'b0;
    end
    else if (read_request == 1'b1) begin
      read_response <= 1'b1;
      case (rw_address)
        `RVX_I2C_DIVIDER_REG_ADDR: read_data <= {16'b0, divider};
        `RVX_I2C_DATA_REG_ADDR:    read_data <= {24'b0, rx_data};
        `RVX_I2C_COMMAND_REG_ADDR: read_data <= {29'b0, command};
        `RVX_I2C_STATUS_REG_ADDR:  read_data <= {29'b0, status};
        default:                   read_data <= {32'b0};
      endcase
    end
  end

  // Register write logic
  // ---------------------------------------------------------------------------

  wire valid_write_strobe = (write_strobe == 4'b1111 || write_strobe == 4'b0011 || write_strobe == 4'b0001);
  wire valid_write_request = write_request == 1'b1 && valid_write_strobe;

  always @(posedge clock) begin
    if (!reset_n) begin
      start          <= 1'b0;
      divider        <= 16'b0;
      tx_data        <= 8'b0;
      tx_ack_bit     <= 1'b0;
      command        <= `RVX_I2C_COMMAND_NOP;
      clear_irq      <= 1'b0;
      write_response <= 1'b0;
    end
    else if (valid_write_request == 1'b1) begin
      write_response <= 1'b1;
      case (rw_address)
        `RVX_I2C_DIVIDER_REG_ADDR: divider <= write_data[15:0];
        `RVX_I2C_DATA_REG_ADDR:    tx_data <= write_data[7:0];
        `RVX_I2C_COMMAND_REG_ADDR: command <= write_data[2:0];
        `RVX_I2C_STATUS_REG_ADDR: begin
          start      <= write_data[`RVX_I2C_STATUS_BIT_RUN];
          tx_ack_bit <= write_data[`RVX_I2C_STATUS_BIT_ACK];
          clear_irq  <= write_data[`RVX_I2C_STATUS_BIT_IRQ];
        end
        default:                   ;
      endcase
    end
    else begin
      start          <= 1'b0;
      clear_irq      <= 1'b0;
      write_response <= 1'b0;
    end
  end

  // Command execution logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) begin
      busy       <= 1'b0;
      i2c_irq    <= 1'b0;
      rx_data    <= 8'b0;
      rx_ack_bit <= 1'b0;
      num_shifts <= 6'b0;
    end
    else begin
      if (start) begin
        busy    <= 1'b1;
        i2c_irq <= 1'b0;
        case (command)
          `RVX_I2C_COMMAND_START:   num_shifts <= 6'd3;
          `RVX_I2C_COMMAND_RESTART: num_shifts <= 6'd3;
          `RVX_I2C_COMMAND_STOP:    num_shifts <= 6'd3;
          `RVX_I2C_COMMAND_DATA:    num_shifts <= 6'd18;
          default:                  num_shifts <= 6'b0;
        endcase
      end
      else if (busy && shift_completed && shift_enable) begin
        busy    <= 1'b0;
        i2c_irq <= 1'b1;
        if (command == `RVX_I2C_COMMAND_DATA) begin
          rx_ack_bit <= rx_reg[0];
          rx_data    <= rx_reg[8:1];
        end
      end
      else if (clear_irq) begin
        i2c_irq <= 1'b0;
      end
    end
  end

  // Start shift register implementation
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n || start) begin
      sda_start_shift_reg <= 4'b1000;
      scl_start_shift_reg <= 4'b1110;
    end
    else if (command == `RVX_I2C_COMMAND_START && shift_enable && !shift_completed) begin
      sda_start_shift_reg <= {sda_start_shift_reg[0+:3], sda_start_shift_reg[3]};
      scl_start_shift_reg <= {scl_start_shift_reg[0+:3], scl_start_shift_reg[3]};
    end
  end

  // Restart shift register implementation
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n || start) begin
      sda_restart_shift_reg <= 4'b1100;
      scl_restart_shift_reg <= 4'b0110;
    end
    else if (command == `RVX_I2C_COMMAND_RESTART && shift_enable && !shift_completed) begin
      sda_restart_shift_reg <= {sda_restart_shift_reg[0+:3], sda_restart_shift_reg[3]};
      scl_restart_shift_reg <= {scl_restart_shift_reg[0+:3], scl_restart_shift_reg[3]};
    end
  end

  // Stop shift register implementation
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n || start) begin
      sda_stop_shift_reg <= 4'b0001;
      scl_stop_shift_reg <= 4'b0111;
    end
    else if (command == `RVX_I2C_COMMAND_STOP && shift_enable && !shift_completed) begin
      sda_stop_shift_reg <= {sda_stop_shift_reg[0+:3], sda_stop_shift_reg[3]};
      scl_stop_shift_reg <= {scl_stop_shift_reg[0+:3], scl_stop_shift_reg[3]};
    end
  end

  // Data shift register implementation
  // ---------------------------------------------------------------------------

  integer i;
  always @(posedge clock) begin
    if (!reset_n || start) begin
      rx_reg <= 9'b0;
      // Duplicate each bit of tx_reg and preload SCL shift register
      // with 50/50 duty cycle clock pattern
      for (i = 0; i < 9; i = i + 1) begin
        sda_data_shift_reg[(i*2)+:2] <= {2{tx_reg[i]}};
        scl_data_shift_reg[(i*2)+:2] <= 2'b01;
      end
    end
    else if (command == `RVX_I2C_COMMAND_DATA && shift_enable && !shift_completed) begin
      sda_data_shift_reg <= {sda_data_shift_reg[0+:17], 1'b0};
      scl_data_shift_reg <= {scl_data_shift_reg[0+:17], 1'b0};
      // Sample SDA on the rising edge of SCL (halfway through the bit period)
      if (shift_counter[0]) begin
        rx_reg <= {rx_reg[0+:8], sda_input};
      end
    end
  end

  // I2C output signals
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) begin
      sda_output <= 1'b1;
      scl_output <= 1'b1;
    end
    else if (busy) begin
      case (command)
        `RVX_I2C_COMMAND_START: begin
          sda_output <= sda_start_shift_reg[3];
          scl_output <= scl_start_shift_reg[3];
        end
        `RVX_I2C_COMMAND_RESTART: begin
          sda_output <= sda_restart_shift_reg[3];
          scl_output <= scl_restart_shift_reg[3];
        end
        `RVX_I2C_COMMAND_STOP: begin
          sda_output <= sda_stop_shift_reg[3];
          scl_output <= scl_stop_shift_reg[3];
        end
        `RVX_I2C_COMMAND_DATA: begin
          sda_output <= sda_data_shift_reg[17];
          scl_output <= scl_data_shift_reg[17];
        end
        default: begin
          sda_output <= 1'b1;
          scl_output <= 1'b1;
        end
      endcase
    end
  end

  // Counters update logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) begin
      cycle_counter <= 16'b0;
      shift_counter <= 6'b0;
    end
    else begin
      if (!busy || (shift_enable && shift_completed)) begin
        cycle_counter <= 16'b0;
        shift_counter <= 6'b0;
      end
      else if (shift_enable) begin
        cycle_counter <= 16'b0;
        shift_counter <= shift_counter + 1'h1;
      end
      else cycle_counter <= cycle_counter + 1'h1;
    end
  end

endmodule
