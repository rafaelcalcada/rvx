// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

void main(void)
{
  // Initialize UART at 9600 baud (assuming clock frequency is 12 MHz)
  rvx_uart_init(RVX_UART_ADDRESS, 9600, 12000000);

  // Print welcome message
  rvx_uart_send_string(RVX_UART_ADDRESS, "RVX Timer Example Project\n\n");
  rvx_uart_send_string(RVX_UART_ADDRESS, "LED 0 state will be toggled by the timer every second.\n");

  // Configure pin 0 as output
  rvx_gpio_set_direction(RVX_GPIO_ADDRESS, 0, RVX_GPIO_OUTPUT);

  // Light up the LED initially
  rvx_gpio_set_high(RVX_GPIO_ADDRESS, 0);

  // Configure the machine timer to generate an interrupt every second
  rvx_timer_disable(RVX_TIMER_ADDRESS);               // Disable while configuring is in progress
  rvx_timer_set_compare(RVX_TIMER_ADDRESS, 12000000); // Assuming CPU frequency is 12 MHz
  rvx_timer_clear_counter(RVX_TIMER_ADDRESS);

  // Enable vectored interrupt mode and timer interrupts in M-mode, then globally enable interrupts in M-mode
  rvx_irq_set_mode(RVX_PRIVILEGE_LEVEL_M, RVX_INTERRUPT_MODE_VECTORED);
  rvx_irq_enable(RVX_PRIVILEGE_LEVEL_M, RVX_IRQ_TIMER_BITMASK);
  rvx_irq_enable_global(RVX_PRIVILEGE_LEVEL_M);

  // Start counting the time
  rvx_timer_enable(RVX_TIMER_ADDRESS);

  // Wait for a timer interrupt
  rvx_wait_for_interrupt();
}

// Provides a custom interrupt handler for timer interrupts in M-mode.
RVX_TRAP_HANDLER_M(rvx_trap_handler_timer_m)
{
  // Read LED 0 state and toggle it
  bool led_state = rvx_gpio_read(RVX_GPIO_ADDRESS, 0);
  rvx_gpio_write(RVX_GPIO_ADDRESS, 0, !led_state);

  // Clear the timer counter to restart counting from zero
  rvx_timer_clear_counter(RVX_TIMER_ADDRESS);
}