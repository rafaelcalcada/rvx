// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx #(

    // Size of the tightly-coupled memory (TCM) in bytes
    parameter TCM_SIZE_IN_BYTES = 8192,

    // (FPGA Only) Path to the boot image to be loaded into the TCM at startup
    parameter TCM_BOOT_IMAGE_PATH = "",

    // Number of GPIO pins
    parameter GPIO_PIN_COUNT = 1,

    // Enable/disable the ZMMUL extension
    parameter ENABLE_ZMMUL = 0

) (

    input  wire                      clock,
    input  wire                      reset_n,
    input  wire                      uart_rx,
    output wire                      uart_tx,
    input  wire [GPIO_PIN_COUNT-1:0] gpio_input,
    output wire [GPIO_PIN_COUNT-1:0] gpio_output_enable,
    output wire [GPIO_PIN_COUNT-1:0] gpio_output,
    output wire                      sclk,
    output wire                      mosi,
    input  wire                      miso,
    output wire                      cs,
    input  wire                      i2c_sda_input,
    input  wire                      i2c_scl_input,
    output wire                      i2c_sda_output,
    output wire                      i2c_scl_output

);

  // RVX Interconnect - Instruction Bus Configuration
  // ---------------------------------------------------------------------------

  localparam IBUS_BOOTLOADER_ROM_REGION_INDEX = 0;
  localparam IBUS_TCM_REGION_INDEX = 1;
  localparam IBUS_NUM_PERIPHERALS = 2;

  localparam [31:0] IBUS_BOOTLOADER_ROM_BASE_ADDRESS = 32'h00000000;
  localparam [31:0] IBUS_BOOTLOADER_ROM_REGION_SIZE = 4096;

  localparam [31:0] IBUS_TCM_BASE_ADDRESS = 32'h00001000;
  localparam [31:0] IBUS_TCM_REGION_SIZE = TCM_SIZE_IN_BYTES;

  // RVX Interconnect - Data Bus Configuration
  // ---------------------------------------------------------------------------

  localparam DBUS_TCM_REGION_INDEX = 0;
  localparam DBUS_UART_REGION_INDEX = 1;
  localparam DBUS_TIMER_REGION_INDEX = 2;
  localparam DBUS_GPIO_REGION_INDEX = 3;
  localparam DBUS_SPI_REGION_INDEX = 4;
  localparam DBUS_I2C_REGION_INDEX = 5;
  localparam DBUS_NUM_PERIPHERALS = 6;

  localparam [31:0] DBUS_TCM_BASE_ADDRESS = 32'h00001000;
  localparam [31:0] DBUS_TCM_REGION_SIZE = TCM_SIZE_IN_BYTES;

  localparam [31:0] DBUS_UART_BASE_ADDRESS = 32'h40000000;
  localparam [31:0] DBUS_UART_REGION_SIZE = 16;

  localparam [31:0] DBUS_TIMER_BASE_ADDRESS = 32'h40001000;
  localparam [31:0] DBUS_TIMER_REGION_SIZE = 32;

  localparam [31:0] DBUS_GPIO_BASE_ADDRESS = 32'h40002000;
  localparam [31:0] DBUS_GPIO_REGION_SIZE = 32;

  localparam [31:0] DBUS_SPI_BASE_ADDRESS = 32'h40003000;
  localparam [31:0] DBUS_SPI_REGION_SIZE = 32;

  localparam [31:0] DBUS_I2C_BASE_ADDRESS = 32'h40004000;
  localparam [31:0] DBUS_I2C_REGION_SIZE = 16;

  // Instruction Bus signals (read-only)
  // ---------------------------------------------------------------------------

  wire [                       31:0] ibus_controller_address;
  wire [                       31:0] ibus_controller_rdata;
  wire                               ibus_controller_rrequest;
  wire                               ibus_controller_rresponse;
  wire [                       31:0] ibus_peripheral_address;
  wire [IBUS_NUM_PERIPHERALS*32-1:0] ibus_peripheral_rdata;
  wire [   IBUS_NUM_PERIPHERALS-1:0] ibus_peripheral_rrequest;
  wire [   IBUS_NUM_PERIPHERALS-1:0] ibus_peripheral_rresponse;

  // Data Bus signals
  // ---------------------------------------------------------------------------

  wire [                       31:0] dbus_controller_address;
  wire [                       31:0] dbus_controller_rdata;
  wire                               dbus_controller_rrequest;
  wire                               dbus_controller_rresponse;
  wire [                       31:0] dbus_controller_wdata;
  wire [                        3:0] dbus_controller_wstrobe;
  wire                               dbus_controller_wrequest;
  wire                               dbus_controller_wresponse;
  wire [                       31:0] dbus_peripheral_address;
  wire [DBUS_NUM_PERIPHERALS*32-1:0] dbus_peripheral_rdata;
  wire [   DBUS_NUM_PERIPHERALS-1:0] dbus_peripheral_rrequest;
  wire [   DBUS_NUM_PERIPHERALS-1:0] dbus_peripheral_rresponse;
  wire [                       31:0] dbus_peripheral_wdata;
  wire [                        3:0] dbus_peripheral_wstrobe;
  wire [   DBUS_NUM_PERIPHERALS-1:0] dbus_peripheral_wrequest;
  wire [   DBUS_NUM_PERIPHERALS-1:0] dbus_peripheral_wresponse;

  // Interrupt configuration
  // ---------------------------------------------------------------------------

  assign irq_fast     = {14'b0, irq_i2c, irq_uart};
  assign irq_external = 1'b0;  // unused
  assign irq_software = 1'b0;  // unused

  // Interrupt signals
  // ---------------------------------------------------------------------------

  wire [15:0] irq_fast;
  wire        irq_external;
  wire        irq_timer;
  wire        irq_software;
  wire        irq_uart;
  wire        irq_i2c;

  // Memory-mapped timer
  // ---------------------------------------------------------------------------

  wire [63:0] timer;

  // Module instantiations
  // ---------------------------------------------------------------------------

  rvx_core #(

      .ENABLE_ZMMUL(ENABLE_ZMMUL)

  ) rvx_core_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Instruction bus
      .ibus_address  (ibus_controller_address),
      .ibus_rdata    (ibus_controller_rdata),
      .ibus_rrequest (ibus_controller_rrequest),
      .ibus_rresponse(ibus_controller_rresponse),

      // Data bus
      .dbus_address  (dbus_controller_address),
      .dbus_rdata    (dbus_controller_rdata),
      .dbus_rrequest (dbus_controller_rrequest),
      .dbus_rresponse(dbus_controller_rresponse),
      .dbus_wdata    (dbus_controller_wdata),
      .dbus_wstrobe  (dbus_controller_wstrobe),
      .dbus_wrequest (dbus_controller_wrequest),
      .dbus_wresponse(dbus_controller_wresponse),

      // Interrupt requests
      .irq_fast    (irq_fast),
      .irq_external(irq_external),
      .irq_timer   (irq_timer),
      .irq_software(irq_software),

      // Memory-mapped timer
      .memory_mapped_timer(timer)

  );

  rvx_interconnect #(

      .NUM_PERIPHERALS(DBUS_NUM_PERIPHERALS),
      .BASE_ADDRESSES({
        DBUS_I2C_BASE_ADDRESS,
        DBUS_SPI_BASE_ADDRESS,
        DBUS_GPIO_BASE_ADDRESS,
        DBUS_TIMER_BASE_ADDRESS,
        DBUS_UART_BASE_ADDRESS,
        DBUS_TCM_BASE_ADDRESS
      }),
      .REGION_SIZES({
        DBUS_I2C_REGION_SIZE,
        DBUS_SPI_REGION_SIZE,
        DBUS_GPIO_REGION_SIZE,
        DBUS_TIMER_REGION_SIZE,
        DBUS_UART_REGION_SIZE,
        DBUS_TCM_REGION_SIZE
      })

  ) rvx_interconnect_dbus_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Connections with the controller device (RVX Core)
      .controller_address  (dbus_controller_address),
      .controller_rdata    (dbus_controller_rdata),
      .controller_rrequest (dbus_controller_rrequest),
      .controller_rresponse(dbus_controller_rresponse),
      .controller_wdata    (dbus_controller_wdata),
      .controller_wstrobe  (dbus_controller_wstrobe),
      .controller_wrequest (dbus_controller_wrequest),
      .controller_wresponse(dbus_controller_wresponse),

      // Connections with the controlled peripheral devices
      .peripheral_address  (dbus_peripheral_address),
      .peripheral_rdata    (dbus_peripheral_rdata),
      .peripheral_rrequest (dbus_peripheral_rrequest),
      .peripheral_rresponse(dbus_peripheral_rresponse),
      .peripheral_wdata    (dbus_peripheral_wdata),
      .peripheral_wstrobe  (dbus_peripheral_wstrobe),
      .peripheral_wrequest (dbus_peripheral_wrequest),
      .peripheral_wresponse(dbus_peripheral_wresponse)

  );

  rvx_interconnect #(

      .NUM_PERIPHERALS(IBUS_NUM_PERIPHERALS),
      .BASE_ADDRESSES ({IBUS_TCM_BASE_ADDRESS, IBUS_BOOTLOADER_ROM_BASE_ADDRESS}),
      .REGION_SIZES   ({IBUS_TCM_REGION_SIZE, IBUS_BOOTLOADER_ROM_REGION_SIZE})

  ) rvx_interconnect_ibus_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Connections with the controller device (RVX Core)
      .controller_address  (ibus_controller_address),
      .controller_rdata    (ibus_controller_rdata),
      .controller_rrequest (ibus_controller_rrequest),
      .controller_rresponse(ibus_controller_rresponse),

      // Connections with the controlled peripheral devices
      .peripheral_address  (ibus_peripheral_address),
      .peripheral_rdata    (ibus_peripheral_rdata),
      .peripheral_rrequest (ibus_peripheral_rrequest),
      .peripheral_rresponse(ibus_peripheral_rresponse),

      // verilator lint_off PINCONNECTEMPTY
      .controller_wdata    (),
      .controller_wstrobe  (),
      .controller_wrequest (),
      .controller_wresponse(),
      .peripheral_wdata    (),
      .peripheral_wstrobe  (),
      .peripheral_wrequest (),
      .peripheral_wresponse()
      // verilator lint_on PINCONNECTEMPTY

  );

  rvx_bootloader_rom rvx_bootloader_rom_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Read-only port - Instruction bus
      .address  (ibus_peripheral_address),
      .rdata    (ibus_peripheral_rdata[32*IBUS_BOOTLOADER_ROM_REGION_INDEX+:32]),
      .rrequest (ibus_peripheral_rrequest[IBUS_BOOTLOADER_ROM_REGION_INDEX]),
      .rresponse(ibus_peripheral_rresponse[IBUS_BOOTLOADER_ROM_REGION_INDEX])

  );

  rvx_tcm #(

      .SIZE_IN_BYTES  (TCM_SIZE_IN_BYTES),
      .BOOT_IMAGE_PATH(TCM_BOOT_IMAGE_PATH),
      .BASE_ADDRESS   (DBUS_TCM_BASE_ADDRESS)

  ) rvx_tightly_coupled_memory_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Port 0 (read-only) - Instruction bus
      .port0_address  (ibus_peripheral_address),
      .port0_rdata    (ibus_peripheral_rdata[32*IBUS_TCM_REGION_INDEX+:32]),
      .port0_rrequest (ibus_peripheral_rrequest[IBUS_TCM_REGION_INDEX]),
      .port0_rresponse(ibus_peripheral_rresponse[IBUS_TCM_REGION_INDEX]),

      // Port 1 (read/write) - Data bus
      .port1_address  (dbus_peripheral_address),
      .port1_rdata    (dbus_peripheral_rdata[32*DBUS_TCM_REGION_INDEX+:32]),
      .port1_rrequest (dbus_peripheral_rrequest[DBUS_TCM_REGION_INDEX]),
      .port1_rresponse(dbus_peripheral_rresponse[DBUS_TCM_REGION_INDEX]),
      .port1_wdata    (dbus_peripheral_wdata),
      .port1_wstrobe  (dbus_peripheral_wstrobe),
      .port1_wrequest (dbus_peripheral_wrequest[DBUS_TCM_REGION_INDEX]),
      .port1_wresponse(dbus_peripheral_wresponse[DBUS_TCM_REGION_INDEX])
  );

  rvx_uart rvx_uart_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Register read/write
      .rw_address    (dbus_peripheral_address[4:0]),
      .read_data     (dbus_peripheral_rdata[32*DBUS_UART_REGION_INDEX+:32]),
      .read_request  (dbus_peripheral_rrequest[DBUS_UART_REGION_INDEX]),
      .read_response (dbus_peripheral_rresponse[DBUS_UART_REGION_INDEX]),
      .write_data    (dbus_peripheral_wdata),
      .write_strobe  (dbus_peripheral_wstrobe),
      .write_request (dbus_peripheral_wrequest[DBUS_UART_REGION_INDEX]),
      .write_response(dbus_peripheral_wresponse[DBUS_UART_REGION_INDEX]),

      // UART RX/TX signals
      .uart_tx(uart_tx),
      .uart_rx(uart_rx),

      // UART interrupt request (connected to Fast Interrupt 0)
      .uart_irq(irq_uart)

  );

  rvx_timer rvx_timer_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Register read/write
      .rw_address    (dbus_peripheral_address[4:0]),
      .read_data     (dbus_peripheral_rdata[32*DBUS_TIMER_REGION_INDEX+:32]),
      .read_request  (dbus_peripheral_rrequest[DBUS_TIMER_REGION_INDEX]),
      .read_response (dbus_peripheral_rresponse[DBUS_TIMER_REGION_INDEX]),
      .write_data    (dbus_peripheral_wdata),
      .write_strobe  (dbus_peripheral_wstrobe),
      .write_request (dbus_peripheral_wrequest[DBUS_TIMER_REGION_INDEX]),
      .write_response(dbus_peripheral_wresponse[DBUS_TIMER_REGION_INDEX]),

      // Timer interrupt request
      .timer_irq(irq_timer),

      // Timer output
      .timer(timer)

  );

  rvx_gpio #(

      .PIN_COUNT(GPIO_PIN_COUNT)

  ) rvx_gpio_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Register read/write
      .rw_address    (dbus_peripheral_address[4:0]),
      .read_data     (dbus_peripheral_rdata[32*DBUS_GPIO_REGION_INDEX+:32]),
      .read_request  (dbus_peripheral_rrequest[DBUS_GPIO_REGION_INDEX]),
      .read_response (dbus_peripheral_rresponse[DBUS_GPIO_REGION_INDEX]),
      .write_data    (dbus_peripheral_wdata[GPIO_PIN_COUNT-1:0]),
      .write_strobe  (dbus_peripheral_wstrobe),
      .write_request (dbus_peripheral_wrequest[DBUS_GPIO_REGION_INDEX]),
      .write_response(dbus_peripheral_wresponse[DBUS_GPIO_REGION_INDEX]),

      // GPIO signals
      .gpio_input        (gpio_input),
      .gpio_output_enable(gpio_output_enable),
      .gpio_output       (gpio_output)

  );

  rvx_spi rvx_spi_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // Register read/write
      .rw_address    (dbus_peripheral_address[4:0]),
      .read_data     (dbus_peripheral_rdata[32*DBUS_SPI_REGION_INDEX+:32]),
      .read_request  (dbus_peripheral_rrequest[DBUS_SPI_REGION_INDEX]),
      .read_response (dbus_peripheral_rresponse[DBUS_SPI_REGION_INDEX]),
      .write_data    (dbus_peripheral_wdata),
      .write_strobe  (dbus_peripheral_wstrobe),
      .write_request (dbus_peripheral_wrequest[DBUS_SPI_REGION_INDEX]),
      .write_response(dbus_peripheral_wresponse[DBUS_SPI_REGION_INDEX]),

      // SPI signals
      .sclk(sclk),
      .mosi(mosi),
      .miso(miso),
      .cs  (cs)

  );

  rvx_i2c rvx_i2c_instance (

      // Global signals
      .clock  (clock),
      .reset_n(reset_n),

      // IO interface
      .rw_address    (dbus_peripheral_address[4:0]),
      .read_data     (dbus_peripheral_rdata[32*DBUS_I2C_REGION_INDEX+:32]),
      .read_request  (dbus_peripheral_rrequest[DBUS_I2C_REGION_INDEX]),
      .read_response (dbus_peripheral_rresponse[DBUS_I2C_REGION_INDEX]),
      .write_data    (dbus_peripheral_wdata[15:0]),
      .write_strobe  (dbus_peripheral_wstrobe),
      .write_request (dbus_peripheral_wrequest[DBUS_I2C_REGION_INDEX]),
      .write_response(dbus_peripheral_wresponse[DBUS_I2C_REGION_INDEX]),

      // I2C signals
      .sda_input (i2c_sda_input),
      .scl_input (i2c_scl_input),
      .sda_output(i2c_sda_output),
      .scl_output(i2c_scl_output),

      // I2C interrupt request (connected to Fast Interrupt 1)
      .i2c_irq(irq_i2c)
  );

endmodule
