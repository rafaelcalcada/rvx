// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include "rvx_sdk_test_framework.h"

static void transfer_test(RvxTestSuite *suite, RvxSpi *spi);

static void spi_test_suite_set_up(RvxTestSuite *suite)
{
  (void)suite;
  rvx_uart_set_baud_rate(RVX_UART0, RVX_TEST_UART_BAUD_RATE, RVX_TEST_CLOCK_FREQUENCY_HZ);
  rvx_gpio_pin_direction(RVX_GPIO0, 0, RVX_GPIO_OUTPUT);
  rvx_gpio_pin_write(RVX_GPIO0, 0, RVX_GPIO_HIGH);
}

static void spi_test_mode_reset(RvxTestSuite *suite)
{
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_MODE_REG, RVX_SPI_MODE_0);
}

static void spi_test_mode_one(RvxTestSuite *suite)
{
  rvx_spi_set_mode(RVX_SPI0, RVX_SPI_MODE_1);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_MODE_REG, RVX_SPI_MODE_1);
}

static void spi_test_mode_zero(RvxTestSuite *suite)
{
  rvx_spi_set_mode(RVX_SPI0, RVX_SPI_MODE_0);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_MODE_REG, RVX_SPI_MODE_0);
}

static void spi_test_internal_chip_select(RvxTestSuite *suite)
{
  rvx_spi_assert_cs(RVX_SPI0);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_CHIP_SELECT_REG, 0);
  rvx_spi_deassert_cs(RVX_SPI0);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_CHIP_SELECT_REG, 1);
}

static void spi_test_subordinate_zero_mode_zero(RvxTestSuite *suite)
{
  rvx_spi_set_mode(RVX_SPI0, RVX_SPI_MODE_0);
  rvx_spi_set_divider(RVX_SPI0, 50);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_DIVIDER_REG, 24);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_MODE_REG, RVX_SPI_MODE_0);
  rvx_spi_assert_cs(RVX_SPI0);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_CHIP_SELECT_REG, 0);
  transfer_test(suite, RVX_SPI0);
  rvx_spi_deassert_cs(RVX_SPI0);
}

static void spi_test_subordinate_one_mode_one(RvxTestSuite *suite)
{
  rvx_spi_set_mode(RVX_SPI0, RVX_SPI_MODE_1);
  rvx_spi_set_divider(RVX_SPI0, 50);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_DIVIDER_REG, 24);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_MODE_REG, RVX_SPI_MODE_1);
  rvx_gpio_pin_write(RVX_GPIO0, 0, RVX_GPIO_LOW);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_pin_read(RVX_GPIO0, 0), RVX_GPIO_LOW);
  transfer_test(suite, RVX_SPI0);
  rvx_gpio_pin_write(RVX_GPIO0, 0, RVX_GPIO_HIGH);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_pin_read(RVX_GPIO0, 0), RVX_GPIO_HIGH);
}

static void spi_test_subordinate_one_mode_two(RvxTestSuite *suite)
{
  rvx_spi_set_mode(RVX_SPI0, RVX_SPI_MODE_2);
  rvx_spi_set_divider(RVX_SPI0, 50);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_DIVIDER_REG, 24);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_MODE_REG, RVX_SPI_MODE_2);
  rvx_gpio_pin_write(RVX_GPIO0, 0, RVX_GPIO_LOW);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_pin_read(RVX_GPIO0, 0), RVX_GPIO_LOW);
  transfer_test(suite, RVX_SPI0);
  rvx_gpio_pin_write(RVX_GPIO0, 0, RVX_GPIO_HIGH);
  RVX_TEST_ASSERT_EQ(suite, rvx_gpio_pin_read(RVX_GPIO0, 0), RVX_GPIO_HIGH);
}

static void spi_test_subordinate_zero_mode_three(RvxTestSuite *suite)
{
  rvx_spi_set_mode(RVX_SPI0, RVX_SPI_MODE_3);
  rvx_spi_set_divider(RVX_SPI0, 50);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_DIVIDER_REG, 24);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_MODE_REG, RVX_SPI_MODE_3);
  rvx_spi_assert_cs(RVX_SPI0);
  RVX_TEST_ASSERT_EQ(suite, RVX_SPI0->RVX_SPI_CHIP_SELECT_REG, 0);
  transfer_test(suite, RVX_SPI0);
  rvx_spi_deassert_cs(RVX_SPI0);
}

static const RvxTestCase spi_test_cases[] = {
    {"SPI MODE register is MODE 0 after reset.", spi_test_mode_reset},
    {"Set the SPI MODE register to MODE 1.", spi_test_mode_one},
    {"Set the SPI MODE register back to MODE 0.", spi_test_mode_zero},
    {"Assert and deassert the SPI chip select.", spi_test_internal_chip_select},
    {"Transfer with subordinate 0 in MODE 0.", spi_test_subordinate_zero_mode_zero},
    {"Transfer with subordinate 1 in MODE 1.", spi_test_subordinate_one_mode_one},
    {"Transfer with subordinate 1 in MODE 2.", spi_test_subordinate_one_mode_two},
    {"Transfer with subordinate 0 in MODE 3.", spi_test_subordinate_zero_mode_three},
};

const RvxTestSuiteDescriptor rvx_sdk_spi_test_suite = {
    .name = "RVX SDK - SPI tests",
    .test_cases = spi_test_cases,
    .test_case_count = RVX_ARRAY_SIZE(spi_test_cases),
    .set_up = spi_test_suite_set_up,
};

static void transfer_test(RvxTestSuite *suite, RvxSpi *spi)
{
  uint8_t received_byte;

  RVX_TEST_ASSERT(suite, rvx_spi_ready(spi));
  rvx_spi_write(spi, 0xa5);
  RVX_TEST_ASSERT(suite, !rvx_spi_ready(spi));
  while (!rvx_spi_ready(spi))
    ;
  rvx_spi_write(spi, 0x5a);
  while (!rvx_spi_ready(spi))
    ;
  received_byte = rvx_spi_read(spi);
  RVX_TEST_ASSERT_EQ(suite, received_byte, 0xa5);

  received_byte = rvx_spi_transfer(spi, 0xff);
  RVX_TEST_ASSERT_EQ(suite, received_byte, 0x5a);
  received_byte = rvx_spi_transfer(spi, 0x00);
  RVX_TEST_ASSERT_EQ(suite, received_byte, 0xff);
  received_byte = rvx_spi_transfer(spi, 0x3c);
  RVX_TEST_ASSERT_EQ(suite, received_byte, 0x00);
  received_byte = rvx_spi_transfer(spi, 0xc3);
  RVX_TEST_ASSERT_EQ(suite, received_byte, 0x3c);
  received_byte = rvx_spi_transfer(spi, 0x00);
  RVX_TEST_ASSERT_EQ(suite, received_byte, 0xc3);
}