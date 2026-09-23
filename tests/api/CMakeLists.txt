# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

# Project setup

cmake_minimum_required(VERSION 3.28)
set(APP_NAME "rvx_api_tests")
project(${APP_NAME} LANGUAGES C ASM)

# RVX SDK setup

set(RVX_ENABLE_ZMMUL FALSE)
set(RVX_RAM_SIZE_IN_BYTES 32768)
set(RVX_MIN_FREE_SPACE_IN_BYTES 2048)
find_package(RVX CONFIG REQUIRED)

# Build the executable and generate the boot image

set(SOURCE_FILES
  source/rvx_api_test.c
  source/rvx_api_test_helpers.c
  source/rvx_api_test_uart.c
  source/rvx_api_test_gpio.c
  source/rvx_api_test_spi.c
  source/rvx_api_test_timer.c
)

add_executable(${APP_NAME} ${SOURCE_FILES})
target_include_directories(${APP_NAME} PRIVATE ${CMAKE_SOURCE_DIR}/include)
target_link_libraries(${APP_NAME} PRIVATE rvx_sdk)
rvx_generate_boot_image(${APP_NAME})