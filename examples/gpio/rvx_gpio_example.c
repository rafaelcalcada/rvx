// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

void main(void)
{
  // Pointer to the GPIO controller registers.
  RvxGpioRegs *gpio_controller = (RvxGpioRegs *)RVX_GPIO_CONTROLLER_ADDRESS;

  // Pointer to the UART controller registers.
  RvxUartRegs *uart_controller = (RvxUartRegs *)RVX_UART_CONTROLLER_ADDRESS;

  // Initialize UART at 9600 baud (assuming clock frequency is 12 MHz)
  rvx_uart_set_baud_rate(uart_controller, 9600, 12000000);

  // Print welcome message
  rvx_uart_send_string(uart_controller, "RVX GPIO Example Project\n\n");
  rvx_uart_send_string(uart_controller, "To toggle LED 0 state, press push-button 1.\n");

  // Configure pin 0 as output, pin 1 as input
  rvx_gpio_pin_mode(gpio_controller, 0, RVX_GPIO_OUTPUT);
  rvx_gpio_pin_mode(gpio_controller, 1, RVX_GPIO_INPUT);

  // Initial states
  RvxGpioPinState led_state = RVX_GPIO_HIGH;         // HIGH = ON, LOW = OFF
  rvx_gpio_pin_write(gpio_controller, 0, led_state); // Turn LED 0 ON initially
  RvxGpioPinState button_last_state = RVX_GPIO_LOW;  // Last read state of the push-button

  while (true)
  {
    // Read the current state of the push-button (pin 1)
    RvxGpioPinState button_current_state = rvx_gpio_pin_read(gpio_controller, 1);

    // Check for a rising edge (button pressed)
    if (button_current_state == RVX_GPIO_HIGH && button_last_state == RVX_GPIO_LOW)
    {
      // Toggle the LED state
      led_state = !led_state;

      // Update the LED (pin 0) based on the new state
      rvx_gpio_pin_write(gpio_controller, 0, led_state);
    }

    // Update the last button state
    button_last_state = button_current_state;
  }
}