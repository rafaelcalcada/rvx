// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module rvsteel_mtimer (

  // Global signals

  input   wire          clock         ,
  input   wire          reset         ,

  // IO interface

  input   wire  [4:0 ]  rw_address    ,
  output  reg   [31:0]  read_data     ,
  input   wire          read_request  ,
  output  reg           read_response ,
  input   wire  [31:0]  write_data    ,
  input   wire  [3:0 ]  write_strobe  ,
  input   wire          write_request ,
  output  reg           write_response,

  // TODO: use it later
  // output  reg        access_fault  ,

  // Side timer irq
  // Interrupt signaling

  output  reg           irq

);

  localparam REG_ADDR_WIDTH   = 2'd3;

  // Map registers
  localparam REG_CR           = 3'd0;
  localparam REG_MTIMEL       = 3'd1;
  localparam REG_MTIMEH       = 3'd2;
  localparam REG_MTIMECMPL    = 3'd3;
  localparam REG_MTIMECMPH    = 3'd4;

  // Map bits
  // CR
  localparam BIT_CR_EN        = 5'd0;
  localparam BIT_CR_WIDTH     = 5'd1;
  localparam CR_PADDING       = {6'd32-BIT_CR_WIDTH{1'd0}};

  // Control register
  reg cr_update;
  reg cr_en;

  // mtime
  reg mtime_l_update;
  reg mtime_h_update;
  reg [63:0] mtime;

  // mtimecmp
  reg mtimecmp_l_update;
  reg mtimecmp_h_update;
  reg [63:0] mtimecmp;


  // Bus
  wire address_aligned;
  assign address_aligned = (~|rw_address[1:0]);

  wire write_word;
  assign write_word = (&write_strobe);

  wire [REG_ADDR_WIDTH-1:0] address;
  assign address = rw_address[2 +:REG_ADDR_WIDTH];

  // Control register
  always @(posedge clock) begin
    if (reset) begin
      cr_en <= 1'b0;
    end else begin
      if (cr_update) begin
        cr_en <= write_data[BIT_CR_EN];
      end
    end
  end


  // mtime
  always @(posedge clock) begin
    if (reset) begin
      mtime <= {64{1'b0}};
    end else begin
      if (cr_en) begin
        mtime <= mtime + 1'd1;
      end

      if (mtime_l_update) begin
        mtime[31:0] <= write_data;
      end

      if (mtime_h_update) begin
        mtime[63:32] <= write_data;
      end
    end
  end


  // mtimecmp
  always @(posedge clock) begin
    if (reset) begin
      mtimecmp <= 64'hffff_ffff_ffff_ffff; // Initially, mtimecmp holds the biggest value so mtime is sure to be smaller than mtimecmp
    end else begin
      if (mtimecmp_l_update) begin
        mtimecmp[31:0] <= write_data;
      end

      if (mtimecmp_h_update) begin
        mtimecmp[63:32] <= write_data;
      end
    end
  end


  // IRQ
  always @(posedge clock) begin
    if (reset) begin
      irq <= 1'b0;
    end else begin
      // Don't update while there is an update
      if (~(mtime_l_update | mtime_h_update | mtimecmp_l_update | mtimecmp_h_update)) begin
        // A machine timer interrupt becomes pending whenever mtime contains a
        // value greater than or equal to mtimecmp
        irq <= (mtime >= mtimecmp);
      end
    end
  end


  // Bus: Response to request
  always @(posedge clock) begin
    if (reset) begin
      read_response <= 1'b0;
      write_response <= 1'b0;
      // access_fault <= 1'b0;
    end else begin
      read_response <= read_request;
      write_response <= write_request;
      // access_fault <= (read_request & !address_aligned) |
      //                 (write_request & !address_aligned) |
      //                 (write_request & !write_word);
    end
  end


  // Bus: Read registers
  always @(posedge clock) begin
    if (reset) begin
      read_data <= 32'd0;
    end else begin
      if (read_request && address_aligned) begin
        case (address)
          REG_CR        : read_data <= {CR_PADDING, cr_en};
          REG_MTIMEL    : read_data <= mtime[31:0];
          REG_MTIMEH    : read_data <= mtime[63:32];
          REG_MTIMECMPL : read_data <= mtimecmp[31:0];
          REG_MTIMECMPH : read_data <= mtimecmp[63:32];
          default: begin end
        endcase
      end
    end
  end


  // Bus: Update registers
  always @(*) begin
    cr_update         = 1'b0;
    mtime_l_update    = 1'b0;
    mtime_h_update    = 1'b0;
    mtimecmp_l_update = 1'b0;
    mtimecmp_h_update = 1'b0;

    if (write_request && address_aligned && write_word) begin
        case (address)
            REG_CR        : cr_update         = 1'b1;
            REG_MTIMEL    : mtime_l_update    = 1'b1;
            REG_MTIMEH    : mtime_h_update    = 1'b1;
            REG_MTIMECMPL : mtimecmp_l_update = 1'b1;
            REG_MTIMECMPH : mtimecmp_h_update = 1'b1;
            default: begin end
        endcase
    end
  end

endmodule
