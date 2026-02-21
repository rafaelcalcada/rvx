#include "Vrvx_gpio_tb.h"
#include "verilated.h"
#include <iostream>

int main(int argc, char **argv)
{
  VerilatedContext *contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  Vrvx_gpio_tb *dut = new Vrvx_gpio_tb{contextp};

  while (!contextp->gotFinish())
  {
    dut->eval();
    contextp->timeInc(10);
  }

  delete dut;
  delete contextp;
  std::cout << std::endl;
  return 0;
}