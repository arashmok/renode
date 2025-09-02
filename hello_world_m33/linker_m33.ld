/* ARM Cortex-M33 Linker Script
 * Educational bare-metal program memory layout
 * Memory regions match the platform definition in cortex_m33_platform.repl
 */

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 1024K   /* 1MB Flash */
    SRAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 256K    /* 256KB SRAM */
}

/* Stack size - allocated at the end of SRAM */
_stack_size = 0x1000;  /* 4KB stack */

/* Top of stack (end of SRAM) */
_estack = ORIGIN(SRAM) + LENGTH(SRAM);

SECTIONS
{
    /* Vector table must be at the beginning of Flash */
    .isr_vector :
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } >FLASH

    /* Program code and constants */
    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text*)
        *(.rodata)
        *(.rodata*)
        
        . = ALIGN(4);
        _etext = .;
    } >FLASH

    /* Exception handling frames */
    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } >FLASH
    
    .ARM :
    {
        __exidx_start = .;
        *(.ARM.exidx*)
        __exidx_end = .;
    } >FLASH

    /* Data section - initialized variables copied from Flash to RAM */
    .data :
    {
        . = ALIGN(4);
        _sdata = .;        /* Start of data in RAM */
        *(.data)
        *(.data*)
        
        . = ALIGN(4);
        _edata = .;        /* End of data in RAM */
    } >SRAM AT >FLASH
    
    /* Store the flash address where .data is stored */
    _sidata = LOADADDR(.data);

    /* BSS section - zero-initialized variables */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;         /* Start of BSS */
        *(.bss)
        *(.bss*)
        *(COMMON)
        
        . = ALIGN(4);
        _ebss = .;         /* End of BSS */
    } >SRAM

    /* Stack allocation at the end of SRAM */
    .stack :
    {
        . = ALIGN(8);
        . = . + _stack_size;
        . = ALIGN(8);
    } >SRAM

    /* Remove debugging information */
    /DISCARD/ :
    {
        *(.note.GNU-stack)
        *(.gnu_debuglink)
        *(.gnu.lto_*)
    }
}

/* Provide symbols for the startup code */
PROVIDE(_stack_start = _estack - _stack_size);
PROVIDE(_heap_start = _ebss);
PROVIDE(_heap_end = _stack_start);
