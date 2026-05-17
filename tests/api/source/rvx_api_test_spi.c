// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx.h"
#include "rvx_api_test_helpers.h"

// Pointer to the UART controller registers.
extern RvxUartRegs *uart_controller;

// Pointer to the SPI controller registers.
RvxSpiRegs *spi_controller = (RvxSpiRegs *)RVX_SPI_CONTROLLER_ADDRESS;

// Pointer to the GPIO controller registers.
RvxGpioRegs *gpio_controller = (RvxGpioRegs *)RVX_GPIO_CONTROLLER_ADDRESS;

void transfer_test();

void run_rvx_api_spi_test()
{
  unsigned int spi_tests_error_count = 0;

  rvx_uart_set_baud_rate(uart_controller, 1000000, 50000000);
  rvx_uart_send_string(uart_controller, "\nRVX API - SPI integration tests\n---------------------------------------\n");

  rvx_gpio_pin_mode(gpio_controller, 0, RVX_GPIO_OUTPUT); // Use GPIO pin 0 as CS for subordinate 1
  rvx_gpio_pin_write(gpio_controller, 0, RVX_GPIO_HIGH);  // Deassert CS for subordinate 1

  rvx_test_start("\nTest 1: SPI MODE register value is 0 after reset. ");
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_MODE == RVX_SPI_MODE_0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 2: Setting SPI MODE register value to 1 succeeds. ");
  rvx_spi_set_mode(spi_controller, RVX_SPI_MODE_1);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_MODE == RVX_SPI_MODE_1);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 3: Setting SPI MODE register value back to 0 succeeds. ");
  rvx_spi_set_mode(spi_controller, RVX_SPI_MODE_0);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_MODE == RVX_SPI_MODE_0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 4: Assert/deassert SPI chip select pin. ");
  rvx_spi_assert_cs(spi_controller);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_CHIP_SELECT == 0);
  rvx_spi_deassert_cs(spi_controller);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_CHIP_SELECT == 1);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 5: Transfering bytes to SPI Subordinate 0 in MODE 0. ");
  rvx_spi_set_mode(spi_controller, RVX_SPI_MODE_0);
  rvx_spi_set_divider(spi_controller, 50);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_DIVIDER == 24);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_MODE == RVX_SPI_MODE_0);
  rvx_spi_assert_cs(spi_controller);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_CHIP_SELECT == 0);
  transfer_test();
  rvx_spi_deassert_cs(spi_controller);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 6: Transfering bytes to SPI Subordinate 1 in MODE 1. ");
  rvx_spi_set_mode(spi_controller, RVX_SPI_MODE_1);
  rvx_spi_set_divider(spi_controller, 50);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_DIVIDER == 24);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_MODE == RVX_SPI_MODE_1);
  rvx_gpio_pin_write(gpio_controller, 0, RVX_GPIO_LOW); // Assert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_pin_read(gpio_controller, 0) == RVX_GPIO_LOW);
  transfer_test();
  rvx_gpio_pin_write(gpio_controller, 0, RVX_GPIO_HIGH); // Deassert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_pin_read(gpio_controller, 0) == RVX_GPIO_HIGH);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 7: Transfering bytes to SPI Subordinate 1 in MODE 2. ");
  rvx_spi_set_mode(spi_controller, RVX_SPI_MODE_2);
  rvx_spi_set_divider(spi_controller, 50);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_DIVIDER == 24);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_MODE == RVX_SPI_MODE_2);
  rvx_gpio_pin_write(gpio_controller, 0, RVX_GPIO_LOW); // Assert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_pin_read(gpio_controller, 0) == RVX_GPIO_LOW);
  transfer_test();
  rvx_gpio_pin_write(gpio_controller, 0, RVX_GPIO_HIGH); // Deassert CS for subordinate 1
  RVX_TEST_ASSERT(rvx_gpio_pin_read(gpio_controller, 0) == RVX_GPIO_HIGH);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  rvx_test_start("\nTest 8: Transfering bytes to SPI Subordinate 0 in MODE 3. ");
  rvx_spi_set_mode(spi_controller, RVX_SPI_MODE_3);
  rvx_spi_set_divider(spi_controller, 50);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_DIVIDER == 24);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_MODE == RVX_SPI_MODE_3);
  rvx_spi_assert_cs(spi_controller);
  RVX_TEST_ASSERT(spi_controller->RVX_SPI_CHIP_SELECT == 0);
  transfer_test();
  rvx_spi_deassert_cs(spi_controller);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&spi_tests_error_count);

  const char *error_msg = "\n\nERROR: Some RVX API integration tests for the SPI controller failed. "
                          "Check the test output for details.\n";
  const char *success_msg = "\n\nRVX API SPI tests: All tests passed successfully.\n";

  if (spi_tests_error_count)
    rvx_uart_send_string(uart_controller, error_msg);
  else
    rvx_uart_send_string(uart_controller, success_msg);
}

void transfer_test()
{
  uint8_t received_byte;
  rvx_spi_transfer(spi_controller, 0xa5);
  received_byte = rvx_spi_transfer(spi_controller, 0x5a);
  RVX_TEST_ASSERT_EQ(received_byte, 0xa5);
  received_byte = rvx_spi_transfer(spi_controller, 0xff);
  RVX_TEST_ASSERT_EQ(received_byte, 0x5a);
  received_byte = rvx_spi_transfer(spi_controller, 0x00);
  RVX_TEST_ASSERT_EQ(received_byte, 0xff);
  received_byte = rvx_spi_transfer(spi_controller, 0x3c);
  RVX_TEST_ASSERT_EQ(received_byte, 0x00);
  received_byte = rvx_spi_transfer(spi_controller, 0xc3);
  RVX_TEST_ASSERT_EQ(received_byte, 0x3c);
  received_byte = rvx_spi_transfer(spi_controller, 0x00);
  RVX_TEST_ASSERT_EQ(received_byte, 0xc3);
}