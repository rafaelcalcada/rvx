// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include <format>
#include <iostream>

class RvxSimulatorLogger
{
  public:
  enum class Severity
  {
    VERBOSE,
    INFO,
    WARNING,
    ERROR,
    FATAL
  };
  RvxSimulatorLogger(std::ostream &os, Severity min_severity, bool quiet)
      : os_(os), min_severity_(min_severity), quiet_(quiet)
  {
  }
  template <typename... Args> void log(Severity severity, const std::string &format_string, Args... args)
  {
    if (quiet_)
    {
      return;
    }
    static const std::array<std::string, 5> severity_strings = {"[verbose]", "[info]", "[warning]", "[error]",
                                                                "[fatal]"};
    if (severity >= min_severity_)
    {
      os_ << std::format("{:9} ", severity_strings[static_cast<size_t>(severity)]);
      os_ << std::vformat(format_string, std::make_format_args(args...)) << std::endl;
    }
  }
  template <typename... Args> void verbose(const std::string &format_string, Args... args)
  {
    log(Severity::VERBOSE, format_string, args...);
  }
  template <typename... Args> void info(const std::string &format_string, Args... args)
  {
    log(Severity::INFO, format_string, args...);
  }
  template <typename... Args> void warning(const std::string &format_string, Args... args)
  {
    log(Severity::WARNING, format_string, args...);
  }
  template <typename... Args> void error(const std::string &format_string, Args... args)
  {
    log(Severity::ERROR, format_string, args...);
  }
  template <typename... Args> void fatal(const std::string &format_string, Args... args)
  {
    log(Severity::FATAL, format_string, args...);
  }

  private:
  std::ostream &os_;
  Severity min_severity_;
  bool quiet_;
};