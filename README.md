<p align="center"><img src="docs/source/images/rvx_logo.png" width="100"/></p>

RVX is a 32-bit RISC-V microcontroller written in Verilog for embedded and FPGA applications. It is designed to be easy to integrate into RTL designs, enabling developers to quickly build and deploy RISC-V projects.

**RVX Docs:** [https://rafaelcalcada.github.io/rvx][1]

## Features

- Software development framework with example applications
- Supports FreeRTOS and bare-metal applications
- Programmable memory and peripherals: SPI, GPIO and UART
- RISC-V ISA support: RV32I instruction set, Zicsr extension, Zmmul extension, full M-mode support
- Verified with RISC-V Test Suite for compliance with specifications
- Standard RISC-V interrupts plus 16 fast interrupt lines
- Comprehensive [documentation][1] included

## Example Projects

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

If you want help porting RVX examples to your FPGA board, please open a [new issue][11]. We will be happy to assist you.

## License

RVX is open source and distributed under the [MIT License][10].

[![RVX Tests](https://github.com/rafaelcalcada/rvx/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/rafaelcalcada/rvx/actions/workflows/tests.yml)

[1]: https://rafaelcalcada.github.io/rvx
[2]: https://rafaelcalcada.github.io/rvx/examples/helloworld
[3]: https://rafaelcalcada.github.io/rvx/examples/freertos
[4]: https://rafaelcalcada.github.io/rvx/examples/uart
[5]: https://rafaelcalcada.github.io/rvx/examples/spimanager
[6]: https://rafaelcalcada.github.io/rvx/examples/gpio
[7]: https://rafaelcalcada.github.io/rvx/examples/timer
[8]: https://rafaelcalcada.github.io/rvx/boards/arty_a7
[9]: https://rafaelcalcada.github.io/rvx/boards/cmod_a7
[10]: LICENSE
[11]: https://github.com/rafaelcalcada/rvx/issues