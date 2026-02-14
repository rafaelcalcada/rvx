---
hide: navigation
---

## Introduction

This guide describes how to develop software applications for RVX using the RISC-V GNU Toolchain and the RVX Hardware Abstraction Layer (RVX HAL). It is intended for embedded software engineers who want to build applications to run on RVX.

The guide is organized to follow the typical software development flow: setting up the RISC-V GNU Toolchain, writing and building the application with the RVX HAL, configuring RVX boot, and running the software on real hardware.

## Obtaining the RISC-V GNU Toolchain

To build software for RVX you need the [RISC-V GNU Toolchain](https://github.com/riscv/riscv-gnu-toolchain). You can either build it from source or use the RVX Development Container, which comes with the RISC-V GNU Toolchain and all its dependencies preinstalled.

### Using the RVX Development Container

The RVX Development Container is a Docker container built from Ubuntu 24.04 LTS with the RISC-V GNU toolchain and all its dependencies preinstalled. It is the easiest way to get started because it avoids the need to manually configure and build the toolchain, which can take a significant amount of time.

We assume you have [Docker](https://www.docker.com/get-started/) installed on your machine. To start the RVX Development Container, follow the steps below:

```title="1. Clone the RVX repository"
git clone https://github.com/rafaelcalcada/rvx
```

```title="2. Start the RVX Development Container"
cd rvx && \
docker run -it --name rvx-dev -v "$(pwd)":"/workspace/rvx" -w /workspace/rvx rafaelcalcada/rvx:latest
```

Breaking down the `docker run` command:

- `-it`: Runs the container in interactive mode with a terminal.
- `--name rvx-dev`: Names the container `rvx-dev` for easier reference.
- `-v "$(pwd)":"/workspace/rvx"`: Mounts the current directory to `/workspace/rvx` inside the container.
- `-w /workspace/rvx`: Sets the working directory inside the container to `/workspace/rvx`.
- `rafaelcalcada/rvx:latest`: The Docker image to use.

### Building from Source

You can also build the RISC-V GNU Toolchain from source on your local machine. To do this, follow the steps below:

```title="1. Clone the RISC-V GNU Toolchain repository"
git clone https://github.com/riscv-collab/riscv-gnu-toolchain
```

=== "Ubuntu"

    ```title="2. Install dependencies (Ubuntu)"
    sudo apt-get install \
        autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev \
        libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc \
        zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev
    ```

=== "Fedora/CentOS/RHEL/Rocky"

    ```title="2. Install dependencies (Fedora/CentOS/RHEL/Rocky)"
    sudo yum install \
        autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex \
        texinfo patchutils gcc gcc-c++ zlib-devel expat-devel libslirp-devel
    ```

=== "Arch Linux"

    ```title="2. Install dependencies (Arch Linux)"
    sudo pacman -Syyu \
        autoconf automake curl python3 libmpc mpfr gmp gawk base-devel bison flex texinfo \
        gperf libtool patchutils bc zlib expat libslirp
    ```

=== "OS X"

    ```title="2. Install dependencies (OS X)"
    brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat texinfo flock libslirp
    ```

```title="3. Configure the RISC-V GNU Toolchain for RVX"
cd riscv-gnu-toolchain && ./configure --with-arch=rv32izicsr --with-abi=ilp32 --prefix=/opt/riscv
```

!!! warning ""

    **Important:** The `--prefix` option defines the installation folder. You need to set it to a folder where you have `rwx` permissions. The command above assumes you have `rwx` permissions on `/opt`.

```title="4. Compile and install (this step may take a long time to complete)"
make -j $(nproc)
```

```bash title="5. Add the RISC-V GNU Toolchain binaries to your PATH"
cat "export PATH=/opt/riscv/bin:\$PATH" >> ~/.bashrc # Or ~/.zshrc if you use Zsh
source ~/.bashrc # Or source ~/.zshrc if you use Zsh
```

## Writing a new application

In this section, you’ll learn how to create a new software application for RVX using the **RVX Hardware Abstraction Layer** (RVX HAL). We’ll walk you through building a simple "Hello, World!" program that sends a message over the RVX UART, with CMake as the build system.

!!! note "About the RVX HAL"

    **RVX HAL** is the Hardware Abstraction Layer for RVX, designed to make developing software for RVX fast, easy, and maintainable. It provides drivers for SPI, GPIO, UART, and simple access to core registers — so you can focus on your application rather than low-level hardware details. The drivers provide a simple, straightforward API that is easy to use.

    Built with CMake and the RISC-V GNU Toolchain, RVX HAL sets up compiler flags and automatically compiles and links your code to RVX startup code. Its lightweight design makes integration simple — just add it to your project’s CMake and start coding.

```title="1. Create a new project directory"
mkdir rvx_hello_world && cd rvx_hello_world
```

```bash title="2. Create the main application file"
vim main.c # Or other text editor of your choice
```

```c title="main.c"
#include "rvx.h"

void main(void) {
    // Initialize UART with baud rate 115200, RVX clocked at 12 MHz
    rvx_uart_init(RVX_UART_ADDRESS, 115200, 12000000);

    // Send "Hello, World!" message over the RVX UART
    rvx_uart_write_string(RVX_UART_ADDRESS, "Hello, World!\n");
}
```

!!! note ""

    :point_right: Change the clock frequency parameter in `rvx_uart_init()` to match the frequency of the clock source you will connect to RVX in your design.

```bash title="3. Create a CMakeLists.txt file for the project"
vim CMakeLists.txt # Or other text editor of your choice
```

```cmake title="CMakeLists.txt"
# Minimal CMake version required
cmake_minimum_required(VERSION 3.28)

# Name of the project/executable to be generated
set(APP_NAME "rvx_hello_world")

# Memory and stack sizes (in bytes)
set(RVX_MEMORY_SIZE 8192)
set(RVX_STACK_SIZE 1024)
set(RVX_HEAP_SIZE 1024)

# Indicate that this is a bare-metal application
set(RVX_BARE_METAL TRUE)

# Fetch RVX HAL
include(FetchContent)
FetchContent_Declare(rvx_hal
  GIT_REPOSITORY https://github.com/rafaelcalcada/rvx-hal.git
  GIT_TAG main
)
FetchContent_MakeAvailable(rvx_hal)

# Define the project languages
project(${APP_NAME} LANGUAGES C ASM) # ASM is needed for RVX startup code

# Source files for the application
set(SOURCE_FILES main.c)

# Create the executable
add_executable(${APP_NAME} ${SOURCE_FILES})

# Link to RVX HAL
target_link_libraries(${APP_NAME} PRIVATE rvx_hal)

# Generate boot image
rvx_generate_boot_image(${APP_NAME})
```

```bash title="4. Build the application"
mkdir build && cd build && \
cmake .. -DCMAKE_BUILD_TYPE=Release && \
cmake --build .
```

!!! note ""

    :point_right: You need to execute the commands above inside the RVX Development Container or have the RISC-V GNU Toolchain binaries available in your terminal.

Once the build completes, you should see output similar to this:

```
Generated files:

Boot image (SPI flash): build/rvx_hello_world.bin
Boot image (FPGA/TCM):  build/rvx_hello_world.mem
ELF binary:             build/rvx_hello_world.elf
Disassembly:            build/rvx_hello_world.disasm

Booting RVX: https://rafaelcalcada.github.io/rvx/userguide/#booting-rvx

[100%] Built target rvx_hello_world
```

The `.bin` and `.mem` files are used for booting RVX. The `.elf` file is the standard executable format that contains the application code and can be used for debugging. The `.disasm` file is a human-readable disassembly of the application code, which can be useful for understanding what the compiled code looks like at the assembly level.

## Booting RVX { #booting-rvx }

The next step is to configure RVX boot to load and execute the application you just built. RVX can boot from an external SPI flash memory connected to its SPI interface, or directly from its TCM memory.

Booting from the TCM memory directly is only supported when implementing RVX in an FPGA. For production hardware, booting from external SPI flash is the typical approach.

### RVX boot sequence

When RVX powers on, it executes the following boot sequence:

1. RVX starts executing from its internal ROM, which contains a bootloader program.
2. The bootloader attempts to boot from an external SPI flash memory connected to RVX SPI interface.

    By default, it will look for a boot image at the beginning of the SPI flash memory (at SPI address `0x00000000`). This address can be changed by modifying the `SPI_BOOT_IMAGE_ADDRESS` parameter of the `rvx` module instance in your RTL design.

    If a valid boot image is found in the SPI flash, the bootloader will load it into RVX TCM memory, jump to its entry point, and start executing it.

3. The bootloader attempts to boot from the TCM memory.

    The bootloader will try to boot from the TCM memory if no valid boot image is found in the SPI flash, or if no SPI flash is connected. This is only supported in FPGA implementations of RVX, where you can initialize the TCM directly by embedding the TCM contents in the FPGA bitstream.

    If a valid boot image is found in the TCM, the bootloader will jump to its entry point and start executing it.

### Booting from SPI flash

To boot from SPI flash, you need to write the boot image (the `.bin` file generated in the previous step) into a SPI flash memory and connect it to RVX SPI interface. The exact method for programming the SPI flash will depend on the specific flash chip you are using, but it typically involves using a SPI flash programmer device that connects to your computer via USB and can read/write data to the flash chip.

Make sure to place the boot image at the correct address in the SPI flash (default is `0x00000000`) and connect the flash chip to RVX SPI interface according to your design. When you power on RVX, it should load the boot image from the SPI flash and start executing it.

### Booting from TCM (FPGA only)

To boot from TCM, change the `TCM_INIT_FILE` parameter of the `rvx` module instance in your RTL design to point to the path of the `.mem` file generated in the build step. This will initialize the TCM with the boot image and embed its contents in the FPGA bitstream. When you power the FPGA (programmed for RVX), it should find the boot image in the TCM and start executing it.

For FPGA implementations, this is the easiest way to get started as it avoids the need to program an external SPI flash. Note, however, that you can also use an external SPI flash with FPGA implementations if you prefer.

</br>
</br>