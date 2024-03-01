// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module rvsteel_gpio #(

  parameter GPIO_WIDTH = 2

) (

  // Global signals

  input   wire                    clock         ,
  input   wire                    reset         ,

  // IO interface

  input   wire  [4:0 ]            rw_address    ,
  output  reg   [31:0]            read_data     ,
  input   wire                    read_request  ,
  output  reg                     read_response ,
  input   wire  [1:0 ]            write_data    ,
  input   wire  [3:0 ]            write_strobe  ,
  input   wire                    write_request ,
  output  reg                     write_response,

  // I/O signals

  input   wire  [GPIO_WIDTH-1:0]  gpio_input    ,
  output  wire  [GPIO_WIDTH-1:0]  gpio_oe       ,
  output  wire  [GPIO_WIDTH-1:0]  gpio_output

);

  // Map registers
  localparam REG_ADDR_WIDTH   = 2'd3;

  localparam REG_IN           = 3'd0;
  localparam REG_OE           = 3'd1;
  localparam REG_OUT          = 3'd2;
  localparam REG_CLR          = 3'd3;
  localparam REG_SET          = 3'd4;


  // Output Enable
  reg oe_update;
  reg [GPIO_WIDTH-1:0] oe;

  // Output data
  reg out_update;
  reg [GPIO_WIDTH-1:0] out;

  // Clear mask
  reg clr_update;

  // Set mask
  reg set_update;


  assign gpio_oe = oe;
  assign gpio_output = out;


  // Bus
  wire address_aligned;
  assign address_aligned = (~|rw_address[1:0]);

  wire write_word;
  assign write_word = (&write_strobe);

  wire [REG_ADDR_WIDTH-1:0] address;
  assign address = rw_address[2 +:REG_ADDR_WIDTH];


  always @(posedge clock) begin
    if (reset) begin
      oe <= {GPIO_WIDTH{1'b0}};
      out <= {GPIO_WIDTH{1'b0}};
    end else begin
      if (oe_update) begin
        oe <= write_data[0 +: GPIO_WIDTH];
      end

      if (out_update) begin
        out <= write_data[0 +: GPIO_WIDTH];
      end

      if (clr_update) begin
        out <= out & ~write_data[0 +: GPIO_WIDTH];
      end

      if (set_update) begin
        out <= out | write_data[0 +: GPIO_WIDTH];
      end
    end
  end


  // Bus: Response to request
  always @(posedge clock) begin
    if (reset) begin
      read_response <= 1'b0;
      write_response <= 1'b0;
    end else begin
      read_response <= read_request;
      write_response <= write_request;
    end
  end


  // Bus: Read registers
  always @(posedge clock) begin
    if (reset) begin
      read_data <= 32'd0;
    end else begin
      if (read_request && address_aligned) begin
        case (address)
          REG_IN    : read_data <= {{32-GPIO_WIDTH{1'b0}}, gpio_input};
          REG_OE    : read_data <= {{32-GPIO_WIDTH{1'b0}}, oe};
          REG_OUT   : read_data <= {{32-GPIO_WIDTH{1'b0}}, out};
          REG_CLR   : read_data <= 32'd0;
          REG_SET   : read_data <= 32'd0;
          default: begin end
        endcase
      end
    end
  end


  // Bus: Update registers
  always @(*) begin
    oe_update   = 1'b0;
    out_update  = 1'b0;
    clr_update  = 1'b0;
    set_update  = 1'b0;

    if (write_request && address_aligned && write_word) begin
        case (address)
            REG_OE    : oe_update   = 1'b1;
            REG_OUT   : out_update  = 1'b1;
            REG_CLR   : clr_update  = 1'b1;
            REG_SET   : set_update  = 1'b1;
            default: begin end
        endcase
    end
  end

endmodule
