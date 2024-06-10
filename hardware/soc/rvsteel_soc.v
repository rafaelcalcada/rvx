// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module rvsteel_soc #(

  // Frequency of 'clock' signal
  parameter CLOCK_FREQUENCY = 50000000  ,
  // Desired baud rate for UART unit
  parameter UART_BAUD_RATE = 9600       ,
  // Memory size in bytes - must be a power of 2
  parameter MEMORY_SIZE = 8192          ,
  // Text file with program and data (one hex value per line)
  parameter MEMORY_INIT_FILE = ""       ,
  // Address of the first instruction to fetch from memory
  parameter BOOT_ADDRESS = 32'h00000000 ,
  // Number of available I/O ports
  parameter GPIO_WIDTH = 2              ,
  // Number of CS (Chip Select) pins for the SPI controller
  parameter NUM_CS_LINES = 1,

  parameter PKA_EN = 1,
  parameter FORTIMAC_EN = 1,
  parameter FORTICRYPT_EN = 1

  ) (

  input   wire                      clock       ,
  input   wire                      reset       ,
  input   wire                      halt        ,
  input   wire                      uart_rx     ,
  output  wire                      uart_tx     ,
  input   wire  [GPIO_WIDTH-1:0]    gpio_input  ,
  output  wire  [GPIO_WIDTH-1:0]    gpio_oe     ,
  output  wire  [GPIO_WIDTH-1:0]    gpio_output ,
  output  wire                      sclk        ,
  output  wire                      pico        ,
  input   wire                      poci        ,
  output  wire  [NUM_CS_LINES-1:0]  cs

  );

  // System bus configuration

  localparam NUM_DEVICES    = 8;
  localparam D0_RAM         = 0;
  localparam D1_UART        = 1;
  localparam D2_MTIMER      = 2;
  localparam D3_GPIO        = 3;
  localparam D4_SPI         = 4;
  localparam D5_PKA         = 5;
  localparam D6_FORTIMAC    = 6;
  localparam D7_FORTICRYPT  = 7;

  wire  [NUM_DEVICES*32-1:0] device_start_address;
  wire  [NUM_DEVICES*32-1:0] device_region_size;

  assign device_start_address [32*D0_RAM        +: 32] = 32'h0000_0000;
  assign device_region_size   [32*D0_RAM        +: 32] = MEMORY_SIZE;

  assign device_start_address [32*D1_UART       +: 32] = 32'h8000_0000;
  assign device_region_size   [32*D1_UART       +: 32] = 8;

  assign device_start_address [32*D2_MTIMER     +: 32] = 32'h8001_0000;
  assign device_region_size   [32*D2_MTIMER     +: 32] = 32;

  assign device_start_address [32*D3_GPIO       +: 32] = 32'h8002_0000;
  assign device_region_size   [32*D3_GPIO       +: 32] = 32;

  assign device_start_address [32*D4_SPI        +: 32] = 32'h8003_0000;
  assign device_region_size   [32*D4_SPI        +: 32] = 32;

  assign device_start_address [32*D5_PKA        +: 32] = 32'h8004_0000;
  assign device_region_size   [32*D5_PKA        +: 32] = 65536;

  assign device_start_address [32*D6_FORTIMAC   +: 32] = 32'h8005_0000;
  assign device_region_size   [32*D6_FORTIMAC   +: 32] = 65536;

  assign device_start_address [32*D7_FORTICRYPT +: 32] = 32'h8006_0000;
  assign device_region_size   [32*D7_FORTICRYPT +: 32] = 65536;

  // RISC-V Steel 32-bit Processor (Manager Device) <=> System Bus

  wire  [31:0]                manager_rw_address      ;
  wire  [31:0]                manager_read_data       ;
  wire                        manager_read_request    ;
  wire                        manager_read_response   ;
  wire  [31:0]                manager_write_data      ;
  wire  [3:0 ]                manager_write_strobe    ;
  wire                        manager_write_request   ;
  wire                        manager_write_response  ;

  // System Bus <=> Managed Devices

  wire  [31:0]                device_rw_address       ;
  wire  [NUM_DEVICES*32-1:0]  device_read_data        ;
  wire  [NUM_DEVICES-1:0]     device_read_request     ;
  wire  [NUM_DEVICES-1:0]     device_read_response    ;
  wire  [31:0]                device_write_data       ;
  wire  [3:0]                 device_write_strobe     ;
  wire  [NUM_DEVICES-1:0]     device_write_request    ;
  wire  [NUM_DEVICES-1:0]     device_write_response   ;

  // Real-time clock (unused)

  wire  [63:0] real_time_clock;

  assign real_time_clock = 64'b0;

  // Interrupt signals

  wire  [15:0] irq_fast;
  wire         irq_external;
  wire         irq_timer;
  wire         irq_software;

  wire  [15:0] irq_fast_response;
  wire         irq_external_response;
  wire         irq_timer_response;
  wire         irq_software_response;

  wire         irq_uart;
  wire         irq_uart_response;

  typedef enum {IDLE, SEL, ENABLE} apb_fsm_t;

  wire irq_fortimac;
  wire irq_fortimac_response;
  wire irq_forticrypt;
  wire irq_forticrypt_response;

  // Interrupt signals map
  assign irq_fast               = {13'b0, irq_forticrypt, irq_fortimac, irq_uart}; // Give UART interrupts the highest priority
  assign irq_uart_response      = irq_fast_response[0];
  assign irq_fortimac_response  = irq_fast_response[1];
  assign irq_forticrypt_response  = irq_fast_response[2];

  assign irq_external           = 1'b0; // unused
  assign irq_software           = 1'b0; // unused


  rvsteel_core #(

    .BOOT_ADDRESS                   (BOOT_ADDRESS                       )

  ) rvsteel_core_instance (

    // Global signals

    .clock                          (clock                              ),
    .reset                          (reset                              ),
    .halt                           (halt                               ),

    // IO interface

    .rw_address                     (manager_rw_address                 ),
    .read_data                      (manager_read_data                  ),
    .read_request                   (manager_read_request               ),
    .read_response                  (manager_read_response              ),
    .write_data                     (manager_write_data                 ),
    .write_strobe                   (manager_write_strobe               ),
    .write_request                  (manager_write_request              ),
    .write_response                 (manager_write_response             ),

    // Interrupt request signals

    .irq_fast                       (irq_fast                           ),
    .irq_external                   (irq_external                       ),
    .irq_timer                      (irq_timer                          ),
    .irq_software                   (irq_software                       ),

    // Interrupt response signals

    .irq_fast_response              (irq_fast_response                  ),
    .irq_external_response          (irq_external_response              ),
    .irq_timer_response             (irq_timer_response                 ),
    .irq_software_response          (irq_software_response              ),

    // Real Time Clock

    .real_time_clock                (real_time_clock                    )

  );

  rvsteel_bus #(

    .NUM_DEVICES(NUM_DEVICES)

  ) rvsteel_bus_instance (

    // Global signals

    .clock                          (clock                              ),
    .reset                          (reset                              ),

    // Interface with the manager device (Processor Core IP)

    .manager_rw_address             (manager_rw_address                 ),
    .manager_read_data              (manager_read_data                  ),
    .manager_read_request           (manager_read_request               ),
    .manager_read_response          (manager_read_response              ),
    .manager_write_data             (manager_write_data                 ),
    .manager_write_strobe           (manager_write_strobe               ),
    .manager_write_request          (manager_write_request              ),
    .manager_write_response         (manager_write_response             ),

    // Interface with the managed devices

    .device_rw_address              (device_rw_address                  ),
    .device_read_data               (device_read_data                   ),
    .device_read_request            (device_read_request                ),
    .device_read_response           (device_read_response               ),
    .device_write_data              (device_write_data                  ),
    .device_write_strobe            (device_write_strobe                ),
    .device_write_request           (device_write_request               ),
    .device_write_response          (device_write_response              ),

    // Base addresses and masks of the managed devices

    .device_start_address          (device_start_address                ),
    .device_region_size            (device_region_size                  )

  );

  rvsteel_ram #(

    .MEMORY_SIZE                    (MEMORY_SIZE                        ),
    .MEMORY_INIT_FILE               (MEMORY_INIT_FILE                   )

  ) rvsteel_ram_instance (

    // Global signals

    .clock                          (clock                              ),
    .reset                          (reset                              ),

    // IO interface

    .rw_address                     (device_rw_address                  ),
    .read_data                      (device_read_data[32*D0_RAM +: 32]  ),
    .read_request                   (device_read_request[D0_RAM]        ),
    .read_response                  (device_read_response[D0_RAM]       ),
    .write_data                     (device_write_data                  ),
    .write_strobe                   (device_write_strobe                ),
    .write_request                  (device_write_request[D0_RAM]       ),
    .write_response                 (device_write_response[D0_RAM]      )

  );

  rvsteel_uart #(

    .CLOCK_FREQUENCY                (CLOCK_FREQUENCY                    ),
    .UART_BAUD_RATE                 (UART_BAUD_RATE                     )

  ) rvsteel_uart_instance (

    // Global signals

    .clock                          (clock                              ),
    .reset                          (reset                              ),

    // IO interface

    .rw_address                     (device_rw_address[4:0]             ),
    .read_data                      (device_read_data[32*D1_UART +: 32] ),
    .read_request                   (device_read_request[D1_UART]       ),
    .read_response                  (device_read_response[D1_UART]      ),
    .write_data                     (device_write_data[7:0]             ),
    .write_request                  (device_write_request[D1_UART]      ),
    .write_response                 (device_write_response[D1_UART]     ),

    // RX/TX signals

    .uart_tx                        (uart_tx                            ),
    .uart_rx                        (uart_rx                            ),

    // Interrupt signaling

    .uart_irq                       (irq_uart                           ),
    .uart_irq_response              (irq_uart_response                  )

  );

  rvsteel_mtimer
  rvsteel_mtimer_instance (

    // Global signals

    .clock                          (clock                                  ),
    .reset                          (reset                                  ),

    // IO interface

    .rw_address                     (device_rw_address[4:0]                 ),
    .read_data                      (device_read_data[32*D2_MTIMER +: 32]   ),
    .read_request                   (device_read_request[D2_MTIMER]         ),
    .read_response                  (device_read_response[D2_MTIMER]        ),
    .write_data                     (device_write_data                      ),
    .write_strobe                   (device_write_strobe                    ),
    .write_request                  (device_write_request[D2_MTIMER]        ),
    .write_response                 (device_write_response[D2_MTIMER]       ),

    // Interrupt signaling

    .irq                            (irq_timer                              )

  );

  rvsteel_gpio #(

    .GPIO_WIDTH                     (GPIO_WIDTH                             )

  ) rvsteel_gpio_instance (

    // Global signals

    .clock                          (clock                                  ),
    .reset                          (reset                                  ),

    // IO interface

    .rw_address                     (device_rw_address[4:0]                 ),
    .read_data                      (device_read_data[32*D3_GPIO +: 32]     ),
    .read_request                   (device_read_request[D3_GPIO]           ),
    .read_response                  (device_read_response[D3_GPIO]          ),
    .write_data                     (device_write_data[1:0]                 ),
    .write_strobe                   (device_write_strobe                    ),
    .write_request                  (device_write_request[D3_GPIO]          ),
    .write_response                 (device_write_response[D3_GPIO]         ),

    // I/O signals

    .gpio_input                     (gpio_input                             ),
    .gpio_oe                        (gpio_oe                                ),
    .gpio_output                    (gpio_output                            )

  );

  rvsteel_spi #(

    .NUM_CS_LINES                   (NUM_CS_LINES                       )

  ) rvsteel_spi_instance (

    // Global signals

    .clock                          (clock                              ),
    .reset                          (reset                              ),

    // IO interface

    .rw_address                     (device_rw_address[4:0]             ),
    .read_data                      (device_read_data[32*D4_SPI +: 32]  ),
    .read_request                   (device_read_request[D4_SPI]        ),
    .read_response                  (device_read_response[D4_SPI]       ),
    .write_data                     (device_write_data[7:0]             ),
    .write_strobe                   (device_write_strobe                ),
    .write_request                  (device_write_request[D4_SPI]       ),
    .write_response                 (device_write_response[D4_SPI]      ),

    // SPI signals

    .sclk                           (sclk                               ),
    .pico                           (pico                               ),
    .poci                           (poci                               ),
    .cs                             (cs                                 )

  );


  if (PKA_EN) begin : pka_gen

    wire pka_cs = device_read_request[D5_PKA] || device_write_request[D5_PKA];
    wire pka_wr = device_write_request[D5_PKA];

    reg pka_read_responce;
    reg pka_write_responce;

    always @(posedge clock or posedge reset) begin
      if (reset) begin
        pka_read_responce  <= 1'b0;
        pka_write_responce <= 1'b0;
      end else begin
        pka_read_responce  <= device_read_request[D5_PKA];
        pka_write_responce <= device_write_request[D5_PKA];
      end
    end

    assign device_read_response[D5_PKA]  = pka_read_responce;
    assign device_write_response[D5_PKA] = pka_write_responce;

    pka_top
    pka_top_inst (

      // Global clock and active-low reset

      .clk_i                          (clock                              ),
      .reset_ni                       (!reset                             ),

      // Interface to host

      .data_i                         (device_write_data                  ),
      .address_i                      (device_rw_address                  ),
      .cs_i                           (pka_cs                             ),
      .wr_i                           (pka_wr                             ),
      .data_o                         (device_read_data[32*D5_PKA +: 32]  ),

      // Pseudorandom data input

      .prnd_valid_i                   (1'b1                               ),
      .prnd_ready_o                   (                                   ),
      .prnd_data_i                    (50'b0                              )

    );
  end else begin: pka_dummy_gen
  
    assign device_read_data[32*D5_PKA +: 32] = 32'b0;
    assign device_read_response[D5_PKA]  = 1'b0;
    assign device_write_response[D5_PKA] = 1'b0;
    
  end

  if (FORTIMAC_EN) begin : fortimac_gen

    wire fortimac_irq_net;
    reg fortimac_irq_ff, fortimac_irq_pending;
    assign irq_fortimac = fortimac_irq_pending;

    always @(posedge clock) begin
      if (reset) begin
        fortimac_irq_ff <= 1'b0;
        fortimac_irq_pending <= 1'b0;
      end else begin
        fortimac_irq_ff <= fortimac_irq_net;
        if (fortimac_irq_net & ~fortimac_irq_ff)
          fortimac_irq_pending <= 1'b1;
        else if (irq_fortimac_response)
          fortimac_irq_pending <= 1'b0;
      end
    end

    wire sha2_top_apb_psel, sha2_top_apb_pwrite, sha2_top_apb_pready;
    wire sha2_top_apb_penable;

    apb_fsm_t apb_fsm;

    always @(posedge clock or posedge reset)
      if (reset)
        apb_fsm <= IDLE;
      else case (apb_fsm)
        IDLE:
          if (device_read_request[D6_FORTIMAC] | device_write_request[D6_FORTIMAC])
            apb_fsm <= SEL;
        SEL:
          apb_fsm <= ENABLE;
        ENABLE:
          if (sha2_top_apb_pready)
            apb_fsm <= IDLE;
        default:
          apb_fsm <= IDLE;
      endcase

    assign sha2_top_apb_psel = apb_fsm == SEL || apb_fsm == ENABLE;
    assign sha2_top_apb_penable = apb_fsm == ENABLE;

    // assign sha2_top_apb_psel = device_read_request[D6_FORTIMAC] | device_write_request[D6_FORTIMAC];
    // assign sha2_top_apb_penable = device_read_request[D6_FORTIMAC] | device_write_request[D6_FORTIMAC];
    assign sha2_top_apb_pwrite = device_write_request[D6_FORTIMAC];
    assign device_read_response[D6_FORTIMAC]  = sha2_top_apb_pready;
    assign device_write_response[D6_FORTIMAC] = sha2_top_apb_pready;
      
    // assign device2_write_response = device_write_request[D6_FORTIMAC] & sha2_top_apb_pready;
    // assign device2_read_response = device_read_request[D6_FORTIMAC] & sha2_top_apb_pready;

    sha2_top_apb #(
        .FIQSHA_BUS_DATA_WIDTH(32)
    ) i_sha2_top_apb (
        .pclk(clock)
      , .presetn(~reset)
      , .paddr(device_rw_address[11:0])
      , .psel(sha2_top_apb_psel)
      , .penable(sha2_top_apb_penable)
      , .pwrite(sha2_top_apb_pwrite)
      , .pwdata(device_write_data)
      , .pready(sha2_top_apb_pready)
      , .prdata(device_read_data[32*D6_FORTIMAC +: 32])
      , .pslverr()
      // interrupt request
      , .irq_o(fortimac_irq_net)
      // extensions
      , .aux_key_i('0)
      , .random_for_rf_i('{default: '0})
      , .random_for_data_i('0)
      // DMA support
      , .dma_wr_req_o()
      , .dma_rd_req_o()
    );

  end else begin : fortimac_dummy_gen

    assign device_read_data[32*D6_FORTIMAC +: 32] = 32'b0;
    assign device_read_response[D6_FORTIMAC]  = 1'b0;
    assign device_write_response[D6_FORTIMAC] = 1'b0;
    assign irq_fortimac = 1'b0;

  end

  if (FORTICRYPT_EN) begin : forticrypt_gen

    // `include "defines.v"

    wire forticrypt_irq_net;
    reg forticrypt_irq_ff, forticrypt_irq_pending;
    assign irq_forticrypt = forticrypt_irq_pending;

    always @(posedge clock) begin
      if (reset) begin
        forticrypt_irq_ff <= 1'b0;
        forticrypt_irq_pending <= 1'b0;
      end else begin
        forticrypt_irq_ff <= forticrypt_irq_net;
        if (forticrypt_irq_net & ~forticrypt_irq_ff)
          forticrypt_irq_pending <= 1'b1;
        else if (irq_forticrypt_response)
          forticrypt_irq_pending <= 1'b0;
      end
    end

    wire forticrypt_top_apb_psel, forticrypt_top_apb_pwrite, forticrypt_top_apb_pready;
    wire forticrypt_top_apb_penable;

    apb_fsm_t forticrypt_apb_fsm;

    always @(posedge clock or posedge reset)
      if (reset)
        forticrypt_apb_fsm <= IDLE;
      else case (forticrypt_apb_fsm)
        IDLE:
          if (device_read_request[D7_FORTICRYPT] | device_write_request[D7_FORTICRYPT])
            forticrypt_apb_fsm <= SEL;
        SEL:
          forticrypt_apb_fsm <= ENABLE;
        ENABLE:
          if (forticrypt_top_apb_pready)
            forticrypt_apb_fsm <= IDLE;
        default:
          forticrypt_apb_fsm <= IDLE;
      endcase

    assign forticrypt_top_apb_psel = forticrypt_apb_fsm == SEL || forticrypt_apb_fsm == ENABLE;
    assign forticrypt_top_apb_penable = forticrypt_apb_fsm == ENABLE;

    // assign forticrypt_top_apb_psel = device_read_request[D7_FORTICRYPT] | device_write_request[D7_FORTICRYPT];
    // assign forticrypt_top_apb_penable = device_read_request[D7_FORTICRYPT] | device_write_request[D7_FORTICRYPT];
    assign forticrypt_top_apb_pwrite = device_write_request[D7_FORTICRYPT];
    assign device_read_response[D7_FORTICRYPT]  = forticrypt_top_apb_pready;
    assign device_write_response[D7_FORTICRYPT] = forticrypt_top_apb_pready;
      
    // assign device2_write_response = device_write_request[D7_FORTICRYPT] & forticrypt_top_apb_pready;
    // assign device2_read_response = device_read_request[D7_FORTICRYPT] & forticrypt_top_apb_pready;

    localparam [127:0] aux_key = {8'h2b,8'h7e,8'h15,8'h16,8'h28,8'hae,8'hd2,8'ha6,8'hab,8'hf7,8'h15,8'h88,8'h09,8'hcf,8'h4f,8'h3c};
    function logic [127:0] swap_bytes_128 (input [127:0] x);
      for (int i = 0; i < 16; i++)
        swap_bytes_128[i*8+:8] = x[(15-i)*8+:8];
    endfunction

    aes_moo_apb #(
        .D_WIDTH(32)
      , .IFIFO_SIZE(4)
      , .OFIFO_SIZE(4)
      , .AUX_KEY_INPUT_EN(1)
    ) u_aes_moo_apb (
        .pclk(clock)
      , .presetn(~reset)
      , .paddr(device_rw_address[11:0])
      , .psel(forticrypt_top_apb_psel)
      , .penable(forticrypt_top_apb_penable)
      , .pwrite(forticrypt_top_apb_pwrite)
      , .pwdata(device_write_data)
      , .pstrb('1)
      , .pready(forticrypt_top_apb_pready)
      , .prdata(device_read_data[32*D7_FORTICRYPT +: 32])
      , .pslverr()
      , .irq(forticrypt_irq_net)
      // extensions
      , .aux_key(swap_bytes_128(aux_key))
    `ifdef FIQAES_SHARES_ENABLE
      , .aux_key_share2('0)
    `endif
      , .rand_i('0)
      // DMA support
      , .dma_wr_req_o()
      , .dma_rd_req_o()
    );

  end else begin : forticrypt_dummy_gen

    assign device_read_data[32*D7_FORTICRYPT +: 32] = 32'b0;
    assign device_read_response[D7_FORTICRYPT]  = 1'b0;
    assign device_write_response[D7_FORTICRYPT] = 1'b0;
    assign irq_forticrypt = 1'b0;

  end


  // Avoid warnings about intentionally unused pins/wires
  wire unused_ok =
    &{1'b0,
    irq_external,
    irq_software,
    irq_external_response,
    irq_software_response,
    irq_timer_response,
    irq_fast_response[15:1 + (FORTIMAC_EN ? 1 : 0) + (FORTICRYPT_EN ? 1 : 0)],
    {(1 + (FORTIMAC_EN ? 1 : 0) + (FORTICRYPT_EN ? 1 : 0)){1'b0}}};

endmodule
