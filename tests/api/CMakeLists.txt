# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

# Minimal CMake version required
cmake_minimum_required(VERSION 3.28)

# Name of the project/executable to be generated
set(APP_NAME "rvx_hal_tests")

# Memory and stack sizes
set(RVX_MEMORY_SIZE 32768)
set(RVX_STACK_SIZE 2048)
set(RVX_HEAP_SIZE 2048)

# Indicate that this is a bare-metal application
set(RVX_BARE_METAL TRUE)

# Fetch RVX SDK
include(FetchContent)
FetchContent_Declare(rvx_sdk
  GIT_REPOSITORY https://github.com/rafaelcalcada/rvx-sdk.git
  GIT_TAG main
)
FetchContent_MakeAvailable(rvx_sdk)

# Define the project languages
project(${APP_NAME} LANGUAGES C ASM)

# Source files for the application
set(SOURCE_FILES
  source/rvx_hal_test.c
  source/rvx_hal_test_helpers.c
  source/rvx_hal_test_uart.c
  source/rvx_hal_test_gpio.c
  source/rvx_hal_test_spi.c
  source/rvx_hal_test_timer.c
)

# Create the executable
add_executable(${APP_NAME} ${SOURCE_FILES})

# Add include directories
target_include_directories(${APP_NAME} PRIVATE ${CMAKE_SOURCE_DIR}/include)

# Link to RVX SDK
target_link_libraries(${APP_NAME} PRIVATE rvx_sdk)

# Generate boot image
rvx_generate_boot_image(${APP_NAME})