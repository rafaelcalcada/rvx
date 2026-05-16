// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// Pointer to the GPIO controller registers.
RvxGpioRegs *gpio_controller = (RvxGpioRegs *)RVX_GPIO_CONTROLLER_ADDRESS;

void main(void)
{
  // Initialize UART at 9600 baud (assuming clock frequency is 12 MHz)
  rvx_uart_init(RVX_UART_ADDRESS, 9600, 12000000);

  // Print welcome message
  rvx_uart_send_string(RVX_UART_ADDRESS, "RVX Timer Example Project\n\n");
  rvx_uart_send_string(RVX_UART_ADDRESS, "LED 0 state will be toggled by the timer every second.\n");

  // Configure pin 0 as output
  rvx_gpio_pin_mode(gpio_controller, 0, RVX_GPIO_OUTPUT);

  // Light up the LED initially
  rvx_gpio_pin_write(gpio_controller, 0, RVX_GPIO_HIGH);

  // Configure the machine timer to generate an interrupt every 1 second
  rvx_timer_stop(RVX_TIMER_ADDRESS);                  // Make sure the timer is stopped before configuring
  rvx_timer_set_compare(RVX_TIMER_ADDRESS, 12000000); // Assuming CPU frequency is 12 MHz
  rvx_timer_set_counter(RVX_TIMER_ADDRESS, 0);        // Reset counter to 0 before starting

  // Enable vectored interrupt mode and timer interrupts in M-mode, then globally enable interrupts in M-mode
  rvx_irq_set_mode(RVX_PRIVILEGE_LEVEL_M, RVX_INTERRUPT_MODE_VECTORED);
  rvx_irq_enable(RVX_PRIVILEGE_LEVEL_M, RVX_IRQ_TIMER_BITMASK);
  rvx_irq_enable_global(RVX_PRIVILEGE_LEVEL_M);

  // Start counting the time
  rvx_timer_start(RVX_TIMER_ADDRESS);

  // Wait for a timer interrupt
  rvx_wait_for_interrupt();
}

// Provides a custom interrupt handler for timer interrupts in M-mode.
RVX_TRAP_HANDLER_M(rvx_trap_handler_timer_m)
{
  // Read LED 0 state and toggle it
  RvxGpioPinState led_state = rvx_gpio_pin_read(gpio_controller, 0);
  rvx_gpio_pin_write(gpio_controller, 0, !led_state);

  // Set the timer counter back to 0 to restart the timer for the next interrupt
  rvx_timer_set_counter(RVX_TIMER_ADDRESS, 0);
}