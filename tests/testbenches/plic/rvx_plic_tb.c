#include "Vrvx_plic_tb.h"
#include "verilated.h"
#include <iostream>

int main(int argc, char **argv)
{
  VerilatedContext *contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  Vrvx_plic_tb *dut = new Vrvx_plic_tb{contextp};

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
