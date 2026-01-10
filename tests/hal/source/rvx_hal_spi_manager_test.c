// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx_hal_spi_manager_test.h"

void transfer_test();

void run_rvx_hal_spi_manager_test()
{
  // Track the number of failed tests locally
  unsigned int spi_manager_tests_error_count = 0;

  rvx_uart_init(rvx_test_uart_address, 5208);
  rvx_uart_write_string(rvx_test_uart_address,
                        "\nRVX HAL - SPI Manager integration tests\n---------------------------------------\n");

  rvx_gpio_pin_configure(rvx_test_gpio_address, 0, RVX_GPIO_OUTPUT); // Use GPIO pin 0 as CS for subordinate 1
  rvx_gpio_pin_set(rvx_test_gpio_address, 0);                        // Deassert CS for subordinate 1

  rvx_test_start("\nTest 1: SPI Manager MODE register value is 0 after reset. ");
  RVX_TEST_ASSERT(rvx_spi_mode_get(rvx_test_spi_manager_address) == RVX_SPI_MODE_0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_manager_tests_error_count);

  rvx_test_start("\nTest 2: Setting SPI Manager MODE register value to 1 succeeds. ");
  rvx_spi_mode_set(rvx_test_spi_manager_address, RVX_SPI_MODE_1);
  RVX_TEST_ASSERT(rvx_spi_mode_get(rvx_test_spi_manager_address) == RVX_SPI_MODE_1);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_manager_tests_error_count);

  rvx_test_start("\nTest 3: Setting SPI Manager MODE register value back to 0 succeeds. ");
  rvx_spi_mode_set(rvx_test_spi_manager_address, RVX_SPI_MODE_0);
  RVX_TEST_ASSERT(rvx_spi_mode_get(rvx_test_spi_manager_address) == RVX_SPI_MODE_0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_manager_tests_error_count);

  rvx_test_start("\nTest 4: Assert/deassert SPI Manager chip select. ");
  rvx_spi_chip_select_assert(rvx_test_spi_manager_address);
  RVX_TEST_ASSERT(rvx_test_spi_manager_address->RVX_SPI_CHIP_SELECT == 0);
  rvx_spi_chip_select_deassert(rvx_test_spi_manager_address);
  RVX_TEST_ASSERT(rvx_test_spi_manager_address->RVX_SPI_CHIP_SELECT == 1);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_manager_tests_error_count);

  rvx_test_start("\nTest 5: Transfering bytes to SPI Subordinate 0 in MODE 0. ");
  rvx_spi_chip_select_assert(rvx_test_spi_manager_address);
  rvx_spi_clock_set_divider(rvx_test_spi_manager_address,
                            24); // Set clock divider to 24 (equals 1 MHz if system clock is 50 MHz)
  RVX_TEST_ASSERT(rvx_spi_clock_get_divider(rvx_test_spi_manager_address) == 24);
  rvx_spi_mode_set(rvx_test_spi_manager_address, RVX_SPI_MODE_0);
  RVX_TEST_ASSERT(rvx_spi_mode_get(rvx_test_spi_manager_address) == RVX_SPI_MODE_0);
  rvx_spi_chip_select_assert(rvx_test_spi_manager_address);
  RVX_TEST_ASSERT(rvx_test_spi_manager_address->RVX_SPI_CHIP_SELECT == 0);
  transfer_test();
  rvx_spi_chip_select_deassert(rvx_test_spi_manager_address);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_manager_tests_error_count);

  rvx_test_start("\nTest 6: Transfering bytes to SPI Subordinate 1 in MODE 1. ");
  rvx_spi_chip_select_assert(rvx_test_spi_manager_address);
  rvx_spi_clock_set_divider(rvx_test_spi_manager_address,
                            24); // Set clock divider to 24 (equals 1 MHz if system clock is 50 MHz)
  RVX_TEST_ASSERT(rvx_spi_clock_get_divider(rvx_test_spi_manager_address) == 24);
  rvx_spi_mode_set(rvx_test_spi_manager_address, RVX_SPI_MODE_1);
  RVX_TEST_ASSERT(rvx_spi_mode_get(rvx_test_spi_manager_address) == RVX_SPI_MODE_1);
  rvx_gpio_pin_clear(rvx_test_gpio_address, 0); // Assert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_pin_read(rvx_test_gpio_address, 0) == false);
  transfer_test();
  rvx_gpio_pin_set(rvx_test_gpio_address, 0); // Deassert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_pin_read(rvx_test_gpio_address, 0) == true);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_manager_tests_error_count);

  rvx_test_start("\nTest 7: Transfering bytes to SPI Subordinate 1 in MODE 2. ");
  rvx_spi_chip_select_assert(rvx_test_spi_manager_address);
  rvx_spi_clock_set_divider(rvx_test_spi_manager_address,
                            24); // Set clock divider to 24 (equals 1 MHz if system clock is 50 MHz)
  RVX_TEST_ASSERT(rvx_spi_clock_get_divider(rvx_test_spi_manager_address) == 24);
  rvx_spi_mode_set(rvx_test_spi_manager_address, RVX_SPI_MODE_2);
  RVX_TEST_ASSERT(rvx_spi_mode_get(rvx_test_spi_manager_address) == RVX_SPI_MODE_2);
  rvx_gpio_pin_clear(rvx_test_gpio_address, 0); // Assert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_pin_read(rvx_test_gpio_address, 0) == false);
  transfer_test();
  rvx_gpio_pin_set(rvx_test_gpio_address, 0); // Deassert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_pin_read(rvx_test_gpio_address, 0) == true);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_manager_tests_error_count);

  rvx_test_start("\nTest 8: Transfering bytes to SPI Subordinate 0 in MODE 3. ");
  rvx_spi_chip_select_assert(rvx_test_spi_manager_address);
  rvx_spi_clock_set_divider(rvx_test_spi_manager_address,
                            24); // Set clock divider to 24 (equals 1 MHz if system clock is 50 MHz)
  RVX_TEST_ASSERT(rvx_spi_clock_get_divider(rvx_test_spi_manager_address) == 24);
  rvx_spi_mode_set(rvx_test_spi_manager_address, RVX_SPI_MODE_3);
  RVX_TEST_ASSERT(rvx_spi_mode_get(rvx_test_spi_manager_address) == RVX_SPI_MODE_3);
  rvx_spi_chip_select_assert(rvx_test_spi_manager_address);
  RVX_TEST_ASSERT(rvx_test_spi_manager_address->RVX_SPI_CHIP_SELECT == 0);
  transfer_test();
  rvx_spi_chip_select_deassert(rvx_test_spi_manager_address);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_manager_tests_error_count);

  if (spi_manager_tests_error_count)
    rvx_uart_write_string(
        rvx_test_uart_address,
        "\n\n(ERROR) Some RVX HAL SPI Manager integration tests failed. Check the output for details.");
  else
    rvx_uart_write_string(rvx_test_uart_address, "\n\nPassed RVX HAL SPI Manager integration tests.");

  rvx_uart_write_string(rvx_test_uart_address, "\n\n");
}

void transfer_test()
{
  uint8_t received_byte;
  rvx_spi_write(rvx_test_spi_manager_address, 0xa5);
  received_byte = rvx_spi_transfer(rvx_test_spi_manager_address, 0x5a);
  RVX_TEST_ASSERT_EQ(received_byte, 0xa5);
  received_byte = rvx_spi_transfer(rvx_test_spi_manager_address, 0xff);
  RVX_TEST_ASSERT_EQ(received_byte, 0x5a);
  received_byte = rvx_spi_transfer(rvx_test_spi_manager_address, 0x00);
  RVX_TEST_ASSERT_EQ(received_byte, 0xff);
  received_byte = rvx_spi_transfer(rvx_test_spi_manager_address, 0x3c);
  RVX_TEST_ASSERT_EQ(received_byte, 0x00);
  received_byte = rvx_spi_transfer(rvx_test_spi_manager_address, 0xc3);
  RVX_TEST_ASSERT_EQ(received_byte, 0x3c);
  received_byte = rvx_spi_transfer(rvx_test_spi_manager_address, 0x00);
  RVX_TEST_ASSERT_EQ(received_byte, 0xc3);
}