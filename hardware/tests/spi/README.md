# SPI Controller IP Tests

This directory contains tests to verify the correct functioning of the SPI Controller. The tests are divided into hardware and software unit tests.

## How do I run the tests?

### Software Unit Tests

The software unit tests consist of an instance of RVX MCU that runs the test program `software/unit_tests.c`. They verify the correct functioning of the API calls used to control the SPI module. This instance of RVX MCU was built in Vivado and is meant to be run on an Arty-A7 development board.

* Open **AMD Xilinx Vivado**
* Click on **Run Tcl script...** in the **Tools** menu
* Select the file `software/arty_a7/create_unit_tests_project.tcl` and click **Ok**

    A Vivado project to run the unit tests will be created.

* Open a PySerial terminal by running `python -m serial.tools.miniterm`
* Generate the bitstream and program the FPGA
* The tests will start running. A successful run ends with the following message:

```
Passed all SPI Controller Software Unit Tests.
```

### Hardware Unit Tests

The hardware unit tests consist of a Verilog testbench. Follow the steps below to run the testbench on Vivado:

* Open **AMD Xilinx Vivado**
* Click on **Run Tcl script...** in the **Tools** menu
* Select the file `hardware/create_unit_tests_project.tcl` and click **Ok**

    A Vivado project to run the unit tests will be created.

* To run the unit tests type `launch_simulation; run -all` in Vivado **Tcl Console** and press Enter.