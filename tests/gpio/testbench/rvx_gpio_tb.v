// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"
`include "rvx_test_macros.vh"

module rvx_gpio_tb ();

  // Global signals
  reg            clock;
  reg            reset_n;

  // Register read/write
  reg     [ 4:0] rw_address;
  wire    [31:0] read_data0;  // For GPIO instance 0
  wire    [31:0] read_data1;  // For GPIO instance 1
  wire    [31:0] read_data2;  // For GPIO instance 2
  reg            read_request;
  reg     [31:0] write_data;
  reg            write_request;
  reg     [ 3:0] write_strobe;

  // GPIO signals
  reg     [31:0] gpio0_input;
  reg     [15:0] gpio1_input;
  reg     [ 0:0] gpio2_input;
  wire    [31:0] gpio0_output_enable;
  wire    [15:0] gpio1_output_enable;
  wire    [ 0:0] gpio2_output_enable;
  wire    [31:0] gpio0_output;
  wire    [15:0] gpio1_output;
  wire    [ 0:0] gpio2_output;

  // Test variables
  integer        error_count;

  // verilator lint_off PINCONNECTEMPTY
  rvx_gpio #(

      .GPIO_WIDTH(32)

  ) rvx_gpio_instance0 (  // Instance 0 uses all 32 GPIO pins

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // IO interface
      .rw_address    (rw_address),
      .read_data     (read_data0),
      .read_request  (read_request),
      .read_response (),
      .write_data    (write_data),
      .write_strobe  (write_strobe),
      .write_request (write_request),
      .write_response(),

      // GPIO signals
      .gpio_input        (gpio0_input),
      .gpio_output_enable(gpio0_output_enable),
      .gpio_output       (gpio0_output)

  );

  rvx_gpio #(

      .GPIO_WIDTH(16)

  ) rvx_gpio_instance1 (  // Instance 1 uses only 16 GPIO pins

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // IO interface
      .rw_address    (rw_address),
      .read_data     (read_data1),
      .read_request  (read_request),
      .read_response (),
      .write_data    (write_data),
      .write_strobe  (write_strobe),
      .write_request (write_request),
      .write_response(),

      // GPIO signals
      .gpio_input        (gpio1_input),
      .gpio_output_enable(gpio1_output_enable),
      .gpio_output       (gpio1_output)

  );

  rvx_gpio #(

      .GPIO_WIDTH(1)

  ) rvx_gpio_instance2 (  // Instance 2 uses only 1 GPIO pin

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // IO interface
      .rw_address    (rw_address),
      .read_data     (read_data2),
      .read_request  (read_request),
      .read_response (),
      .write_data    (write_data),
      .write_strobe  (write_strobe),
      .write_request (write_request),
      .write_response(),

      // GPIO signals
      .gpio_input        (gpio2_input),
      .gpio_output_enable(gpio2_output_enable),
      .gpio_output       (gpio2_output)

  );
  // verilator lint_on PINCONNECTEMPTY

  // Clock generation
  localparam CLOCK_PERIOD = 20;
  initial clock = 1'b0;
  always #(CLOCK_PERIOD / 2) clock = !clock;

  function [8*13-1:0] gpio_reg_name;
    input [4:0] address;
    begin
      case (address)
        `RVX_GPIO_READ_REG_ADDR:          gpio_reg_name = "READ";
        `RVX_GPIO_OUTPUT_ENABLE_REG_ADDR: gpio_reg_name = "OUTPUT_ENABLE";
        `RVX_GPIO_OUTPUT_REG_ADDR:        gpio_reg_name = "OUTPUT";
        `RVX_GPIO_CLEAR_REG_ADDR:         gpio_reg_name = "CLEAR";
        `RVX_GPIO_SET_REG_ADDR:           gpio_reg_name = "SET";
        default:                          gpio_reg_name = "UNKNOWN";
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

  task read_gpio_register;
    input [4:0] address;
    begin
      rw_address   = address;
      read_request = 1'b1;
      #(CLOCK_PERIOD);
      read_request = 1'b0;
      rw_address   = 5'h00;
      $display("");
      $display("Reading GPIO register: %s", gpio_reg_name(address));
      $display("Read value (instance 0): 0x%08h", read_data0);
      $display("Read value (instance 1): 0x%08h", read_data1);
      $display("Read value (instance 2): 0x%08h", read_data2);
    end
  endtask

  task write_gpio_register;
    input [4:0] address;
    input [31:0] data;
    begin
      $display("");
      $display("Writing GPIO register: %s", gpio_reg_name(address));
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
    gpio0_input = 32'h00000000;
    gpio1_input = 16'h0000;
    gpio2_input = 1'b0;

    reset_all_devices();

    $display("");
    $display("Checking GPIO module state after reset...");
    $display("-----------------------------------------");
    $display("");

    read_gpio_register(`RVX_GPIO_READ_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'h00000000, "READ register not zero after reset (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h00000000, "READ register not zero after reset (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000000, "READ register not zero after reset (instance 2).")
    read_gpio_register(`RVX_GPIO_OUTPUT_ENABLE_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'h00000000, "OUTPUT_ENABLE register not zero after reset (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h00000000, "OUTPUT_ENABLE register not zero after reset (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000000, "OUTPUT_ENABLE register not zero after reset (instance 2).")
    `RVX_ASSERT(gpio0_output_enable == 32'h00000000, "OUTPUT_ENABLE signals not zero after reset (instance 0).")
    `RVX_ASSERT(gpio1_output_enable == 16'h0000, "OUTPUT_ENABLE signals not zero after reset (instance 1).")
    `RVX_ASSERT(gpio2_output_enable == 1'b0, "OUTPUT_ENABLE signals not zero after reset (instance 2).")
    read_gpio_register(`RVX_GPIO_OUTPUT_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'h00000000, "OUTPUT register not zero after reset (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h00000000, "OUTPUT register not zero after reset (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000000, "OUTPUT register not zero after reset (instance 2).")
    `RVX_ASSERT(gpio0_output == 32'h00000000, "OUTPUT signals not zero after reset (instance 0).")
    `RVX_ASSERT(gpio1_output == 16'h0000, "OUTPUT signals not zero after reset (instance 1).")
    `RVX_ASSERT(gpio2_output == 1'b0, "OUTPUT signals not zero after reset (instance 2).")

    $display("");
    $display("Change input signals and observe read values...");
    $display("-----------------------------------------------");
    $display("");

    $display("Setting GPIO 0 input vector to 0xA5A5A5A5...");
    gpio0_input = 32'hA5A5A5A5;
    $display("Setting GPIO 1 input vector to 0x5A5A...");
    gpio1_input = 16'h5A5A;
    $display("Setting GPIO 2 input vector to 0x1...");
    gpio2_input = 1'b1;
    #CLOCK_PERIOD;
    read_gpio_register(`RVX_GPIO_READ_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'hA5A5A5A5, "READ register did not reflect GPIO input changes (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h00005A5A, "READ register did not reflect GPIO input changes (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000001, "READ register did not reflect GPIO input changes (instance 2).")

    $display("");
    $display("Writing 0x000000FF to OUTPUT_ENABLE registers to set some pins as outputs...");
    $display("----------------------------------------------------------------------------");
    $display("");

    write_gpio_register(`RVX_GPIO_OUTPUT_ENABLE_REG_ADDR, 32'h000000FF);
    #CLOCK_PERIOD;
    read_gpio_register(`RVX_GPIO_OUTPUT_ENABLE_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'h000000FF, "OUTPUT_ENABLE register did not update correctly (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h000000FF, "OUTPUT_ENABLE register did not update correctly (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000001, "OUTPUT_ENABLE register did not update correctly (instance 2).")
    `RVX_ASSERT(gpio0_output_enable == 32'h000000FF, "OUTPUT_ENABLE signals did not update correctly (instance 0).")
    `RVX_ASSERT(gpio1_output_enable == 16'h00FF, "OUTPUT_ENABLE signals did not update correctly (instance 1).")
    `RVX_ASSERT(gpio2_output_enable == 1'b1, "OUTPUT_ENABLE signals did not update correctly (instance 2).")
    read_gpio_register(`RVX_GPIO_READ_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'hA5A5A500, "READ register did not reflect OUTPUT_ENABLE changes (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h00005A00, "READ register did not reflect OUTPUT_ENABLE changes (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000000, "READ register did not reflect OUTPUT_ENABLE changes (instance 2).")
    `RVX_ASSERT(gpio0_output == 32'h00000000, "OUTPUT signals did not reflect OUTPUT_ENABLE changes (instance 0).")
    `RVX_ASSERT(gpio1_output == 16'h0000, "OUTPUT signals did not reflect OUTPUT_ENABLE changes (instance 1).")
    `RVX_ASSERT(gpio2_output == 1'b0, "OUTPUT signals did not reflect OUTPUT_ENABLE changes (instance 2).")

    $display("");
    $display("Changing OUTPUT registers to set output pin values...");
    $display("-----------------------------------------------------");
    $display("");

    write_gpio_register(`RVX_GPIO_OUTPUT_REG_ADDR, 32'h000000FF);
    #CLOCK_PERIOD;
    read_gpio_register(`RVX_GPIO_OUTPUT_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'h000000FF, "OUTPUT register did not update correctly (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h000000FF, "OUTPUT register did not update correctly (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000001, "OUTPUT register did not update correctly (instance 2).")
    read_gpio_register(`RVX_GPIO_READ_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'hA5A5A5FF, "READ register did not reflect OUTPUT changes (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h00005AFF, "READ register did not reflect OUTPUT changes (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000001, "READ register did not reflect OUTPUT changes (instance 2).")
    `RVX_ASSERT(gpio0_output == 32'h000000FF, "OUTPUT signals did not update correctly (instance 0).")
    `RVX_ASSERT(gpio1_output == 16'h00FF, "OUTPUT signals did not update correctly (instance 1).")
    `RVX_ASSERT(gpio2_output == 1'b1, "OUTPUT signals did not update correctly (instance 2).")

    $display("");
    $display("Testing CLEAR register to clear output pin values...");
    $display("----------------------------------------------------");
    $display("");

    write_gpio_register(`RVX_GPIO_CLEAR_REG_ADDR, 32'hA50000A5);
    #CLOCK_PERIOD;
    read_gpio_register(`RVX_GPIO_OUTPUT_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'h0000005A, "OUTPUT register did not clear bits correctly (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h0000005A, "OUTPUT register did not clear bits correctly (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000000, "OUTPUT register did not clear bits correctly (instance 2).")
    read_gpio_register(`RVX_GPIO_READ_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'hA5A5A55A, "READ register did not reflect CLEAR changes (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h00005A5A, "READ register did not reflect CLEAR changes (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000000, "READ register did not reflect CLEAR changes (instance 2).")
    `RVX_ASSERT(gpio0_output == 32'h0000005A, "OUTPUT signals did not reflect CLEAR changes (instance 0).")
    `RVX_ASSERT(gpio1_output == 16'h005A, "OUTPUT signals did not reflect CLEAR changes (instance 1).")
    `RVX_ASSERT(gpio2_output == 1'b0, "OUTPUT signals did not reflect CLEAR changes (instance 2).")

    $display("");
    $display("Testing SET register to set output pin values...");
    $display("------------------------------------------------");
    $display("");

    write_gpio_register(`RVX_GPIO_SET_REG_ADDR, 32'h5A0000A5);
    #CLOCK_PERIOD;
    read_gpio_register(`RVX_GPIO_OUTPUT_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'h5A0000FF, "OUTPUT register did not set bits correctly (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h000000FF, "OUTPUT register did not set bits correctly (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000001, "OUTPUT register did not set bits correctly (instance 2).")
    read_gpio_register(`RVX_GPIO_READ_REG_ADDR);
    `RVX_ASSERT(read_data0 == 32'hA5A5A5FF, "READ register did not reflect SET changes (instance 0).")
    `RVX_ASSERT(read_data1 == 32'h00005AFF, "READ register did not reflect SET changes (instance 1).")
    `RVX_ASSERT(read_data2 == 32'h00000001, "READ register did not reflect SET changes (instance 2).")
    `RVX_ASSERT(gpio0_output == 32'h5A0000FF, "OUTPUT signals did not reflect SET changes (instance 0).")
    `RVX_ASSERT(gpio1_output == 16'h00FF, "OUTPUT signals did not reflect SET changes (instance 1).")
    `RVX_ASSERT(gpio2_output == 1'b1, "OUTPUT signals did not reflect SET changes (instance 2).")

    $display("");
    $display("Testbench result:");
    $display("-----------------");
    $display("");
    if (error_count === 0) $display("Passed RTL testbench for the RVX GPIO module.");
    else $display("[ERROR] GPIO module failed one or more unit tests. Please investigate.");
    $display("");

    $finish();

  end

endmodule
