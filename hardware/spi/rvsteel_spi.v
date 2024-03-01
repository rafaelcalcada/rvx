// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module rvsteel_spi #(

  parameter NUM_CS_LINES = 1

  )(

  // Global signals

  input   wire                      clock           ,
  input   wire                      reset           ,

  // IO interface

  input  wire   [4:0 ]              rw_address      ,
  output reg    [31:0]              read_data       ,
  input  wire                       read_request    ,
  output reg                        read_response   ,
  input  wire   [7:0 ]              write_data      ,
  input  wire   [3:0 ]              write_strobe    ,
  input  wire                       write_request   ,
  output reg                        write_response  ,

  // SPI signals

  output reg                        sclk            ,
  output reg                        pico            ,
  input  wire                       poci            ,
  output reg    [NUM_CS_LINES-1:0]  cs

  );

  reg tx_start;
  reg cpol;
  reg cpha;
  reg clk_edge;
  reg sclk_internal;
  reg pico_internal;
  reg [NUM_CS_LINES-1:0] cs_internal;
  reg [3:0] curr_state;
  reg [3:0] next_state;
  reg [3:0] bit_count;
  reg [7:0] tx_reg;
  reg [7:0] rx_reg;
  reg [7:0] chip_select;
  reg [7:0] cycle_counter;
  reg [7:0] clock_div;

  // SPI State Machine
  localparam SPI_READY        = 4'b0001;
  localparam SPI_IDLE         = 4'b0010;
  localparam SPI_CPOL         = 4'b0100;
  localparam SPI_CPOL_N       = 4'b1000;

  // Register addresses
  localparam REG_CPOL           = 5'h00;
  localparam REG_CPHA           = 5'h04;
  localparam REG_CHIP_SELECT    = 5'h08;
  localparam REG_CLOCK_DIV      = 5'h0c;
  localparam REG_WDATA          = 5'h10;
  localparam REG_RDATA          = 5'h14;
  localparam REG_STATUS         = 5'h18;

  wire busy_bit = curr_state == SPI_CPOL || curr_state == SPI_CPOL_N;
  wire valid_write_request = write_request == 1'b1 && &write_strobe == 1'b1;

  integer i;

  always @(posedge clock) begin
    if (reset) begin
      read_response <= 1'b0;
      write_response <= 1'b0;
    end
    else begin
      read_response <= read_request;
      write_response <= write_request;
    end
  end

  always @(posedge clock) begin
    if (reset)
      read_data <= 32'hdeadbeef;
    else if (read_request == 1'b1) begin
      case (rw_address)
        REG_CPOL:         read_data <= {31'b0, cpol};
        REG_CPHA:         read_data <= {31'b0, cpha};
        REG_CHIP_SELECT:  read_data <= {24'b0, chip_select};
        REG_CLOCK_DIV:    read_data <= {24'b0, clock_div};
        REG_RDATA:        read_data <= {24'b0, rx_reg};
        REG_STATUS:       read_data <= {31'b0, busy_bit};
        default:          read_data <= 32'hdeadbeef;
      endcase
    end
    else
      read_data <= 32'hdeadbeef;
  end

  always @(posedge clock) begin
    if (reset)
      cpol <= 1'b0;
    else if (rw_address == REG_CPOL && valid_write_request == 1'b1)
      cpol <= write_data[0];
    else
      cpol <= cpol;
  end

  always @(posedge clock) begin
    if (reset)
      cpha <= 1'b0;
    else if (rw_address == REG_CPHA && valid_write_request == 1'b1)
      cpha <= write_data[0];
    else
      cpha <= cpha;
  end

  always @(posedge clock) begin
    if (reset)
      chip_select <= 8'hff;
    else if (rw_address == REG_CHIP_SELECT && valid_write_request == 1'b1)
      chip_select <= write_data[7:0];
    else
      chip_select <= chip_select;
  end

  always @(posedge clock) begin
    if (reset)
      clock_div <= 8'h00;
    else if (rw_address == REG_CLOCK_DIV && valid_write_request == 1'b1)
      clock_div <= write_data[7:0];
    else
      clock_div <= clock_div;
  end

  always @(posedge clock) begin
    if (reset) begin
      tx_reg <= 8'h00;
      tx_start <= 1'b0;
    end
    else if (rw_address == REG_WDATA && valid_write_request == 1'b1) begin
      tx_reg <= (curr_state == SPI_READY || curr_state == SPI_IDLE) ? write_data[7:0] : tx_reg;
      tx_start <= (curr_state == SPI_READY || curr_state == SPI_IDLE) ? 1'b1 : tx_start;
    end
    else begin
      tx_reg <= tx_reg;
      tx_start <= (curr_state == SPI_CPOL || curr_state == SPI_CPOL_N) ? 1'b0 : tx_start;
    end
  end

  always @(posedge clock) begin
    if (reset | chip_select == 8'hff)
      curr_state <= SPI_READY;
    else
      curr_state <= next_state;
  end

  always @(posedge clock) begin
    if (reset || curr_state == SPI_READY || curr_state == SPI_IDLE)
      cycle_counter <= 0;
    else if (curr_state == SPI_CPOL && next_state == SPI_CPOL_N)
      cycle_counter <= 0;
    else if (curr_state == SPI_CPOL_N && next_state == SPI_CPOL)
      cycle_counter <= 0;
    else
      cycle_counter <= cycle_counter + 1;
  end

  always @(posedge clock) begin
    if (reset || curr_state == SPI_READY || curr_state == SPI_IDLE)
      bit_count <= 7;
    else if (cpha == 1'b0 && curr_state == SPI_CPOL_N && next_state == SPI_CPOL)
      bit_count <= bit_count - 1;
    else if (cpha == 1'b1 && curr_state == SPI_CPOL && next_state == SPI_CPOL_N)
      bit_count <= bit_count - 1;
    else
      bit_count <= bit_count;
  end

  always @* begin
    for (i = 0; i < NUM_CS_LINES; i=i+1) begin
      cs_internal[i] = ({24'd0, chip_select} == i) ? 1'b0 : 1'b1;
    end
    case (curr_state)
      SPI_READY: begin
        sclk_internal = cpol;
        pico_internal = tx_reg[7];
        next_state = tx_start == 1'b1 ? (cpha == 1'b1 ? SPI_CPOL_N : SPI_CPOL) : curr_state;
      end
      SPI_CPOL: begin
        sclk_internal = cpol;
        pico_internal = tx_reg[bit_count[2:0]];
        next_state = cycle_counter < clock_div ? curr_state : (bit_count == 0 && cpha == 1'b1 ? SPI_IDLE : SPI_CPOL_N);
      end
      SPI_CPOL_N: begin
        sclk_internal = !cpol;
        pico_internal = tx_reg[bit_count[2:0]];
        next_state = cycle_counter < clock_div ? curr_state : (bit_count == 0 && cpha == 1'b0 ? SPI_IDLE : SPI_CPOL);
      end
      SPI_IDLE: begin
        sclk_internal = cpol;
        pico_internal = tx_reg[0];
        next_state = chip_select == 8'hff ? SPI_READY : (tx_start == 1'b1 ? (cpha == 1'b1 ? SPI_CPOL_N : SPI_CPOL) : curr_state);
      end
      default: begin
        sclk_internal = cpol;
        pico_internal = tx_reg[7];
        next_state = tx_start == 1'b1 ? SPI_CPOL : curr_state;
      end
    endcase
  end

  always @(posedge clock) begin
    if (reset) begin
      sclk <= 1'b0;
      pico <= 1'b0;
      cs <= {NUM_CS_LINES{1'b1}};
    end
    else begin
      sclk <= sclk_internal;
      pico <= pico_internal;
      cs <= cs_internal;
    end
  end

  always @(posedge clock) begin
    clk_edge <= cpol ^ cpha ? !sclk_internal : sclk_internal;
  end

  always @(posedge clk_edge) begin
    rx_reg[7:0] <= {rx_reg[6:0], poci};
  end

endmodule
