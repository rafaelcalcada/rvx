// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#include "rvx.h"
#include "rvx_api_test_helpers.h"

// Pointer to the UART controller registers.
extern RvxUartRegs *uart_controller;

/// @name Global variables
/// @{
uint8_t uart_received_byte = 0;                ///< Last byte received via UART interrupt
volatile bool uart_received_byte_flag = false; ///< Flag indicating a byte has been received via UART interrupt
/// @}

/// @name RVX API UART Test Utility Functions
/// @{
void wait_tx_complete();
void transfer_byte_busy_wait(uint8_t tx_byte);
void transfer_byte_interrupt(uint8_t tx_byte);
/// @}

// UART interrupt signal is connected to Fast Interrupt 0
RVX_TRAP_HANDLER_M(rvx_trap_handler_fast_irq_0)
{
  uart_received_byte = rvx_uart_read(uart_controller);
  uart_received_byte_flag = true;
}

/// @brief Run RVX API UART integration tests.
void run_rvx_api_uart_test()
{
  unsigned int uart_tests_error_count = 0;

  // Save reset values of UART registers before any modifications
  uint32_t baud_reg_reset_value = uart_controller->RVX_UART_BAUD_REG;
  uint32_t read_reg_reset_value = uart_controller->RVX_UART_READ_REG;
  uint32_t status_reg_reset_value = uart_controller->RVX_UART_STATUS_REG;

  rvx_uart_set_baud_rate(uart_controller, 1000000, 50000000);
  rvx_uart_send_string(uart_controller, "\nRVX API - UART integration tests\n--------------------------------\n");

  rvx_test_start("\nTest 1: Initialize UART at 9600 baud. ");
  RVX_TEST_ASSERT(uart_controller->RVX_UART_BAUD_REG == 50);
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
  RVX_TEST_ASSERT(rvx_uart_rx_ready(uart_controller) == true);
  RVX_TEST_ASSERT_EQ(rvx_uart_read(uart_controller), '\n');     // Why '\n'? This was the first character sent
  RVX_TEST_ASSERT(rvx_uart_rx_ready(uart_controller) == false); // RX ready flag should be cleared after read
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
  rvx_irq_set_mode(RVX_PRIVILEGE_LEVEL_M, RVX_INTERRUPT_MODE_VECTORED);
  rvx_irq_enable(RVX_PRIVILEGE_LEVEL_M, RVX_IRQ_FAST_BITMASK(0));
  transfer_byte_interrupt(0xa5);
  transfer_byte_interrupt(0x5a);
  transfer_byte_interrupt(0xff);
  transfer_byte_interrupt(0x00);
  transfer_byte_interrupt(0xc3);
  transfer_byte_interrupt(0x3c);
  rvx_irq_disable(RVX_PRIVILEGE_LEVEL_M, RVX_IRQ_FAST_BITMASK(0));
  rvx_test_finish("\n  All bytes transferred successfully. (Passed)");
  rvx_test_update_error_count(&uart_tests_error_count);

  const char *error_msg = "\n\nERROR: Some RVX API integration tests for the UART controller failed. "
                          "Check the test output for details.\n";
  const char *success_msg = "\n\nRVX API UART tests: All tests passed successfully.\n";

  if (uart_tests_error_count)
    rvx_uart_send_string(uart_controller, error_msg);
  else
    rvx_uart_send_string(uart_controller, success_msg);
}

/// @brief Wait until UART transmission is complete by polling the TX ready flag.
void wait_tx_complete()
{
  while (!rvx_uart_tx_ready(uart_controller))
    ;
}

/// @brief Transfer a byte via UART using busy-wait and verify reception.
/// @param tx_byte The byte to transmit.
void transfer_byte_busy_wait(uint8_t tx_byte)
{
  rvx_uart_send_string(uart_controller, "\n  Sending byte: ");
  rvx_test_print_byte(tx_byte);
  rvx_uart_send_string(uart_controller, " -- ASCII ");
  wait_tx_complete();             // Ensure previous transmission is complete
  rvx_uart_read(uart_controller); // Clear RX register
  RVX_TEST_ASSERT(rvx_uart_rx_ready(uart_controller) == false);
  rvx_uart_send(uart_controller, tx_byte); // Send byte
  wait_tx_complete();                      // Wait until transmission is complete
  RVX_TEST_ASSERT_EQ(rvx_uart_receive(uart_controller), tx_byte);
}

/// @brief Transfer a byte via UART using interrupt and verify reception.
/// @param tx_byte The byte to transmit.
void transfer_byte_interrupt(uint8_t tx_byte)
{
  rvx_uart_send_string(uart_controller, "\n  Sending byte: ");
  rvx_test_print_byte(tx_byte);
  rvx_uart_send_string(uart_controller, " -- ASCII ");
  wait_tx_complete();
  rvx_uart_receive(uart_controller); // Clear RX register
  RVX_TEST_ASSERT(rvx_uart_rx_ready(uart_controller) == false);
  uart_received_byte_flag = false;
  rvx_irq_enable_global(RVX_PRIVILEGE_LEVEL_M);
  rvx_uart_send(uart_controller, tx_byte); // Send byte
  while (!uart_received_byte_flag)         // Wait until UART interrupt handler sets the flag
    ;
  rvx_irq_disable_global(RVX_PRIVILEGE_LEVEL_M);
  uart_received_byte_flag = false;
  RVX_TEST_ASSERT_EQ(uart_received_byte, tx_byte);
}