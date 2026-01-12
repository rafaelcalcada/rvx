# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

cmake_minimum_required(VERSION 3.28)

set(CMAKE_CXX_STANDARD 20)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(rvx_simulator LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(verilator REQUIRED)

set(RVX_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/..)

set(VERILATOR_INCLUDE_DIRS
  ${RVX_ROOT_DIR}/rtl
  ${RVX_ROOT_DIR}/rtl/core
  ${RVX_ROOT_DIR}/rtl/interconnect
  ${RVX_ROOT_DIR}/rtl/peripherals
  ${RVX_ROOT_DIR}/rtl/memory
)

set(SIMULATOR_SOURCES
  ${CMAKE_CURRENT_SOURCE_DIR}/source/rvx_simulator.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/source/rvx_simulator_argparser.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/source/ram_init.cpp
)

add_executable(rvx_simulator ${SIMULATOR_SOURCES})

target_include_directories(rvx_simulator PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

# Suppress stringop-overread warnings from Verilator-generated code
target_compile_options(rvx_simulator PRIVATE -Wno-stringop-overread)

verilate(rvx_simulator
  SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/source/rvx_simulator.v
  TOP_MODULE rvx_simulator
  DIRECTORY verilated
  PREFIX rvx_simulator
  TRACE_FST
  INCLUDE_DIRS ${VERILATOR_INCLUDE_DIRS}
  VERILATOR_ARGS
    --Wall
    --default-language 1364-2001
    --timescale 1ns/1ps
    --timing
)

install(TARGETS rvx_simulator)