# Simple RISC-V assembly test program
.section .text
.global _start

_start:
    # Set stack pointer
    li sp, 0x80100000
    
    # UART0 base address
    li a0, 0x10013000
    
    # Send 'H'
    li a1, 0x48
    sb a1, 0(a0)
    
    # Send 'i'
    li a1, 0x69
    sb a1, 0(a0)
    
    # Send newline
    li a1, 0x0A
    sb a1, 0(a0)
    
loop:
    wfi
    j loop
