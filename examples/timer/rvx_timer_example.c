// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// Pointer to the GPIO controller registers.
RvxGpioRegs *gpio_controller = (RvxGpioRegs *)RVX_GPIO_CONTROLLER_ADDRESS;

// Pointer to the UART controller registers.
RvxUartRegs *uart_controller = (RvxUartRegs *)RVX_UART_CONTROLLER_ADDRESS;

// Pointer to the timer controller registers.
RvxTimerRegs *timer_controller = (RvxTimerRegs *)RVX_TIMER_CONTROLLER_ADDRESS;

void main(void)
{
  // Initialize UART at 9600 baud (RVX clock is 12 MHz)
  rvx_uart_set_baud_rate(uart_controller, 9600, 12000000);

  // Print welcome message
  rvx_uart_send_string(uart_controller, "RVX Timer Example Project\n\n");
  rvx_uart_send_string(uart_controller, "LED 0 state will be toggled by the timer every second.\n");

  // Configure pin 0 as output
  rvx_gpio_pin_mode(gpio_controller, 0, RVX_GPIO_OUTPUT);

  // Light up the LED initially
  rvx_gpio_pin_write(gpio_controller, 0, RVX_GPIO_HIGH);

  // Configure the machine timer to generate an interrupt every 1 second
  rvx_timer_stop_counter(timer_controller);          // Make sure the timer is stopped before configuring
  rvx_timer_set_compare(timer_controller, 12000000); // Assuming CPU frequency is 12 MHz
  rvx_timer_reset_counter(timer_controller);         // Reset counter before starting the timer

  // Enable vectored interrupt mode
  rvx_irq_set_mode_m(RVX_IRQ_MODE_VECTORED);

  // Enable the timer interrupt
  rvx_irq_enable_m(RVX_IRQ_TIMER_BITMASK);

  // Enable interrupts globally in M-mode
  rvx_irq_enable_global_m();

  // Start counting the time
  rvx_timer_start_counter(timer_controller);

  // Wait for a timer interrupt
  while (1)
    ;
}

// Provides a trap handle for the timer interrupt
RVX_TRAP_HANDLER_M(rvx_trap_handler_timer_m)
{
  // Read LED 0 state and toggle it
  RvxGpioPinState led_state = rvx_gpio_pin_read(gpio_controller, 0);
  rvx_gpio_pin_write(gpio_controller, 0, !led_state);

  // Reset the timer counter
  rvx_timer_reset_counter(timer_controller);
}