---
hide: navigation
---

# RVX Hardware Docs

## Introduction

RVX is a microcontroller IP core developed in Verilog that implements the RV32I instruction set of RISC-V and optionnaly the Zmmul extension. It is designed for easy, seamless integration into embedded systems and FPGA designs, facilitating the rapid development of innovative RISC-V applications.

RVX can run real-time operating systems such as FreeRTOS, as well as bare-metal embedded software. Its design includes components such as memory, timers, and interfaces for UART, GPIO, and SPI communication, enabling RVX to integrate with a variety of sensors and actuators commonly used in embedded applications.

For information on how to develop a new application with RVX, see the [User Guide](userguide.md).

RVX implements the following features of the RISC-V specifications:

- the RV32I Base Integer Instruction Set, `v2.1`
- the Zicsr Extension for Control and Status Register (CSR) Instructions, `v2.0`
- the Machine-Level ISA, `v1.13`
- Optionnal Zmmul extension for integer multiplication, `v0.1`

## Architecture

A top-level view of RVX architecture is presented in the diagram below.

</br>

<figure markdown="span">
![Image title](images/rvx_architecture.svg){ width=70% }
<figcaption><strong>Figure 1.</strong> RVX Architecture</figcaption>
</figure>

## Source Files

The source files of RVX are saved in the `rtl/` folder of its [repository](https://github.com/rafaelcalcada/rvx).

## Configuration

The table below lists the configuration parameters of RVX Top Module, `rvx.v`:

| Parameter name and description                                                            | Value type          | Default value    |
| ----------------------------------------------------------------------------------------- | ------------------- | ---------------- |
| **BOOT_ADDRESS**</br>Memory address of the first instruction to be fetched and executed.  | 32-bit hexadecimal  | `32'h00000000`   |
| **CLOCK_FREQUENCY**</br>Frequency (in Hertz) of the `clock` input signal.                 | Integer             | `50000000`       |
| **UART_BAUD_RATE**</br>Baud rate of the UART module (in bauds per second).                | Integer             | `9600`           |
| **MEMORY_SIZE**</br>Size of the memory module (in bytes).                                 | Integer             | `8192`           |
| **MEMORY_INIT_FILE**</br>Absolute path to the memory initialization file.                 | String              | `(empty string)` |
| **GPIO_WIDTH**</br>Number of general-purpose I/O pins.                                    | Integer             | `1`              |
| **SPI_NUM_CHIP_SELECT**</br>Number of Chip Select (CS) lines for the SPI Controller.      | Integer             | `1`              |

## I/O Signals

The input/output signals of RVX Top Module, `rvx.v`, are listed in the table below:

| Pin name and description                        | Direction | Size                  |
| ----------------------------------------------- | --------- | --------------------- |
| **clock**</br>Clock input.                      | Input     | 1 bit                 |
| **reset**</br>Reset pin (active-high).          | Input     | 1 bit                 |
| **halt**</br>Halt pin (active-high).            | Input     | 1 bit                 |
| **uart_rx**</br>UART receiver pin.              | Input     | 1 bit                 |
| **uart_tx**</br>UART transmitter pin.           | Output    | 1 bit                 |
| **gpio_input**</br>GPIO input signals.          | Input     | `GPIO_WIDTH`          |
| **gpio_output_enable**</br>GPIO output enable.  | Output    | `GPIO_WIDTH`          |
| **gpio_output**</br>GPIO output signals.        | Output    | `GPIO_WIDTH`          |
| **sclk**</br>SPI Controller clock.              | Output    | 1 bit                 |
| **miso**</br>SPI Peripheral In Controller Out.  | Output    | 1 bit                 |
| **mosi**</br>SPI Peripheral Out Controller In.  | Input     | 1 bit                 |
| **cs**</br>SPI Chip Select lines.               | Output    | `SPI_NUM_CHIP_SELECT` |

## Memory Map

The devices in RVX are mapped to memory addresses as detailed below:

| Start address | Final address       | Range size (Bytes) | Device                     |
| ------------- | ------------------- | ------------------ | -------------------------- |
| `0x00000000`  | `0x(MEMORY_SIZE-1)` | `MEMORY_SIZE`      | RAM                        |
| `0x80000000`  | `0x8000000f`        | 16                 | UART Controller            |
| `0x80010000`  | `0x8001001f`        | 32                 | Timer                      |
| `0x80020000`  | `0x8002001f`        | 32                 | GPIO Controller            |
| `0x80030000`  | `0x8003001f`        | 32                 | SPI Controller             |

</br>
</br>