// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

RvxUart *uart_address = (RvxUart *)0x80000000;
RvxTimer *timer_address = (RvxTimer *)0x80010000;
int error_count = 0;
int error_flag = 0;
uint64_t counter_value = 0;

#define STRINGIFY(x) #x
#define MACRO_STRINGIFY(x) STRINGIFY(x)
#define RVX_ASSERT(condition)                                                                                          \
  rvx_assert(condition, "\n[ERROR] Assertion at line " MACRO_STRINGIFY(__LINE__) " failed.");

void rvx_assert(bool condition, const char *message);
void finish_test();
void print_double_word_hex(uint64_t value);

RVX_IRQ_HANDLER_M(mti_irq_handler)
{
  rvx_timer_disable(timer_address);
  rvx_uart_write_string(uart_address, "Passed.");
}

int main()
{
  rvx_uart_init(uart_address, 5208); // 50 MHz / 9600 baud = 5208 cycles per baud
  rvx_uart_write_string(uart_address, "\nRunning RVX Timer module HAL unit tests...\n");

  rvx_uart_write_string(uart_address, "\nTest 1: COUNTER ENABLE register is 0 after reset... ");
  RVX_ASSERT(rvx_timer_is_enabled(timer_address) == false);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 2: COUNTER register is 0 after reset... ");
  RVX_ASSERT(rvx_timer_get_counter(timer_address) == 0);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 3: COMPARE register is 0xffffffffffffffff after reset... ");
  RVX_ASSERT(rvx_timer_get_compare(timer_address) == 0xFFFFFFFFFFFFFFFFULL);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 4: Counter increments after enable... ");
  rvx_timer_enable(timer_address);
  for (volatile int i = 0; i < 100; i++) // Delay to allow counter to increment
    asm volatile("nop");
  RVX_ASSERT(rvx_timer_get_counter(timer_address) > 0);
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 5: Counter stops incrementing after disable... ");
  rvx_timer_disable(timer_address);
  counter_value = rvx_timer_get_counter(timer_address);
  for (volatile int i = 0; i < 100; i++) // Delay to check counter remains the same
    asm volatile("nop");
  uint64_t new_counter_value = rvx_timer_get_counter(timer_address);
  RVX_ASSERT(new_counter_value == counter_value);
  if (error_flag)
  {
    rvx_uart_write_string(uart_address, "\nCounter value was: ");
    print_double_word_hex(new_counter_value);
    rvx_uart_write_string(uart_address, ", expected: ");
    print_double_word_hex(counter_value);
  }
  finish_test();

  rvx_uart_write_string(uart_address, "\nTest 6: Check if timer interrupt is triggered... ");
  rvx_timer_set_counter(timer_address, 0);
  rvx_timer_set_compare(timer_address, 50); // Set compare to a small value
  rvx_timer_enable(timer_address);
  // Wait for some time to allow interrupt to trigger
  for (volatile int i = 0; i < 100; i++)
    asm volatile("nop");
  finish_test();

  if (error_count == 0)
    rvx_uart_write_string(uart_address, "\n\nPassed all RVX HAL unit tests for the Timer module.");
  else
    rvx_uart_write_string(uart_address,
                          "\n[ERROR] Timer module failed on one or more unit tests. Please investigate.\n");

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

void finish_test()
{
  if (error_flag == 0)
  {
    rvx_uart_write_string(uart_address, "Passed.");
  }
  error_flag = 0;
}

void print_double_word_hex(uint64_t value)
{
  const char hex_chars[] = "0123456789ABCDEF";
  char buffer[19];
  buffer[0] = '0';
  buffer[1] = 'x';
  for (int i = 0; i < 16; i++)
  {
    buffer[17 - i] = hex_chars[(value >> (i * 4)) & 0xF];
  }
  buffer[18] = '\0';
  rvx_uart_write_string(uart_address, buffer);
}