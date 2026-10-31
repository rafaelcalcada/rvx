// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// RVX setup configuration (adjust clock frequency if needed)
const RvxSetup rvx_setup = {.clock_frequency = 50000000U, .trap_handler = RVX_DEFAULT_TRAP_HANDLER};

void main()
{
  // RVX initialization
  rvx_init(&rvx_setup);

  // Initialize UART at 9600 baud per second
  rvx_uart_set_baud_rate(RVX_UART0, 9600U);

  // Send "Hello World, RVX!" message
  rvx_uart_print(RVX_UART0, "Hello World, RVX!\n");
}