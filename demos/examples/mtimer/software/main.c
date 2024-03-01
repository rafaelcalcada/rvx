#include "rvsteel_soc.h"
#include "rvsteel_csr.h"

void interrupt_handler()
{
  mtimer_clear_counter(MTIMER0);
  uart_send_string(UART0, "5ms\n");
}

int main()
{
  extern volatile void *__RVSTEEL_IRQ_HANDLER;
  __RVSTEEL_IRQ_HANDLER = (volatile void *)interrupt_handler;

  mtimer_set_compare(MTIMER0, 250000);
  mtimer_clear_counter(MTIMER0);
  mtimer_enable(MTIMER0);
  enable_irq(IRQ_MTIMER0_MASK);
  global_enable_irq();

  while (1)
    ;
}
