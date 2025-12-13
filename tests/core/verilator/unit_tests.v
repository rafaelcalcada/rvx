// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module unit_tests #(

    // Memory size in bytes
    parameter MEMORY_SIZE_IN_BYTES = 2097152,
    parameter BOOT_ADDRESS         = 32'h00000000

) (
    input clock,
    input reset
);

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

  // Memory-mapped timer (unused)
  wire [63:0] memory_mapped_timer;
  assign memory_mapped_timer = 64'b0;

  // Interrupt signals

  wire [15:0] irq_fast;
  wire        irq_external;
  wire        irq_timer;
  wire        irq_software;

  assign irq_fast     = 16'd0;
  assign irq_external = 1'd0;
  assign irq_timer    = 1'd0;
  assign irq_software = 1'd0;

  rvx_core #(
      .BOOT_ADDRESS(BOOT_ADDRESS)
  ) rvx_core_instance (

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
      .irq_fast    (irq_fast),
      .irq_external(irq_external),
      .irq_software(irq_software),
      .irq_timer   (irq_timer),

      // Memory-mapped timer
      .memory_mapped_timer(memory_mapped_timer)
  );

  rvx_tightly_coupled_memory #(

      .MEMORY_SIZE_IN_BYTES(MEMORY_SIZE_IN_BYTES)

  ) rvx_tightly_coupled_memory_instance (

      // Global signals
      .clock  (clock),
      .reset_n(!reset),

      // Port 0 (read/write) - Data bus
      .port0_address  (dbus_address),
      .port0_rdata    (dbus_rdata),
      .port0_rrequest (dbus_rrequest),
      .port0_rresponse(dbus_rresponse),
      .port0_wdata    (dbus_wdata),
      .port0_wstrobe  (dbus_wstrobe),
      .port0_wrequest (dbus_wrequest),
      .port0_wresponse(dbus_wresponse),

      // Port 1 (read-only) - Instruction bus
      .port1_address  (ibus_address),
      .port1_rdata    (ibus_rdata),
      .port1_rrequest (ibus_rrequest),
      .port1_rresponse(ibus_rresponse)
  );

endmodule
