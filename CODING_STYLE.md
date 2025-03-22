# RVX Coding Style Guides

## Table of Contents

- [Verilog Style Guide](#rvx-verilog-style-guide)
  - [Introduction](#introduction)
  - [Basic style elements](#basic-style-elements)
  - [Naming conventions](#naming-conventions)
  - [Suffixes for signals and types](#suffixes-for-signals-and-types)
  - [Language features](#language-features)
- [C Style Guide](#c-style-guide)
  - [Introduction](#introduction-1)
  - [Basic style elements](#basic-style-elements-1)
  - [Naming conventions](#naming-conventions-1)
- [License Notice](#license-notice)

## Verilog Style Guide

### Introduction

Verilog-2001 is the main design language for RVX IP.

Verilog can be written in vastly different styles, which can lead to code conflicts and code review latency.

This style guide aims to promote Verilog readability for RVX IP. The goals are to:

*   promote consistency
*   promote best practices
*   increase code sharing and re-use

This style guide defines style for Verilog-2001 code, both synthesizable and test bench code.

### Basic style elements

* Use Verilog-2001 conventions, files named as module.v, one file per module
* Only ASCII, **100** chars per line, **no** tabs, **two** spaces per indent for all paired keywords.
* C++ style comments `//`
* For multiple items on a line, **one** space must separate the comma and the next character
* Include **whitespace** around keywords and binary operators
* **No** space between case item and colon, function/task/macro call and open parenthesis
* Line wraps should indent by **four** spaces
* `begin` must be on the same line as the preceding keyword and end the line
* `end` must start a new line

### Naming conventions

* Use **lower\_snake\_case** for instance names, signals, declarations, variables, types
* Use **ALL\_CAPS** for parameters, enumerated values, constants and define macros
* Main clock signal is named `clock`. All clock signals must start with `clock_`
* Reset signals are **active-low** and **synchronous**, default name is `reset_n`
* Signal names should be descriptive and be consistent throughout the hierarchy
* Avoid abbreviations

### Suffixes for signals and types

* Do **not** add suffixes like `_i`, `_o` or `_io` to indicate the direction of module ports
* Active low signals should use `_n`

### Language features

* Use **full port declaration style** for modules, any clock and reset declared first
* Use **named parameters** for instantiation, all declared ports must be present, do **not** use `.*`
* Use **symbolically named constants** instead of raw numbers
* Local constants should be declared `localparam`
* Sequential logic must use **non-blocking** assignments
* Combinational blocks must use **blocking** assignments
* Use of latches is strongly discouraged, use flip-flops when possible
* The use of `X` assignments in RTL is strongly discouraged
* Prefer `assign` statements wherever practical.
* Always define a `default` case
* When printing use `0b` and `0x` as a prefix for binary and hex. Use `_` for clarity, e.g. `0x0000_0000`
* Use logical constructs (i.e `||`) for logical comparison, bit-wise (i.e `|`) for data comparison
* Bit vectors and packed arrays must be little-endian, unpacked arrays must be big-endian
* FSMs: **no logic** except for reset should be performed in the process for the state register

## C Style Guide

### Introduction

C is the primary language used in software development for RVX IP.

Like Verilog, C code can be written in vastly different styles, which can lead to code conflicts and code review latency.

This style guide aims to promote readability for RVX software source code. The goals are to:

*   promote consistency
*   promote best practices
*   increase code sharing and re-use

### Basic style elements

* All source code must be clang-formatted
* A `.clang-format` file with the style definitions can be found in the root folder of RVX repository

### Naming conventions

* Use **lower\_snake\_case** for variables, functions and arguments
* Use **UpperCamelCase** for structs
* Use **ALL\_CAPS** for enums, constants, register addresses and compiler macros
* Names should be descriptive and be consistent
* Avoid abbreviations

## License Notice

RVX Coding Style Guides is licensed under the [MIT License](LICENSE).

This work is adapted from "[lowRISC Verilog Coding Style Guide](https://github.com/lowRISC/style-guides)" by [lowRISC](https://lowrisc.org/), originally licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed).