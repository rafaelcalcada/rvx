// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx_simulator_argparser.h"
#include <algorithm>
#include <array>
#include <filesystem>
#include <getopt.h>
#include <iostream>

const char *rvx_simulator_description = "RVX Simulator\n"
                                        "\n"
                                        "    Simulates a program on RVX, optionally generating trace (waveform\n"
                                        "    visualization) and memory dump files.\n"
                                        "\n"
                                        "Usage:\n"
                                        "\n"
                                        "    rvx_simulator <program> [options]\n"
                                        "\n"
                                        "Positional arguments:\n"
                                        "\n"
                                        "    <program>             (Required) Path to the memory initialization file\n"
                                        "                          for the program to simulate. This file can be\n"
                                        "                          generated using the RVX toolchain.\n"
                                        "\n"
                                        "Options:\n"
                                        "\n"
                                        "    --trace <file>        Path to the output trace file (.fst).\n"
                                        "                          If omitted, tracing is disabled.\n"
                                        "    --dump <file>         Path to the memory dump output file.\n"
                                        "                          If omitted, no memory dump is created.\n"
                                        "    --max-cycles <num>    Maximum number of clock cycles to simulate.\n"
                                        "                          Default is 0 (infinite).\n"
                                        "    -q,--quiet            Suppress all log messages.\n"
                                        "    -v,--verbose          Enable verbose output.\n"
                                        "    -h,--help             Show this help message and exit.\n"
                                        "\n";

static struct option rvx_simulator_cli_options[] = {
    {"help", no_argument, nullptr, 'h'},
    {"quiet", no_argument, nullptr, 'q'},
    {"verbose", no_argument, nullptr, 'v'},
    {"trace", required_argument, nullptr, RvxSimulatorCliLongOptions::TRACE},
    {"dump", required_argument, nullptr, RvxSimulatorCliLongOptions::DUMP},
    {"max-cycles", required_argument, nullptr, RvxSimulatorCliLongOptions::MAX_CYCLES},
    {0, 0, 0, 0}};

const std::array<std::string, 10> rvx_simulator_all_options = {"-h",        "--help",  "-q",     "--quiet",     "-v",
                                                               "--verbose", "--trace", "--dump", "--max-cycles"};

RvxSimulatorArgs::RvxSimulatorArgs(int argc, char *argv[])
{
  int option;

  // Check presence of required positional argument: <program>
  if (argc < 2)
  {
    std::cout << "Error: <program> argument is required. Run '" << argv[0] << " --help' for usage.\n";
    std::exit(EXIT_FAILURE);
  }

  // Check for help flag
  if (std::string(argv[1]) == "--help" || std::string(argv[1]) == "-h")
  {
    std::cout << rvx_simulator_description;
    std::exit(EXIT_SUCCESS);
  }

  // Set program path and open program file stream
  program_path = argv[1];
  if (std::filesystem::exists(program_path))
  {
    program_fstream.open(program_path, std::ios::in);
    if (!program_fstream.is_open())
    {
      std::cerr << argv[0] << ": unable to open '" << program_path << "'.\n";
      std::exit(EXIT_FAILURE);
    }
  }
  else if (std::find(rvx_simulator_all_options.begin(), rvx_simulator_all_options.end(), program_path) !=
           rvx_simulator_all_options.end())
  {
    std::cerr << argv[0] << ": missing <program> argument. Run '" << argv[0] << " --help' for usage.\n";
    std::exit(EXIT_FAILURE);
  }
  else
  {
    std::cerr << argv[0] << ": program '" << program_path << "' not found.\n";
    std::exit(EXIT_FAILURE);
  }

  // Start parsing after the program name
  optind = 2;

  // Parse optional arguments
  while ((option = getopt_long(argc, argv, "hqv:", rvx_simulator_cli_options, nullptr)) != -1)
  {
    switch (option)
    {
    case 'h':
      std::cout << rvx_simulator_description;
      std::exit(EXIT_SUCCESS);
      break;
    case 'q':
      quiet = true;
      break;
    case 'v':
      verbose = true;
      break;
    case RvxSimulatorCliLongOptions::TRACE:
      trace_path = optarg;
      break;
    case RvxSimulatorCliLongOptions::DUMP:
      dump_path = optarg;
      break;
    case RvxSimulatorCliLongOptions::MAX_CYCLES:
      try
      {
        max_cycles = static_cast<unsigned int>(std::stoul(optarg));
        std::cout << "Max cycles: " << max_cycles << std::endl;
      }
      catch (const std::exception &e)
      {
        std::cerr << argv[0] << ": invalid value for --max-cycles: " << optarg << std::endl;
        std::cerr << "Run '" << argv[0] << " --help' for usage.\n";
        std::exit(EXIT_FAILURE);
      }
      break;
    default:
      std::cerr << "Run '" << argv[0] << " --help' for usage.\n";
      std::exit(EXIT_FAILURE);
    }
  }
}