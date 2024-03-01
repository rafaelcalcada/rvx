#include "rvsteel_api.h"

// Interrupt handler routine: echo back the received character
void process_received_character()
{
  char received_character = uart_read_last_char();
  if (received_character == '\r')
    uart_send_string("\nType something else and press enter: ");
  else if (received_character < 127)
    uart_send_char(received_character);
}

// A Hello World program
int main()
{
  uart_send_string(
      "\nRISC-V Steel SoC IP"
      "\n-------------------"
      "\n\nHello World!"
      "\n\nType something and press enter: "
      "\n");
  irq_set_interrupt_handler(process_received_character);
  irq_enable_all();
  busy_wait();
}