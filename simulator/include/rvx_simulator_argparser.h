// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include <fstream>
#include <string>

/// Structure to hold RVX Simulator command-line arguments
typedef struct RvxSimulatorArgs
{
  RvxSimulatorArgs(int argc, char *argv[]);
  std::string program_path;   ///< Path to the program to simulate
  std::string trace_path;     ///< Path to the trace output file (.fst)
  std::string dump_path;      ///< Path to the RAM dump output file
  std::string signature_path; ///< Path to the test signature output file (hidden option)
  unsigned int max_cycles{0}; ///< Maximum number of cycles to simulate (0 = infinite)
  bool quiet{false};          ///< Whether to suppress all log messages. Default: false
  bool verbose{false};        ///< Whether to enable verbose output. Default: false
} RvxSimulatorArgs;

/// Description of the RVX Simulator for help messages
extern const char *rvx_simulator_description;

/// Enumeration of command-line options for the RVX Simulator
enum RvxSimulatorCliLongOptions
{
  TRACE,
  DUMP,
  MAX_CYCLES,
  SIGNATURE
};