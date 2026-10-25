// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include "rvx_sdk_test_framework.h"

extern const RvxTestSuiteDescriptor rvx_sdk_uart_test_suite;
extern const RvxTestSuiteDescriptor rvx_sdk_gpio_test_suite;
extern const RvxTestSuiteDescriptor rvx_sdk_spi_test_suite;
extern const RvxTestSuiteDescriptor rvx_sdk_timer_test_suite;

static const RvxTestSuiteDescriptor *const rvx_sdk_test_suites[] = {
    &rvx_sdk_uart_test_suite,
    &rvx_sdk_gpio_test_suite,
    &rvx_sdk_spi_test_suite,
    &rvx_sdk_timer_test_suite,
};

static const size_t rvx_sdk_test_suite_count = RVX_ARRAY_SIZE(rvx_sdk_test_suites);

const RvxSetup rvx_setup = {.clock_frequency = 50000000U, .trap_handler = RVX_DEFAULT_TRAP_HANDLER};

extern void rvx_timer0_interrupt_handler(void);
extern void rvx_uart0_interrupt_handler(void);

// Interrupt handler for the SDK tests.
// Dispatches to the appropriate peripheral-specific handler based on the cause code.
void rvx_interrupt_handler(uint32_t interrupt_cause)
{
  if (interrupt_cause == RVX_CAUSE_EXTERNAL_IRQ_M)
  {
    const uint8_t source_id = rvx_plic_claim_source(RVX_PLIC0);
    if (source_id == RVX_PLIC0_SOURCE_UART0)
      rvx_uart0_interrupt_handler();
    if (source_id == RVX_PLIC0_SOURCE_TIMER0)
      rvx_timer0_interrupt_handler();
  }
}

int main(void)
{
  rvx_init(&rvx_setup);

  rvx_plic_enable_source(RVX_PLIC0, RVX_PLIC0_SOURCE_UART0);
  rvx_plic_enable_source(RVX_PLIC0, RVX_PLIC0_SOURCE_TIMER0);
  rvx_plic_set_priority(RVX_PLIC0, RVX_PLIC0_SOURCE_UART0, RVX_PLIC_MAX_PRIORITY);
  rvx_plic_set_priority(RVX_PLIC0, RVX_PLIC0_SOURCE_TIMER0, RVX_PLIC_MAX_PRIORITY);

  const bool all_tests_passed = rvx_test_run_suites(rvx_sdk_test_suites, rvx_sdk_test_suite_count);

  if (all_tests_passed)
    rvx_uart_print(RVX_UART0, "\nPassed all RVX SDK tests.\n\n");
  else
    rvx_uart_print(RVX_UART0, "\nERROR: Some RVX SDK tests failed. Check the test output for details.\n\n");

  volatile uint32_t *const simulator_status = (volatile uint32_t *)0x00000000;
  *simulator_status = all_tests_passed ? 0U : 1U;

  return all_tests_passed ? 0 : 1;
}