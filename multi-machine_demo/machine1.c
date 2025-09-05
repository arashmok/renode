typedef unsigned int uint32_t;
typedef unsigned char uint8_t;

#define UART0_BASE 0x10013000
#define UART1_BASE 0x10023000
#define UART_THR   0x00  
#define UART_LSR   0x14  
#define UART_LSR_THRE 0x20  

static void uart_putc(uint32_t base, char c) {
    volatile uint8_t *lsr = (uint8_t*)(base + UART_LSR);
    volatile uint8_t *thr = (uint8_t*)(base + UART_THR);
    while (!(*lsr & UART_LSR_THRE));
    *thr = c;
}

static void uart_puts(uint32_t base, const char *s) {
    while (*s) {
        if (*s == '\n') uart_putc(base, '\r');
        uart_putc(base, *s++);
    }
}

void _start(void) {
    __asm__ volatile("li sp, 0x80100000");
    
    uart_puts(UART0_BASE, "[Machine1] Starting...\n");
    
    for(int i = 0; i < 3; i++) {
        uart_puts(UART0_BASE, "[Machine1] Sending message ");
        uart_putc(UART0_BASE, '0' + i);
        uart_puts(UART0_BASE, "\n");
        
        uart_puts(UART1_BASE, "MSG");
        uart_putc(UART1_BASE, '0' + i);
        uart_puts(UART1_BASE, " from Machine1\n");
        
        // Simple delay
        for(volatile int j = 0; j < 100000; j++);
    }
    
    uart_puts(UART0_BASE, "[Machine1] Done sending\n");
    
    while(1) {
        __asm__ volatile("wfi");
    }
}
