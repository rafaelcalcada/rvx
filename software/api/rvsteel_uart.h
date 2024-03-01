// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __UART__
#define __UART__

#include <stdint.h>
#include "rvsteel_def.h"

typedef struct
{
  volatile uint32_t TX;
  volatile uint32_t RX;
} UartDevice;

static inline uint8_t uart_read(UartDevice *UARTx)
{
  return UARTx->RX;
}

static inline void uart_write(UartDevice *UARTx, uint8_t data)
{
  UARTx->TX = data;
}

static inline int uart_write_busy(UartDevice *UARTx)
{
  return UARTx->TX != 1;
}

static inline void uart_send_char(UartDevice *UARTx, const char c)
{
  while ((UARTx->TX != 1))
  {
    __NOP();
  }

  UARTx->TX = c;
}

static inline void uart_send_string(UartDevice *UARTx, const char *str)
{
  while (*(str) != '\0')
  {
    uart_send_char(UARTx, *(str));
    str++;
  }
}

#endif // __UART__
