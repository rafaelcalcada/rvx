// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// RVX setup configuration (adjust clock frequency if needed)
const RvxSetup rvx_setup = {.clock_frequency = 12000000U, .trap_handler = RVX_DEFAULT_TRAP_HANDLER};

// Custom interrupt handler for the UART0 interrupt
void rvx_interrupt_handler(const uint32_t interrupt_cause)
{
  if (interrupt_cause == RVX_CAUSE_EXTERNAL_IRQ_M)
  {
    uint32_t source_id = rvx_plic_claim_source(RVX_PLIC0);
    if (source_id == RVX_PLIC0_SOURCE_UART0)
    {
      // Read received byte from UART
      char rx_data = rvx_uart_read(RVX_UART0);

      // Echo it back
      rvx_uart_write(RVX_UART0, rx_data);
    }
  }
}

void main(void)
{
  // RVX initialization
  rvx_init(&rvx_setup);

  // Initialize UART at 9600 baud (rvx_setup.clock_frequency / 1250 = 9600)
  rvx_uart_set_clock_divider(RVX_UART0, 1250U);

  // Print welcome message
  rvx_uart_print(RVX_UART0, "RVX UART Example Project\n\n");
  rvx_uart_print(RVX_UART0, "Type something to echo it back:\n");

  // Enable UART0 interrupt in the PLIC and set it to maximum priority
  rvx_plic_enable_source(RVX_PLIC0, RVX_PLIC0_SOURCE_UART0);
  rvx_plic_set_priority(RVX_PLIC0, RVX_PLIC0_SOURCE_UART0, RVX_PLIC_MAX_PRIORITY);

  // Enable interrupts in M-mode and wait for UART interrupt
  rvx_interrupt_enable_m();
  while (1)
    ;
}