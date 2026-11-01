# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

# Project setup

cmake_minimum_required(VERSION 3.28)
set(APP_NAME "rvx_freertos_example")
project(${APP_NAME} LANGUAGES C ASM)

# RVX setup

set(RVX_RAM_SIZE_IN_BYTES 32768)
set(RVX_MIN_FREE_SPACE_IN_BYTES 0) # FreeRTOS allocates its own heap space
set(RVX_ENABLE_ZMMUL_EXTENSION FALSE)
set(RVX_DIR "../../sdk")
find_package(RVX CONFIG REQUIRED)

# FreeRTOS setup

include(FetchContent)
FetchContent_Declare(freertos_kernel GIT_REPOSITORY https://github.com/FreeRTOS/FreeRTOS-Kernel.git GIT_TAG V11.0.0)
add_library(freertos_config INTERFACE)
target_include_directories(freertos_config INTERFACE ${CMAKE_SOURCE_DIR})
target_compile_definitions(freertos_config INTERFACE projCOVERAGE_TEST=0)
set(FREERTOS_HEAP "4" CACHE STRING "" FORCE)
set(FREERTOS_PORT "GCC_RISC_V_GENERIC" CACHE STRING "" FORCE)
set(FREERTOS_RISCV_EXTENSION RISCV_MTIME_CLINT_no_extensions CACHE STRING "" FORCE)
FetchContent_MakeAvailable(freertos_kernel)

# Build the executable and generate the boot image

add_executable(${APP_NAME} rvx_freertos_example.c)
target_link_libraries(${APP_NAME} PRIVATE rvx_sdk freertos_kernel freertos_config)
rvx_generate_boot_image(${APP_NAME})