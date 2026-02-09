#include "rvx.h"

inline static uint32_t read_word_from_spi()
{
  uint32_t word = 0;
  for (int i = 0; i < 4; i++)
  {
    uint8_t byte = rvx_spi_transfer(RVX_SPI_MANAGER_ADDRESS, 0x00);
    word = word | (((uint32_t)byte) << (i * 8));
  }
  return word;
}

RVX_NAKED void main(void)
{
  // Read CSR 0x7C0 (RVX SPI Boot Image Address)
  uint32_t spi_boot_image_address;
  asm volatile("csrr %0, 0x7C0" : "=r"(spi_boot_image_address));

  uint8_t addr_byte_1 = (spi_boot_image_address >> 16) & 0xFF;
  uint8_t addr_byte_2 = (spi_boot_image_address >> 8) & 0xFF;
  uint8_t addr_byte_3 = spi_boot_image_address & 0xFF;

  rvx_spi_chip_select_assert(RVX_SPI_MANAGER_ADDRESS);
  rvx_spi_write(RVX_SPI_MANAGER_ADDRESS, 0x03); // Read Data command
  rvx_spi_write(RVX_SPI_MANAGER_ADDRESS, addr_byte_1);
  rvx_spi_write(RVX_SPI_MANAGER_ADDRESS, addr_byte_2);
  rvx_spi_write(RVX_SPI_MANAGER_ADDRESS, addr_byte_3);

  uint32_t rv32_magic_number = read_word_from_spi();
  uint32_t image_size = read_word_from_spi();
  uint32_t entry_point = read_word_from_spi();
  uint32_t rvx4_magic_number = read_word_from_spi();

  uint32_t tcm_base_address = 0x00001000;

  // If not a valid RVX boot image, try booting from TCM instead
  if (rv32_magic_number != 0x52563332 || rvx4_magic_number != 0x52565834)
  {
    rvx_spi_chip_select_deassert(RVX_SPI_MANAGER_ADDRESS);
    rv32_magic_number = *((volatile uint32_t *)(tcm_base_address));
    image_size = *((volatile uint32_t *)(tcm_base_address + 4));
    entry_point = *((volatile uint32_t *)(tcm_base_address + 8));
    rvx4_magic_number = *((volatile uint32_t *)(tcm_base_address + 12));
    if (rv32_magic_number == 0x52563332 && rvx4_magic_number == 0x52565834)
      asm volatile("jr %0" : : "r"(entry_point));
    else
      asm volatile("j 0x1000");
  }

  // Write the image header
  *((volatile uint32_t *)(tcm_base_address)) = rv32_magic_number;
  *((volatile uint32_t *)(tcm_base_address + 4)) = image_size;
  *((volatile uint32_t *)(tcm_base_address + 8)) = entry_point;
  *((volatile uint32_t *)(tcm_base_address + 12)) = rvx4_magic_number;

  // Write the image data
  for (uint32_t i = 16; i < image_size; i += 4)
  {
    uint32_t word = read_word_from_spi();
    *((volatile uint32_t *)(tcm_base_address + i)) = word;
  }
  rvx_spi_chip_select_deassert(RVX_SPI_MANAGER_ADDRESS);

  // Jump to entry point
  asm volatile("jr %0" : : "r"(entry_point));
}