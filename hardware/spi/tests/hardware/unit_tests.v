// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

`timescale 1ns / 1ps

module unit_tests();

  localparam NUM_CS_LINES = 8;

  // Global signals

  reg                       clock           ;
  reg                       reset           ;

  // IO interface

  reg   [4:0 ]              rw_address      ;
  wire  [31:0]              read_data       ;
  reg                       read_request    ;
  wire                      read_response   ;
  reg   [7:0 ]              write_data      ;
  reg   [3:0 ]              write_strobe    ;
  reg                       write_request   ;
  wire                      write_response  ;

  // SPI signals

  wire                      sclk            ;
  wire                      pico            ;
  wire                      poci            ;
  wire  [NUM_CS_LINES-1:0]  cs              ;

  rvsteel_spi #(

    .NUM_CS_LINES                   (NUM_CS_LINES                )

  ) rvsteel_spi_instance (

    // Global signals

    .clock                          (clock                       ),
    .reset                          (reset                       ),

    // IO interface

    .rw_address                     (rw_address                  ),
    .read_data                      (read_data                   ),
    .read_request                   (read_request                ),
    .read_response                  (read_response               ),
    .write_data                     (write_data                  ),
    .write_strobe                   (write_strobe                ),
    .write_request                  (write_request               ),
    .write_response                 (write_response              ),

    // SPI signals

    .sclk                           (sclk                        ),
    .pico                           (pico                        ),
    .poci                           (poci                        ),
    .cs                             (cs                          )

  );

  dummy_spi_peripheral_modes03 spi_modes03 (

    .sclk                           (sclk                        ),
    .pico                           (pico                        ),
    .poci                           (poci                        ),
    .cs                             (cs[0]                       )

  );

  dummy_spi_peripheral_modes12 spi_modes12 (

    .sclk                           (sclk                        ),
    .pico                           (pico                        ),
    .poci                           (poci                        ),
    .cs                             (cs[1]                       )

  );

  // 50MHz clock (20ns period)
  initial clock = 1'b0;
  always #10 clock = !clock;

  integer i;
  integer error_flag;
  integer error_count;

  initial begin

    error_count     = 0;
    reset           = 1'b0;
    rw_address      = 32'b0;
    read_request    = 1'b0;
    write_request   = 1'b0;
    write_strobe    = 4'b0;
    write_data      = 32'b0;

    #20;

    reset           = 1'b1;

    #20;

    reset           = 1'b0;

    #20;

    // Test #1 - Check whether all CS lines are HIGH after reset
    error_flag = 0;
    $display("Running unit test #1...");
    for (i = 0; i < NUM_CS_LINES; i=i+1) begin
      if (cs[i] !== 1'b1) begin
        error_flag = 1;
        error_count = error_count + 1;
        $display("[ERROR] CS (Chip Select) %d is not logic HIGH after reset.", i);
      end
    end

    // Test #2 - Check whether pico is zero after reset
    error_flag = 0;
    $display("Running unit test #2...");
    if (pico !== 1'b0) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] PICO pin is not HIGH IMPEDANCE after reset.");
    end

    // Test #3 - Check whether CPOL is 0 after reset
    error_flag = 0;
    $display("Running unit test #3...");
    #20;
    rw_address      = 5'h00;
    read_request    = 1'b1;
    #20;
    read_request    = 1'b0;
    if (read_data !== 32'h00000000) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] CPOL register is not 0 after reset. Actual value: 0x%h", read_data);
    end

    // Test #4 - Check whether CPHA is 0 after reset
    error_flag = 0;
    $display("Running unit test #4...");
    #20;
    rw_address      = 5'h04;
    read_request    = 1'b1;
    #20;
    read_request    = 1'b0;
    if (read_data !== 32'h00000000) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] CPHA register is not 0 after reset. Actual value: 0x%h", read_data);
    end

    // Test #5 - Check writing to CPOL register (legal value)
    error_flag = 0;
    $display("Running unit test #5...");
    #20;
    rw_address      = 5'h00;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    read_request    = 1'b1;
    #20;
    read_request    = 1'b0;
    if (read_data !== 32'h00000001) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Writing to CPOL register failed. Expected value: 0x%h. Actual value: 0x%h", write_data, read_data);
    end

    // Test #6 - Check writing to CPHA register (legal value)
    error_flag = 0;
    $display("Running unit test #6...");
    #20;
    rw_address      = 5'h04;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    read_request    = 1'b1;
    #20;
    read_request    = 1'b0;
    if (read_data !== 32'h00000001) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Writing to CPHA register failed. Expected value: 0x%h. Actual value: 0x%h", write_data, read_data);
    end

    // Test #7 - Check writing to CPOL register (illegal value)
    error_flag = 0;
    $display("Running unit test #7...");
    #20;
    rw_address      = 5'h00;
    write_data      = 8'hff;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    read_request    = 1'b1;
    #20;
    read_request    = 1'b0;
    if (read_data !== 32'h00000001) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Writing illegal value to CPOL register. Expected value: 0x%h. Actual value: 0x%h", 32'h00000001, read_data);
    end

    // Test #8 - Check writing to CPHA register (illegal value)
    error_flag = 0;
    $display("Running unit test #8...");
    #20;
    rw_address      = 5'h04;
    write_data      = 8'h78;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    read_request    = 1'b1;
    #20;
    read_request    = 1'b0;
    if (read_data !== 32'h00000000) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Writing illegal value to CPHA register. Expected value: 0x%h. Actual value: 0x%h", 32'h00000000, read_data);
    end

    // Test #9 - Check writing 0 to CPOL register (legal value)
    error_flag = 0;
    $display("Running unit test #9...");
    #20;
    rw_address      = 5'h00;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    read_request    = 1'b1;
    #20;
    read_request    = 1'b0;
    if (read_data !== 32'h00000000) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Writing to CPOL register failed. Expected value: 0x%h. Actual value: 0x%h", write_data, read_data);
    end

    // Test #10 - Check writing 0 to CPHA register (legal value)
    error_flag = 0;
    $display("Running unit test #10...");
    #20;
    rw_address      = 5'h04;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    read_request    = 1'b1;
    #20;
    read_request    = 1'b0;
    if (read_data !== 32'h00000000) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Writing to CPHA register failed. Expected value: 0x%h. Actual value: 0x%h", write_data, read_data);
    end

    // Test #11 - Check deasserting and asserting CS lines
    error_flag = 0;
    $display("Running unit test #11...");
    for (i = 0; i < NUM_CS_LINES; i=i+1) begin
      #20;
      rw_address      = 5'h08;
      write_data      = i;
      write_strobe    = 4'b1111;
      write_request   = 1'b1;
      #20;
      write_request   = 1'b0;
      read_request    = 1'b1;
      #20;
      read_request    = 1'b0;
      if (read_data !== i) begin
        error_flag = 1;
        error_count = error_count + 1;
        $display("[ERROR] Writing to CS register failed. Expected value: 0x%h. Actual value: 0x%h", write_data, read_data);
      end
      if (cs[i] !== 1'b0) begin
        error_flag = 1;
        error_count = error_count + 1;
        $display("[ERROR] CS line %d expected to be deasserted.", i);
      end
    end
    #20;
    rw_address      = 5'h08;
    write_data      = 8'hff;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    read_request    = 1'b1;
    #20;
    read_request    = 1'b0;
    if (read_data !== 32'h000000ff) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Writing to CS register failed. Expected value: 0x%h. Actual value: 0x%h", write_data, read_data);
    end
    for (i = 0; i < NUM_CS_LINES; i=i+1) begin
      if (cs[i] !== 1'b1) begin
        error_flag = 1;
        error_count = error_count + 1;
        $display("[ERROR] CS line %d expected to be deasserted.", i);
      end
    end

    // Test #12 - Test sending/receiving a byte at base speed, MODE 0
    error_flag = 0;
    $display("Running unit test #12...");
    #20;
    rw_address      = 5'h00;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h04;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h0c;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h08;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #40;
    if (cs[0] !== 1'b0) begin
      $display("[ERROR] CS line #0 expected to be logic LOW.");
      error_count = error_count + 1;
    end
    rw_address      = 5'h10;
    write_data      = 8'hf0;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #120;
    rw_address      = 5'h10;
    write_data      = 8'h0f;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40;
    rw_address      = 5'h08;
    write_data      = 8'hff;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    if (cs[0] !== 1'b1) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] CS line #0 was expected to be asserted.");
    end
    #40;
    rw_address      = 5'h14;
    read_request   = 1'b1;
    #40;
    if (read_data !== 32'h000000f0) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Read data is not what it is expected to be.");
    end

    // Test #13 - Test sending/receiving a byte at base speed, MODE 1
    error_flag = 0;
    $display("Running unit test #13...");
    #20;
    rw_address      = 5'h00;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h04;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h0c;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h08;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #40;
    if (cs[1] !== 1'b0) begin
      $display("[ERROR] CS line #1 expected to be logic LOW.");
      error_count = error_count + 1;
    end
    rw_address      = 5'h10;
    write_data      = 8'hf0;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #120;
    rw_address      = 5'h10;
    write_data      = 8'h0f;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40;
    rw_address      = 5'h08;
    write_data      = 8'hff;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    if (cs[1] !== 1'b1) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] CS line #1 was expected to be asserted.");
    end
    #40;
    rw_address      = 5'h14;
    read_request   = 1'b1;
    #40;
    if (read_data !== 32'h000000f0) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Read data is not what it is expected to be.");
    end

    // Test #14 - Test sending/receiving a byte at base speed, MODE 2
    error_flag = 0;
    $display("Running unit test #14...");
    #20;
    rw_address      = 5'h00;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h04;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h0c;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h08;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #40;
    if (cs[1] !== 1'b0) begin
      $display("[ERROR] CS line #1 expected to be logic LOW.");
      error_count = error_count + 1;
    end
    rw_address      = 5'h10;
    write_data      = 8'hf0;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #120;
    rw_address      = 5'h10;
    write_data      = 8'h0f;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40;
    rw_address      = 5'h08;
    write_data      = 8'hff;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    if (cs[1] !== 1'b1) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] CS line #1 was expected to be asserted.");
    end
    #40;
    rw_address      = 5'h14;
    read_request   = 1'b1;
    #40;
    if (read_data !== 32'h000000f0) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Read data is not what it is expected to be.");
    end

    // Test #15 - Test sending/receiving a byte at base speed, MODE 3
    error_flag = 0;
    $display("Running unit test #15...");
    #20;
    rw_address      = 5'h00;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h04;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h0c;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h08;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #40;
    if (cs[0] !== 1'b0) begin
      $display("[ERROR] CS line #0 expected to be logic LOW.");
      error_count = error_count + 1;
    end
    rw_address      = 5'h10;
    write_data      = 8'hf0;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #120;
    rw_address      = 5'h10;
    write_data      = 8'h0f;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #40;
    rw_address      = 5'h08;
    write_data      = 8'hff;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    if (cs[0] !== 1'b1) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] CS line #0 was expected to be asserted.");
    end
    #40;
    rw_address      = 5'h14;
    read_request   = 1'b1;
    #40;
    if (read_data !== 32'h000000f0) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Read data is not what it is expected to be.");
    end

    // Test #16 - Test sending/receiving a byte at clock / 50, MODE 0
    error_flag = 0;
    $display("Running unit test #16...");
    #20;
    rw_address      = 5'h00;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h04;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h0c;
    write_data      = 8'h19;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h08;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #40;
    if (cs[0] !== 1'b0) begin
      $display("[ERROR] CS line #0 expected to be logic LOW.");
      error_count = error_count + 1;
    end
    rw_address      = 5'h10;
    write_data      = 8'hf0;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #2000;
    rw_address      = 5'h10;
    write_data      = 8'h0f;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000;
    rw_address      = 5'h08;
    write_data      = 8'hff;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    if (cs[0] !== 1'b1) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] CS line #0 was expected to be asserted.");
    end
    #40;
    rw_address      = 5'h14;
    read_request   = 1'b1;
    #40;
    if (read_data !== 32'h000000f0) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Read data is not what it is expected to be.");
    end

    // Test #17 - Test sending/receiving a byte at clock / 50, MODE 1
    error_flag = 0;
    $display("Running unit test #17...");
    #20;
    rw_address      = 5'h00;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h04;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h0c;
    write_data      = 8'h19;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h08;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #40;
    if (cs[1] !== 1'b0) begin
      $display("[ERROR] CS line #1 expected to be logic LOW.");
      error_count = error_count + 1;
    end
    rw_address      = 5'h10;
    write_data      = 8'hf0;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #2000;
    rw_address      = 5'h10;
    write_data      = 8'h0f;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000;
    rw_address      = 5'h08;
    write_data      = 8'hff;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    if (cs[1] !== 1'b1) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] CS line #1 was expected to be asserted.");
    end
    #40;
    rw_address      = 5'h14;
    read_request   = 1'b1;
    #40;
    if (read_data !== 32'h000000f0) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Read data is not what it is expected to be.");
    end

    // Test #18 - Test sending/receiving a byte at clock / 50, MODE 2
    error_flag = 0;
    $display("Running unit test #18...");
    #20;
    rw_address      = 5'h00;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h04;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h0c;
    write_data      = 8'h19;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h08;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #40;
    if (cs[1] !== 1'b0) begin
      $display("[ERROR] CS line #1 expected to be logic LOW.");
      error_count = error_count + 1;
    end
    rw_address      = 5'h10;
    write_data      = 8'hf0;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #2000;
    rw_address      = 5'h10;
    write_data      = 8'h0f;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000;
    rw_address      = 5'h08;
    write_data      = 8'hff;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    if (cs[1] !== 1'b1) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] CS line #1 was expected to be asserted.");
    end
    #40;
    rw_address      = 5'h14;
    read_request   = 1'b1;
    #40;
    if (read_data !== 32'h000000f0) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Read data is not what it is expected to be.");
    end

    // Test #19 - Test sending/receiving a byte at clock / 50, MODE 3
    error_flag = 0;
    $display("Running unit test #19...");
    #20;
    rw_address      = 5'h00;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h04;
    write_data      = 8'h01;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h0c;
    write_data      = 8'h19;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    rw_address      = 5'h08;
    write_data      = 8'h00;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #40;
    if (cs[0] !== 1'b0) begin
      $display("[ERROR] CS line #0 expected to be logic LOW.");
      error_count = error_count + 1;
    end
    rw_address      = 5'h10;
    write_data      = 8'hf0;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #2000;
    rw_address      = 5'h10;
    write_data      = 8'h0f;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b0) begin $display("[ERROR] PICO pin expected to be logic LOW."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000 if (pico !== 1'b1) begin $display("[ERROR] PICO pin expected to be logic HIGH."); error_count = error_count + 1; end
    #1000;
    rw_address      = 5'h08;
    write_data      = 8'hff;
    write_strobe    = 4'b1111;
    write_request   = 1'b1;
    #20;
    write_request   = 1'b0;
    #20;
    if (cs[0] !== 1'b1) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] CS line #0 was expected to be asserted.");
    end
    #40;
    rw_address      = 5'h14;
    read_request   = 1'b1;
    #40;
    if (read_data !== 32'h000000f0) begin
      error_flag = 1;
      error_count = error_count + 1;
      $display("[ERROR] Read data is not what it is expected to be.");
    end

    if (error_count === 0)
      $display("Passed all SPI Controller Software Unit Tests.");
    else
      $display("[ERROR] SPI Controller failed one or more unit tests.");

    $finish();

  end

endmodule

module dummy_spi_peripheral_modes03 (

  input wire sclk,
  input wire pico,
  input wire cs,
  output wire poci

  );

  reg [7:0] rx_data = 8'h00;
  reg tx_bit = 1'b0;
  reg [3:0] bit_count = 7;

  always @(posedge sclk) begin
    if (!cs) rx_data <= {rx_data[6:0], pico};
  end

  always @(negedge sclk) begin
    if (!cs) tx_bit <= rx_data[7];
  end

  assign poci = cs ? 1'bZ : tx_bit;

endmodule

module dummy_spi_peripheral_modes12 (

  input wire sclk,
  input wire pico,
  input wire cs,
  output wire poci

  );

  reg [7:0] rx_data = 8'h00;
  reg tx_bit = 1'b0;
  reg [3:0] bit_count = 7;

  always @(negedge sclk) begin
    if (!cs) rx_data <= {rx_data[6:0], pico};
  end

  always @(posedge sclk) begin
    if (!cs) tx_bit <= rx_data[7];
  end

  assign poci = cs ? 1'bZ : tx_bit;

endmodule