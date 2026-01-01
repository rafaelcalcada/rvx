// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"
`include "rvx_test_macros.vh"

module rvx_uart_tb ();

  // Global signals
  reg            clock;
  reg            reset_n;

  // Register read/write
  reg     [ 4:0] rw_address;
  wire    [31:0] read_data;
  reg            read_request;
  reg     [31:0] write_data;
  reg            write_request;
  reg     [ 3:0] write_strobe;

  // UART signals
  wire           uart_tx;
  wire           uart_irq;

  // Test variables
  integer        error_count;
  integer        trace_uart_tx;
  reg [63:0] start_time, duration;
  reg prev_state;

  // verilator lint_off PINCONNECTEMPTY
  rvx_uart rvx_uart_instance (

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

      // UART signals
      .uart_tx (uart_tx),  // Loopback for testbench
      .uart_rx (uart_tx),  // Loopback for testbench
      .uart_irq(uart_irq)

  );
  // verilator lint_on PINCONNECTEMPTY

  // Clock generation
  localparam CLOCK_PERIOD = 20;
  initial clock = 1'b0;
  always #(CLOCK_PERIOD / 2) clock = !clock;

  function [8*11-1:0] uart_reg_name;
    input [4:0] address;
    begin
      case (address)
        `RVX_UART_WRITE_REG_ADDR:  uart_reg_name = "WRITE";
        `RVX_UART_READ_REG_ADDR:   uart_reg_name = "READ";
        `RVX_UART_STATUS_REG_ADDR: uart_reg_name = "STATUS";
        `RVX_UART_BAUD_REG_ADDR:   uart_reg_name = "BAUD";
        default:                   uart_reg_name = "UNKNOWN";
      endcase
    end
  endfunction

  task reset_all_devices;
    begin
      reset_n       = 1'b0;
      rw_address    = 5'h00;
      read_request  = 1'b0;
      write_request = 1'b0;
      write_data    = 32'b0;
      #(CLOCK_PERIOD * 2);
      reset_n = 1'b1;
      #(CLOCK_PERIOD * 2);
    end
  endtask

  task read_uart_register;
    input [4:0] address;
    begin
      rw_address   = address;
      read_request = 1'b1;
      #(CLOCK_PERIOD);
      read_request = 1'b0;
      rw_address   = 5'h00;
      $display("");
      $display("Reading UART register: %s", uart_reg_name(address));
      $display("Read value: 0x%08h", read_data);
    end
  endtask

  task write_uart_register;
    input [4:0] address;
    input [31:0] data;
    begin
      $display("");
      $display("Writing UART register: %s", uart_reg_name(address));
      $display("Write value: 0x%08h", data);
      rw_address    = address;
      write_data    = data;
      write_request = 1'b1;
      write_strobe  = 4'b1111;
      #(CLOCK_PERIOD);
      write_request = 1'b0;
      rw_address    = 5'h00;
      write_data    = 32'b0;
      write_strobe  = 4'b0000;
    end
  endtask

  task verify_byte_transmission;
    input [7:0] expected_byte;
    input [15:0] cycles_per_baud;
    integer i;
    integer transmission_error;
    begin
      trace_uart_tx = 1;
      $display("");
      $display("Checking transmission of: 0x%02h", expected_byte);
      `RVX_ASSERT(rvx_uart_instance.ready_to_send === 1'b0, "UART ready_to_send flag is not low during transmission.")

      // Start bit
      #(CLOCK_PERIOD * cycles_per_baud / 2);
      if (uart_tx !== 1'b0) begin
        $display("Start bit mismatch: expected 0, got %b", uart_tx);
        transmission_error = 1;
      end
      else begin
        $display("Passed: uart_tx === 0 (start bit) after 0.5 baud periods at t = %0d ns", $time);
      end
      `RVX_ASSERT(rvx_uart_instance.ready_to_send === 1'b0, "UART ready_to_send flag is not low during transmission.")

      // Data bits
      for (i = 0; i <= 7; i = i + 1) begin
        #(CLOCK_PERIOD * cycles_per_baud);
        if (uart_tx !== expected_byte[7-i]) begin
          transmission_error = 1;
          $display("Bit %0d mismatch: expected %b, got %b", i, expected_byte[7-i], uart_tx);
        end
        else begin
          $display("Passed: uart_tx === %b after %0d.5 baud periods at t = %0d ns", uart_tx, (i + 1), $time);
        end
        `RVX_ASSERT(rvx_uart_instance.ready_to_send === 1'b0, "UART ready_to_send flag is not low during transmission.")
      end

      // Stop bit
      #(CLOCK_PERIOD * cycles_per_baud);
      if (uart_tx !== 1'b1) begin
        $display("Stop bit mismatch: expected 1, got %b", uart_tx);
        transmission_error = 1;
      end
      else begin
        $display("Passed: uart_tx === 1 (stop bit) after 9.5 baud periods at t = %0d ns", $time);
      end

      // Wait for the last half baud period
      #(CLOCK_PERIOD * cycles_per_baud / 2);
      //#(CLOCK_PERIOD * 10);
      `RVX_ASSERT(rvx_uart_instance.ready_to_send === 1'b1, "UART ready_to_send flag is not high after transmission.")

      // Final result
      if (transmission_error == 1) begin
        $display("Transmission of byte 0x%02h FAILED.", expected_byte);
        $stop();
      end
      else begin
        $display("Byte 0x%02h transmission check complete.", expected_byte);
      end
      trace_uart_tx = 0;
    end
  endtask

  task assert_is_ready_to_send;
    begin
      read_uart_register(`RVX_UART_STATUS_REG_ADDR);
      `RVX_ASSERT(read_data[0] === 1'b1, "UART ready_to_send flag is not high before transmission.")
      `RVX_ASSERT(rvx_uart_instance.ready_to_send === 1'b1, "UART ready_to_send flag is not high before transmission.")
    end
  endtask

  initial begin
    prev_state    = uart_tx;
    start_time    = $time;
    trace_uart_tx = 0;
  end

  // verilator lint_off BLKSEQ
  // verilator lint_off SYNCASYNCNET
  always @(posedge uart_tx or negedge uart_tx) begin
    duration = $time - start_time;
    if (trace_uart_tx == 1) begin
      $display("-- TX pin changed from %b to %b after %0d ns", prev_state, uart_tx, duration);
      `RVX_ASSERT(duration % (CLOCK_PERIOD * rvx_uart_instance.cycles_per_baud) == 0,
                  "UART TX pin held high or low for more cycles than expected.")
    end
    prev_state = uart_tx;
    start_time = $time;
  end
  // verilator lint_on SYNCASYNCNET
  // verilator lint_on BLKSEQ

  initial begin

    error_count = 0;

    reset_all_devices();

    $display("");
    $display("Checking UART module state after reset...");
    $display("-----------------------------------------");
    $display("");

    `RVX_ASSERT(uart_tx === 1'b1, "UART TX pin is not logic HIGH after reset.")
    `RVX_ASSERT(uart_irq === 1'b0, "UART IRQ pin is not logic LOW after reset.")
    read_uart_register(`RVX_UART_READ_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h00000000, "Register is not 0 after reset.")
    read_uart_register(`RVX_UART_STATUS_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h00000001, "Register is not 1 after reset.")
    read_uart_register(`RVX_UART_BAUD_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h00000000, "Register is not 0 after reset.")

    $display("");
    $display("Testing read/write to UART registers...");
    $display("--------------------------------------");

    write_uart_register(`RVX_UART_BAUD_REG_ADDR, 32'h000004e2);  // 12 Mhz / 9600 baud = 1250 (0x4e2) cycles per baud 
    read_uart_register(`RVX_UART_BAUD_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h000004e2, "Register is not 0x000004e2 after write.")

    $display("");
    $display("Running UART data transfer test...");
    $display("------------------------------------------------");

    // Send: 0xA5 (0x10100101)
    assert_is_ready_to_send();
    write_uart_register(`RVX_UART_WRITE_REG_ADDR, 32'h000000a5);
    verify_byte_transmission(8'ha5, 1250);
    #(CLOCK_PERIOD * 4);

    // Read back
    read_uart_register(`RVX_UART_READ_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h000000a5, "READ register does not contain the expected byte (0xa5).")

    // Send: 0x5A (0x01011010)
    assert_is_ready_to_send();
    write_uart_register(`RVX_UART_WRITE_REG_ADDR, 32'h0000005a);
    verify_byte_transmission(8'h5a, 1250);
    #(CLOCK_PERIOD * 4);

    // Read back
    read_uart_register(`RVX_UART_READ_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h0000005a, "READ register does not contain the expected byte (0x5a).")

    // Send: 0xFF (0x11111111)
    assert_is_ready_to_send();
    write_uart_register(`RVX_UART_WRITE_REG_ADDR, 32'h000000ff);
    verify_byte_transmission(8'hff, 1250);
    #(CLOCK_PERIOD * 4);

    // Read back
    read_uart_register(`RVX_UART_READ_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h000000ff, "READ register does not contain the expected byte (0xff).")

    // Send: 0x00 (0x00000000)
    assert_is_ready_to_send();
    write_uart_register(`RVX_UART_WRITE_REG_ADDR, 32'h00000000);
    verify_byte_transmission(8'h00, 1250);
    #(CLOCK_PERIOD * 4);

    // Read back
    read_uart_register(`RVX_UART_READ_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h00000000, "READ register does not contain the expected byte (0x00).")

    // Send: 0x3C (0x00111100)
    assert_is_ready_to_send();
    write_uart_register(`RVX_UART_WRITE_REG_ADDR, 32'h0000003c);
    verify_byte_transmission(8'h3c, 1250);
    #(CLOCK_PERIOD * 4);

    // Read back
    read_uart_register(`RVX_UART_READ_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h0000003c, "READ register does not contain the expected byte (0x3c).")

    // Send: 0xC3 (0x11000011)
    assert_is_ready_to_send();
    write_uart_register(`RVX_UART_WRITE_REG_ADDR, 32'h000000c3);
    verify_byte_transmission(8'hc3, 1250);
    #(CLOCK_PERIOD * 4);

    // Read back
    read_uart_register(`RVX_UART_READ_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h000000c3, "READ register does not contain the expected byte (0xc3).")

    $display("");
    $display("Testbench result:");
    $display("-----------------");
    $display("");
    if (error_count === 0) $display("Passed RTL testbench for the RVX UART module.");
    else $display("[ERROR] UART module failed one or more unit tests. Please investigate.");
    $display("");

    $finish();

  end

endmodule
