/* SPDX-License-Identifier: MIT */
/* Copyright (c) 2020-2026 RVX Project Contributors */

OUTPUT_ARCH("riscv")
ENTRY(rvx_bootloader)

MEMORY
{
  BOOTLOADER_ROM (rx) : ORIGIN = 0x00000000, LENGTH = 4K
}

SECTIONS
{

  __rvx_min_free_space = DEFINED(__rvx_min_free_space) ? __rvx_min_free_space : 0;

  .text :
  {
    KEEP(*(.text.rvx_bootloader_entry))
    *(.text.rvx_bootloader_helpers)

    *(SORT_NONE(.init))
    *(SORT_NONE(.fini))

    . = ALIGN(4);
    PROVIDE_HIDDEN (__preinit_array_start = .);
    *(.preinit_array*)
    PROVIDE_HIDDEN (__preinit_array_end = .);

    . = ALIGN(4);
    PROVIDE_HIDDEN (__init_array_start = .);
    *(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*))
    *(.init_array .ctors)
    PROVIDE_HIDDEN (__init_array_end = .);

    . = ALIGN(4);
    *(.text*)
    *(.gnu.linkonce.t.*)

    . = ALIGN(4);
    *(.rodata*)

    . = ALIGN(4);
    *(.srodata*)
  } > BOOTLOADER_ROM

  .data : ALIGN(4)
  {
    *(.data*)
    *(.gnu.linkonce.d.*)

    . = ALIGN(8);
    __sdata_start = .;
    PROVIDE(__global_pointer$ = __sdata_start + 0x800);
    *(.sdata*)
    *(.gnu.linkonce.s.*)
    __sdata_end = .;
  } > BOOTLOADER_ROM

  .bss (NOLOAD) : ALIGN(4)
  {
    PROVIDE(__bss_start = .);
    *(.sbss*)
    *(.gnu.linkonce.sb.*)
    *(.bss*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN(4);
    PROVIDE(__bss_end = .);
  }

  /DISCARD/ :
  {
    *(.comment)
    *(.riscv.attributes)
  }

}

PROVIDE( __stack_top                 = ORIGIN(BOOTLOADER_ROM) + LENGTH(BOOTLOADER_ROM));
PROVIDE( __heap_start                = ALIGN(ADDR(.bss) + SIZEOF(.bss), 8));
PROVIDE( __free_ram                  = __stack_top - __heap_start);

ASSERT(__free_ram >= __rvx_min_free_space,  "ERROR: Bootloader does not fit in RVX Bootloader ROM: minimum free space requirement cannot be satisfied.");
ASSERT(rvx_bootloader == ORIGIN(BOOTLOADER_ROM), "ERROR: rvx_bootloader is not at 0x00000000.");