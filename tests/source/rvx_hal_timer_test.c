// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx_hal_timer_test.h"

/// @brief Set up the timer interrupt handler.
RVX_IRQ_HANDLER_M(mti_irq_handler)
{
  rvx_timer_disable(rvx_test_timer_address);
  rvx_uart_write_string(rvx_test_uart_address, "Passed.");
}

/// @brief Run RVX HAL Timer integration tests.
void run_rvx_hal_timer_test()
{
  // Track the number of failed tests locally
  unsigned int timer_tests_error_count = 0;

  rvx_uart_init(rvx_test_uart_address, 5208);
  rvx_uart_write_string(rvx_test_uart_address,
                        "\nRVX HAL - Timer integration tests\n---------------------------------\n");

  rvx_test_start("\nTest 1: Timer COUNTER ENABLE register is 0 after reset. ");
  RVX_TEST_ASSERT(rvx_timer_is_enabled(rvx_test_timer_address) == false);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);

  rvx_test_start("\nTest 2: Timer COUNTER register is 0 after reset. ");
  RVX_TEST_ASSERT(rvx_timer_get_counter(rvx_test_timer_address) == 0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);

  rvx_test_start("\nTest 3: Timer COMPARE register is 0xffffffffffffffff after reset. ");
  RVX_TEST_ASSERT(rvx_timer_get_compare(rvx_test_timer_address) == 0xFFFFFFFFFFFFFFFFULL);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);

  rvx_test_start("\nTest 4: Timer COUNTER register increments after enable. ");
  rvx_timer_enable(rvx_test_timer_address);
  for (volatile int i = 0; i < 100; i++) // Delay to allow counter to increment
    asm volatile("nop");
  RVX_TEST_ASSERT(rvx_timer_get_counter(rvx_test_timer_address) > 0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);

  rvx_test_start("\nTest 5: Timer COUNTER register stops incrementing after disable. ");
  rvx_timer_disable(rvx_test_timer_address);
  uint64_t old_counter_value = rvx_timer_get_counter(rvx_test_timer_address);
  for (volatile int i = 0; i < 100; i++) // Delay to check counter remains the same
    asm volatile("nop");
  uint64_t new_counter_value = rvx_timer_get_counter(rvx_test_timer_address);
  RVX_TEST_ASSERT(new_counter_value == old_counter_value);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);
  if (rvx_test_error_flag)
  {
    rvx_uart_write_string(rvx_test_uart_address, "\nCounter value was: ");
    rvx_test_print_double_word_hex(new_counter_value);
    rvx_uart_write_string(rvx_test_uart_address, ", expected: ");
    rvx_test_print_double_word_hex(old_counter_value);
  }

  rvx_test_start("\nTest 6: Check if timer interrupt is triggered. ");
  rvx_timer_set_counter(rvx_test_timer_address, 0);
  rvx_timer_set_compare(rvx_test_timer_address, 50); // Set compare to a small value
  rvx_timer_enable(rvx_test_timer_address);
  // Wait for some time to allow interrupt to trigger
  for (volatile int i = 0; i < 100; i++)
    asm volatile("nop");
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&timer_tests_error_count);

  if (timer_tests_error_count)
    rvx_uart_write_string(rvx_test_uart_address,
                          "\n\n(ERROR) Some RVX HAL Timer integration tests failed. Check the output for details.");
  else
    rvx_uart_write_string(rvx_test_uart_address, "\n\nPassed RVX HAL Timer integration tests.");

  rvx_uart_write_string(rvx_test_uart_address, "\n");
}