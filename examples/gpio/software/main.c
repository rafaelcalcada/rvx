// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "libsteel.h"

#define DEFAULT_GPIO (GpioController *)0x80020000

void main(void)
{
  gpio_set_output(DEFAULT_GPIO, 0);
  gpio_set_output(DEFAULT_GPIO, 1);
  gpio_set_input(DEFAULT_GPIO, 2);
  gpio_write(DEFAULT_GPIO, 0, HIGH);
  while (1)
  {
    uint32_t button_state = gpio_read(DEFAULT_GPIO, 2);
    gpio_write(DEFAULT_GPIO, 1, button_state);
  }
}
