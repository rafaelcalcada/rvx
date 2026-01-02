// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_gpio #(

    parameter GPIO_WIDTH = 1

) (

    // Global signals
    input wire clock,
    input wire reset_n,

    // Register read/write
    input  wire [ 4:0] rw_address,
    output reg  [31:0] read_data,
    input  wire        read_request,
    output reg         read_response,
    // verilator lint_off UNUSEDSIGNAL
    input  wire [31:0] write_data,
    // verilator lint_on UNUSEDSIGNAL
    input  wire [ 3:0] write_strobe,
    input  wire        write_request,
    output reg         write_response,

    // GPIO signals
    input  wire [GPIO_WIDTH-1:0] gpio_input,
    output reg  [GPIO_WIDTH-1:0] gpio_output_enable,
    output reg  [GPIO_WIDTH-1:0] gpio_output

);

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
      read_data <= 32'h00000000;
    end
    else if (read_request == 1'b1) begin
      case (rw_address[4:0])
        `RVX_GPIO_READ_REG_ADDR: begin
          read_data <= {
            {32 - GPIO_WIDTH{1'b0}}, (gpio_output_enable & gpio_output) | (~gpio_output_enable & gpio_input)
          };
        end
        `RVX_GPIO_OUTPUT_ENABLE_REG_ADDR: read_data <= {{32 - GPIO_WIDTH{1'b0}}, gpio_output_enable};
        `RVX_GPIO_OUTPUT_REG_ADDR:        read_data <= {{32 - GPIO_WIDTH{1'b0}}, gpio_output};
        default:                          read_data <= 32'h00000000;
      endcase
    end
  end

  // Register write logic
  // ---------------------------------------------------------------------------

  wire valid_write_strobe = (write_strobe == 4'b1111 || write_strobe == 4'b0011 || write_strobe == 4'b0001);
  wire valid_write_request = write_request == 1'b1 && valid_write_strobe;

  always @(posedge clock) begin
    if (!reset_n) begin
      gpio_output_enable <= {GPIO_WIDTH{1'b0}};
      gpio_output        <= {GPIO_WIDTH{1'b0}};
    end
    else if (valid_write_request == 1'b1) begin
      case (rw_address[4:0])
        `RVX_GPIO_OUTPUT_ENABLE_REG_ADDR: gpio_output_enable <= write_data[0+:GPIO_WIDTH];
        `RVX_GPIO_OUTPUT_REG_ADDR:        gpio_output <= write_data[0+:GPIO_WIDTH];
        `RVX_GPIO_CLEAR_REG_ADDR:         gpio_output <= gpio_output & ~write_data[0+:GPIO_WIDTH];
        `RVX_GPIO_SET_REG_ADDR:           gpio_output <= gpio_output | write_data[0+:GPIO_WIDTH];
        default: begin
          gpio_output_enable <= gpio_output_enable;
          gpio_output        <= gpio_output;
        end
      endcase
    end
  end

endmodule
