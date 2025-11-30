// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module unit_tests #(

    // Memory size in bytes
    parameter MEMORY_SIZE   = 2097152     ,
    parameter BOOT_ADDRESS  = 32'h00000000

  )(
    input   clock ,
    input   reset ,
    input   halt
  );

  wire   [31:0]  rw_address;
  wire   [31:0]  read_data;
  wire           read_request;
  wire           read_response;
  wire   [31:0]  write_data;
  wire   [3:0 ]  write_strobe;
  wire           write_request;
  wire           write_response;

  // Real-time clock (unused)

  wire  [63:0]  real_time_clock;
  assign        real_time_clock = 64'b0;

  // Interrupt signals

  wire  [15:0]  irq_fast;
  wire          irq_external;
  wire          irq_timer;
  wire          irq_software;

  assign        irq_fast      = 16'd0;
  assign        irq_external  = 1'd0;
  assign        irq_timer     = 1'd0;
  assign        irq_software  = 1'd0;

  wire  [15:0]  irq_fast_response;
  wire          irq_external_response;
  wire          irq_timer_response;
  wire          irq_software_response;

  rvx_core #(
    .BOOT_ADDRESS(BOOT_ADDRESS)
  ) rvx_core_instance (

    // Global signals

    .clock                  (clock                ),
    .reset                  (reset                ),
    .halt                   (halt                 ),

    // IO interface

    .rw_address             (rw_address           ),
    .read_data              (read_data            ),
    .read_request           (read_request         ),
    .read_response          (read_response        ),
    .write_data             (write_data           ),
    .write_strobe           (write_strobe         ),
    .write_request          (write_request        ),
    .write_response         (write_response       ),

    // Interrupt request signals

    .irq_fast               (irq_fast             ),
    .irq_external           (irq_external         ),
    .irq_timer              (irq_timer            ),
    .irq_software           (irq_software         ),

    // Interrupt response signals
    .irq_fast_response      (irq_fast_response    ),
    .irq_external_response  (irq_external_response),
    .irq_timer_response     (irq_timer_response   ),
    .irq_software_response  (irq_software_response),

    // Real Time Clock (hardwire to zero if unused)

    .real_time_clock        (real_time_clock      )
  );

  rvx_ram #(
    .MEMORY_SIZE(MEMORY_SIZE)
  ) rvx_ram_instance (

    // Global signals

    .clock                  (clock          ),
    .reset                  (reset          ),

    // IO interface

    .rw_address             (rw_address     ),
    .read_data              (read_data      ),
    .read_request           (read_request   ),
    .read_response          (read_response  ),
    .write_data             (write_data     ),
    .write_strobe           (write_strobe   ),
    .write_request          (write_request  ),
    .write_response         (write_response )
  );

  // Avoid warnings about intentionally unused pins/wires
  wire unused_ok =
    &{1'b0,
    irq_fast_response,
    irq_external_response,
    irq_timer_response,
    irq_software_response,
    1'b0};

endmodule
