#include "Vrvx_core_bus_controller_tb.h"
#include "verilated.h"
#include "verilated_fst_c.h"
#include <iostream>

int main(int argc, char **argv)
{
  VerilatedContext *contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  contextp->traceEverOn(true);
  Vrvx_core_bus_controller_tb *dut = new Vrvx_core_bus_controller_tb{contextp};
  VerilatedFstC *trace = new VerilatedFstC;
  dut->trace(trace, 99);
  trace->open("rvx_core_bus_controller.fst");

  while (!contextp->gotFinish())
  {
    dut->eval();
    trace->dump(contextp->time());
    contextp->timeInc(1);
  }

  trace->close();
  delete trace;
  delete dut;
  delete contextp;
  std::cout << std::endl;
  return 0;
}
