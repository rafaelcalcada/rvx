# RVX Coding Standards

This document outlines the coding standards and style guidelines for all contributions to the RVX project. Adhering to these standards helps ensure that the codebase remains consistent, readable, and maintainable as it grows.

The primary objectives of these standards are to:

- Foster consistency across all code and documentation
- Encourage best practices in both hardware and software development
- Improve code quality, reliability, and long-term maintainability
- Make collaboration, review, and code sharing easier for contributors

Following these guidelines helps everyone work more efficiently and supports the continued success of the RVX project.

## Table of Contents

- [Verilog Coding Standards](#verilog-coding-standards)
  - [Formatting](#formatting)
  - [Naming Conventions](#naming-conventions)
  - [Coding Practices](#coding-practices)
- [C Coding Standards](#c-coding-standards)
  - [Formatting](#formatting-1)
  - [Naming Conventions](#naming-conventions-1)
- [License Notice](#license-notice)

## Verilog Coding Standards

### Formatting

* All files must be formatted with `verible-verilog-format` using the rules file at `.config/.verible-format`.
* All files must be linted with `verilator --lint-only -Wall --timing`.
* Use only ASCII characters, **120** chars per line, **no** tabs, **2** spaces per indent for all paired keywords.
* Use C style comments: `//`.
* For multiple items on a line, **one** space must separate the comma and the next character.
* Include **whitespace** around keywords and binary operators.
* **No** space between case item and colon, function/task/macro call and open parenthesis.
* Line wraps should indent by **4** spaces.
* `begin` must be on the same line as the preceding keyword and terminate the line.
* `end` must start a new line.

**Tip:** The RVX development container applies most formatting rules automatically. It can be created from the `.devcontainer` folder, ensuring a consistently formatted and linted codebase with minimal setup.

### Naming Conventions

* Verilog source files must be named after the top module they contain.
* Use **lower\_snake\_case** for instance names, signals, declarations, variables, types.
* Use **ALL\_CAPS** for parameters, enumerated values, constants and define macros.
* Main clock signal is named `clock`. All other clock signals must begin with `clock_`.
* Reset signals are **active-low** and **synchronous**, default name is `reset_n`.
* Signal names should be descriptive and be consistent throughout the hierarchy.
* Avoid abbreviations.
* Do **not** add suffixes like `_i`, `_o` or `_io` to indicate the direction of module ports.
* Active low signal names should end with `_n`.
* Signals spanning multiple pipeline stages should use suffixes such as `_s1`, `_s2`, etc.

### Coding Practices

* Use **full port declaration style** for modules, any clock and reset declared first.
* Use **named parameters** for instantiation, all declared ports must be present, do **not** use `.*`.
* Local constants should be declared `localparam`.
* Sequential logic must use **non-blocking** assignments.
* Combinational blocks must use **blocking** assignments.
* Use of latches is strongly discouraged, use flip-flops when possible.
* The use of `X` assignments in RTL is strongly discouraged.
* Prefer `assign` statements wherever practical.
* Always define a `default` case.
* When printing use `0b` and `0x` as a prefix for binary and hex. Use `_` for clarity, e.g. `0x0000_0000`.
* Use logical constructs (i.e `||`) for logical comparison, bit-wise (i.e `|`) for data comparison.
* Bit vectors and packed arrays must be little-endian, unpacked arrays must be big-endian.
* FSMs: **no logic** except for reset should be performed in the process for the state register.

## C Coding Standards

### Formatting

* All files must be formatted with `clang-format` using the rules file at `.config/.clang-format`.

**Tip:** The RVX development container applies most formatting rules automatically. It can be created from the `.devcontainer` folder, ensuring a consistently formatted and linted codebase with minimal setup.

### Naming Conventions

* Use **lower\_snake\_case** for variables, functions and arguments.
* Use **UpperCamelCase** for structs.
* Use **ALL\_CAPS** for enums, constants, register addresses and compiler macros.
* Names should be descriptive and be consistent.
* Avoid abbreviations.

## License Notice

RVX Coding Standards is licensed under the [MIT License](LICENSE).

This work is adapted from "[lowRISC Verilog Coding Style Guide](https://github.com/lowRISC/style-guides)" by [lowRISC](https://lowrisc.org/), originally licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed).