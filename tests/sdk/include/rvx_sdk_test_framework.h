// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#ifndef RVX_SDK_TEST_FRAMEWORK_H
#define RVX_SDK_TEST_FRAMEWORK_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "rvx.h"

typedef struct RvxTestSuite RvxTestSuite;

typedef void (*RvxTestFunction)(RvxTestSuite *suite);

typedef struct
{
  const char *name;
  RvxTestFunction run;
} RvxTestCase;

typedef struct
{
  const char *name;
  const RvxTestCase *test_cases;
  size_t test_case_count;
  RvxTestFunction set_up;
  RvxTestFunction tear_down;
  void *context;
} RvxTestSuiteDescriptor;

struct RvxTestSuite
{
  const char *name;
  unsigned int total_tests;
  unsigned int failed_tests;
  bool current_test_failed;
  void *context;
};

#define RVX_TEST_CLOCK_FREQUENCY_HZ 50000000U
#define RVX_TEST_UART_BAUD_RATE 1000000U

// Stringify `x`
#define STRINGIFY(x) #x

// Stringify `x` after macro expansion
#define MACRO_STRINGIFY(x) STRINGIFY(x)

// Return the number of elements in an array.
#define RVX_ARRAY_SIZE(array) (sizeof(array) / sizeof((array)[0]))

// Assert that `condition` is true.
#define RVX_TEST_ASSERT(suite, condition)                                                                              \
  do                                                                                                                   \
  {                                                                                                                    \
    rvx_test_assert((suite), (condition), STRINGIFY(condition), __LINE__);                                             \
  } while (0)

// Assert that `actual` equals `expected`, evaluating each expression once.
#define RVX_TEST_ASSERT_EQ(suite, actual, expected)                                                                    \
  do                                                                                                                   \
  {                                                                                                                    \
    const uint64_t actual_value = (uint64_t)(actual);                                                                  \
    const uint64_t expected_value = (uint64_t)(expected);                                                              \
    rvx_test_assert_eq((suite), actual_value, expected_value, STRINGIFY(actual), STRINGIFY(expected), __LINE__);       \
  } while (0)

/// @name RVX SDK Test Utility Functions
/// @{
bool rvx_test_run_suite(const RvxTestSuiteDescriptor *descriptor);
bool rvx_test_run_suites(const RvxTestSuiteDescriptor *const descriptors[], size_t descriptor_count);
void rvx_test_assert(RvxTestSuite *suite, bool condition, const char *expression, unsigned int line);
void rvx_test_assert_eq(RvxTestSuite *suite, uint64_t actual, uint64_t expected, const char *actual_expression,
                        const char *expected_expression, unsigned int line);
void rvx_test_print_byte(uint8_t value);
void rvx_test_print_double_word_hex(uint64_t value);
/// @}

#endif