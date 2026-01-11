# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

cmake_minimum_required(VERSION 3.28)

project(rvx_simulator LANGUAGES CXX)

find_package(verilator REQUIRED)

add_executable(rvx_simulator rvx_simulator.cpp ram_init.cpp argparse.cpp)

# Suppress stringop-overread warnings from Verilator-generated code
target_compile_options(rvx_simulator PRIVATE -Wno-stringop-overread)

set(RVX_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/..)

set(VERILATOR_INCLUDE_DIRS
  ${RVX_ROOT_DIR}/rtl
  ${RVX_ROOT_DIR}/rtl/core
  ${RVX_ROOT_DIR}/rtl/interconnect
  ${RVX_ROOT_DIR}/rtl/peripherals
  ${RVX_ROOT_DIR}/rtl/memory
)

verilate(rvx_simulator
  SOURCES verilator_config.vlt rvx_simulator.v
  TOP_MODULE rvx_simulator
  DIRECTORY verilated
  PREFIX Vrvx_simulator
  TRACE_FST
  INCLUDE_DIRS ${VERILATOR_INCLUDE_DIRS}
  VERILATOR_ARGS
    --Wall
    --default-language 1364-2001
    --timescale 1ns/1ps
    --timing
)

install(TARGETS rvx_simulator)