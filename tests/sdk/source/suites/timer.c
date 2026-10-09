// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include "rvx_sdk_test_framework.h"

#define RVX_TIMER_DELAY_ITERATIONS 100

static volatile bool timer_interrupt_received;

static void timer_test_suite_set_up(RvxTestSuite *suite);
static void timer_test_delay(void);
static void timer_test_counter_enable_reset(RvxTestSuite *suite);
static void timer_test_set_counter(RvxTestSuite *suite);
static void timer_test_compare_reset(RvxTestSuite *suite);
static void timer_test_counter_increments(RvxTestSuite *suite);
static void timer_test_counter_stops(RvxTestSuite *suite);
static void timer_test_interrupt(RvxTestSuite *suite);

/// @brief Handle the machine timer interrupt during the timer test.
RVX_IRQ_HANDLER_M void rvx_irq_handler_timer_m(void)
{
  rvx_timer_stop_counter(RVX_TIMER0);
  rvx_timer_set_compare(RVX_TIMER0, 0xFFFFFFFFFFFFFFFFULL);
  timer_interrupt_received = true;
}

static void timer_test_suite_set_up(RvxTestSuite *suite)
{
  (void)suite;
  rvx_uart_set_baud_rate(RVX_UART0, RVX_TEST_UART_BAUD_RATE, RVX_TEST_CLOCK_FREQUENCY_HZ);
}

static void timer_test_delay(void)
{
  for (volatile unsigned int iteration = 0; iteration < RVX_TIMER_DELAY_ITERATIONS; iteration++)
    asm volatile("nop");
}

static void timer_test_counter_enable_reset(RvxTestSuite *suite)
{
  RVX_TEST_ASSERT(suite, rvx_timer_is_counting(RVX_TIMER0));
}

static void timer_test_set_counter(RvxTestSuite *suite)
{
  rvx_timer_stop_counter(RVX_TIMER0);
  rvx_timer_set_counter(RVX_TIMER0, 0x123456789ABCDEF0ULL);
  RVX_TEST_ASSERT_EQ(suite, rvx_timer_get_counter(RVX_TIMER0), 0x123456789ABCDEF0ULL);
}

static void timer_test_compare_reset(RvxTestSuite *suite)
{
  RVX_TEST_ASSERT_EQ(suite, rvx_timer_get_compare(RVX_TIMER0), 0xFFFFFFFFFFFFFFFFULL);
}

static void timer_test_counter_increments(RvxTestSuite *suite)
{
  rvx_timer_reset_counter(RVX_TIMER0);
  rvx_timer_start_counter(RVX_TIMER0);
  timer_test_delay();
  RVX_TEST_ASSERT(suite, rvx_timer_get_counter(RVX_TIMER0) > 0);
}

static void timer_test_counter_stops(RvxTestSuite *suite)
{
  rvx_timer_stop_counter(RVX_TIMER0);
  uint64_t expected_counter_value = rvx_timer_get_counter(RVX_TIMER0);
  timer_test_delay();
  RVX_TEST_ASSERT_EQ(suite, rvx_timer_get_counter(RVX_TIMER0), expected_counter_value);
}

static void timer_test_interrupt(RvxTestSuite *suite)
{
  timer_interrupt_received = false;
  rvx_timer_reset_counter(RVX_TIMER0);
  rvx_timer_set_compare(RVX_TIMER0, 50);
  rvx_irq_enable_m(RVX_IRQ_TIMER_BITMASK);
  rvx_irq_global_enable_m();
  rvx_timer_start_counter(RVX_TIMER0);
  timer_test_delay();
  rvx_irq_global_disable_m();
  rvx_irq_disable_m(RVX_IRQ_TIMER_BITMASK);
  RVX_TEST_ASSERT(suite, timer_interrupt_received);
}

static const RvxTestCase timer_test_cases[] = {
    {"Timer COUNTER ENABLE is set after reset.", timer_test_counter_enable_reset},
    {"Writing the COUNTER register stores the value.", timer_test_set_counter},
    {"Timer COMPARE has its reset value.", timer_test_compare_reset},
    {"The COUNTER register increments while running.", timer_test_counter_increments},
    {"The COUNTER register stops incrementing when stopped.", timer_test_counter_stops},
    {"The timer compare interrupt is delivered.", timer_test_interrupt},
};

const RvxTestSuiteDescriptor rvx_sdk_timer_test_suite = {
    .name = "RVX SDK - Timer tests",
    .test_cases = timer_test_cases,
    .test_case_count = RVX_ARRAY_SIZE(timer_test_cases),
    .set_up = timer_test_suite_set_up,
};