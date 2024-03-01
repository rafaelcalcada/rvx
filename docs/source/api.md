# RISC-V Steel System-on-Chip { class="main-section-title" }
<h2 class="main-section-subtitle">Software API Reference</h2>

## Introduction

The Software API of RISC-V Steel System-on-Chip IP provides function calls to configure and control the devices in the system, making it easy to write applications for it.

To use it you need to include the `rvsteel_api.h` header in the source code of your application:

```c
#include "rvsteel_api.h"
```

The documentation of the available API calls is presented in the following sections.

## UART communication
---
#### uart_send_char { class="api-hidden" }

`#!c void uart_send_char(const char c);`
{ class="api-call" }

<div class="api-doc" markdown>
Send character <strong>c</strong> over the UART.

This is a blocking call, that is, the execution of the program is halted until the UART finishes sending the data.

```c
// Example

uart_send_char('\n');
```
</div>

#### uart_send_string { class="api-hidden" }

`#!c void uart_send_string(const char *str);`
{ class="api-call" }

<div class="api-doc" markdown>
Send the null-terminated C-string <strong>str</strong> over the UART.

This is a blocking call, that is, the execution of the program is halted until the UART finishes sending the data.

```c
// Example

uart_send_string("Hello World!");
```
</div>

#### uart_read_last_char { class="api-hidden" }

`#!c volatile char uart_read_last_char();`
{ class="api-call" }

<div class="api-doc" markdown>
Return the last character received by the UART. The null character `'\0'` is returned if no character was received since power up.

This is a non-blocking call.

```c
// Example

if (uart_read_last_char() == '\n')
{
  uart_send_string("Last received character is new line.");
}
```
</div>

## Interrupt handling
---
#### irq_enable_all { class="api-hidden" }

`#!c void irq_enable_all();`
{ class="api-call" }

<div class="api-doc" markdown>
Enable external, timer and software interrupts by setting the global interrupt-enable bit in the <strong>mstatus</strong> CSR and the corresponding interrupt-enable bits in the <strong>mie</strong> CSR.

```c
// Example

irq_enable_all();
```
</div>

#### irq_disable_all { class="api-hidden" }

`#!c void irq_disable_all();`
{ class="api-call" }

<div class="api-doc" markdown>
Disable external, timer and software interrupts by clearing the global interrupt-enable bit in the <strong>mstatus</strong> CSR and the corresponding interrupt-enable bits in the <strong>mie</strong> CSR.

```c
// Example

irq_disable_all();
```
</div>

#### irq_set_interrupt_handler { class="api-hidden" }

`#!c void irq_set_interrupt_handler(void (*interrupt_handler)());`
{ class="api-call" }

<div class="api-doc" markdown>
Set the interrupt handler, a routine called everytime an interrupt is accepted.

The interrupt handler routine must be a `void` function with no arguments.

```c hl_lines="13"
// Example

void my_custom_interrupt_handler()
{
  // simply echoes back the received character
  char c = uart_read_last_char();
  uart_send_char(c);
}

int main()
{
  uart_send_string("Hello! Type something (it will be echoed back): ");
  irq_set_interrupt_handler(my_custom_interrupt_handler)
  irq_enable_all();
  busy_wait();
}
```
</div>

## Miscellaneous
---

#### busy_wait { class="api-hidden" }

`#!c void busy_wait();`
{ class="api-call" }

<div class="api-doc" markdown>

Enter into an infinite loop that can only be stopped by an interrupt request.

Make sure interrupts are enabled before calling this method (see [**`irq_enable_all`**](#irq_enable_all)).

```c hl_lines="15"
// Example

void my_custom_interrupt_handler()
{
  // simply echoes back the received character
  char c = uart_read_last_char();
  uart_send_char(c);
}

int main()
{
  uart_send_string("Hello! Type something (it will be echoed back): ");
  irq_set_interrupt_handler(my_custom_interrupt_handler)
  irq_enable_all();
  busy_wait();
}
```
</div>

</br>
</br>