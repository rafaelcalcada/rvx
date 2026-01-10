# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

# Minimal CMake version required
cmake_minimum_required(VERSION 3.15)

# Name of the project/executable to be generated
set(APP_NAME "rvx_hal_tests")

# Memory and stack sizes
set(RVX_MEMORY_SIZE 32768)
set(RVX_STACK_SIZE 2048)
set(RVX_HEAP_SIZE 2048)

# Indicate that this is a bare-metal application
set(RVX_BARE_METAL TRUE)

# Fetch RVX HAL
include(FetchContent)
FetchContent_Declare(rvx_hal
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/../../hal
)
FetchContent_MakeAvailable(rvx_hal)

# Define the project languages
project(${APP_NAME} LANGUAGES C ASM)

# Source files for the application
set(SOURCE_FILES
  source/rvx_hal_tests.c
  source/rvx_hal_test_utils.c
  source/rvx_hal_uart_test.c
  source/rvx_hal_gpio_test.c
  source/rvx_hal_spi_manager_test.c
  source/rvx_hal_timer_test.c
)

# Create the executable
add_executable(${APP_NAME} ${SOURCE_FILES})

# Add include directories
target_include_directories(${APP_NAME} PRIVATE ${CMAKE_SOURCE_DIR}/include)

# Link to RVX HAL
target_link_libraries(${APP_NAME} PRIVATE rvx_hal)

# Generate memory initialization file
rvx_generate_memory_init_file(${APP_NAME})