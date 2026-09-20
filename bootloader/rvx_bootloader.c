// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include <stdint.h>

#define RVX_TCM_START_ADDRESS 0x00001000U
#define RVX_MAGIC_NUMBER 0x52565830U
#define RVX_SPI0_CHIP_SELECT_REG 0x40003004U
#define RVX_SPI0_WRITE_REG 0x4000300CU
#define RVX_SPI0_READ_REG 0x40003010U
#define RVX_SPI0_STATUS_REG 0x40003014U

static inline __attribute__((always_inline)) uint8_t rvx_bootloader_spi_transfer(const uint8_t tx_data)
{
  *((volatile uint32_t *)(RVX_SPI0_WRITE_REG)) = tx_data;
  while (*((volatile uint32_t *)(RVX_SPI0_STATUS_REG)) & 1)
    ;
  return (uint8_t)(*((volatile uint32_t *)(RVX_SPI0_READ_REG)));
}

static inline __attribute__((always_inline)) uint32_t rvx_bootloader_read_word_from_spi(void)
{
  uint32_t word = (uint32_t)rvx_bootloader_spi_transfer(0x00);
  word |= ((uint32_t)rvx_bootloader_spi_transfer(0x00)) << 8;
  word |= ((uint32_t)rvx_bootloader_spi_transfer(0x00)) << 16;
  word |= ((uint32_t)rvx_bootloader_spi_transfer(0x00)) << 24;
  return word;
}

__attribute__((used, naked, section(".text.rvx_bootloader_entry"))) void rvx_bootloader(void)
{
  *((volatile uint32_t *)(RVX_SPI0_CHIP_SELECT_REG)) = 0; // Assert CS
  rvx_bootloader_spi_transfer(0x03);                      // READ_DATA command
  rvx_bootloader_spi_transfer(0x00);                      // Address byte 0
  rvx_bootloader_spi_transfer(0x00);                      // Address byte 1
  rvx_bootloader_spi_transfer(0x00);                      // Address byte 2

  uint32_t rvx_magic = rvx_bootloader_read_word_from_spi();

  if (rvx_magic != RVX_MAGIC_NUMBER)
  {
    *((volatile uint32_t *)(RVX_SPI0_CHIP_SELECT_REG)) = 1; // Deassert CS
    if (*((volatile uint32_t *)(RVX_TCM_START_ADDRESS)) != RVX_MAGIC_NUMBER)
    {
      asm volatile("j 0x1000");
    }

    uint32_t entry_point = *((volatile uint32_t *)(RVX_TCM_START_ADDRESS + 4U));
    asm volatile("jr %0" : : "r"(entry_point));
  }

  uint32_t entry_point = rvx_bootloader_read_word_from_spi();
  uint32_t image_size = rvx_bootloader_read_word_from_spi();
  uint32_t riscv_magic = rvx_bootloader_read_word_from_spi();

  *((volatile uint32_t *)(RVX_TCM_START_ADDRESS)) = rvx_magic;
  *((volatile uint32_t *)(RVX_TCM_START_ADDRESS + 4U)) = entry_point;
  *((volatile uint32_t *)(RVX_TCM_START_ADDRESS + 8U)) = image_size;
  *((volatile uint32_t *)(RVX_TCM_START_ADDRESS + 12U)) = riscv_magic;

  for (uint32_t i = 16U; i < image_size; i += 4U)
  {
    *((volatile uint32_t *)(RVX_TCM_START_ADDRESS + i)) = rvx_bootloader_read_word_from_spi();
  }

  *((volatile uint32_t *)(RVX_SPI0_CHIP_SELECT_REG)) = 1; // Deassert CS
  asm volatile("jr %0" : : "r"(entry_point));
}