// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "rvsteel_soc.h"

int main(void)
{
  gpio_enable_output(GPIO0, GPIO_PIN0_MASK);

  while (1)
  {
    gpio_toggle(GPIO0, GPIO_PIN0_MASK);
  }
}
