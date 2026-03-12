---
hide: navigation
---

<h1 id="hidden-homepage-title">RVX Documentation</h1>

<p align="center"><img src="images/rvx_logo.png" width="100"/></p>

<p align="center">Welcome to the official documentation for RVX!</p>

RVX is a RISC-V microcontroller IP core written in Verilog for embedded, FPGA, and ASIC applications. It offers a rich feature set while remaining easy to integrate, enabling rapid development of RISC-V systems — from FPGA prototypes to custom silicon.

## Features

- **RISC-V ISA**: Implements the RV32I integer instruction set + Zicsr and Zmmul extensions.
- **Verified**: Validated with the [RISC-V Tests][1] framework.
- **Software Stack**: [RVX HAL][2] makes developing software for RVX fast, easy, and maintainable.
- **Supports FreeRTOS** — Runs FreeRTOS out of the box, with full bare-metal support as well.
- **Built-in Peripherals** — Includes I2C, SPI, GPIO, and UART controllers and drivers.
- **Easy to Integrate** — Integrates cleanly into FPGA and ASIC workflows.
- **Comprehensive Documentation** — Includes [Developer Guide][3], [Design Reference][4], [RVX HAL Reference][2], and several [Example Projects][5].

## Getting Started

The fastest way to evaluate RVX is to build and run one of the example projects.

If you are new to RVX, start with the [Hello World][6] example. It demonstrates how to build and run a simple "Hello, World!" program for RVX, and introduces the RVX toolchain and development workflow.

Each example contains:

- Step-by-step build and run instructions
- Complete RTL and software source code
- Pre-built FPGA bitstreams for supported boards

### Example Projects

- [Hello World][6] - Introduces the RVX toolchain and development workflow with a simple "Hello, World!" program.
- [FreeRTOS][7] - Runs FreeRTOS on RVX, showcasing multitasking and real-time capabilities.
- [UART][8] - Example of serial communication using the UART peripheral.
- [SPI][9] - Communicates with external SPI devices using the SPI peripheral.
- [I2C][10] - Example of communication using the I2C controller.
- [GPIO][11] - Digital input/output control using the GPIO module.
- [Timer][12] - Time interval measurement and periodic interrupt generation.

## Software Stack

Software for RVX is developed using the **RISC-V GNU Toolchain** and **CMake**.

The [RVX Hardware Abstraction Layer][2] provides peripheral drivers and simple access to processor registers for RVX. It integrates with CMake to configure compiler and linker settings, making software development for RVX fast, easy, and maintainable.

For more details on the software stack and development workflow, see the [Developer Guide][3].

## RVX Design

RVX is written in synthesizable **Verilog** and is designed for compatibility with FPGA and ASIC workflows.

The design avoids vendor-specific constructs to ensure portability across synthesis tools.

## Documentation

The documentation for RVX includes:

- [Developer Guide][3] — Guide for developing software applications for RVX.
- [Design Reference][4] — Documentation for the RTL design of RVX, including architecture, source files, configuration parameters, I/O signals, and memory map.
- [RVX HAL Reference][2] — Reference for the RVX Hardware Abstraction Layer (HAL), including peripheral drivers and processor register access.
- [Example Projects][5] — Complete source code and instructions for building and running example applications.

## License

RVX is open source and distributed under the [MIT License][13].

[![RVX Tests](https://github.com/rafaelcalcada/rvx/actions/workflows/tests.yml/badge.svg)](https://github.com/rafaelcalcada/rvx/actions/workflows/tests.yml)

[1]: https://github.com/riscv-software-src/riscv-tests
[2]: https://rafaelcalcada.github.io/rvx/hal
[3]: https://rafaelcalcada.github.io/rvx/devguide
[4]: https://rafaelcalcada.github.io/rvx/design
[5]: https://rafaelcalcada.github.io/rvx/examples
[6]: https://rafaelcalcada.github.io/rvx/examples/helloworld
[7]: https://rafaelcalcada.github.io/rvx/examples/freertos
[8]: https://rafaelcalcada.github.io/rvx/examples/uart
[9]: https://rafaelcalcada.github.io/rvx/examples/spi
[10]: https://rafaelcalcada.github.io/rvx/examples/i2c
[11]: https://rafaelcalcada.github.io/rvx/examples/gpio
[12]: https://rafaelcalcada.github.io/rvx/examples/timer
[13]: LICENSE

<br/>
<br/>