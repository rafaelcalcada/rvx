// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __RVSTEEL_SOC__
#define __RVSTEEL_SOC__

#include "rvsteel_csr.h"
#include "rvsteel_uart.h"
#include "rvsteel_mtimer.h"
#include "rvsteel_gpio.h"

// Base address
#define MAIN_BASE_ADDR 0x00000000U

// Map devices
#define UART0_BASE (MAIN_BASE_ADDR + 0x80000000U)
#define MTIMER0_BASE (MAIN_BASE_ADDR + 0x80010000U)
#define GPIO0_BASE (MAIN_BASE_ADDR + 0x80020000U)

// List devices
#define UART0 ((UartDevice *)UART0_BASE)
#define MTIMER0 ((MTimerDevice *)MTIMER0_BASE)
#define GPIO0 ((GpioDevice *)GPIO0_BASE)

// Machine Interrupt mask
#define IRQ_MTIMER0_MASK MIP_MIE_MASK_MTI
#define IRQ_UART0_MASK MIP_MIE_MASK_F0I

// Machine Interrupt Vectors
#define IRQ_MTIMER0_VECTOR irq_m_timer
#define IRQ_UART0_VECTOR irq_fast_0

#endif // __RVSTEEL_SOC__
