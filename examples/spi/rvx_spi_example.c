// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// RVX setup configuration (adjust clock frequency if needed)
const RvxSetup rvx_setup = {.clock_frequency = 12000000U, .trap_handler = RVX_DEFAULT_TRAP_HANDLER};

// Custom utility to print a byte in hexadecimal format
void print_byte(const uint8_t read_data);

void main(void)
{
  // RVX initialization
  rvx_init(&rvx_setup);

  // Initialize UART at 9600 baud (12000000 / 1250 = 9600)
  rvx_uart_set_clock_divider(RVX_UART0, 1250U);

  // Print welcome message
  rvx_uart_print(RVX_UART0, "RVX SPI Example Project\n\n");
  rvx_uart_print(RVX_UART0, "This example reads the manufacturer ID of the FPGA board's SPI flash memory.\n");

  // Initialize the SPI controller to mode 0 and 1 MHz frequency (12000000 / 12 = 1000000)
  rvx_spi_set_mode(RVX_SPI0, RVX_SPI_MODE_0);
  rvx_spi_set_clock_divider(RVX_SPI0, 12U);

  // Read Manufacturer ID from SPI Flash
  rvx_uart_print(RVX_UART0, "\nReading Manufacturer ID from SPI Flash...\n");
  rvx_spi_assert_cs(RVX_SPI0);
  while (!rvx_spi_ready(RVX_SPI0))
    ;
  rvx_spi_write(RVX_SPI0, 0x9F);                       // 0x9F = Read Manufacturer ID command
  uint8_t read_val = rvx_spi_transfer(RVX_SPI0, 0x00); // Read Manufacturer ID
  rvx_spi_deassert_cs(RVX_SPI0);

  // Print Manufacturer ID
  print_byte(read_val);
  rvx_uart_print(RVX_UART0, "Manufacturer: ");
  switch (read_val)
  {
  case 0x01:
    rvx_uart_print(RVX_UART0, "Infineon\n");
    break;
  case 0xC2:
    rvx_uart_print(RVX_UART0, "Macronix\n");
    break;
  case 0x20:
    rvx_uart_print(RVX_UART0, "Micron\n");
    break;
  default:
    rvx_uart_print(RVX_UART0, "Unknown manufacturer\n");
    break;
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
  rvx_uart_print(RVX_UART0, "\nRead value: ");
  rvx_uart_print(RVX_UART0, str_val);
  rvx_uart_print(RVX_UART0, "\n");
}