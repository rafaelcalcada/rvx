// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// Stringify `x`
#define STRINGIFY(x) #x

// Stringify `x` after macro expansion
#define MACRO_STRINGIFY(x) STRINGIFY(x)

// Assert that `condition` is true; if not, print an error message with the line number.
#define RVX_TEST_ASSERT(condition)                                                                                     \
  rvx_test_assert(condition, "\n(ERROR) Assertion at line " MACRO_STRINGIFY(__LINE__) " failed.");

// Assert that `val1` equals `val2`; if not, print an error message with their actual values and the line number.
#define RVX_TEST_ASSERT_EQ(val1, val2)                                                                                 \
  rvx_test_assert_eq(                                                                                                  \
      val1, val2,                                                                                                      \
      "\n(ERROR) Assertion " STRINGIFY(val1) " == " STRINGIFY(val2) " at line " MACRO_STRINGIFY(__LINE__) " failed.");

// Base addresses of peripherals in the simulation environment
extern RvxUart *rvx_test_uart_address;
extern RvxTimer *rvx_test_timer_address;
extern RvxGpio *rvx_test_gpio_address;
extern RvxSpiManager *rvx_test_spi_manager_address;

// Global variables to track test errors
extern int rvx_test_error_flag;
extern int rvx_test_global_error_flag;

/// @name RVX HAL Test Utility Functions
/// @{
void rvx_test_assert(bool condition, const char *message);
void rvx_test_assert_eq(uint8_t val1, uint8_t val2, const char *message);
void rvx_test_print_byte(const uint8_t read_data);
void rvx_test_print_double_word_hex(const uint64_t value);
void rvx_test_start(const char *start_message);
void rvx_test_finish(const char *success_message);
void rvx_test_update_error_count(unsigned int *local_error_count);
/// @}