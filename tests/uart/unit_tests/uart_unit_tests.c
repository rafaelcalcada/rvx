// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx.h"

RvxUart *uart_address = (RvxUart *)0x80000000;
int error_count = 0;
int error_flag = 0;
uint8_t received_byte = 0;
volatile bool received_byte_flag = false;

#define STRINGIFY(x) #x
#define MACRO_STRINGIFY(x) STRINGIFY(x)
#define RVX_ASSERT(condition)                                                                                          \
  rvx_assert(condition, "\n[ERROR] Assertion at line " MACRO_STRINGIFY(__LINE__) " failed.");
#define RVX_ASSERT_EQ(val1, val2)                                                                                      \
  rvx_assert_eq(val1, val2, "\n[ERROR] Assertion at line " MACRO_STRINGIFY(__LINE__) " failed.");

void rvx_assert(bool condition, const char *message);
void rvx_assert_eq(uint8_t val1, uint8_t val2, const char *message);
void print_byte(const uint8_t read_data);
void transfer_byte_busy_wait(uint8_t byte_to_send);
void transfer_byte_interrupt(uint8_t byte_to_send);
void finish_test();

int main()
{
  // Save register values after reset
  uint32_t baud_reg_reset_value = uart_address->RVX_UART_BAUD_REG;
  uint32_t read_reg_reset_value = uart_address->RVX_UART_READ_REG;
  uint32_t status_reg_reset_value = uart_address->RVX_UART_STATUS_REG;

  rvx_uart_init(uart_address, 5208); // 50 MHz / 9600 baud = 5208 cycles per baud
  rvx_uart_write_string(uart_address, "\nRunning RVX UART module HAL unit tests...\n");

  RVX_ASSERT(uart_address->RVX_UART_BAUD_REG == 5208);

  rvx_uart_write_string(uart_address, "\nTest 1: BAUD register was 0 after reset... ");
  RVX_ASSERT_EQ(baud_reg_reset_value, 0);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 2: READ register is 0 after reset... ");
  RVX_ASSERT_EQ(read_reg_reset_value, 0);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 3: STATUS is ready to send after reset... ");
  RVX_ASSERT_EQ(status_reg_reset_value, 1);
  finish_test();

  // UART is connected in loopback mode for unit tests, the data transmitted above should have been received
  rvx_uart_write_string(uart_address, "\nTest 4: STATUS register flags new data is received... ");
  RVX_ASSERT(rvx_uart_rx_ready(uart_address) == true);
  RVX_ASSERT_EQ(rvx_uart_read(uart_address), '\n');     // This was the first character sent
  RVX_ASSERT(rvx_uart_rx_ready(uart_address) == false); // RX ready flag should be cleared after read
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 5: Send bytes and read them back (busy wait mode)... ");
  transfer_byte_busy_wait(0xa5);
  transfer_byte_busy_wait(0x5a);
  transfer_byte_busy_wait(0xff);
  transfer_byte_busy_wait(0x00);
  transfer_byte_busy_wait(0xc3);
  transfer_byte_busy_wait(0x3c);
  if (error_flag == 0)
    rvx_uart_write_string(uart_address, "\nAll bytes transferred successfully. ");
  error_flag = 0;

  rvx_uart_write_string(uart_address, "\nTest 6: Send bytes and read them back (interrupt mode)... ");
  rvx_irq_enable_vectored_mode();
  rvx_irq_enable(RVX_IRQ_FAST_MASK(0)); // UART is connected to Fast IRQ #0
  transfer_byte_interrupt(0xa5);
  transfer_byte_interrupt(0x5a);
  transfer_byte_interrupt(0xff);
  transfer_byte_interrupt(0x00);
  transfer_byte_interrupt(0xc3);
  transfer_byte_interrupt(0x3c);
  rvx_irq_disable(RVX_IRQ_FAST_MASK(0));
  if (error_flag == 0)
    rvx_uart_write_string(uart_address, "\nAll bytes transferred successfully.");
  error_flag = 0;

  if (error_count == 0)
    rvx_uart_write_string(uart_address, "\n\nPassed all RVX HAL unit tests for the UART module.");
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

void rvx_assert_eq(uint8_t val1, uint8_t val2, const char *message)
{
  if (val1 != val2)
  {
    rvx_uart_write_string(uart_address, message);
    rvx_uart_write_string(uart_address, "\nByte received: ");
    print_byte(val1);
    rvx_uart_write_string(uart_address, "\nByte expected: ");
    print_byte(val2);
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
  rvx_uart_write_string(uart_address, str_val);
}

void transfer_byte_busy_wait(uint8_t byte_to_send)
{
  rvx_uart_write_string(uart_address, "\nSending byte: ");
  print_byte(byte_to_send);
  rvx_uart_write_string(uart_address, " -- ASCII ");
  rvx_uart_wait_tx_complete(uart_address); // Ensure previous transmission is complete
  rvx_uart_read(uart_address);             // Clear RX register
  RVX_ASSERT(rvx_uart_rx_ready(uart_address) == false);
  rvx_uart_write(uart_address, byte_to_send); // Send byte
  rvx_uart_wait_tx_complete(uart_address);    // Wait until transmission is complete
  while (!rvx_uart_rx_ready(uart_address))    // Wait for byte to be received
    ;
  RVX_ASSERT_EQ(rvx_uart_read(uart_address), byte_to_send);
}

void transfer_byte_interrupt(uint8_t byte_to_send)
{
  rvx_uart_write_string(uart_address, "\nSending byte: ");
  print_byte(byte_to_send);
  rvx_uart_write_string(uart_address, " -- ASCII ");
  rvx_uart_wait_tx_complete(uart_address); // Ensure previous transmission is complete
  rvx_uart_read(uart_address);             // Clear RX register
  RVX_ASSERT(rvx_uart_rx_ready(uart_address) == false);
  received_byte_flag = false;
  rvx_irq_enable_global();
  rvx_uart_write(uart_address, byte_to_send); // Send byte
  rvx_uart_wait_tx_complete(uart_address);    // Wait until transmission is complete
  while (!received_byte_flag)                 // Wait until UART interrupt handler sets the flag
    ;
  rvx_irq_disable_global();
  received_byte_flag = false;
  RVX_ASSERT_EQ(received_byte, byte_to_send);
}

void finish_test()
{
  if (error_flag == 0)
  {
    rvx_uart_write_string(uart_address, "Passed.");
  }
  error_flag = 0;
}

// UART interrupt signal is connected to Fast IRQ #0
RVX_IRQ_HANDLER_M(fast0_irq_handler)
{
  received_byte = rvx_uart_read(uart_address);
  received_byte_flag = true;
}