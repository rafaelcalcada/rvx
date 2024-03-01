// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "rvsteel_api.h"

#ifndef MEMORY_SIZE
#define __RVSTEEL_MEM_SIZE "8192"
#else
#define __RVSTEEL_MEM_SIZE MEMORY_SIZE
#endif

// Boot code. Set the memory size, the return address, the stack pointer and
// the interrupt handler
asm(".section .boot, \"ax\";              \
    .global _start;                       \
    _start:                               \
      la ra, _start;                      \
      la sp, " __RVSTEEL_MEM_SIZE ";      \
      la t0, __rvsteel_irq_handler__;     \
      csrw mtvec, t0;                     \
      j main;                             \
    __rvsteel_irq_handler__:              \
      la t0, __RVSTEEL_IRQ_HANDLER;       \
      lw t1, 0(t0);                       \
      jalr ra, t1, 0;                     \
      mret;                               ");

// Address for sending data to UART
volatile char *__RVSTEEL_UART_TX = (volatile char *)0x80000000;

// Address for receiving data from UART
volatile char *__RVSTEEL_UART_RX = (volatile char *)0x80000004;

// Address of the interrupt handler
volatile void *__RVSTEEL_IRQ_HANDLER = (volatile void *)0x00000000;

void uart_send_char(const char c)
{
  while ((*__RVSTEEL_UART_TX) != 1)
    ;
  *(__RVSTEEL_UART_TX) = c;
}

void uart_send_string(const char *str)
{
  while (*(str) != '\0')
  {
    uart_send_char(*(str));
    str++;
  }
}

volatile char uart_read_last_char()
{
  return (*__RVSTEEL_UART_RX);
}

void irq_enable_all()
{
  asm("sw t0, -4(sp); li t0, 0xffffffff; csrw mstatus, t0; csrw mie, t0; lw t0, -4(sp);");
}

void irq_disable_all()
{
  asm("sw t0, -4(sp); li t0, 0x00000000; csrw mstatus, t0; csrw mie, t0; lw t0, -4(sp);");
}

void irq_set_interrupt_handler(void (*interrupt_handler)())
{
  __RVSTEEL_IRQ_HANDLER = (volatile void *)interrupt_handler;
}

void busy_wait()
{
  while (1)
    ;
}