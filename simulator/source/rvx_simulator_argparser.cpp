// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx_simulator_argparser.h"
#include <algorithm>
#include <array>
#include <getopt.h>
#include <iostream>

const char *rvx_simulator_description =
    "RVX Simulator\n"
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
    "    <program>               (Required) Path to the memory initialization file\n"
    "                            for the program to simulate. This file can be\n"
    "                            generated using the RVX toolchain.\n"
    "\n"
    "Options:\n"
    "\n"
    "    --trace <file>          Path to the output trace file (.fst).\n"
    "                            If omitted, tracing is disabled.\n"
    "    --dump <file>           Path to the memory dump output file.\n"
    "                            If omitted, no memory dump is created.\n"
    "    --max-cycles <num>      Maximum number of clock cycles to simulate.\n"
    "                            Default is 0 (infinite).\n"
    "    -q, --quiet             Suppress all log messages.\n"
    "    -v, --verbose           Enable verbose output.\n"
    "    -h, --help              Show this help message and exit.\n"
    "\n";

static struct option rvx_simulator_cli_options[] = {
    {"help", no_argument, nullptr, 'h'},
    {"quiet", no_argument, nullptr, 'q'},
    {"verbose", no_argument, nullptr, 'v'},
    {"signature", required_argument, nullptr, RvxSimulatorCliLongOptions::SIGNATURE},
    {"trace", required_argument, nullptr, RvxSimulatorCliLongOptions::TRACE},
    {"dump", required_argument, nullptr, RvxSimulatorCliLongOptions::DUMP},
    {"max-cycles", required_argument, nullptr, RvxSimulatorCliLongOptions::MAX_CYCLES},
    {0, 0, 0, 0}};

const std::array<std::string, 9> rvx_simulator_all_options = {"-q",      "--quiet", "-v",           "--verbose",
                                                              "--trace", "--dump",  "--max-cycles", "--signature"};

RvxSimulatorArgs::RvxSimulatorArgs(int argc, char *argv[])
{
  int option;

  // Check presence of required positional argument: <program>
  if (argc < 2)
  {
    std::cout << argv[0] << ": <program> argument is required.\nRun '" << argv[0] << " --help' for usage.\n";
    std::exit(EXIT_FAILURE);
  }

  // Check for help flag
  if (std::string(argv[1]) == "--help" || std::string(argv[1]) == "-h")
  {
    std::cout << rvx_simulator_description;
    std::exit(EXIT_SUCCESS);
  }

  // Ensure the first argument is not a known option
  program_path = argv[1];
  if (std::find(rvx_simulator_all_options.begin(), rvx_simulator_all_options.end(), program_path) !=
      rvx_simulator_all_options.end())
  {
    std::cerr << argv[0] << ": <program> must be the first argument.\nRun '" << argv[0] << " --help' for usage.\n";
    std::exit(EXIT_FAILURE);
  }

  // Start parsing after the program name
  optind = 2;

  // Parse optional arguments
  while ((option = getopt_long(argc, argv, ":hqv", rvx_simulator_cli_options, nullptr)) != -1)
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
    case RvxSimulatorCliLongOptions::SIGNATURE:
      signature_path = optarg;
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
      }
      catch (const std::exception &e)
      {
        std::cerr << argv[0] << ": invalid value for --max-cycles: " << optarg << std::endl;
        std::cerr << "Run '" << argv[0] << " --help' for usage.\n";
        std::exit(EXIT_FAILURE);
      }
      break;
    default:
      std::string option_str = argv[optind - 1];
      static const std::array<std::string, 4> require_arg_options = {"--trace", "--dump", "--max-cycles",
                                                                     "--signature"};
      if (std::find(require_arg_options.begin(), require_arg_options.end(), option_str) != require_arg_options.end())
      {
        std::cerr << argv[0] << ": option '" << option_str << "' requires an argument.\n";
      }
      else
      {
        std::cerr << argv[0] << ": unknown option '" << argv[optind - 1] << "'.\n";
      }
      std::cerr << "Run '" << argv[0] << " --help' for usage.\n";
      std::exit(EXIT_FAILURE);
    }
  }
}