// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include "rvx_sdk_test_framework.h"

#define RVX_UART_TIMEOUT_ITERATIONS 100000U

typedef struct
{
  uint32_t baud_register_reset_value;
  uint32_t read_register_reset_value;
  uint32_t status_register_reset_value;
} RvxUartResetValues;

static RvxPlicRegs *const plic_controller = (RvxPlicRegs *)RVX_PLIC_CONTROLLER_ADDRESS;
static volatile uint8_t uart_received_byte;
static volatile bool uart_received_byte_flag;
static RvxUartResetValues uart_reset_values;

static void uart_test_suite_set_up(RvxTestSuite *suite);
static void uart_test_initialization(RvxTestSuite *suite);
static void uart_test_baud_register_reset(RvxTestSuite *suite);
static void uart_test_read_register_reset(RvxTestSuite *suite);
static void uart_test_status_register_reset(RvxTestSuite *suite);
static void uart_test_receive_after_test_output(RvxTestSuite *suite);
static void uart_test_busy_wait_transfer(RvxTestSuite *suite);
static void uart_test_interrupt_transfer(RvxTestSuite *suite);
static bool wait_tx_ready(RvxUart *uart);
static bool wait_rx_ready(RvxUart *uart);
static bool wait_for_received_byte(void);
static void transfer_byte_busy_wait(RvxTestSuite *suite, uint8_t tx_byte);
static void transfer_byte_interrupt(RvxTestSuite *suite, uint8_t tx_byte);

/// @brief Interrupt handler for UART0.
void rvx_irq_handler_uart0(void)
{
  uart_received_byte = rvx_uart_read(RVX_UART0);
  uart_received_byte_flag = true;
}

static void uart_test_suite_set_up(RvxTestSuite *suite)
{
  (void)suite;
  rvx_plic_enable_source(plic_controller, 0);
  rvx_plic_set_priority(plic_controller, 0, RVX_PLIC_MAX_PRIORITY);

  uart_reset_values.baud_register_reset_value = RVX_UART0->RVX_UART_BAUD_REG;
  uart_reset_values.read_register_reset_value = RVX_UART0->RVX_UART_READ_REG;
  uart_reset_values.status_register_reset_value = RVX_UART0->RVX_UART_STATUS_REG;

  rvx_uart_set_baud_rate(RVX_UART0, RVX_TEST_UART_BAUD_RATE_HZ);
}

static void uart_test_initialization(RvxTestSuite *suite)
{
  RVX_TEST_ASSERT_EQ(suite, RVX_UART0->RVX_UART_BAUD_REG, 50);
}

static void uart_test_baud_register_reset(RvxTestSuite *suite)
{
  RVX_TEST_ASSERT_EQ(suite, uart_reset_values.baud_register_reset_value, 0);
}

static void uart_test_read_register_reset(RvxTestSuite *suite)
{
  RVX_TEST_ASSERT_EQ(suite, uart_reset_values.read_register_reset_value, 0);
}

static void uart_test_status_register_reset(RvxTestSuite *suite)
{
  RVX_TEST_ASSERT_EQ(suite, uart_reset_values.status_register_reset_value, 0);
}

static void uart_test_receive_after_test_output(RvxTestSuite *suite)
{
  RVX_TEST_ASSERT(suite, rvx_uart_rx_ready(RVX_UART0));
  RVX_TEST_ASSERT_EQ(suite, rvx_uart_read(RVX_UART0), '\n');
  RVX_TEST_ASSERT(suite, !rvx_uart_rx_ready(RVX_UART0));
}

static void uart_test_busy_wait_transfer(RvxTestSuite *suite)
{
  transfer_byte_busy_wait(suite, 0xa5);
  transfer_byte_busy_wait(suite, 0x5a);
  transfer_byte_busy_wait(suite, 0xff);
  transfer_byte_busy_wait(suite, 0x00);
  transfer_byte_busy_wait(suite, 0xc3);
  transfer_byte_busy_wait(suite, 0x3c);
  rvx_uart_print(RVX_UART0, "\n  All bytes transferred successfully. ");
}

static void uart_test_interrupt_transfer(RvxTestSuite *suite)
{
  rvx_irq_enable_m(RVX_IRQ_EXTERNAL_BITMASK);
  transfer_byte_interrupt(suite, 0xa5);
  transfer_byte_interrupt(suite, 0x5a);
  transfer_byte_interrupt(suite, 0xff);
  transfer_byte_interrupt(suite, 0x00);
  transfer_byte_interrupt(suite, 0xc3);
  transfer_byte_interrupt(suite, 0x3c);
  rvx_irq_disable_m(RVX_IRQ_EXTERNAL_BITMASK);
  rvx_uart_print(RVX_UART0, "\n  All bytes transferred successfully. ");
}

