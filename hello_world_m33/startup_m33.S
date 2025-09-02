/* ARM Cortex-M33 Startup Assembly
 * Educational bare-metal startup code
 */

.syntax unified
.cpu cortex-m33
.thumb

.extern main

/* Vector table section */
.section .isr_vector,"a",%progbits
.global g_pfnVectors
g_pfnVectors:
    .word _estack               @ 0: Initial Main Stack Pointer
    .word Reset_Handler         @ 1: Reset
    .word NMI_Handler           @ 2: NMI
    .word HardFault_Handler     @ 3: HardFault
    .word MemManage_Handler     @ 4: MemManage (MPU)
    .word BusFault_Handler      @ 5: BusFault
    .word UsageFault_Handler    @ 6: UsageFault
    .word SecureFault_Handler   @ 7: SecureFault (M33)
    .word 0                     @ 8: Reserved
    .word 0                     @ 9: Reserved
    .word 0                     @ 10: Reserved
    .word SVC_Handler           @ 11: SVCall
    .word DebugMon_Handler      @ 12: Debug Monitor
    .word 0                     @ 13: Reserved
    .word PendSV_Handler        @ 14: PendSV
    .word SysTick_Handler       @ 15: SysTick
    @ External IRQs would follow here...
    .word UART_Handler          @ 16: UART IRQ (example)

.text
.thumb
.align 2
.global Reset_Handler
Reset_Handler:
    @ Mask interrupts during initialization
    cpsid   i

    @ Call system initialization (optional)
    bl      SystemInit

    @ Set vector table base address
    ldr     r0, =g_pfnVectors
    ldr     r1, =0xE000ED08      @ SCB->VTOR register
    str     r0, [r1]
    dsb
    isb

    @ Copy .data section from Flash to RAM
    ldr     r0, =_sidata         @ Flash source
    ldr     r1, =_sdata          @ RAM destination start
    ldr     r2, =_edata          @ RAM destination end
data_copy_loop:
    cmp     r1, r2
    bcs     data_copy_done
    ldr     r3, [r0], #4
    str     r3, [r1], #4
    b       data_copy_loop
data_copy_done:

    @ Zero initialize .bss section
    ldr     r1, =_sbss           @ BSS start
    ldr     r2, =_ebss           @ BSS end
    movs    r3, #0
bss_clear_loop:
    cmp     r1, r2
    bcs     bss_clear_done
    str     r3, [r1], #4
    b       bss_clear_loop
bss_clear_done:

    @ Enable interrupts after initialization
    cpsie   i

    @ Call main function
    bl      main

    @ If main returns, loop forever
infinite_loop:
    b       infinite_loop

@ Weak default system initialization
.weak SystemInit
.type SystemInit,%function
SystemInit:
    bx      lr

@ Default exception handler
.global Default_Handler
.type Default_Handler,%function
Default_Handler:
    b       Default_Handler

@ Create weak aliases for all exception handlers
.macro DEFHAND name
    .weak \name
    .thumb_set \name, Default_Handler
.endm

DEFHAND NMI_Handler
DEFHAND HardFault_Handler
DEFHAND MemManage_Handler
DEFHAND BusFault_Handler
DEFHAND UsageFault_Handler
DEFHAND SecureFault_Handler
DEFHAND SVC_Handler
DEFHAND DebugMon_Handler
DEFHAND PendSV_Handler
DEFHAND SysTick_Handler
DEFHAND UART_Handler
