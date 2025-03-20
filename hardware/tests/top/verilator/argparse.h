// ----------------------------------------------------------------------------
// Copyright (c) 2020-2025 RVX contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

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
  uint32_t max_cycles{500000};
  uint32_t host_out{0x00000000};
  uint32_t freq{100};
};

Args parser(int argc, char *argv[]);

#endif // ARGPARSE_H
