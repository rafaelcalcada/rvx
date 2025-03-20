// ----------------------------------------------------------------------------
// Copyright (c) 2020-2025 RVX contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"

#define DEFAULT_UART (UartController *)0x80000000

void main(void)
{
  uart_write_string(DEFAULT_UART, "Hello World from RVX!");
}