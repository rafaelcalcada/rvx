// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

RvxUart *uart_address = (RvxUart *)0x80000000;
RvxSpiManager *spi_address = (RvxSpiManager *)0x80030000;

void print_byte(const uint8_t read_data);

// UART interrupt signal is connected to Fast IRQ #0
RVX_IRQ_HANDLER_M(fast0_irq_handler)
{
  rvx_spi_chip_select_assert(spi_address);
  rvx_spi_write(spi_address, 0x9F);                       // Send "Read Manufacturer ID" command
  uint8_t read_val = rvx_spi_transfer(spi_address, 0x00); // Read manufacturer ID
  rvx_spi_chip_select_deassert(spi_address);

  if (rvx_uart_read(uart_address) == '\n') // Enter key pressed
  {
    print_byte(read_val);
    rvx_uart_write_string(uart_address, "Manufacturer: ");
    if (read_val == 0x01)
    {
      rvx_uart_write_string(uart_address, "Infineon\n");
    }
    else if (read_val == 0xC2)
    {
      rvx_uart_write_string(uart_address, "Macronix\n");
    }
    else if (read_val == 0x20)
    {
      rvx_uart_write_string(uart_address, "Micron\n");
    }
    else
    {
      rvx_uart_write_string(uart_address, "Unknown\n");
    }
  }
}

void main(void)
{
  rvx_uart_init(uart_address, 1250); // 12 MHz / 9600 baud = 1250 cycles per baud
  rvx_uart_write_string(uart_address, "RVX Project - SPI Manager Example");
  rvx_uart_write_string(uart_address, "\n\nPress Enter to read the SPI Flash Manufacturer ID.\n");

  // Enable UART interrupts
  rvx_irq_enable_vectored_mode();
  rvx_irq_enable(RVX_IRQ_FAST_MASK(0));
  rvx_irq_enable_global();

  // Set SPI Manager to MODE 0
  rvx_spi_mode_set(spi_address, RVX_SPI_MODE_0);

  // Busy wait for interrupt
  while (1)
    ;
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