---
hide: navigation
---

## Introduction

This guide describes how to develop software applications for RVX. It is intended for embedded software engineers who want to learn how to write and build applications for RVX.

By following this guide, you will learn how to:

- set up a development environment for RVX, including obtaining the RISC-V GNU Toolchain
- write a CMake-based application for RVX using the RVX Hardware Abstraction Layer (RVX HAL)
- build the application and generate boot images for RVX

## RVX HAL Overview

[RVX HAL][1] is the Hardware Abstraction Layer for RVX, designed to make software development fast, easy, and maintainable. It provides drivers for RVX peripherals and simple access to processor registers — so you can focus on your application rather than low-level hardware details.

Built with CMake and the RISC-V GNU Toolchain, RVX HAL is designed to be included in RVX application projects via CMake's FetchContent module, setting up compiler and linker settings for RVX and providing functions for generating boot images.

This guide demonstrates how to use the RVX HAL to write a simple "Hello, World!" application for RVX, including both the application code and the CMake configuration to build it.

## Obtaining the RISC-V GNU Toolchain

The RVX software stack is built on top of the [RISC-V GNU Toolchain][2], which provides the compiler, assembler, linker, and other tools needed to build software for RISC-V targets like RVX. Therefore, to develop software for RVX, you first need to obtain the RISC-V GNU Toolchain. You can either build it from source or use it from the RVX Development Container. The next sections provide instructions for both options.

### Using the RVX Development Container

The RVX Development Container is a Docker container built from Ubuntu 24.04 LTS with the RISC-V GNU Toolchain and all its dependencies preinstalled. It is the easiest way to get started because it avoids the need to manually configure and build the toolchain, which can take a significant amount of time.

After starting the container, run all the commands in this guide inside the container terminal.

