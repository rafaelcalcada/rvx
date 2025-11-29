# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2025 RVX Project Contributors

cmake_minimum_required(VERSION 3.12)

cmake_policy(SET CMP0074 NEW)

set(APP_NAME "mcu_sim")

# Get more verbose output from Makefile builds
set(CMAKE_VERBOSE_MAKEFILE OFF)

project(${APP_NAME})

find_package(verilator
  HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT}
  PATHS "/usr/local/bin"
)
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Set the VERILATOR_ROOT environment variable")
endif()

add_compile_options(
    -std=c++17
)

set(SOURCES
  ${CMAKE_SOURCE_DIR}/main.cpp
  ${CMAKE_SOURCE_DIR}/argparse.cpp
  ${CMAKE_SOURCE_DIR}/ram_init.cpp
)

include_directories(
  ${CMAKE_SOURCE_DIR}
)

add_executable(${APP_NAME} ${SOURCES})

verilate(${APP_NAME}
  INCLUDE_DIRS
    "../../../../hardware/core"
    "../../../../hardware/bus"
    "../../../../hardware/ram"
    "../../../../hardware/uart"
    "../../../../hardware/mtimer"
    "../../../../hardware/mcu"
    "../../../../hardware/gpio"
    "../../../../hardware/spi"

  SOURCES "mcu_sim.v"
  TRACE_FST
  VERILATOR_ARGS
    vcfg.vlt
    --Wall
    --default-language 1364-2001
)
