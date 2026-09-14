OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
  SRAM (rwx) : ORIGIN = 0x10000000, LENGTH = 64K
}

SECTIONS
{
  .text ORIGIN(SRAM) + 0x80 : ALIGN(4) {
    KEEP(*(.text.start))
    *(.text .text.*)
    *(.rodata .rodata.*)
  } > SRAM

  .data : ALIGN(4) {
    *(.sdata .sdata.*)
    *(.data .data.*)
  } > SRAM

  .bss (NOLOAD) : ALIGN(4) {
    __bss_start = .;
    *(.sbss .sbss.*)
    *(.bss .bss.*)
    *(COMMON)
    __bss_end = .;
  } > SRAM

  /DISCARD/ : { *(.comment) *(.riscv.attributes) }
}

PROVIDE(__stack_top = ORIGIN(SRAM) + LENGTH(SRAM));
