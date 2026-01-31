<p align="center"><img src="docs/source/images/rvx_logo.png" width="100"/></p>

**RVX** is a 32-bit RISC-V microcontroller written in Verilog for embedded, FPGA and ASIC applications. It is designed to be easily integrated into RTL designs, enabling developers to quickly build and deploy RISC-V systems — from rapid FPGA prototypes to full custom silicon.

**RVX Docs:** [https://rafaelcalcada.github.io/rvx][1]

## Features

- **RV32I** base integer instruction set + **Zicsr** and **Zmmul** extensions
- **Verified** with [RISC-V Arch Tests][2]
- **Software toolchain** with ready-to-run example applications
- **RTOS-ready** — runs FreeRTOS out of the box as well as bare-metal applications
- **Integrated peripherals** — SPI, GPIO, and UART plus programmable memory
- **RTL-friendly** — easy to integrate into FPGA and ASIC flows, with comprehensive [documentation][1]

## Example Projects

The quickest way to get started with RVX is to implement one of the example projects on your FPGA. Check it out:

- [Hello World Example][3]
- [FreeRTOS Example][4]
- [UART Example][5]
- [SPI Manager Example][6]
- [GPIO Example][7]
- [Timer Example][8]

## Featured FPGA Boards

The example projects above have been ported to the following FPGA boards:

- [Digilent Arty A7][9] (35T and 100T)
- [Digilent Cmod A7][10]

If you want help porting RVX examples to your FPGA board, please open a [new issue][11]. We will be happy to assist you.

## License

RVX is open source and distributed under the [MIT License][12].

[![RVX Tests](https://github.com/rafaelcalcada/rvx/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/rafaelcalcada/rvx/actions/workflows/tests.yml)

[1]: https://rafaelcalcada.github.io/rvx
[2]: https://github.com/riscv-non-isa/riscv-arch-test
[3]: https://rafaelcalcada.github.io/rvx/examples/helloworld
[4]: https://rafaelcalcada.github.io/rvx/examples/freertos
[5]: https://rafaelcalcada.github.io/rvx/examples/uart
[6]: https://rafaelcalcada.github.io/rvx/examples/spimanager
[7]: https://rafaelcalcada.github.io/rvx/examples/gpio
[8]: https://rafaelcalcada.github.io/rvx/examples/timer
[9]: https://rafaelcalcada.github.io/rvx/boards/arty_a7
[10]: https://rafaelcalcada.github.io/rvx/boards/cmod_a7
[11]: https://github.com/rafaelcalcada/rvx/issues
[12]: LICENSE