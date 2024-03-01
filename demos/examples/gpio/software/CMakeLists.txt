# -----------------------------------------------------------------------------
# Copyright (c) 2020-2024 RISC-V Steel contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# -----------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.15)


set(APP_NAME            "example_gpio")
set(CPU_FREQUENCY       50000000UL)
set(RVSTEEL_ROOT        "../../../../")
set(RVSTEEL_API         ${RVSTEEL_ROOT}/software/api)

set(APP_ARCH            rv32izicsr)
set(APP_ABI             ilp32)
set(APP_MACHINE         riscv)


set(STACK_USAGE         1024)
set(CMAKE_CXX_STANDARD  11)
set(CMAKE_CXX_FLAGS     "-O2")

set(CMAKE_C_STANDARD    11)
set(CMAKE_C_FLAGS       "-O2")

set(LINKER_SCRIPT       ${CMAKE_SOURCE_DIR}/startup/link.ld)


# Cross-Compiling for a Microcontroller
set(CMAKE_SYSTEM_NAME Generic)
# Tell CMake not to try to link executables during its checks
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
# The suffix for executables on this platform.
set(CMAKE_EXECUTABLE_SUFFIX ".elf")
# Get more verbose output from Makefile builds
set(CMAKE_VERBOSE_MAKEFILE OFF)


# Toolchain prefix (cmake -DTOOLCHAIN_PREFIX=toolchain-prefix)
if(NOT DEFINED TOOLCHAIN_PREFIX)
  message(STATUS "NOT DEFINED TOOLCHAIN_PREFIX")
  set(TOOLCHAIN_PREFIX riscv32-unknown-elf-)
endif()


set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}as     )
set(CMAKE_C_COMPILER   ${TOOLCHAIN_PREFIX}gcc    )
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++    )
set(CMAKE_OBJCOPY      ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_OBJDUMP      ${TOOLCHAIN_PREFIX}objdump)


find_program(PATH_CMAKE_C_COMPILER
  ${CMAKE_C_COMPILER}
  PATHS ENV PATH
  REQUIRED
)


if(NOT PATH_CMAKE_C_COMPILER)
  message(FATAL_ERROR "NOT DEFINED CMAKE_C_COMPILER: " ${PATH_CMAKE_C_COMPILER})
else()
  message(STATUS "PATH CMAKE_C_COMPILER: " ${PATH_CMAKE_C_COMPILER})
endif()


set(ARCH_FLAGS
  -march=${APP_ARCH}
  -mabi=${APP_ABI}
)


set(SPECS
  --specs=nano.specs
  --specs=nosys.specs
)


add_compile_options(
  -Wall
  -Wextra
  -Wstack-usage=${STACK_USAGE}
  -mstrict-align
  -pedantic
  -ffreestanding
  -ffunction-sections
  -fdata-sections
  -fno-exceptions
  $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>
  ${SPECS}
  ${ARCH_FLAGS}
)


add_link_options(
  -nostartfiles
  -nostdlib
  -nodefaultlibs
  -mstrict-align
  -Wl,-lm
  -Wl,--start-group
  -Wl,--end-group
  -Wl,--gc-sections
  -Wl,--no-warn-rwx-segments
  -Wl,--print-memory-usage
  -Wl,--cref
  -Wl,-Map=${APP_NAME}.map
  -T ${LINKER_SCRIPT}
  ${SPECS}
  ${ARCH_FLAGS}
)


set(SOURCES
  ${CMAKE_SOURCE_DIR}/startup/startup_reset.S
  ${CMAKE_SOURCE_DIR}/startup/startup_init.c
  ${CMAKE_SOURCE_DIR}/main.cpp
)


set(HEADERS
  ${CMAKE_SOURCE_DIR}/${RVSTEEL_API}/rvsteel_gcc.h
  ${CMAKE_SOURCE_DIR}/${RVSTEEL_API}/rvsteel_def.h
  ${CMAKE_SOURCE_DIR}/${RVSTEEL_API}/rvsteel_csr.h
  ${CMAKE_SOURCE_DIR}/${RVSTEEL_API}/rvsteel_soc.h
  ${CMAKE_SOURCE_DIR}/${RVSTEEL_API}/rvsteel_uart.h
  ${CMAKE_SOURCE_DIR}/${RVSTEEL_API}/rvsteel_mtimer.h
)


set_source_files_properties(${CMAKE_SOURCE_DIR}/startup/startup_reset.S PROPERTIES LANGUAGE C)


include_directories(
  ${RVSTEEL_API}
)


# Set the name of the project
project(${APP_NAME} LANGUAGES C CXX)
add_executable(${APP_NAME}.elf ${SOURCES} ${HEADERS})


# Set dependency on linker script
set_target_properties(${APP_NAME}.elf PROPERTIES
  LINK_DEPENDS "${LINKER_SCRIPT}"
)


add_custom_command(TARGET ${APP_NAME}.elf POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary      ${APP_NAME}.elf ${APP_NAME}.bin
  COMMAND ${CMAKE_OBJCOPY} -O verilog     ${APP_NAME}.elf --verilog-data-width=4 ${APP_NAME}.hex
  COMMAND ${CMAKE_OBJDUMP} -D             ${APP_NAME}.elf > ${APP_NAME}.objdump
)


set_property(TARGET ${APP_NAME}.elf
  APPEND PROPERTY ADDITIONAL_CLEAN_FILES
  ${APP_NAME}.bin
  ${APP_NAME}.hex
  ${APP_NAME}.objdump
  ${APP_NAME}.map
)

# Set definitions
add_compile_definitions(CPU_FREQUENCY=${CPU_FREQUENCY})

