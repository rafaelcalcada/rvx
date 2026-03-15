// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

void main()
{
  // Initialize UART at 9600 baud (assuming clock frequency is 12 MHz)
  rvx_uart_init(RVX_UART_ADDRESS, 9600, 12000000);

  // Send "Hello World, RVX!" message via RVX UART
  rvx_uart_send_string(RVX_UART_ADDRESS, "Hello World, RVX!\n");
}