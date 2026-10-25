// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include <FreeRTOS.h>
#include <task.h>

extern void freertos_risc_v_trap_handler(); ///< FreeRTOS trap handler (provided by FreeRTOS)

// RVX setup configuration for FreeRTOS (uses same clock frequency from FreeRTOSConfig.h, installs FreeRTOS trap
// handler)
const RvxSetup rvx_setup = {.clock_frequency = configCPU_CLOCK_HZ, .trap_handler = &freertos_risc_v_trap_handler};

void led_0_task(void *pvParameters); ///< FreeRTOS Task for blinking LED 0
void led_1_task(void *pvParameters); ///< FreeRTOS Task for blinking LED 1

uint8_t ucHeap[configTOTAL_HEAP_SIZE]; ///< Application-owned heap for FreeRTOS (heap_4.c)

void main(void)
{
  // RVX initialization
  rvx_init(&rvx_setup);

  // Initialize UART at 9600 baud
  rvx_uart_set_clock_divider(RVX_UART0, configCPU_CLOCK_HZ / 9600U);

  // Print welcome message
  rvx_uart_print(RVX_UART0, "RVX FreeRTOS Example Project\n\n");
  rvx_uart_print(RVX_UART0, "LEDs 0 and 1 will blink alternately at different rates.\n");

  // Configure pins 0 and 2 as outputs
  rvx_gpio_pin_direction(RVX_GPIO0, 0, RVX_GPIO_OUTPUT);
  rvx_gpio_pin_direction(RVX_GPIO0, 2, RVX_GPIO_OUTPUT);

  // Create 2 tasks for blinking the LEDs
  xTaskCreate(led_0_task, "LED 0 Task", configMINIMAL_STACK_SIZE, NULL, 1, NULL);
  xTaskCreate(led_1_task, "LED 1 Task", configMINIMAL_STACK_SIZE, NULL, 1, NULL);

  // Start the FreeRTOS scheduler
  vTaskStartScheduler();
}

// FreeRTOS Task for blinking LED 0 (connected to GPIO pin 0)
void led_0_task(void *pvParameters)
{
  (void)pvParameters;
  for (;;)
  {
    vTaskDelay(pdMS_TO_TICKS(500)); // Delay 500 ms
    rvx_gpio_pin_write(RVX_GPIO0, 0, RVX_GPIO_HIGH);
    vTaskDelay(pdMS_TO_TICKS(500)); // Delay 500 ms
    rvx_gpio_pin_write(RVX_GPIO0, 0, RVX_GPIO_LOW);
  }
}

// FreeRTOS Task for blinking LED 1 (connected to GPIO pin 2)
void led_1_task(void *pvParameters)
{
  (void)pvParameters;
  for (;;)
  {
    vTaskDelay(pdMS_TO_TICKS(1000)); // Delay 1000 ms
    rvx_gpio_pin_write(RVX_GPIO0, 2, RVX_GPIO_HIGH);
    vTaskDelay(pdMS_TO_TICKS(1000)); // Delay 1000 ms
    rvx_gpio_pin_write(RVX_GPIO0, 2, RVX_GPIO_LOW);
  }
}

// This handler is called by FreeRTOS for all interrupts except timer interrupts.
void freertos_risc_v_application_interrupt_handler(uint32_t interrupt_cause)
{
  (void)interrupt_cause; // Suppress unused parameter warning
  rvx_uart_print(RVX_UART0, "Interrupt occurred!\n");
  // Handle here interrupts as needed
}

// This handler is called by FreeRTOS for all exceptions.
void freertos_risc_v_application_exception_handler(uint32_t exception_cause)
{
  (void)exception_cause; // Suppress unused parameter warning
  rvx_uart_print(RVX_UART0, "Exception occurred!\n");
  // Handle here exceptions as needed
}