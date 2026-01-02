// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include <stdlib.h>

#include <fstream>
#include <iostream>
#include <signal.h>
#include <string.h>

#include <verilated_fst_c.h>

#include "Vunit_tests.h"
#include "Vunit_tests___024root.h"
#include "argparse.h"
#include "log.h"
#include "ram_init.h"

using Dut = Vunit_tests;
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
}

void exit_app(int sig)
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

  uint32_t ram_size = dut->rootp->unit_tests__DOT__MEMORY_SIZE_IN_BYTES;

  switch (variants)
  {
  case RamInitVariants::H32:
    ram_init_h32(args.ram_init_path, ram_size / 4, [](uint32_t i, uint32_t v)
                 { dut->rootp->unit_tests__DOT__rvx_tightly_coupled_memory_instance__DOT__tcm[i] = v; });
    break;

  case RamInitVariants::BIN:
    ram_init_bin(args.ram_init_path, ram_size / 4, [](uint32_t i, uint32_t v)
                 { dut->rootp->unit_tests__DOT__rvx_tightly_coupled_memory_instance__DOT__tcm[i] = v; });
    break;
  }
}

static void ram_dump_h32(const char *path, uint32_t offset, uint32_t size)
{
  std::ofstream file;
  file.open(path, std::ios::out | std::ios::trunc);

  if (!file.is_open())
  {
    Log::error("Error file opening: %s", path);
    std::exit(EXIT_FAILURE);
  }

  char buff[32];

  // In words
  offset /= 4;
  size /= 4;

  for (int i = 0; i < size; i++)
  {
    uint32_t data = dut->rootp->unit_tests__DOT__rvx_tightly_coupled_memory_instance__DOT__tcm[offset + i];
    snprintf(buff, sizeof(buff), "%08" PRIx32, (const uint32_t)data);
    file << buff << '\n';
  }

  Log::info("Ok dump ram h32");
  file.close();
}

static bool is_finished(uint32_t addr)
{
  // After each clock cycle it tests whether the test program finished its execution
  // This event is signaled by writing 1 to the address 0x00001000
  return (dut->rootp->unit_tests__DOT__dbus_address == addr) && dut->rootp->unit_tests__DOT__dbus_wrequest &&
         dut->rootp->unit_tests__DOT__dbus_wdata == 0x00000001;
}

static bool is_host_out(uint32_t addr)
{
  static bool is_pos_edg = false;

  bool is_write = (addr != 0x0) && (not is_pos_edg and dut->rootp->unit_tests__DOT__dbus_wrequest) &&
                  (dut->rootp->unit_tests__DOT__dbus_address == addr) && dut->rootp->unit_tests__DOT__dbus_wrequest &&
                  dut->rootp->unit_tests__DOT__dbus_wdata;

  is_pos_edg = dut->rootp->unit_tests__DOT__dbus_wrequest;

  return is_write;
}

static uint32_t get_signature(uint32_t addr)
{
  return dut->rootp->unit_tests__DOT__rvx_tightly_coupled_memory_instance__DOT__tcm[addr];
}

int main(int argc, char *argv[])
{
  signal(SIGINT, exit_app);
  signal(SIGKILL, exit_app);

  // Default log level
  Log::set_level(Log::DEBUG);
  args = parser(argc, argv);

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

    // --wr-addr
    if (is_finished(args.wr_addr))
    {
      Log::info("Exit: wr-addr");

      // The beginning and end of signature are stored at
      uint32_t start_addr = get_signature(2047);
      uint32_t stop_addr = get_signature(2046);
      uint32_t size = stop_addr - start_addr;

      Log::info("Signature size: %u", size);

      if (args.ram_dump_h32 and (size >= 4))
      {
        ram_dump_h32(args.ram_dump_h32, start_addr, size);
      }

      close_trace();
      std::exit(EXIT_SUCCESS);
    }

    // --host-out
    if (is_host_out(args.host_out))
    {
      Log::host_out((char)dut->rootp->unit_tests__DOT__dbus_wdata);
    }
  }
}
