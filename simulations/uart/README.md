# RVX UART Module Tests

This directory contains the following tests for the RVX UART module:

- `testbench/` - Verilog RTL testbench compatible with Verilator and Vivado
- `unit_tests/` - Unit tests for the RVX HAL functionality related to the UART module

## Testbench

The testbench (`testbench/rvx_uart_tb.v`) verifies the UART module's RTL implementation using either Verilator or Vivado.

### Running with Verilator

From the RVX development container:

```bash
cd tests/uart/testbench/verilator
make run
```

A successful test run ends with the message: `Passed RTL testbench for the RVX UART module`.

> **Note**: To run outside the dev container, make sure `verilator` (v5.042 or higher) is installed and available in your `PATH`.

### Running with Vivado

To run with Vivado, you'll need to have it installed on your machine. The RVX development container does **not** include Vivado.

1. Launch **Vivado**
2. Go to **Tools** → **Run Tcl script...**
3. Select `tests/uart/testbench/vivado/create_test_project.tcl`
4. In the **Tcl Console**, run:

   ```tcl
   launch_simulation
   run -all
   ```

A successful test run ends with the message: `Passed RTL testbench for the RVX UART module`.

If you have `vivado` in your `PATH`, you can also run the testbench from the command line:

```bash
cd tests/uart/testbench/vivado
make run
```

## HAL Unit Tests

The HAL unit tests verify that the RVX Hardware Abstraction Layer API works correctly with the UART module. These tests run on an **Arty A7-35T Development Board** using the test program `uart_unit_tests.c`.

### Prerequisites

- Vivado (for synthesis and programming)
- Arty A7-35T Development Board
- Python 3 with `pyserial` installed

### Steps

1. Build the unit test program from the RVX development container:

    ```bash
    cd tests/uart/unit_tests
    make
    ```

    > **Note**: The next steps must be executed outside the dev container.

2. **Create the Vivado project**

   - Launch **Vivado**
   - Go to **Tools** → **Run Tcl script...**
   - Select `tests/uart/unit_tests/create_test_project.tcl` and click **OK**

3. **Open a serial terminal**

   ```bash
   python3 -m serial.tools.miniterm /dev/ttyUSB1 9600
   ```

   > **Note**: Replace `/dev/ttyUSB1` with your actual serial port (e.g., `/dev/ttyUSB0` on Linux, `COM3` on Windows)

4. **Program the FPGA**

   - Generate the bitstream in Vivado
   - Program the FPGA

5. **Run the tests**

   - Reset the board to start execution
   - Monitor the serial output

A successful test run ends with the message: `Passed all RVX HAL unit tests for the UART module`.