// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "libsteel.h"

#define DEFAULT_UART (UartController *)0x80000000
#define DEFAULT_MTIMER (MTimerController *)0x80010000

// Overrides the standard interrupt handler for Machine Timer interrupts
__NAKED void mti_irq_handler()
{
  mtimer_clear_counter(DEFAULT_MTIMER);
  uart_write_string(DEFAULT_UART, "Time elapsed: 1 sec\n");
  __ASM_VOLATILE("mret");
}

int main(void)
{
  uart_write_string(DEFAULT_UART, "MTimer demo started running...\n");
  mtimer_set_compare(DEFAULT_MTIMER, CPU_FREQUENCY);
  mtimer_clear_counter(DEFAULT_MTIMER);
  mtimer_enable(DEFAULT_MTIMER);
  csr_enable_vectored_mode_irq();
  CSR_SET(CSR_MIE, MIP_MIE_MASK_MTI);
  csr_global_enable_irq();
  while (1)
    ;
}
