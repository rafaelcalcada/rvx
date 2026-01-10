// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include "rvx_hal_gpio_test.h"
#include "rvx_hal_spi_manager_test.h"
#include "rvx_hal_test_utils.h"
#include "rvx_hal_timer_test.h"
#include "rvx_hal_uart_test.h"

int main()
{
  run_rvx_hal_uart_test();
  run_rvx_hal_gpio_test();
  run_rvx_hal_spi_manager_test();
  run_rvx_hal_timer_test();

  if (rvx_test_global_error_flag)
    rvx_uart_write_string(rvx_test_uart_address,
                          "\n(ERROR) Some RVX HAL integration tests failed. Check the output for details.");
  else
    rvx_uart_write_string(rvx_test_uart_address, "\nPassed all RVX HAL integration tests.");

  rvx_uart_write_string(rvx_test_uart_address, "\n\n");

  uint32_t *sigstart = (uint32_t *)0x00000004;
  uint32_t *sigend = (uint32_t *)0x00000008;
  uint32_t *tohost = (uint32_t *)0x00000000;
  *sigstart = 0x0;
  *sigend = 0x0;
  *tohost = 1;
  while (1)
    ;
}