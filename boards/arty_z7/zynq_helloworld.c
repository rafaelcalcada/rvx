/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xuartps_hw.h"

#define UART0 XPAR_UART0_BASEADDR
#define UART1 XPAR_UART1_BASEADDR

int main()
{
    init_platform();

    while (1)
    {
        u8 uart0_rx_data;
        u8 uart1_rx_data;

        // Receive from uart1, transmit to uart 0
        if (XUartPs_IsReceiveData(UART1))
        {
            uart1_rx_data = XUartPs_RecvByte(UART1);
            XUartPs_SendByte(UART0, uart1_rx_data);
        }

        // Receive from uart0, transmit to uart 1
        if (XUartPs_IsReceiveData(UART0))
        {
            uart0_rx_data = XUartPs_RecvByte(UART0);
            XUartPs_SendByte(UART1, uart0_rx_data);
        }
    }

    cleanup_platform();
    return 0;
}
