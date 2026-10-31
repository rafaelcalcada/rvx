// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// RVX setup configuration (adjust clock frequency if needed)
const RvxSetup rvx_setup = {.clock_frequency = 12000000U, .trap_handler = RVX_DEFAULT_TRAP_HANDLER};

void main(void)
{
  // RVX initialization
  rvx_init(&rvx_setup);

  // Initialize UART at 9600 baud per second
  rvx_uart_set_baud_rate(RVX_UART0, 9600U);

  // Print welcome message
  rvx_uart_print(RVX_UART0, "RVX GPIO Example Project\n\n");
  rvx_uart_print(RVX_UART0, "Press push-button 1 to toggle LED 0 on/off.\n");

  // Configure pin 0 (LED 1) as output, pin 1 (push-button 1) as input
  rvx_gpio_pin_direction(RVX_GPIO0, 0, RVX_GPIO_OUTPUT);
  rvx_gpio_pin_direction(RVX_GPIO0, 1, RVX_GPIO_INPUT);

  // Turn LED 0 ON initially
  RvxGpioPinLevel led_level = RVX_GPIO_HIGH;
  rvx_gpio_pin_write(RVX_GPIO0, 0, led_level);

  while (true)
  {
    // Wait the push-button to be pressed
    while (rvx_gpio_pin_read(RVX_GPIO0, 1) == RVX_GPIO_LOW)
      ;

    // Toggle LED state
    led_level = (led_level == RVX_GPIO_HIGH) ? RVX_GPIO_LOW : RVX_GPIO_HIGH;
    rvx_gpio_pin_write(RVX_GPIO0, 0, led_level);

    // Wait the push-button to be released
    while (rvx_gpio_pin_read(RVX_GPIO0, 1) == RVX_GPIO_HIGH)
      ;
  }
}