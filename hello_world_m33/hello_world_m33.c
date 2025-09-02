/*
 * ARM Cortex-M33 Hello World Demo
 * Educational bare-metal program demonstrating UART communication
 * and basic embedded systems concepts for learning purposes.
 */

#include <stdint.h>

/* ARM PL011 UART Register Definitions */
#define UART_BASE       0x40000000

#define UART_DR         (*(volatile uint32_t*)(UART_BASE + 0x00))   /* Data Register */
#define UART_FR         (*(volatile uint32_t*)(UART_BASE + 0x18))   /* Flag Register */
#define UART_IBRD       (*(volatile uint32_t*)(UART_BASE + 0x24))   /* Integer Baud Rate */
#define UART_FBRD       (*(volatile uint32_t*)(UART_BASE + 0x28))   /* Fractional Baud Rate */
#define UART_LCRH       (*(volatile uint32_t*)(UART_BASE + 0x2C))   /* Line Control */
#define UART_CR         (*(volatile uint32_t*)(UART_BASE + 0x30))   /* Control Register */
#define UART_IMSC       (*(volatile uint32_t*)(UART_BASE + 0x38))   /* Interrupt Mask */

/* UART Flag Register bits */
#define UART_FR_TXFF    (1 << 5)    /* Transmit FIFO Full */
#define UART_FR_BUSY    (1 << 3)    /* UART Busy */

/* UART Control Register bits */
#define UART_CR_UARTEN  (1 << 0)    /* UART Enable */
#define UART_CR_TXE     (1 << 8)    /* Transmit Enable */
#define UART_CR_RXE     (1 << 9)    /* Receive Enable */

/* UART Line Control Register bits */
#define UART_LCRH_WLEN8 (3 << 5)    /* 8-bit word length */
#define UART_LCRH_FEN   (1 << 4)    /* FIFO Enable */

/* Simple delay function (not precise timing) */
static void delay(volatile uint32_t count) {
    while (count--) {
        __asm__ volatile ("nop");
    }
}

/* Initialize the UART for communication */
static void uart_init(void) {
    /* Disable UART during configuration */
    UART_CR = 0;
    
    /* Set baud rate to 115200 (assuming 24MHz clock) */
    /* Baud rate calculation: baud_div = clock_freq / (16 * baud_rate) */
    /* For 24MHz / (16 * 115200) = 13.02 */
    UART_IBRD = 13;      /* Integer part */
    UART_FBRD = 1;       /* Fractional part (approximate) */
    
    /* Configure: 8 data bits, no parity, 1 stop bit, FIFO enabled */
    UART_LCRH = UART_LCRH_WLEN8 | UART_LCRH_FEN;
    
    /* Disable interrupts for this simple demo */
    UART_IMSC = 0;
    
    /* Enable UART, transmit, and receive */
    UART_CR = UART_CR_UARTEN | UART_CR_TXE | UART_CR_RXE;
    
    /* Small delay to ensure UART is ready */
    delay(1000);
}

/* Send a single character via UART */
static void uart_putchar(char c) {
    /* Wait until transmit FIFO is not full */
    while (UART_FR & UART_FR_TXFF) {
        /* Wait */
    }
    
    /* Send the character */
    UART_DR = c;
}

/* Send a string via UART */
static void uart_puts(const char* str) {
    while (*str) {
        /* Convert line feeds to carriage return + line feed */
        if (*str == '\n') {
            uart_putchar('\r');
        }
        uart_putchar(*str++);
    }
}

/* Send a number as decimal via UART */
static void uart_put_number(uint32_t num) {
    char buffer[12];  /* Enough for 32-bit number */
    char* ptr = buffer + sizeof(buffer) - 1;
    
    *ptr = '\0';  /* Null terminator */
    
    if (num == 0) {
        *(--ptr) = '0';
    } else {
        while (num > 0) {
            *(--ptr) = '0' + (num % 10);
            num /= 10;
        }
    }
    
    uart_puts(ptr);
}

/* Function prototype for SystemInit */
void SystemInit(void);

/* System initialization function (called from startup) */
void SystemInit(void) {
    /* For this simple demo, we don't need complex system initialization */
    /* In a real application, you might configure clocks, caches, etc. */
}

/* Main application function */
int main(void) {
    uint32_t counter = 0;
    
    /* Initialize the UART for output */
    uart_init();
    
    /* Send startup message */
    uart_puts("===========================================\n");
    uart_puts("ARM Cortex-M33 Custom Board Demo\n");
    uart_puts("===========================================\n");
    uart_puts("Board: Custom ARM Cortex-M33 Board (Renode)\n");
    uart_puts("CPU: ARM Cortex-M33 @ 100MHz\n");
    uart_puts("Memory: 1MB Flash + 256KB SRAM\n");
    uart_puts("UART: PL011 @ 115200 baud\n");
    uart_puts("===========================================\n\n");
    
    uart_puts("Starting counter demonstration...\n");
    uart_puts("This demonstrates basic UART communication\n");
    uart_puts("and timing on a custom ARM Cortex-M33 board.\n\n");
    
    /* Main application loop */
    while (1) {
        uart_puts("Counter: ");
        uart_put_number(counter);
        uart_puts(" - Cortex-M33 is running!\n");
        
        counter++;
        
        /* Add a delay between messages */
        delay(2000000);  /* Approximate 1 second delay */
        
        /* Reset counter after reaching 100 for cleaner demo */
        if (counter > 100) {
            counter = 0;
            uart_puts("\n--- Counter reset ---\n\n");
        }
    }
    
    /* This point should never be reached */
    return 0;
}
