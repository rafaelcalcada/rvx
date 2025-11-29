// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "libsteel.h"

#define DEFAULT_UART (UartController *)0x80000000

void main(void)
{
  uart_write_string(DEFAULT_UART, "Hello World from RVX!");
}