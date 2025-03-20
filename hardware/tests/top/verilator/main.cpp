// ----------------------------------------------------------------------------
// Copyright (c) 2020-2025 RVX contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include <stdlib.h>

#include <fstream>
#include <iostream>
#include <signal.h>
#include <string.h>

#include <verilated_fst_c.h>

#include "Vmcu_sim.h"
#include "Vmcu_sim___024root.h"
#include "argparse.h"
#include "log.h"
#include "ram_init.h"

using Dut = Vmcu_sim;
using Trace = VerilatedFstC;

vluint64_t trace_time = 0;
vluint64_t clk_cur_cycles = 0;
vluint64_t clk_half_cycles = 2;
Dut *dut = new Dut;
Trace *trace = new Trace;
Args args;

static void open_trace(const char *out_wave_path)
{
  Verilated::traceEverOn(true);
  dut->trace(trace, 99);
  trace->set_time_resolution("1ns");
  trace->set_time_unit("1ns");
  trace->open(out_wave_path);
}

static void close_trace()
{
  if (trace->isOpen())
  {
    trace->dump(trace_time);
    trace->close();
  }
}

static void clk()
{
  static vluint64_t interval = 0;

  if (trace_time >= interval)
  {
    dut->clock ^= 1;
    interval = trace_time + clk_half_cycles;
    clk_cur_cycles += dut->clock & 0x1;
  }
}

static void eval(vluint64_t cycles_cnt = 1)
{
  while (cycles_cnt--)
  {
    clk();
    dut->eval();
    trace->dump(trace_time++);
  }
}

static void reset_dut()
{
  dut->reset = 1;
  eval(100);
  dut->reset = 0;
  dut->halt = 0;
}

static void set_clock_frequency(Dut *dut, uint32_t frequency)
{
  uint32_t clock_dut = dut->rootp->mcu_sim__DOT__rvx_instance__DOT__CLOCK_FREQUENCY;

  Log::warning("Dut clock frequency: %u (Hz)", clock_dut);
  Log::warning("MCU sim clock frequency: %u (ns)", frequency);

  // Set clock frequency (freq/2)
  clk_half_cycles = frequency / 2;
}

static void exit_app(int sig)
{
  (void)sig;
  close_trace();
  Log::info("Exit.");
  std::exit(EXIT_SUCCESS);
}

static void ram_init(const char *path, RamInitVariants variants)
{
  if (not path)
  {
    return;
  }

  uint32_t ram_size = dut->rootp->mcu_sim__DOT__rvx_instance__DOT__MEMORY_SIZE;

  switch (args.ram_init_variants)
  {
  case RamInitVariants::H32:
    ram_init_h32(
        args.ram_init_path, ram_size / 4,
        [](uint32_t i, uint32_t v) {
          dut->rootp->mcu_sim__DOT__rvx_instance__DOT__rvx_ram_instance__DOT__ram[i] = v;
        });
    break;

  case RamInitVariants::BIN:
    ram_init_bin(
        args.ram_init_path, ram_size / 4,
        [](uint32_t i, uint32_t v) {
          dut->rootp->mcu_sim__DOT__rvx_instance__DOT__rvx_ram_instance__DOT__ram[i] = v;
        });
    break;
  }
}

static bool is_host_out(uint32_t addr)
{
  static bool is_pos_edg = false;

  bool is_write =
      (addr != 0x0) &&
      (not is_pos_edg and
       dut->rootp
           ->mcu_sim__DOT__rvx_instance__DOT__rvx_core_instance__DOT__write_request) &&
      (dut->rootp->mcu_sim__DOT__rvx_instance__DOT__rvx_core_instance__DOT__rw_address ==
       addr);

  is_pos_edg =
      dut->rootp->mcu_sim__DOT__rvx_instance__DOT__rvx_core_instance__DOT__write_request;

  return is_write;
}

int main(int argc, char *argv[])
{
  signal(SIGINT, exit_app);
  signal(SIGKILL, exit_app);

  // Default log level
  Log::set_level(Log::DEBUG);
  args = parser(argc, argv);

  set_clock_frequency(dut, args.freq);

  if (args.out_wave_path)
  {
    open_trace(args.out_wave_path);
  }

  reset_dut();

  ram_init(args.ram_init_path, args.ram_init_variants);

  while (true)
  {
    eval();

    // --cycles
    if (args.max_cycles)
    {
      if (clk_cur_cycles >= args.max_cycles)
      {
        Log::info("Exit: end cycles");
        close_trace();
        std::exit(EXIT_SUCCESS);
      }
    }

    // --host-out
    if (is_host_out(args.host_out))
    {
      Log::host_out(
          (char)dut->rootp
              ->mcu_sim__DOT__rvx_instance__DOT__rvx_core_instance__DOT__write_data);
    }
  }
}
