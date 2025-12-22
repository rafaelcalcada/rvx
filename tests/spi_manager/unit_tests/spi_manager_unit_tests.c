// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx.h"

RvxUart *uart_address = (RvxUart *)0x80000000;
RvxGpio *gpio_address = (RvxGpio *)0x80020000;
RvxSpiManager *spi_address = (RvxSpiManager *)0x80030000;
int error_count = 0;
int error_flag = 0;

#define STRINGIFY(x) #x
#define MACRO_STRINGIFY(x) STRINGIFY(x)
#define ASSERT(condition) assert(condition, "\n[ERROR]Assertion at line " MACRO_STRINGIFY(__LINE__) " failed.");
#define ASSERT_EQ(val1, val2)                                                                                          \
  assert_eq(val1, val2, "\n[ERROR] Value of " STRINGIFY(val1) " is not equal to " STRINGIFY(val2) ".");

void assert(bool condition, const char *message);
void assert_eq(uint8_t val1, uint8_t val2, const char *message);
void print_byte(const uint8_t read_data);
void transfer_test();
void finish_test();

int main()
{
  rvx_uart_init(uart_address, 5208); // 50 MHz / 9600 baud = 5208 cycles per baud
  rvx_uart_write_string(uart_address, "\nRunning RVX SPI Manager HAL unit tests...\n");

  rvx_gpio_pin_configure(gpio_address, 0, RVX_GPIO_OUTPUT); // Use GPIO pin 0 as CS for subordinate 1
  rvx_gpio_pin_set(gpio_address, 0);                        // Deassert CS for subordinate 1

  rvx_uart_write_string(uart_address, "\nTest 1: MODE is 0 after reset... ");
  ASSERT(rvx_spi_mode_get(spi_address) == RVX_SPI_MODE_0);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 2: If setting MODE to 1 succeeds... ");
  rvx_spi_mode_set(spi_address, RVX_SPI_MODE_1);
  ASSERT(rvx_spi_mode_get(spi_address) == RVX_SPI_MODE_1);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 3: If setting MODE back to 0 succeeds... ");
  rvx_spi_mode_set(spi_address, RVX_SPI_MODE_0);
  ASSERT(rvx_spi_mode_get(spi_address) == RVX_SPI_MODE_0);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 4: Chip Select assert/deassert... ");
  rvx_spi_chip_select_assert(spi_address);
  ASSERT(spi_address->RVX_SPI_CHIP_SELECT == 0);
  rvx_spi_chip_select_deassert(spi_address);
  ASSERT(spi_address->RVX_SPI_CHIP_SELECT == 1);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 5: Transfering bytes to SPI Subordinate 0 in MODE 0... ");
  rvx_spi_chip_select_assert(spi_address);
  rvx_spi_clock_set_divider(spi_address, 24); // Set clock divider to 24 (equals 1 MHz if system clock is 50 MHz)
  ASSERT(rvx_spi_clock_get_divider(spi_address) == 24);
  rvx_spi_mode_set(spi_address, RVX_SPI_MODE_0);
  ASSERT(rvx_spi_mode_get(spi_address) == RVX_SPI_MODE_0);
  rvx_spi_chip_select_assert(spi_address);
  ASSERT(spi_address->RVX_SPI_CHIP_SELECT == 0);
  transfer_test();
  rvx_spi_chip_select_deassert(spi_address);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 6: Transfering bytes to SPI Subordinate 1 in MODE 1... ");
  rvx_spi_chip_select_assert(spi_address);
  rvx_spi_clock_set_divider(spi_address, 24); // Set clock divider to 24 (equals 1 MHz if system clock is 50 MHz)
  ASSERT(rvx_spi_clock_get_divider(spi_address) == 24);
  rvx_spi_mode_set(spi_address, RVX_SPI_MODE_1);
  ASSERT(rvx_spi_mode_get(spi_address) == RVX_SPI_MODE_1);
  rvx_gpio_pin_clear(gpio_address, 0); // Assert CS for subordinate 1
  ASSERT(rvx_gpio_pin_read(gpio_address, 0) == false);
  transfer_test();
  rvx_gpio_pin_set(gpio_address, 0); // Deassert CS for subordinate 1
  ASSERT(rvx_gpio_pin_read(gpio_address, 0) == true);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 7: Transfering bytes to SPI Subordinate 1 in MODE 2... ");
  rvx_spi_chip_select_assert(spi_address);
  rvx_spi_clock_set_divider(spi_address, 24); // Set clock divider to 24 (equals 1 MHz if system clock is 50 MHz)
  ASSERT(rvx_spi_clock_get_divider(spi_address) == 24);
  rvx_spi_mode_set(spi_address, RVX_SPI_MODE_2);
  ASSERT(rvx_spi_mode_get(spi_address) == RVX_SPI_MODE_2);
  rvx_gpio_pin_clear(gpio_address, 0); // Assert CS for subordinate 1
  ASSERT(rvx_gpio_pin_read(gpio_address, 0) == false);
  transfer_test();
  rvx_gpio_pin_set(gpio_address, 0); // Deassert CS for subordinate 1
  ASSERT(rvx_gpio_pin_read(gpio_address, 0) == true);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 8: Transfering bytes to SPI Subordinate 0 in MODE 3... ");
  rvx_spi_chip_select_assert(spi_address);
  rvx_spi_clock_set_divider(spi_address, 24); // Set clock divider to 24 (equals 1 MHz if system clock is 50 MHz)
  ASSERT(rvx_spi_clock_get_divider(spi_address) == 24);
  rvx_spi_mode_set(spi_address, RVX_SPI_MODE_3);
  ASSERT(rvx_spi_mode_get(spi_address) == RVX_SPI_MODE_3);
  rvx_spi_chip_select_assert(spi_address);
  ASSERT(spi_address->RVX_SPI_CHIP_SELECT == 0);
  transfer_test();
  rvx_spi_chip_select_deassert(spi_address);
  finish_test();

  if (error_count == 0)
    rvx_uart_write_string(uart_address, "\n\nPassed all RVX HAL unit tests for the SPI Manager.");
  else
    rvx_uart_write_string(uart_address,
                          "\n[ERROR] SPI Manager failed on one or more unit tests. Please investigate.\n");

  while (1)
    ;
}

