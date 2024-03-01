# RISC-V Steel System-on-Chip { class="main-section-title" }
<h2 class="main-section-subtitle">Software Guide</h2>

## First steps

To compile, assemble and link programs for RISC-V machines you need the [RISC-V GNU Toolchain](https://github.com/riscv/riscv-gnu-toolchain). You can install and configure the toolchain for use with RISC-V Steel by following the steps below:

<h4>1. Get the source files</h4>

```
git clone https://github.com/riscv/riscv-gnu-toolchain
```

<h4>2. Install dependencies</h4>

=== "Ubuntu"

    ```
    sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev
    ```

=== "Fedora/CentOS/RHEL OS"

    ```
    sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
    ```

=== "Arch Linux"

    ```
    sudo pacman -Syyu autoconf automake curl python3 libmpc mpfr gmp gawk base-devel bison flex texinfo gperf libtool patchutils bc zlib expat
    ```

=== "OS X"

    ```
    brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat texinfo flock
    ```

<h4>3. Configure it for RISC-V Steel</h4>

```
cd riscv-gnu-toolchain
./configure --with-arch=rv32i --with-abi=ilp32 --prefix=/opt/riscv
```

<h4>4. Compile and install</h4>

```
make -j $(nproc)
```

## Make a copy of the template project

Once you have installed the RISC-V GNU Toolchain you can start a new application. The easiest way to start is making a copy of the template project (located at `software/template_project/`). The template project comes with a Makefile to help you automate the tasks of compiling the software and generating a memory initialization file for the SoC IP.

## Configure your project

You configure the template project by editing the Makefile in it. The Makefile starts with the definition of the four variables you need to set for your project. The expected value for these variables are described in the table below.

| Variable            | Description                                                                                                       |
| ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| ``PROGRAM_NAME``    | The name of the ELF executable to be generated. Ex: *myapp*.                                                      |
| ``MEMORY_SIZE``     | The size you set for the RAM memory of the SoC IP (the same value you provided </br>for the `MEMORY_SIZE` parameter when instantiating the `rvsteel_soc` module). |
| ``RVSTEEL_API_DIR`` | Path to the directory containing the source files of the [Software API](api.md).                                  |
| ``RISCV_PREFIX``    | Path to the RISC-V GNU Toolchain binaries in your machine + RISC-V binaries prefix.                               |

## Write your application

The template project comes with a `main.c` file containing a Hello World example. You can edit this file, rename it or delete it.

You can add as many source files to the project as you want. The Makefile was written so that all `*.c` source files you add to the project get automatically compiled when you run `make`.

The SoC IP has an API with functions you can call in your software to configure and control the devices in it. The [Software API](api.md) page contains the documentation for the available API calls.

## Compile and generate the memory init file

Run `make` to build your application and generate the memory initialization file. A successfull build output is similar to this:

```
Generated files:
-- ELF executable   : build/my_app.elf
-- Disassembly      : build/my_app.objdump
-- Memory init file : build/my_app.hex

The memory size is set to 8192 bytes.
```

The `.hex` file can now be used to initialize RISC-V Steel SoC IP memory and run the application.

## Run the application

When you synthesize the SoC IP for your FPGA, the data to be loaded into the SoC IP memory gets embedded in the FPGA bitstream. Every time you power on your FPGA the memory gets initialized and your program runs immediately afterwards.

You define the initial content of the SoC IP memory through the `MEMORY_INIT_FILE` parameter. This parameter expects a string with the path to the memory initialization file you generated in the steps above.

```verilog
// This example shows an instantiation of the SoC IP top module
// configured to load the contents of a file named `hello_world.hex`

// The initial contents of the SoC IP memory gets embedded in the
// FPGA bitstream when the module is synthesized

rvsteel_soc                  #(
    .CLOCK_FREQUENCY          (50000000           ),
    .UART_BAUD_RATE           (9600               ),
    .MEMORY_SIZE              (8192               ),
    .MEMORY_INIT_FILE         ("hello_world.hex"  ),
    .BOOT_ADDRESS             (32'h00000000       ))
rvsteel_soc_instance          (
    .clock                    (clock_50mhz        ),
    .reset                    (reset              ),
    .uart_rx                  (uart_rx            ),
    .uart_tx                  (uart_tx            ));
```

</br>
</br>