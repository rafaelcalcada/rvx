#include "Vrvx_spi_manager_tb.h"
#include "verilated.h"

int main(int argc, char **argv)
{
  VerilatedContext *contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  Vrvx_spi_manager_tb *dut = new Vrvx_spi_manager_tb{contextp};

  while (!contextp->gotFinish())
  {
    dut->eval();
    contextp->timeInc(10);
  }

  delete dut;
  delete contextp;
  return 0;
}