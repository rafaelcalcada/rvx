// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include <FreeRTOS.h>
#include <task.h>

void led_0_task(void *pvParameters); ///< FreeRTOS Task for blinking LED 0
void led_1_task(void *pvParameters); ///< FreeRTOS Task for blinking LED 1

extern void freertos_risc_v_trap_handler(); ///< FreeRTOS trap handler
extern uint8_t __heap_start;                ///< Heap start symbol provided by RVX linker script
extern uint8_t __heap_end;                  ///< Heap end symbol provided by RVX linker script

void main(void)
{
  // Initialize UART at 9600 baud (assuming clock frequency is 12 MHz)
  rvx_uart_init(RVX_UART_ADDRESS, 9600, 12000000);

  // Print welcome message
  rvx_uart_write_string(RVX_UART_ADDRESS, "RVX FreeRTOS Example Project\n\n");
  rvx_uart_write_string(
      RVX_UART_ADDRESS,
      "LEDs 0 and 1 will blink alternately at different rates with the help of FreeRTOS task scheduler.\n");

  // Configure pins 0 and 2 as outputs
  rvx_gpio_pin_configure(RVX_GPIO_ADDRESS, 0, RVX_GPIO_OUTPUT);
  rvx_gpio_pin_configure(RVX_GPIO_ADDRESS, 2, RVX_GPIO_OUTPUT);

  // Configure FreeRTOS heap regions (this example used FreeRTOS heap_5.c)
  HeapRegion_t xHeapRegions[] = {{&__heap_start, (size_t)(&__heap_end - &__heap_start)}, {NULL, 0}};

  // Initialize heap_5 with the regions
  vPortDefineHeapRegions(xHeapRegions);

  // Create 2 tasks for blinking LEDs
  xTaskCreate(led_0_task, "LED 0 Task", configMINIMAL_STACK_SIZE, NULL, 1, NULL);
  xTaskCreate(led_1_task, "LED 1 Task", configMINIMAL_STACK_SIZE, NULL, 1, NULL);

  // Start the FreeRTOS scheduler
  vTaskStartScheduler();
}

// FreeRTOS Task for blinking LED 0
void led_0_task(void *pvParameters)
{
  (void)pvParameters;
  for (;;)
  {
    vTaskDelay(pdMS_TO_TICKS(500)); // Delay 500 ms
    rvx_gpio_pin_set(RVX_GPIO_ADDRESS, 0);
    vTaskDelay(pdMS_TO_TICKS(500)); // Delay 500 ms
    rvx_gpio_pin_clear(RVX_GPIO_ADDRESS, 0);
  }
}

// FreeRTOS Task for blinking LED 1
void led_1_task(void *pvParameters)
{
  (void)pvParameters;
  for (;;)
  {
    vTaskDelay(pdMS_TO_TICKS(1000)); // Delay 1000 ms
    rvx_gpio_pin_set(RVX_GPIO_ADDRESS, 2);
    vTaskDelay(pdMS_TO_TICKS(1000)); // Delay 1000 ms
    rvx_gpio_pin_clear(RVX_GPIO_ADDRESS, 2);
  }
}

// Overrides RVX default trap handler implementation, delegating trap handling to FreeRTOS trap handler.
RVX_NAKED void rvx_trap_handler_default(void)
{
  freertos_risc_v_trap_handler();
}

// This handler is called by FreeRTOS for all interrupts except timer interrupts.
void freertos_risc_v_application_interrupt_handler(uint32_t interrupt_cause)
{
  (void)interrupt_cause;
  rvx_uart_write_string(RVX_UART_ADDRESS, "Interrupt occurred!\n");

  // Example

  // if (interrupt_cause == RVX_TRAP_CAUSE_MEI) // Machine External Interrupt
  // {
  //   // Handle external interrupt
  // }
}

// This handler is called by FreeRTOS for all exceptions.
void freertos_risc_v_application_exception_handler(uint32_t exception_cause)
{
  (void)exception_cause;
  rvx_uart_write_string(RVX_UART_ADDRESS, "Exception occurred!\n");

  // Example

  // if (exception_cause == RVX_TRAP_CAUSE_BREAKPOINT)
  // {
  //   // Handle breakpoint exception
  // }
}