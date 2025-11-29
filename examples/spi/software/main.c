// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "libsteel.h"

#define DEFAULT_UART (UartController *)0x80000000
#define DEFAULT_SPI (SpiController *)0x80030000

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
  uart_write_string(DEFAULT_UART, "Read out value: ");
  uart_write_string(DEFAULT_UART, str_val);
  uart_write_string(DEFAULT_UART, "\n");
}

// UART interrupt signal is connected to Fast IRQ #0
__NAKED void fast0_irq_handler(void)
{
  spi_wait_ready(DEFAULT_SPI);
  spi_select(DEFAULT_SPI, 0);
  spi_write(DEFAULT_SPI, 0x9f);
  volatile uint8_t read_val = spi_transfer(DEFAULT_SPI, 0x00);
  spi_deselect(DEFAULT_SPI);
  if (uart_read(DEFAULT_UART) == '\n') // Enter key
  {
    print_readout_value(read_val);
    uart_write_string(DEFAULT_UART, "Manufacturer: ");
    if (read_val == 0x01)
      uart_write_string(DEFAULT_UART, "Infineon\n");
    else if (read_val == 0xC2)
      uart_write_string(DEFAULT_UART, "Macronix\n");
    else if (read_val == 0x20)
      uart_write_string(DEFAULT_UART, "Micron\n");
    else
      uart_write_string(DEFAULT_UART, "Unknown\n");
  }
  __ASM_VOLATILE("mret");
}

void main(void)
{
  uart_write_string(DEFAULT_UART, "RVX - SPI demo");
  uart_write_string(DEFAULT_UART, "\n\nPress Enter to read the SPI Flash Manufacturer ID.\n");
  // Enable UART interrupts
  csr_enable_vectored_mode_irq();
  CSR_SET(CSR_MIE, MIP_MIE_MASK_F0I);
  csr_global_enable_irq();
  // Configure the controller
  spi_set_mode(DEFAULT_SPI, SPI_MODE0_CPOL0_CPHA0);
  // Wait for interrupts
  while (1)
    ;
}
