// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

`include "rvx_constants.vh"
`include "rvx_test_macros.vh"

module rvx_plic_tb ();

  // Global signals
  reg            clock;
  reg            reset_n;

  // Register read/write
  reg     [ 6:0] rw_address;
  wire    [31:0] read_data;
  reg            read_request;
  // verilator lint_off UNUSEDSIGNAL
  wire           read_response;
  // verilator lint_on UNUSEDSIGNAL
  reg     [15:0] write_data;
  reg            write_request;
  reg     [ 3:0] write_strobe;

  // Interrupt request lines
  reg     [15:0] plic_sources;
  wire           plic_irq;

  // Test variables
  integer        error_count;

  // verilator lint_off PINCONNECTEMPTY
  rvx_plic rvx_plic_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // IO interface
      .rw_address    (rw_address),
      .read_data     (read_data),
      .read_request  (read_request),
      .read_response (read_response),
      .write_data    (write_data),
      .write_strobe  (write_strobe),
      .write_request (write_request),
      .write_response(),

      // Interrupt request lines
      .plic_sources(plic_sources),

      // External interrupt request
      .plic_irq(plic_irq)

  );
  // verilator lint_on PINCONNECTEMPTY

  // Clock generation
  localparam CLOCK_PERIOD = 20;
  initial clock = 1'b0;
  always #(CLOCK_PERIOD / 2) clock <= !clock;

  function [8*10-1:0] plic_reg_name;
    input [6:0] address;
    begin
      case (address)
        `RVX_PLIC_PRIORITY1_REG_ADDR:  plic_reg_name = "PRIORITY1";
        `RVX_PLIC_PRIORITY2_REG_ADDR:  plic_reg_name = "PRIORITY2";
        `RVX_PLIC_PRIORITY3_REG_ADDR:  plic_reg_name = "PRIORITY3";
        `RVX_PLIC_PRIORITY4_REG_ADDR:  plic_reg_name = "PRIORITY4";
        `RVX_PLIC_PRIORITY5_REG_ADDR:  plic_reg_name = "PRIORITY5";
        `RVX_PLIC_PRIORITY6_REG_ADDR:  plic_reg_name = "PRIORITY6";
        `RVX_PLIC_PRIORITY7_REG_ADDR:  plic_reg_name = "PRIORITY7";
        `RVX_PLIC_PRIORITY8_REG_ADDR:  plic_reg_name = "PRIORITY8";
        `RVX_PLIC_PRIORITY9_REG_ADDR:  plic_reg_name = "PRIORITY9";
        `RVX_PLIC_PRIORITY10_REG_ADDR: plic_reg_name = "PRIORITY10";
        `RVX_PLIC_PRIORITY11_REG_ADDR: plic_reg_name = "PRIORITY11";
        `RVX_PLIC_PRIORITY12_REG_ADDR: plic_reg_name = "PRIORITY12";
        `RVX_PLIC_PRIORITY13_REG_ADDR: plic_reg_name = "PRIORITY13";
        `RVX_PLIC_PRIORITY14_REG_ADDR: plic_reg_name = "PRIORITY14";
        `RVX_PLIC_PRIORITY15_REG_ADDR: plic_reg_name = "PRIORITY15";
        `RVX_PLIC_PRIORITY16_REG_ADDR: plic_reg_name = "PRIORITY16";
        `RVX_PLIC_ENABLE_REG_ADDR:     plic_reg_name = "ENABLE";
        `RVX_PLIC_PENDING_REG_ADDR:    plic_reg_name = "PENDING";
        `RVX_PLIC_CLAIM_REG_ADDR:      plic_reg_name = "CLAIM";
        default:                       plic_reg_name = "UNKNOWN";
      endcase
    end
  endfunction

  task reset_all_devices;
    begin
      reset_n       = 1'b0;
      rw_address    = 7'h00;
      read_request  = 1'b0;
      write_request = 1'b0;
      write_data    = 16'b0;
      write_strobe  = 4'b0000;
      plic_sources  = 16'h0000;
      #(CLOCK_PERIOD * 2);
      reset_n = 1'b1;
      #(CLOCK_PERIOD * 2);
    end
  endtask

  task read_plic_register;
    input [6:0] address;
    begin
      rw_address   = address;
      read_request = 1'b1;
      #(CLOCK_PERIOD);
      read_request = 1'b0;
      rw_address   = 7'h00;
      $display("");
      $display("Reading PLIC register: %s", plic_reg_name(address));
      $display("Read value: 0x%08h", read_data);
    end
  endtask

  task write_plic_register;
    input [6:0] address;
    input [31:0] data;
    begin
      $display("");
      $display("Writing PLIC register: %s", plic_reg_name(address));
      $display("Write value: 0x%08h", data);
      rw_address    = address;
      write_data    = data[15:0];
      write_request = 1'b1;
      write_strobe  = 4'b1111;
      #(CLOCK_PERIOD);
      write_request = 1'b0;
      rw_address    = 7'h00;
      write_data    = 16'b0;
      write_strobe  = 4'b0000;
    end
  endtask

  integer i;

  initial begin

    error_count = 0;

    reset_all_devices();

    $display("");
    $display("Checking PLIC module state after reset...");
    $display("------------------------------------------");

    for (i = 1; i <= 16; i = i + 1) begin
      read_plic_register((i[6:0] - 1'b1) * 4);
      `RVX_ASSERT(read_data == 32'h00000000, "PRIORITY register not zero after reset.")
    end
    read_plic_register(`RVX_PLIC_ENABLE_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000000, "ENABLE register not zero after reset.")
    read_plic_register(`RVX_PLIC_PENDING_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000000, "PENDING register not zero after reset.")
    read_plic_register(`RVX_PLIC_CLAIM_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000000, "CLAIM register not zero after reset.")
    `RVX_ASSERT(plic_irq == 1'b0, "plic_irq not zero after reset.")

    $display("");
    $display("Testing PRIORITY register writes/reads...");
    $display("------------------------------------------");

    write_plic_register(`RVX_PLIC_PRIORITY1_REG_ADDR, 32'h00000005);
    read_plic_register(`RVX_PLIC_PRIORITY1_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000005, "PRIORITY1 register did not update correctly.")

    write_plic_register(`RVX_PLIC_PRIORITY16_REG_ADDR, 32'h0000000F);
    read_plic_register(`RVX_PLIC_PRIORITY16_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h0000000F, "PRIORITY16 register did not update correctly.")

    $display("");
    $display("Testing that only the lower 4 bits of PRIORITY registers are stored...");
    $display("------------------------------------------------------------------------");

    write_plic_register(`RVX_PLIC_PRIORITY2_REG_ADDR, 32'hFFFFFFFF);
    read_plic_register(`RVX_PLIC_PRIORITY2_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h0000000F, "PRIORITY2 register did not truncate write data to 4 bits.")

    $display("");
    $display("Testing ENABLE register writes/reads...");
    $display("----------------------------------------");

    write_plic_register(`RVX_PLIC_ENABLE_REG_ADDR, 32'hFFFF1234);
    read_plic_register(`RVX_PLIC_ENABLE_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00001234, "ENABLE register did not truncate write data to 16 bits.")

    $display("");
    $display("Testing PENDING register reflects plic_sources masked by ENABLE...");
    $display("-------------------------------------------------------------------");

    plic_sources = 16'hFFFF;
    #(CLOCK_PERIOD);
    read_plic_register(`RVX_PLIC_PENDING_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00001234, "PENDING register did not map source lines to IDs 1-16.")

    write_plic_register(`RVX_PLIC_ENABLE_REG_ADDR, 32'h0000FFFF);
    read_plic_register(`RVX_PLIC_PENDING_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h0000FFFF, "PENDING register did not set pending bits 0-15 for source IDs 1-16.")

    plic_sources = 16'h0000;
    #(CLOCK_PERIOD);
    read_plic_register(`RVX_PLIC_PENDING_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000000, "PENDING register did not clear when plic_sources deasserted.")

    $display("");
    $display("Testing CLAIM register arbitration (highest priority wins)...");
    $display("-----------------------------------------------------------------");

    reset_all_devices();

    write_plic_register(`RVX_PLIC_PRIORITY1_REG_ADDR, 32'h00000005);
    write_plic_register(`RVX_PLIC_PRIORITY2_REG_ADDR, 32'h0000000A);
    write_plic_register(`RVX_PLIC_PRIORITY3_REG_ADDR, 32'h00000003);
    write_plic_register(`RVX_PLIC_ENABLE_REG_ADDR, 32'h00000007);
    plic_sources = 16'h0007;
    #(CLOCK_PERIOD);
    read_plic_register(`RVX_PLIC_CLAIM_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000002, "CLAIM register did not return the winning source ID.")

    $display("");
    $display("Testing CLAIM register tie-break (lowest index wins on equal priority)...");
    $display("-----------------------------------------------------------------------------");

    reset_all_devices();

    write_plic_register(`RVX_PLIC_PRIORITY1_REG_ADDR, 32'h00000008);
    write_plic_register(`RVX_PLIC_PRIORITY4_REG_ADDR, 32'h00000008);
    write_plic_register(`RVX_PLIC_ENABLE_REG_ADDR, 32'h00000009);
    plic_sources = 16'h0009;
    #(CLOCK_PERIOD);
    read_plic_register(`RVX_PLIC_CLAIM_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000001, "CLAIM register did not break ties in favor of the lowest source ID.")

    $display("");
    $display("Testing that a priority of 0 disables a source from winning arbitration...");
    $display("------------------------------------------------------------------------------");

    reset_all_devices();

    write_plic_register(`RVX_PLIC_PRIORITY1_REG_ADDR, 32'h00000000);
    write_plic_register(`RVX_PLIC_PRIORITY2_REG_ADDR, 32'h00000002);
    write_plic_register(`RVX_PLIC_ENABLE_REG_ADDR, 32'h00000003);
    plic_sources = 16'h0003;
    #(CLOCK_PERIOD);
    read_plic_register(`RVX_PLIC_CLAIM_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000002, "CLAIM register selected a source with priority 0.")

    $display("");
    $display("Testing that all-zero priorities never assert any_pending, even if enabled and pending...");
    $display("------------------------------------------------------------------------------------------");

    reset_all_devices();

    write_plic_register(`RVX_PLIC_ENABLE_REG_ADDR, 32'h0000FFFF);
    plic_sources = 16'hFFFF;
    #(CLOCK_PERIOD);
    read_plic_register(`RVX_PLIC_CLAIM_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000000, "CLAIM register asserted any_pending with all priorities set to 0.")

    $display("");
    $display("Testing that disabling a source removes it from PENDING and arbitration...");
    $display("------------------------------------------------------------------------------");

    reset_all_devices();

    write_plic_register(`RVX_PLIC_PRIORITY1_REG_ADDR, 32'h00000005);
    write_plic_register(`RVX_PLIC_PRIORITY2_REG_ADDR, 32'h0000000A);
    write_plic_register(`RVX_PLIC_ENABLE_REG_ADDR, 32'h00000003);
    plic_sources = 16'h0003;
    #(CLOCK_PERIOD);
    read_plic_register(`RVX_PLIC_CLAIM_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000002, "CLAIM register did not select source ID 2 before source ID 2 was disabled.")

    write_plic_register(`RVX_PLIC_ENABLE_REG_ADDR, 32'h00000001);
    read_plic_register(`RVX_PLIC_PENDING_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000001, "PENDING register did not retain source ID 1 only.")
    read_plic_register(`RVX_PLIC_CLAIM_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000001, "CLAIM register did not fall back to source ID 1.")

    $display("");
    $display("Testing source ID 16 fits in the claim register...");
    $display("--------------------------------------------------");

    reset_all_devices();
    write_plic_register(`RVX_PLIC_PRIORITY16_REG_ADDR, 32'h00000001);
    write_plic_register(`RVX_PLIC_ENABLE_REG_ADDR, 32'h00008000);
    plic_sources = 16'h00008000;
    #(CLOCK_PERIOD);
    read_plic_register(`RVX_PLIC_CLAIM_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00000010, "CLAIM register did not return source ID 16.")
    read_plic_register(`RVX_PLIC_PENDING_REG_ADDR);
    `RVX_ASSERT(read_data == 32'h00008000, "PENDING register did not set source ID 16 in bit 15.")

    $display("");
    $display("Testing plic_irq follows arbitration result...");
    $display("----------------------------------------------------");

    reset_all_devices();
    `RVX_ASSERT(plic_irq == 1'b0, "plic_irq asserted with no pending interrupts.")

    write_plic_register(`RVX_PLIC_PRIORITY1_REG_ADDR, 32'h00000001);
    write_plic_register(`RVX_PLIC_ENABLE_REG_ADDR, 32'h00000001);
    plic_sources = 16'h0001;
    #(CLOCK_PERIOD);
    `RVX_ASSERT(plic_irq == 1'b1, "plic_irq not asserted while an enabled source is pending.")

    plic_sources = 16'h0000;
    #(CLOCK_PERIOD);
    `RVX_ASSERT(plic_irq == 1'b0, "plic_irq not deasserted once no source is pending.")

    $display("");
    $display("Testbench result:");
    $display("-----------------");
    $display("");
    if (error_count === 0) $display("Passed RTL testbench for the PLIC module of RVX.");
    else $display("[ERROR] PLIC module failed one or more unit tests. Please investigate.");
    $display("");

    $finish();

  end

endmodule
