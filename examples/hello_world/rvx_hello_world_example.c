// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

void main()
{
  // Pointer to the UART controller registers.
  RvxUartRegs *uart_controller = (RvxUartRegs *)RVX_UART_CONTROLLER_ADDRESS;

  // Initialize UART at 9600 baud (RVX clock is 12 MHz)
  rvx_uart_set_baud_rate(uart_controller, 9600, 12000000);

  // Send "Hello World, RVX!" message
  rvx_uart_send_string(uart_controller, "Hello World, RVX!\n");
}