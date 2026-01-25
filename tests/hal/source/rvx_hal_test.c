// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include "rvx_hal_test_helpers.h"

extern void run_rvx_hal_uart_test();
extern void run_rvx_hal_gpio_test();
extern void run_rvx_hal_spi_manager_test();
extern void run_rvx_hal_timer_test();

int main()
{
  run_rvx_hal_uart_test();
  run_rvx_hal_gpio_test();
  run_rvx_hal_spi_manager_test();
  run_rvx_hal_timer_test();

  const char *error_msg = "\nERROR: Some RVX HAL integration tests failed. Check the test output for details.\n\n";
  const char *success_msg = "\nPassed all RVX HAL integration tests.\n\n";

  if (rvx_test_global_error_flag)
    rvx_uart_write_string(RVX_UART_ADDRESS, error_msg);
  else
    rvx_uart_write_string(RVX_UART_ADDRESS, success_msg);

  // Signal to simulator that tests are complete and whether they passed or failed
  *((uint32_t *)0x00000000) = rvx_test_global_error_flag;
}