// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "libsteel.h"
#include "stdint.h"

#define RVX_UART (UartController *)0x80000000
#define RVX_SPI (SpiController *)0x80030000

volatile uint32_t *__SPI_CPOL_ADDRESS = (volatile uint32_t *)0x80030000;
volatile uint32_t *__SPI_CPHA_ADDRESS = (volatile uint32_t *)0x80030004;
volatile uint32_t *__SPI_CS_ADDRESS = (volatile uint32_t *)0x80030008;
volatile uint32_t *__SPI_CLKDIV_ADDRESS = (volatile uint32_t *)0x8003000c;
volatile uint32_t *__SPI_WDATA_ADDRESS = (volatile uint32_t *)0x80030010;
volatile uint32_t *__SPI_RDATA_ADDRESS = (volatile uint32_t *)0x80030014;
volatile uint32_t *__SPI_STATUS_ADDRESS = (volatile uint32_t *)0x80030018;

// Test macros
#define STRINGIFY(x) #x
#define STRINGIFY_MACRO(x) STRINGIFY(x)
#define ASSERT_EQ(val1, val2)                                                                      \
  if (val1 != val2)                                                                                \
  {                                                                                                \
    uart_write_string(RVX_UART,                                                                    \
                      "[ERROR] Assertion at line " STRINGIFY_MACRO(__LINE__) " failed.");          \
    error_count++;                                                                                 \
  }

// Global variables
int error_count = 0;

void print_readout_value(const uint8_t rdata)
{
  uint8_t val = rdata;
  char str_val[4] = "xxx";
  for (int i = 1; i <= 3; i++)
  {
    str_val[3 - i] = (uint8_t)((val % 10UL) + '0');
    val /= 10;
  }
  str_val[3] = '\0';
  uart_write_string(RVX_UART, "Read out value is: ");
  uart_write_string(RVX_UART, str_val);
  uart_write_string(RVX_UART, "\n");
}

