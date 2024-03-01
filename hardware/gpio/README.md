# GPIO

## Initialization

1. Write port direction in register `OE`.
2. Read from register `IN` or write to register `OUT`.
3. Write `1<<PIN` to register `CLR` if you want to clear the port output to 0.
4. Write `1<<PIN` to register `SET` if you want to set the port output to 1.

![RISC-V Steel GPIO Diagram](doc/rvsteel_gpio_blockdiagram.svg)

## Register Access

Registers are accessed via 32-bit access operations. Attempts to access an misaligned address will be ignored.

## Registers

| Name                       | Offset | Bits  | Description            |
|:---------------------------|:-------|------ |:-----------------------|
| [`IN`](#IN)                | 0x0    |   32  | GPIO Input data        |
| [`OE`](#OE)                | 0x4    |   32  | GPIO Output Enable     |
| [`OUT`](#OUT)              | 0x8    |   32  | GPIO Output data       |
| [`CLR`](#CLR)              | 0xC    |   32  | GPIO Clear mask        |
| [`SET`](#SET)              | 0x10   |   32  | GPIO Set mask          |
