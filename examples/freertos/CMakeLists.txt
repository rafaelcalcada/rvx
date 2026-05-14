# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

# Minimal CMake version required
cmake_minimum_required(VERSION 3.28)

# Name of the project/executable to be generated
set(APP_NAME "rvx_freertos_example")

# Size of RVX tightly coupled memory (TCM)
# Set this to the same value you provided for the TCM_SIZE_IN_BYTES parameter of RVX top module.
set(RVX_MEMORY_SIZE 32768)

# Memory space reserved for stack growth
set(RVX_STACK_SIZE 1024)

# Memory space reserved for heap growth
set(RVX_HEAP_SIZE 8192)

# For bare-metal applications, set to TRUE.
# For FreeRTOS applications, set to FALSE or leave it undefined.
set(RVX_BARE_METAL FALSE)

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

# Fetch FreeRTOS Kernel
include(FetchContent)
FetchContent_Declare(freertos_kernel
  GIT_REPOSITORY https://github.com/FreeRTOS/FreeRTOS-Kernel.git
  GIT_TAG V11.0.0
)

# Create an interface library to hold FreeRTOS configuration,
# and set necessary compile definitions and include directories as directed by FreeRTOS porting guide
add_library(freertos_config INTERFACE)
target_include_directories(freertos_config INTERFACE ${CMAKE_SOURCE_DIR})
target_compile_definitions(freertos_config INTERFACE projCOVERAGE_TEST=0)

# Configure FreeRTOS for a RISC-V target
set(FREERTOS_HEAP "5" CACHE STRING "" FORCE)
set(FREERTOS_PORT "GCC_RISC_V_GENERIC" CACHE STRING "" FORCE)
set(FREERTOS_RISCV_EXTENSION RISCV_MTIME_CLINT_no_extensions CACHE STRING "" FORCE)

FetchContent_MakeAvailable(freertos_kernel)

# Create the executable
add_executable(${APP_NAME} rvx_freertos_example.c)

# Link to RVX SDK and FreeRTOS
target_link_libraries(${APP_NAME} PRIVATE rvx_sdk freertos_kernel freertos_config)

# This function generates the boot images for RVX
rvx_generate_boot_image(${APP_NAME})