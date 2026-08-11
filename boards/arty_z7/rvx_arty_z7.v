// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

module rvx_arty_z7 #(

    parameter GPIO_PIN_COUNT = 3

) (

    input  wire clock,
    output wire sclk,
    output wire mosi,
    input  wire miso,
    output wire cs,
    inout  wire sda,
    inout  wire scl,
    input  wire push_button_0,  // Used for reset
    input  wire push_button_1,  // Used for toggling LED
    output wire led_4,
    output wire led_5,

    inout wire DDR_cas_n,
    inout wire DDR_cke,
    inout wire DDR_ck_n,
    inout wire DDR_ck_p,
    inout wire DDR_cs_n,
    inout wire DDR_reset_n,
    inout wire DDR_odt,
    inout wire DDR_ras_n,
    inout wire DDR_we_n,
    inout wire [2:0] DDR_ba,
    inout wire [14:0] DDR_addr,
    inout wire [3:0] DDR_dm,
    inout wire [31:0] DDR_dq,
    inout wire [3:0] DDR_dqs_n,
    inout wire [3:0] DDR_dqs_p,
    inout wire [53:0] FIXED_IO_mio,
    inout wire FIXED_IO_ddr_vrn,
    inout wire FIXED_IO_ddr_vrp,
    inout wire FIXED_IO_ps_srstb,
    inout wire FIXED_IO_ps_clk,
    inout wire FIXED_IO_ps_porb

);

  wire                      i2c_sda_output;
  wire                      i2c_scl_output;
  wire [GPIO_PIN_COUNT-1:0] gpio_output_enable;
  wire [GPIO_PIN_COUNT-1:0] gpio_input;
  wire [GPIO_PIN_COUNT-1:0] gpio_output;
  wire                      rvx_clock;
  wire                      uart_rvx_rx_ps_tx;
  wire                      uart_rvx_tx_ps_rx;

  // Number of clock cycles in 20ms at 50MHz (Arty A7 board clock frequency)
  localparam NUM_CYCLES_IN_20_MS = 1100000;

  reg        push_button_0_sync_0;
  reg        push_button_1_sync_0;
  reg        push_button_0_sync_1;
  reg        push_button_1_sync_1;
  reg        push_button_0_debounced;
  reg        push_button_1_debounced;
  reg [20:0] push_button_0_counter;
  reg [20:0] push_button_1_counter;

  // RVX Instantiation
  // ---------------------------------------------------------------------------

  rvx #(

      .TCM_SIZE_IN_BYTES(32768),
      .TCM_BOOT_IMAGE_PATH("rvx_gpio_example.mem"),
      .GPIO_PIN_COUNT       (GPIO_PIN_COUNT)

  ) rvx_instance (

      .clock             (rvx_clock),
      .reset_n           (!push_button_0_debounced),
      .uart_tx           (uart_rvx_tx_ps_rx),
      .uart_rx           (uart_rvx_rx_ps_tx),
      .sclk              (sclk),
      .mosi              (mosi),
      .miso              (miso),
      .cs                (cs),
      .gpio_input        (gpio_input),
      .gpio_output_enable(gpio_output_enable),
      .gpio_output       (gpio_output),
      .i2c_sda_input     (sda),
      .i2c_scl_input     (scl),
      .i2c_sda_output    (i2c_sda_output),
      .i2c_scl_output    (i2c_scl_output)

  );

  processing_system_bd_sv u_processing_system_bd
  (
   .DDR_cas_n(DDR_cas_n),
   .DDR_cke(DDR_cke),
   .DDR_ck_n(DDR_ck_n),
   .DDR_ck_p(DDR_ck_p),
   .DDR_cs_n(DDR_cs_n),
   .DDR_reset_n(DDR_reset_n),
   .DDR_odt(DDR_odt),
   .DDR_ras_n(DDR_ras_n),
   .DDR_we_n(DDR_we_n),
   .DDR_ba(DDR_ba),
   .DDR_addr(DDR_addr),
   .DDR_dm(DDR_dm),
   .DDR_dq(DDR_dq),
   .DDR_dqs_n(DDR_dqs_n),
   .DDR_dqs_p(DDR_dqs_p),
   .FIXED_IO_mio(FIXED_IO_mio),
   .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
   .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
   .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
   .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
   .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
   .UART_1_txd(uart_rvx_rx_ps_tx),
   .UART_1_rxd(uart_rvx_tx_ps_rx)
  );

  assign sda           = (i2c_sda_output) ? 1'bz : 1'b0;
  assign scl           = (i2c_scl_output) ? 1'bz : 1'b0;
  assign gpio_input[0] = gpio_output_enable[0] ? gpio_output[0] : led_4;
  assign gpio_input[1] = gpio_output_enable[1] ? gpio_output[1] : push_button_1_debounced;
  assign gpio_input[2] = gpio_output_enable[2] ? gpio_output[2] : led_5;
  assign led_4         = gpio_output[0];
  assign led_5         = gpio_output[2];

  // Divide Arty 125MHz board clock to 55 MHz
  // ---------------------------------------------------------------------------
  clk_wiz_0 u_clk_wiz_0 (
    .clk_in1(clock),
    .clk_out1(rvx_clock)
  );

  // Push-buttons debouncing
  // ---------------------------------------------------------------------------

  always @(posedge rvx_clock) begin
    if (push_button_0) begin
      push_button_0_sync_0    <= 1'b1;
      push_button_0_sync_1    <= 1'b1;
      push_button_0_debounced <= 1'b1;
      push_button_0_counter   <= 0;
      push_button_1_sync_0    <= 1'b1;
      push_button_1_sync_1    <= 1'b1;
      push_button_1_debounced <= 1'b1;
      push_button_1_counter   <= 0;
    end
    else begin
      push_button_0_sync_0 <= push_button_0;
      push_button_0_sync_1 <= push_button_0_sync_0;
      push_button_1_sync_0 <= push_button_1;
      push_button_1_sync_1 <= push_button_1_sync_0;
      if (push_button_0_sync_1 != push_button_0_debounced) begin
        push_button_0_counter <= push_button_0_counter + 1;
        if (push_button_0_counter >= NUM_CYCLES_IN_20_MS) begin
          push_button_0_debounced <= push_button_0_sync_1;
          push_button_0_counter   <= 0;
        end
      end
      else push_button_0_counter <= 0;
      if (push_button_1_sync_1 != push_button_1_debounced) begin
        push_button_1_counter <= push_button_1_counter + 1;
        if (push_button_1_counter >= NUM_CYCLES_IN_20_MS) begin
          push_button_1_debounced <= push_button_1_sync_1;
          push_button_1_counter   <= 0;
        end
      end
      else push_button_1_counter <= 0;
    end
  end

endmodule
