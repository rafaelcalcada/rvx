// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

// Standard library includes
#include <csignal>
#include <fstream>
#include <iostream>
#include <string>

// Verilator includes
#include "rvx_simulator.h"
#include "rvx_simulator___024root.h"
#include <verilated_fst_c.h>

// Project includes
#include "log.h"
#include "ram_init.h"
#include "rvx_simulator_argparser.h"

// Type aliases
using Dut = rvx_simulator;
using Trace = VerilatedFstC;

// Global flag to indicate if a shutdown has been requested (Ctrl+C)
static bool shutdown_requested = false;

void exit_app(int sig)
{
  (void)sig;
  shutdown_requested = true;
  Log::info("Exit requested, finishing simulation...");
}

static void ram_dump_h32(Dut *dut, const std::string &dump_path, uint32_t offset, uint32_t size)
{
  std::ofstream file;
  file.open(dump_path, std::ios::out | std::ios::trunc);

  if (!file.is_open())
  {
    Log::error("Error file opening: %s", dump_path.c_str());
    std::exit(EXIT_FAILURE);
  }

  char buff[32];

  // In words
  offset /= 4;
  size /= 4;

  for (int i = 0; i < size; i++)
  {
    uint32_t data =
        dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__rvx_tightly_coupled_memory_instance__DOT__tcm[offset + i];
    snprintf(buff, sizeof(buff), "%08" PRIx32, (const uint32_t)data);
    file << buff << '\n';
  }

  Log::info("Ok dump ram h32");
  file.close();
}

int main(int argc, char *argv[])
{
  // Register signal handlers
  std::signal(SIGINT, exit_app);
  std::signal(SIGTERM, exit_app);

  // Parse command-line arguments
  RvxSimulatorArgs sim_options(argc, argv);

  // Simulation objects
  VerilatedContext *contextp = new VerilatedContext;
  Dut *dut = new Dut(contextp);
  Trace *trace = new Trace;

  // Read from RVX Tightly Coupled Memory at the given address
  auto read_memory = [&dut](uint32_t memory_address)
  {
    return dut->rootp
        ->rvx_simulator__DOT__rvx_instance__DOT__rvx_tightly_coupled_memory_instance__DOT__tcm[memory_address >> 2];
  };

  /**
   * @brief Returns true if the running program has finished execution.
   * @note A program signals its end by writing 1 to address 0x00000000.
   */
  auto program_end = [&]()
  {
    return (dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__manager_rw_address == 0x00000000 &&
            dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__manager_write_request == 1 &&
            dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__manager_write_data == 0x00000001);
  };

  auto is_host_out = [&](uint32_t addr)
  {
    static bool is_pos_edg = false;

    bool is_write = (addr != 0x0) &&
                    (not is_pos_edg and dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__manager_write_request) &&
                    (dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__manager_rw_address == addr) &&
                    dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__manager_write_request &&
                    dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__manager_write_data;

    is_pos_edg = dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__manager_write_request;

    return is_write;
  };

  // Closes the simulation trace file if tracing is enabled
  auto close_trace = [&]()
  {
    if (trace->isOpen())
    {
      trace->dump(contextp->time());
      trace->close();
    }
  };

  // Default log level
  Log::set_level(Log::DEBUG);

  if (!sim_options.trace_path.empty())
  {
    Verilated::traceEverOn(true);
    dut->trace(trace, 99);
    trace->set_time_resolution("1ns");
    trace->set_time_unit("1ns");
    trace->open(sim_options.trace_path.c_str());
  }

  // Assert reset
  dut->reset_n = 0;
  dut->clock = 0;
  dut->eval();

  // Keep reset high for 5 clock cycles
  for (int i = 0; i < 10; i++)
  {
    contextp->timeInc(10);
    dut->clock ^= 1;
    dut->eval();
    trace->dump(contextp->time());
  }

  // Deassert reset
  contextp->timeInc(10);
  dut->reset_n = 1;
  dut->clock = 1;
  dut->eval();
  trace->dump(contextp->time());

  // Load program into RAM
  // Need to be done after reset, as reset would clear memory
  ram_init_h32(
      sim_options.program_path.c_str(), dut->rootp->rvx_simulator__DOT__MEMORY_SIZE_IN_BYTES / 4,
      [&dut](uint32_t i, uint32_t v)
      { dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__rvx_tightly_coupled_memory_instance__DOT__tcm[i] = v; });

  while (true)
  {
    if (shutdown_requested)
    {
      Log::info("Shutting down simulation...");
      close_trace();
      break;
    }

    dut->clock ^= 1;
    dut->eval();

    // uart out
    if (dut->rootp->clock && dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__manager_rw_address == 0x80000000 &&
        dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__manager_write_request &&
        dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__rvx_uart_instance__DOT__tx_bit_counter == 0)
    {
      std::cout << (char)dut->rootp->rvx_simulator__DOT__rvx_instance__DOT__manager_write_data;
      // std::cout.flush();
      contextp->timeInc(20 * 5208); // UART baud rate delay simulation
    }
    else
    {
      contextp->timeInc(20);
    }

    contextp->timeInc(10);
    trace->dump(contextp->time());

    // --cycles
    /*if (args.max_cycles)
    {
      if (contextp->time() >= args.max_cycles)
      {
        Log::info("Exit: end cycles");
        close_trace();
        std::exit(EXIT_SUCCESS);
      }
    }*/

    // --wr-addr
    if (program_end())
    {
      Log::info("Exit: wr-addr");

      // The beginning and end of signature are stored at
      uint32_t start_addr = read_memory(0x00000004);
      uint32_t stop_addr = read_memory(0x00000008);
      uint32_t size = stop_addr - start_addr;

      Log::info("Signature size: %u", size);

      if (!sim_options.dump_path.empty() and (size >= 4))
      {
        ram_dump_h32(dut, sim_options.dump_path, start_addr, size);
      }

      close_trace();
      std::exit(EXIT_SUCCESS);
    }
  }
}
