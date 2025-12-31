// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_timer (

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

    // Timer interrupt request
    output reg timer_irq

);

  // Signals and registers
  reg        counter_enable;
  reg [63:0] counter;
  reg [63:0] compare;

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
        `RVX_TIMER_COUNTER_ENABLE_REG_ADDR: read_data <= {31'b0, counter_enable};
        `RVX_TIMER_COUNTERL_REG_ADDR:       read_data <= counter[31:0];
        `RVX_TIMER_COUNTERH_REG_ADDR:       read_data <= counter[63:32];
        `RVX_TIMER_COMPAREL_REG_ADDR:       read_data <= compare[31:0];
        `RVX_TIMER_COMPAREH_REG_ADDR:       read_data <= compare[63:32];
        default:                            read_data <= 32'h00000000;
      endcase
    end
  end


  // Register write logic
  // ---------------------------------------------------------------------------

  wire valid_write_strobe = (write_strobe == 4'b1111 || write_strobe == 4'b0011 || write_strobe == 4'b0001);
  wire valid_write_request = write_request == 1'b1 && valid_write_strobe;

  always @(posedge clock) begin
    if (!reset_n) begin
      counter_enable <= 1'b0;
      compare[63:0]  <= 64'hffffffff_ffffffff;
    end
    else if (valid_write_request == 1'b1) begin
      case (rw_address[4:0])
        `RVX_TIMER_COUNTER_ENABLE_REG_ADDR: counter_enable <= write_data[0];
        `RVX_TIMER_COMPAREL_REG_ADDR:       compare[31:0] <= write_data;
        `RVX_TIMER_COMPAREH_REG_ADDR:       compare[63:32] <= write_data;
        default:                            ;
      endcase
    end
  end

  // Counter logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) begin
      counter <= 64'd0;
    end
    else begin
      if (valid_write_request == 1'b1) begin
        case (rw_address[4:0])
          `RVX_TIMER_COUNTERL_REG_ADDR: counter[31:0] <= write_data;
          `RVX_TIMER_COUNTERH_REG_ADDR: counter[63:32] <= write_data;
          default:                      ;
        endcase
      end
      else if (counter_enable) begin
        counter <= counter + 64'd1;
      end
    end
  end

  // Interrupt logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) begin
      timer_irq <= 1'b0;
    end
    else begin
      if (valid_write_request == 1'b0) begin
        timer_irq <= (counter >= compare) ? 1'b1 : 1'b0;
      end
    end
  end

endmodule
