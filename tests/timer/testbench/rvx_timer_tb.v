// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`timescale 1ns / 1ps

`include "rvx_constants.vh"
`include "rvx_test_macros.vh"

module rvx_timer_tb ();

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

  // Timer interrupt signal
  wire           timer_irq;

  // Test variables
  integer        error_count;
  reg     [31:0] current_value;

  // verilator lint_off PINCONNECTEMPTY
  rvx_timer rvx_timer_instance (

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

      // Timer interrupt signal
      .timer_irq(timer_irq)

  );
  // verilator lint_on PINCONNECTEMPTY

  // Clock generation
  localparam CLOCK_PERIOD = 20;
  initial clock = 1'b0;
  always #(CLOCK_PERIOD / 2) clock = !clock;

  function [8*11-1:0] timer_reg_name;
    input [4:0] address;
    begin
      case (address)
        `RVX_TIMER_COUNTER_ENABLE_REG_ADDR: timer_reg_name = "CONTROL";
        `RVX_TIMER_COUNTERL_REG_ADDR:       timer_reg_name = "COUNTERL";
        `RVX_TIMER_COUNTERH_REG_ADDR:       timer_reg_name = "COUNTERH";
        `RVX_TIMER_COMPAREL_REG_ADDR:       timer_reg_name = "COMPAREL";
        `RVX_TIMER_COMPAREH_REG_ADDR:       timer_reg_name = "COMPAREH";
        default:                            timer_reg_name = "UNKNOWN";
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

  task read_timer_register;
    input [4:0] address;
    begin
      rw_address   = address;
      read_request = 1'b1;
      #(CLOCK_PERIOD);
      read_request = 1'b0;
      rw_address   = 5'h00;
      $display("");
      $display("Reading Timer register: %s", timer_reg_name(address));
      $display("Read value: 0x%08h", read_data);
    end
  endtask

  task write_timer_register;
    input [4:0] address;
    input [31:0] data;
    begin
      $display("");
      $display("Writing Timer register: %s", timer_reg_name(address));
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

  initial begin

    error_count = 0;

    reset_all_devices();

    $display("");
    $display("Checking Timer module state after reset...");
    $display("-----------------------------------------");
    $display("");

    `RVX_ASSERT(timer_irq === 1'b0, "Timer IRQ signal is not deasserted after reset.")
    read_timer_register(`RVX_TIMER_COUNTER_ENABLE_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h00000000, "CONTROL register is not 0 after reset.")
    read_timer_register(`RVX_TIMER_COUNTERL_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h00000000, "COUNTERL register is not 0 after reset.")
    read_timer_register(`RVX_TIMER_COUNTERH_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h00000000, "COUNTERH register is not 0 after reset.")
    read_timer_register(`RVX_TIMER_COMPAREL_REG_ADDR);
    `RVX_ASSERT(read_data === 32'hffffffff, "COMPAREL register is not 0xffffffff after reset.")
    read_timer_register(`RVX_TIMER_COMPAREH_REG_ADDR);
    `RVX_ASSERT(read_data === 32'hffffffff, "COMPAREH register is not 0xffffffff after reset.")

    $display("");
    $display("Checking Timer counter enable/disable...");
    $display("-----------------------------------------");
    $display("");

    write_timer_register(`RVX_TIMER_COUNTER_ENABLE_REG_ADDR, 32'h00000001);  // Enable counter
    #(CLOCK_PERIOD * 100);  // Wait for some time to let the counter increment
    read_timer_register(`RVX_TIMER_COUNTERL_REG_ADDR);
    `RVX_ASSERT(read_data > 32'h00000000, "COUNTERL register did not increment after enabling the counter.")
    current_value = read_data;
    write_timer_register(`RVX_TIMER_COUNTER_ENABLE_REG_ADDR, 32'h00000000);  // Disable counter
    #(CLOCK_PERIOD * 100);  // Wait for some time
    read_timer_register(`RVX_TIMER_COUNTERL_REG_ADDR);
    `RVX_ASSERT(read_data == current_value + 2, "COUNTERL register changed after disabling the counter.")
    #(CLOCK_PERIOD);
    write_timer_register(`RVX_TIMER_COUNTERL_REG_ADDR, 32'hfffffff0);  // Set COUNTERL to a value close to overflow
    write_timer_register(`RVX_TIMER_COUNTER_ENABLE_REG_ADDR, 32'h00000001);  // Enable counter
    #(CLOCK_PERIOD * 200);  // Wait for some time to let the counter increment and overflow
    read_timer_register(`RVX_TIMER_COUNTERL_REG_ADDR);
    `RVX_ASSERT(read_data < 32'h00000100, "COUNTERL register did not overflow correctly.")
    read_timer_register(`RVX_TIMER_COUNTERH_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000001, "COUNTERH register did not increment after COUNTERL overflow.")
    write_timer_register(`RVX_TIMER_COUNTER_ENABLE_REG_ADDR, 32'h00000000);  // Disable counter
    #(CLOCK_PERIOD);

    $display("");
    $display("Checking Timer interrupt...");
    $display("-----------------------------------------");
    $display("");

    write_timer_register(`RVX_TIMER_COUNTERL_REG_ADDR, 32'h00000000);  // Reset COUNTERL
    write_timer_register(`RVX_TIMER_COUNTERH_REG_ADDR, 32'h00000000);  // Reset COUNTERH
    write_timer_register(`RVX_TIMER_COMPAREL_REG_ADDR, 32'h00000010);  // Set COMPAREL to 16
    write_timer_register(`RVX_TIMER_COMPAREH_REG_ADDR, 32'h00000000);  // Set COMPAREH to 0
    write_timer_register(`RVX_TIMER_COUNTER_ENABLE_REG_ADDR, 32'h00000001);  // Enable counter
    #(CLOCK_PERIOD * 16);  // Wait until just before the compare match
    `RVX_ASSERT(timer_irq === 1'b0, "Timer IRQ asserted too early.")
    #(CLOCK_PERIOD);  // Wait to cross the compare match
    `RVX_ASSERT(timer_irq === 1'b1, "Timer IRQ not asserted on compare match.")
    #(CLOCK_PERIOD);
    `RVX_ASSERT(timer_irq === 1'b1, "Timer IRQ deasserted too early.")
    write_timer_register(`RVX_TIMER_COMPAREL_REG_ADDR, 32'hffffffff);  // Update COMPAREL to clear IRQ
    write_timer_register(`RVX_TIMER_COMPAREH_REG_ADDR, 32'hffffffff);  // Update COMPAREH to clear IRQ
    #(CLOCK_PERIOD);
    `RVX_ASSERT(timer_irq === 1'b0, "Timer IRQ not cleared after updating COMPARE register.")
    write_timer_register(`RVX_TIMER_COUNTER_ENABLE_REG_ADDR, 32'h00000000);  // Disable counter
    #(CLOCK_PERIOD);

    $display("");
    $display("Testbench result:");
    $display("-----------------");
    $display("");
    if (error_count === 0) $display("Passed RTL testbench for the RVX Timer module.");
    else $display("[ERROR] Timer module failed one or more unit tests. Please investigate.");
    $display("");

    $finish();

  end

endmodule
