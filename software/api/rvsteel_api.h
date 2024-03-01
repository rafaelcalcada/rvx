// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __RVSTEEL_SOC_IP_API__
#define __RVSTEEL_SOC_IP_API__

/// Send a single character over the UART
void uart_send_char(const char c);

/// Send a C-string over the UART
void uart_send_string(const char *str);

/// Return the last character received over the UART
volatile char uart_read_last_char();

/// Enable external, timer and software interrupts
void irq_enable_all();

/// Disable external, timer and software interrupts
void irq_disable_all();

/// Sets the function to be called on interrupts
void irq_set_interrupt_handler(void (*interrupt_handler)());

/// Enter into an infinite loop that can only be stopped by an interrupt
/// request. Make sure interrupts are enabled before calling this method.
/// You can enable all types of interrupt by calling irq_enable_all().
void busy_wait();

#endif