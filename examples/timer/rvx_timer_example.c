// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

void main(void)
{
  // Initialize UART at 9600 baud (assuming clock frequency is 12 MHz)
  rvx_uart_init(RVX_UART_ADDRESS, 9600, 12000000);

  // Print welcome message
  rvx_uart_write_string(RVX_UART_ADDRESS, "RVX Timer Example Project\n\n");
  rvx_uart_write_string(RVX_UART_ADDRESS, "LED 0 state will be toggled by the timer every second.\n");

  // Configure pin 0 as output
  rvx_gpio_pin_configure(RVX_GPIO_ADDRESS, 0, RVX_GPIO_OUTPUT);

  // LEF initial state
  bool led_state = true;                              // true = ON, false = OFF
  rvx_gpio_pin_write(RVX_GPIO_ADDRESS, 0, led_state); // Turn LED 0 ON initially

  // Configure the machine timer to generate an interrupt every second
  rvx_timer_disable(RVX_TIMER_ADDRESS);               // Disable while configuring is in progress
  rvx_timer_set_compare(RVX_TIMER_ADDRESS, 12000000); // Assuming CPU frequency is 12 MHz
  rvx_timer_clear_counter(RVX_TIMER_ADDRESS);

  // Enable vectored interrupts and timer interrupt
  rvx_irq_enable_vectored_mode();
  rvx_irq_enable(RVX_IRQ_TIMER_BITMASK); // Enable M-mode Timer Interrupt specifically
  rvx_irq_enable_global();               // Set global interrupt enable bit

  // Start counting the time
  rvx_timer_enable(RVX_TIMER_ADDRESS);

  // Wait for a timer interrupt
  rvx_wait_for_interrupt();
}

// Provides a custom Machine Timer Interrupt Handler
RVX_TRAP_HANDLER_M(rvx_trap_handler_timer_irq)
{
  // Read LED 0 state and toggle it
  bool led_state = rvx_gpio_pin_read(RVX_GPIO_ADDRESS, 0);
  rvx_gpio_pin_write(RVX_GPIO_ADDRESS, 0, !led_state);

  // Clear the timer counter to restart counting from zero
  rvx_timer_clear_counter(RVX_TIMER_ADDRESS);
}