---
hide: navigation
---

## Introduction

This document describes how to develop software applications for RVX using the **RISC-V GNU Toolchain** and the **RVX Hardware Abstraction Layer** (RVX HAL). It is intended for embedded software engineers who want to build applications to run on RVX.

The guide is organized to follow the typical software development flow: setting up the RISC-V GNU Toolchain, writing and building applications with the RVX HAL, configuring RVX, and running the software on real hardware. Each chapter builds on the previous one, so new users are encouraged to read the guide in order.

## Obtaining the RISC-V GNU Toolchain

To build software for RVX you need the [RISC-V GNU Toolchain](https://github.com/riscv/riscv-gnu-toolchain), a suite of compilers and development tools for the RISC-V architecture. You can either build it from source on your machine or use the **RVX Development Container**, which comes with the RISC-V GNU Toolchain and all its dependencies preinstalled.

### Using the RVX Development Container

The RVX Development Container is a Docker container built from Ubuntu 24.04 LTS with the RISC-V GNU toolchain and all its dependencies preinstalled. It is the easiest way to get started because it avoids the need to manually configure and build the toolchain, which can take a significant amount of time.

We assume you have [Docker](https://www.docker.com/get-started/) installed on your machine. To use the RVX Development Container:

```title="1. Clone the RVX repository"
git clone https://github.com/rafaelcalcada/rvx
```

```title="2. Start the RVX Development Container"
cd rvx
docker run -it --name rvx-dev -v "$(pwd)":"/workspace/rvx" -w /workspace/rvx rafaelcalcada/rvx:latest
```

Breaking down the `docker run` command:

- `-it`: Runs the container in interactive mode with a terminal.
- `--name rvx-dev`: Names the container `rvx-dev` for easier reference.
- `-v "$(pwd)":"/workspace/rvx"`: Mounts the current directory to `/workspace/rvx` inside the container.
- `-w /workspace/rvx`: Sets the working directory inside the container to `/workspace/rvx`.
- `rafaelcalcada/rvx:latest`: The Docker image to use.

### Building from Source

You can also build the RISC-V GNU Toolchain from source on your local machine. This process can take a significant amount of time depending on your machine's performance.

Follow the steps to configure and build the RISC-V GNU Toolchain for RVX:

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

```title="4. Compile and install (this step may take a while)"
make -j $(nproc)
```

To make the RISC-V GNU Toolchain binaries available in your terminal, add the following line to your shell configuration file (e.g., `~/.bashrc` or `~/.zshrc`):

```bash
export PATH=/opt/riscv/bin:$PATH
```

## Writing a New Application

In this section, you’ll learn how to create a new software application for RVX using the **RVX Hardware Abstraction Layer** (RVX HAL). We’ll walk you through building a simple "Hello, World!" program that sends a message over the RVX UART, with CMake as the build system.

!!! note "About the RVX HAL"

    **RVX HAL** is the Hardware Abstraction Layer for RVX, designed to make developing software for RVX fast, easy, and maintainable. It provides drivers for SPI, GPIO, UART, and simple access to core registers — so you can focus on your application rather than low-level hardware details. The drivers provide a simple, straightforward API that is easy to use.

    Built with CMake and the RISC-V GNU Toolchain, RVX HAL sets up compiler flags and automatically compiles and links your code to RVX startup code. Its lightweight design makes integration simple — just add it to your project’s CMake and start coding.

```title="1. Create a new project directory"
mkdir rvx_hello_world && cd rvx_hello_world
```

```bash title="2. Create the main application file"
# Or other text editor of your choice
vim main.c
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

```bash title="3. Create the application's CMakeLists.txt file"
# Or other text editor of your choice
vim CMakeLists.txt
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

# Generate memory initialization file
rvx_generate_memory_init_file(${APP_NAME})
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
Memory init file:   /home/rvx/example/build/rvx_hello_world.mem
ELF binary:         /home/rvx/example/build/rvx_hello_world
Disassembly:        /home/rvx/example/build/rvx_hello_world.disasm

Memory usage report (total memory size: 8192 bytes)
      text       data        bss      total filename
       284          0          4        288 /home/rvx/example/build/rvx_hello_world

[100%] Built target rvx_hello_world
```

### Configuring RVX to Run the Application



</br>
</br>