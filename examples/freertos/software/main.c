// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "libsteel.h"
#include <FreeRTOS.h>
#include <task.h>

#define DEFAULT_MTIMER (MTimerController *)0x80010000
#define DEFAULT_GPIO (GpioController *)0x80020000

extern void freertos_risc_v_mtimer_interrupt_handler();
extern void freertos_risc_v_exception_handler();

// FreeRTOS heap
uint8_t ucHeap[configTOTAL_HEAP_SIZE];

// Override the trap handler for Machine Timer Interrupts: make it call FreeRTOS MTimer interrupt
// handler.
__NAKED void mti_irq_handler()
{
  freertos_risc_v_mtimer_interrupt_handler();
}

// Override the default trap handler (for non-vectored mode): make it call FreeRTOS exception
// handler.
__NAKED void default_trap_handler()
{
  freertos_risc_v_exception_handler();
}

// Task 1: toggle LED #0 each 500ms
void task1(void *pvParameters)
{
  configASSERT((uint32_t)pvParameters == 1UL);
  for (;;)
  {
    vTaskDelay(500);
    gpio_set(DEFAULT_GPIO, 0);
    vTaskDelay(500);
    gpio_clear(DEFAULT_GPIO, 0);
  }
}

// Task 2: toggle LED #1 each 1000ms
void task2(void *pvParameters)
{
  configASSERT((uint32_t)pvParameters == 1UL);
  for (;;)
  {
    vTaskDelay(1000);
    gpio_set(DEFAULT_GPIO, 1);
    vTaskDelay(1000);
    gpio_clear(DEFAULT_GPIO, 1);
  }
}

int main(void)
{
  csr_enable_vectored_mode_irq();
  mtimer_enable(DEFAULT_MTIMER);

  gpio_set_output(DEFAULT_GPIO, 0);
  gpio_set_output(DEFAULT_GPIO, 1);

  xTaskCreate(task1, "task1", configMINIMAL_STACK_SIZE, (void *)1, 1, NULL);
  xTaskCreate(task2, "task2", configMINIMAL_STACK_SIZE, (void *)1, 1, NULL);

  vTaskStartScheduler();

  while (1)
    ;
}