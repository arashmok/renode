/* Simple linker script for Cortex-M33 memory exploration */

MEMORY
{
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 64K
}

/* Entry point */
ENTRY(Reset_Handler)

SECTIONS
{
    .text :
    {
        . = ALIGN(4);
        *(.isr_vector)
        *(.text)
        *(.text*)
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
    } > SRAM

    .data :
    {
        . = ALIGN(4);
        *(.data)
        *(.data*)
        . = ALIGN(4);
    } > SRAM

    .bss :
    {
        . = ALIGN(4);
        __bss_start__ = .;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > SRAM

    . = ALIGN(4);
    _end = .;
}