static bool wait_tx_ready(RvxUart *uart)
{
  for (unsigned int iteration = 0; iteration < RVX_UART_TIMEOUT_ITERATIONS; iteration++)
  {
    if (rvx_uart_tx_ready(uart))
      return true;
  }

  return false;
}

static bool wait_rx_ready(RvxUart *uart)
{
  for (unsigned int iteration = 0; iteration < RVX_UART_TIMEOUT_ITERATIONS; iteration++)
  {
    if (rvx_uart_rx_ready(uart))
      return true;
  }

  return false;
}

static bool wait_for_received_byte(void)
{
  for (unsigned int iteration = 0; iteration < RVX_UART_TIMEOUT_ITERATIONS; iteration++)
  {
    if (uart_received_byte_flag)
      return true;
  }

  return false;
}

/// @brief Transfer a byte via UART using busy-wait and verify reception.
/// @param tx_byte The byte to transmit.
static void transfer_byte_busy_wait(RvxTestSuite *suite, uint8_t tx_byte)
{
  rvx_uart_print(RVX_UART0, "\n  Sending byte: ");
  rvx_test_print_byte(tx_byte);
  rvx_uart_print(RVX_UART0, " -- ASCII ");
  const bool tx_ready = wait_tx_ready(RVX_UART0);
  RVX_TEST_ASSERT(suite, tx_ready);
  if (!tx_ready)
    return;

  rvx_uart_read(RVX_UART0);
  RVX_TEST_ASSERT(suite, !rvx_uart_rx_ready(RVX_UART0));
  rvx_uart_write(RVX_UART0, tx_byte);

  const bool transfer_completed = wait_tx_ready(RVX_UART0);
  RVX_TEST_ASSERT(suite, transfer_completed);
  if (!transfer_completed)
    return;

  const bool byte_received = wait_rx_ready(RVX_UART0);
  RVX_TEST_ASSERT(suite, byte_received);
  if (!byte_received)
    return;

  RVX_TEST_ASSERT_EQ(suite, rvx_uart_read(RVX_UART0), tx_byte);
}

/// @brief Transfer a byte via UART using interrupt and verify reception.
/// @param tx_byte The byte to transmit.
static void transfer_byte_interrupt(RvxTestSuite *suite, uint8_t tx_byte)
{
  rvx_uart_print(RVX_UART0, "\n  Sending byte: ");
  rvx_test_print_byte(tx_byte);
  rvx_uart_print(RVX_UART0, " -- ASCII ");
  const bool tx_ready = wait_tx_ready(RVX_UART0);
  RVX_TEST_ASSERT(suite, tx_ready);
  if (!tx_ready)
    return;

  rvx_uart_read(RVX_UART0);
  RVX_TEST_ASSERT(suite, !rvx_uart_rx_ready(RVX_UART0));
  uart_received_byte_flag = false;
  rvx_irq_global_enable_m();
  rvx_uart_write(RVX_UART0, tx_byte);
  const bool byte_received = wait_for_received_byte();
  rvx_irq_global_disable_m();
  RVX_TEST_ASSERT(suite, byte_received);
  if (!byte_received)
    return;

  uart_received_byte_flag = false;
  RVX_TEST_ASSERT_EQ(suite, uart_received_byte, tx_byte);
}

static const RvxTestCase uart_test_cases[] = {
    {"Initialize UART at 1,000,000 baud.", uart_test_initialization},
    {"UART BAUD register has its reset value.", uart_test_baud_register_reset},
    {"UART READ register has its reset value.", uart_test_read_register_reset},
    {"UART STATUS register has its reset value.", uart_test_status_register_reset},
    {"UART loopback receives the test output newline.", uart_test_receive_after_test_output},
    {"Send and receive bytes using polling.", uart_test_busy_wait_transfer},
    {"Send and receive bytes using interrupts.", uart_test_interrupt_transfer},
};

const RvxTestSuiteDescriptor rvx_sdk_uart_test_suite = {
    .name = "RVX SDK - UART tests",
    .test_cases = uart_test_cases,
    .test_case_count = RVX_ARRAY_SIZE(uart_test_cases),
    .set_up = uart_test_suite_set_up,
};