# MTIMER

## Initialization

1. Write the count register `MTIME` and comparison register `MTIMECMP`;
2. Enable the timer by writing the `EN` bit to the `CR` register.

## Register Access

MTIMER IP has a 64-bit count register `MTIME` and a 64-bit comparison register `MTIMECMP`. Registers are accessed via 32-bit access operations. Attempts to access an misaligned address will be ignored.

## Interrupt Handling

The machine timer interrupt becomes pending whenever `MTIME` contains a value greater than or equal to `MTIMECMP`. The interrupt can be cleared by updating `MTIME` or `MTIMECMP`.

`output irq` is set high whenever `MTIME >= MTIMECMP`. The `irq_response` input is not used, left for future implementations.


## Registers

| Name                       | Offset | Bits  | Description            |
|:---------------------------|:-------|------ |:-----------------------|
| [`CR`](#cr)                | 0x0    |    32 | Control register       |
| [`MTIMEL`](#mtimel)        | 0x4    |    32 | Timer value Low        |
| [`MTIMEH`](#mtimeh)        | 0x8    |    32 | Timer value High       |
| [`MTIMECMPL`](#mtimecmpl)  | 0xC    |    32 | Timer compare Low      |
| [`MTIMECMPH`](#mtimecmph)  | 0x10   |    32 | Timer compare High     |


### MTIMER control register (MTIMER_CR)

- Address offset: `0x0`
- Reset value: `0x0`
- Bits 31:1 Reserved, must be kept at reset value
- Bit 0 `EN` Enable count


### MTIMER counter register (MTIMER_MTIMEL)

- Address offset: `0x4`
- Reset value: `0x0`
- Bits 31:0 `MTIMEL`: Timer value Low


### MTIMER counter register (MTIMER_MTIMEH)

- Address offset: `0x8`
- Reset value: `0x0`
- Bits 31:0 `MTIMEH`: Timer value High


### MTIMER compare register (MTIMER_MTIMECMPL)

- Address offset: `0xC`
- Reset value: `0x0`
- Bits 31:0 `MTIMECMPL`: Timer compare Low


### MTIMER compare register (MTIMER_MTIMECMPH)

- Address offset: `0x10`
- Reset value: `0x0`
- Bits 31:0 `MTIMECMPH`: Timer compare High
