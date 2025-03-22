module rvx_wrapper (

  input   wire          clock       ,
  input   wire          reset       ,
  input   wire          halt        ,

  // UART pins
  // You can remove them if your application does not use the UART controller
  input   wire          uart_rx     ,
  output  wire          uart_tx     ,

  // General Purpose I/O pins
  // You can remove them if your application does not use the GPIO controller
  input   wire  [3:0]   gpio_input  ,
  output  wire  [3:0]   gpio_oe     ,
  output  wire  [3:0]   gpio_output ,

  // Serial Peripheral Interface (SPI) pins
  // You can remove them if your application does not use the SPI controller
  output  wire          sclk        ,
  output  wire          pico        ,
  input   wire          poci        ,
  output  wire  [0:0]   cs

  );

  reg reset_debounced;
  always @(posedge clock) reset_debounced <= reset;

  reg halt_debounced;
  always @(posedge clock) halt_debounced <= halt;

  rvx #(

    // Frequency (in Hertz) of the `clock` pin
    .CLOCK_FREQUENCY          (50000000                   ),
    // Absolute path to the .hex init file generated in the previous step
    .MEMORY_INIT_FILE         ("/path/to/myapp.hex"       ),    
    // The size you want for the memory (in bytes)
    .MEMORY_SIZE              (8192                       ),
    // The UART baud rate (in bauds per second)
    .UART_BAUD_RATE           (9600                       ),
    // Don't change it unless you explicitly modified the boot address
    .BOOT_ADDRESS             (32'h00000000               ),
    // Width of the gpio_* ports
    .GPIO_WIDTH               (4                          ),
    // Width of the cs port
    .SPI_NUM_CHIP_SELECT      (1                          ))

    rvx_instance      (

    .clock                    (clock                      ),
    .reset                    (reset_debounced            ),
    .halt                     (halt_debounced             ),
    .uart_rx                  (uart_rx                    ),
    .uart_tx                  (uart_tx                    ),
    .gpio_input               (gpio_input                 ),
    .gpio_oe                  (gpio_oe                    ),
    .gpio_output              (gpio_output                ),
    .sclk                     (sclk                       ),
    .pico                     (pico                       ),
    .poci                     (poci                       ),
    .cs                       (cs                         ));

endmodule