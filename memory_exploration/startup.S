.syntax unified
.cpu cortex-m33
.thumb

.section .isr_vector, "a"
.align 2
.globl __isr_vector
__isr_vector:
    .long   0x20010000          /* Top of Stack */
    .long   Reset_Handler       /* Reset Handler */
    .long   0                   /* NMI Handler */
    .long   0                   /* Hard Fault Handler */
    
.text
.thumb_func
.globl Reset_Handler
Reset_Handler:
    /* Initialize stack pointer */
    ldr sp, =0x20010000
    
    /* Zero out BSS section */
    ldr r0, =__bss_start__
    ldr r1, =__bss_end__
    mov r2, #0
bss_loop:
    cmp r0, r1
    bge bss_done
    str r2, [r0]
    add r0, r0, #4
    b bss_loop
bss_done:

    /* Call main function */
    bl main
    
    /* Infinite loop if main returns */
loop_forever:
    b loop_forever

.end
