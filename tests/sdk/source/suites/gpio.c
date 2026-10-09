// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include "rvx_sdk_test_framework.h"

static void gpio_test_suite_set_up(RvxTestSuite *suite)
{
  (void)suite;
  rvx_uart_set_baud_rate(RVX_UART0, RVX_TEST_UART_BAUD_RATE, RVX_TEST_CLOCK_FREQUENCY_HZ);
}

static void gpio_test_output_register_reset(RvxTestSuite *suite)
{
  RVX_TEST_ASSERT_EQ(suite, RVX_GPIO0->RVX_GPIO_OUTPUT_REG, 0);
}

static void gpio_test_output_enable_register_reset(RvxTestSuite *suite)
{
  RVX_TEST_ASSERT_EQ(suite, RVX_GPIO0->RVX_GPIO_OUTPUT_ENABLE_REG, 0);
}

static void gpio_test_read_register_reset(RvxTestSuite *suite)
{
  RVX_TEST_ASSERT_EQ(suite, RVX_GPIO0->RVX_GPIO_READ_REG, 0xa5a5a5a5);
}

static void gpio_test_pin_output_mode(RvxTestSuite *suite)
{
  rvx_gpio_pin_direction(RVX_GPIO0, 2, RVX_GPIO_OUTPUT);
  RVX_TEST_ASSERT_EQ(suite, RVX_GPIO0->RVX_GPIO_OUTPUT_ENABLE_REG, 0x4);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_pin_read(RVX_GPIO0, 2), RVX_GPIO_LOW);
}

static void gpio_test_pin_input_mode(RvxTestSuite *suite)
{
  rvx_gpio_pin_direction(RVX_GPIO0, 2, RVX_GPIO_INPUT);
  RVX_TEST_ASSERT_EQ(suite, RVX_GPIO0->RVX_GPIO_OUTPUT_ENABLE_REG, 0x0);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_pin_read(RVX_GPIO0, 2), RVX_GPIO_HIGH);
}

static void gpio_test_port_output_mode(RvxTestSuite *suite)
{
  rvx_gpio_port_direction(RVX_GPIO0, 0xF00FF00F);
  RVX_TEST_ASSERT_EQ(suite, RVX_GPIO0->RVX_GPIO_OUTPUT_ENABLE_REG, 0xF00FF00F);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_port_read(RVX_GPIO0), 0x05a005a0);
}

static void gpio_test_port_input_mode(RvxTestSuite *suite)
{
  rvx_gpio_port_direction(RVX_GPIO0, 0xF00F0000);
  RVX_TEST_ASSERT_EQ(suite, RVX_GPIO0->RVX_GPIO_OUTPUT_ENABLE_REG, 0xF00F0000);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_port_read(RVX_GPIO0), 0x05a0a5a5);
}

static void gpio_test_pin_write(RvxTestSuite *suite)
{
  rvx_gpio_pin_write(RVX_GPIO0, 16, RVX_GPIO_HIGH);
  RVX_TEST_ASSERT_EQ(suite, RVX_GPIO0->RVX_GPIO_OUTPUT_REG, 0x00010000);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_port_read(RVX_GPIO0), 0x05a1a5a5);
}

static void gpio_test_pin_clear(RvxTestSuite *suite)
{
  rvx_gpio_pin_clear(RVX_GPIO0, 16);
  RVX_TEST_ASSERT_EQ(suite, RVX_GPIO0->RVX_GPIO_OUTPUT_REG, 0x00000000);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_port_read(RVX_GPIO0), 0x05a0a5a5);
}

static void gpio_test_pin_set(RvxTestSuite *suite)
{
  rvx_gpio_pin_write(RVX_GPIO0, 16, RVX_GPIO_HIGH);
  RVX_TEST_ASSERT_EQ(suite, RVX_GPIO0->RVX_GPIO_OUTPUT_REG, 0x00010000);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_port_read(RVX_GPIO0), 0x05a1a5a5);
}

static void gpio_test_port_write(RvxTestSuite *suite)
{
  rvx_gpio_port_write(RVX_GPIO0, 0xf0000000);
  RVX_TEST_ASSERT_EQ(suite, RVX_GPIO0->RVX_GPIO_OUTPUT_REG, 0xf0000000);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_port_read(RVX_GPIO0), 0xf5a0a5a5);
}

static const RvxTestCase gpio_test_cases[] = {
    {"GPIO OUTPUT register is zero after reset.", gpio_test_output_register_reset},
    {"GPIO OUTPUT ENABLE register is zero after reset.", gpio_test_output_enable_register_reset},
    {"GPIO READ register has its reset value.", gpio_test_read_register_reset},
    {"Configure a pin as output.", gpio_test_pin_output_mode},
    {"Configure the same pin as input.", gpio_test_pin_input_mode},
    {"Configure multiple pins as outputs.", gpio_test_port_output_mode},
    {"Configure multiple pins as inputs.", gpio_test_port_input_mode},
    {"Write high to an output pin.", gpio_test_pin_write},
    {"Clear the same output pin.", gpio_test_pin_clear},
    {"Set the same output pin.", gpio_test_pin_set},
    {"Write a value to all output pins.", gpio_test_port_write},
};

const RvxTestSuiteDescriptor rvx_sdk_gpio_test_suite = {
    .name = "RVX SDK - GPIO tests",
    .test_cases = gpio_test_cases,
    .test_case_count = RVX_ARRAY_SIZE(gpio_test_cases),
    .set_up = gpio_test_suite_set_up,
};