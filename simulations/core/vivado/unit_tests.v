// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RVXtors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module unit_tests ();

  reg         clock;
  reg         reset;

  reg         read_response_test;
  reg         write_response_test;

  // Instruction bus
  wire [31:0] ibus_address;
  wire [31:0] ibus_rdata;
  wire        ibus_rrequest;
  wire        ibus_rresponse;

  // Data bus
  wire [31:0] dbus_address;
  wire [31:0] dbus_rdata;
  wire        dbus_rrequest;
  wire        dbus_rresponse;
  wire [31:0] dbus_wdata;
  wire [ 3:0] dbus_wstrobe;
  wire        dbus_wrequest;
  wire        dbus_wresponse;

  rvx_core #(

      .ENABLE_ZMMUL(1)

  ) dut0 (

      // Global signals
      .clock  (clock),
      .reset_n(!reset),

      // Instruction bus
      .ibus_rdata    (ibus_rdata),
      .ibus_rresponse(ibus_rresponse),
      .ibus_address  (ibus_address),
      .ibus_rrequest (ibus_rrequest),

      // Data bus
      .dbus_rdata    (dbus_rdata),
      .dbus_rresponse(dbus_rresponse),
      .dbus_wresponse(dbus_wresponse),
      .dbus_address  (dbus_address),
      .dbus_rrequest (dbus_rrequest),
      .dbus_wdata    (dbus_wdata),
      .dbus_wstrobe  (dbus_wstrobe),
      .dbus_wrequest (dbus_wrequest),

      // Interrupt signals
      .irq_external(1'b0),
      .irq_timer   (1'b0),
      .irq_software(1'b0),

      // Memory-mapped timer
      .memory_mapped_timer(64'b0)

  );

  rvx_tightly_coupled_memory #(

      .MEMORY_SIZE_IN_BYTES(2097152)

  ) dut1 (

      // Global signals

      .clock  (clock),
      .reset_n(!reset),

      // Port 0 (read-only) - Instruction bus
      .port0_address  (ibus_address),
      .port0_rdata    (ibus_rdata),
      .port0_rrequest (ibus_rrequest),
      .port0_rresponse(ibus_rresponse),

      // Port 1 (read/write) - Data bus
      .port1_address  (dbus_address),
      .port1_rdata    (dbus_rdata),
      .port1_rrequest (dbus_rrequest),
      .port1_rresponse(dbus_rresponse),
      .port1_wdata    (dbus_wdata),
      .port1_wstrobe  (dbus_wstrobe),
      .port1_wrequest (dbus_wrequest),
      .port1_wresponse(dbus_wresponse)

  );

  always #10 clock = !clock;

  reg [167:0] unit_test_programs_array[0:57] = {"add-01.hex",
                                                "addi-01.hex",
                                                "and-01.hex",
                                                "andi-01.hex",
                                                "auipc-01.hex",
                                                "beq-01.hex",
                                                "bge-01.hex",
                                                "bgeu-01.hex",
                                                "blt-01.hex",
                                                "bltu-01.hex",
                                                "bne-01.hex",
                                                "ebreak.hex",
                                                "ecall.hex",
                                                "fence-01.hex",
                                                "jal-01.hex",
                                                "jalr-01.hex",
                                                "lb-align-01.hex",
                                                "lbu-align-01.hex",
                                                "lh-align-01.hex",
                                                "lhu-align-01.hex",
                                                "lui-01.hex",
                                                "lw-align-01.hex",
                                                "misalign-beq-01.hex",
                                                "misalign-bge-01.hex",
                                                "misalign-bgeu-01.hex",
                                                "misalign-blt-01.hex",
                                                "misalign-bltu-01.hex",
                                                "misalign-bne-01.hex",
                                                "misalign-jal-01.hex",
                                                "misalign-lh-01.hex",
                                                "misalign-lhu-01.hex",
                                                "misalign-lw-01.hex",
                                                "misalign-sh-01.hex",
                                                "misalign-sw-01.hex",
                                                "misalign1-jalr-01.hex",
                                                "misalign2-jalr-01.hex",
                                                "mul-01.hex",
                                                "mulh-01.hex",
                                                "mulhsu-01.hex",
                                                "mulhu-01.hex",
                                                "or-01.hex",
                                                "ori-01.hex",
                                                "sb-align-01.hex",
                                                "sh-align-01.hex",
                                                "sll-01.hex",
                                                "slli-01.hex",
                                                "slt-01.hex",
                                                "slti-01.hex",
                                                "sltiu-01.hex",
                                                "sltu-01.hex",
                                                "sra-01.hex",
                                                "srai-01.hex",
                                                "srl-01.hex",
                                                "srli-01.hex",
                                                "sub-01.hex",
                                                "sw-align-01.hex",
                                                "xor-01.hex",
                                                "xori-01.hex"};

  reg [519:0] golden_reference_array[0:57] = {"add-01.reference.hex",
                                              "addi-01.reference.hex",
                                              "and-01.reference.hex",
                                              "andi-01.reference.hex",
                                              "auipc-01.reference.hex",
                                              "beq-01.reference.hex",
                                              "bge-01.reference.hex",
                                              "bgeu-01.reference.hex",
                                              "blt-01.reference.hex",
                                              "bltu-01.reference.hex",
                                              "bne-01.reference.hex",
                                              "ebreak.reference.hex",
                                              "ecall.reference.hex",
                                              "fence-01.reference.hex",
                                              "jal-01.reference.hex",
                                              "jalr-01.reference.hex",
                                              "lb-align-01.reference.hex",
                                              "lbu-align-01.reference.hex",
                                              "lh-align-01.reference.hex",
                                              "lhu-align-01.reference.hex",
                                              "lui-01.reference.hex",
                                              "lw-align-01.reference.hex",
                                              "misalign-beq-01.reference.hex",
                                              "misalign-bge-01.reference.hex",
                                              "misalign-bgeu-01.reference.hex",
                                              "misalign-blt-01.reference.hex",
                                              "misalign-bltu-01.reference.hex",
                                              "misalign-bne-01.reference.hex",
                                              "misalign-jal-01.reference.hex",
                                              "misalign-lh-01.reference.hex",
                                              "misalign-lhu-01.reference.hex",
                                              "misalign-lw-01.reference.hex",
                                              "misalign-sh-01.reference.hex",
                                              "misalign-sw-01.reference.hex",
                                              "misalign1-jalr-01.reference.hex",
                                              "misalign2-jalr-01.reference.hex",
                                              "mul-01.reference.hex",
                                              "mulh-01.reference.hex",
                                              "mulhsu-01.reference.hex",
                                              "mulhu-01.reference.hex",
                                              "or-01.reference.hex",
                                              "ori-01.reference.hex",
                                              "sb-align-01.reference.hex",
                                              "sh-align-01.reference.hex",
                                              "sll-01.reference.hex",
                                              "slli-01.reference.hex",
                                              "slt-01.reference.hex",
                                              "slti-01.reference.hex",
                                              "sltiu-01.reference.hex",
                                              "sltu-01.reference.hex",
                                              "sra-01.reference.hex",
                                              "srai-01.reference.hex",
                                              "srl-01.reference.hex",
                                              "srli-01.reference.hex",
                                              "sub-01.reference.hex",
                                              "sw-align-01.reference.hex",
                                              "xor-01.reference.hex",
                                              "xori-01.reference.hex"};

  // The tests below are expected to fail because
  // RVX does not support misaligned branch/jump instructions
  reg [167:0] expected_to_fail[0:7] = {"misalign-beq-01.hex",
                                       "misalign-bge-01.hex",
                                       "misalign-bgeu-01.hex",
                                       "misalign-blt-01.hex",
                                       "misalign-bltu-01.hex",
                                       "misalign-bne-01.hex",
                                       "misalign-jal-01.hex",
                                       "misalign2-jalr-01.hex"};

  integer i, j, k, m, n, t, u, z;
  integer        failing_tests_counter;
  integer        current_test_failed_flag;
  integer        expected_to_fail_flag;
  reg     [31:0] current_golden_reference [0:2047];

  always begin

    read_response_test  = 1'b1;
    write_response_test = 1'b1;
    #200;

    for (t = 0; t < 10000; t = t + 1) begin
      read_response_test  = $random();
      write_response_test = $random();
      #20;
    end

    read_response_test  = 1'b1;
    write_response_test = 1'b1;

  end

  initial begin

    i                        = 0;
    j                        = 0;
    k                        = 0;
    m                        = 0;
    n                        = 0;
    t                        = 0;
    z                        = 0;
    current_test_failed_flag = 0;
    expected_to_fail_flag    = 0;
    failing_tests_counter    = 0;
    clock                    = 1'b0;
    reset                    = 1'b0;

    $display("Running unit test programs from RISC-V Architectural Test Suite.");

    for (k = 0; k < 54; k = k + 1) begin

      // Reset
      reset = 1'b1;
      for (i = 0; i < 524287; i = i + 1) dut1.tcm[i] = 32'hdeadbeef;
      for (i = 0; i < 2048; i = i + 1) current_golden_reference[i] = 32'hdeadbeef;
      #40;
      reset = 1'b0;

      // Initialization
      $readmemh(unit_test_programs_array[k], dut1.tcm);
      $readmemh(golden_reference_array[k], current_golden_reference);

      $display("Running test: %s", unit_test_programs_array[k]);

      // Main loop: run test
      for (j = 0; j < 500000; j = j + 1) begin

        // After each clock cycle it tests whether the test program finished its execution
        // This event is signaled by writing 1 to the address 0x00001000
        #20;
        if (dbus_address == 32'h00001000 && dbus_wrequest == 1'b1 && dbus_wdata == 32'h00000001) begin

          // The beginning and end of signature are stored at
          // 0x00001ffc (tcm[2046]) and 0x00001ff8 (tcm[2047]).
          m                        = dut1.tcm[2047][24:2];  // m holds the address of the beginning of the signature
          n                        = dut1.tcm[2046][24:2];  // n holds the address of the end of the signature

          // Compare signature with golden reference
          z                        = 0;
          current_test_failed_flag = 0;
          for (m = dut1.tcm[2047][24:2]; m < n; m = m + 1) begin
            if (dut1.tcm[m] !== current_golden_reference[z]) begin
              // Is this test expected to fail?
              expected_to_fail_flag = 0;
              for (t = 0; t < 9; t = t + 1) begin
                if (unit_test_programs_array[k] == expected_to_fail[t]) begin
                  expected_to_fail_flag = 1;
                  t                     = 9;
                end
              end
              // In case it is not, print failure message
              if (expected_to_fail_flag == 0) begin
                $display("TEST FAILED: %s", unit_test_programs_array[k]);
                $display("Signature at line %d differs from golden reference.", z + 1);
                $display("Signature: %h. Golden reference: %h", dut1.tcm[m], current_golden_reference[z]);
                failing_tests_counter    = failing_tests_counter + 1;
                current_test_failed_flag = 1;
                $stop();
              end
            end
            z = z + 1;
          end

          // Skip loop in a successful run
          if (current_test_failed_flag == 0) j = 999999;

        end
      end

      // The program ran for 500000 cycles and did not finish (something is wrong)
      if (j == 500000) begin
        $info("TEST FAILED (probably hanging): %s", unit_test_programs_array[k]);
        $stop();
      end

    end

    if (failing_tests_counter == 0) begin
      $display("------------------------------------------------------------------------------------------");
      $display("RVX Core IP passed ALL unit tests from RISC-V Architectural Test Suite");
      $display("------------------------------------------------------------------------------------------");
    end
    else begin
      $display("FAILED on one or more unit tests.");
      $fatal();
    end

    $finish(0);

  end

endmodule
