// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_test_macros.vh"

module rvx_single_port_memory_tb ();

  // Program constants (see program.mem)
  localparam MEMORY_SIZE_IN_BYTES = 8192;
  localparam [31:0] COUNTER_ADDRESS = 32'h00001000;
  localparam [31:0] DONE_FLAG_ADDRESS = 32'h00001004;
  localparam [31:0] COUNTER_FINAL_VALUE = 32'h00000014;
  localparam EXPECTED_STORES = 5;
  localparam TIMEOUT_IN_CYCLES = 2000;

  // System indexes
  localparam NUM_SYSTEMS = 2;
  localparam DATA_PRIORITY = 0;
  localparam INSTRUCTION_PRIORITY = 1;

  // Global signals
  reg            clock;
  reg            reset_n;

  // Observation signals
  wire    [31:0] fetch_address       [0:NUM_SYSTEMS-1];
  wire    [31:0] memory_address      [0:NUM_SYSTEMS-1];
  wire    [31:0] memory_wdata        [0:NUM_SYSTEMS-1];
  wire           memory_wrequest     [0:NUM_SYSTEMS-1];

  // Monitors
  reg            done_flag           [0:NUM_SYSTEMS-1];
  reg     [31:0] counter_last_written[0:NUM_SYSTEMS-1];
  integer        store_count         [0:NUM_SYSTEMS-1];

  // Test variables
  integer        error_count;
  integer        cycle_count;
  integer        m;

  genvar g;
  generate
    for (g = 0; g < NUM_SYSTEMS; g = g + 1) begin : gen_system

      rvx_single_port_system #(

          .SIZE_IN_BYTES        (MEMORY_SIZE_IN_BYTES),
          .BOOT_IMAGE_PATH      ("program.mem"),
          .DATA_BUS_HAS_PRIORITY(g == DATA_PRIORITY ? 1 : 0)

      ) rvx_single_port_system_instance (

          // Global signals
          .clock  (clock),
          .reset_n(reset_n),

          // Testbench observation signals
          .fetch_address  (fetch_address[g]),
          .memory_address (memory_address[g]),
          .memory_wdata   (memory_wdata[g]),
          .memory_wrequest(memory_wrequest[g])

      );

    end
  endgenerate

  // Clock generation
  localparam CLOCK_PERIOD = 20;
  initial clock = 1'b0;
  always #(CLOCK_PERIOD / 2) clock <= !clock;

  // Watch the stores issued by each system
  always @(posedge clock) begin
    for (m = 0; m < NUM_SYSTEMS; m = m + 1) begin
      if (!reset_n) begin
        done_flag[m]            <= 1'b0;
        counter_last_written[m] <= 32'h00000000;
        store_count[m]          <= 0;
      end
      else if (memory_wrequest[m]) begin
        store_count[m] <= store_count[m] + 1;
        if (memory_address[m] == COUNTER_ADDRESS) counter_last_written[m] <= memory_wdata[m];
        if (memory_address[m] == DONE_FLAG_ADDRESS) done_flag[m] <= 1'b1;
      end
    end
  end

  task reset_all_systems;
    begin
      reset_n = 1'b0;
      #(CLOCK_PERIOD * 4);
      @(negedge clock);
      reset_n = 1'b1;
    end
  endtask

  task display_system_state;
    input index;
    begin
      $display("Fetch address: 0x%08h", fetch_address[index]);
      $display("Stores observed: %0d", store_count[index]);
      $display("Counter value: 0x%08h", counter_last_written[index]);
      $display("");
    end
  endtask

  initial begin

    error_count = 0;
    cycle_count = 0;

    reset_all_systems();

    $display("");
    $display("Running the program on all systems...");
    $display("--------------------------------------");
    $display("");

    while (cycle_count < TIMEOUT_IN_CYCLES &&
           !(done_flag[DATA_PRIORITY] && done_flag[INSTRUCTION_PRIORITY])) begin
      @(posedge clock);
      cycle_count = cycle_count + 1;
    end
    @(posedge clock);
    @(posedge clock);

    $display("Ran for %0d clock cycles.", cycle_count);

    $display("");
    $display("Checking single-port system with data bus priority...");
    $display("-----------------------------------------------------");
    $display("");

    display_system_state(DATA_PRIORITY);
    `RVX_ASSERT(done_flag[DATA_PRIORITY] === 1'b1, "Core hung with data bus priority.")
    `RVX_ASSERT(counter_last_written[DATA_PRIORITY] === COUNTER_FINAL_VALUE, "Wrong counter value (data priority).")
    `RVX_ASSERT(store_count[DATA_PRIORITY] === EXPECTED_STORES, "Wrong number of stores (data priority).")

    $display("");
    $display("Checking single-port system with instruction bus priority...");
    $display("------------------------------------------------------------");
    $display("");

    display_system_state(INSTRUCTION_PRIORITY);
    `RVX_ASSERT(done_flag[INSTRUCTION_PRIORITY] === 1'b1, "Core hung with instruction bus priority.")
    `RVX_ASSERT(counter_last_written[INSTRUCTION_PRIORITY] === COUNTER_FINAL_VALUE,
                "Wrong counter value (instruction priority).")
    `RVX_ASSERT(store_count[INSTRUCTION_PRIORITY] === EXPECTED_STORES, "Wrong number of stores (instruction priority).")

    $display("");
    $display("Testbench result:");
    $display("-----------------");
    $display("");
    if (error_count === 0) $display("Passed RTL testbench for RVX with a single-port memory.");
    else $display("[ERROR] RVX failed one or more single-port memory tests. Please investigate.");
    $display("");

    $finish();

  end

endmodule
