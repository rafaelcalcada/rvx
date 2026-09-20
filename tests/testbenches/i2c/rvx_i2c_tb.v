// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"
`include "rvx_test_macros.vh"

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
  wire           sda_output;  // instance1 TX line, looped back into instance0's SDA input.
  wire           scl_output_probe;  // instance1 SCL line, observed only (SCL itself is driven externally by scl_input).
  wire           i2c_irq;

  // Test variables
  integer        error_count;

  // Edge capture for START/RESTART/STOP waveform checks
  reg            capture_edges;
  reg sda_prev, scl_prev;
  reg [63:0] t_sda_fall, t_sda_rise, t_scl_fall, t_scl_rise;

  // Clock generation
  localparam CLOCK_PERIOD = 20;
  initial clock = 1'b0;
  always #(CLOCK_PERIOD / 2) clock <= !clock;

  // verilator lint_off PINCONNECTEMPTY
  // Receiver/controller under test: samples instance1's transmitted SDA line.
  rvx_i2c rvx_i2c_instance0 (

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

  // Loopback transmitter: receives the same register commands as instance0 and
  // drives the SDA waveform that instance0 samples as a simulated peer device.
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
      .scl_output(scl_output_probe),

      // Interrupt request
      .i2c_irq()
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
      scl_input     = 1'b1;
      capture_edges = 1'b0;
      #(CLOCK_PERIOD * 2);
      reset_n = 1'b1;
      #(CLOCK_PERIOD * 2);
      sda_prev = sda_output;
      scl_prev = scl_output_probe;
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

  // Wait until the controller under test has finished the current command.
  task wait_command_completion;
    begin
      while (rvx_i2c_instance0.busy || rvx_i2c_instance0.start) #(CLOCK_PERIOD);
    end
  endtask

  // Track SDA/SCL edges so START/RESTART/STOP waveforms can be checked by ordering, not exact
  // timing, since only the relative order of the SDA/SCL transitions defines a valid condition.
  // verilator lint_off SYNCASYNCNET
  always @(sda_output) begin
    if (capture_edges && sda_prev === 1'b1 && sda_output === 1'b0) t_sda_fall = $time;
    if (capture_edges && sda_prev === 1'b0 && sda_output === 1'b1) t_sda_rise = $time;
    sda_prev = sda_output;
  end

  always @(scl_output_probe) begin
    if (capture_edges && scl_prev === 1'b1 && scl_output_probe === 1'b0) t_scl_fall = $time;
    if (capture_edges && scl_prev === 1'b0 && scl_output_probe === 1'b1) t_scl_rise = $time;
    scl_prev = scl_output_probe;
  end
  // verilator lint_on SYNCASYNCNET

  task check_start_like_condition;
    input [15:0] command;
    begin
      t_sda_fall    = 0;
      t_scl_fall    = 0;
      capture_edges = 1'b1;
      write_register(`RVX_I2C_COMMAND_REG_ADDR, command);
      write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_RUN);
      wait_command_completion();
      capture_edges = 1'b0;
      `RVX_ASSERT(t_sda_fall != 0 && t_scl_fall != 0, "Expected both an SDA and an SCL falling edge.")
      `RVX_ASSERT(t_scl_fall > t_sda_fall, "SCL fell before SDA, which does not produce a valid START condition.")
    end
  endtask

  integer duration_low, duration_high;

  // Measures the exact number of clock cycles the module stays "busy" during a DATA command,
  // isolated from any register write overhead, to check the per-bit timing against DIVIDER.
  task measure_data_transfer_cycles;
    input [15:0] divider_value;
    output integer cycles;
    reg [63:0] t_busy_start, t_busy_end;
    begin
      write_register(`RVX_I2C_DIVIDER_REG_ADDR, divider_value);
      write_register(`RVX_I2C_DATA_REG_ADDR, 16'hA5);
      write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_DATA);
      write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_RUN);
      if (!rvx_i2c_instance0.busy) @(posedge rvx_i2c_instance0.busy);
      // verilator lint_off WIDTHTRUNC
      t_busy_start = $time;
      @(negedge rvx_i2c_instance0.busy);
      t_busy_end = $time;
      cycles     = (t_busy_end - t_busy_start) / CLOCK_PERIOD;
      // verilator lint_on WIDTHTRUNC
    end
  endtask

  initial begin

    error_count = 0;

    reset_all_devices();

    $display("");
    $display("Checking I2C module state after reset...");
    $display("----------------------------------------");
    read_register(`RVX_I2C_DIVIDER_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h0, "Register RVX_I2C_DIVIDER_REG_ADDR is not 0 after reset.")

    read_register(`RVX_I2C_DATA_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h0, "Register RVX_I2C_DATA_REG_ADDR is not 0 after reset.")

    read_register(`RVX_I2C_COMMAND_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h0, "Register RVX_I2C_COMMAND_REG_ADDR is not 0 after reset.")

    read_register(`RVX_I2C_STATUS_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h18, "Register RVX_I2C_STATUS_REG_ADDR is not 0x18 after reset.")

    `RVX_ASSERT(i2c_irq === 1'b0, "Irq is not clear after reset.")
    `RVX_ASSERT(rvx_i2c_instance0.busy === 1'b0, "busy is not clear after reset.")
    `RVX_ASSERT(sda_output === 1'b1, "SDA line is not idle-high after reset.")
    `RVX_ASSERT(scl_output_probe === 1'b1, "SCL line is not idle-high after reset.")

    $display("");
    $display("Testing prescale (divider) register...");
    $display("--------------------------------------");
    write_register(`RVX_I2C_DIVIDER_REG_ADDR, 16'h4);
    read_register(`RVX_I2C_DIVIDER_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h4, "Register RVX_I2C_DIVIDER_REG_ADDR is not 0x00000004 after write.")

    write_register(`RVX_I2C_DIVIDER_REG_ADDR, 16'hFFFF);
    read_register(`RVX_I2C_DIVIDER_REG_ADDR);
    `RVX_ASSERT(read_data === 32'hFFFF, "Register RVX_I2C_DIVIDER_REG_ADDR is not 0x0000FFFF after write.")

    write_register(`RVX_I2C_DIVIDER_REG_ADDR, 16'h0);
    read_register(`RVX_I2C_DIVIDER_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h0, "Register RVX_I2C_DIVIDER_REG_ADDR is not 0x00000000 after write.")

    $display("");
    $display("Testing command register encodings...");
    $display("-------------------------------------");
    write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_NOP);
    read_register(`RVX_I2C_COMMAND_REG_ADDR);
    `RVX_ASSERT(read_data === `RVX_I2C_COMMAND_NOP, "Register RVX_I2C_COMMAND_REG_ADDR is not NOP after write.")

    write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_START);
    read_register(`RVX_I2C_COMMAND_REG_ADDR);
    `RVX_ASSERT(read_data === `RVX_I2C_COMMAND_START, "Register RVX_I2C_COMMAND_REG_ADDR is not START after write.")

    $display("");
    $display("Testing the timing/shape of the START condition (SDA falls while SCL is high, then SCL falls)...");
    $display("------------------------------------------------------------------------------------------------");
    reset_all_devices();
    check_start_like_condition(`RVX_I2C_COMMAND_START);

    $display("");
    $display("Testing the timing/shape of the RESTART condition (same shape as START)...");
    $display("--------------------------------------------------------------------------");
    reset_all_devices();
    check_start_like_condition(`RVX_I2C_COMMAND_RESTART);

    $display("");
    $display("Testing the timing/shape of the STOP condition (SCL rises while SDA is low, then SDA rises)...");
    $display("----------------------------------------------------------------------------------------------");
    reset_all_devices();
    t_sda_rise    = 0;
    t_scl_rise    = 0;
    capture_edges = 1'b1;
    write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_STOP);
    write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_RUN);
    wait_command_completion();
    capture_edges = 1'b0;
    `RVX_ASSERT(t_sda_rise != 0 && t_scl_rise != 0, "Expected both an SDA and an SCL rising edge.")
    `RVX_ASSERT(t_sda_rise > t_scl_rise, "SDA rose before SCL, which does not produce a valid STOP condition.")

    $display("");
    $display("Testing data transfer (TX/RX loopback) without ACK...");
    $display("-----------------------------------------------------");
    reset_all_devices();
    write_register(`RVX_I2C_DIVIDER_REG_ADDR, 16'h2);
    write_register(`RVX_I2C_DATA_REG_ADDR, 16'hA5);
    write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_DATA);
    write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_RUN);
    wait_command_completion();
    read_register(`RVX_I2C_DATA_REG_ADDR);
    `RVX_ASSERT(read_data === 32'hA5, "Received data does not match the transmitted byte (0xA5).")
    read_register(`RVX_I2C_STATUS_REG_ADDR);
    `RVX_ASSERT(read_data[`RVX_I2C_STATUS_BIT_ACK] === 1'b0,
                "Received ACK bit is set even though the ACK bit was not driven.")
    `RVX_ASSERT(read_data[`RVX_I2C_STATUS_BIT_IRQ] === 1'b1, "Irq is not set after transfer completion.")
    `RVX_ASSERT(i2c_irq === 1'b1, "Irq output is not set after transfer completion.")

    $display("");
    $display("Testing data transfer (TX/RX loopback) with ACK...");
    $display("--------------------------------------------------");
    write_register(`RVX_I2C_DATA_REG_ADDR, 16'h3C);
    write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_DATA);
    write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_RUN | `RVX_I2C_STATUS_MASK_ACK);
    wait_command_completion();
    read_register(`RVX_I2C_DATA_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h3C, "Received data does not match the transmitted byte (0x3C).")
    read_register(`RVX_I2C_STATUS_REG_ADDR);
    `RVX_ASSERT(read_data[`RVX_I2C_STATUS_BIT_ACK] === 1'b1,
                "Received ACK bit is clear even though the ACK bit was driven.")

    $display("");
    $display("Testing that the irq flag is only cleared by an explicit write...");
    $display("-----------------------------------------------------------------");
    `RVX_ASSERT(i2c_irq === 1'b1, "Irq was unexpectedly cleared.")
    write_register(`RVX_I2C_DATA_REG_ADDR, 16'h00);
    `RVX_ASSERT(i2c_irq === 1'b1, "Irq was cleared by an unrelated register write.")
    write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_IRQ);
    #(CLOCK_PERIOD);
    `RVX_ASSERT(i2c_irq === 1'b0, "Irq was not cleared by writing the IRQ status bit.")

    $display("");
    $display("Testing that the SDA/SCL status bits track the live bus state...");
    $display("----------------------------------------------------------------");
    scl_input = 1'b0;
    #(CLOCK_PERIOD);
    read_register(`RVX_I2C_STATUS_REG_ADDR);
    `RVX_ASSERT(read_data[`RVX_I2C_STATUS_BIT_SCL] === 1'b0, "STATUS SCL bit did not track the SCL line going low.")
    scl_input = 1'b1;
    #(CLOCK_PERIOD);
    read_register(`RVX_I2C_STATUS_REG_ADDR);
    `RVX_ASSERT(read_data[`RVX_I2C_STATUS_BIT_SCL] === 1'b1, "STATUS SCL bit did not track the SCL line going high.")

    $display("");
    $display("Testing clock stretching (external device holding SCL low)...");
    $display("-------------------------------------------------------------");
    reset_all_devices();
    write_register(`RVX_I2C_DIVIDER_REG_ADDR, 16'h2);
    write_register(`RVX_I2C_DATA_REG_ADDR, 16'h5A);
    write_register(`RVX_I2C_COMMAND_REG_ADDR, `RVX_I2C_COMMAND_DATA);
    write_register(`RVX_I2C_STATUS_REG_ADDR, `RVX_I2C_STATUS_MASK_RUN);
    wait (rvx_i2c_instance0.busy && rvx_i2c_instance0.scl_data_shift_reg[17] === 1'b1);
    scl_input = 1'b0;
    #(CLOCK_PERIOD);
    `RVX_ASSERT(rvx_i2c_instance0.clock_stretching === 1'b1,
                "clock_stretching flag not asserted while SCL is held low externally.")
    `RVX_ASSERT(rvx_i2c_instance0.busy === 1'b1, "Transfer completed despite the clock being stretched.")
    #(CLOCK_PERIOD * 20);
    `RVX_ASSERT(rvx_i2c_instance0.busy === 1'b1, "Transfer completed despite the clock still being stretched.")
    scl_input = 1'b1;
    wait_command_completion();
    read_register(`RVX_I2C_DATA_REG_ADDR);
    `RVX_ASSERT(read_data === 32'h5A, "Received data is incorrect after a clock-stretched transfer.")

    $display("");
    $display("Testing that the DIVIDER value scales the per-bit transfer timing...");
    $display("----------------------------------------------------------------------");
    reset_all_devices();
    measure_data_transfer_cycles(16'd1, duration_low);
    reset_all_devices();
    measure_data_transfer_cycles(16'd4, duration_high);
    $display("");
    $display("Cycles with DIVIDER=1: %0d, cycles with DIVIDER=4: %0d", duration_low, duration_high);
    `RVX_ASSERT(duration_high > duration_low, "Increasing DIVIDER did not increase the transfer duration.")
    // A DATA command performs 18 shifts, plus one extra (divider+1) settle period so the
    // registered SDA/SCL outputs and rx_reg can present their final value before busy drops.
    `RVX_ASSERT((duration_high - duration_low) === (19 * (4 - 1)),
                "Transfer duration did not scale linearly with DIVIDER as expected (18 shifts + 1 settle period).")

    $display("");
    $display("Testbench result:");
    $display("-----------------");
    $display("");
    if (error_count === 0) $display("Passed RTL testbench for the I2C module of RVX.");
    else $display("[ERROR] I2C module failed one or more unit tests. Please investigate.");
    $display("");

    $finish();
  end

endmodule

