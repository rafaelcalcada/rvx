# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2026 RVX Project Contributors

# Project setup

cmake_minimum_required(VERSION 3.28)
set(APP_NAME "rvx_spi_example")
project(${APP_NAME} LANGUAGES C ASM)

# RVX setup

set(RVX_RAM_SIZE_IN_BYTES 8192)
set(RVX_MIN_FREE_SPACE_IN_BYTES 1024)
set(RVX_ENABLE_ZMMUL_EXTENSION FALSE)
set(RVX_DIR "../../sdk")
find_package(RVX CONFIG REQUIRED)

# Build the executable and generate the boot image

add_executable(${APP_NAME} rvx_spi_example.c)
target_link_libraries(${APP_NAME} PRIVATE rvx_sdk)
rvx_generate_boot_image(${APP_NAME})