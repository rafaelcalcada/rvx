// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

void main(void)
{
  RvxUart *uart_address = (RvxUart *)0x80000000;
  rvx_uart_init(uart_address, 1250);
  rvx_uart_write_string(uart_address, "Hello World from RVX!");
}