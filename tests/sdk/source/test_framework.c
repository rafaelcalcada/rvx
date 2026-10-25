// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx_sdk_test_framework.h"

static void rvx_test_print_unsigned(unsigned int value)
{
  char buffer[11];
  unsigned int index = sizeof(buffer) - 1;

  buffer[index] = '\0';
  do
  {
    buffer[--index] = (char)('0' + (value % 10));
    value /= 10;
  } while (value != 0);

  rvx_uart_print(RVX_UART0, &buffer[index]);
}

static void rvx_test_suite_start(RvxTestSuite *suite)
{
  suite->total_tests = 0;
  suite->failed_tests = 0;
  suite->current_test_failed = false;
  rvx_uart_print(RVX_UART0, "\n");
  rvx_uart_print(RVX_UART0, suite->name);
  rvx_uart_print(RVX_UART0, "\n--------------------------------\n");
}

static void rvx_test_case_run(RvxTestSuite *suite, const RvxTestCase *test_case)
{
  suite->total_tests++;
  suite->current_test_failed = false;

  rvx_uart_print(RVX_UART0, "\nTest ");
  rvx_test_print_unsigned(suite->total_tests);
  rvx_uart_print(RVX_UART0, ": ");
  rvx_uart_print(RVX_UART0, test_case->name);
  rvx_uart_print(RVX_UART0, " ");

  test_case->run(suite);

  if (suite->current_test_failed)
  {
    suite->failed_tests++;
    rvx_uart_print(RVX_UART0, "(Failed)");
    return;
  }

  rvx_uart_print(RVX_UART0, "(Passed)");
}

static void rvx_test_suite_report_result(const RvxTestSuite *suite)
{
  rvx_uart_print(RVX_UART0, "\n\n");
  rvx_uart_print(RVX_UART0, suite->name);
  rvx_uart_print(RVX_UART0, ": ");

  if (suite->failed_tests != 0)
  {
    rvx_test_print_unsigned(suite->failed_tests);
    rvx_uart_print(RVX_UART0, " of ");
    rvx_test_print_unsigned(suite->total_tests);
    rvx_uart_print(RVX_UART0, " tests failed.\n");
    return;
  }

  rvx_test_print_unsigned(suite->total_tests);
  rvx_uart_print(RVX_UART0, " tests passed.\n");
}

bool rvx_test_run_suite(const RvxTestSuiteDescriptor *descriptor)
{
  RvxTestSuite suite = {
      .name = descriptor->name,
      .context = descriptor->context,
  };

  if (descriptor->set_up != NULL)
    descriptor->set_up(&suite);

  rvx_test_suite_start(&suite);

  for (size_t index = 0; index < descriptor->test_case_count; index++)
    rvx_test_case_run(&suite, &descriptor->test_cases[index]);

  if (descriptor->tear_down != NULL)
    descriptor->tear_down(&suite);

  rvx_test_suite_report_result(&suite);
  return suite.failed_tests == 0;
}

bool rvx_test_run_suites(const RvxTestSuiteDescriptor *const descriptors[], const size_t descriptor_count)
{
  bool all_tests_passed = true;

  for (size_t index = 0; index < descriptor_count; index++)
  {
    if (!rvx_test_run_suite(descriptors[index]))
      all_tests_passed = false;
  }

  return all_tests_passed;
}

void rvx_test_assert(RvxTestSuite *suite, bool condition, const char *expression, unsigned int line)
{
  if (condition)
    return;

  rvx_uart_print(RVX_UART0, "\n  Assertion failed: ");
  rvx_uart_print(RVX_UART0, expression);
  rvx_uart_print(RVX_UART0, " (line ");
  rvx_test_print_unsigned(line);
  rvx_uart_print(RVX_UART0, ").");
  suite->current_test_failed = true;
}

void rvx_test_assert_eq(RvxTestSuite *suite, uint64_t actual, uint64_t expected, const char *actual_expression,
                        const char *expected_expression, unsigned int line)
{
  if (actual == expected)
    return;

  rvx_uart_print(RVX_UART0, "\n  Assertion failed: ");
  rvx_uart_print(RVX_UART0, actual_expression);
  rvx_uart_print(RVX_UART0, " == ");
  rvx_uart_print(RVX_UART0, expected_expression);
  rvx_uart_print(RVX_UART0, " (line ");
  rvx_test_print_unsigned(line);
  rvx_uart_print(RVX_UART0, ").\n    Expected: ");
  rvx_test_print_double_word_hex(expected);
  rvx_uart_print(RVX_UART0, "\n    Actual: ");
  rvx_test_print_double_word_hex(actual);
  rvx_uart_write(RVX_UART0, '\n');
  suite->current_test_failed = true;
}

/**
 * @brief Print a byte in hexadecimal format to the test UART.
 *
 * @param read_data The byte to print.
 */
void rvx_test_print_byte(const uint8_t read_data)
{
  uint8_t high_nibble = (read_data >> 4) & 0x0F;
  uint8_t low_nibble = read_data & 0x0F;
  char str_val[5];
  str_val[0] = '0';
  str_val[1] = 'x';
  str_val[2] = high_nibble < 10 ? high_nibble + '0' : high_nibble - 10 + 'a';
  str_val[3] = low_nibble < 10 ? low_nibble + '0' : low_nibble - 10 + 'a';
  str_val[4] = '\0';
  rvx_uart_print(RVX_UART0, str_val);
}

/**
 * @brief Print a 64-bit value in hexadecimal format to the test UART.
 *
 * @param value The 64-bit value to print.
 */
void rvx_test_print_double_word_hex(uint64_t value)
{
  const char hex_chars[] = "0123456789ABCDEF";
  char buffer[19];
  buffer[0] = '0';
  buffer[1] = 'x';
  for (int i = 0; i < 16; i++)
  {
    buffer[17 - i] = hex_chars[(value >> (i * 4)) & 0xF];
  }
  buffer[18] = '\0';
  rvx_uart_print(RVX_UART0, buffer);
}
