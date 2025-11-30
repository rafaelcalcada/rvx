// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

#ifndef LOG_H
#define LOG_H

#include <cstddef>
#include <iostream>
#include <sstream>
#include <fstream>
#include <cstring>

class Log
{
  public:
    ~Log() = default;
    static constexpr size_t BUFFER_SIZE = 1024;

    enum Level
    {
      DEBUG,
      INFO,
      WARNING,
      ERROR,
      CRITICAL,
      QUIET,
      END
    };

    static const char *level_name(Level level) {
      switch(level) {
      case DEBUG: return "DEBUG";
      case INFO: return "INFO";
      case WARNING: return "WARNING";
      case ERROR: return "ERROR";
      case CRITICAL: return "CRITICAL";
      case QUIET: return "QUIET";
      default: return "UNKNOWN";
      }
    }

    static Log& get_instance() {
        static Log instance;
        return instance;
    }

    static void set_level(const Level level)
    {
      get_instance().level = level;
    }

    static void set_level(const char * level)
    {
      for (int i = 0; i < Level::END; i++)
      {
        const char *name = level_name((Level)i);

        if (strcmp(level, name) == 0)
        {
          get_instance().set_level((Level)i);
        }
      }
    }

    static void set_out(const std::string& filename)
    {
      Log &log = get_instance();
      log.fileout.open(filename, std::ios::out | std::ios::trunc);

      if (log.fileout.is_open())
      {
        log.log_stream = &log.fileout;
      }
    }

    template<typename... Targs>
    static void debug(const char* format, Targs... Fargs)
    {
      get_instance().message(DEBUG, format, Fargs...);
    }

    template<typename... Targs>
    static void info(const char* format, Targs... Fargs)
    {
      get_instance().message(INFO, format, Fargs...);
    }

    template<typename... Targs>
    static void warning(const char* format, Targs... Fargs)
    {
      get_instance().message(WARNING, format, Fargs...);
    }

    template<typename... Targs>
    static void error(const char* format, Targs... Fargs)
    {
      get_instance().message(ERROR, format, Fargs...);
    }

    template<typename... Targs>
    static void critical(const char* format, Targs... Fargs)
    {
      get_instance().message(CRITICAL, format, Fargs...);
    }

    static void host_out(const char c)
    {
      if (get_instance().level < QUIET)
      {
        *get_instance().log_stream << c;
      }
    }

  private:
    char buffer[BUFFER_SIZE];
    Level level{DEBUG};
    std::ofstream fileout;
    std::ostream* log_stream{&std::cout};

    Log() = default;

    template<typename... Targs>
    void message(Level level, const char* format, Targs... Fargs);

    template<typename... Targs>
    void message(std::stringstream &ss, const char* format, Targs... Fargs);

    template<typename... Targs>
    void message(std::stringstream &ss, const char* str)
    {
      ss << str;
    }
};

template<typename... Targs>
void Log::message(Level level, const char* format, Targs... Fargs)
{
  if (level >= this->level)
  {
    std::stringstream ss;
    message(ss, "[%s] ", level_name(level));
    message(ss, format, Fargs...);
    *log_stream << ss.str() << std::endl;
  }
}

template<typename... Targs>
void Log::message(std::stringstream &ss, const char* format, Targs... Fargs)
{
  snprintf(buffer, sizeof(buffer), format, Fargs...);
  ss << buffer;
}

#endif // LOG_H
