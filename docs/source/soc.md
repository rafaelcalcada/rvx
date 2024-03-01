# RISC-V Steel System-on-Chip { class="main-section-title" }
<h2 class="main-section-subtitle">Documentation</h2>

## Introduction

RISC-V Steel System-on-Chip expands the Processor Core IP by adding memory and UART modules to its design. It comes with a [Software API](api.md) that makes it easy to develop new RISC-V applications.

This page contains information about the SoC IP hardware design. Check out the [Software Guide](softwareguide.md) for instructions on how to write, compile and run software for the SoC IP.

## Design overview

**Figure 1**{#figure-1} - RISC-V Steel SoC IP design overview

![Image title](images/rvsteel_soc.svg)

## Source files

**Table 1** - RISC-V Steel SoC IP source files

| Module name      | Source file                    | Description                       |
| ---------------- | ------------------------------ | --------------------------------- |
| **rvsteel_soc**  | `hardware//soc/rvsteel_soc.v`  | Top module of RISC-V Steel SoC IP |
| **rvsteel_core** | `hardware/core/rvsteel_core.v` | RISC-V Steel Processor Core       |
| **rvsteel_ram**  | `hardware/ram/rvsteel_ram.v`   | RAM memory                        |
| **rvsteel_uart** | `hardware/uart/rvsteel_uart.v` | UART                              |
| **rvsteel_bus**  | `hardware/bus/rvsteel_bus.v`   | System Bus                        |

## I/O signals

**Table 2** - RISC-V Steel SoC IP top module input and output signals

| Pin name       | Direction | Size  | Description          |
| -------------- | --------- | ----- | -------------------- |
| **clock**      | Input     | 1 bit | Clock input.         |
| **reset**      | Input     | 1 bit | Reset (active-high). |
| **halt**       | Input     | 1 bit | Halts the processor core (active-high). |
| **uart_rx**    | Input     | 1 bit | UART receiver pin. Must be connected to the transmitter (`TX`) pin of another UART device. |
| **uart_tx**    | Output    | 1 bit | UART transmitter pin. Must be connected to the receiver (`RX`) pin of another UART device. |

## Memory Map

In RISC-V systems, all devices share the processor address space and are mapped to an exclusive region in it (*Memory Mapped I/O*).

The memory region assigned to each device of RISC-V Steel SoC IP is listed in the table below.

**Table 4**{#table-4} - Memory Map of RISC-V Steel SoC IP

| Start address     | Final address       | Mapped device              |
| ----------------- | ------------------- | -------------------------- |
| `0x00000000`      | `0x(MEMORY_SIZE-1)` | RAM memory                 |
| `0x(MEMORY_SIZE)` | `0x7fffffff`        | -                          |
| `0x80000000`      | `0x80000004`        | UART                       |
| `0x80000005`      | `0xffffffff`        | -                          |

## Configuration

**Table 3** - Configuration parameters of RISC-V Steel SoC IP

| Parameter name         | Default value    | Value type and description                                                                    |
| ---------------------- | ---------------- | --------------------------------------------------------------------------------------------- |
| **`BOOT_ADDRESS`**     | `32'h00000000`   | 32-bit hexadecimal value. Memory address of the first instruction to be fetched and executed. |
| **`CLOCK_FREQUENCY`**  | `50000000`       | Integer. Frequency (in hertz) of the **clock** input signal.                                  |
| **`UART_BAUD_RATE`**   | `9600`           | Integer. UART baud rate (in bauds per second).                                                |
| **`MEMORY_SIZE`**      | `8192`           | Integer. RAM memory size (in bytes).                                             |
| **`MEMORY_INIT_FILE`** | `(empty string)` | String. Path to a memory initialization file.                                                 |

## Instantiation template

An instantiation template for RISC-V Steel SoC IP top module is provided below.

``` systemverilog
rvsteel_soc #(

  // Configuration parameters. For more information read the 'Configuration'
  // section of RISC-V Steel System-on-Chip Documentation

  .BOOT_ADDRESS             (),  // Default value: 32'h00000000
  .CLOCK_FREQUENCY          (),  // Default value: 50000000
  .UART_BAUD_RATE           (),  // Default value: 9600
  .MEMORY_SIZE              (),  // Default value: 8192
  .MEMORY_INIT_FILE         ())  // Default value: Empty string (uninitialized)

  rvsteel_soc_instance (

  // I/O signals. For more information read the 'I/O signals'
  // section of RISC-V Steel System-on-Chip Documentation

  .clock                    (),  // Connect this pin to a clock source
  .reset                    (),  // Connect this pin to a switch/button or hardwire it to 1'b0.
  .halt                     (),  // Connect this pin to a switch/button or hardwire it to 1'b0.
  .uart_rx                  (),  // Connect this pin to the TX pin of another UART device
  .uart_tx                  ()   // Connect this pin to the RX pin of another UART device

);
```

## How to add new devices

You can integrate a new device into the SoC IP design by making simple changes to its top module. The following lines of `rvsteel_soc.v` contain the parameters you need to change:

``` systemverilog
  // System bus configuration

  localparam NUM_DEVICES    = 2;
  localparam D0_RAM         = 0;
  localparam D1_UART        = 1;

  wire  [NUM_DEVICES*32-1:0] device_start_address;
  wire  [NUM_DEVICES*32-1:0] device_region_size;

  assign device_start_address [32*D0_RAM  +: 32]  = 32'h0000_0000;
  assign device_region_size   [32*D0_RAM  +: 32]  = 8192;

  assign device_start_address [32*D1_UART +: 32]  = 32'h8000_0000;
  assign device_region_size   [32*D1_UART +: 32]  = 8;
```

The `NUM_DEVICES` parameter holds the total number of devices in the system. Each device is assigned an index (`D0_RAM` and `D1_UART`). To accomodate your new device you need to increase `NUM_DEVICES` and assign it the next index, `2`, like this:

``` systemverilog
  localparam NUM_DEVICES    = 3;
  localparam D0_RAM         = 0;
  localparam D1_UART        = 1;
  localparam D2_NEW_DEVICE  = 2; // your new device
```

Next you have to assign your device a region in the processor's address space. You can assign it to any free region (see [Memory Map](#memory-map)). The region cannot overlap the address space of other devices and its size must be a power of 2. In the example below, the new device `D2_NEW_DEVICE` is assigned a 32KB region starting at `0x00008000`:

``` systemverilog
  assign device_start_address [32*D2_NEW_DEVICE +: 32]  = 32'h0000_8000;
  assign device_region_size   [32*D2_NEW_DEVICE +: 32]  = 32768;
```

Finally, you have to instantiate the new device in the `rvsteel_soc` module and connect it to the system bus interface. The Processor Core IP will issue read and write requests to your device as described in the [I/O Operations](core.md#io-operations) section of its [Documentation](core.md). A template for instantiating and connecting the new device to the system bus is provided below:

``` systemverilog
  // Instantiate the new device in the rvsteel_soc.v module like this:

  new_device
  new_device_instance (

    // I/O interface of the new device

    .new_device_rw_address      (device_rw_address                        ),
    .new_device_read_data       (device_read_data[32*D2_NEW_DEVICE +: 32] ),
    .new_device_read_request    (device_read_request[D2_NEW_DEVICE]       ),
    .new_device_read_response   (device_read_response[D2_NEW_DEVICE]      ),
    .new_device_write_data      (device_write_data                        ),
    .new_device_write_strobe    (device_write_strobe                      ),
    .new_device_write_request   (device_write_request[D2_NEW_DEVICE]      ),
    .new_device_write_response  (device_write_response[D2_NEW_DEVICE]     )

  );
```

</br>
</br>