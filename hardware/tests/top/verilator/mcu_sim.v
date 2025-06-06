// ----------------------------------------------------------------------------
// Copyright (c) 2020-2025 RVX contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module mcu_sim #(

    // Number of available I/O ports
    parameter GPIO_WIDTH    = 2,
    // Number of CS (Chip Select) pins for the SPI controller
    parameter SPI_NUM_CHIP_SELECT  = 1

  ) (

    input   wire                            clock       ,
    input   wire                            reset       ,
    input   wire                            halt        ,
    input   wire                            uart_rx     ,
    output  wire                            uart_tx     ,
    input   wire  [GPIO_WIDTH-1:0]          gpio_input  ,
    output  wire  [GPIO_WIDTH-1:0]          gpio_oe     ,
    output  wire  [GPIO_WIDTH-1:0]          gpio_output ,
    output  wire                            sclk        ,
    output  wire                            pico        ,
    input   wire                            poci        ,
    output  wire  [SPI_NUM_CHIP_SELECT-1:0] cs
  );

  rvx #(

    .CLOCK_FREQUENCY          (50000000           ),
    .UART_BAUD_RATE           (9600               ),
    .MEMORY_SIZE              (32768              ),
    .MEMORY_INIT_FILE         (""                 ),
    .BOOT_ADDRESS             (32'h00000000       ),
    .GPIO_WIDTH               (GPIO_WIDTH         )

  ) rvx_instance (

    .clock                    (clock              ),
    .reset                    (reset              ),
    .halt                     (halt               ),
    .uart_rx                  (uart_rx            ),
    .uart_tx                  (uart_tx            ),
    .gpio_input               (gpio_input         ),
    .gpio_oe                  (gpio_oe            ),
    .gpio_output              (gpio_output        ),
    .sclk                     (sclk               ),
    .pico                     (pico               ),
    .poci                     (poci               ),
    .cs                       (cs                 )
  );

endmodule
