// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

module rvx #(

    // Frequency of 'clock' signal
    parameter CLOCK_FREQUENCY     = 50000000,
    // Desired baud rate for UART unit
    parameter UART_BAUD_RATE      = 9600,
    // Memory size in bytes - must be a power of 2
    parameter MEMORY_SIZE         = 8192,
    // Text file with program and data (one hex value per line)
    parameter MEMORY_INIT_FILE    = "",
    // Address of the first instruction to fetch from memory
    parameter BOOT_ADDRESS        = 32'h00000000,
    // Number of available I/O ports
    parameter GPIO_WIDTH          = 1,
    // Number of CS (Chip Select) pins for the SPI controller
    parameter SPI_NUM_CHIP_SELECT = 1

) (

    input  wire                           clock,
    input  wire                           reset,
    input  wire                           halt,
    input  wire                           uart_rx,
    output wire                           uart_tx,
    input  wire [         GPIO_WIDTH-1:0] gpio_input,
    output wire [         GPIO_WIDTH-1:0] gpio_oe,
    output wire [         GPIO_WIDTH-1:0] gpio_output,
    output wire                           sclk,
    output wire                           pico,
    input  wire                           poci,
    output wire [SPI_NUM_CHIP_SELECT-1:0] cs

);

  // System bus configuration

  localparam NUM_DEVICES = 5;
  localparam D0_RAM = 0;
  localparam D1_UART = 1;
  localparam D2_MTIMER = 2;
  localparam D3_GPIO = 3;
  localparam D4_SPI = 4;

  wire [NUM_DEVICES*32-1:0] device_start_address;
  wire [NUM_DEVICES*32-1:0] device_region_size;

  assign device_start_address[32*D0_RAM+:32]    = 32'h0000_0000;
  assign device_region_size[32*D0_RAM+:32]      = MEMORY_SIZE;

  assign device_start_address[32*D1_UART+:32]   = 32'h8000_0000;
  assign device_region_size[32*D1_UART+:32]     = 16;

  assign device_start_address[32*D2_MTIMER+:32] = 32'h8001_0000;
  assign device_region_size[32*D2_MTIMER+:32]   = 32;

  assign device_start_address[32*D3_GPIO+:32]   = 32'h8002_0000;
  assign device_region_size[32*D3_GPIO+:32]     = 32;

  assign device_start_address[32*D4_SPI+:32]    = 32'h8003_0000;
  assign device_region_size[32*D4_SPI+:32]      = 32;

  // RVX 32-bit Processor (Manager Device) <=> System Bus

  wire [              31:0] manager_rw_address;
  wire [              31:0] manager_read_data;
  wire                      manager_read_request;
  wire                      manager_read_response;
  wire [              31:0] manager_write_data;
  wire [               3:0] manager_write_strobe;
  wire                      manager_write_request;
  wire                      manager_write_response;

  // System Bus <=> Managed Devices

  wire [              31:0] device_rw_address;
  wire [NUM_DEVICES*32-1:0] device_read_data;
  wire [   NUM_DEVICES-1:0] device_read_request;
  wire [   NUM_DEVICES-1:0] device_read_response;
  wire [              31:0] device_write_data;
  wire [               3:0] device_write_strobe;
  wire [   NUM_DEVICES-1:0] device_write_request;
  wire [   NUM_DEVICES-1:0] device_write_response;

  // Real-time clock (unused)

  wire [              63:0] real_time_clock;

  assign real_time_clock = 64'b0;

  // Interrupt signals

  wire [15:0] irq_fast;
  wire        irq_external;
  wire        irq_timer;
  wire        irq_software;

  wire [15:0] irq_fast_response;
  wire        irq_external_response;
  wire        irq_timer_response;
  wire        irq_software_response;

  wire        irq_uart;
  wire        irq_uart_response;

  // Interrupt signals map

  assign irq_fast          = {15'b0, irq_uart};  // Give UART interrupts the highest priority
  assign irq_uart_response = irq_fast_response[0];

  assign irq_external      = 1'b0;  // unused
  assign irq_software      = 1'b0;  // unused


  rvx_core #(

      .BOOT_ADDRESS(BOOT_ADDRESS)

  ) rvx_core_instance (

      // Global signals

      .clock(clock),
      .reset(reset),
      .halt (halt),

      // IO interface

      .rw_address    (manager_rw_address),
      .read_data     (manager_read_data),
      .read_request  (manager_read_request),
      .read_response (manager_read_response),
      .write_data    (manager_write_data),
      .write_strobe  (manager_write_strobe),
      .write_request (manager_write_request),
      .write_response(manager_write_response),

      // Interrupt request signals

      .irq_fast    (irq_fast),
      .irq_external(irq_external),
      .irq_timer   (irq_timer),
      .irq_software(irq_software),

      // Interrupt response signals

      .irq_fast_response    (irq_fast_response),
      .irq_external_response(irq_external_response),
      .irq_timer_response   (irq_timer_response),
      .irq_software_response(irq_software_response),

      // Real Time Clock

      .real_time_clock(real_time_clock)

  );

  rvx_bus #(

      .NUM_DEVICES(NUM_DEVICES)

  ) rvx_bus_instance (

      // Global signals

      .clock(clock),
      .reset(reset),

      // Interface with the manager device (Processor Core IP)

      .manager_rw_address    (manager_rw_address),
      .manager_read_data     (manager_read_data),
      .manager_read_request  (manager_read_request),
      .manager_read_response (manager_read_response),
      .manager_write_data    (manager_write_data),
      .manager_write_strobe  (manager_write_strobe),
      .manager_write_request (manager_write_request),
      .manager_write_response(manager_write_response),

      // Interface with the managed devices

      .device_rw_address    (device_rw_address),
      .device_read_data     (device_read_data),
      .device_read_request  (device_read_request),
      .device_read_response (device_read_response),
      .device_write_data    (device_write_data),
      .device_write_strobe  (device_write_strobe),
      .device_write_request (device_write_request),
      .device_write_response(device_write_response),

      // Base addresses and masks of the managed devices

      .device_start_address(device_start_address),
      .device_region_size  (device_region_size)

  );

  rvx_ram #(

      .MEMORY_SIZE     (MEMORY_SIZE),
      .MEMORY_INIT_FILE(MEMORY_INIT_FILE)

  ) rvx_ram_instance (

      // Global signals

      .clock(clock),
      .reset(reset),

      // IO interface

      .rw_address    (device_rw_address),
      .read_data     (device_read_data[32*D0_RAM+:32]),
      .read_request  (device_read_request[D0_RAM]),
      .read_response (device_read_response[D0_RAM]),
      .write_data    (device_write_data),
      .write_strobe  (device_write_strobe),
      .write_request (device_write_request[D0_RAM]),
      .write_response(device_write_response[D0_RAM])

  );

  rvx_uart #(

      .CLOCK_FREQUENCY(CLOCK_FREQUENCY),
      .UART_BAUD_RATE (UART_BAUD_RATE)

  ) rvx_uart_instance (

      // Global signals

      .clock(clock),
      .reset(reset),

      // IO interface

      .rw_address    (device_rw_address[4:0]),
      .read_data     (device_read_data[32*D1_UART+:32]),
      .read_request  (device_read_request[D1_UART]),
      .read_response (device_read_response[D1_UART]),
      .write_data    (device_write_data[7:0]),
      .write_request (device_write_request[D1_UART]),
      .write_response(device_write_response[D1_UART]),

      // RX/TX signals

      .uart_tx(uart_tx),
      .uart_rx(uart_rx),

      // Interrupt signaling

      .uart_irq         (irq_uart),
      .uart_irq_response(irq_uart_response)

  );

  rvx_mtimer rvx_mtimer_instance (

      // Global signals

      .clock(clock),
      .reset(reset),

      // IO interface

      .rw_address    (device_rw_address[4:0]),
      .read_data     (device_read_data[32*D2_MTIMER+:32]),
      .read_request  (device_read_request[D2_MTIMER]),
      .read_response (device_read_response[D2_MTIMER]),
      .write_data    (device_write_data),
      .write_strobe  (device_write_strobe),
      .write_request (device_write_request[D2_MTIMER]),
      .write_response(device_write_response[D2_MTIMER]),

      // Interrupt signaling

      .irq(irq_timer)

  );

  rvx_gpio #(

      .GPIO_WIDTH(GPIO_WIDTH)

  ) rvx_gpio_instance (

      // Global signals

      .clock(clock),
      .reset(reset),

      // IO interface

      .rw_address    (device_rw_address[4:0]),
      .read_data     (device_read_data[32*D3_GPIO+:32]),
      .read_request  (device_read_request[D3_GPIO]),
      .read_response (device_read_response[D3_GPIO]),
      .write_data    (device_write_data[GPIO_WIDTH-1:0]),
      .write_strobe  (device_write_strobe),
      .write_request (device_write_request[D3_GPIO]),
      .write_response(device_write_response[D3_GPIO]),

      // I/O signals

      .gpio_input (gpio_input),
      .gpio_oe    (gpio_oe),
      .gpio_output(gpio_output)

  );

  rvx_spi #(

      .SPI_NUM_CHIP_SELECT(SPI_NUM_CHIP_SELECT)

  ) rvx_spi_instance (

      // Global signals

      .clock(clock),
      .reset(reset),

      // IO interface

      .rw_address    (device_rw_address[4:0]),
      .read_data     (device_read_data[32*D4_SPI+:32]),
      .read_request  (device_read_request[D4_SPI]),
      .read_response (device_read_response[D4_SPI]),
      .write_data    (device_write_data[7:0]),
      .write_strobe  (device_write_strobe),
      .write_request (device_write_request[D4_SPI]),
      .write_response(device_write_response[D4_SPI]),

      // SPI signals

      .sclk(sclk),
      .pico(pico),
      .poci(poci),
      .cs  (cs)

  );

  // Avoid warnings about intentionally unused pins/wires
  wire unused_ok = &{1'b0, irq_external, irq_software, irq_external_response, irq_software_response, irq_timer_response,
                     irq_fast_response[15:1], 1'b0};

endmodule
