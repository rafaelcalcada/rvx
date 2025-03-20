# Processor Core IP Tests

This directory contains tests to verify that instructions implemented by the Processor Core IP are compliant with the RISC-V specifications.

The tests consist of Verilog simulations that run unit test programs from the [RISC-V Architecture Test](https://github.com/riscv-non-isa/riscv-arch-test/) repository. Each unit test program tests an instruction and generates a signature after its execution, which is compared to a golden reference. The signature only matches the golden reference if the instruction implements its function correctly.

The tests can be run with **Verilator** and **AMD Xilinx Vivado**. At the end of a successful run the following message is printed:

```
------------------------------------------------------------------------------------------
RVX Processor Core IP passed ALL unit tests from RISC-V Architectural Test
------------------------------------------------------------------------------------------
```

## How do I run the tests?

### Using Verilator

To run the unit tests using Verilator do:

```bash
cd verilator
make # verilates the unit tests
python unit_tests.py # run and show results
```

Verilator version 5.0 or higher is required. For the available options run:

```bash
python unit_tests.py --help
```

### Using AMD Xilinx Vivado

* Open **AMD Xilinx Vivado**
* Click on **Run Tcl script...** in the **Tools** menu
* Select the file `vivado/create-test-project.tcl` and click **Ok**

    A Vivado project to run the unit tests will be created.

* To run the unit tests type `launch_simulation; run -all` in Vivado **Tcl Console** and press Enter.

