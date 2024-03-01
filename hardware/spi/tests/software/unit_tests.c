// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "rvsteel_api.h"
#include "stdint.h"

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
#define ASSERT_EQ(val1, val2)                                                            \
  if (val1 != val2)                                                                      \
  {                                                                                      \
    uart_send_string("[ERROR] Assertion at line " STRINGIFY_MACRO(__LINE__) " failed."); \
    error_count++;                                                                       \
  }

// Global variables
int error_count = 0;

// Set the clock polarity of the SPI Controller.
inline void spi_set_cpol(const uint8_t cpol_value)
{
  (*__SPI_CPOL_ADDRESS) = cpol_value;
}

// Set the clock phase of the SPI Controller.
inline void spi_set_cpha(const uint8_t cpha_value)
{
  (*__SPI_CPHA_ADDRESS) = cpha_value;
}

// Read the clock polarity (CPOL register) of the SPI Controller.
inline uint8_t spi_get_cpol()
{
  return (*__SPI_CPOL_ADDRESS);
}

// Read the clock phase (CPHA register) of the SPI Controller.
inline uint8_t spi_get_cpha()
{
  return (*__SPI_CPHA_ADDRESS);
}

// Select a Chip Select (CS) line
inline void spi_select(const uint8_t id)
{
  (*__SPI_CS_ADDRESS) = id;
}

// Deselect the Chip Select (CS) line
inline void spi_deselect()
{
  (*__SPI_CS_ADDRESS) = 0xff;
}

// Read the Chip Select (CS) register
inline uint8_t spi_get_cs()
{
  return (*__SPI_CS_ADDRESS);
}

// Busy wait loop that only stops when the SPI controller is ready for a new read/write operation
inline void spi_wait_ready()
{
  while ((*__SPI_STATUS_ADDRESS != 0))
    ;
}

// Set the value of the clock_div (clock divider) register
inline void spi_set_clock(const uint8_t cpha_value)
{
  (*__SPI_CLKDIV_ADDRESS) = cpha_value;
}

// Read the value of the clock_div (clock divider) register
inline uint8_t spi_get_clock()
{
  return (*__SPI_CLKDIV_ADDRESS);
}

// Send a byte to a SPI peripheral, ignoring the data received over the POCI pin.
inline void spi_write(const uint8_t wdata)
{
  (*__SPI_WDATA_ADDRESS) = wdata;
  spi_wait_ready();
}

// Send a byte to a SPI peripheral, returning the data received over the POCI pin.
inline uint8_t spi_transfer(const uint8_t wdata)
{
  (*__SPI_WDATA_ADDRESS) = wdata;
  spi_wait_ready();
  return (*__SPI_RDATA_ADDRESS);
}

void print_readout_value(const uint8_t rdata)
{
  uint8_t val = rdata;
  char str_val[4] = "xxx\0";
  for (int i = 1; i <= 3; i++)
  {
    str_val[3 - i] = (uint8_t)((val % 10UL) + '0');
    val /= 10;
  }
  str_val[3] = '\0';
  uart_send_string("Read out value is: ");
  uart_send_string(str_val);
  uart_send_string("\n");
}

