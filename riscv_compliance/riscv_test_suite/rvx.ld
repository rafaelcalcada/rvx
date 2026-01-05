OUTPUT_ARCH("riscv")
ENTRY(rvtest_entry_point)

SECTIONS
{
  . = 0x00000000;
  PROVIDE ( tohost = . );
  .text.init : { *(.text.init) }
  . = ALIGN(0x1000);
  .text : { *(.text) }
  . = ALIGN(0x1000);
  .data : { *(.data) }
  .data.string : { *(.data.string) }
  .bss : { *(.bss) }
  _end = .;
}

PROVIDE ( begin_signature_pointer = 0x4 );
PROVIDE ( end_signature_pointer = 0x8 );