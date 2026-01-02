/* SPDX-License-Identifier: MIT */
/* Copyright (c) 2020-2025 RVX Project Contributors */

OUTPUT_ARCH("riscv")
ENTRY(rvx_boot)

MEMORY
{
  RAM (wx)  : ORIGIN = 0x00000000, LENGTH = __memory_size
}

PHDRS
{
  text PT_LOAD FLAGS(5); /* PF_R+PF_X (Read, execute) */
  data PT_LOAD FLAGS(6); /* PF_R+PF_W (Read, write) */
}

SECTIONS
{

  __stack_size = DEFINED(__stack_size) ? __stack_size : 1K;
  __heap_size = DEFINED(__heap_size) ? __heap_size : 0;

  .text :
  {
    *(.init.rvx_boot)
    *(.init.rvx_trap_vector)
    *(.text.rvx_return_from_trap)
    *(.text.default_trap_handler)
    *(.text.*_irq_handler)
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
  } > RAM :text

  .data : ALIGN(4)
  {
    *(.data*)
    *(.gnu.linkonce.d.*)

    . = ALIGN(4);
    PROVIDE( __global_pointer$ = . + 0x800 );
    *(.sdata*)
    *(.gnu.linkonce.s.*)

    . = ALIGN(4);
  } > RAM :data

  .bss : ALIGN(4)
  {
    PROVIDE ( __bss_start = . );
    *(.sbss*)
    *(.gnu.linkonce.sb.*)
    *(.bss*)
    *(.gnu.linkonce.b.*)
    *(COMMON)

    . = ALIGN(4);
  } > RAM :data

  .heap : ALIGN(4)
  {
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + __heap_size;
  } > RAM :data

  .stack : ALIGN(4)
  {
    . += __stack_size;
    . = ALIGN(4);
  } > RAM :data

  /DISCARD/ :
  {
    *(.comment)
    *(.riscv.attributes)
  }

}

PROVIDE( __stack_limit              = ORIGIN(RAM) + LENGTH(RAM) - __stack_size);
PROVIDE( __stack_top                = ORIGIN(RAM) + LENGTH(RAM));
PROVIDE( __freertos_irq_stack_top   = __stack_top);

PROVIDE( __data_source_start        = LOADADDR(.data));
PROVIDE( __data_target_start        = ADDR(.data));
PROVIDE( __data_target_end          = ADDR(.data) + SIZEOF(.data));

PROVIDE( __bss_source_start         = LOADADDR(.bss));
PROVIDE( __bss_target_start         = ADDR(.bss));
PROVIDE( __bss_target_end           = ADDR(.bss) + SIZEOF(.bss));