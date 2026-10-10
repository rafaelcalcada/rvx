# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

# Project setup

cmake_minimum_required(VERSION 3.28)
set(APP_NAME "rvx_sdk_tests")
project(${APP_NAME} LANGUAGES C ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# RVX SDK setup

set(RVX_ENABLE_ZMMUL FALSE)
set(RVX_RAM_SIZE_IN_BYTES 32768)
set(RVX_MIN_FREE_SPACE_IN_BYTES 2048)
set(RVX_DIR "../../sdk")
find_package(RVX CONFIG REQUIRED)

# Build the executable and generate the boot image

set(RVX_SDK_TEST_SOURCES
  source/main.c
  source/test_framework.c
  source/suites/uart.c
  source/suites/gpio.c
  source/suites/spi.c
  source/suites/timer.c
)

add_executable(${APP_NAME} ${RVX_SDK_TEST_SOURCES})
target_include_directories(${APP_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_link_libraries(${APP_NAME} PRIVATE rvx_sdk)
rvx_generate_boot_image(${APP_NAME})