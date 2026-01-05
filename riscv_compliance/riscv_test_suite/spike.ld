OUTPUT_ARCH("riscv")
ENTRY(rvtest_entry_point)

SECTIONS
{
  . = 0x00002000;
  .text.init : { *(.text.init) }
  . = ALIGN(0x1000);
  .text : { *(.text) }
  . = ALIGN(0x1000);
  .data : { *(.data) }
  .data.string : { *(.data.string) }
  .bss : { *(.bss) }
  _end = .;
  . = ALIGN(0x1000);
  .tohost : {
    . = ALIGN(8);
    tohost = .;
    . += 4;
    . = ALIGN(8);
    fromhost = .;
  }
}

PROVIDE ( begin_signature_pointer = 0x200000 );
PROVIDE ( end_signature_pointer = 0x200004 );