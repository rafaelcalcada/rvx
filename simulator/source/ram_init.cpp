// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "ram_init.h"

#include <fstream>
#include <string.h>

void ram_init_h32(const char *path, uint32_t words, DutRamWrite write)
{
  std::ifstream file;

  file.open(path, std::ios::in);

  if (!file.is_open())
  {
    std::exit(EXIT_FAILURE);
  }

  std::string line;
  size_t load_address = 0x00000000;

  // First initialize the RAM
  for (size_t i = 0; i < words; i++)
  {
    write(i, 0xdeadbeef);
  }

  // Then load the memory init file
  while (std::getline(file, line))
  {
    char *token = strtok((char *)line.c_str(), " \n");
    while (token != NULL)
    {
      std::string token_str = std::string(token);
      if (token_str[0] == '@') // update load address
      {
        load_address = std::stoul(token_str.substr(1), nullptr, 16);
        token = strtok(NULL, " \n");
      }
      else
      {
        uint32_t data = std::stoul(token_str, nullptr, 16);

        if (load_address > words)
        {
          std::exit(EXIT_FAILURE);
        }

        write(load_address, data);
        token = strtok(NULL, " \n");
        load_address++;
      }
    }
  }

  file.close();
}

void ram_init_bin(const char *path, uint32_t words, DutRamWrite write)
{
  std::ifstream file;

  file.open(path, std::ios::binary);

  if (!file.is_open())
  {
    std::exit(EXIT_FAILURE);
  }

  // First initialize the RAM
  for (size_t i = 0; i < words; i++)
  {
    write(i, 0xdeadbeef);
  }

  char buffer[4];
  size_t load_address = 0;

  while (not file.eof())
  {
    file.read(buffer, 4);

    uint32_t data = 0;
    size_t count = file.gcount();

    if (count == 0)
    {
      break;
    }

    for (size_t i = count; i != 0; i--)
    {
      data <<= 8;
      data |= (buffer[i - 1] & 0xff);
    }

    if (load_address > words)
    {
      std::exit(EXIT_FAILURE);
    }

    write(load_address++, data);
  }

  file.close();
}
