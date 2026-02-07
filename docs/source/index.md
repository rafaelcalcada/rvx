---
hide: navigation
---

<h1 id="hidden-homepage-title">RVX Documentation</h1>

<p align="center"><img src="images/rvx_logo.png" width="100"/></p>

<p align="center">Welcome to the official documentation for <strong>RVX</strong>!</p>

**RVX** is a 32-bit RISC-V microcontroller written in Verilog for embedded, FPGA and ASIC applications. It is designed to be easily integrated into RTL designs, enabling developers to quickly build and deploy RISC-V systems — from rapid FPGA prototypes to full custom silicon.

## Features

- **RV32I** base integer instruction set + **Zicsr** and **Zmmul** extensions
- **Verified** with RISC-V Test Suite
- **Software toolchain** with ready-to-run example applications
- **RTOS-ready** — runs FreeRTOS out of the box as well as bare-metal applications
- **Integrated peripherals** — SPI, GPIO, and UART plus programmable memory
- **RTL-friendly** — easy to integrate into FPGA and ASIC flows, with comprehensive [documentation][1]

## Getting Started

The quickest way to get started with RVX is to implement one of the example projects on your FPGA. Check it out:

- [Hello World Example][2]
- [FreeRTOS Example][3]
- [UART Example][4]
- [SPI Manager Example][5]
- [GPIO Example][6]
- [Timer Example][7]

## Featured FPGA Boards

The example projects above have been ported to the following FPGA boards:

- [Digilent Arty A7][8] (35T and 100T)
- [Digilent Cmod A7][9]

If you want help porting RVX examples to your FPGA board, please open a [new issue][10]. We will be happy to assist you.

[1]: https://rafaelcalcada.github.io/rvx
[2]: https://rafaelcalcada.github.io/rvx/examples/helloworld
[3]: https://rafaelcalcada.github.io/rvx/examples/freertos
[4]: https://rafaelcalcada.github.io/rvx/examples/uart
[5]: https://rafaelcalcada.github.io/rvx/examples/spimanager
[6]: https://rafaelcalcada.github.io/rvx/examples/gpio
[7]: https://rafaelcalcada.github.io/rvx/examples/timer
[8]: https://rafaelcalcada.github.io/rvx/boards/arty_a7
[9]: https://rafaelcalcada.github.io/rvx/boards/cmod_a7
[10]: https://github.com/rafaelcalcada/rvx/issues
[11]: LICENSE

</br>
</br>