// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "libsteel.h"

#define DEFAULT_UART (UartController *)0x80000000

// UART interrupt signal is connected to Fast IRQ #0
__NAKED void fast0_irq_handler(void)
{
  char rx = uart_read(DEFAULT_UART);
  if (rx == '\r') // Enter key
    uart_write_string(DEFAULT_UART, "\n\nType something else and press enter: ");
  else if (rx < 127)
    uart_write(DEFAULT_UART, rx);
  __ASM_VOLATILE("mret");
}

void main(void)
{
  uart_write_string(DEFAULT_UART, "RVX - UART demo");
  uart_write_string(DEFAULT_UART, "\n\nType something and press Enter:\n");
  csr_enable_vectored_mode_irq();
  CSR_SET(CSR_MIE, MIP_MIE_MASK_F0I);
  csr_global_enable_irq();
  while (1)
    ;
}
