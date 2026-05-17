// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

#define UART_RX_BUFFER_SIZE 32            // Size of the UART RX buffer
char uart_rx_buffer[UART_RX_BUFFER_SIZE]; // Buffer to store bytes received via UART
unsigned int uart_rx_buffer_count = 0;    // Number of bytes in the UART RX buffer

// Pointer to the UART controller registers.
RvxUartRegs *uart_controller = (RvxUartRegs *)RVX_UART_CONTROLLER_ADDRESS;

void main(void)
{
  // Initialize UART at 9600 baud (RVX clock frequency is 12 MHz)
  rvx_uart_set_baud_rate(uart_controller, 9600, 12000000);

  // Print welcome message
  rvx_uart_send_string(uart_controller, "RVX UART Example Project\n\n");
  rvx_uart_send_string(uart_controller, "Type something and press Enter to echo it back.\n");

  // Enable vectored interrupt mode
  rvx_irq_set_mode_m(RVX_IRQ_MODE_VECTORED);

  // Enable UART interrupt
  rvx_irq_enable_m(RVX_IRQ_UART_BITMASK);

  // Enable interrupts in M-mode
  rvx_irq_enable_global_m();

  // Wait for a UART interrupt
  rvx_wait_for_interrupt();
}

// Provide a trap handler for the UART interrupt
RVX_TRAP_HANDLER_M(rvx_trap_handler_uart_m)
{
  // Read received byte from UART
  char rx_data = rvx_uart_read(uart_controller);

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
    rvx_uart_send_string(uart_controller, "\b \b");
  }
  else if (printable_char_pressed && !buffer_full)
  {
    uart_rx_buffer[uart_rx_buffer_count++] = rx_data;
    uart_rx_buffer[uart_rx_buffer_count] = '\0';
    rvx_uart_send(uart_controller, rx_data);
  }
  else if ((enter_key_pressed && buffer_not_empty) || buffer_full)
  {
    rvx_uart_send_string(uart_controller, "\nYou typed: '");
    rvx_uart_send_string(uart_controller, uart_rx_buffer);
    rvx_uart_send_string(uart_controller, "'\n");
    uart_rx_buffer_count = 0;
    uart_rx_buffer[0] = '\0';
  }
}