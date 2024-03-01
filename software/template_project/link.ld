OUTPUT_ARCH("riscv")
ENTRY(_start)

SECTIONS {

  . = 0x00000000;
  .boot : { *(.boot) }
  .text : { *(.text) }
  . = ALIGN (CONSTANT (COMMONPAGESIZE));
  .data : { *(.data) }
  /DISCARD/ : { *(.comment) *(.riscv.attributes) }

}