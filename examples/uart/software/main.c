// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx.h"

RvxUart *uart_address = (RvxUart *)0x80000000;

// UART interrupt signal is connected to Fast IRQ #0
RVX_NAKED void fast0_irq_handler(void)
{
  char rx = rvx_uart_read(uart_address);
  if (rx == '\r') // Enter key
    rvx_uart_write_string(uart_address, "\n\nType something else and press enter: ");
  else if (rx < 127)
    rvx_uart_write(uart_address, rx);
  asm volatile("mret");
}

void main(void)
{
  rvx_uart_init(uart_address, 1250); // 12 MHz / 9600 baud = 1250 cycles per baud
  rvx_uart_write_string(uart_address, "RVX Project - UART Example\n");
  rvx_uart_write_string(uart_address, "\n\nType something and press Enter:\n");
  rvx_irq_enable_vectored_mode();
  rvx_irq_enable(RVX_IRQ_FAST_MASK(0)); // UART is connected to Fast IRQ #0
  rvx_irq_enable_global();
  while (1)
    ;
}
