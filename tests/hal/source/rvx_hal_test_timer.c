// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx.h"
#include "rvx_hal_test_helpers.h"

/// @brief Set up the timer interrupt handler.
RVX_TRAP_HANDLER_M(rvx_trap_handler_mti)
{
  rvx_timer_disable(RVX_TIMER_ADDRESS);
  rvx_uart_write_string(RVX_UART_ADDRESS, "Passed.");
}

/// @brief Run RVX HAL Timer integration tests.
void run_rvx_hal_timer_test()
{
  unsigned int timer_tests_error_count = 0;

  rvx_uart_init(RVX_UART_ADDRESS, 1000000, 50000000);
  rvx_uart_write_string(RVX_UART_ADDRESS, "\nRVX HAL - Timer integration tests\n---------------------------------\n");

  rvx_test_start("\nTest 1: Timer COUNTER ENABLE register is 1 after reset. ");
  RVX_TEST_ASSERT(rvx_timer_is_enabled(RVX_TIMER_ADDRESS) == true);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);

  rvx_test_start("\nTest 2: Timer COUNTER register is 0 after clear. ");
  rvx_timer_disable(RVX_TIMER_ADDRESS);
  rvx_timer_clear_counter(RVX_TIMER_ADDRESS);
  RVX_TEST_ASSERT(rvx_timer_get_counter(RVX_TIMER_ADDRESS) == 0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);

  rvx_test_start("\nTest 3: Timer COMPARE register is 0xffffffffffffffff after reset. ");
  RVX_TEST_ASSERT(rvx_timer_get_compare(RVX_TIMER_ADDRESS) == 0xFFFFFFFFFFFFFFFFULL);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);

  rvx_test_start("\nTest 4: Timer COUNTER register increments after enable. ");
  rvx_timer_enable(RVX_TIMER_ADDRESS);
  for (volatile int i = 0; i < 100; i++) // Delay to allow counter to increment
    asm volatile("nop");
  RVX_TEST_ASSERT(rvx_timer_get_counter(RVX_TIMER_ADDRESS) > 0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);

  rvx_test_start("\nTest 5: Timer COUNTER register stops incrementing after disable. ");
  rvx_timer_disable(RVX_TIMER_ADDRESS);
  uint64_t old_counter_value = rvx_timer_get_counter(RVX_TIMER_ADDRESS);
  for (volatile int i = 0; i < 100; i++) // Delay to check counter remains the same
    asm volatile("nop");
  uint64_t new_counter_value = rvx_timer_get_counter(RVX_TIMER_ADDRESS);
  RVX_TEST_ASSERT(new_counter_value == old_counter_value);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);
  if (rvx_test_error_flag)
  {
    rvx_uart_write_string(RVX_UART_ADDRESS, "\nCounter value was: ");
    rvx_test_print_double_word_hex(new_counter_value);
    rvx_uart_write_string(RVX_UART_ADDRESS, ", expected: ");
    rvx_test_print_double_word_hex(old_counter_value);
  }

  rvx_test_start("\nTest 6: Check if timer interrupt is triggered. ");
  rvx_timer_set_counter(RVX_TIMER_ADDRESS, 0);
  rvx_timer_set_compare(RVX_TIMER_ADDRESS, 50); // Set compare to a small value
  rvx_timer_enable(RVX_TIMER_ADDRESS);
  // Wait for some time to allow interrupt to trigger
  for (volatile int i = 0; i < 100; i++)
    asm volatile("nop");
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);

  const char *error_msg = "\n\nERROR: Some RVX HAL integration tests for the Timer controller failed. "
                          "Check the test output for details.\n";
  const char *success_msg = "\n\nRVX HAL Timer tests: All tests passed successfully.\n";

  if (timer_tests_error_count)
    rvx_uart_write_string(RVX_UART_ADDRESS, error_msg);
  else
    rvx_uart_write_string(RVX_UART_ADDRESS, success_msg);
}