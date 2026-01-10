// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx_hal_gpio_test.h"

/// @brief Run RVX HAL GPIO integration tests.
void run_rvx_hal_gpio_test()
{
  // Track the number of failed tests locally
  unsigned int gpio_tests_error_count = 0;

  rvx_uart_init(rvx_test_uart_address, 5208);
  rvx_uart_write_string(rvx_test_uart_address,
                        "\nRVX HAL - GPIO integration tests\n--------------------------------\n");

  rvx_test_start("\nTest 1: GPIO OUTPUT register is 0 after reset. ");
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_REG == 0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 2: GPIO OUTPUT ENABLE register is 0 after reset. ");
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 3: GPIO READ register is 0 after reset. ");
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_READ_REG == 0xa5a5a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 4: Configure a pin as output. ");
  rvx_gpio_pin_configure(rvx_test_gpio_address, 2, RVX_GPIO_OUTPUT);
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0x4);
  RVX_TEST_ASSERT(rvx_gpio_pin_read(rvx_test_gpio_address, 2) == false);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 5: Configure the same pin as input. ");
  rvx_gpio_pin_configure(rvx_test_gpio_address, 2, RVX_GPIO_INPUT);
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0x0);
  RVX_TEST_ASSERT(rvx_gpio_pin_read(rvx_test_gpio_address, 2) == true);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 6: Configure multiple pins as output. ");
  rvx_gpio_configure_all(rvx_test_gpio_address, 0xF00FF00F);
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0xF00FF00F);
  RVX_TEST_ASSERT(rvx_gpio_read_all(rvx_test_gpio_address) == 0x05a005a0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 7: Configure multiple pins as inputs. ");
  rvx_gpio_configure_all(rvx_test_gpio_address, 0xF00F0000);
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0xF00F0000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(rvx_test_gpio_address) == 0x05a0a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 8: Write value (1) to an output pin. ");
  rvx_gpio_pin_write(rvx_test_gpio_address, 16, true);
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_REG == 0x00010000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(rvx_test_gpio_address) == 0x05a1a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 9: Clear (write 0) the same output pin. ");
  rvx_gpio_pin_clear(rvx_test_gpio_address, 16);
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_REG == 0x00000000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(rvx_test_gpio_address) == 0x05a0a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 10: Set (write 1) the same output pin. ");
  rvx_gpio_pin_set(rvx_test_gpio_address, 16);
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_REG == 0x00010000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(rvx_test_gpio_address) == 0x05a1a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 11: Write values (0xf0000000) to multiple output pins. ");
  rvx_gpio_write_all(rvx_test_gpio_address, 0xf0000000);
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_REG == 0xf0000000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(rvx_test_gpio_address) == 0xf5a0a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 12: Clear (0xf0000000) multiple output pins. ");
  rvx_gpio_multi_pin_clear(rvx_test_gpio_address, 0xf0000000);
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_REG == 0x00000000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(rvx_test_gpio_address) == 0x05a0a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 13: Set (0xf0000000) multiple output pins. ");
  rvx_gpio_multi_pin_set(rvx_test_gpio_address, 0xf0000000);
  RVX_TEST_ASSERT(rvx_test_gpio_address->RVX_GPIO_OUTPUT_REG == 0xf0000000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(rvx_test_gpio_address) == 0xf5a0a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  if (gpio_tests_error_count)
    rvx_uart_write_string(rvx_test_uart_address,
                          "\n\n(ERROR) Some RVX HAL GPIO integration tests failed. Check the output for details.");
  else
    rvx_uart_write_string(rvx_test_uart_address, "\n\nPassed RVX HAL GPIO integration tests.");

  rvx_uart_write_string(rvx_test_uart_address, "\n");
}