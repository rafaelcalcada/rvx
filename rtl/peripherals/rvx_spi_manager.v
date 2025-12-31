// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_spi_manager (

    // Global signals
    input wire clock,
    input wire reset_n,

    // IO interface
    input  wire [ 4:0] rw_address,
    output reg  [31:0] read_data,
    input  wire        read_request,
    output reg         read_response,
    input  wire [31:0] write_data,
    input  wire [ 3:0] write_strobe,
    input  wire        write_request,
    output reg         write_response,

    // SPI signals
    output reg  sclk,
    output reg  mosi,
    input  wire miso,
    output wire cs

);

  // SPI FSM states
  localparam STATE_RESET = 4'b0001;
  localparam STATE_READY = 4'b0010;
  localparam STATE_CPOL = 4'b0100;
  localparam STATE_CPOL_N = 4'b1000;

  // Signals and registers
  reg       cpol;
  reg       cpha;
  reg       start_flag;
  reg       chip_select;
  reg       leading_cycle;
  reg [3:0] spi_state;
  reg [7:0] tx_reg;
  reg [7:0] rx_reg;
  reg [3:0] bit_counter;
  reg [7:0] cycle_counter;
  reg [7:0] clock_div;

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

  wire busy = spi_state == STATE_CPOL || spi_state == STATE_CPOL_N || start_flag == 1'b1;

  always @(posedge clock) begin
    if (!reset_n) read_data <= 32'hdeadbeef;
    else if (read_request == 1'b1) begin
      case (rw_address)
        `RVX_SPI_MODE_REG_ADDR:        read_data <= {30'b0, cpol, cpha};
        `RVX_SPI_CHIP_SELECT_REG_ADDR: read_data <= {31'b0, chip_select};
        `RVX_SPI_DIVIDER_REG_ADDR:     read_data <= {24'b0, clock_div};
        `RVX_SPI_WRITE_REG_ADDR:       read_data <= {24'b0, tx_reg};
        `RVX_SPI_READ_REG_ADDR:        read_data <= {24'b0, rx_reg};
        `RVX_SPI_STATUS_REG_ADDR:      read_data <= {31'b0, busy};
        default:                       read_data <= 32'h00000000;
      endcase
    end
    else read_data <= write_data;
  end

  // Register write logic
  // ---------------------------------------------------------------------------

  wire valid_write_strobe = (write_strobe == 4'b1111 || write_strobe == 4'b0011 || write_strobe == 4'b0001);
  wire valid_write_request = write_request == 1'b1 && valid_write_strobe;

  always @(posedge clock) begin
    if (!reset_n) begin
      cpol        <= 1'b0;
      cpha        <= 1'b0;
      chip_select <= 1'b1;
      clock_div   <= 8'h00;
    end
    else if (valid_write_request == 1'b1) begin
      case (rw_address)
        `RVX_SPI_MODE_REG_ADDR: begin
          cpha <= write_data[0];
          cpol <= write_data[1];
        end
        `RVX_SPI_CHIP_SELECT_REG_ADDR: begin
          chip_select <= write_data[0];
        end
        `RVX_SPI_DIVIDER_REG_ADDR: begin
          clock_div <= write_data[7:0];
        end
        default: begin
          cpol        <= cpol;
          cpha        <= cpha;
          chip_select <= chip_select;
          clock_div   <= clock_div;
        end
      endcase
    end
  end

  // Transmission start logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) begin
      tx_reg     <= 8'h00;
      start_flag <= 1'b0;
    end
    else if (rw_address == `RVX_SPI_WRITE_REG_ADDR && valid_write_request == 1'b1) begin
      tx_reg     <= (spi_state == STATE_READY) ? write_data[7:0] : tx_reg;
      start_flag <= (spi_state == STATE_READY) ? 1'b1 : start_flag;
    end
    else begin
      tx_reg     <= tx_reg;
      start_flag <= (spi_state == STATE_CPOL || spi_state == STATE_CPOL_N) ? 1'b0 : start_flag;
    end
  end

  // SPI State Machine
  // ---------------------------------------------------------------------------

  wire [2:0] bit_select = 3'd7 - bit_counter[2:0];

  always @(posedge clock) begin
    if (!reset_n) begin
      sclk          <= cpol;
      mosi          <= 1'b0;
      leading_cycle <= 1'b0;
      bit_counter   <= 4'd0;
      cycle_counter <= 8'd0;
      spi_state     <= STATE_RESET;
    end
    else begin
      case (spi_state)
        STATE_RESET: spi_state <= STATE_READY;
        STATE_READY: begin
          sclk          <= cpol;
          mosi          <= 1'b0;
          bit_counter   <= 4'd0;
          cycle_counter <= 8'd0;
          if (start_flag == 1'b1) begin
            leading_cycle <= 1'b1;
            spi_state     <= cpha == 1'b1 ? STATE_CPOL_N : STATE_CPOL;
          end
        end
        STATE_CPOL: begin
          sclk          <= cpol;
          mosi          <= tx_reg[bit_select];
          cycle_counter <= cycle_counter < clock_div ? cycle_counter + 1 : 0;
          if (cycle_counter >= clock_div) begin
            if (leading_cycle == 1'b1) begin
              if (bit_counter > 7) begin
                leading_cycle <= 1'b0;
                bit_counter   <= 4'd0;
                spi_state     <= STATE_READY;
              end
              else begin
                leading_cycle <= 1'b0;
                bit_counter   <= bit_counter;
                spi_state     <= STATE_CPOL_N;
              end
            end
            else begin
              if (bit_counter + 1 > 7) begin
                leading_cycle <= 1'b0;
                bit_counter   <= 4'd0;
                spi_state     <= STATE_READY;
              end
              else begin
                leading_cycle <= 1'b1;
                bit_counter   <= bit_counter + 1;
                spi_state     <= STATE_CPOL_N;
              end
            end
          end
        end
        STATE_CPOL_N: begin
          sclk          <= ~cpol;
          mosi          <= tx_reg[bit_select];
          cycle_counter <= cycle_counter < clock_div ? cycle_counter + 1 : 0;
          if (cycle_counter >= clock_div) begin
            if (leading_cycle == 1'b1) begin
              if (bit_counter > 7) begin
                leading_cycle <= 1'b0;
                bit_counter   <= 4'd0;
                spi_state     <= STATE_READY;
              end
              else begin
                leading_cycle <= 1'b0;
                bit_counter   <= bit_counter;
                spi_state     <= STATE_CPOL;
              end
            end
            else begin
              if (bit_counter + 1 > 7) begin
                leading_cycle <= 1'b0;
                bit_counter   <= 4'd0;
                spi_state     <= STATE_READY;
              end
              else begin
                leading_cycle <= 1'b1;
                bit_counter   <= bit_counter + 1;
                spi_state     <= STATE_CPOL;
              end
            end
          end
        end
        default: begin
          sclk          <= cpol;
          mosi          <= 1'b0;
          leading_cycle <= 1'b0;
          bit_counter   <= 4'd0;
          cycle_counter <= 8'd0;
          spi_state     <= STATE_READY;
        end
      endcase
    end
  end

  // MISO data reception logic
  // ---------------------------------------------------------------------------

  wire sample_edge;
  reg  sclk_prev;

  always @(posedge clock) begin
    if (!reset_n) begin
      sclk_prev <= cpol;
    end
    else begin
      sclk_prev <= sclk;
    end
  end

  // Detect the sampling edge based on CPOL and CPHA
  assign sample_edge = (cpol ^ cpha) ? (sclk_prev && !sclk) : (!sclk_prev && sclk);

  always @(posedge clock) begin
    if (!reset_n) begin
      rx_reg <= 8'h00;
    end
    else if (sample_edge) begin
      rx_reg[7:0] <= {rx_reg[6:0], miso};
    end
  end

  // Chip select output
  // ---------------------------------------------------------------------------

  assign cs = chip_select;

endmodule
