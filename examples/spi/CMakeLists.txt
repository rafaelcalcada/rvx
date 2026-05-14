# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

# Minimal CMake version required
cmake_minimum_required(VERSION 3.28)

# Name of the project/executable to be generated
set(APP_NAME "rvx_spi_example")

# Size of RVX tightly coupled memory (TCM)
# Set this to the same value you provided for the TCM_SIZE_IN_BYTES parameter of RVX top module.
set(RVX_MEMORY_SIZE 8192)

# Memory space reserved for stack growth
set(RVX_STACK_SIZE 1024)

# Memory space reserved for heap growth
set(RVX_HEAP_SIZE 1024)

# For bare-metal applications, set to TRUE.
# For FreeRTOS applications, set to FALSE or leave it undefined.
set(RVX_BARE_METAL TRUE)

# Fetch RVX SDK
# Note that the RVX SDK is included before the project() command,
# so that it can set up compiler and linker settings for RVX.
include(FetchContent)
FetchContent_Declare(rvx_sdk
  GIT_REPOSITORY https://github.com/rafaelcalcada/rvx-sdk.git
  GIT_TAG main
)
FetchContent_MakeAvailable(rvx_sdk)

# Define the project and set languages
# ASM is needed for RVX startup code
project(${APP_NAME} LANGUAGES C ASM)

# Create the executable
add_executable(${APP_NAME} rvx_spi_example.c)

# Link to RVX SDK
target_link_libraries(${APP_NAME} PRIVATE rvx_sdk)

# This function generates the boot images for RVX
rvx_generate_boot_image(${APP_NAME})