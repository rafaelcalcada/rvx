# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

# Minimal CMake version required
cmake_minimum_required(VERSION 3.28)

# Name of the project/executable to be generated
set(APP_NAME "rvx_freertos_example")

# Define CPU clock frequency (in Hz)
set(CPU_FREQUENCY 50000000)

# Memory and stack sizes (in bytes)
set(RVX_MEMORY_SIZE 32768)
set(RVX_STACK_SIZE 1024)
set(RVX_HEAP_SIZE 0) # Heap is statically allocated by FreeRTOS, no need to reserve space here

# Fetch RVX HAL
include(FetchContent)
FetchContent_Declare(rvx_hal
  GIT_REPOSITORY https://github.com/rafaelcalcada/rvx-hal.git
  GIT_TAG main
)
FetchContent_MakeAvailable(rvx_hal)

# Define the project languages
project(${APP_NAME} LANGUAGES C CXX ASM) # ASM is needed for RVX startup code

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
set(FREERTOS_HEAP "4" CACHE STRING "" FORCE)
set(FREERTOS_PORT "GCC_RISC_V_GENERIC" CACHE STRING "" FORCE)
set(FREERTOS_RISCV_EXTENSION RISCV_MTIME_CLINT_no_extensions CACHE STRING "" FORCE)

FetchContent_MakeAvailable(freertos_kernel)

# Source files for the application
set(SOURCE_FILES rvx_freertos_example.c)

# Create the executable
add_executable(${APP_NAME} ${SOURCE_FILES})

# Link to RVX HAL
target_link_libraries(${APP_NAME} PRIVATE rvx_hal freertos_kernel freertos_config)

# Generate memory initialization file
rvx_generate_memory_init_file(${APP_NAME})