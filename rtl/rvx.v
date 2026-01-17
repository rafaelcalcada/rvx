// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx #(

    parameter MEMORY_SIZE      = 8192,
    parameter MEMORY_INIT_FILE = "",
    parameter BOOT_ADDRESS     = 32'h00000000,
    parameter GPIO_WIDTH       = 1,
    parameter ENABLE_ZMMUL     = 0

) (

    input  wire                  clock,
    input  wire                  reset_n,
    input  wire                  uart_rx,
    output wire                  uart_tx,
    input  wire [GPIO_WIDTH-1:0] gpio_input,
    output wire [GPIO_WIDTH-1:0] gpio_output_enable,
    output wire [GPIO_WIDTH-1:0] gpio_output,
    output wire                  sclk,
    output wire                  mosi,
    input  wire                  miso,
    output wire                  cs

);

  // Instruction bus signals

  wire [31:0] ibus_address;
  wire [31:0] ibus_rdata;
  wire        ibus_rrequest;
  wire        ibus_rresponse;

  // RVX Interconnect configuration

  localparam NUM_PERIPHERALS = 5;

  localparam TCM_REGION_INDEX = 0;
  localparam UART_REGION_INDEX = 1;
  localparam TIMER_REGION_INDEX = 2;
  localparam GPIO_REGION_INDEX = 3;
  localparam SPI_REGION_INDEX = 4;

  localparam [31:0] TCM_BASE_ADDRESS = 32'h00000000;
  localparam [31:0] TCM_REGION_SIZE = MEMORY_SIZE;

  localparam [31:0] UART_BASE_ADDRESS = 32'h40000000;
  localparam [31:0] UART_REGION_SIZE = 16;

  localparam [31:0] TIMER_BASE_ADDRESS = 32'h40001000;
  localparam [31:0] TIMER_REGION_SIZE = 32;

  localparam [31:0] GPIO_BASE_ADDRESS = 32'h40002000;
  localparam [31:0] GPIO_REGION_SIZE = 32;

  localparam [31:0] SPI_BASE_ADDRESS = 32'h40003000;
  localparam [31:0] SPI_REGION_SIZE = 32;

  // Connections between the RVX Core and the Interconnect

  wire [                  31:0] controller_rw_address;
  wire [                  31:0] controller_read_data;
  wire                          controller_read_request;
  wire                          controller_read_response;
  wire [                  31:0] controller_write_data;
  wire [                   3:0] controller_write_strobe;
  wire                          controller_write_request;
  wire                          controller_write_response;

  // Connections between the Interconnect and Controlled Peripherals

  wire [                  31:0] peripheral_rw_address;
  wire [NUM_PERIPHERALS*32-1:0] peripheral_read_data;
  wire [   NUM_PERIPHERALS-1:0] peripheral_read_request;
  wire [   NUM_PERIPHERALS-1:0] peripheral_read_response;
  wire [                  31:0] peripheral_write_data;
  wire [                   3:0] peripheral_write_strobe;
  wire [   NUM_PERIPHERALS-1:0] peripheral_write_request;
  wire [   NUM_PERIPHERALS-1:0] peripheral_write_response;

  // Interrupt request signals

  wire [                  15:0] irq_fast;
  wire                          irq_external;
  wire                          irq_timer;
  wire                          irq_software;
  wire                          irq_uart;

  // Interrupts configuration

  assign irq_fast     = {15'b0, irq_uart};  // Only Fast IRQ 0 is used for UART
  assign irq_external = 1'b0;  // unused
  assign irq_software = 1'b0;  // unused

  // Memory-mapped timer
  wire [63:0] timer;

  rvx_core #(

      .BOOT_ADDRESS(BOOT_ADDRESS),
      .ENABLE_ZMMUL(ENABLE_ZMMUL)

  ) rvx_core_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Instruction bus
      .ibus_address  (ibus_address),
      .ibus_rdata    (ibus_rdata),
      .ibus_rrequest (ibus_rrequest),
      .ibus_rresponse(ibus_rresponse),

      // Data bus
      .dbus_address  (controller_rw_address),
      .dbus_rdata    (controller_read_data),
      .dbus_rrequest (controller_read_request),
      .dbus_rresponse(controller_read_response),
      .dbus_wdata    (controller_write_data),
      .dbus_wstrobe  (controller_write_strobe),
      .dbus_wrequest (controller_write_request),
      .dbus_wresponse(controller_write_response),

      // Interrupt requests
      .irq_fast    (irq_fast),
      .irq_external(irq_external),
      .irq_timer   (irq_timer),
      .irq_software(irq_software),

      // Memory-mapped timer
      .memory_mapped_timer(timer)

  );

  rvx_interconnect #(

      .NUM_PERIPHERALS(NUM_PERIPHERALS),
      .BASE_ADDRESSES ({SPI_BASE_ADDRESS, GPIO_BASE_ADDRESS, TIMER_BASE_ADDRESS, UART_BASE_ADDRESS, TCM_BASE_ADDRESS}),
      .REGION_SIZES   ({SPI_REGION_SIZE, GPIO_REGION_SIZE, TIMER_REGION_SIZE, UART_REGION_SIZE, TCM_REGION_SIZE})

  ) rvx_interconnect_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Connections with the controller device (RVX Core)
      .controller_rw_address    (controller_rw_address),
      .controller_read_data     (controller_read_data),
      .controller_read_request  (controller_read_request),
      .controller_read_response (controller_read_response),
      .controller_write_data    (controller_write_data),
      .controller_write_strobe  (controller_write_strobe),
      .controller_write_request (controller_write_request),
      .controller_write_response(controller_write_response),

      // Connections with the controlled peripheral devices
      .peripheral_rw_address    (peripheral_rw_address),
      .peripheral_read_data     (peripheral_read_data),
      .peripheral_read_request  (peripheral_read_request),
      .peripheral_read_response (peripheral_read_response),
      .peripheral_write_data    (peripheral_write_data),
      .peripheral_write_strobe  (peripheral_write_strobe),
      .peripheral_write_request (peripheral_write_request),
      .peripheral_write_response(peripheral_write_response)

  );

  rvx_tightly_coupled_memory #(

      .MEMORY_SIZE     (MEMORY_SIZE),
      .MEMORY_INIT_FILE(MEMORY_INIT_FILE)

  ) rvx_tightly_coupled_memory_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Port 0 (read-only) - Instruction bus
      .port0_address  (ibus_address),
      .port0_rdata    (ibus_rdata),
      .port0_rrequest (ibus_rrequest),
      .port0_rresponse(ibus_rresponse),

      // Port 1 (read/write) - Data bus
      .port1_address  (peripheral_rw_address),
      .port1_rdata    (peripheral_read_data[32*TCM_REGION_INDEX+:32]),
      .port1_rrequest (peripheral_read_request[TCM_REGION_INDEX]),
      .port1_rresponse(peripheral_read_response[TCM_REGION_INDEX]),
      .port1_wdata    (peripheral_write_data),
      .port1_wstrobe  (peripheral_write_strobe),
      .port1_wrequest (peripheral_write_request[TCM_REGION_INDEX]),
      .port1_wresponse(peripheral_write_response[TCM_REGION_INDEX])
  );

  rvx_uart rvx_uart_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Register read/write
      .rw_address    (peripheral_rw_address[4:0]),
      .read_data     (peripheral_read_data[32*UART_REGION_INDEX+:32]),
      .read_request  (peripheral_read_request[UART_REGION_INDEX]),
      .read_response (peripheral_read_response[UART_REGION_INDEX]),
      .write_data    (peripheral_write_data[31:0]),
      .write_strobe  (peripheral_write_strobe),
      .write_request (peripheral_write_request[UART_REGION_INDEX]),
      .write_response(peripheral_write_response[UART_REGION_INDEX]),

      // UART RX/TX signals
      .uart_tx(uart_tx),
      .uart_rx(uart_rx),

      // UART interrupt request (connected to Fast IRQ 0)
      .uart_irq(irq_uart)

  );

  rvx_timer rvx_timer_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Register read/write
      .rw_address    (peripheral_rw_address[4:0]),
      .read_data     (peripheral_read_data[32*TIMER_REGION_INDEX+:32]),
      .read_request  (peripheral_read_request[TIMER_REGION_INDEX]),
      .read_response (peripheral_read_response[TIMER_REGION_INDEX]),
      .write_data    (peripheral_write_data),
      .write_strobe  (peripheral_write_strobe),
      .write_request (peripheral_write_request[TIMER_REGION_INDEX]),
      .write_response(peripheral_write_response[TIMER_REGION_INDEX]),

      // Timer interrupt request
      .timer_irq(irq_timer),

      // Timer output
      .timer(timer)

  );

  rvx_gpio #(

      .GPIO_WIDTH(GPIO_WIDTH)

  ) rvx_gpio_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Register read/write
      .rw_address    (peripheral_rw_address[4:0]),
      .read_data     (peripheral_read_data[32*GPIO_REGION_INDEX+:32]),
      .read_request  (peripheral_read_request[GPIO_REGION_INDEX]),
      .read_response (peripheral_read_response[GPIO_REGION_INDEX]),
      .write_data    (peripheral_write_data),
      .write_strobe  (peripheral_write_strobe),
      .write_request (peripheral_write_request[GPIO_REGION_INDEX]),
      .write_response(peripheral_write_response[GPIO_REGION_INDEX]),

      // GPIO signals
      .gpio_input        (gpio_input),
      .gpio_output_enable(gpio_output_enable),
      .gpio_output       (gpio_output)

  );

  rvx_spi_manager rvx_spi_manager_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Register read/write
      .rw_address    (peripheral_rw_address[4:0]),
      .read_data     (peripheral_read_data[32*SPI_REGION_INDEX+:32]),
      .read_request  (peripheral_read_request[SPI_REGION_INDEX]),
      .read_response (peripheral_read_response[SPI_REGION_INDEX]),
      .write_data    (peripheral_write_data),
      .write_strobe  (peripheral_write_strobe),
      .write_request (peripheral_write_request[SPI_REGION_INDEX]),
      .write_response(peripheral_write_response[SPI_REGION_INDEX]),

      // SPI signals
      .sclk(sclk),
      .mosi(mosi),
      .miso(miso),
      .cs  (cs)

  );

endmodule
