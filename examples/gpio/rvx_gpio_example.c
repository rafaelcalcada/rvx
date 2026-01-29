// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

void main(void)
{
  // Initialize UART at 9600 baud (assuming clock frequency is 12 MHz)
  rvx_uart_init(RVX_UART_ADDRESS, 9600, 12000000);

  // Print welcome message
  rvx_uart_write_string(RVX_UART_ADDRESS, "RVX GPIO Example Project\n\n");
  rvx_uart_write_string(RVX_UART_ADDRESS, "To toggle LED 0 state, press push-button 1.\n");

  // Configure pin 0 as output, pin 1 as input
  rvx_gpio_pin_configure(RVX_GPIO_ADDRESS, 0, RVX_GPIO_OUTPUT);
  rvx_gpio_pin_configure(RVX_GPIO_ADDRESS, 1, RVX_GPIO_INPUT);

  // Initial states
  bool led_state = true;                              // true = ON, false = OFF
  rvx_gpio_pin_write(RVX_GPIO_ADDRESS, 0, led_state); // Turn LED 0 ON initially
  bool button_last_state = false;                     // Last read state of the push-button

  while (1)
  {
    // Read the current state of the push-button (pin 1)
    bool button_current_state = rvx_gpio_pin_read(RVX_GPIO_ADDRESS, 1);

    // Check for a rising edge (button pressed)
    if (button_current_state && !button_last_state)
    {
      // Toggle the LED state
      led_state = !led_state;

      // Update the LED (pin 0) based on the new state
      rvx_gpio_pin_write(RVX_GPIO_ADDRESS, 0, led_state);
    }

    // Update the last button state
    button_last_state = button_current_state;
  }
}