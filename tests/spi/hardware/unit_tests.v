// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`timescale 1ns / 1ns

`include "rvx_constants.vh"

`define ASSERT(cond, msg)                                   \
  if (!(cond)) begin                                        \
    $display("");                                           \
    $display("Assertion FAILED.");                          \
    $display("  Condition: %s", `"cond`");                  \
    $display("  Message: %s", msg);                         \
    error_count = error_count + 1;                          \
    $stop();                                                \
  end                                                       \
  else begin                                                \
    $display("Passed: %s", `"cond`");                       \
  end

module unit_tests ();

  // Global signals
  reg            clock;
  reg            reset_n;

  // Register read/write
  reg     [ 4:0] rw_address;
  wire    [31:0] read_data;
  reg            read_request;
  reg     [31:0] write_data;
  reg     [ 3:0] write_strobe;
  reg            write_request;

  // SPI signals
  wire           sclk;
  wire           mosi;
  wire           miso;
  wire           cs;

  reg            gpio_cs;

  // Test variables
  integer        error_count;

  // verilator lint_off PINCONNECTEMPTY
  rvx_spi_manager rvx_spi_manager_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // IO interface
      .rw_address    (rw_address),
      .read_data     (read_data),
      .read_request  (read_request),
      .read_response (),
      .write_data    (write_data),
      .write_strobe  (write_strobe),
      .write_request (write_request),
      .write_response(),

      // SPI signals
      .sclk(sclk),
      .mosi(mosi),
      .miso(miso),
      .cs  (cs)

  );
  // verilator lint_on PINCONNECTEMPTY

  test_spi_subordinate_0 test_spi_subordinate_0_instance (

      .clock  (clock),
      .reset_n(reset_n),
      .sclk   (sclk),
      .mosi   (mosi),
      .miso   (miso),
      .cs     (cs)

  );

  test_spi_subordinate_1 test_spi_subordinate_1_instance (

      .clock  (clock),
      .reset_n(reset_n),
      .sclk   (sclk),
      .mosi   (mosi),
      .miso   (miso),
      .cs     (gpio_cs)

  );

  // Clock generation
  localparam CLOCK_PERIOD = 20;
  initial clock = 1'b0;
  always #(CLOCK_PERIOD / 2) clock = !clock;

  function [8*11-1:0] spi_reg_name;
    input [4:0] address;
    begin
      case (address)
        `RVX_SPI_MODE_REG_ADDR:        spi_reg_name = "MODE";
        `RVX_SPI_CHIP_SELECT_REG_ADDR: spi_reg_name = "CHIP_SELECT";
        `RVX_SPI_DIVIDER_REG_ADDR:     spi_reg_name = "DIVIDER";
        `RVX_SPI_WRITE_REG_ADDR:       spi_reg_name = "WRITE";
        `RVX_SPI_READ_REG_ADDR:        spi_reg_name = "READ";
        `RVX_SPI_STATUS_REG_ADDR:      spi_reg_name = "STATUS";
        default:                       spi_reg_name = "UNKNOWN";
      endcase
    end
  endfunction

  task reset_all_devices;
    begin
      reset_n       = 1'b0;
      rw_address    = 5'h00;
      read_request  = 1'b0;
      write_request = 1'b0;
      write_strobe  = 4'b0;
      write_data    = 32'b0;
      #(CLOCK_PERIOD * 2);
      reset_n = 1'b1;
      #(CLOCK_PERIOD * 2);
    end
  endtask

  task read_spi_register;
    input [4:0] address;
    begin
      rw_address   = address;
      read_request = 1'b1;
      #(CLOCK_PERIOD);
      read_request = 1'b0;
      rw_address   = 5'h00;
      $display("");
      $display("Reading SPI register: %s", spi_reg_name(address));
      $display("Read value: 0x%08h", read_data);
    end
  endtask

  task write_spi_register;
    input [4:0] address;
    input [31:0] data;
    begin
      $display("");
      $display("Writing SPI register: %s", spi_reg_name(address));
      $display("Write value: 0x%08h", data);
      rw_address    = address;
      write_data    = data;
      write_strobe  = 4'b1111;
      write_request = 1'b1;
      #(CLOCK_PERIOD);
      write_request = 1'b0;
      rw_address    = 5'h00;
      write_data    = 32'b0;
      write_strobe  = 4'b0;
    end
  endtask

  task verify_byte_transmission;
    input [7:0] expected_byte;
    input [15:0] sclk_period;  // Delay between bits in clock periods
    integer i;
    integer transmission_error;
    begin
      $display("");
      $display("Checking transmission of: 0x%02h", expected_byte);
      for (i = 0; i <= 7; i = i + 1) begin
        #(sclk_period);
        if (mosi !== expected_byte[7-i]) begin
          transmission_error = 1;
          $display("Bit %0d mismatch: expected %b, got %b", i, expected_byte[7-i], mosi);
        end
        else begin
          $display("Passed: MOSI === %b after %0d ns at t = %0d ns", mosi, sclk_period * (i + 1), $time);
        end
      end
      if (transmission_error == 1) begin
        $display("Transmission of byte 0x%02h FAILED.", expected_byte);
        $stop();
      end
      else begin
        $display("Byte 0x%02h transmission check complete.", expected_byte);
      end
    end
  endtask

  task test_transmission;
    input [15:0] sclk_period;  // Delay between bits in clock periods
    begin
      // Send: 0xA5 (0x10100101)
      write_spi_register(`RVX_SPI_WRITE_REG_ADDR, 32'h000000a5);
      verify_byte_transmission(8'ha5, sclk_period);
      #(CLOCK_PERIOD * 4);

      // Send: 0x5A (0x01011010)
      write_spi_register(`RVX_SPI_WRITE_REG_ADDR, 32'h0000005a);
      verify_byte_transmission(8'h5a, sclk_period);
      #(CLOCK_PERIOD * 4);

      // Send: 0xFF (0x11111111)
      write_spi_register(`RVX_SPI_WRITE_REG_ADDR, 32'h000000ff);
      verify_byte_transmission(8'hff, sclk_period);
      #(CLOCK_PERIOD * 4);

      // Send: 0x00 (0x00000000)
      write_spi_register(`RVX_SPI_WRITE_REG_ADDR, 32'h00000000);
      verify_byte_transmission(8'h00, sclk_period);
      #(CLOCK_PERIOD * 4);

      // Send: 0x3C (0x00111100)
      write_spi_register(`RVX_SPI_WRITE_REG_ADDR, 32'h0000003c);
      verify_byte_transmission(8'h3c, sclk_period);
      #(CLOCK_PERIOD * 4);

      // Send: 0xC3 (0x11000011)
      write_spi_register(`RVX_SPI_WRITE_REG_ADDR, 32'h000000c3);
      verify_byte_transmission(8'hc3, sclk_period);
      #(CLOCK_PERIOD * 4);

      // Read received byte (subordinate sends the byte sent in the penultimate transmission)
      read_spi_register(`RVX_SPI_READ_REG_ADDR);
      `ASSERT(read_data === 32'h0000003c, "READ register does not contain the expected byte (0x3c).")
    end
  endtask

  initial begin

    error_count = 0;
    gpio_cs     = 1'b1;  // deselect subordinate 1

    reset_all_devices();

    $display("");
    $display("Checking SPI Manager state after reset...");
    $display("-----------------------------------------");
    $display("");

    `ASSERT(cs === 1'b1, "CS (Chip Select) is not logic HIGH after reset.")
    `ASSERT(mosi === 1'b0, "MOSI is not logic LOW after reset.")
    `ASSERT(sclk === 1'b0, "SCLK is not logic LOW after reset.")
    read_spi_register(`RVX_SPI_MODE_REG_ADDR);
    `ASSERT(read_data === 32'h00000000, "Register is not 0 after reset.")
    read_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR);
    `ASSERT(read_data === 32'h00000001, "Register is not 1 after reset.")
    read_spi_register(`RVX_SPI_DIVIDER_REG_ADDR);
    `ASSERT(read_data === 32'h00000000, "Register is not 0 after reset.")
    read_spi_register(`RVX_SPI_STATUS_REG_ADDR);
    `ASSERT(read_data === 32'h00000000, "Register is not 0 after reset.")
    read_spi_register(`RVX_SPI_READ_REG_ADDR);
    `ASSERT(read_data === 32'h00000000, "Register is not 0 after reset.")
    read_spi_register(`RVX_SPI_WRITE_REG_ADDR);
    `ASSERT(read_data === 32'h00000000, "Register is not 0 after reset.")

    $display("");
    $display("Testing read/write to SPI registers...");
    $display("--------------------------------------");

    write_spi_register(`RVX_SPI_MODE_REG_ADDR, 32'h00000001);
    read_spi_register(`RVX_SPI_MODE_REG_ADDR);
    `ASSERT(read_data === 32'h00000001, "Register is not 0x00000001 after write.")
    write_spi_register(`RVX_SPI_MODE_REG_ADDR, 32'hffffffff);
    read_spi_register(`RVX_SPI_MODE_REG_ADDR);
    `ASSERT(read_data === 32'h00000003, "Register is not 0x00000003 after write.")
    write_spi_register(`RVX_SPI_MODE_REG_ADDR, 32'h00000000);
    read_spi_register(`RVX_SPI_MODE_REG_ADDR);
    `ASSERT(read_data === 32'h00000000, "Register is not 0x00000000 after write.")
    write_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR, 32'h00000000);
    read_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR);
    `ASSERT(read_data === 32'h00000000, "Register is not 0x00000000 after write.")
    `ASSERT(cs === 1'b0, "CS (Chip Select) line is not asserted (logic LOW) after writing 0 to CHIP SELECT register.")
    write_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR, 32'h00000001);
    read_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR);
    `ASSERT(read_data === 32'h00000001, "Register is not 0x00000001 after write.")
    `ASSERT(cs === 1'b1,
            "CS (Chip Select) line is not deasserted (logic HIGH) after writing 1 to CHIP SELECT register.")

    $display("");
    $display("Running SPI data transfer tests in mode 0 (base speed)...");
    $display("---------------------------------------------------------");

    // Configure SPI: MODE 0, base speed, deassert CS (selects subordinate 0)
    write_spi_register(`RVX_SPI_MODE_REG_ADDR, 32'h00000000);
    write_spi_register(`RVX_SPI_DIVIDER_REG_ADDR, 32'h0000000);
    write_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR, 32'h00000000);
    #(CLOCK_PERIOD * 2);
    `ASSERT(cs === 1'b0, "CS (Chip Select) line is not asserted (logic LOW) after writing 0 to CHIP SELECT register.")

    test_transmission(CLOCK_PERIOD * 2);

    // Deselect subordinate
    write_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR, 32'h00000001);
    read_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR);
    `ASSERT(read_data === 32'h00000001, "Register is not 0x00000001 after write.")
    `ASSERT(cs === 1'b1,
            "CS (Chip Select) line is not deasserted (logic HIGH) after writing 1 to CHIP SELECT register.")

    $display("");
    $display("Running SPI data transfer tests in mode 1 (base speed)...");
    $display("---------------------------------------------------------");

    // Configure SPI: MODE 1, base speed, deassert gpio_cs (selects subordinate 1)
    write_spi_register(`RVX_SPI_MODE_REG_ADDR, 32'h00000001);
    write_spi_register(`RVX_SPI_DIVIDER_REG_ADDR, 32'h00000000);
    gpio_cs = 1'b0;
    #(CLOCK_PERIOD * 2);
    `ASSERT(gpio_cs === 1'b0, "CS (Chip Select) line for subordinate 1 is not asserted (logic LOW).")

    test_transmission(CLOCK_PERIOD * 2);

    // Deselect subordinate 1
    gpio_cs = 1'b1;
    #(CLOCK_PERIOD * 2);
    `ASSERT(gpio_cs === 1'b1, "CS (Chip Select) line for subordinate 1 is not deasserted (logic HIGH).")

    $display("");
    $display("Running SPI data transfer tests in mode 2 (base speed)...");
    $display("---------------------------------------------------------");

    // Configure SPI: MODE 2, base speed, deassert gpio_cs (selects subordinate 1)
    write_spi_register(`RVX_SPI_MODE_REG_ADDR, 32'h00000002);
    write_spi_register(`RVX_SPI_DIVIDER_REG_ADDR, 32'h00000000);
    gpio_cs = 1'b0;
    #(CLOCK_PERIOD * 2);
    `ASSERT(gpio_cs === 1'b0, "CS (Chip Select) line for subordinate 1 is not asserted (logic LOW).")

    test_transmission(CLOCK_PERIOD * 2);

    // Deselect subordinate 1
    gpio_cs = 1'b1;
    #(CLOCK_PERIOD * 2);
    `ASSERT(gpio_cs === 1'b1, "CS (Chip Select) line for subordinate 1 is not deasserted (logic HIGH).")

    $display("");
    $display("Running SPI data transfer tests in mode 3 (base speed)...");
    $display("---------------------------------------------------------");

    // Configure SPI: MODE 3, base speed, deassert CS (selects subordinate 0)
    write_spi_register(`RVX_SPI_MODE_REG_ADDR, 32'h00000003);
    write_spi_register(`RVX_SPI_DIVIDER_REG_ADDR, 32'h0000000);
    write_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR, 32'h00000000);
    #(CLOCK_PERIOD * 2);
    `ASSERT(cs === 1'b0, "CS (Chip Select) line is not asserted (logic LOW) after writing 0 to CHIP SELECT register.")

    test_transmission(CLOCK_PERIOD * 2);

    // Deselect subordinate
    write_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR, 32'h00000001);
    read_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR);
    `ASSERT(read_data === 32'h00000001, "Register is not 0x00000001 after write.")
    `ASSERT(cs === 1'b1,
            "CS (Chip Select) line is not deasserted (logic HIGH) after writing 1 to CHIP SELECT register.")

    $display("");
    $display("Running SPI data transfer tests in mode 0 (divider = 4)...");
    $display("---------------------------------------------------------");

    // Configure SPI: MODE 0, base speed, deassert CS (selects subordinate 0)
    write_spi_register(`RVX_SPI_MODE_REG_ADDR, 32'h00000000);
    write_spi_register(`RVX_SPI_DIVIDER_REG_ADDR, 32'h00000004);
    write_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR, 32'h00000000);
    #(CLOCK_PERIOD * 2);
    `ASSERT(cs === 1'b0, "CS (Chip Select) line is not asserted (logic LOW) after writing 0 to CHIP SELECT register.")

    test_transmission(CLOCK_PERIOD * 10);

    // Deselect subordinate
    write_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR, 32'h00000001);
    read_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR);
    `ASSERT(read_data === 32'h00000001, "Register is not 0x00000001 after write.")
    `ASSERT(cs === 1'b1,
            "CS (Chip Select) line is not deasserted (logic HIGH) after writing 1 to CHIP SELECT register.")

    $display("");
    $display("Running SPI data transfer tests in mode 1 (base speed)...");
    $display("---------------------------------------------------------");

    // Configure SPI: MODE 1, base speed, deassert gpio_cs (selects subordinate 1)
    write_spi_register(`RVX_SPI_MODE_REG_ADDR, 32'h00000001);
    write_spi_register(`RVX_SPI_DIVIDER_REG_ADDR, 32'h00000004);
    gpio_cs = 1'b0;
    #(CLOCK_PERIOD * 2);
    `ASSERT(gpio_cs === 1'b0, "CS (Chip Select) line for subordinate 1 is not asserted (logic LOW).")

    test_transmission(CLOCK_PERIOD * 10);

    // Deselect subordinate 1
    gpio_cs = 1'b1;
    #(CLOCK_PERIOD * 2);
    `ASSERT(gpio_cs === 1'b1, "CS (Chip Select) line for subordinate 1 is not deasserted (logic HIGH).")

    $display("");
    $display("Running SPI data transfer tests in mode 2 (base speed)...");
    $display("---------------------------------------------------------");

    // Configure SPI: MODE 2, base speed, deassert gpio_cs (selects subordinate 1)
    write_spi_register(`RVX_SPI_MODE_REG_ADDR, 32'h00000002);
    write_spi_register(`RVX_SPI_DIVIDER_REG_ADDR, 32'h00000004);
    gpio_cs = 1'b0;
    #(CLOCK_PERIOD * 2);
    `ASSERT(gpio_cs === 1'b0, "CS (Chip Select) line for subordinate 1 is not asserted (logic LOW).")

    test_transmission(CLOCK_PERIOD * 10);

    // Deselect subordinate 1
    gpio_cs = 1'b1;
    #(CLOCK_PERIOD * 2);
    `ASSERT(gpio_cs === 1'b1, "CS (Chip Select) line for subordinate 1 is not deasserted (logic HIGH).")

    $display("");
    $display("Running SPI data transfer tests in mode 3 (base speed)...");
    $display("---------------------------------------------------------");

    // Configure SPI: MODE 3, base speed, deassert CS (selects subordinate 0)
    write_spi_register(`RVX_SPI_MODE_REG_ADDR, 32'h00000003);
    write_spi_register(`RVX_SPI_DIVIDER_REG_ADDR, 32'h00000004);
    write_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR, 32'h00000000);
    #(CLOCK_PERIOD * 2);
    `ASSERT(cs === 1'b0, "CS (Chip Select) line is not asserted (logic LOW) after writing 0 to CHIP SELECT register.")

    test_transmission(CLOCK_PERIOD * 10);

    // Deselect subordinate
    write_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR, 32'h00000001);
    read_spi_register(`RVX_SPI_CHIP_SELECT_REG_ADDR);
    `ASSERT(read_data === 32'h00000001, "Register is not 0x00000001 after write.")
    `ASSERT(cs === 1'b1,
            "CS (Chip Select) line is not deasserted (logic HIGH) after writing 1 to CHIP SELECT register.")

    $display("");
    $display("Testbench result:");
    $display("-----------------");
    $display("");
    if (error_count === 0) $display("Passed all SPI Manager unit tests.");
    else $display("[ERROR] SPI Manager failed one or more unit tests. Please investigate.");
    $display("");

    $finish();

  end

endmodule

// Subordinate device that samples MOSI on rising SCLK edge and updates MISO
// on falling SCLK edge. This corresponds to SPI modes 0 and 3.
// ----------------------------------------------------------------------------

// verilator lint_off DECLFILENAME
module test_spi_subordinate_0 (

    input  wire clock,
    input  wire reset_n,
    input  wire sclk,
    input  wire mosi,
    input  wire cs,
    output wire miso

);

  reg  [7:0] rx_data;
  reg        tx_bit;

  wire       sample_edge;
  reg        sclk_prev;

  always @(posedge clock) begin
    if (!reset_n) begin
      sclk_prev <= 1'b0;
    end
    else begin
      sclk_prev <= sclk;
    end
  end

  // Sample on rising edge of SCLK
  assign sample_edge = !sclk_prev && sclk;

  always @(posedge clock) begin
    if (!reset_n) rx_data <= 8'h00;
    else if (!cs & sample_edge) rx_data <= {rx_data[6:0], mosi};
  end

  always @(negedge clock) begin
    if (!reset_n) tx_bit <= 1'b0;
    else if (!cs & sample_edge) tx_bit <= rx_data[7];
  end

  assign miso = cs ? 1'bZ : tx_bit;

endmodule

// Subordinate device that samples MOSI on falling SCLK edge and updates MISO
// on rising SCLK edge. This corresponds to SPI modes 1 and 2.
// ----------------------------------------------------------------------------

module test_spi_subordinate_1 (

    input  wire clock,
    input  wire reset_n,
    input  wire sclk,
    input  wire mosi,
    input  wire cs,
    output wire miso

);

  reg  [7:0] rx_data;
  reg        tx_bit;

  wire       sample_edge;
  reg        sclk_prev;

  always @(posedge clock) begin
    if (!reset_n) begin
      sclk_prev <= 1'b0;
    end
    else begin
      sclk_prev <= sclk;
    end
  end

  // Sample on falling edge of SCLK
  assign sample_edge = sclk_prev && !sclk;

  always @(posedge clock) begin
    if (!reset_n) rx_data <= 8'h00;
    else if (!cs & sample_edge) rx_data <= {rx_data[6:0], mosi};
  end

  always @(negedge clock) begin
    if (!reset_n) tx_bit <= 1'b0;
    else if (!cs & sample_edge) tx_bit <= rx_data[7];
  end

  assign miso = cs ? 1'bZ : tx_bit;

endmodule
// verilator lint_on DECLFILENAME
