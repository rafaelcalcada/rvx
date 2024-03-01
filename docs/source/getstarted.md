# Getting Started

## Introduction

This guide shows how to synthesize the SoC IP demo project for two Digilent development boards: [Arty A7](https://digilent.com/reference/programmable-logic/arty-a7/reference-manual) and [Cmod A7](https://digilent.com/reference/programmable-logic/cmod-a7/reference-manual).

The demo project is a Hello World application that makes the SoC IP send a "Hello World!" message to your computer via the board's UART interface. Its goal is to quickly introduce you to the SoC IP so that you can expand it and develop your own embedded applications.

!!! abstract ""

    __Looking for the demo project for other development boards?__

    We are willing to help! Let us know which development board you would like the demo project ported to by opening a [new issue](https://github.com/riscv-steel/riscv-steel/issues/new) on GitHub.

## First steps

To follow this guide you'll need one of the following FPGA boards:

* **Digilent** [**Arty A7**](https://digilent.com/reference/programmable-logic/arty-a7/reference-manual)

* **Digilent** [**Cmod A7**](https://digilent.com/reference/programmable-logic/cmod-a7/reference-manual)

Also, make sure you have the following software installed on your computer:

* **AMD Xilinx Vivado**

    The latest version of AMD Xilinx Vivado is available for [download here](https://www.xilinx.com/support/download.html).

    During installation, remember to include support for the Artix-7 device family and the cable drivers.

* **PySerial**

    [PySerial](https://pyserial.readthedocs.io/en/latest/index.html) is a Python package for communication over serial protocol. It can be installed by running:

    ```
    python -m pip install pyserial
    ```

## Get RISC-V Steel

Clone RISC-V Steel repository from GitHub:

```
git clone https://github.com/riscv-steel/riscv-steel.git
```

## Start PySerial

Connect your Digilent board to your computer using a USB cable and start PySerial terminal by running:

```
python -m serial.tools.miniterm
```

A list of available serial ports will follow. Select the port your board is connected to and **keep the terminal open** for the next steps.

<figure markdown>
  ![](images/pyserial.png){ width="500" }
</figure>

## Program the FPGA

Open **AMD Xilinx Vivado** and follow the steps:

1. Click **Run Tcl Script** in the **Tools** menu.

2. Select `hello_world_???.tcl` and click **Ok**. The `???` stands for your board name.

    This file is located at `demos/boards/???/` and it creates the demo project for your board in Vivado.

3. Click on **Generate Bitstream** in the **Flow** menu.

4. Click **Open Hardware Manager** in the **Flow** menu.

5. Click **Auto Connect** in the **Tools** menu.

6. Click **Program Device** in the **Tools** menu. A dialog box asking you to provide the bitstream will open.

7. Search for `hello_world_???.bit`. Again, the `???` stands for your board name.

    This file is located at `demos/boards/???/hello_world_???/hello_world_???.runs/impl_1/`.

8. Click on **Program** and wait for Vivado to finish programming the FPGA.

Now go back to PySerial terminal window. You should see the message below:

<figure markdown>
  ![](images/hello_world.png){ width="500" }
</figure>

## Next steps

If you've reached this point, congratulations! You have a working instance of the SoC IP. You can now change it to create your own embedded applications.

- **Run your own software**

    The [SoC IP Software Guide](softwareguide.md) contains instructions on how to write, compile, and run software applications for the SoC IP.

- **Expand the design**

    The [SoC IP Documentation](soc.md) contains detailed information about its design so that you can expand it to create larger projects.

</br>
</br>