void assert(bool condition, const char *message)
{
  if (!condition)
  {
    rvx_uart_write_string(uart_address, message);
    error_count++;
    error_flag = 1;
  }
}

void assert_eq(uint8_t val1, uint8_t val2, const char *message)
{
  if (val1 != val2)
  {
    rvx_uart_write_string(uart_address, message);
    print_byte(val1);
    error_count++;
    error_flag = 1;
  }
}

void print_byte(const uint8_t read_data)
{
  uint8_t high_nibble = (read_data >> 4) & 0x0F;
  uint8_t low_nibble = read_data & 0x0F;
  char str_val[5];
  str_val[0] = '0';
  str_val[1] = 'x';
  str_val[2] = high_nibble < 10 ? high_nibble + '0' : high_nibble - 10 + 'a';
  str_val[3] = low_nibble < 10 ? low_nibble + '0' : low_nibble - 10 + 'a';
  str_val[4] = '\0';
  rvx_uart_write_string(uart_address, "\nByte received: ");
  rvx_uart_write_string(uart_address, str_val);
  rvx_uart_write_string(uart_address, "\n");
}

void transfer_test()
{
  uint8_t received_byte;
  rvx_spi_write(spi_address, 0xa5);
  received_byte = rvx_spi_transfer(spi_address, 0x5a);
  ASSERT_EQ(received_byte, 0xa5);
  received_byte = rvx_spi_transfer(spi_address, 0xff);
  ASSERT_EQ(received_byte, 0x5a);
  received_byte = rvx_spi_transfer(spi_address, 0x00);
  ASSERT_EQ(received_byte, 0xff);
  received_byte = rvx_spi_transfer(spi_address, 0x3c);
  ASSERT_EQ(received_byte, 0x00);
  received_byte = rvx_spi_transfer(spi_address, 0xc3);
  ASSERT_EQ(received_byte, 0x3c);
  received_byte = rvx_spi_transfer(spi_address, 0x00);
  ASSERT_EQ(received_byte, 0xc3);
}

void finish_test()
{
  if (error_flag == 0)
  {
    rvx_uart_write_string(uart_address, "Passed.");
  }
  error_flag = 0;
}