// Unit tests for the SPI Controller
int main()
{
  uart_write_string(RVX_UART, "SPI Controller Software Unit Tests\n\n");

  // Test #1
  // Check the default values of CPOL and CPHA (0 and 0, respectively)
  uart_write_string(RVX_UART, "Running test #1...\n");
  ASSERT_EQ(spi_get_cpol(RVX_SPI), 0);
  ASSERT_EQ(spi_get_cpha(RVX_SPI), 0);

  // Test #2
  // Check if CPOL and CPHA registers hold their values after write
  uart_write_string(RVX_UART, "Running test #2...\n");
  spi_set_cpol(RVX_SPI, 1);
  spi_set_cpha(RVX_SPI, 1);
  ASSERT_EQ(spi_get_cpol(RVX_SPI), 1);
  ASSERT_EQ(spi_get_cpha(RVX_SPI), 1);

  // Test #3
  // Check if restoring the value of CPOL and CPHA succeeds
  uart_write_string(RVX_UART, "Running test #3...\n");
  spi_set_cpol(RVX_SPI, 0);
  spi_set_cpha(RVX_SPI, 0);
  ASSERT_EQ(spi_get_cpol(RVX_SPI), 0);
  ASSERT_EQ(spi_get_cpha(RVX_SPI), 0);

  // Test #4
  // Check select/deselect CS lines
  uart_write_string(RVX_UART, "Running test #4...\n");
  spi_select(RVX_SPI, 0);
  ASSERT_EQ(spi_get_cs(RVX_SPI), 0);
  spi_deselect(RVX_SPI);
  ASSERT_EQ(spi_get_cs(RVX_SPI), 255);
  spi_select(RVX_SPI, 1);
  ASSERT_EQ(spi_get_cs(RVX_SPI), 1);
  spi_deselect(RVX_SPI);
  ASSERT_EQ(spi_get_cs(RVX_SPI), 255);

  // Test #5
  // Send/receive a byte to the dummy SPI peripheral in MODE 0
  uart_write_string(RVX_UART, "Running test #5...\n");
  spi_set_cpol(RVX_SPI, 0);
  ASSERT_EQ(spi_get_cpol(RVX_SPI), 0);
  spi_set_cpha(RVX_SPI, 0);
  ASSERT_EQ(spi_get_cpha(RVX_SPI), 0);
  spi_set_clock(RVX_SPI, 0x19);
  ASSERT_EQ(spi_get_clock(RVX_SPI), 0x19);
  spi_select(RVX_SPI, 0);
  ASSERT_EQ(spi_get_cs(RVX_SPI), 0);
  spi_write(RVX_SPI, 0xf0);
  uint8_t read_val = spi_transfer(RVX_SPI, 0xaa);
  ASSERT_EQ(read_val, 0xf0);
  if (read_val != 0xf0)
    print_readout_value(read_val);
  spi_deselect(RVX_SPI);

  // Test #6
  // Send/receive a byte to the dummy SPI peripheral in MODE 1
  uart_write_string(RVX_UART, "Running test #6...\n");
  spi_set_cpol(RVX_SPI, 0);
  ASSERT_EQ(spi_get_cpol(RVX_SPI), 0);
  spi_set_cpha(RVX_SPI, 1);
  ASSERT_EQ(spi_get_cpha(RVX_SPI), 1);
  spi_set_clock(RVX_SPI, 0x19);
  ASSERT_EQ(spi_get_clock(RVX_SPI), 0x19);
  spi_select(RVX_SPI, 1);
  ASSERT_EQ(spi_get_cs(RVX_SPI), 1);
  spi_write(RVX_SPI, 0xf0);
  read_val = spi_transfer(RVX_SPI, 0xaa);
  ASSERT_EQ(read_val, 0xf0);
  if (read_val != 0xf0)
    print_readout_value(read_val);
  spi_deselect(RVX_SPI);

  // Test #7
  // Send/receive a byte to the dummy SPI peripheral in MODE 2
  uart_write_string(RVX_UART, "Running test #7...\n");
  spi_set_cpol(RVX_SPI, 1);
  ASSERT_EQ(spi_get_cpol(RVX_SPI), 1);
  spi_set_cpha(RVX_SPI, 0);
  ASSERT_EQ(spi_get_cpha(RVX_SPI), 0);
  spi_set_clock(RVX_SPI, 0x19);
  ASSERT_EQ(spi_get_clock(RVX_SPI), 0x19);
  spi_select(RVX_SPI, 1);
  ASSERT_EQ(spi_get_cs(RVX_SPI), 1);
  spi_write(RVX_SPI, 0xf0);
  read_val = spi_transfer(RVX_SPI, 0xaa);
  ASSERT_EQ(read_val, 0xf0);
  if (read_val != 0xf0)
    print_readout_value(read_val);
  spi_deselect(RVX_SPI);

  // Test #8
  // Send/receive a byte to the dummy SPI peripheral in MODE 3
  uart_write_string(RVX_UART, "Running test #8...\n");
  spi_set_cpol(RVX_SPI, 1);
  ASSERT_EQ(spi_get_cpol(RVX_SPI), 1);
  spi_set_cpha(RVX_SPI, 1);
  ASSERT_EQ(spi_get_cpha(RVX_SPI), 1);
  spi_set_clock(RVX_SPI, 0x19);
  ASSERT_EQ(spi_get_clock(RVX_SPI), 0x19);
  spi_select(RVX_SPI, 0);
  ASSERT_EQ(spi_get_cs(RVX_SPI), 0);
  spi_write(RVX_SPI, 0xf0);
  read_val = spi_transfer(RVX_SPI, 0xaa);
  ASSERT_EQ(read_val, 0xf0);
  if (read_val != 0xf0)
    print_readout_value(read_val);
  spi_deselect(RVX_SPI);

  if (error_count == 0)
    uart_write_string(RVX_UART, "Passed all SPI Controller Software Unit Tests.\n");
  else
    uart_write_string(RVX_UART, "[ERROR] SPI Controller failed on one or more unit tests.\n");

  while (1)
    ;
}