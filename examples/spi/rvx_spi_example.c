// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// Pointer to the UART controller registers.
RvxUartRegs *uart_controller = (RvxUartRegs *)RVX_UART_CONTROLLER_ADDRESS;

// Pointer to the SPI controller registers.
RvxSpiRegs *spi_controller = (RvxSpiRegs *)RVX_SPI_CONTROLLER_ADDRESS;

void print_byte(const uint8_t read_data);

void main(void)
{
  // Initialize UART at 9600 baud (assuming RVX is connected to a 12 MHz clock source)
  rvx_uart_set_baud_rate(uart_controller, 9600, 12000000);

  // Print welcome message
  rvx_uart_send_string(uart_controller, "RVX SPI Example Project\n\n");
  rvx_uart_send_string(uart_controller,
                       "This example reads the manufacturer ID of the FPGA board's SPI flash memory.\n");

  // Initialize the SPI controller to mode 0 and 1MHz frequency (assuming RVX is connected to a 12 MHz clock source)
  rvx_spi_set_mode(spi_controller, RVX_SPI_MODE_0);
  rvx_spi_set_divider(spi_controller, 12);

  // Read Manufacturer ID from SPI Flash
  rvx_uart_send_string(uart_controller, "\nReading Manufacturer ID from SPI Flash...\n");
  rvx_spi_assert_cs(spi_controller);
  rvx_spi_write(spi_controller, 0x9F);                       // 0x9F = Read Manufacturer ID command
  uint8_t read_val = rvx_spi_transfer(spi_controller, 0x00); // Read Manufacturer ID
  rvx_spi_deassert_cs(spi_controller);

  // Print Manufacturer ID
  print_byte(read_val);
  rvx_uart_send_string(uart_controller, "Manufacturer: ");
  switch (read_val)
  {
  case 0x01:
    rvx_uart_send_string(uart_controller, "Infineon\n");
    break;
  case 0xC2:
    rvx_uart_send_string(uart_controller, "Macronix\n");
    break;
  case 0x20:
    rvx_uart_send_string(uart_controller, "Micron\n");
    break;
  default:
    rvx_uart_send_string(uart_controller, "Unknown manufacturer\n");
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
  rvx_uart_send_string(uart_controller, "\nRead value: ");
  rvx_uart_send_string(uart_controller, str_val);
  rvx_uart_send_string(uart_controller, "\n");
}