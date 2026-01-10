// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx_hal_test_utils.h"

// Base addresses of peripherals in the simulation environment
RvxUart *rvx_test_uart_address = (RvxUart *)0x80000000;
RvxTimer *rvx_test_timer_address = (RvxTimer *)0x80010000;
RvxGpio *rvx_test_gpio_address = (RvxGpio *)0x80020000;
RvxSpiManager *rvx_test_spi_manager_address = (RvxSpiManager *)0x80030000;

/// @brief Global variables to track test errors
/// @{
int rvx_test_error_flag = 0;        ///< Local error flag for the current test
int rvx_test_global_error_flag = 0; ///< Global error flag for all tests
/// @}

/**
 * @brief Assert that a condition is true; if not, print an error message.
 *
 * If the condition is false, the provided error message is sent via test UART, and the global error
 * count and flag are updated accordingly.
 *
 * @param condition The condition to assert.
 * @param message The error message to print if the assertion fails.
 */
void rvx_test_assert(bool condition, const char *message)
{
  if (!condition)
  {
    rvx_uart_write_string(rvx_test_uart_address, message);
    rvx_test_error_flag = 1;
    rvx_test_global_error_flag = 1;
  }
}

/**
 * @brief Assert that two uint8_t values are equal; if not, print an error message with their actual values.
 *
 * If the values are not equal, the provided error message is sent via test UART along with the actual
 * values of `val1` and `val2`. The global error count and flag are updated accordingly.
 *
 * @param val1 The first value to compare.
 * @param val2 The second value to compare.
 * @param message The error message to print if the assertion fails.
 */
void rvx_test_assert_eq(uint8_t val1, uint8_t val2, const char *message)
{
  if (val1 != val2)
  {
    rvx_uart_write_string(rvx_test_uart_address, message);
    rvx_uart_write_string(rvx_test_uart_address, "\nLeft-hand value: ");
    rvx_test_print_byte(val1);
    rvx_uart_write_string(rvx_test_uart_address, "\nRight-hand value: ");
    rvx_test_print_byte(val2);
    rvx_uart_write(rvx_test_uart_address, '\n');
    rvx_test_error_flag = 1;
    rvx_test_global_error_flag = 1;
  }
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
  rvx_uart_write_string(rvx_test_uart_address, str_val);
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
  rvx_uart_write_string(rvx_test_uart_address, buffer);
}

/**
 * @brief Start a test by printing a message and resetting the local error flag.
 *
 * @param test_message The message to print at the start of the test.
 */
void rvx_test_start(const char *test_message)
{
  rvx_uart_write_string(rvx_test_uart_address, test_message);
  rvx_test_error_flag = 0;
}

/**
 * @brief Finish a test by printing `success_message` if no errors were flagged.
 */
void rvx_test_finish(const char *success_message)
{
  if (rvx_test_error_flag == 0)
  {
    rvx_uart_write_string(rvx_test_uart_address, success_message);
  }
}

/**
 * @brief Update the local error count based on the global error flag.
 *
 * Each set of tests maintains its own local error count. This function increments the local
 * error count if any assertion in the last test that was run failed.
 *
 * @param local_error_count Pointer to the local error count variable.
 */
void rvx_test_update_error_count(unsigned int *local_error_count)
{
  if (rvx_test_error_flag != 0)
    (*local_error_count)++;
}