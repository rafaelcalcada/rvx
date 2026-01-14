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

/* The addresses of the begin and the end of the test signature
 * are saved at these pointers, respectively. */
PROVIDE ( begin_signature_pointer = 0x1FFFF8 );
PROVIDE ( end_signature_pointer = 0x1FFFFC );