// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_plic (

    // Global signals
    input wire clock,
    input wire reset_n,

    // IO interface
    input  wire [ 6:0] rw_address,
    output reg  [31:0] read_data,
    input  wire        read_request,
    output reg         read_response,
    input  wire [15:0] write_data,
    input  wire [ 3:0] write_strobe,
    input  wire        write_request,
    output reg         write_response,

    // Interrupt request lines for source IDs 1-16, mapped from plic_sources[0:15]
    input wire [15:0] plic_sources,

    // External interrupt request (asserted while a source is pending)
    output reg plic_irq

);

  // Signals and registers
  // ---------------------------------------------------------------------------

  // One dedicated priority register per source. A priority of 0 disables
  // the source, matching the RISC-V PLIC convention.
  reg     [ 3:0] priority_regs                                                     [1:16];
  reg     [15:0] enable_reg;

  wire    [15:0] masked_pending = plic_sources & enable_reg;

  // PRIORITY1..PRIORITY16 occupy addresses 0x00-0x3c.
  // ENABLE, PENDING, and CLAIM occupy addresses 0x40, 0x44, and 0x48.
  wire           is_priority_reg_addr = !rw_address[6] && rw_address[1:0] == 2'b00;
  wire    [ 4:0] priority_reg_index = {1'b0, rw_address[5:2]} + 5'd1;

  // Priority arbitration logic
  // ---------------------------------------------------------------------------

  integer        i;
  reg     [ 4:0] best_id;
  reg     [ 3:0] best_priority;

  always @* begin
    best_id       = 5'd0;
    best_priority = 4'd0;
    for (i = 1; i <= 16; i = i + 1) begin
      if (masked_pending[i-1] && priority_regs[i] > best_priority) begin
        best_id       = i[4:0];
        best_priority = priority_regs[i];
      end
    end
  end

  // Register read logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n || !read_request) begin
      read_response <= 1'b0;
      read_data     <= 32'h00000000;
    end
    else if (read_request == 1'b1) begin
      read_response <= 1'b1;
      if (is_priority_reg_addr) read_data <= {28'b0, priority_regs[priority_reg_index]};
      else begin
        case (rw_address[6:0])
          `RVX_PLIC_ENABLE_REG_ADDR:  read_data <= {16'b0, enable_reg};
          `RVX_PLIC_PENDING_REG_ADDR: read_data <= {16'b0, masked_pending};
          `RVX_PLIC_CLAIM_REG_ADDR:   read_data <= {27'b0, best_id};
          default:                    read_data <= 32'h00000000;
        endcase
      end
    end
  end

  // Register write logic
  // ---------------------------------------------------------------------------

  wire    valid_write_strobe = (write_strobe == 4'b1111 || write_strobe == 4'b0011 || write_strobe == 4'b0001);
  wire    valid_write_request = write_request == 1'b1 && valid_write_strobe;

  integer j;
  always @(posedge clock) begin
    if (!reset_n) begin
      write_response <= 1'b0;
      for (j = 1; j <= 16; j = j + 1) priority_regs[j] <= 4'd0;
      enable_reg <= 16'h0000;
    end
    else if (valid_write_request == 1'b1) begin
      write_response <= 1'b1;
      if (is_priority_reg_addr) priority_regs[priority_reg_index] <= write_data[3:0];
      else begin
        case (rw_address[6:0])
          `RVX_PLIC_ENABLE_REG_ADDR: enable_reg <= write_data;
          default:                   ;
        endcase
      end
    end
    else write_response <= 1'b0;
  end

  // Interrupt logic
  // ---------------------------------------------------------------------------

  always @(posedge clock) begin
    if (!reset_n) begin
      plic_irq <= 1'b0;
    end
    else begin
      plic_irq <= best_id != 5'd0;
    end
  end

endmodule
