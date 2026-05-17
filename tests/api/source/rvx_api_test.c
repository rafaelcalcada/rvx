// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include "rvx_api_test_helpers.h"

extern void run_rvx_api_uart_test();
extern void run_rvx_api_gpio_test();
extern void run_rvx_api_spi_test();
extern void run_rvx_api_timer_test();

// Pointer to the UART controller registers.
RvxUartRegs *uart_controller = (RvxUartRegs *)RVX_UART_CONTROLLER_ADDRESS;

int main()
{
  run_rvx_api_uart_test();
  run_rvx_api_gpio_test();
  run_rvx_api_spi_test();
  run_rvx_api_timer_test();

  const char *error_msg = "\nERROR: Some RVX API integration tests failed. Check the test output for details.\n\n";
  const char *success_msg = "\nPassed all RVX API integration tests.\n\n";

  if (rvx_test_global_error_flag)
    rvx_uart_send_string(uart_controller, error_msg);
  else
    rvx_uart_send_string(uart_controller, success_msg);

  // Signal to simulator that tests are complete and whether they passed or failed
  *((uint32_t *)0x00000000) = rvx_test_global_error_flag;
}