// Unit tests for the SPI Controller
int main()
{
  uart_send_string("SPI Controller Software Unit Tests\n\n");

  // Test #1
  // Check the default values of CPOL and CPHA (0 and 0, respectively)
  uart_send_string("Running test #1...\n");
  ASSERT_EQ(spi_get_cpol(), 0);
  ASSERT_EQ(spi_get_cpha(), 0);

  // Test #2
  // Check if CPOL and CPHA registers hold their values after write
  uart_send_string("Running test #2...\n");
  spi_set_cpol(1);
  spi_set_cpha(1);
  ASSERT_EQ(spi_get_cpol(), 1);
  ASSERT_EQ(spi_get_cpha(), 1);

  // Test #3
  // Check if restoring the value of CPOL and CPHA succeeds
  uart_send_string("Running test #3...\n");
  spi_set_cpol(0);
  spi_set_cpha(0);
  ASSERT_EQ(spi_get_cpol(), 0);
  ASSERT_EQ(spi_get_cpha(), 0);

  // Test #4
  // Check select/deselect CS lines
  uart_send_string("Running test #4...\n");
  spi_select(0);
  ASSERT_EQ(spi_get_cs(), 0);
  spi_deselect();
  ASSERT_EQ(spi_get_cs(), 255);
  spi_select(1);
  ASSERT_EQ(spi_get_cs(), 1);
  spi_deselect();
  ASSERT_EQ(spi_get_cs(), 255);

  // Test #5
  // Send/receive a byte to the dummy SPI peripheral in MODE 0
  uart_send_string("Running test #5...\n");
  spi_set_cpol(0);
  ASSERT_EQ(spi_get_cpol(), 0);
  spi_set_cpha(0);
  ASSERT_EQ(spi_get_cpha(), 0);
  spi_set_clock(0x19);
  ASSERT_EQ(spi_get_clock(), 0x19);
  spi_select(0);
  ASSERT_EQ(spi_get_cs(), 0);
  spi_write(0xf0); // The SPI peripheral was built to return the value sent in the next transfer
  uint8_t read_val = spi_transfer(0xaa);
  ASSERT_EQ(read_val, 0xf0);
  if (read_val != 0xf0)
    print_readout_value(read_val);
  spi_deselect();

  // Test #6
  // Send/receive a byte to the dummy SPI peripheral in MODE 1
  uart_send_string("Running test #6...\n");
  spi_set_cpol(0);
  ASSERT_EQ(spi_get_cpol(), 0);
  spi_set_cpha(1);
  ASSERT_EQ(spi_get_cpha(), 1);
  spi_set_clock(0x19);
  ASSERT_EQ(spi_get_clock(), 0x19);
  spi_select(1);
  ASSERT_EQ(spi_get_cs(), 1);
  spi_write(0xf0); // The SPI peripheral was built to return the value sent in the next transfer
  read_val = spi_transfer(0xaa);
  ASSERT_EQ(read_val, 0xf0);
  if (read_val != 0xf0)
    print_readout_value(read_val);
  spi_deselect();

  // Test #7
  // Send/receive a byte to the dummy SPI peripheral in MODE 2
  uart_send_string("Running test #7...\n");
  spi_set_cpol(1);
  ASSERT_EQ(spi_get_cpol(), 1);
  spi_set_cpha(0);
  ASSERT_EQ(spi_get_cpha(), 0);
  spi_set_clock(0x19);
  ASSERT_EQ(spi_get_clock(), 0x19);
  spi_select(1);
  ASSERT_EQ(spi_get_cs(), 1);
  spi_write(0xf0); // The SPI peripheral was built to return the value sent in the next transfer
  read_val = spi_transfer(0xaa);
  ASSERT_EQ(read_val, 0xf0);
  if (read_val != 0xf0)
    print_readout_value(read_val);
  spi_deselect();

  // Test #8
  // Send/receive a byte to the dummy SPI peripheral in MODE 3
  uart_send_string("Running test #8...\n");
  spi_set_cpol(1);
  ASSERT_EQ(spi_get_cpol(), 1);
  spi_set_cpha(1);
  ASSERT_EQ(spi_get_cpha(), 1);
  spi_set_clock(0x19);
  ASSERT_EQ(spi_get_clock(), 0x19);
  spi_select(0);
  ASSERT_EQ(spi_get_cs(), 0);
  spi_write(0xf0); // The SPI peripheral was built to return the value sent in the next transfer
  read_val = spi_transfer(0xaa);
  ASSERT_EQ(read_val, 0xf0);
  if (read_val != 0xf0)
    print_readout_value(read_val);
  spi_deselect();

  if (error_count == 0)
    uart_send_string("Passed all SPI Controller Software Unit Tests.\n");
  else
    uart_send_string("[ERROR] SPI Controller failed on one or more unit tests.\n");

  busy_wait();
}