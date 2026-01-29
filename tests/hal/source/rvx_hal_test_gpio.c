// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx.h"
#include "rvx_hal_test_helpers.h"

/// @brief Run RVX HAL GPIO integration tests.
void run_rvx_hal_gpio_test()
{
  RvxGpio *rvx_gpio_address = RVX_GPIO_ADDRESS;
  unsigned int gpio_tests_error_count = 0;

  rvx_uart_init(RVX_UART_ADDRESS, 1000000, 50000000);
  rvx_uart_write_string(RVX_UART_ADDRESS, "\nRVX HAL - GPIO integration tests\n--------------------------------\n");

  rvx_test_start("\nTest 1: GPIO OUTPUT register is 0 after reset. ");
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_REG == 0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 2: GPIO OUTPUT ENABLE register is 0 after reset. ");
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 3: GPIO READ register is 0 after reset. ");
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_READ_REG == 0xa5a5a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 4: Configure a pin as output. ");
  rvx_gpio_pin_configure(RVX_GPIO_ADDRESS, 2, RVX_GPIO_OUTPUT);
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0x4);
  RVX_TEST_ASSERT(rvx_gpio_pin_read(RVX_GPIO_ADDRESS, 2) == false);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 5: Configure the same pin as input. ");
  rvx_gpio_pin_configure(RVX_GPIO_ADDRESS, 2, RVX_GPIO_INPUT);
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0x0);
  RVX_TEST_ASSERT(rvx_gpio_pin_read(RVX_GPIO_ADDRESS, 2) == true);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 6: Configure multiple pins as output. ");
  rvx_gpio_configure_all(RVX_GPIO_ADDRESS, 0xF00FF00F);
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0xF00FF00F);
  RVX_TEST_ASSERT(rvx_gpio_read_all(RVX_GPIO_ADDRESS) == 0x05a005a0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 7: Configure multiple pins as inputs. ");
  rvx_gpio_configure_all(RVX_GPIO_ADDRESS, 0xF00F0000);
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0xF00F0000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(RVX_GPIO_ADDRESS) == 0x05a0a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 8: Write value (1) to an output pin. ");
  rvx_gpio_pin_write(RVX_GPIO_ADDRESS, 16, true);
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_REG == 0x00010000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(RVX_GPIO_ADDRESS) == 0x05a1a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 9: Clear (write 0) the same output pin. ");
  rvx_gpio_pin_clear(RVX_GPIO_ADDRESS, 16);
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_REG == 0x00000000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(RVX_GPIO_ADDRESS) == 0x05a0a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 10: Set (write 1) the same output pin. ");
  rvx_gpio_pin_set(RVX_GPIO_ADDRESS, 16);
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_REG == 0x00010000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(RVX_GPIO_ADDRESS) == 0x05a1a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 11: Write values (0xf0000000) to multiple output pins. ");
  rvx_gpio_write_all(RVX_GPIO_ADDRESS, 0xf0000000);
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_REG == 0xf0000000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(RVX_GPIO_ADDRESS) == 0xf5a0a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 12: Clear (0xf0000000) multiple output pins. ");
  rvx_gpio_multi_pin_clear(RVX_GPIO_ADDRESS, 0xf0000000);
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_REG == 0x00000000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(RVX_GPIO_ADDRESS) == 0x05a0a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  rvx_test_start("\nTest 13: Set (0xf0000000) multiple output pins. ");
  rvx_gpio_multi_pin_set(RVX_GPIO_ADDRESS, 0xf0000000);
  RVX_TEST_ASSERT(rvx_gpio_address->RVX_GPIO_OUTPUT_REG == 0xf0000000);
  RVX_TEST_ASSERT(rvx_gpio_read_all(RVX_GPIO_ADDRESS) == 0xf5a0a5a5);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&gpio_tests_error_count);

  const char *error_msg = "\n\nERROR: Some RVX HAL integration tests for the GPIO module failed. "
                          "Check the test output for details.\n";
  const char *success_msg = "\n\nRVX HAL GPIO tests: All tests passed successfully.\n";

  if (gpio_tests_error_count)
    rvx_uart_write_string(RVX_UART_ADDRESS, error_msg);
  else
    rvx_uart_write_string(RVX_UART_ADDRESS, success_msg);
}