// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#ifndef ARGPARSE_H
#define ARGPARSE_H

#include <cstdint>
#include <cstddef>

enum RamInitVariants
{
  NONE,
  H32,
  BIN,
};

struct Args
{
  char *out_wave_path{nullptr};
  char *ram_init_path{nullptr};
  RamInitVariants ram_init_variants{NONE};
  char *ram_dump_h32{nullptr};
  uint32_t max_cycles{500000};
  uint32_t wr_addr{0x00001000};
  uint32_t host_out{0x00000000};
};

Args parser(int argc, char *argv[]);

#endif // ARGPARSE_H
