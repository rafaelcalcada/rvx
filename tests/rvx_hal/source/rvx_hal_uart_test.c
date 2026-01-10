// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx_hal_uart_test.h"

/// @name Global variables
/// @{
uint8_t uart_received_byte = 0;                ///< Last byte received via UART interrupt
volatile bool uart_received_byte_flag = false; ///< Flag indicating a byte has been received via UART interrupt
/// @}

/// @name RVX HAL UART Test Utility Functions
/// @{
void transfer_byte_busy_wait(uint8_t tx_byte);
void transfer_byte_interrupt(uint8_t tx_byte);
/// @}

// UART interrupt signal is connected to Fast IRQ #0
RVX_IRQ_HANDLER_M(fast0_irq_handler)
{
  uart_received_byte = rvx_uart_read(rvx_test_uart_address);
  uart_received_byte_flag = true;
}

/// @brief Run RVX HAL UART integration tests.
void run_rvx_hal_uart_test()
{
  // Track the number of failed tests locally
  unsigned int uart_tests_error_count = 0;

  // Save reset values of UART registers before any modifications
  uint32_t baud_reg_reset_value = rvx_test_uart_address->RVX_UART_BAUD_REG;
  uint32_t read_reg_reset_value = rvx_test_uart_address->RVX_UART_READ_REG;
  uint32_t status_reg_reset_value = rvx_test_uart_address->RVX_UART_STATUS_REG;

  rvx_uart_init(rvx_test_uart_address, 5208);
  rvx_uart_write_string(rvx_test_uart_address,
                        "\nRVX HAL - UART integration tests\n--------------------------------\n");

  rvx_test_start("\nTest 1: Initialize UART at 9600 baud. ");
  RVX_TEST_ASSERT(rvx_test_uart_address->RVX_UART_BAUD_REG == 5208);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&uart_tests_error_count);

  rvx_test_start("\nTest 2: UART BAUD register is 0 after reset. ");
  RVX_TEST_ASSERT_EQ(baud_reg_reset_value, 0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&uart_tests_error_count);

  rvx_test_start("\nTest 3: UART READ register is 0 after reset. ");
  RVX_TEST_ASSERT_EQ(read_reg_reset_value, 0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&uart_tests_error_count);

  rvx_test_start("\nTest 4: UART STATUS is not ready to send after reset. ");
  RVX_TEST_ASSERT_EQ(status_reg_reset_value, 0);
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&uart_tests_error_count);

  // UART is connected in loopback, the data transmitted above should have been received
  rvx_test_start("\nTest 5: UART STATUS register flags new data is received. ");
  RVX_TEST_ASSERT(rvx_uart_rx_ready(rvx_test_uart_address) == true);
  RVX_TEST_ASSERT_EQ(rvx_uart_read(rvx_test_uart_address), '\n');     // This was the first character sent
  RVX_TEST_ASSERT(rvx_uart_rx_ready(rvx_test_uart_address) == false); // RX ready flag should be cleared after read
  rvx_test_finish("(Passed)");
  rvx_test_update_error_count(&uart_tests_error_count);

  rvx_test_start("\nTest 6: Send bytes and read them back (busy wait). ");
  transfer_byte_busy_wait(0xa5);
  transfer_byte_busy_wait(0x5a);
  transfer_byte_busy_wait(0xff);
  transfer_byte_busy_wait(0x00);
  transfer_byte_busy_wait(0xc3);
  transfer_byte_busy_wait(0x3c);
  rvx_test_finish("\n  All bytes transferred successfully. (Passed)");
  rvx_test_update_error_count(&uart_tests_error_count);

  rvx_test_start("\nTest 7: Send bytes and read them back (interrupt). ");
  rvx_irq_enable_vectored_mode();
  rvx_irq_enable(RVX_IRQ_FAST_BITMASK(0)); // UART is connected to Fast IRQ #0
  transfer_byte_interrupt(0xa5);
  transfer_byte_interrupt(0x5a);
  transfer_byte_interrupt(0xff);
  transfer_byte_interrupt(0x00);
  transfer_byte_interrupt(0xc3);
  transfer_byte_interrupt(0x3c);
  rvx_irq_disable(RVX_IRQ_FAST_BITMASK(0));
  rvx_test_finish("\n  All bytes transferred successfully. (Passed)");
  rvx_test_update_error_count(&uart_tests_error_count);

  if (uart_tests_error_count)
    rvx_uart_write_string(rvx_test_uart_address,
                          "\n\n(ERROR) Some RVX HAL UART integration tests failed. Check the output for details.");
  else
    rvx_uart_write_string(rvx_test_uart_address, "\n\nPassed RVX HAL UART integration tests.");

  rvx_uart_write_string(rvx_test_uart_address, "\n");
}

/// @brief Transfer a byte via UART using busy-wait and verify reception.
/// @param tx_byte The byte to transmit.
void transfer_byte_busy_wait(uint8_t tx_byte)
{
  rvx_uart_write_string(rvx_test_uart_address, "\n  Sending byte: ");
  rvx_test_print_byte(tx_byte);
  rvx_uart_write_string(rvx_test_uart_address, " -- ASCII ");
  rvx_uart_wait_tx_complete(rvx_test_uart_address); // Ensure previous transmission is complete
  rvx_uart_read(rvx_test_uart_address);             // Clear RX register
  RVX_TEST_ASSERT(rvx_uart_rx_ready(rvx_test_uart_address) == false);
  rvx_uart_write(rvx_test_uart_address, tx_byte);   // Send byte
  rvx_uart_wait_tx_complete(rvx_test_uart_address); // Wait until transmission is complete
  while (!rvx_uart_rx_ready(rvx_test_uart_address)) // Wait for byte to be received
    ;
  RVX_TEST_ASSERT_EQ(rvx_uart_read(rvx_test_uart_address), tx_byte);
}

/// @brief Transfer a byte via UART using interrupt and verify reception.
/// @param tx_byte The byte to transmit.
void transfer_byte_interrupt(uint8_t tx_byte)
{
  rvx_uart_write_string(rvx_test_uart_address, "\n  Sending byte: ");
  rvx_test_print_byte(tx_byte);
  rvx_uart_write_string(rvx_test_uart_address, " -- ASCII ");
  rvx_uart_wait_tx_complete(rvx_test_uart_address); // Ensure previous transmission is complete
  rvx_uart_read(rvx_test_uart_address);             // Clear RX register
  RVX_TEST_ASSERT(rvx_uart_rx_ready(rvx_test_uart_address) == false);
  uart_received_byte_flag = false;
  rvx_irq_enable_global();
  rvx_uart_write(rvx_test_uart_address, tx_byte);   // Send byte
  rvx_uart_wait_tx_complete(rvx_test_uart_address); // Wait until transmission is complete
  while (!uart_received_byte_flag)                  // Wait until UART interrupt handler sets the flag
    ;
  rvx_irq_disable_global();
  uart_received_byte_flag = false;
  RVX_TEST_ASSERT_EQ(uart_received_byte, tx_byte);
}