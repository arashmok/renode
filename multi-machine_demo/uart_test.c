// Simple UART test without standard headers
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
    
    uart_puts(UART0_BASE, "Machine starting...\n");
    uart_puts(UART1_BASE, "Hello from machine!\n");
    
    while(1) {
        __asm__ volatile("wfi");
    }
}
