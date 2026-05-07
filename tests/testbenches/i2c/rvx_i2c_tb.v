// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"
`include "rvx_test_macros.vh"

`define RVX_TITLE(msg)                                  \
  $display("");                                         \
  $display("-> ", msg);                                 \
  $display("-----------------------------------------");

module rvx_i2c_tb ();

  // Global signals
  reg            clock;
  reg            reset_n;

  // Register read/write
  reg     [ 4:0] rw_address;
  wire    [31:0] read_data;
  reg            read_request;
  reg     [15:0] write_data;
  reg            write_request;
  reg     [ 3:0] write_strobe;

  // I2C signals
  reg            scl_input;
  wire           sda_output;
  wire           i2c_irq;

  // Test variables
  integer        error_count;

  // Clock generation
  localparam CLOCK_PERIOD = 20;
  initial clock = 1'b0;
  always #(CLOCK_PERIOD / 2) clock <= !clock;

  // verilator lint_off PINCONNECTEMPTY
  rvx_i2c rvx_i2c_instance (

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

      // I2C signals
      .sda_input (sda_output),
      .scl_input (scl_input),
      .sda_output(),
      .scl_output(),

      // Interrupt request
      .i2c_irq(i2c_irq)
  );

  rvx_i2c rvx_i2c_instance1 (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // IO interface
      .rw_address    (rw_address),
      .read_data     (),
      .read_request  (read_request),
      .read_response (),
      .write_data    (write_data),
      .write_strobe  (write_strobe),
      .write_request (write_request),
      .write_response(),

      // I2C signals
      .sda_input (),
      .scl_input (scl_input),
      .sda_output(sda_output),
      .scl_output(),

      // Interrupt request
      .i2c_irq(i2c_irq)
  );
  // verilator lint_on PINCONNECTEMPTY

  task reset_all_devices;
    begin
      reset_n       = 1'b0;
      rw_address    = 5'h00;
      read_request  = 1'b0;
      write_request = 1'b0;
      write_strobe  = 4'b0;
      write_data    = 16'b0;
      #(CLOCK_PERIOD * 2);
      reset_n = 1'b1;
      #(CLOCK_PERIOD * 2);
    end
  endtask

  function [8*13-1:0] reg_name;
    input [4:0] address;
    begin
      case (address)
        `RVX_I2C_DIVIDER_REG_ADDR: reg_name = "DIVIDER";
        `RVX_I2C_DATA_REG_ADDR:    reg_name = "DATA";
        `RVX_I2C_STATUS_REG_ADDR:  reg_name = "STATUS";
        `RVX_I2C_COMMAND_REG_ADDR: reg_name = "COMMAND";
        default:                   reg_name = "UNKNOWN";
      endcase
    end
  endfunction

  task read_register;
    input [4:0] address;
    begin
      rw_address   = address;
      read_request = 1'b1;
      #(CLOCK_PERIOD);
      read_request = 1'b0;
      rw_address   = 5'h00;
      $display("");
      $display("Reading I2C register: %s", reg_name(address));
      $display("Read value: 0x%08h", read_data);
    end
  endtask

  task write_register;
    input [4:0] address;
    input [15:0] data;
    begin
      $display("");
      $display("Writing I2C register: %s", reg_name(address));
      $display("Write value: 0x%08h", data);
      rw_address    = address;
      write_data    = data;
      write_request = 1'b1;
      write_strobe  = 4'b1111;
      #(CLOCK_PERIOD);
      write_request = 1'b0;
      rw_address    = 5'h00;
      write_data    = 16'b0;
      write_strobe  = 4'b0000;
    end
  endtask

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, rvx_i2c_tb);

    reset_all_devices();

    `RVX_TITLE("Start test I2C");

    `RVX_TITLE("Test register and irq after reset");
    read_register(`RVX_I2C_DIVIDER_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h0, "Register RVX_I2C_DIVIDER_REG_ADDR is not 0 after reset.")

    read_register(`RVX_I2C_DATA_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h0, "Register RVX_I2C_DATA_REG_ADDR is not 0 after reset.")

    read_register(`RVX_I2C_COMMAND_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h0, "Register RVX_I2C_COMMAND_REG_ADDR is not 0 after reset.")

    read_register(`RVX_I2C_STATUS_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h0, "Register RVX_I2C_STATUS_REG_ADDR is not 0 after reset.")

    `RVX_ASSERT(i2c_irq === 1'b0, "Irq is not clear after reset.")

    `RVX_TITLE("Test prescale");
    write_register(`RVX_I2C_DIVIDER_REG_ADDR, 16'h4);
    read_register(`RVX_I2C_DIVIDER_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h4, "Register RVX_I2C_DIVIDER_REG_ADDR is not 0x00000004 after write.")

    `RVX_TITLE("Test start");
    write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_START);
    read_register(`RVX_I2C_COMMAND_REG_ADDR);
    `RVX_ASSERT(read_data === `RVX_I2C_COMMAND_START,
                "Register RVX_I2C_COMMAND_REG_ADDR is not 0x00000001 after write.")

    write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_RUN);
    #(CLOCK_PERIOD * 4);
    read_register(`RVX_I2C_STATUS_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h1, "Register RVX_I2C_STATUS_REG_ADDR is not 0x00000001 after write.")
    #(CLOCK_PERIOD * 50);

    `RVX_TITLE("Test data");
    write_register(`RVX_I2C_DATA_REG_ADDR, 'h0);
    write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_DATA);
    write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_RUN);
    #(CLOCK_PERIOD * 200);

    read_register(`RVX_I2C_DATA_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h0, "Register RVX_I2C_DATA_REG_ADDR is not 0x00000000 after write.")
    read_register(`RVX_I2C_STATUS_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h4, "Register RVX_I2C_STATUS_REG_ADDR is not 0x00000004 after write.")

    `RVX_TITLE("Test set irq after run");
    `RVX_ASSERT(i2c_irq === 1'b1, "Irq is not set")

    `RVX_TITLE("Test restart");
    write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_RESTART);
    read_register(`RVX_I2C_COMMAND_REG_ADDR);
    `RVX_ASSERT(read_data === `RVX_I2C_COMMAND_RESTART,
                "Register RVX_I2C_COMMAND_REG_ADDR is not 0x00000002 after write.")

    write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_RUN);
    read_register(`RVX_I2C_STATUS_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h5, "Register RVX_I2C_STATUS_REG_ADDR is not 0x00000005 after write.")
    #(CLOCK_PERIOD * 50);

    `RVX_TITLE("Test set irq after run");
    `RVX_ASSERT(i2c_irq === 1'b1, "Irq is not set")

    `RVX_TITLE("Test data");
    write_register(`RVX_I2C_DATA_REG_ADDR, 'h3);
    write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_DATA);
    write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_RUN | `RVX_I2C_STATUS_MASK_ACK);
    #(CLOCK_PERIOD * 200);

    read_register(`RVX_I2C_DATA_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h3, "Register RVX_I2C_DATA_REG_ADDR is not 0x00000003 after write.")
    read_register(`RVX_I2C_STATUS_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h6, "Register RVX_I2C_STATUS_REG_ADDR is not 0x00000006 after write.")

    `RVX_TITLE("Test set irq after run");
    `RVX_ASSERT(i2c_irq === 1'b1, "Irq is not set")

    `RVX_TITLE("Test stop");
    write_register(`RVX_I2C_DATA_REG_ADDR, 'h0);
    write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_STOP);
    write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_RUN);
    #(CLOCK_PERIOD * 50);
    write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_IRQ);
    #(CLOCK_PERIOD);

    `RVX_TITLE("Test clear irq");
    `RVX_ASSERT(i2c_irq === 1'b0, "Irq is not clear")

    #(CLOCK_PERIOD * 50);

    `RVX_TITLE("Testbench result:");
    if (error_count === 0) $display("Passed RTL testbench for the I2C module of RVX.");
    else $display("[ERROR] I2C module failed one or more unit tests. Please investigate.");
    $display("");

    $finish();
  end

  // Test clock stretching by forcing the SCL line low when the I2C controller releases it
  initial begin
    scl_input = 1'b1;
    #1550;
    scl_input = 1'b0;
    #1000;
    scl_input = 1'b1;
  end

endmodule
