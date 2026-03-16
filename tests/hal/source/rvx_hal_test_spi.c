// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx.h"
#include "rvx_hal_test_helpers.h"

void transfer_test();

void run_rvx_hal_spi_test()
{
  RvxSpi *rvx_spi_address = RVX_SPI_ADDRESS;
  unsigned int spi_tests_error_count = 0;

  rvx_uart_init(RVX_UART_ADDRESS, 1000000, 50000000);
  rvx_uart_send_string(RVX_UART_ADDRESS,
                       "\nRVX HAL - SPI integration tests\n---------------------------------------\n");

  rvx_gpio_set_direction(RVX_GPIO_ADDRESS, 0, RVX_GPIO_OUTPUT); // Use GPIO pin 0 as CS for subordinate 1
  rvx_gpio_set_high(RVX_GPIO_ADDRESS, 0);                       // Deassert CS for subordinate 1

  rvx_test_start("\nTest 1: SPI MODE register value is 0 after reset. ");
  RVX_TEST_ASSERT(rvx_spi_mode_get(RVX_SPI_ADDRESS) == RVX_SPI_MODE_0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 2: Setting SPI MODE register value to 1 succeeds. ");
  rvx_spi_mode_set(RVX_SPI_ADDRESS, RVX_SPI_MODE_1);
  RVX_TEST_ASSERT(rvx_spi_mode_get(RVX_SPI_ADDRESS) == RVX_SPI_MODE_1);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 3: Setting SPI MODE register value back to 0 succeeds. ");
  rvx_spi_mode_set(RVX_SPI_ADDRESS, RVX_SPI_MODE_0);
  RVX_TEST_ASSERT(rvx_spi_mode_get(RVX_SPI_ADDRESS) == RVX_SPI_MODE_0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 4: Assert/deassert SPI chip select pin. ");
  rvx_spi_chip_select_assert(RVX_SPI_ADDRESS);
  RVX_TEST_ASSERT(rvx_spi_address->RVX_SPI_CHIP_SELECT == 0);
  rvx_spi_chip_select_deassert(RVX_SPI_ADDRESS);
  RVX_TEST_ASSERT(rvx_spi_address->RVX_SPI_CHIP_SELECT == 1);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 5: Transfering bytes to SPI Subordinate 0 in MODE 0. ");
  rvx_spi_chip_select_assert(RVX_SPI_ADDRESS);
  rvx_spi_clock_set_divider(RVX_SPI_ADDRESS, 24);
  RVX_TEST_ASSERT(rvx_spi_clock_get_divider(RVX_SPI_ADDRESS) == 24);
  rvx_spi_mode_set(RVX_SPI_ADDRESS, RVX_SPI_MODE_0);
  RVX_TEST_ASSERT(rvx_spi_mode_get(RVX_SPI_ADDRESS) == RVX_SPI_MODE_0);
  rvx_spi_chip_select_assert(RVX_SPI_ADDRESS);
  RVX_TEST_ASSERT(rvx_spi_address->RVX_SPI_CHIP_SELECT == 0);
  transfer_test();
  rvx_spi_chip_select_deassert(RVX_SPI_ADDRESS);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 6: Transfering bytes to SPI Subordinate 1 in MODE 1. ");
  rvx_spi_chip_select_assert(RVX_SPI_ADDRESS);
  rvx_spi_clock_set_divider(RVX_SPI_ADDRESS, 24);
  RVX_TEST_ASSERT(rvx_spi_clock_get_divider(RVX_SPI_ADDRESS) == 24);
  rvx_spi_mode_set(RVX_SPI_ADDRESS, RVX_SPI_MODE_1);
  RVX_TEST_ASSERT(rvx_spi_mode_get(RVX_SPI_ADDRESS) == RVX_SPI_MODE_1);
  rvx_gpio_set_low(RVX_GPIO_ADDRESS, 0); // Assert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_read(RVX_GPIO_ADDRESS, 0) == false);
  transfer_test();
  rvx_gpio_set_high(RVX_GPIO_ADDRESS, 0); // Deassert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_read(RVX_GPIO_ADDRESS, 0) == true);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 7: Transfering bytes to SPI Subordinate 1 in MODE 2. ");
  rvx_spi_chip_select_assert(RVX_SPI_ADDRESS);
  rvx_spi_clock_set_divider(RVX_SPI_ADDRESS, 24);
  RVX_TEST_ASSERT(rvx_spi_clock_get_divider(RVX_SPI_ADDRESS) == 24);
  rvx_spi_mode_set(RVX_SPI_ADDRESS, RVX_SPI_MODE_2);
  RVX_TEST_ASSERT(rvx_spi_mode_get(RVX_SPI_ADDRESS) == RVX_SPI_MODE_2);
  rvx_gpio_set_low(RVX_GPIO_ADDRESS, 0); // Assert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_read(RVX_GPIO_ADDRESS, 0) == false);
  transfer_test();
  rvx_gpio_set_high(RVX_GPIO_ADDRESS, 0); // Deassert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_read(RVX_GPIO_ADDRESS, 0) == true);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 8: Transfering bytes to SPI Subordinate 0 in MODE 3. ");
  rvx_spi_chip_select_assert(RVX_SPI_ADDRESS);
  rvx_spi_clock_set_divider(RVX_SPI_ADDRESS, 24);
  RVX_TEST_ASSERT(rvx_spi_clock_get_divider(RVX_SPI_ADDRESS) == 24);
  rvx_spi_mode_set(RVX_SPI_ADDRESS, RVX_SPI_MODE_3);
  RVX_TEST_ASSERT(rvx_spi_mode_get(RVX_SPI_ADDRESS) == RVX_SPI_MODE_3);
  rvx_spi_chip_select_assert(RVX_SPI_ADDRESS);
  RVX_TEST_ASSERT(rvx_spi_address->RVX_SPI_CHIP_SELECT == 0);
  transfer_test();
  rvx_spi_chip_select_deassert(RVX_SPI_ADDRESS);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  const char *error_msg = "\n\nERROR: Some RVX HAL integration tests for the SPI controller failed. "
                          "Check the test output for details.\n";
  const char *success_msg = "\n\nRVX HAL SPI tests: All tests passed successfully.\n";

  if (spi_tests_error_count)
    rvx_uart_send_string(RVX_UART_ADDRESS, error_msg);
  else
    rvx_uart_send_string(RVX_UART_ADDRESS, success_msg);
}

void transfer_test()
{
  uint8_t received_byte;
  rvx_spi_write(RVX_SPI_ADDRESS, 0xa5);
  received_byte = rvx_spi_transfer(RVX_SPI_ADDRESS, 0x5a);
  RVX_TEST_ASSERT_EQ(received_byte, 0xa5);
  received_byte = rvx_spi_transfer(RVX_SPI_ADDRESS, 0xff);
  RVX_TEST_ASSERT_EQ(received_byte, 0x5a);
  received_byte = rvx_spi_transfer(RVX_SPI_ADDRESS, 0x00);
  RVX_TEST_ASSERT_EQ(received_byte, 0xff);
  received_byte = rvx_spi_transfer(RVX_SPI_ADDRESS, 0x3c);
  RVX_TEST_ASSERT_EQ(received_byte, 0x00);
  received_byte = rvx_spi_transfer(RVX_SPI_ADDRESS, 0xc3);
  RVX_TEST_ASSERT_EQ(received_byte, 0x3c);
  received_byte = rvx_spi_transfer(RVX_SPI_ADDRESS, 0x00);
  RVX_TEST_ASSERT_EQ(received_byte, 0xc3);
}