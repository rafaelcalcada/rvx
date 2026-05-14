# Minimal CMake version required
cmake_minimum_required(VERSION 3.28)

# Name of the project/executable to be generated
set(APP_NAME "rvx_bootloader")

# Memory and stack sizes (in bytes)
set(RVX_MEMORY_SIZE 1024)
set(RVX_STACK_SIZE 0)
set(RVX_HEAP_SIZE 0)

# Indicate that this is a bare-metal application
set(RVX_BARE_METAL TRUE)

# Special flag for bootloader compilation, uses a different linker script
set(RVX_BOOTLOADER TRUE)

# Fetch RVX SDK
include(FetchContent)
FetchContent_Declare(rvx_sdk
  GIT_REPOSITORY https://github.com/rafaelcalcada/rvx-sdk.git
  GIT_TAG main
)
FetchContent_MakeAvailable(rvx_sdk)

# Define the project languages
project(${APP_NAME} LANGUAGES C ASM) # ASM is needed for RVX startup code

# Source files for the application
set(SOURCE_FILES rvx_bootloader.c)

# Create the executable
add_executable(${APP_NAME} ${SOURCE_FILES})

# Link to RVX SDK
target_link_libraries(${APP_NAME} PRIVATE rvx_sdk)

# Generate boot image
rvx_generate_boot_image(${APP_NAME})