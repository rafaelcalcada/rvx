// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

#define UART_RX_BUFFER_SIZE 32            // Size of the UART RX buffer
char uart_rx_buffer[UART_RX_BUFFER_SIZE]; // Buffer to store bytes received via UART
unsigned int uart_rx_buffer_count = 0;    // Number of bytes in the UART RX buffer

void main(void)
{
  // Initialize UART at 9600 baud (assuming clock frequency is 12 MHz)
  rvx_uart_init(RVX_UART_ADDRESS, 9600, 12000000);

  // Print welcome message
  rvx_uart_write_string(RVX_UART_ADDRESS, "RVX UART Example Project\n\n");
  rvx_uart_write_string(RVX_UART_ADDRESS, "Type something and press Enter to echo it back.\n");

  // Enable vectored interrupts and UART interrupt
  rvx_irq_enable_vectored_mode();
  rvx_irq_enable(RVX_IRQ_FAST_BITMASK(0)); // UART is connected to RVX Fast IRQ 0
  rvx_irq_enable_global();

  // Wait for interrupts in busy-wait loop
  while (1)
    ;
}

// Interrupt handler for RVX Fast IRQ 0 (connected to UART)
RVX_TRAP_HANDLER_M(rvx_trap_handler_fast0)
{
  // Read received byte from UART
  char rx_data = rvx_uart_read(RVX_UART_ADDRESS);

  // Predicate conditions for handling received byte
  bool enter_key_pressed = (rx_data == '\n' || rx_data == '\r');
  bool backspace_pressed = (rx_data == '\b' || rx_data == 127);
  bool printable_char_pressed = (rx_data >= 32 && rx_data <= 126);
  bool buffer_not_empty = (uart_rx_buffer_count > 0);
  bool buffer_full = (uart_rx_buffer_count >= UART_RX_BUFFER_SIZE - 1);

  // Handle received byte
  if (backspace_pressed && buffer_not_empty)
  {
    uart_rx_buffer[--uart_rx_buffer_count] = '\0';
    rvx_uart_write_string(RVX_UART_ADDRESS, "\b \b");
  }
  else if (printable_char_pressed && !buffer_full)
  {
    uart_rx_buffer[uart_rx_buffer_count++] = rx_data;
    uart_rx_buffer[uart_rx_buffer_count] = '\0';
    rvx_uart_write(RVX_UART_ADDRESS, rx_data);
  }
  else if ((enter_key_pressed && buffer_not_empty) || buffer_full)
  {
    rvx_uart_write_string(RVX_UART_ADDRESS, "\nYou typed: '");
    rvx_uart_write_string(RVX_UART_ADDRESS, uart_rx_buffer);
    rvx_uart_write_string(RVX_UART_ADDRESS, "'\n");
    uart_rx_buffer_count = 0;
    uart_rx_buffer[0] = '\0';
  }
}