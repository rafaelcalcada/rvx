// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx.h"

RvxUart *uart_address = (RvxUart *)0x80000000;
RvxGpio *gpio_address = (RvxGpio *)0x80020000;
int error_count = 0;
int error_flag = 0;

#define STRINGIFY(x) #x
#define MACRO_STRINGIFY(x) STRINGIFY(x)
#define RVX_ASSERT(condition)                                                                                          \
  rvx_assert(condition, "\n[ERROR] Assertion at line " MACRO_STRINGIFY(__LINE__) " failed.");

void rvx_assert(bool condition, const char *message);
void print_word(const uint32_t read_data);
void finish_test();

int main()
{
  rvx_uart_init(uart_address, 5208); // 50 MHz / 9600 baud = 5208 cycles per baud
  rvx_uart_write_string(uart_address, "\nRunning RVX GPIO module HAL unit tests...\n");

  rvx_uart_write_string(uart_address, "\nTest 2: OUTPUT register is 0 after reset... ");
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_REG == 0);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 3: OUTPUT ENABLE register is 0 after reset... ");
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 4: Read all inputs... ");
  RVX_ASSERT(gpio_address->RVX_GPIO_INPUT_REG == 0xa5a5a5a5);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 5: Configure a pin as output... ");
  rvx_gpio_pin_configure(gpio_address, 2, RVX_GPIO_OUTPUT);
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0x4);
  RVX_ASSERT(rvx_gpio_pin_read(gpio_address, 2) == false);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 5: Configure the same pin as input... ");
  rvx_gpio_pin_configure(gpio_address, 2, RVX_GPIO_INPUT);
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0x0);
  RVX_ASSERT(rvx_gpio_pin_read(gpio_address, 2) == true);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 6: Configure multiple pins as output... ");
  rvx_gpio_configure_all(gpio_address, 0xF00FF00F);
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0xF00FF00F);
  RVX_ASSERT(rvx_gpio_read_all(gpio_address) == 0x05a005a0);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 7: Configure multiple pins as inputs... ");
  rvx_gpio_configure_all(gpio_address, 0xF00F0000);
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_ENABLE_REG == 0xF00F0000);
  RVX_ASSERT(rvx_gpio_read_all(gpio_address) == 0x05a0a5a5);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 8: Write value (1) to an output pin... ");
  rvx_gpio_pin_write(gpio_address, 16, true);
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_REG == 0x00010000);
  RVX_ASSERT(rvx_gpio_read_all(gpio_address) == 0x05a1a5a5);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 9: Clear (write 0) the same output pin... ");
  rvx_gpio_pin_clear(gpio_address, 16);
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_REG == 0x00000000);
  RVX_ASSERT(rvx_gpio_read_all(gpio_address) == 0x05a0a5a5);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 10: Set (write 1) the same output pin... ");
  rvx_gpio_pin_set(gpio_address, 16);
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_REG == 0x00010000);
  RVX_ASSERT(rvx_gpio_read_all(gpio_address) == 0x05a1a5a5);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 11: Write values (0xf0000000) to multiple output pins... ");
  rvx_gpio_write_all(gpio_address, 0xf0000000);
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_REG == 0xf0000000);
  RVX_ASSERT(rvx_gpio_read_all(gpio_address) == 0xf5a0a5a5);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 12: Clear (0xf0000000) multiple output pins... ");
  rvx_gpio_multi_pin_clear(gpio_address, 0xf0000000);
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_REG == 0x00000000);
  RVX_ASSERT(rvx_gpio_read_all(gpio_address) == 0x05a0a5a5);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 13: Set (0xf0000000) multiple output pins... ");
  rvx_gpio_multi_pin_set(gpio_address, 0xf0000000);
  RVX_ASSERT(gpio_address->RVX_GPIO_OUTPUT_REG == 0xf0000000);
  RVX_ASSERT(rvx_gpio_read_all(gpio_address) == 0xf5a0a5a5);
  finish_test();

  if (error_count == 0)
    rvx_uart_write_string(uart_address, "\n\nPassed all RVX HAL unit tests for the GPIO module.");
  else
    rvx_uart_write_string(uart_address,
                          "\n[ERROR] UART module failed on one or more unit tests. Please investigate.\n");

  while (1)
    ;
}

void rvx_assert(bool condition, const char *message)
{
  if (!condition)
  {
    rvx_uart_write_string(uart_address, message);
    error_count++;
    error_flag = 1;
  }
}

void print_word(const uint32_t read_data)
{
  for (int8_t i = 28; i >= 0; i -= 4)
  {
    uint8_t nibble = (read_data >> i) & 0x0F;
    char hex_char;
    if (nibble < 10)
      hex_char = '0' + nibble;
    else
      hex_char = 'A' + (nibble - 10);
    rvx_uart_write(uart_address, hex_char);
  }
}

void finish_test()
{
  if (error_flag == 0)
  {
    rvx_uart_write_string(uart_address, "Passed.");
  }
  error_flag = 0;
}