// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_single_port_system #(

    // Size of the memory in bytes
    parameter SIZE_IN_BYTES = 8192,

    // Path to the file with program and data
    parameter BOOT_IMAGE_PATH = "",

    // Arbitration policy, see rvx_single_port_arbiter
    parameter DATA_BUS_HAS_PRIORITY = 1

) (

    // Global signals
    input wire clock,
    input wire reset_n,

    // Testbench observation signals
    output wire [31:0] fetch_address,
    output wire [31:0] memory_address,
    output wire [31:0] memory_wdata,
    output wire        memory_wrequest

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

  // Memory port
  wire [31:0] memory_rdata;
  wire        memory_rrequest;
  wire        memory_rresponse;
  wire [ 3:0] memory_wstrobe;
  wire        memory_wresponse;

  rvx_core #(

      .ENABLE_ZMMUL(0)

  ) rvx_core_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

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
      .irq_software(1'b0),
      .irq_timer   (1'b0),

      // Memory-mapped timer
      .memory_mapped_timer(64'h0000000000000000)

  );

  rvx_single_port_arbiter #(

      .DATA_BUS_HAS_PRIORITY(DATA_BUS_HAS_PRIORITY)

  ) rvx_single_port_arbiter_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Instruction bus
      .ibus_address  (ibus_address),
      .ibus_rdata    (ibus_rdata),
      .ibus_rrequest (ibus_rrequest),
      .ibus_rresponse(ibus_rresponse),

      // Data bus
      .dbus_address  (dbus_address),
      .dbus_rdata    (dbus_rdata),
      .dbus_rrequest (dbus_rrequest),
      .dbus_rresponse(dbus_rresponse),
      .dbus_wdata    (dbus_wdata),
      .dbus_wstrobe  (dbus_wstrobe),
      .dbus_wrequest (dbus_wrequest),
      .dbus_wresponse(dbus_wresponse),

      // Memory port
      .memory_address  (memory_address),
      .memory_rdata    (memory_rdata),
      .memory_rrequest (memory_rrequest),
      .memory_rresponse(memory_rresponse),
      .memory_wdata    (memory_wdata),
      .memory_wstrobe  (memory_wstrobe),
      .memory_wrequest (memory_wrequest),
      .memory_wresponse(memory_wresponse)

  );

  rvx_memory_sp #(

      .SIZE_IN_BYTES (SIZE_IN_BYTES),
      .INIT_FILE_PATH(BOOT_IMAGE_PATH),
      .BASE_ADDRESS  (32'h00000000)

  ) rvx_memory_sp_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Port 0 (read/write)
      .port0_rw_address    (memory_address),
      .port0_read_data     (memory_rdata),
      .port0_read_request  (memory_rrequest),
      .port0_read_response (memory_rresponse),
      .port0_write_data    (memory_wdata),
      .port0_write_strobe  (memory_wstrobe),
      .port0_write_request (memory_wrequest),
      .port0_write_response(memory_wresponse)

  );

  // Testbench observation signals
  assign fetch_address = ibus_address;

endmodule
