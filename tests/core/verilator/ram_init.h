// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#ifndef RAM_INIT_H
#define RAM_INIT_H

#include <cstddef>
#include <cstdint>
#include <functional>

using DutRamWrite = std::function<void(uint32_t i, uint32_t v)>;

void ram_init_h32(const char *path, uint32_t words, DutRamWrite write);
void ram_init_bin(const char *path, uint32_t words, DutRamWrite write);

#endif // RAM_INIT_H
