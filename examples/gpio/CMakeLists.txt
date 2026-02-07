# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

# Minimal CMake version required
cmake_minimum_required(VERSION 3.28)

# Name of the project/executable to be generated
set(APP_NAME "rvx_gpio_example")

# Memory and stack sizes (in bytes)
set(RVX_MEMORY_SIZE 8192)
set(RVX_STACK_SIZE 1024)
set(RVX_HEAP_SIZE 1024)

# Indicate that this is a bare-metal application
set(RVX_BARE_METAL TRUE)

# Fetch RVX HAL
include(FetchContent)
FetchContent_Declare(rvx_hal
  GIT_REPOSITORY https://github.com/rafaelcalcada/rvx-hal.git
  GIT_TAG main
)
FetchContent_MakeAvailable(rvx_hal)

# Define the project languages
project(${APP_NAME} LANGUAGES C ASM) # ASM is needed for RVX startup code

# Source files for the application
set(SOURCE_FILES rvx_gpio_example.c)

# Create the executable
add_executable(${APP_NAME} ${SOURCE_FILES})

# Link to RVX HAL
target_link_libraries(${APP_NAME} PRIVATE rvx_hal)

# Generate boot image
rvx_generate_boot_image(${APP_NAME})