We assume you have [Docker](https://www.docker.com/get-started/) installed on your machine. To start the RVX Development Container, follow the steps below:

```title="1. Clone the RVX repository"
git clone https://github.com/rafaelcalcada/rvx
```

```title="2. Start the RVX Development Container"
cd rvx && \
docker run -it --name rvx-dev -v "$(pwd)":"/workspace/rvx" -w /workspace/rvx rafaelcalcada/rvx:latest
```

### Building from Source

You can also build the RISC-V GNU Toolchain from source on your machine. To do this, follow the steps below:

```bash title="1. Clone the RISC-V GNU Toolchain repository"
git clone https://github.com/riscv-collab/riscv-gnu-toolchain
```

```bash title="2. Install dependencies for your operating system"
# Ubuntu
sudo apt-get install \
    autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev \
    libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc \
    zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev

# Fedora/CentOS/RHEL/Rocky
sudo yum install \
    autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk bison flex \
    texinfo patchutils gcc gcc-c++ zlib-devel expat-devel libslirp-devel

# Arch Linux
sudo pacman -Syyu \
    autoconf automake curl python3 libmpc mpfr gmp gawk base-devel bison flex texinfo \
    gperf libtool patchutils bc zlib expat libslirp

# macOS
brew install \
    python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat texinfo flock libslirp
```

```bash title="3. Configure the RISC-V GNU Toolchain for RVX"
# Assuming you want to install the toolchain to /opt/riscv
# You need write permissions to the installation folder (/opt)
cd riscv-gnu-toolchain && ./configure --with-arch=rv32izicsr --with-abi=ilp32 --prefix=/opt/riscv
```

```bash title="4. Compile and install (this step may take a long time to complete)"
make -j $(nproc)
```

```bash title="5. Add the RISC-V GNU Toolchain binaries to your PATH"
echo 'export PATH=/opt/riscv/bin:$PATH' >> ~/.bashrc # Or ~/.zshrc if you use Zsh
source ~/.bashrc # Or source ~/.zshrc if you use Zsh
```

```bash title="6. Verify that the RISC-V GNU Toolchain is correctly installed"
# Should print the version of the RISC-V GNU Toolchain you just built
riscv32-unknown-elf-gcc --version
```

## Writing a "Hello, World!" application for RVX { #writing }

This section will walk you through writing a program that sends a "Hello, World!" message over the UART interface of RVX — along with the CMake setup to build it.

### Source code

An application for RVX typically includes the `rvx.h` header file provided by the RVX HAL, which contains definitions and functions to interact with RVX peripherals and processor registers. In this example, we will use the UART functions provided by the RVX HAL to send a message over the UART interface.

For the complete reference of the functions and definitions provided by the RVX HAL, see the [RVX HAL Reference][1].

To get started, create a project folder and add a `main.c` file with the following content:

```title="1. Create a folder for the new project"
mkdir rvx_hello_world && cd rvx_hello_world
```

```bash title="2. Create the main.c file"
vim main.c # Or other text editor of your choice
```

```c title="main.c"
#include "rvx.h"

void main(void) {
    // Initialize UART with baud rate 115200 bps.
    // Adjust the third argument - `clock_frequency_in_hz` - to match
    // the frequency of the clock signal connected to RVX (for example, 12 MHz).
    rvx_uart_init(RVX_UART_ADDRESS, 115200, 12000000);

    // Send the message "Hello, World!" over the UART.
    rvx_uart_write_string(RVX_UART_ADDRESS, "Hello, World!\n");
}
```

### CMake configuration

Let's now create a `CMakeLists.txt` file to configure the build for the "Hello, World!" application. This file uses CMake’s FetchContent module to download the RVX HAL and make it configure the required compiler and linker settings for RVX. At the end, it calls the `rvx_generate_boot_image()` function provided by the RVX HAL to generate boot images for the application.

```bash title="Create a CMakeLists.txt file for the project"
vim CMakeLists.txt # Or other text editor of your choice
```

```cmake title="CMakeLists.txt"
# Minimal CMake version required
cmake_minimum_required(VERSION 3.28)

# Name of the project/executable to be generated
set(APP_NAME "rvx_hello_world")

# Size of RVX tightly coupled memory (TCM)
# Set this to the same value you provided for the TCM_SIZE_IN_BYTES parameter of RVX top module.
set(RVX_MEMORY_SIZE 8192)

# Memory space reserved for stack growth
set(RVX_STACK_SIZE 1024)

# Memory space reserved for heap growth
set(RVX_HEAP_SIZE 1024)

# For bare-metal applications, set to TRUE.
# For FreeRTOS applications, set to FALSE or leave it undefined.
set(RVX_BARE_METAL TRUE)

# Fetch RVX HAL
# Note that the RVX HAL is included before the project() command,
# so that it can set up compiler and linker settings for RVX.
include(FetchContent)
FetchContent_Declare(rvx_hal
  GIT_REPOSITORY https://github.com/rafaelcalcada/rvx-hal.git
  GIT_TAG main
)
FetchContent_MakeAvailable(rvx_hal)

# Define the project and set languages
# ASM is needed for RVX startup code
project(${APP_NAME} LANGUAGES C ASM)

# Create the executable
add_executable(${APP_NAME} main.c)

# Link to RVX HAL
target_link_libraries(${APP_NAME} PRIVATE rvx_hal)

# This function generates the boot images for RVX
rvx_generate_boot_image(${APP_NAME})
```

## Building the application and generating boot images for RVX { #building }

To build and generate boot images for the application you just wrote, run the following commands in the terminal:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && \
cmake --build build
```

Once the build completes, you should see output similar to this:

```
Generated files:

Boot image (SPI flash): build/rvx_hello_world.bin
Boot image (FPGA/TCM):  build/rvx_hello_world.mem
ELF binary:             build/rvx_hello_world.elf
Disassembly:            build/rvx_hello_world.disasm

Booting RVX: https://rafaelcalcada.github.io/rvx/devguide/#booting-rvx

[100%] Built target rvx_hello_world
```

## Booting RVX { #booting-rvx }

RVX can boot from either an external SPI flash memory connected to its SPI interface or from its internal TCM memory. The generated `.bin` boot image is intended for booting from SPI flash, while the `.mem` image is intended for booting from TCM.

When you power on RVX, it will first attempt to boot from an external SPI flash memory. If no valid boot image is found there, it will attempt to boot from TCM.

### Booting from SPI flash

To boot from SPI flash, you need to write the `.bin` boot image into an SPI flash memory and connect it to the SPI interface of RVX. The boot image must be placed at address `0x00000000`, unless you have changed the default boot address (see [Configuration Parameters](design.md#configuration-parameters) in the [Design Reference](design.md)).

The exact method for programming the SPI flash will depend on the specific flash chip you are using, but it typically involves using a programmer device that connects to your computer via USB and can read/write data to the flash chip.

### Booting from TCM

In FPGA implementations, you can boot RVX without an external SPI flash by loading the `.mem` boot image into RVX tightly coupled memory (TCM) when programming the FPGA. To do this, set the [`TCM_BOOT_IMAGE_PATH`](design.md#configuration-parameters) parameter of RVX top module instance to the path of the `.mem` boot image. This will embed the boot image into the FPGA bitstream.

When you power on the FPGA, the bootloader will find the boot image in the TCM and start executing it. Make sure that RVX is not connected to an external SPI flash (or, if it is, that the flash does not contain a boot image); otherwise, RVX will attempt to boot from SPI flash first.

## Running the application { #running }

To run the application you just built, you need to implement RVX on an FPGA. The [Examples][3] page has detailed instructions on how to write the Verilog code to instantiate RVX for the "Hello, World!" project of this guide. It also provides pre-built FPGA bitstreams for supported FPGA boards and explains how to generate a bitstream for a generic FPGA.

For general instructions on how to start a new RTL project for RVX, see the [Design Reference](design.md). There you'll also find information about RVX top module ports and parameters, and how to integrate RVX into an existing RTL design.

<br/>
<br/>

[1]: hal.md
[2]: https://github.com/riscv/riscv-gnu-toolchain
[3]: examples