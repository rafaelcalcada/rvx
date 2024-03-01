// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __RVSTEEL_GPIO__
#define __RVSTEEL_GPIO__

#include <stdint.h>
#include "rvsteel_def.h"

typedef struct
{
  volatile uint32_t IN;
  volatile uint32_t OE;
  volatile uint32_t OUT;
  volatile uint32_t CLR;
  volatile uint32_t SET;
} GpioDevice;

#define GPIO_PIN0_OFFSET 0U
#define GPIO_PIN0_MASK (0x1U << GPIO_PIN0_OFFSET)

#define GPIO_PIN1_OFFSET 1U
#define GPIO_PIN1_MASK (0x1U << GPIO_PIN1_OFFSET)

#define GPIO_PIN2_OFFSET 2U
#define GPIO_PIN2_MASK (0x1U << GPIO_PIN2_OFFSET)

#define GPIO_PIN3_OFFSET 3U
#define GPIO_PIN3_MASK (0x1U << GPIO_PIN3_OFFSET)

#define GPIO_PIN4_OFFSET 4U
#define GPIO_PIN4_MASK (0x1U << GPIO_PIN4_OFFSET)

#define GPIO_PIN5_OFFSET 5U
#define GPIO_PIN5_MASK (0x1U << GPIO_PIN5_OFFSET)

#define GPIO_PIN6_OFFSET 6U
#define GPIO_PIN6_MASK (0x1U << GPIO_PIN6_OFFSET)

#define GPIO_PIN7_OFFSET 7U
#define GPIO_PIN7_MASK (0x1U << GPIO_PIN7_OFFSET)

#define GPIO_PIN8_OFFSET 8U
#define GPIO_PIN8_MASK (0x1U << GPIO_PIN8_OFFSET)

#define GPIO_PIN9_OFFSET 9U
#define GPIO_PIN9_MASK (0x1U << GPIO_PIN9_OFFSET)

#define GPIO_PIN10_OFFSET 10U
#define GPIO_PIN10_MASK (0x1U << GPIO_PIN10_OFFSET)

#define GPIO_PIN11_OFFSET 11U
#define GPIO_PIN11_MASK (0x1U << GPIO_PIN11_OFFSET)

#define GPIO_PIN12_OFFSET 12U
#define GPIO_PIN12_MASK (0x1U << GPIO_PIN12_OFFSET)

#define GPIO_PIN13_OFFSET 13U
#define GPIO_PIN13_MASK (0x1U << GPIO_PIN13_OFFSET)

#define GPIO_PIN14_OFFSET 14U
#define GPIO_PIN14_MASK (0x1U << GPIO_PIN14_OFFSET)

#define GPIO_PIN15_OFFSET 15U
#define GPIO_PIN15_MASK (0x1U << GPIO_PIN15_OFFSET)

static inline void gpio_enable_output(GpioDevice *GPIOx, const uint32_t pin_mask)
{
  SET_FLAG(GPIOx->OE, pin_mask);
}

static inline void gpio_enable_input(GpioDevice *GPIOx, const uint32_t pin_mask)
{
  CLR_FLAG(GPIOx->OE, pin_mask);
}

static inline uint32_t gpio_read(GpioDevice *GPIOx)
{
    return GPIOx->IN;
}

static inline void gpio_write(GpioDevice *GPIOx, const uint32_t value)
{
    GPIOx->OUT = value;
}

static inline void gpio_set(GpioDevice *GPIOx, const uint32_t pin_mask)
{
    GPIOx->SET = pin_mask;
}

static inline void gpio_clear(GpioDevice *GPIOx, const uint32_t pin_mask)
{
    GPIOx->CLR= pin_mask;
}

static inline void gpio_toggle(GpioDevice *GPIOx, const uint32_t pin_mask)
{
    INVERT_FLAG(GPIOx->OUT, pin_mask);
}

static inline int gpio_is_set(GpioDevice *GPIOx, const uint32_t pin_mask)
{
    return (GPIOx->IN & pin_mask) != 0;
}

static inline int gpio_is_clear(GpioDevice *GPIOx, const uint32_t pin_mask)
{
    return (GPIOx->IN & pin_mask) == 0;
}

#endif // __RVSTEEL_GPIO__
