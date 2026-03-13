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
    output reg irq

);

  // Internal constants
  // ---------------------------------------------------------------------------

  localparam PRESCALE_WIDTH = 16;
  localparam DATA_WIDTH = 8;
  localparam COMMAND_WIDTH = 2;
  localparam STATUS_WIDTH = 3;
  localparam ENCODE_WIDTH = 6;

  // Data and encode preparation
  // ---------------------------------------------------------------------------

  reg  [   DATA_WIDTH-1:0] tx_data;
  reg                      tx_no_acknowledge;
  wire [     DATA_WIDTH:0] tx_data_encode = {tx_data, tx_no_acknowledge};
  reg  [   DATA_WIDTH-1:0] rx_data;
  reg                      rx_no_acknowledge;
  wire [     DATA_WIDTH:0] rx_data_encode;
  reg                      i2c_run;
  reg                      i2c_run_strobe;
  reg  [COMMAND_WIDTH-1:0] command;
  wire [ STATUS_WIDTH-1:0] status = {irq, rx_no_acknowledge, i2c_run | i2c_run_strobe};

  // Commands
  // ---------------------------------------------------------------------------

  localparam COMMAND_START = 2'd0;
  localparam COMMAND_RESTART = 2'd1;
  localparam COMMAND_STOP = 2'd2;
  localparam COMMAND_DATA = 2'd3;

  wire        is_command_start = (command == COMMAND_START);
  wire        is_command_restart = (command == COMMAND_RESTART);
  wire        is_command_stop = (command == COMMAND_STOP);
  wire        is_command_data = (command == COMMAND_DATA);

  reg  [ 7:0] sda_start_encode;
  reg  [ 7:0] scl_start_encode;
  reg  [ 7:0] sda_restart_encode;
  reg  [ 7:0] scl_restart_encode;
  reg  [ 7:0] sda_stop_encode;
  reg  [ 7:0] scl_stop_encode;
  reg  [35:0] sda_data_encode;
  reg  [35:0] scl_data_encode;
  wire [35:0] sda_data_encode_value;
  wire [35:0] scl_data_encode_value;

  genvar i;
  generate
    for (i = 0; i < 9; i = i + 1) begin : out
      assign sda_data_encode_value[(i*4)+:4] = {4{tx_data_encode[i]}};
      assign scl_data_encode_value[(i*4)+:4] = 4'b0110;
      assign rx_data_encode[i]               = sda_data_encode[(i*4)];
    end
  endgenerate

  // Prescale counters
  // ---------------------------------------------------------------------------
  reg  [PRESCALE_WIDTH-1:0] prescale;
  reg  [PRESCALE_WIDTH-1:0] prescale_counter;
  wire                      prescale_count_ok = (prescale_counter == prescale);

  reg  [  ENCODE_WIDTH-1:0] encode_counter;
  reg  [  ENCODE_WIDTH-1:0] encode_count_max;
  wire                      encode_count_ok = (encode_counter == encode_count_max);

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

  always @(posedge clock) begin
    if (!reset_n) begin
      read_data <= 32'h0;
    end
    else if (read_request == 1'b1) begin
      case (rw_address)
        `RVX_I2C_PRESCALE_REG_ADDR: read_data <= {{32 - PRESCALE_WIDTH{1'b0}}, prescale};
        `RVX_I2C_DATA_REG_ADDR:     read_data <= {{32 - DATA_WIDTH{1'b0}}, rx_data};
        `RVX_I2C_COMMAND_REG_ADDR:  read_data <= {{32 - COMMAND_WIDTH{1'b0}}, command};
        `RVX_I2C_STATUS_REG_ADDR:   read_data <= {{32 - STATUS_WIDTH{1'b0}}, status};
        default:                    read_data <= 32'h0;
      endcase
    end
  end

  // Register write logic
  // ---------------------------------------------------------------------------

  wire valid_write_strobe = (write_strobe == 4'b1111 || write_strobe == 4'b0011 || write_strobe == 4'b0001);
  wire valid_write_request = write_request == 1'b1 && valid_write_strobe;

  always @(posedge clock) begin
    if (!reset_n) begin
      prescale <= {PRESCALE_WIDTH{1'b0}};
    end
    else if (rw_address == `RVX_I2C_PRESCALE_REG_ADDR && valid_write_request == 1'b1) begin
      prescale <= write_data[0+:PRESCALE_WIDTH];
    end
  end

  always @(posedge clock) begin
    if (!reset_n) begin
      tx_data <= {DATA_WIDTH{1'b0}};
    end
    else if (rw_address == `RVX_I2C_DATA_REG_ADDR && valid_write_request == 1'b1) begin
      tx_data <= write_data[0+:DATA_WIDTH];
    end
  end

  always @(posedge clock) begin
    if (!reset_n) begin
      command <= COMMAND_START;
    end
    else if (rw_address == `RVX_I2C_COMMAND_REG_ADDR && valid_write_request == 1'b1) begin
      command <= write_data[0+:COMMAND_WIDTH];
    end
  end

  // Run and stop logics
  // ---------------------------------------------------------------------------

  wire write_to_status_reg = (rw_address == `RVX_I2C_STATUS_REG_ADDR && valid_write_request == 1'b1);

  always @(posedge clock) begin
    if (!reset_n) begin
      i2c_run_strobe    <= 1'b0;
      i2c_run           <= 1'b0;
      tx_no_acknowledge <= 1'b0;
      rx_no_acknowledge <= 1'b0;
      irq               <= 1'b0;
      rx_data           <= {DATA_WIDTH{1'b0}};
      encode_count_max  <= {ENCODE_WIDTH{1'b0}};
    end
    else begin
      i2c_run_strobe <= 1'b0;

      if (write_to_status_reg) begin
        i2c_run_strobe    <= write_data[`RVX_I2C_STATUS_BIT_RUN];
        tx_no_acknowledge <= write_data[`RVX_I2C_STATUS_BIT_NOACKNOWLEDGE];
      end

      if (write_to_status_reg && write_data[`RVX_I2C_STATUS_BIT_IRQ]) begin
        irq <= 1'b0;
      end

      if (i2c_run && encode_count_ok && prescale_count_ok) begin
        i2c_run <= 1'b0;
        irq     <= 1'b1;
        if (is_command_data) begin
          rx_no_acknowledge <= rx_data_encode[0];
          rx_data           <= rx_data_encode[1+:DATA_WIDTH];
        end
      end

      if (i2c_run_strobe) begin
        i2c_run <= 1'b1;
        if (is_command_start || is_command_restart || is_command_stop) begin
          encode_count_max <= 6'd6;
        end
        if (is_command_data) begin
          encode_count_max <= 6'd35;
        end
      end
    end
  end

  // Start encode logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (is_command_start && prescale_count_ok && !encode_count_ok) begin
      sda_start_encode <= {sda_start_encode[0+:7], sda_start_encode[7]};
      scl_start_encode <= {scl_start_encode[0+:7], scl_start_encode[7]};
    end

    if (i2c_run_strobe) begin
      sda_start_encode <= 8'b11110000;
      scl_start_encode <= 8'b11111100;
    end
  end

  // Restart encode logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (is_command_restart && prescale_count_ok && !encode_count_ok) begin
      sda_restart_encode <= {sda_restart_encode[0+:7], sda_restart_encode[7]};
      scl_restart_encode <= {scl_restart_encode[0+:7], scl_restart_encode[7]};
    end

    if (i2c_run_strobe) begin
      sda_restart_encode <= 8'b11110000;
      scl_restart_encode <= 8'b00111100;
    end
  end

  // Stop encode logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (is_command_stop && prescale_count_ok && !encode_count_ok) begin
      sda_stop_encode <= {sda_stop_encode[0+:7], sda_stop_encode[7]};
      scl_stop_encode <= {scl_stop_encode[0+:7], scl_stop_encode[7]};
    end

    if (i2c_run_strobe) begin
      sda_stop_encode <= 8'b00011111;
      scl_stop_encode <= 8'b01111111;
    end
  end

  // Data + acknowledge encode logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (is_command_data && prescale_count_ok && !encode_count_ok) begin
      sda_data_encode <= {sda_data_encode[0+:35], sda_input};
      scl_data_encode <= {scl_data_encode[0+:35], 1'b0};
    end

    if (i2c_run_strobe) begin
      sda_data_encode <= sda_data_encode_value;
      scl_data_encode <= scl_data_encode_value;
    end
  end

  // I2C output signals
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) begin
      sda_output <= 1'b1;
      scl_output <= 1'b1;
    end
    else begin
      if (is_command_start && i2c_run) begin
        sda_output <= sda_start_encode[7];
        scl_output <= scl_start_encode[7];
      end

      if (is_command_restart && i2c_run) begin
        sda_output <= sda_restart_encode[7];
        scl_output <= scl_restart_encode[7];
      end

      if (is_command_stop && i2c_run) begin
        sda_output <= sda_stop_encode[7];
        scl_output <= scl_stop_encode[7];
      end

      if (is_command_data && i2c_run) begin
        sda_output <= sda_data_encode[35];
        scl_output <= scl_data_encode[35];
      end
    end
  end

  // Prescale counter for the bit rate generator
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) begin
      prescale_counter <= {PRESCALE_WIDTH{1'b0}};
      encode_counter   <= {ENCODE_WIDTH{1'b0}};
    end
    else begin
      prescale_counter <= prescale_counter + 1'h1;
      if (prescale_count_ok) begin
        prescale_counter <= {PRESCALE_WIDTH{1'b0}};
        encode_counter   <= encode_counter + 1'h1;
      end
      if (!i2c_run || (prescale_count_ok && encode_count_ok)) begin
        prescale_counter <= {PRESCALE_WIDTH{1'b0}};
        encode_counter   <= {ENCODE_WIDTH{1'b0}};
      end
    end
  end

endmodule
