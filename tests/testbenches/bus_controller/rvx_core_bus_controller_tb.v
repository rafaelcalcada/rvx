// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"
`include "rvx_test_macros.vh"

module rvx_core_bus_controller_tb ();

  // Global signals
  reg            clock;
  reg            reset_n;

  // Instruction bus interface
  reg     [31:0] ibus_rdata;
  reg            ibus_rresponse;
  wire    [31:0] ibus_address;
  wire           ibus_rrequest;

  // Data bus interface
  reg     [31:0] dbus_rdata;
  reg            dbus_rresponse;
  reg            dbus_wresponse;
  wire    [31:0] dbus_address;
  wire           dbus_rrequest;
  wire    [31:0] dbus_wdata;
  wire           dbus_wrequest;
  wire    [ 3:0] dbus_wstrobe;

  // Core interface
  reg            flush_pipeline_s1;
  reg            load_s1;
  reg            misaligned_load_s1;
  reg            misaligned_store_s1;
  reg     [31:0] program_counter_s0;
  reg            store_s1;
  reg     [31:0] store_data_s1;
  reg     [ 3:0] store_strobe_s1;
  reg            take_trap_s1;
  reg     [31:2] target_address_31_2_s1;
  wire           clock_enable;
  wire    [31:0] instruction_s1;
  wire    [31:0] memory_data_s2;

  // Test variables
  integer        error_count;

  rvx_core_bus_controller rvx_core_bus_controller_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Instruction bus interface
      .ibus_rdata    (ibus_rdata),
      .ibus_rresponse(ibus_rresponse),
      .ibus_address  (ibus_address),
      .ibus_rrequest (ibus_rrequest),

      // Data bus interface
      .dbus_rdata    (dbus_rdata),
      .dbus_rresponse(dbus_rresponse),
      .dbus_wresponse(dbus_wresponse),
      .dbus_address  (dbus_address),
      .dbus_rrequest (dbus_rrequest),
      .dbus_wdata    (dbus_wdata),
      .dbus_wrequest (dbus_wrequest),
      .dbus_wstrobe  (dbus_wstrobe),

      // Inputs
      .flush_pipeline_s1     (flush_pipeline_s1),
      .load_s1               (load_s1),
      .misaligned_load_s1    (misaligned_load_s1),
      .misaligned_store_s1   (misaligned_store_s1),
      .program_counter_s0    (program_counter_s0),
      .store_s1              (store_s1),
      .store_data_s1         (store_data_s1),
      .store_strobe_s1       (store_strobe_s1),
      .take_trap_s1          (take_trap_s1),
      .target_address_31_2_s1(target_address_31_2_s1),

      // Outputs
      .clock_enable  (clock_enable),
      .instruction_s1(instruction_s1),
      .memory_data_s2(memory_data_s2)

  );

  localparam CLOCK_PERIOD = 20;
  initial clock = 1'b0;
  always #(CLOCK_PERIOD / 2) clock <= !clock;

  task reset_controller;
    begin
      @(negedge clock);
      reset_n        = 1'b0;
      ibus_rdata     = `RISCV_NOP_INSTRUCTION;
      ibus_rresponse = 1'b0;
      dbus_rdata     = 32'h00000000;
      dbus_rresponse = 1'b0;
      dbus_wresponse = 1'b0;
      @(posedge clock);
      #1;
      @(negedge clock);
      reset_n = 1'b1;
    end
  endtask

  task launch_instruction_and_load;
    input [31:0] instruction_address;
    input [31:0] load_address;
    begin
      program_counter_s0     = instruction_address;
      target_address_31_2_s1 = load_address[31:2];
      load_s1                = 1'b1;
      @(posedge clock);
      #1;
      `RVX_ASSERT(ibus_rrequest, "Instruction request was not issued.")
      `RVX_ASSERT(dbus_rrequest, "Data read request was not issued.")
      `RVX_ASSERT(!clock_enable, "Pipeline did not stall for outstanding bus requests.")
      `RVX_ASSERT(ibus_address == instruction_address, "Instruction address was not held.")
      `RVX_ASSERT(dbus_address == load_address, "Data address was not held.")
    end
  endtask

  initial begin

    error_count            = 0;
    flush_pipeline_s1      = 1'b0;
    load_s1                = 1'b0;
    misaligned_load_s1     = 1'b0;
    misaligned_store_s1    = 1'b0;
    program_counter_s0     = 32'h00000000;
    store_s1               = 1'b0;
    store_data_s1          = 32'h00000000;
    store_strobe_s1        = 4'b0000;
    take_trap_s1           = 1'b0;
    target_address_31_2_s1 = 30'h00000000;

    $display("");
    $display("Testing instruction response before data response...");
    $display("----------------------------------------------------");

    reset_controller();
    launch_instruction_and_load(32'h00000100, 32'h00000200);

    @(negedge clock);
    ibus_rdata     = 32'h12345678;
    ibus_rresponse = 1'b1;
    @(posedge clock);
    #1;
    @(negedge clock);
    ibus_rresponse = 1'b0;
    `RVX_ASSERT(!ibus_rrequest, "Instruction request was not withdrawn after its response.")
    `RVX_ASSERT(dbus_rrequest, "Data request was not held while awaiting its response.")
    `RVX_ASSERT(!clock_enable, "Pipeline resumed before the data response.")
    `RVX_ASSERT(instruction_s1 == `RISCV_NOP_INSTRUCTION,
                "Instruction changed while the data request was pending.")

    @(posedge clock);
    #1;
    `RVX_ASSERT(!clock_enable, "A one-cycle instruction response was not retained.")

    @(negedge clock);
    load_s1        = 1'b0;
    dbus_rdata     = 32'h89ABCDEF;
    dbus_rresponse = 1'b1;
    #1;
    `RVX_ASSERT(clock_enable, "Pipeline did not become enabled when both responses arrived.")
    @(posedge clock);
    #1;
    `RVX_ASSERT(!clock_enable, "The next instruction request was not tracked after resume.")
    `RVX_ASSERT(instruction_s1 == 32'h12345678, "Instruction response data was not retained.")
    `RVX_ASSERT(memory_data_s2 == 32'h89ABCDEF, "Data response data was not retained.")
    @(negedge clock);
    dbus_rresponse = 1'b0;

    $display("");
    $display("Testing data response before instruction response...");
    $display("----------------------------------------------------");

    reset_controller();
    launch_instruction_and_load(32'h00000300, 32'h00000400);

    @(negedge clock);
    dbus_rdata     = 32'hCAFEBABE;
    dbus_rresponse = 1'b1;
    @(posedge clock);
    #1;
    `RVX_ASSERT(ibus_rrequest, "Instruction request was not held while awaiting its response.")
    `RVX_ASSERT(!dbus_rrequest, "Data request was not withdrawn after its response.")
    `RVX_ASSERT(!clock_enable, "Pipeline resumed before the instruction response.")
    `RVX_ASSERT(memory_data_s2 == 32'hCAFEBABE, "Early data response was not retained.")

    @(negedge clock);
    dbus_rresponse = 1'b0;
    @(posedge clock);
    #1;
    `RVX_ASSERT(!clock_enable, "A one-cycle data response was not retained.")

    @(negedge clock);
    load_s1        = 1'b0;
    ibus_rdata     = 32'h0BADF00D;
    ibus_rresponse = 1'b1;
    #1;
    `RVX_ASSERT(clock_enable, "Pipeline did not become enabled when both responses arrived.")
    @(posedge clock);
    #1;
    `RVX_ASSERT(instruction_s1 == 32'h0BADF00D, "Instruction response data was not retained.")
    `RVX_ASSERT(memory_data_s2 == 32'hCAFEBABE,
                "Data response data was lost while waiting for instruction.")
    @(negedge clock);
    ibus_rresponse = 1'b0;
    #1;
    `RVX_ASSERT(!clock_enable, "The next instruction request was not tracked after resume.")

    $display("");
    $display("Testing write response before instruction response...");
    $display("---------------------------------------------------");

    reset_controller();
    program_counter_s0     = 32'h00000500;
    target_address_31_2_s1 = 30'h00000180;
    store_s1               = 1'b1;
    store_data_s1          = 32'hA5A55A5A;
    store_strobe_s1        = 4'b0101;
    @(posedge clock);
    #1;
    `RVX_ASSERT(ibus_rrequest, "Instruction request was not issued for the store.")
    `RVX_ASSERT(dbus_wrequest, "Data write request was not issued.")
    `RVX_ASSERT(!clock_enable, "Pipeline did not stall for the outstanding write.")
    `RVX_ASSERT(dbus_address == 32'h00000600, "Data write address was incorrect.")
    `RVX_ASSERT(dbus_wdata == 32'hA5A55A5A, "Data write payload was incorrect.")
    `RVX_ASSERT(dbus_wstrobe == 4'b0101, "Data write strobe was incorrect.")

    @(negedge clock);
    dbus_wresponse = 1'b1;
    @(posedge clock);
    #1;
    `RVX_ASSERT(!clock_enable, "Pipeline resumed before the instruction response.")
    `RVX_ASSERT(ibus_rrequest, "Instruction request was not held while awaiting its response.")
    `RVX_ASSERT(!dbus_wrequest, "Completed write request was not withdrawn.")
    `RVX_ASSERT(dbus_wdata == 32'hA5A55A5A, "Write payload changed while the pipeline was stalled.")
    `RVX_ASSERT(dbus_wstrobe == 4'b0101, "Write strobe changed while the pipeline was stalled.")

    @(negedge clock);
    dbus_wresponse = 1'b0;
    store_s1       = 1'b0;
    @(posedge clock);
    #1;
    `RVX_ASSERT(!clock_enable, "One-cycle write response was not retained while stalled.")
    `RVX_ASSERT(!dbus_wrequest, "Completed write request was reissued while stalled.")

    @(negedge clock);
    ibus_rdata     = 32'h55AA55AA;
    ibus_rresponse = 1'b1;
    #1;
    `RVX_ASSERT(clock_enable, "Pipeline did not resume after both responses arrived.")
    @(posedge clock);
    #1;
    `RVX_ASSERT(instruction_s1 == 32'h55AA55AA, "Instruction response data was not accepted.")
    `RVX_ASSERT(!dbus_wrequest, "Completed write request was reissued after resume.")
    @(negedge clock);
    ibus_rresponse = 1'b0;
    #1;
    `RVX_ASSERT(!clock_enable, "The next instruction request was not tracked after resume.")

    $display("");
    $display("Testing instruction response before write response...");
    $display("---------------------------------------------------");

    reset_controller();
    program_counter_s0     = 32'h00000700;
    target_address_31_2_s1 = 30'h00000200;
    store_s1               = 1'b1;
    store_data_s1          = 32'hDEADBEEF;
    store_strobe_s1        = 4'b1010;
    @(posedge clock);
    #1;
    `RVX_ASSERT(ibus_rrequest, "Instruction request was not issued for the store.")
    `RVX_ASSERT(dbus_wrequest, "Data write request was not issued.")
    `RVX_ASSERT(!dbus_rrequest, "Store unexpectedly issued a data read request.")
    `RVX_ASSERT(!clock_enable, "Pipeline did not stall for the outstanding write.")
    `RVX_ASSERT(dbus_address == 32'h00000800, "Data write address was incorrect.")
    `RVX_ASSERT(dbus_wdata == 32'hDEADBEEF, "Data write payload was incorrect.")
    `RVX_ASSERT(dbus_wstrobe == 4'b1010, "Data write strobe was incorrect.")

    @(negedge clock);
    ibus_rdata     = 32'h11223344;
    ibus_rresponse = 1'b1;
    @(posedge clock);
    #1;
    `RVX_ASSERT(!ibus_rrequest, "Completed instruction request was not withdrawn.")
    `RVX_ASSERT(!clock_enable, "Pipeline resumed before the write response.")
    `RVX_ASSERT(instruction_s1 == `RISCV_NOP_INSTRUCTION,
                "Instruction changed while the write request was pending.")

    @(negedge clock);
    ibus_rresponse         = 1'b0;
    ibus_rdata             = 32'h00000000;
    program_counter_s0     = 32'h00000900;
    target_address_31_2_s1 = 30'h00000280;
    store_s1               = 1'b0;
    store_data_s1          = 32'h00000000;
    store_strobe_s1        = 4'b0000;
    repeat (3) begin
      @(posedge clock);
      #1;
      `RVX_ASSERT(!clock_enable, "Pipeline resumed while the write response was delayed.")
      `RVX_ASSERT(!ibus_rrequest, "Completed instruction request was reissued while stalled.")
      `RVX_ASSERT(ibus_address == 32'h00000700, "Instruction address changed while stalled.")
      `RVX_ASSERT(dbus_wrequest, "Write request was withdrawn before its response.")
      `RVX_ASSERT(dbus_address == 32'h00000800, "Pending write address changed while stalled.")
      `RVX_ASSERT(dbus_wdata == 32'hDEADBEEF, "Pending write payload changed while stalled.")
      `RVX_ASSERT(dbus_wstrobe == 4'b1010, "Pending write strobe changed while stalled.")
      `RVX_ASSERT(instruction_s1 == `RISCV_NOP_INSTRUCTION,
                  "Instruction changed while the write response was delayed.")
    end

    @(negedge clock);
    dbus_wresponse = 1'b1;
    #1;
    `RVX_ASSERT(clock_enable, "Pipeline did not resume when the delayed write response arrived.")
    `RVX_ASSERT(!dbus_wrequest, "Completed write request was not withdrawn.")
    `RVX_ASSERT(instruction_s1 == 32'h11223344, "Buffered instruction was lost during the write stall.")
    @(posedge clock);
    #1;
    `RVX_ASSERT(instruction_s1 == 32'h11223344, "Buffered instruction was not retained after resume.")
    `RVX_ASSERT(ibus_rrequest, "The next instruction request was not issued after resume.")
    `RVX_ASSERT(ibus_address == 32'h00000900, "The next instruction address was not accepted.")
    `RVX_ASSERT(!dbus_wrequest, "Completed write request was reissued after resume.")
    @(negedge clock);
    dbus_wresponse = 1'b0;
    #1;
    `RVX_ASSERT(!clock_enable, "The next instruction request was not tracked after resume.")

    $display("");
    $display("Testbench result:");
    $display("-----------------");
    $display("");
    if (error_count === 0) $display("Passed RTL testbench for the RVX core bus controller.");
    else $display("[ERROR] RVX core bus controller failed one or more unit tests.");
    $display("");

    $finish();

  end

endmodule
