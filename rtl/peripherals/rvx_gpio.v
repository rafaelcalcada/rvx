// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module rvx_gpio #(

    parameter GPIO_WIDTH = 1

) (

    // Global signals

    input wire clock,
    input wire reset_n,

    // IO interface

    input  wire [           4:0] rw_address,
    output reg  [          31:0] read_data,
    input  wire                  read_request,
    output reg                   read_response,
    input  wire [GPIO_WIDTH-1:0] write_data,
    input  wire [           3:0] write_strobe,
    input  wire                  write_request,
    output reg                   write_response,

    // I/O signals

    input  wire [GPIO_WIDTH-1:0] gpio_input,
    output wire [GPIO_WIDTH-1:0] gpio_oe,
    output wire [GPIO_WIDTH-1:0] gpio_output

);

  localparam REG_IN = 5'h00;
  localparam REG_OE = 5'h04;
  localparam REG_OUT = 5'h08;
  localparam REG_CLR = 5'h0C;
  localparam REG_SET = 5'h10;


  // Output Enable
  reg [GPIO_WIDTH-1:0] oe;

  // Output data
  reg [GPIO_WIDTH-1:0] out;

  assign gpio_oe     = oe;
  assign gpio_output = out;

  wire address_aligned = (~|rw_address[1:0]);
  wire write_word = (&write_strobe);

  always @(posedge clock) begin
    if (!reset_n) begin
      oe  <= {GPIO_WIDTH{1'b0}};
      out <= {GPIO_WIDTH{1'b0}};
    end
    else if (write_request & address_aligned & write_word) begin
      case (rw_address[4:0])
        REG_OE:  oe <= write_data[0+:GPIO_WIDTH];
        REG_OUT: out <= write_data[0+:GPIO_WIDTH];
        REG_CLR: out <= out & ~write_data[0+:GPIO_WIDTH];
        REG_SET: out <= out | write_data[0+:GPIO_WIDTH];
        default: begin
          oe  <= oe;
          out <= out;
        end
      endcase
    end
  end

  // Bus: Response to request
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

  // Bus: Read registers
  always @(posedge clock) begin
    if (!reset_n) begin
      read_data <= 32'd0;
    end
    else begin
      if (read_request && address_aligned) begin
        case (rw_address[4:0])
          REG_IN:  read_data <= {{32 - GPIO_WIDTH{1'b0}}, (gpio_oe & out) | (~gpio_oe & gpio_input)};
          REG_OE:  read_data <= {{32 - GPIO_WIDTH{1'b0}}, oe};
          REG_OUT: read_data <= {{32 - GPIO_WIDTH{1'b0}}, out};
          REG_CLR: read_data <= 32'd0;
          REG_SET: read_data <= 32'd0;
          default: begin
          end
        endcase
      end
    end
  end

endmodule
